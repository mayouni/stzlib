# Narrative
# --------
# pr()
#
# Extracted from stzfoldertest.ring, block #27.

load "../../stzBase.ring"


o1 = new stzFolder("c:/testarea")
? @@NL( o1.FilesXT() )


? o1.IsFile("test.txt")
#--> FALSE

? o1.IsFile("c:/testarea/test.txt")


pf()

#--

pr()

o1 = new stzFolder("c:/testarea")

? o1.NormalizefileName("test.txt")
#--> /test.txt

? o1.NormalizeFolderName("images") + NL
#--> /images/

? o1.Folders()

? o1.IsFolderPath("/images")
#--> TRUE

? o1.IsFolderPath("images")
#--> TRUE

pf()
