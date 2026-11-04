"""IM9f: the token ids Hugging Face's CLIPTokenizer gives OWL-ViT's queries -- the GOLDEN the engine's tokenizer is held to.

    python owlvit_tokens.py <owlvit dir> <out.tsv>

One line per prompt: the 16 ids (padded as OWL-ViT pads), a tab, the prompt with \n and \t escaped. The prompts are written here, by hand, to
reach what a tokenizer gets wrong: contractions, digits, runs of punctuation, capitals, odd whitespace, words that take many merges, a query
too long for 16 tokens, and the empty query.
"""
import sys

from transformers import OwlViTProcessor

PROMPTS = [
    "a photo of a cat", "a photo of a laptop", "a photo of a keyboard", "a red mug", "the cat's left ear",
    "cat", "dog", "person", "traffic light", "stop sign", "fire hydrant", "teddy bear", "hair drier", "pizza", "a slice of pizza",
    "A Photo Of A CAT", "LAPTOP", "Red   Mug", "  leading and trailing  ", "tab\tseparated", "line\nbreak",
    "don't", "it's", "we've", "they're", "I'm", "she'll", "he'd", "o'clock", "rock'n'roll", "'quoted'", "''s",
    "2 dogs", "42", "007", "3.14159", "room 101", "mp3 player", "b52 bomber", "1990s", "x2", "2x",
    "hello, world!", "what?!", "a--b", "(parentheses)", "[brackets]", "{braces}", "a/b", "a\b", "50% off", "$100", "#hashtag", "@mention", "e.g.", "...", "!!!", "a & b", "a + b = c",
    "http://example.com/a?b=c", "snake_case_name", "CamelCaseName", "kebab-case-name",
    "pneumonoultramicroscopicsilicovolcanoconiosis", "supercalifragilisticexpialidocious", "antidisestablishmentarianism",
    "a very long query that goes on and on and on and on and on and on and on and on",
    "one two three four five six seven eight nine ten eleven twelve thirteen fourteen",
    "a b c d e f g h i j k l m n o", "a b c d e f g h i j k l m n o p",
    "", " ", "a",
    "traffic cone", "street sign", "coffee cup", "wine glass", "baseball bat", "tennis racket", "potted plant", "dining table", "cell phone", "remote control",
    "the logo of a company", "a handwritten signature", "a barcode", "a QR code", "a stamp", "an ink stamp on paper", "a table with 3 columns", "a photo taken at night",
    "caf\u00e9", "na\u00efve", "\u00fcber", "\u65e5\u672c\u8a9e", "\u043a\u043e\u0448\u043a\u0430", "emoji \U0001F600 face", "\u00c9cole",
]


def main(model_dir, out):
    proc = OwlViTProcessor.from_pretrained(model_dir)
    tk = proc.tokenizer
    rows = []
    for p in PROMPTS:
        ids = tk(p, padding="max_length", max_length=16, truncation=True)["input_ids"]
        assert len(ids) == 16
        bs = chr(92)
        esc = p.replace(bs, bs + bs).replace(chr(10), bs + "n").replace(chr(9), bs + "t")
        rows.append(" ".join(map(str, ids)) + chr(9) + esc)
    open(out, "w", encoding="utf-8", newline="\n").write("\n".join(rows) + "\n")
    print(len(rows), "prompts written to", out)
    try:
        import ftfy  # noqa: F401
        print("ftfy is installed: HF used its ftfy path")
    except ImportError:
        print("ftfy is NOT installed: HF used its BasicTokenizer fallback (accents stripped, every script lower-cased)")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
