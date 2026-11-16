"""Whisper, read from whisper.cpp's ggml file and run in numpy -- the reference the engine's speech graph is checked against.

    python -I whisper_reference.py <ggml-small.bin> <recording.wav> [language|auto] [--dump <folder>]

The recording is 16-bit PCM, mono, 16 kHz. Prints the language the model detects (the language token it ranks first after
<|startoftranscript|>), then the greedy transcript in the given language (the detected one with `auto`). With --dump, writes
the log-mel (80 x 3000), the encoder's output (1500 x d) and the first decoding step's logits as float32 .npy files, for a
parity check with the engine.

The model as OpenAI's whisper/model.py defines it, in float32: two convolutions with exact (erf) GELU, sinusoidal positions
read from the file, pre-LayerNorm blocks (eps 1e-5), attention scaled by 1/sqrt(head), the key projection without a bias;
the decoder's output projection is its token embedding. The log-mel as whisper/audio.py computes it: 30 s of samples (zeros
after the recording), a 400-sample periodic Hann window every 160 samples on the reflect-padded signal, the power spectrum
through the file's 80 mel filters, log10 clamped at 1e-10, floored 8 below its maximum, then (x + 4) / 4.
"""
import struct
import sys
import wave

import numpy as np
from scipy.special import erf

SAMPLE_RATE = 16000
N_SAMPLES = 480000
N_FFT = 400
HOP = 160

LANGUAGES = ("en zh de es ru ko fr ja pt tr pl ca nl ar sv it id hi fi vi he uk el ms cs ro da hu ta no th ur hr bg lt la mi ml "
             "cy sk te fa lv bn sr az sl kn et mk br eu is hy ne mn bs kk sq sw gl mr pa si km sn yo so af oc ka be tg sd gu am "
             "yi lo uz fo ht ps tk nn mt sa lb my bo tl mg as tt haw ln ha ba jw su").split()

EOT, SOT = 50257, 50258
TRANSCRIBE, NO_TIMESTAMPS = 50359, 50363


def read_model(path):
    with open(path, "rb") as f:
        data = f.read()
    at = 0

    def ints(n):
        nonlocal at
        v = struct.unpack_from("<%di" % n, data, at)
        at += 4 * n
        return v

    assert ints(1)[0] == 0x67676D6C, "not a whisper.cpp ggml file"
    names = ("n_vocab n_audio_ctx n_audio_state n_audio_head n_audio_layer n_text_ctx n_text_state n_text_head "
             "n_text_layer n_mels ftype").split()
    hp = dict(zip(names, ints(11)))
    n_mel, n_fft = ints(2)
    filters = np.frombuffer(data, np.float32, n_mel * n_fft, at).reshape(n_mel, n_fft)
    at += 4 * n_mel * n_fft
    n_words = ints(1)[0]
    vocab = []
    for _ in range(n_words):
        n = ints(1)[0]
        vocab.append(data[at:at + n])
        at += n
    tensors = {}
    while at < len(data):
        n_dims, n_name, ttype = ints(3)
        ne = ints(n_dims)
        name = data[at:at + n_name].decode()
        at += n_name
        count = int(np.prod(ne))
        dtype = {0: np.float32, 1: np.float16}[ttype]
        arr = np.frombuffer(data, dtype, count, at).astype(np.float32)
        at += count * np.dtype(dtype).itemsize
        tensors[name] = arr.reshape(tuple(reversed(ne)))
    return hp, filters, vocab, tensors


def read_wav(path):
    with wave.open(path, "rb") as w:
        assert w.getframerate() == SAMPLE_RATE and w.getnchannels() == 1 and w.getsampwidth() == 2, \
            "the recording must be 16 kHz, mono, 16-bit"
        pcm = np.frombuffer(w.readframes(w.getnframes()), np.int16)
    return pcm.astype(np.float32) / 32768.0


