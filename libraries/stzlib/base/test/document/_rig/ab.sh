#!/bin/bash
# ab.sh <tag> [sets...] -- rebuild Ring++ stz_file from _wti_pub's pdf.zig, run the sets in one process, score each
S="${RIG_WORK:-/tmp/pdfrig}"
TAG=$1; shift
SETS=${@:-"1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36"}
GD=D:/GitHub/_wti_pub/libraries/stzlib/base/test/document/_data
cp ${SRC:-/d/GitHub/_wti_pub/libraries/stzlib/engine/src/pdf.zig} /d/GitHub/_wti_rpp_engine/src/pdf.zig || exit 1
cd /d/GitHub/_wti_rpp_engine && ONLY=stz_file timeout 400 zig build -j2 2>&1 | grep -E "error" | head -5
cp /d/GitHub/_wti_rpp_engine/zig-out/bin/stz_file.dll /d/GitHub/_wti_rpp_tree/libraries/stzlib/engine/zig-out/bin/ || exit 1
rm -rf "$S/ab_$TAG" "$S/ab_${TAG}_res"
ARGS=""
for v in $SETS; do ARGS="$ARGS $GD/golden_v$v"; done
cd /d/GitHub/_wti_rpp_tree/libraries/stzlib/base/test/document && timeout 560 /d/GitHub/ringpp/zig-out/bin/rnxc.exe _native_predict.ring many "$S/ab_$TAG" $ARGS > "$S/ab_$TAG.log" 2>&1
cd /d/GitHub/_wti_pub/libraries/stzlib/base/test/document
for v in $SETS; do echo -n "v$v "; python -I -X utf8 _doc_score.py _data/golden_v$v "$S/ab_$TAG/golden_v$v" native "$S/ab_${TAG}_res" 2>&1 | tail -1 | sed 's/MACRO //'; done
for v in $SETS; do echo -n "v$v "; python -I -X utf8 "$S/head_precision.py" _data/golden_v$v "$S/ab_$TAG/golden_v$v" native; done
