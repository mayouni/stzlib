# Narrative
# --------
# Creating Single Folders
#
# Extracted from stzfoldertest.ring, block #8.

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
