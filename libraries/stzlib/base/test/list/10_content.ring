# Narrative
# --------
# ReplaceManyByMany (1-to-1 mapping) and the Section<->Range conversions.
#
# ReplaceManyByMany pairs each needle with its OWN replacement (no cycling):
# every "ring"->"♥", "softanza"->"♥♥", "kandaji"->"♥♥♥", including repeats.
# Then two small position helpers: SectionToRange turns a [start,end] section
# into a [start, count] range, and RangeToSection does the inverse.
#
# (The extraction had two pr()/pf() blocks joined by a stray "#====";
# merged here into one runnable script.)
#
# Extracted from stzlisttest.ring, block #10.

load "../../stzBase.ring"

pr()

o1 = new stzList([
	"ring", "qt", "softanza", "pyhton", "kandaji", "csharp", "ring", "kandaji" ])

o1.ReplaceManyByMany([
	"ring", "softanza", "kandaji" ], :By = [ "♥", "♥♥", "♥♥♥" ])

? @@( o1.Content() )
#--> [ "♥", "qt", "♥♥", "pyhton", "♥♥♥", "csharp", "♥", "♥♥♥" ]

? SectionToRange(3, 7)
#--> [ 3, 5 ]

? RangeToSection(3, 5)
#--> [ 3, 7 ]

pf()
# Executed in almost 0 second(s)
