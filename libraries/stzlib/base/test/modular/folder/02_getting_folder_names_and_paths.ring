# Narrative
# --------
# Getting Folder Names and Paths
#
# Extracted from stzfoldertest.ring, block #2.

load "../../../stzBase.ring"


pr()

o1 = new stzFolder("output")
o1 {

    ? Name()
    #--> Projects
    
    ? Path()
    #--> C:\Users\John\Documents\Projects
    
    ? FullPath() # Or AbsolutePath()
    #--> C:\Users\John\Documents\Projects
    
    ? IsAbsolute()
    #--> TRUE
    
    ? IsRoot()
    #--> FALSE
}

pf()
# Executed in almost 0 second(s) in Ring 1.22
