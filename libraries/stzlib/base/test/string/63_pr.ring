# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #63.

load "../../stzBase.ring"


	o1 = new stzString("**word1***word2**word3***")
	? o1.Sections([ [1,2], [8, 10], [16, 17], [23, 25] ])
	#--> [ "**", "***", "**", "***" ]
		
	o1.RemoveManySections([
		[1,2], [8, 10], [16, 17], [23, 25]
	])
		
	? o1.Content()
	#--> "word1word2word3"

pf()
# Executed in 0.06 second(s) in Ring 1.22
# Executed in 0.17 second(s) in Ring 1.17
