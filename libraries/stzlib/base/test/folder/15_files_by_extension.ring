# Narrative
# --------
# Files by Extension
#
# Extracted from stzfoldertest.ring, block #15.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzFolder("C:\Windows\System32")
o1 {
    # Getting .exe files
    aExeFiles = FilesByExtension(".exe")
    ? len(aExeFiles)
    #--> 642
    
    # Getting .dll files (without dot)
    aDllFiles = FilesByExtension("dll")  # Extension with or without dot works
    ? len(aDllFiles)
    #--> 3382
}

pf()
# Executed in 0.04 second(s) in Ring 1.22
