# Narrative
# --------
# Cache & Performance
#
# Extracted from stzdatasettest.ring, block #34.

load "../../stzBase.ring"

# Caches computed values for faster access.
#
# WHAT CACHES, AND WHAT DOES NOT. This file used to assert that Mean() caches
# and that poking @aCache[:Mean] = 77 would make Mean() answer 77. It never
# did: Mean() returns straight from the engine, which computes it in one pass,
# so there is nothing to save and no invalidation to get wrong. Asserting the
# cache through a method that does not use it tested nothing and hid the fact
# that the cache was broken for the methods that DO.
#
# The genuinely cached ones are the expensive ones -- FrequencyTable(),
# UniqueValues(), Mode(), TrimmedMean(), WeightedMean().
#
# Three defects were found here once the file asked the right question:
#
#   _CacheKeys() ASSIGNED where it should have appended, and appended the
#   whole pair rather than the key, so it answered the last entry. Every
#   _KeyIsCached() and _RemoveFromCache() consulted that.
#
#   FrequencyTable() reused _cKey_ -- the CACHE key -- as its loop variable,
#   so the table was filed under the last data value ("50") instead of
#   "freq_table". The next call missed and recomputed, filing another copy.
#
#   _GetCached() read the hashlist at a missing key, and a Ring hashlist read
#   LEAVES THE KEY BEHIND holding "". The miss created the entry it was
#   looking for.

pr()

o1 = new stzDataSet([ 10, 20, 30, 40, 50 ])
o1 {
    ? @@(Cache())            #--> [ ] (nothing is computed at birth)

    # Mean is engine-direct: it does not cache, and the cache stays empty.
    ? Mean()                 #--> 30
    ? @@(Cache())            #--> [ ]

    # An expensive one DOES cache, under its own name.
    aFreq = FrequencyTable()
    ? @@(CacheKeys())        #--> [ "freq_table" ]

    # ...and asking again HITS: the cache does not grow a second copy.
    aFreq2 = FrequencyTable()
    ? @@(CacheKeys())        #--> [ "freq_table" ]
    ? NumberOfCachedValues() #--> 1

    # Two more, each filed under its own key.
    ? Mode()                 #--> 10
    ? @@(UniqueValues())     #--> [ 10, 20, 30, 40, 50 ]
    ? NumberOfCachedValues() #--> 3

    ClearCache()
    ? @@(Cache())            #--> [ ]
    ? Mean()                 #--> 30
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22
