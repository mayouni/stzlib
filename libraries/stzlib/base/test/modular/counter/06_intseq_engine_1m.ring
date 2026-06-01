# Narrative
# --------
# Engine-first 1M cycle: the same 1..4 cycle as blocks 04 and 05, but
# built through the stzIntSeq engine feature instead of native Ring
# list ops. CountToSeq returns an stzIntSeq wrapping a Zig-allocated
# []i64 backing store; queries (Len, At, Sum, Min, Max) stay engine-
# fast (no per-item FFI roundtrip).
#
# Compares directly against block 04 (raw Ring) and block 05
# (stzCounter Ring-loop). On Ring 1.26 block 05's Counting() hangs
# at N >= 100,000 due to a class-method list-append regression;
# this block completes N = 1,000,000 in ~7 ms.

load "../../../stzBase.ring"

pr()

oCounter = new stzCounter([
    :StartAt = 1,
    :WhenYouReach = 4,
    :RestartAt = 1
])

oSeq = oCounter.CountToSeq(1000000)

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
