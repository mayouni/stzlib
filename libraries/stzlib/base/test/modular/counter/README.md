# Modular counter tests

Originated from `base/test/stzCounterTest.ring`. Each `/*---` block of
the original was extracted into its own runnable thematic file with the
narrative preserved at the top and the `#-->` expected-output markers
left inline.

Run from this directory:

```
D:\Ring126\bin\ring.exe 01_skip_after_9_restart_at_0.ring
D:\Ring126\bin\ring.exe 02_restart_at_1.ring
D:\Ring126\bin\ring.exe 03_restart_at_2.ring
D:\Ring126\bin\ring.exe 04_raw_ring_1M_perf.ring
D:\Ring126\bin\ring.exe 05_softanza_1M_perf.ring
```

The `pf()` profiler at the end of each block raises a STOPPED! marker
on purpose -- it is the Softanza idiom for ending a profiled run, not
a test failure. The actual output to verify is everything BEFORE the
STOPPED! banner.

## Block index

| File | Topic | Expected key result |
|---|---|---|
| `01_skip_after_9_restart_at_0.ring` | StartAt=1, AfterYouSkip=9, RestartAt=0 | `[1..9,0,1,2,3]`, Last=3, Nth(12)=2 |
| `02_restart_at_1.ring` | WhenYouReach=5, RestartAt=1 | `[1..4,1..4,1]`, Nth(7)=3 |
| `03_restart_at_2.ring` | WhenYouReach=5, RestartAt=2 | `[1..4,2..4,2,3]`, Nth(7)=4 |
| `04_raw_ring_1M_perf.ring` | Raw Ring loop, 1M cycles | timing only |
| `05_softanza_1M_perf.ring` | stzCounter 1M cycles | **REGRESSION** -- hangs (was 0.91s in Ring 1.23) |

## Known regression (block 05)

`stzCounter.CountTo(1000000)` hangs for minutes vs. the documented
0.91s in Ring 1.23. Investigate whether RestartAt boundary checks or
list-append cost became O(n) per step. Tracked as task #4.
