# Narrative
# --------
# Cache & Performance
#
# Extracted from stzdatasettest.ring, block #34.

load "../../stzBase.ring"

# Caches computed values for faster access.

pr()

o1 = new stzDataSet([ 10, 20, 30, 40, 50 ])
o1 {
    ? @@(Cache())         #--> [] (initially empty)
    ? Mean()              #--> 30 (computes and caches)
    ? @@(Cache())         #--> [[ "mean", 30]]
    @aCache[:Mean] = 77
    ? Mean()              #--> 77 (uses modified cache)
    ClearCache()
    ? @@(Cache())         #--> [] (cache cleared)
    ? Mean()              #--> 30 (recomputed)
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22
