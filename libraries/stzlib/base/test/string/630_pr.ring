# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #630.

load "../../stzBase.ring"


o1 = new stzString("Ring can be compared to Python, Ruby and PHP.")

o1.MarkTheseSubStringsCS( [ "Ring", "Python", "Ruby", "PHP" ], TRUE )
# Or ReplaceSubstringsWithMarquersCS

? o1.Content() + NL
#--> "#1 can be compared to #2, #3 and #4."

o1 = new stzString("Ring can be compared to Python, Ruby and PHP.")
o1.MarkSubStringsCS( [ "ring", "python", "ruby", "PHP" ], :CS = FALSE )
# Or ReplaceSubstringsWithMarquersCS

? o1.Content()
#--> "#1 can be compared to #2, #3 and #4."

pf()
# Executed in 0.01 second(s)
