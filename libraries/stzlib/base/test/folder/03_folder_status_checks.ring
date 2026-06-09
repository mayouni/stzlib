# Narrative
# --------
# Folder Status Checks
#
# Extracted from stzfoldertest.ring, block #3.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzFolder("C:\Windows")
o1 {
    ? IsReadable()
    #--> TRUE
    
    ? Exists("System32")
    #--> TRUE
    
    ? HasFiles() # Or ContainsFiles()
    #--> TRUE
    
    ? HasFolders() # Or HasDirs()
    #--> TRUE
}

pf()
# Executed in almost 0 second(s) in Ring 1.22

#=====================#
#  FOLDER NAVIGATION  #
#=====================#
