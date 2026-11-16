"""Fetch the FLEURS recordings: the first five recordings of FLEURS' test split for Arabic (ar_eg) and Hausa (ha_ng) --
the hearing-local tasks -- and for French (fr_fr) and English (en_us), which with them make the spoken-language golden set, read from Google's archives on Hugging Face as a STREAM and stopped after the fifth, so a few MB are
read of archives of 243 and 602 MB.

    python -I _rig/fleurs_fetch.py            (from the clusterbench folder; writes recordings/fleurs/<config>/*.wav)

FLEURS (Conneau et al., 2022) is Google's, licensed CC BY 4.0: https://huggingface.co/datasets/google/fleurs. The
recordings are not kept in this repository; tasks.tsv names the five files of each language, and this checks that the
archive still starts with them.
"""
import os
import sys
import tarfile
import urllib.request

URL = "https://huggingface.co/datasets/google/fleurs/resolve/main/data/{}/audio/test.tar.gz"
EXPECTED = {
    "ar_eg": ["10019390257075855641.wav", "10035416633083120372.wav", "10080665469720750912.wav",
              "1021284281927612037.wav", "10219273669592698682.wav"],
    "fr_fr": ["10043298898524273336.wav", "10097171356371990207.wav", "10138021779681596478.wav",
              "10143749263702132703.wav", "10166091086920486572.wav"],
    "en_us": ["1003119935936341070.wav", "10052240106321793346.wav", "10167324587744183095.wav",
              "10197164397713068203.wav", "10233995782544396174.wav"],
    "ha_ng": ["10063376879559181525.wav", "1011451118830394019.wav", "10130278018512375037.wav",
              "10203648568113620209.wav", "10262687583681135357.wav"],
}

for config, names in EXPECTED.items():
    out = os.path.join("recordings", "fleurs", config)
    os.makedirs(out, exist_ok=True)
    got = []
    with urllib.request.urlopen(URL.format(config)) as resp, tarfile.open(fileobj=resp, mode="r|gz") as tar:
        for m in tar:
            name = os.path.basename(m.name)
            if not m.isfile() or name not in names:
                continue
            with open(os.path.join(out, name), "wb") as f:
                f.write(tar.extractfile(m).read())
            got.append(name)
            if len(got) == len(names):
                break
    missing = sorted(set(names) - set(got))
    print(config, len(got), "of", len(names), "recordings" + ("; missing " + ", ".join(missing) if missing else ""))
    if missing:
        sys.exit(1)
