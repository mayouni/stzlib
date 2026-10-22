#!/usr/bin/env bash
# RX4 -- run the render benchmark under the method of BENCH_METHOD.md.
#
#   bash bench_run.sh [iterations] [requests]       from base/test/render
#
# Order, and why:
#   0. refuse to start if a Zig build is running: the build and the run never
#      overlap, because the machine freezes under memory pressure and a build
#      beside a run measures the build
#   1. the PARITY GATE, first half: the RX1 oracle (escape_sinks_narrated.ring)
#      must say STATUS: OK. A render that is not correct is not worth timing
#   2. three separate processes of bench_render.ring, one after the other
#   3. the PARITY GATE, second half: the three runs must print the same bytes
#      and the same sha256 for every canonical output. If not, NO timing is
#      reported and the script exits 1
#   4. one process of bench_appserver.ring
#   5. the report, dated, written beside the method
# Exit 0 reported, 1 parity failed, 2 refused to start.

set -u
ITER="${1:-30}"
REQS="${2:-300}"
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE" || exit 2
WORK="${TMPDIR:-/tmp}/bench_render_$$"
mkdir -p "$WORK"

if tasklist 2>/dev/null | grep -qi "zig.exe"; then
	echo "REFUSED: a zig build is running; the build and the run never overlap" >&2
	exit 2
fi

load_now() {
	# mean of three CPU snapshots two seconds apart, percent
	powershell -NoProfile -Command "\$s=0; 1..3 | ForEach-Object { \$s += (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average; Start-Sleep -Seconds 2 }; [math]::Round(\$s/3)"
}

LOAD_BEFORE="$(load_now)"
echo "== ambient CPU before: $LOAD_BEFORE percent"

echo "== gate 1: the RX1 oracle"
if ! ring escape_sinks_narrated.ring 2>&1 | grep -q "STATUS: OK"; then
	echo "PARITY FAILED: the oracle is not green; nothing is timed" >&2
	exit 1
fi
echo "   oracle green"

for r in 1 2 3; do
	echo "== run $r of 3: bench_render.ring $ITER iterations"
	ring bench_render.ring "$ITER" > "$WORK/render_$r.txt" 2>&1 || { echo "run $r failed" >&2; cat "$WORK/render_$r.txt" >&2; exit 1; }
	grep -q "^ERR" "$WORK/render_$r.txt" && { cat "$WORK/render_$r.txt" >&2; exit 1; }
done

echo "== gate 2: byte parity across the three runs"
grep "^OUT " "$WORK/render_1.txt" > "$WORK/out_1.txt"
for r in 2 3; do
	grep "^OUT " "$WORK/render_$r.txt" > "$WORK/out_$r.txt"
	if ! cmp -s "$WORK/out_1.txt" "$WORK/out_$r.txt"; then
		echo "PARITY FAILED: run $r printed different bytes or a different sha256; no timing is reported" >&2
		diff "$WORK/out_1.txt" "$WORK/out_$r.txt" >&2
		exit 1
	fi
done
echo "   three runs, identical bytes and sha256 for every output"

echo "== app server: bench_appserver.ring $REQS requests"
ring bench_appserver.ring "$REQS" > "$WORK/app.txt" 2>&1 || { cat "$WORK/app.txt" >&2; exit 1; }
grep -q "^ERR" "$WORK/app.txt" && { cat "$WORK/app.txt" >&2; exit 1; }

LOAD_AFTER="$(load_now)"
echo "== ambient CPU after: $LOAD_AFTER percent"

python bench_report.py "$WORK" "$ITER" "$REQS" "$LOAD_BEFORE" "$LOAD_AFTER"
exit $?
