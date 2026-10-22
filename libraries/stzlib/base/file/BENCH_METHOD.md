# The render benchmark method

*Plane `stzlib-render`, rung RX4, 2026-10-22. Stage words: **built** (the script that
shows it is named), **designed**, **absent**. This page is a method, not a result;
the results are dated pages beside it, `BENCH_RESULTS_<date>_<HHMM>.md`, one per run,
never overwritten.*

A benchmark here is **dated evidence**. It says what one machine did on one day with
one build, and it says nothing else. The numbers on a results page are **compared with
nothing**: no other framework, no multiple, no ranking, and no sentence in this
library's documents may outrun a figure on a results page. **Rerun before publishing a
current comparison**, because a figure ages with the machine, the build and the
neighbours on the machine.

## 1. What is measured

Three canonical outputs, each timed on the work the library does to produce it and not
on building its inputs. **built**: `base/test/render/bench_render.ring`.

| output | the work in the time |
|---|---|
| `table200` | a 200-row, 5-column table through `stzHtmlBuilder`, construction and `Build()` together |
| `panel` | the `.panel` document `base/test/gui/showcase.panel` through `stzUiDocument.ToHtml()`, the document already parsed and judged |
| `chapter` | ONE education chapter in English through `stzEduReader` (an `AddChapter` and `Html()`), the chapter already run; never all 72 |

The app server, **built**: `base/test/render/bench_appserver.ring`: an idle-memory
figure and a throughput run, each made three times and shown three times.

- **Idle memory** is the resident set of the process after the library is loaded and
  before the listener starts (the baseline), and again after `Start()` and before any
  request. The difference is the server's own share.
- **Throughput is closed-loop, one client.** The next request is sent only after the
  previous answer has arrived, so the offered load adjusts to the server and queueing
  is never exercised. It is a round trip of one request at a time, not a capacity.
  Client and server share one process and one machine, so a request's time includes
  the client's own cost. An **open-loop** run, which fires at a fixed rate whatever the
  answers do, is **absent**: it is not made and must not be implied.

## 2. Parity before timing

A render that is not correct is not worth timing, so two gates stand in front of every
figure, and a failed gate prints **no timing at all**.

1. **The oracle.** `escape_sinks_narrated.ring`, the RX1 guard, must say `STATUS: OK`.
2. **Byte parity.** Three separate processes of `bench_render.ring` run one after the
   other. Each prints, for every canonical output, its byte count and its sha256; the
   three prints must be identical, and every iteration inside a process must match the
   first iteration's sha256. Anything else exits 1.

Parity compares a library's runs with themselves. It proves sameness and never
rightness; rightness is the oracle's and the perception record's.

## 3. What a results page must carry

- **Date** of the run, local and UTC, read from the clock.
- **Hardware**: machine model, processor and its core count, memory, system version.
  **Software**: the Ring version, the Zig version, the commit of the tree, the last
  commit that touched the engine sources, and the modification time of the engine
  builds measured.
- **Ambient load**: the mean of three CPU snapshots before and after. This machine runs
  several sessions at once; the figure is the honest size of that noise, and it is
  printed rather than argued away.
- **Time** as **p50, p95 and the worst** (nearest rank) in milliseconds, per run, from
  the engine's monotonic clock (`StzEngineWatchTimestampNs`), never wall time. Three
  runs are shown side by side and **not pooled**, so the spread between them is
  visible.
- **Memory beside time**: the resident set after load, after the inputs are built and
  after the timed loops (`StzEnginePerfMemRss`).
- The sentence **what this does not say**.

## 4. Conditions, and how each is kept

| condition | kept by |
|---|---|
| measure an engine built from a commit that is named | the page names the tree commit and the last engine-source commit, and the build times; the engine is rebuilt first when its sources moved |
| the baseline is the current builder, which escapes by default | the oracle gate runs on the same tree; the sha256 are of the escaped output |
| one heavy job at a time, the build never overlapping the run | `bench_run.sh` refuses to start (exit 2) while a `zig.exe` is running; the machine freezes under memory pressure, and a build beside a run measures the build |
| hardware, date, p50, p95, worst and memory beside time, compared with nothing | `bench_report.py` writes them and writes the closing sentence |

## 5. How to run it

From the repository root, after the engine is built, with no other heavy job running:

```bash
cd libraries/stzlib/base/test/render && bash bench_run.sh 30 300
```

The two numbers are the iterations per run and the requests of the closed-loop run.
Exit **0** a results page was written, **1** a parity gate failed and nothing was
timed, **2** the run was refused. The page lands in `libraries/stzlib/base/file/`.

## 6. Limits of the method itself

- The clock reads a monotonic counter; Windows quantizes CPU accounting at 15.625 ms,
  so a time under that is read from the clock and never from process CPU times.
- The first iteration of a run is included. It is part of what a first request costs;
  a reader who wants the warm figure reads the p50, and the worst shows the cold one.
- The inputs are built once and are not in the time. A figure for building the inputs
  is a different measurement and is not made here.
- The resident set includes the library and the engine loaded into the process. It is
  not the cost of one page.
- **Ambient load moves a figure by a factor, so a page without its load is not evidence.**
  On 2026-10-22 the 200-row table's p50 was about 485 ms in a session that began at 32
  percent ambient CPU and about 1,000 ms in a session that began at 73 percent, with the
  same code, the same engine build and the same bytes. The first session's page was
  replaced by the second before pages carried the time in their name, which is why the
  name carries it now. Every page prints its load before and after; a reader compares
  pages only at similar loads.
- **The closed-loop figure is bimodal on this machine.** Observed on 2026-10-22, the same
  code gave a p50 near 5 ms in some runs and near 31.6 ms in others, run to run and once
  within a pair of runs of one size: two Windows timer quanta of 15.6 ms, which is what a
  sleep costs when the 1 ms resolution the reactor requests is not in force. The cause
  is not diagnosed here. So the method runs the app server three times, shows all three,
  and never reports one.
- A benchmark of the builder is a benchmark of its present shape: `Build()` rebuilds
  its node objects from its lists on every call. The method does not say whether that
  is right; it says what it costs today.
