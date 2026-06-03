# Narrative
# --------
# Creating Folder Paths
#
# Extracted from stzfoldertest.ring, block #10.

load "../../stzBase.ring"


pr()

o1 = new stzFolder("C:\")
o1 {
    # Creating deep path...
    oDeepFolder = CreatePath("TestArea\Level1\Level2\Level3") # Or mkpath()
    ? oDeepFolder.Name()
    #--> Level3
}

pf()
# Executed in 0.01 second(s) in Ring 1.22
