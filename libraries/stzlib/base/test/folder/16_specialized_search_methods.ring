# Narrative
# --------
# Specialized Search Methods
#
# Extracted from stzfoldertest.ring, block #16.
#ERR Error (R3) : Calling Function without definition: vizsearchfiles

load "../../stzBase.ring"


pr()

o1 = new stzFolder("C:\Windows\System32") #TODO Error
o1 {
    # Finding .dll files
    ? VizSearchFiles("*.dll")
    
    # Finding folders starting with 'config'
    ? FindFolders("config*")

}


pf()
