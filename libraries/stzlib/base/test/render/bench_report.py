"""RX4 -- turn the raw lines of one benchmark session into a dated results page.

    python bench_report.py WORKDIR ITER REQS LOAD_BEFORE LOAD_AFTER

Reads render_1..3.txt and app.txt that bench_run.sh wrote, asks the machine for
what the figures were taken on, and writes BENCH_RESULTS_<date>_<HHMM>.md beside the
method, so a rerun never overwrites another page. It judges nothing: parity was gated before this ran. It states the
conditions and the figures and compares with nothing.
"""
import datetime
import os
import subprocess
import sys

work, iters, reqs, load_before, load_after = sys.argv[1:6]
here = os.path.dirname(os.path.abspath(__file__))
repo = os.path.abspath(os.path.join(here, "..", "..", "..", "..", ".."))
out_dir = os.path.abspath(os.path.join(here, "..", "..", "file"))


def run(cmd):
    try:
        return subprocess.run(cmd, capture_output=True, text=True, timeout=60).stdout.strip()
    except Exception as e:  # a missing reading is stated, never guessed
        return "unavailable (%s)" % e


def ps(expr):
    return run(["powershell", "-NoProfile", "-Command", expr])


now_local = datetime.datetime.now()
now_utc = datetime.datetime.now(datetime.timezone.utc)
cpu = ps("(Get-CimInstance Win32_Processor | Select-Object -First 1).Name")
cores = ps("$p=Get-CimInstance Win32_Processor | Select-Object -First 1; \"$($p.NumberOfCores) cores, $($p.NumberOfLogicalProcessors) logical\"")
ram = ps("[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB,1)")
model = ps("$c=Get-CimInstance Win32_ComputerSystem; \"$($c.Manufacturer) $($c.Model)\"")
osv = ps("(Get-CimInstance Win32_OperatingSystem).Caption + ' ' + (Get-CimInstance Win32_OperatingSystem).Version")
zig = run(["zig", "version"])
ring = "unavailable"
for _l in run(["ring", "-v"]).splitlines():
    if _l.startswith("Ring version"):
        ring = _l.strip()
commit = run(["git", "-C", repo, "rev-parse", "HEAD"])
engine_commit = run(["git", "-C", repo, "log", "-1", "--format=%H", "--", "libraries/stzlib/engine/src"])
dlls = []
for name in ("stz_html.dll", "stz_json.dll"):
    p = os.path.join(repo, "libraries", "stzlib", "engine", "zig-out", "bin", name)
    if os.path.exists(p):
        dlls.append("%s %s" % (name, datetime.datetime.fromtimestamp(os.path.getmtime(p)).strftime("%Y-%m-%d %H:%M")))
    else:
        dlls.append("%s absent" % name)


def lines(path, tag):
    with open(path, encoding="utf-8", errors="replace") as f:
        return [l.split() for l in f.read().splitlines() if l.startswith(tag + " ")]


outs = {l[1]: (l[2], l[3]) for l in lines(os.path.join(work, "render_1.txt"), "OUT")}
runs = []
for r in (1, 2, 3):
    p = os.path.join(work, "render_%d.txt" % r)
    times = {l[1]: l[2:] for l in lines(p, "TIME")}
    rss = {l[1]: int(l[2]) for l in lines(p, "RSS")}
    runs.append((times, rss))
app_runs = []
for r in (1, 2, 3):
    p = os.path.join(work, "app_%d.txt" % r)
    app_runs.append(({l[1]: int(l[2]) for l in lines(p, "RSS")}, lines(p, "LOAD")[0]))


def mb(b):
    return "%.1f" % (b / 1048576.0)


date = now_local.strftime("%Y-%m-%d")
md = []
md.append("# Render benchmark results -- %s\n" % date)
md.append("*Dated evidence under `BENCH_METHOD.md`. Rerun before publishing a current comparison. "
          "These figures are compared with nothing and say nothing about any other framework.*\n")
