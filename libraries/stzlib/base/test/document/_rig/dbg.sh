#!/bin/bash
# dbg.sh <mkdbgN.py> <pdf> [grep] -- build a debug probe from the live pdf.zig and run it
S="${RIG_WORK:-/tmp/pdfrig}"
cd $S && python $1 D:/GitHub/_wti_pub/libraries/stzlib/engine/src/pdf.zig pdf_dbg.zig >/dev/null && zig build-exe -O ReleaseSafe --dep pdf -Mroot=probe.zig -Mpdf=pdf_dbg.zig -femit-bin=probe_dbg.exe 2>&1 | head -5
./probe_dbg.exe $2 2>&1 | grep -E "${3:-.}"
