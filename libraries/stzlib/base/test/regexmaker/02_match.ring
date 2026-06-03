# Narrative
# --------
# pr()
#
# Extracted from stzregexmakertest.ring, block #2.

load "../../stzBase.ring"

pr()

rx(pat(:xlsConditionalExpression)) {

	? Match("B2<>C3")
	#--> TRUE

	? Pattern() + NL
	#--> "^.*(?:=|<|>|<>).*$"

	? Explain() + NL
	#--> Matches an Excel conditional expression

	? ExplainXT() + NL
	#-->
	# - `^.*(?:=|<|>|<>).*$`: Matches any formula containing comparison operators.

	# - Matches: `A1=A2`, `B1<>C1`, `A1>10`, `5<=6`.
	# - Non-matches: `A1A2`, `=A1`, `<B2`.

}

pf()
# Executed in almost 0 second(s) in Ring 1.22
