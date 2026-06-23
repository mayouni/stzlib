# Narrative
# --------
# Design-history note: why "=" is not a general Softanza operator -- and how
# list value-equality is still available.
#
# Early on, "=" was overloaded on ALL Softanza objects so you could write
# Q("str") = "str", Q(2+5) = 7, etc. That general form was disqualified: in
# older Ring, an "=" written after a variable holding an object could be taken
# as the overloaded operator instead of a plain assignment, making
# "oTempObj = anyValue" ambiguous. So Softanza keeps only the arithmetic
# operators (+, -, *, /) overloaded on objects in general.
#
# List value-equality survives in two safe forms: the .IsEqualTo() method, and
# -- in current Ring, where the assignment ambiguity no longer reproduces --
# the "=" operator on a Q()-wrapped list, e.g. Q([ 1, 2 ]) = [ 1, 2 ] (see
# block 356). The historical general-object "=" examples are preserved below as
# comments, since that broad overload is intentionally NOT supported.
#
# Extracted from stzlisttest.ring, block #405.

load "../../stzBase.ring"

pr()

# The one supported form: by-value equality on a Q()-wrapped list.
? Q([ 1, 2 ]) = [ 1, 2 ]
#--> TRUE

# --- Historical (disqualified) general-object "=" examples, kept for the record ---
#
#	? Q("str") = "str"                       #--> was TRUE when = was overloaded on all objects
#	? Q("str") = Q("str") = "str"            #--> TRUE
#	? Q(2+5) = 7                             #--> TRUE
#	? Q(2+5) = Q(3+4) = 7                    #--> TRUE
#	? Q(2+5) = Q(3+4) = Q(9-2) = 7           #--> TRUE
#	? Q(1:3) = Q(3:1) = [3, 1, 2]
#
# Why it was dropped: writing "=" after a variable that holds a Softanza object
# was being read as the overloaded operator rather than assignment, so
# "oTempObj = anyValue" misbehaved. Only +, -, *, / stayed overloaded on
# objects in general; "=" value-equality is offered through IsEqualTo() (and,
# safely now, the list "=" operator above).

pf()
# Executed in almost 0 second(s)
