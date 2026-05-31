# Narrative
# --------
# APPLICATION: GAME SCORE VALIDATION
#
# Extracted from stznumbrextest.ring, block #30.

load "../../../stzBase.ring"


pr()

oScoreValidator = Nx("{@Property(Even) & @Digit2-4 & @Relation(Mod:10=0)}")
? oScoreValidator.Match(100)   #--> TRUE
? oScoreValidator.Match(1230)  #--> TRUE
? oScoreValidator.Match(125)   #--> FALSE (not even)
? oScoreValidator.Match(10)    #--> TRUE

pf()