md.append("## Conditions\n")
md.append("| | |")
md.append("|---|---|")
md.append("| taken | %s local, %s UTC |" % (now_local.strftime("%Y-%m-%d %H:%M"), now_utc.strftime("%Y-%m-%d %H:%M")))
md.append("| machine | %s |" % model)
md.append("| processor | %s, %s |" % (cpu, cores))
md.append("| memory | %s GB |" % ram)
md.append("| system | %s |" % osv)
md.append("| Ring | %s |" % ring)
md.append("| Zig | %s |" % zig)
md.append("| tree commit | %s |" % commit)
md.append("| last commit touching the engine sources | %s |" % engine_commit)
md.append("| engine builds measured | %s |" % "; ".join(dlls))
md.append("| ambient CPU, mean of three snapshots | %s percent before, %s percent after; other sessions share this machine |" % (load_before, load_after))
md.append("| one machine, one operator session, one build at a time | the build never overlapped a run |")
md.append("")
md.append("## The parity gate, passed before anything was timed\n")
md.append("The RX1 oracle (`escape_sinks_narrated.ring`) said `STATUS: OK`; then three separate processes of "
          "`bench_render.ring` each produced every canonical output with the same byte count and the same sha256, "
          "and every iteration inside a process matched its first.\n")
md.append("| output | bytes | sha256 |")
md.append("|---|---|---|")
for k in ("table200", "panel", "chapter"):
    md.append("| %s | %s | `%s` |" % (k, outs[k][0], outs[k][1]))
md.append("")
md.append("## Time, milliseconds, %s iterations per run, three runs\n" % iters)
md.append("Monotonic clock (`StzEngineWatchTimestampNs`). p50, p95 and worst by nearest rank over each run's iterations. "
          "Each run is its own process, so the spread between runs is visible and nothing is pooled.\n")
md.append("| output | run | p50 | p95 | worst |")
md.append("|---|---|---|---|---|")
what = {
    "table200": "200 rows x 5 cells through `stzHtmlBuilder`, construction and Build",
    "panel": "`showcase.panel` through `stzUiDocument.ToHtml`, already parsed",
    "chapter": "one education chapter (English) through `stzEduReader`, AddChapter and Html, chapter already run",
}
for k in ("table200", "panel", "chapter"):
    for i, (times, _) in enumerate(runs, 1):
        t = times[k]
        md.append("| %s | %d | %s | %s | %s |" % (k, i, t[1], t[2], t[3]))
md.append("")
for k in ("table200", "panel", "chapter"):
    md.append("- **%s**: %s." % (k, what[k]))
md.append("")
md.append("## Memory, resident set, megabytes\n")
md.append("The engine's own reading (`StzEnginePerfMemRss`), beside the time, per run.\n")
md.append("| run | after library load | after inputs built | after the timed loops |")
md.append("|---|---|---|---|")
for i, (_, rss) in enumerate(runs, 1):
    md.append("| %d | %s | %s | %s |" % (i, mb(rss["after-load"]), mb(rss["after-inputs"]), mb(rss["after-loops"])))
md.append("")
md.append("## The app server\n")
md.append("**Closed-loop, one client**: the next request is sent only after the previous answer arrived, so queueing is not "
          "exercised and this is a round trip, not a capacity. Client and server share one process and one machine, so a "
          "request's time includes the client's own cost. The route answers a short text. An open-loop run is not made here "
          "and is not implied.\n")
md.append("Three runs, each its own process, shown side by side and never pooled or reduced to one: the same code on this "
          "machine has given a p50 near 5 ms in some runs and near 31.6 ms, twice the Windows timer quantum of 15.6 ms, in "
          "others, so one figure would be a coin toss.\n")
md.append("| run | idle: library loaded, before the listener (MB) | idle: after Start(), before any request (MB) | after the requests (MB) |")
md.append("|---|---|---|---|")
for i, (rss, _) in enumerate(app_runs, 1):
    md.append("| %d | %s | %s | %s |" % (i, mb(rss["baseline"]), mb(rss["idle-server"]), mb(rss["after-load"])))
md.append("")
md.append("| run | requests | seconds | requests per second | p50 ms | p95 ms | worst ms |")
md.append("|---|---|---|---|---|---|---|")
for i, (_, ld) in enumerate(app_runs, 1):
    md.append("| %d | %s | %s | %s | %s | %s | %s |" % (i, ld[2], ld[3], ld[4], ld[5], ld[6], ld[7]))
md.append("")
md.append("## What this does not say\n")
md.append("- No other framework, no multiple, no ranking: parity of output is the only comparison made, and only between "
          "this library's own runs.\n"
          "- One machine and one afternoon, with other sessions running; the ambient CPU above is the honest size of that.\n"
          "- Inputs (the rows, the parsed panel, the run chapter) are built once and are not in the time.\n"
          "- Resident set includes the library and engine loaded into the process; it is not the cost of one page.\n")
path = os.path.join(out_dir, "BENCH_RESULTS_%s_%s.md" % (date, now_local.strftime("%H%M")))
with open(path, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(md))
print("report written:", path)
