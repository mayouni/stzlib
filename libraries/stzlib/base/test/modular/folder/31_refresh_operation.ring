# Narrative
# --------
# Refresh Operation
#
# Extracted from stzfoldertest.ring, block #31.

load "../../../stzBase.ring"


pr()

o1 = new stzFolder("C:\TestArea")
o1 {
    # Count before refresh
	? Count() # or CountFilesAndFolders()
    #-->  5
    
    CreateFolder("NewlyAdded")
    
    Refresh()
    ? Count()
    #--> 6
}

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.22
