#!/bin/bash
# runwave.sh <Class> -- apply the class's wave docs (w1_docs_<Class>.json in $DOCWAVE_DIR) on the
# pristine sources, export the four pilot classes and print what still fails.
# needs: DOCWAVE_CLASSES (default the four pilot classes; set it to the wave's classes), DOCWAVE_DIR (scratch folder), DOCWAVE_BASE (.../libraries/stzlib/base), RING (ring executable)
set -e
cd "$DOCWAVE_DIR"
python "$DOCWAVE_BASE/doc/tools/pilot/reapply_all.py" . "$1"
(cd "$DOCWAVE_BASE/test/reflect" && "${RING:-ring}" ../../doc/tools/wave/export_classes.ring "$DOCWAVE_DIR/ref_pilot.json" ${DOCWAVE_CLASSES:-stzString stzList stzNumber stzHashList} 2>&1 | tail -2)
python - "$1" <<'PY'
import json, sys
r = json.load(open("ref_pilot.json", encoding="utf-8"))
for c in r["classes"]:
    if c["name"] != sys.argv[1]:
        continue
    ms = c["methods"]
    f = [m for m in ms if not m.get("pass")]
    print(c["name"], len(ms), "fail", len(f))
    for m in f[:60]:
        print(" ", m["name"], m.get("checks"), "|", (m.get("brief") or "")[:70])
PY
