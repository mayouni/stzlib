# BERT forward-pass PARITY -- the ground truth the behavioral probes never had.
#
# The neural tier's transformer forward (neural_embed.zig) has run real
# MiniLM models for a while, but nothing ever compared its NUMBERS against
# an independent implementation -- the semantic probes assert behavior
# (similarity separations), which a subtly wrong forward could still pass.
#
# This guard closes that: tiny_bert.gguf is a synthetic BERT (random
# weights, seed 42, 83 KB, COMMITTED -- so CI runs this with no model
# download) and bert_parity_expected.ring carries token ids + embeddings
# computed by an INDEPENDENT numpy forward pass (float32, engine op
# order). Tokenizer ids must match EXACTLY -- ##-continuations, punctuation
# splits, and the [UNK] word included; embeddings must match within a band
# SET FROM MEASUREMENT (f32 accumulation-order noise only).
#
# Regenerate the fixture (deterministic): python tools/gen_tiny_bert.py

load "../../stzBase.ring"
load "bert_parity_expected.ring"

nPass = 0
nFail = 0

pr()

decimals(12)

? "-- Scene 0: the tiny model loads like any GGUF --"
chk("tiny_bert.gguf loads", StzEngineNeuralModelLoad("tiny_bert.gguf") = 1)
chk("architecture reads back as bert", StzEngineNeuralModelArch() = "bert")
chk("hyperparameters read back (32 dims, 2 layers, 2 heads)",
    StzEngineNeuralModelNEmbd() = 32 and StzEngineNeuralModelNLayers() = 2 and
    StzEngineNeuralModelNHeads() = 2)

nCases = len(aBertParityCases)
? ""
? "-- Scene 1: the tokenizer matches the reference EXACTLY, id by id --"
for c = 1 to nCases
    cText = aBertParityCases[c][1]
    aWant = aBertParityCases[c][2]
    nTok = StzEngineNeuralTokenize(cText)
    bOk = (nTok = len(aWant))
    if bOk
        for i = 1 to nTok
            if StzEngineNeuralTokenAt(i - 1) != aWant[i]
                bOk = FALSE
            ok
        next
    ok
    chk("ids exact: " + cText, bOk)
next

? ""
? "-- Scene 2: the forward pass matches the independent reference --"
nMaxDiff = 0
for c = 1 to nCases
    cText = aBertParityCases[c][1]
    aWant = aBertParityCases[c][3]
    nDim = StzEngineNeuralEmbed(cText)
    chk("embeds to 32 dims: " + cText, nDim = 32)
    if nDim = 32
        for i = 1 to 32
            _nD_ = fabs(StzEngineNeuralEmbedAt(i - 1) - aWant[i])
            if _nD_ > nMaxDiff
                nMaxDiff = _nD_
            ok
        next
    ok
next
? "  measured max |engine - reference| across " + nCases + " sentences: " + nMaxDiff
# band history: the first reference used plain tanh-GELU and measured
# 8.3e-5 -- the gap was ggml's GGML_GELU_FP16 table (f16-quantized input
# AND output); mirroring it collapsed the diff 500x. Wrong math would
# show O(1) differences; this band is pure accumulation-order noise.
chk("parity band: max abs diff < 2e-5 (measured 1.64e-7 with the f16-GELU mirror)",
    nMaxDiff < 0.00002)

? ""
? "-- Scene 3: deterministic, and discriminating --"
StzEngineNeuralEmbed(aBertParityCases[1][1])
aFirst = []
for i = 1 to 32
    aFirst + StzEngineNeuralEmbedAt(i - 1)
next
StzEngineNeuralEmbed(aBertParityCases[1][1])
bSame = TRUE
for i = 1 to 32
    if StzEngineNeuralEmbedAt(i - 1) != aFirst[i]
        bSame = FALSE
    ok
next
chk("embedding the same text twice is BYTE-identical", bSame)
# different sentences on a random-weight model must NOT collapse together
StzEngineNeuralEmbed(aBertParityCases[2][1])
nCos = 0
for i = 1 to 32
    nCos += aFirst[i] * StzEngineNeuralEmbedAt(i - 1)
next
? "  cos(sentence1, sentence2) = " + nCos
chk("different sentences give distinct vectors (|cos| < 0.99)", fabs(nCos) < 0.99)

StzEngineNeuralModelFree()
chk("model freed", StzEngineNeuralModelLoaded() = 0)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func fabs n
	if n < 0 return -n ok
	return n
