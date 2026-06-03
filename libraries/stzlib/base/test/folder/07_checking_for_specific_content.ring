# Narrative
# --------
# Checking for Specific Content
#
# Extracted from stzfoldertest.ring, block #7.
#ERR exit 1: 0

load "../../stzBase.ring"


pr()

o1 = new stzFolder("C:\Windows")
o1 {
    ? Contains("System32") # Or Has()
    #--> TRUE
    
    ? ContainsFile("explorer.exe")
    #--> TRUE
    
    ? ContainsFolder("System32") + NL # Or ContainsDir()
    #--> TRUE

	? DeepContains("Boot") # Takes most of the execution time!
	#--> TRUE
}

pf()
# Executed in 8.45 second(s) in Ring 1.22

#=============================#
#  FOLDER CREATION & REMOVAL  #
#=============================#
