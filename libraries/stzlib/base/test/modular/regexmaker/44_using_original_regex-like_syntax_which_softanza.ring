# Narrative
# --------
# Using original regex-like syntax (which Softanza
#
# Extracted from stzregexmakertest.ring, block #44.

load "../../../stzBase.ring"

# does'nt actually like, because it's some how conduing!)
*/

pr()

o1 = new stzRegexLookAroundMaker

o1.LookingBehind("@").
   NotLookingAhead("\W").
   ThenMatch("[a-zA-Z0-9_]+")

? o1.Pattern()
#--> (?<=@)(?!\W)[a-zA-Z0-9_]+

pf()
# Executed in almost 0 second(s) in Ring 1.22

#=====================#
#  OTHER EXAMPLES...  #
#=====================#
