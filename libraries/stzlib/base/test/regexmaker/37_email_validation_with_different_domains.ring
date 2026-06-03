# Narrative
# --------
# Email validation with different domains
#
# Extracted from stzregexmakertest.ring, block #37.

load "../../stzBase.ring"


pr()

wrxm() {

	IfEndsWith(".edu").
	ThenMatch("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.edu").
	ElseMatch("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(com|org|net)")

	? Pattern()
}

#--> (?(?=.edu$)[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.edu|[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(com|org|net))

pf()
# Executed in almost 0 second(s) in Ring 1.22
