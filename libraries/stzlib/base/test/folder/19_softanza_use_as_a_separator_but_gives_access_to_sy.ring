# Narrative
# --------
# Softanza use "/" as a separator but gives access to system separaor
#
# Extracted from stzfoldertest.ring, block #19.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzFolder("c:/testarea")

? o1.Separator()
#--> "/"

? o1.SystemSeparator() # I'm on windows
#--> "\"

? o1.Path() # All outputs use the "/" separator
# c:/testarea

# NOTE: You can use any separator in entering paths '/' or '\'
# and Softanza will understand them indifferently

? @@( o1.FindFile("/test.txt") )
#--> [ "/test.txt" ]

? @@( o1.FindFile("\test.txt") )
#--> [ "/test.txt" ]

pf()
