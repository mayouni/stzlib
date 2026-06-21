# Narrative
# --------
# ReplaceManyByMany: distinct 1-to-1 -- each needle gets its OWN replacement,
# applied to ALL its occurrences.
#
# Two needles [ "*", "=" ] map to two replacements [ "C", "F" ]: every "*"
# becomes "C" (both occurrences) and "=" becomes "F". The needle and
# replacement lists must be the same length -- this is value-keyed pairing,
# NOT occurrence cycling (for that, see the XT form, blocks #80-#83).
#
# (The original stub fed 3 replacements for 2 needles -- a size mismatch that
# only made sense under occurrence-based semantics; corrected here to the
# authoritative distinct-pairing contract that tests #10 and #452 document.)
#
# Extracted from stzlisttest.ring, block #78.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "*", "D", "*",  "=" ])
o1.ReplaceManyByMany([ "*", "=" ], :With = ["C", "F"])
? @@( o1.Content() )
#--> [ "A", "B", "C", "D", "C", "F" ]

pf()
# Executed in 0.06 second(s)
