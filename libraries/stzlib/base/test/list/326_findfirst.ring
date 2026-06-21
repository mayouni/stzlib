# Narrative
# --------
# Shallow finds vs DEEP contains -- searching at the top level vs at ANY
# nesting depth.
#
# FindFirst / FindNth / Contains operate on the top-level items (Contains
# matches the whole sublist [ "2","♥","2" ] as one item). The DeepContains
# family instead searches recursively into nested sublists:
#   DeepContains        -- is the value anywhere, at any depth?
#   DeepContainsMany    -- are ALL of these present (deep)?
#   DeepContainsBoth    -- both of two (:And names the second)
#   DeepContainsOneOfThese / DeepContainsNOfThese -- at least one / at least n
# So "🌞" buried inside [ "2", ["3","🌞"] ] is found by DeepContains but
# not by a shallow Contains. (Multibyte ♥ / 🌞 are matched codepoint-safe.)
#
# Extracted from stzlisttest.ring, block #326.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "1", "1", [ "2", "♥", "2"], "1", [ "2", ["3", "🌞"] ] , "3" ])

? o1.FindFirst("3")
#--> 6

? o1.FindNth(3, "1")
#--> 4

? o1.Contains([ "2", "♥", "2"])
#--> TRUE

? o1.DeepContains("🌞")
#--> TRUE

? o1.DeepContainsMany([ "1", "♥", "3", "🌞" ]) # Or DeepContainsThese()
#--> TRUE

? o1.DeepContainsBoth("♥", :And = "🌞")
#--> TRUE

? o1.DeepContainsOneOfThese(["_", "🌞", "0" ])
#--> TRUE

? o1.DeepContainsNOfThese(2, ["_", "🌞", "0", "♥" ])
#--> TRUE

StopProfiler()

pf()
# Executed in almost 0 second(s)
