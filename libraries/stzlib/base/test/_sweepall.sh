#!/usr/bin/env bash
# Broad correctness sweep: run every example under base/test/<module>/,
# categorize ok / RED / ERR / HANG. Prints problems inline + a
# per-module tally and a grand total at the end.
#
# WHAT COUNTS AS A PROBLEM -- and why this list grew.
# The first version looked only for Ring ERRORS (R.., C.., panic). A
# file that ran to completion and failed every one of its assertions
# printed no Ring error, so it was counted "ok". Not hypothetical:
# 305_substrongs_substrinks.ring documented the correct contract for
# SubStrongs/SubStrinks, failed 0/2 for months, and this sweep called
# it fine every time (fixed 2026-08-01, ccc7ca6c1). A sweep that cannot
# see a failed assertion is a compile check wearing a test suite's name.
#
# ASSERTION-BEARING FILES ARE FOUND BY CONTENT, NOT BY NAME. The glob
# below has always been *.ring and never needed widening -- but the
# narrated-only filters used elsewhere did: ~1000 assertion-bearing
# examples under string/ and list/ use Scenario()/Then() WITHOUT the
# _narrated suffix, and every sweep that filtered on the name skipped
# them. Anything printing "TOTAL: .. fail", "STATUS: FAILED" or a
# [FAIL] marker is judged here, whatever the file is called.
#
# The #ASSERTING line is the blind-spot metric: how many files actually
# check something, versus merely run without crashing.
cd /d/GitHub/stzlib/libraries/stzlib/base/test || exit 1
TIMEOUT=20
total_ok=0; total_red=0; total_err=0; total_hang=0; total_assert=0

for d in */; do
  d="${d%/}"
  case "$d" in _data|_smoke|_tmp) continue;; esac
  [ -d "$d" ] || continue
  shopt -s nullglob
  files=("$d"/*.ring)
  [ ${#files[@]} -eq 0 ] && continue
  mok=0; mred=0; merr=0; mhang=0; massert=0
  for f in "${files[@]}"; do
    base=$(basename "$f")
    case "$base" in _*) continue;; esac      # _probe / scratch files
    out=$( cd "$d" && timeout $TIMEOUT ring "$base" 2>&1 ); rc=$?

    # does this file assert anything at all? (the blind-spot metric)
    if echo "$out" | grep -qE "TOTAL: [0-9]+ assertions|\[PASS\]|\[OK\]"; then
      massert=$((massert+1))
    fi

    if [ $rc -eq 124 ]; then
      echo "HANG $d/$base"; mhang=$((mhang+1))

    # Ring error CODES *and* bare raise() messages. A detector keyed on
    # "Error (R14)" cannot see `raise("Error: ...")`, which is how the
    # library refuses DELIBERATELY -- 05_advanced_combining sat broken
    # and was reported clean until this line grew its second half.
    elif echo "$out" | grep -qE "Error \(R[0-9]|Error \(C[0-9]|^[[:space:]]*Error:|panic|Segmentation|Can't open file"; then
      err=$(echo "$out" | grep -oE "Error \(R[0-9]+\)[^|]*|Error \(C[0-9]+\)[^|]*|Error:[^|]*|panic[^|]*" | head -1)
      echo "ERR  $d/$base :: $err"; merr=$((merr+1))

    # a CLEAN run that still failed its own assertions -- the category
    # whose absence hid a real inverted-result bug for months
    elif echo "$out" | grep -qE "STATUS: FAILED|\[FAIL\]|TOTAL:.*, [1-9][0-9]* fail"; then
      why=$(echo "$out" | grep -oE "TOTAL:[^$]*fail" | head -1)
      lab=$(echo "$out" | grep -oE "THEN[^[]*\[FAIL\]" | head -2 | tr '\n' '~')
      echo "RED  $d/$base :: ${why:-assertions failed} :: $lab"; mred=$((mred+1))

    else
      mok=$((mok+1))
    fi
  done
  echo "#TALLY $d ok=$mok red=$mred err=$merr hang=$mhang asserting=$massert"
  total_ok=$((total_ok+mok)); total_red=$((total_red+mred))
  total_err=$((total_err+merr)); total_hang=$((total_hang+mhang))
  total_assert=$((total_assert+massert))
done

echo "#GRANDTOTAL ok=$total_ok red=$total_red err=$total_err hang=$total_hang"
echo "#ASSERTING  $total_assert files actually assert something"
