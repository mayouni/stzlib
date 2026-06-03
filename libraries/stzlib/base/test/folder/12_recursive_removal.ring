# Narrative
# --------
# Recursive Removal
#
# Extracted from stzfoldertest.ring, block #12.

load "../../stzBase.ring"


pr()

o1 = new stzFolder("C:\TestArea\Level1")
o1 {
    # Current path before removal
	? Path()
    #--> C:\TestArea\Level1
    
    # Removing all the folder and its subfolders (recursively)

    bSuccess = DeepRemoveAll()
    ? bSuccess
    #--> Removal successful: TRUE
}

pf()
# Executed in almost 0 second(s) in Ring 1.22

#======================#
#  SEARCH & FILTERING  #
#======================#
