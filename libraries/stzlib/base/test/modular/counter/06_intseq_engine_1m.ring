# Narrative
# --------
# Engine-first 1M cycle: the same 1..4 cycle as blocks 04 and 05, but
# kept on the engine side instead of materialising to a Ring list.
# CountToQ returns an stzIntSeq wrapping a Zig-allocated []i64 backing
# store; queries (Len, At, Sum, Min, Max) stay engine-fast (no per-item
# FFI roundtrip and no Ring-list construction).
#
# CountTo() itself always returns a plain Ring list (engine-built,
# then materialised) and is the natural surface for typical callers.
# Reach for CountToQ only when you specifically need streaming
# stats over a large cycle without paying the materialisation cost.
#
# Compares directly against block 04 (raw Ring) and block 05
# (stzCounter materialised path). This block completes N = 1,000,000
# stat queries in ~7 ms.

load "../../../stzBase.ring"

pr()

oCounter = new stzCounter([
    :StartAt = 1,
    :WhenYouReach = 4,
    :RestartAt = 1
])

oSeq = oCounter.CountToQ(1000000)

? oSeq.Len()
#--> 1000000

? oSeq.First()
#--> 1

? oSeq.At(2)
#--> 2

? oSeq.At(3)
#--> 3

? oSeq.At(4)
#--> 1

? oSeq.Sum()
#--> 1999999

oSeq.Release()

pf()
# Reference timings:
# - 7 ms for N = 1,000,000 on Ring 1.26 (engine path)
# - Ring-loop equivalent (block 05) hangs above N = 100,000 on 1.26
