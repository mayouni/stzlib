# Narrative
# --------
# Basic Navigation
#
# Extracted from stzfoldertest.ring, block #4.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzFolder("C:\Users")
o1 {
    # Current path
	? Path()
    #--> C:\Users
    
    GoTo("Public") # Or MoveTo() or cd()
	? Path()
    #--> C:\Users\Public
    
    Up() # Or GoUp() or cdUp()
    ? Path()
    #--> C:\Users
    
    GoHome()
    ? Path()
    #--> C:\Users\[Username]
}

pf()
# Executed in almost 0 second(s) in Ring 1.22

#==================================#
#  FILE & FOLDER OPERATIONS       #
#==================================#
