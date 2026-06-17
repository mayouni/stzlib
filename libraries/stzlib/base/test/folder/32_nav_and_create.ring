# Narrative
# --------
# Folder creation and navigation logic
#
# Extracted from stzfoldertest.ring, block #32.
# Made portable + non-destructive: the original walked the real
# C:\Windows\System32 / C:\Windows\Temp and created folders there. Here we
# mirror that navigation shape inside a local sandbox. The API exercised
# (GoTo / Up / CreateFolder with block scope, location-follows-action) is
# unchanged.

load "../../stzBase.ring"

# Demonstrates how to use the stzFolder class to navigate the file system,
# create folders, and track the current path. Highlights support for
# both sequential navigation and scoped (block-based) folder creation.

pr()

cSbx = CurrentDir() + "/_fx_nav"
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
StzMakeDir(cSbx + "/Windows/System32")
StzMakeDir(cSbx + "/Windows/Temp")

o1 = new stzFolder(cSbx)  # Start from the sandbox root
o1 {

    GoTo("Windows")        # Navigate into 'Windows' folder
    GoTo("System32")       # Further descend into 'System32' (deep navigation)
    Up()                   # Move one level up (back to 'Windows')
    GoTo("Temp")           # Enter 'Temp' folder -- final target before creation

	# Confirm current path before folder operations
    ? Path()
    #--> <sandbox>/Windows/Temp

    # Create 'ChainTest' inside 'Temp'. Under location-follows-action the
    # receiver descends INTO the new folder, so no explicit GoTo is needed
    # (and adding one would double the segment: Temp/ChainTest/ChainTest).
    CreateFolder("ChainTest")
    # Now positioned at Temp/ChainTest

    CreateFolderQ("SubTest") {   # Q form returns the object for the block
        # Create 'SubTest' inside 'ChainTest' and *immediately* enter it
        ? Path()
        # Outputs full path from inside the 'SubTest' block
    }

    # After the block, we are still inside 'SubTest'
    ? Path()
    #--> <sandbox>/Windows/Temp/ChainTest/SubTest
    # Confirms persistent navigation after block exit
}

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in almost 0 second(s) in Ring 1.23
