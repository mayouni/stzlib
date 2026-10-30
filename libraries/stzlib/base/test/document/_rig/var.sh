#!/bin/bash
# var.sh <name> <old> <new> -- build probe_<name>.exe from live pdf.zig with one replacement
S="${RIG_WORK:-/tmp/pdfrig}"
cd $S
python - "$2" "$3" <<'PY'
import sys
s=open('D:/GitHub/_wti_pub/libraries/stzlib/engine/src/pdf.zig',encoding='utf-8',newline='').read().replace('\r\n','\n')
assert s.count(sys.argv[1])==1, s.count(sys.argv[1])
open('pdf_var.zig','w',encoding='utf-8',newline='').write(s.replace(sys.argv[1],sys.argv[2]))
PY
zig build-exe -O ReleaseSafe --dep pdf -Mroot=probe.zig -Mpdf=pdf_var.zig -femit-bin=probe_$1.exe 2>&1 | head -5