def log_mel(audio, filters):
    x = np.zeros(N_SAMPLES + N_FFT, np.float32)                   # zeros past 30 s, so the 3000th frame is whole
    n = min(len(audio), N_SAMPLES)
    x[:n] = audio[:n]
    x = np.concatenate([x[1:N_FFT // 2 + 1][::-1], x])        # torch.stft(center=True) reflects the start
    window = (0.5 - 0.5 * np.cos(2 * np.pi * np.arange(N_FFT) / N_FFT)).astype(np.float32)
    frames = np.lib.stride_tricks.sliding_window_view(x, N_FFT)[::HOP][:3000] * window
    power = np.abs(np.fft.rfft(frames.astype(np.float64), axis=1)) ** 2     # 3000 x 201
    mel = filters.astype(np.float64) @ power.T                               # 80 x 3000
    lg = np.log10(np.maximum(mel, 1e-10))
    lg = np.maximum(lg, lg.max() - 8.0)
    return ((lg + 4.0) / 4.0).astype(np.float32)


def gelu(x):
    return 0.5 * x * (1.0 + erf(x / np.sqrt(2.0)))


def layer_norm(x, w, b):
    m = x.mean(-1, keepdims=True)
    v = ((x - m) ** 2).mean(-1, keepdims=True)
    return (x - m) / np.sqrt(v + 1e-5) * w + b


def conv1d(x, w, b, stride):
    # x: (C_in, T), w: (C_out, C_in, 3), padding 1
    xp = np.pad(x, ((0, 0), (1, 1)))
    T = (x.shape[1] + 2 - 3) // stride + 1
    cols = np.stack([xp[:, k:k + stride * (T - 1) + 1:stride] for k in range(3)], axis=-1)   # (C_in, T, 3)
    return np.einsum("oik,itk->ot", w, cols) + b.reshape(-1, 1)


def attention(t, p, x, src, heads, causal):
    q = x @ t[p + "query.weight"].T + t[p + "query.bias"]
    k = src @ t[p + "key.weight"].T
    v = src @ t[p + "value.weight"].T + t[p + "value.bias"]
    n, d = q.shape
    hd = d // heads
    q = q.reshape(n, heads, hd).transpose(1, 0, 2)
    k = k.reshape(-1, heads, hd).transpose(1, 0, 2)
    v = v.reshape(-1, heads, hd).transpose(1, 0, 2)
    s = q @ k.transpose(0, 2, 1) / np.sqrt(hd)
    if causal:
        s = s + np.triu(np.full((n, n), -np.inf, np.float32), 1)
    s = s - s.max(-1, keepdims=True)
    e = np.exp(s)
    a = e / e.sum(-1, keepdims=True)
    o = (a @ v).transpose(1, 0, 2).reshape(n, d)
    return o @ t[p + "out.weight"].T + t[p + "out.bias"]


def mlp(t, p, x):
    return gelu(x @ t[p + "mlp.0.weight"].T + t[p + "mlp.0.bias"]) @ t[p + "mlp.2.weight"].T + t[p + "mlp.2.bias"]


def encode(hp, t, mel):
    x = gelu(conv1d(mel, t["encoder.conv1.weight"], t["encoder.conv1.bias"], 1))
    x = gelu(conv1d(x, t["encoder.conv2.weight"], t["encoder.conv2.bias"], 2))
    x = x.T + t["encoder.positional_embedding"]
    for i in range(hp["n_audio_layer"]):
        p = "encoder.blocks.%d." % i
        h = layer_norm(x, t[p + "attn_ln.weight"], t[p + "attn_ln.bias"])
        x = x + attention(t, p + "attn.", h, h, hp["n_audio_head"], False)
        x = x + mlp(t, p, layer_norm(x, t[p + "mlp_ln.weight"], t[p + "mlp_ln.bias"]))
    return layer_norm(x, t["encoder.ln_post.weight"], t["encoder.ln_post.bias"])


def decode_logits(hp, t, tokens, enc):
    x = t["decoder.token_embedding.weight"][tokens] + t["decoder.positional_embedding"][:len(tokens)]
    for i in range(hp["n_text_layer"]):
        p = "decoder.blocks.%d." % i
        h = layer_norm(x, t[p + "attn_ln.weight"], t[p + "attn_ln.bias"])
        x = x + attention(t, p + "attn.", h, h, hp["n_text_head"], True)
        h = layer_norm(x, t[p + "cross_attn_ln.weight"], t[p + "cross_attn_ln.bias"])
        x = x + attention(t, p + "cross_attn.", h, enc, hp["n_text_head"], False)
        x = x + mlp(t, p, layer_norm(x, t[p + "mlp_ln.weight"], t[p + "mlp_ln.bias"]))
    x = layer_norm(x, t["decoder.ln.weight"], t["decoder.ln.bias"])
    return x[-1] @ t["decoder.token_embedding.weight"].T


def detect_language(hp, t, enc):
    logits = decode_logits(hp, t, [SOT], enc)
    lang = logits[SOT + 1:SOT + 1 + len(LANGUAGES)]
    return LANGUAGES[int(np.argmax(lang))]


def transcribe(hp, t, vocab, enc, language, max_tokens=96):
    tokens = [SOT, SOT + 1 + LANGUAGES.index(language), TRANSCRIBE, NO_TIMESTAMPS]
    first = None
    out = []
    for _ in range(max_tokens):
        logits = decode_logits(hp, t, tokens, enc)
        if first is None:
            first = logits
        nxt = int(np.argmax(logits[:EOT + 1]))       # text tokens and the end: no special token is chosen
        if nxt == EOT:
            break
        tokens.append(nxt)
        out.append(nxt)
    text = b"".join(vocab[i] for i in out if i < len(vocab)).decode("utf-8", "replace")
    return text.strip(), first


def main():
    args = sys.argv[1:]
    dump = None
    if "--dump" in args:
        i = args.index("--dump")
        dump = args[i + 1]
        del args[i:i + 2]
    hp, filters, vocab, t = read_model(args[0])
    mel = log_mel(read_wav(args[1]), filters)
    enc = encode(hp, t, mel)
    detected = detect_language(hp, t, enc)
    language = args[2] if len(args) > 2 and args[2] != "auto" else detected
    text, first = transcribe(hp, t, vocab, enc, language)
    print("language\t" + detected)
    print("text\t" + text)
    if dump:
        np.save(dump + "/mel.npy", mel)
        np.save(dump + "/encoder.npy", enc.astype(np.float32))
        np.save(dump + "/logits0.npy", first.astype(np.float32))


if __name__ == "__main__":
    main()
