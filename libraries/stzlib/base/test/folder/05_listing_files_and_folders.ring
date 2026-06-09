# Narrative
# --------
# Listing Files and Folders
#
# Extracted from stzfoldertest.ring, block #5.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzFolder("C:\Windows\System32")
o1 {

	? CountFiles()

    aFiles = Files()
	? First3(aFiles)
    #--> calc.exe
    #    notepad.exe
    #    cmd.exe
    
	CountFolders()

    aFolders = Folders() # Or Dirs() or SubFolders()
	? First3(aFolders)
    #--> drivers
    #    config
    #    Tasks
}

pf()
# Executed in 0.07 second(s) in Ring 1.22
