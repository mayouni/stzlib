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
# hearing-v3's items (fleurs_v3.tsv): the next ten of each archive
NEXT = {
    "fr_fr": "10174413140250646001.wav 10221277978969763776.wav 10334413597118469552.wav 10385751433252343757.wav 10399459061919571703.wav 10451502537136425109.wav 10473501692975174389.wav 10481242713503018126.wav 10496509281839367149.wav 10550408276028637262.wav".split(),
    "en_us": "10235738076911595987.wav 10323357556845456822.wav 10335587906469246566.wav 10344335557154974057.wav 1036771894648013441.wav 1038214857203833067.wav 10383288285905292158.wav 10405958125670257178.wav 10411016628242228511.wav 1042003289011443756.wav".split(),
    "ar_eg": "10223562251993082117.wav 10340788584398631536.wav 1035166469684084794.wav 10361044285640817256.wav 10366294495925707527.wav 10372562911047932559.wav 10394942145902478734.wav 10427622000895658817.wav 10459237854135592487.wav 10482686991657251883.wav".split(),
    "ha_ng": "10623312076286681949.wav 10638829075402093921.wav 10642781891041506444.wav 10657622312586281522.wav 10682387719049649408.wav 10689944351391995888.wav 10768008037567316007.wav 1077849305568046366.wav 10849188633248803659.wav 10916169113204290877.wav".split(),
}
EXPECTED = {
    "ar_eg": ["10019390257075855641.wav", "10035416633083120372.wav", "10080665469720750912.wav",
              "1021284281927612037.wav", "10219273669592698682.wav"],
    "fr_fr": ["10043298898524273336.wav", "10097171356371990207.wav", "10138021779681596478.wav",
              "10143749263702132703.wav", "10166091086920486572.wav"],
    "en_us": ["1003119935936341070.wav", "10052240106321793346.wav", "10167324587744183095.wav",
              "10197164397713068203.wav", "10233995782544396174.wav"],
    "ha_ng": ["10063376879559181525.wav", "1011451118830394019.wav", "10130278018512375037.wav",
              "10203648568113620209.wav", "10262687583681135357.wav",
              # recordings 6 to 15: hearing-v2's fresh Hausa items (hausa_fresh.tsv)
              "10270881705223021661.wav", "10274607477242713999.wav", "10275407413289163724.wav", "10291405143076270704.wav",
              "10340343059762214769.wav", "10435630491638189387.wav", "10460143409645722218.wav", "10511075547046752697.wav",
              "10529716865753778831.wav", "10600401760102194440.wav"],
}

for config in NEXT:
    EXPECTED[config] = EXPECTED[config] + NEXT[config]

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
