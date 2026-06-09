# Narrative
# --------
# Removing Files and Folders
#
# Extracted from stzfoldertest.ring, block #11.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzFolder("C:\TestArea")
o1 {
    # Create test content first
    CreateFolder("ToDelete")
	? CountFolders()
    #--> 6
    
    RemoveFolder("ToDelete") # Or rmdir() or DeleteFolder()
    ? CountFolders()
    #--> 5
    
    # Test file removal

	? FileExists("test.txt") #--> FALSE

	# RemoveFile("test.txt") # Or DeleteFile()
    #--> ERROR: File 'test.txt' doesn't exist here.

	CreateFile("test.txt")
	? FileExists("test.txt") #--> TRUE
	
}

pf()
# Executed in 0.01 second(s) in Ring 1.22
