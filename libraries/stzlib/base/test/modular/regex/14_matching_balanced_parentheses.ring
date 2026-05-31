# Narrative
# --------
# Matching balanced parentheses
#
# Extracted from stzRegexTest.ring, block #14.

load "../../../stzBase.ring"


pr()

# Regex pattern used:

cPattern = "\(([^()]|(?R))*\)"

# Explanation:

# (?R) is a recursive call to the entire regex, allowing it
# to match nested parentheses dynamically.
# This ensures that only strings with balanced parentheses are matched.

rx(cPattern) { ? MatchManyXT([ "(nested)", "((nested))", "(((deeply nested)))" ]) }
#--> [ TRUE, TRUE, TRUE ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
