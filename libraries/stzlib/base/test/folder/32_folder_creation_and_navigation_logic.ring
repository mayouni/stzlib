# Narrative
# --------
# Folder creation and navigation logic
#
# Extracted from stzfoldertest.ring, block #32.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

# Demonstrates how to use the stzFolder class to navigate the file system,
# create folders, and track the current path. Highlights support for
# both sequential navigation and scoped (block-based) folder creation.

pr()

o1 = new stzFolder("C:\")  # Start from root directory
o1 {

    GoTo("Windows")        # Navigate into 'Windows' folder
    GoTo("System32")       # Further descend into 'System32' (example of deep navigation)
    Up()                   # Move one level up (back to 'Windows')
    GoTo("Temp")           # Enter 'Temp' folder — final target before creation

	# Confirm current path before folder operations
    ? Path()
    #--> C:/Windows/Temp

    # Chain folder creation without changing the current location
    CreateFolder("ChainTest")  
    # Creates 'ChainTest' inside 'Temp' — current path remains at 'Temp'

    GoTo("ChainTest")       
    # Manually enter 'ChainTest' after creation

    CreateFolder("SubTest") {  
        # Create 'SubTest' inside 'ChainTest' and *immediately* enter it via block scope
        ? Path() 
        # Outputs full path from inside the 'SubTest' block
    }

    # After the block, we are still inside 'SubTest'
    ? Path()
    #--> C:/Windows/Temp/ChainTest/SubTest
    # Confirms persistent navigation after block exit
}

pf()
# Executed in almost 0 second(s) in Ring 1.22

#==========================#
#  COMPREHENSIVE WORKFLOW  #
#==========================#
