"""Word error rate of transcripts against FLEURS' own transcriptions.

    python -I _rig/wer.py [--fold-hooks] <transcripts .tsv> [<more .tsv> ...]

A transcripts file holds one line a recording: its path (ending in <config>/<file>.wav), a tab, the words. The reference
is the normalised transcription in recordings/fleurs/<config>/test.tsv's metadata, fetched beside FLEURS' audio by
fleurs_fetch.py; both sides are put in small letters, with punctuation removed, before the words are aligned. With --fold-hooks, Hausa's hooked letters are read as their plain ones on both sides
(ɓ b, ɗ d, ƙ k, ƴ y, and the apostrophe dropped): FLEURS' own Hausa transcriptions write them in some words and not in
others ("haƙiƙa" and "hakika"), so the folded score counts words, not that spelling.
"""
import io
import os
import re
import sys
import unicodedata
import urllib.request

FLEURS_TSV = "https://huggingface.co/datasets/google/fleurs/resolve/main/data/{}/test.tsv"


FOLD = False
HOOKS = {"ɓ": "b", "ɗ": "d", "ƙ": "k", "ƴ": "y", "Ɓ": "b", "Ɗ": "d", "Ƙ": "k", "Ƴ": "y", "'": ""}


def words(t):
    t = unicodedata.normalize("NFC", t).lower()
    if FOLD:
        t = "".join(HOOKS.get(c, c) for c in t)
    t = "".join(c if (c.isalnum() or c.isspace() or c in "'") else " " for c in t)
    return t.split()


def edits(a, b):
    d = list(range(len(b) + 1))
    for i in range(1, len(a) + 1):
        prev, d[0] = d[0], i
        for j in range(1, len(b) + 1):
            cur = min(d[j] + 1, d[j - 1] + 1, prev + (a[i - 1] != b[j - 1]))
            prev, d[j] = d[j], cur
    return d[len(b)]


refs = {}
args = sys.argv[1:]
if "--fold-hooks" in args:
    FOLD = True
    args.remove("--fold-hooks")
for path in args:
    total_e = total_n = 0
    for line in io.open(path, encoding="utf-8"):
        if "\t" not in line:
            continue
        rec, hyp = line.rstrip("\n").split("\t", 1)
        config, name = rec.replace("\\", "/").split("/")[-2:]
        if config not in refs:
            refs[config] = {}
            meta = urllib.request.urlopen(FLEURS_TSV.format(config)).read().decode("utf-8")
            for row in meta.splitlines():
                f = row.split("\t")
                if len(f) > 3:
                    refs[config][f[1]] = f[3]
        ref = words(refs[config][name])
        e = edits(ref, words(hyp))
        total_e += e
        total_n += len(ref)
        print("%-28s WER %5.1f%%  (%d of %d words)" % (name, 100.0 * e / len(ref), e, len(ref)))
    print("%s: WER %.1f%% over %d reference words" % (os.path.basename(path), 100.0 * total_e / total_n, total_n))
