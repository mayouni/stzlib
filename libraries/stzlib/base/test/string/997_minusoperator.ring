# Narrative
# --------
# String editing via the (-) operator on a Q()/stzString -- with two caveats.
#
# `- N` trims N trailing chars and `- "x"` removes a substring, each returning
# a NEW stzString. Two things hold in the current build: (1) a bare `?` on the
# returned stzString prints the object dump, not its text -- use @@()/.Content()
# or a scalar projection like .StzType()/.Lowercased(); and (2) subtraction with
# a Q()-WRAPPED operand, `- Q("*")`, is currently a NO-OP (the asterisks
# survive), so .Lowercased() yields "a**bc***de***" rather than "abcde". The raw
# `- "*"` form works (see 996_minusoperator). Documented stub pending the
# stz-object-operand subtraction fix.
#
# Repositioned from test/list (stzlisttest.ring, block #421): this is a
# stzString test, so it belongs under test/string.
#ERR (stz-object-operand subtraction is a no-op; bare ? dumps the object)

load "../../stzBase.ring"

pr()

? Q("A**BC***DE***") - 3	# Remove the last 3 chars
#--> "A**BC***DE"

? Q("A**BC***DE***") - "*"
#--> ABCDE

? ( Q("A**BC***DE***") - Q("*") ).StzType() + NL
#--> stzstring

? ( Q("A**BC***DE***") - Q("*")  ).Lowercased()
#--> abcde

pf()
# Executed in 0.02 second(s).
