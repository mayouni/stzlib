# Narrative
# --------
# Creating Single Folders
#
# Extracted from stzfoldertest.ring, block #8.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzFolder("C:\TestArea")
o1 {
    oNewFolder = CreateFolder("TestSubFolder") # Or mkdir() or MakeFolder()
    ? oNewFolder.Name()
    #--> TestSubFolder
}

pf()
# Executed in almost 0 second(s) in Ring 1.22
