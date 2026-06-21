# Narrative
# --------
# Three ways a stzList renders itself as text: ToString, Stringified, ToCode.
#
# ToString() gives a plain display form -- the items joined one per line
# (newline-separated), so @@() shows a single multi-line string. Stringified()
# returns the bracketed literal of the content as a STRING (numbers stay
# numbers, strings stay quoted); because that value is itself a string holding
# double quotes, @@() wraps it in single quotes. ToCode() returns the same
# re-loadable Ring literal -- feed it back to the interpreter and you rebuild
# the list. (ToString was missing on stzList and fell back to the object's
# "@noname" handle; it is restored here to the monolith NL-join semantics.)
#
# Extracted from stzlisttest.ring, block #210.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3, "*", 5, 6, "*", 7 ])

? @@( o1.ToString() ) + NL
#--> "1
# 2
# 3
# *
# 5
# 6
# *
# 7"

? @@( o1.Stringified() ) + NL
#--> '[ 1, 2, 3, "*", 5, 6, "*", 7 ]'

? o1.ToCode()
#--> [ 1, 2, 3, "*", 5, 6, "*", 7 ]

pf()
# Executed in 0.02 second(s)
