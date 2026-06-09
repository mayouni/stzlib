# Narrative
# --------
# #  Example 12: DSEQUENCE DIAGRAM  #
#
# Extracted from stzdotcodetest.ring, block #18.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

#---------------------------------#

pr()

#NOTE #TODO Use this technique in stzDiagram to fix the messy
# native "ortho" splines type of Graphiz DOT engine

o1 = new stzDotCode()

o1.SetCode('
graph {
  rankdir=TD;
  A -- B -- C;
  D -- E -- F;
  B -- D;
  {rank = same; B; D;};
}
')

o1.Run()
o1.View()

pf()
# Executed in 0.47 second(s) in Ring 1.24
