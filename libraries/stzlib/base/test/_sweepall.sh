#!/usr/bin/env bash
# Broad correctness sweep: run every example under base/test/<module>/,
# categorize ok / FAIL / HANG. Prints failures inline + a per-module
# tally and a grand total at the end.
cd /d/GitHub/stzlib/libraries/stzlib/base/test || exit 1
TIMEOUT=20
total_ok=0; total_fail=0; total_hang=0
for d in */; do
  d="${d%/}"
  case "$d" in _data|_smoke|_tmp) continue;; esac
  [ -d "$d" ] || continue
  shopt -s nullglob
  files=("$d"/*.ring)
  [ ${#files[@]} -eq 0 ] && continue
  mok=0; mfail=0; mhang=0
  for f in "${files[@]}"; do
    base=$(basename "$f")
    out=$( cd "$d" && timeout $TIMEOUT ring "$base" 2>&1 ); rc=$?
    if [ $rc -eq 124 ]; then
      echo "HANG $d/$base"; mhang=$((mhang+1))
    elif echo "$out" | grep -qE "Error \(R[0-9]|Error \(C[0-9]|panic|Segmentation|Can't open file"; then
      err=$(echo "$out" | grep -oE "Error \(R[0-9]+\)[^|]*|Error \(C[0-9]+\)[^|]*|panic[^|]*" | head -1)
      echo "FAIL $d/$base :: $err"; mfail=$((mfail+1))
    else
      mok=$((mok+1))
    fi
  done
  echo "#TALLY $d ok=$mok fail=$mfail hang=$mhang"
  total_ok=$((total_ok+mok)); total_fail=$((total_fail+mfail)); total_hang=$((total_hang+mhang))
done
echo "#GRANDTOTAL ok=$total_ok fail=$total_fail hang=$total_hang"
