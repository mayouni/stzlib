# Narrative
# --------
# Specialized Search Methods
#
# Extracted from stzfoldertest.ring, block #14.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzFolder("C:\Windows\System32")
o1 {
    # Finding .dll files
    aDlls = FindFiles("*.dll")
    ? len(aDlls)
    #--> 3611
    
    # Finding folders starting with 'config'
    aConfigFolders = FindFolders("config*")
    ? len(aConfigFolders)
    #--> Config folders: 2
    
    ? @@(aConfigFolders)
    #--> [ "config", "Configuration" ]
}

pf()
# Executed in 0.17 second(s) in Ring 1.23
# Executed in 0.18 second(s) in Ring 1.22
