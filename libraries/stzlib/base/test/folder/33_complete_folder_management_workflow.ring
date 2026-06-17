# Narrative
# --------
# Complete Folder Management Workflow
#
# Extracted from stzfoldertest.ring, block #33.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

# 1. Create main project folder
oProject = new stzFolder("C:\MyProject")
oProject {

    ? @@NL( Info() ) + NL
    
    # 2. Create project structure

    aFolders = ["src", "docs", "tests", "build", "assets"]
    CreateFolders(aFolders)
   
	? @@( Folders() ) + NL
    
    # 3. Navigate and create sub-structure

    GoTo("src")
    CreateFolders(["models", "views", "controllers"])
    
    Up()
    GoTo("assets")
    CreateFolders(["images", "css", "js"])
    
    # Go back to root and show final structure
    Up()

    # Final project tree
    ShowXT()   # (ShowXT takes no depth arg in the documented design)
    
    # 5. Get comprehensive info
    ? ""
    ? @@NL( Info() ) + NL
    
    # 6. Search for specific patterns

    ? @@NL( FindFolders("*view*") )
    
    # 7. Cleanup (commented out for safety)

    ? DeepRemoveAll() # TRUE
    ? Count() #--> 0 #Now the folder is empy!

}

pf()
# Executed in 0.01 second(s) in Ring 1.23
