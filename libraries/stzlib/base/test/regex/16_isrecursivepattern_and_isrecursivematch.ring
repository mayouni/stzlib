# Narrative
# --------
# IsRecursivePattern() and IsRecursiveMatch()
#
# Extracted from stzRegexTest.ring, block #16.

load "../../stzBase.ring"


pr()

# Match nested parentheses recursively

rx("\((?:[^()]+|(?R))*\)") {

	? MatchRecursive("(a(b(c)d)e)")
	#--> TRUE

	? IsRecursiveMatch() + NL
	#--> TRUE
}

rx("Hello") { 

	? MatchRecursive("(a(b(c)d)e)")
	#--> FALSE

}

pf()
# Executed in 0.01 second(s) in Ring 1.22
