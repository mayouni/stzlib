# Narrative
# --------
# Complete Folder Management Workflow
#
# Extracted from stzfoldertest.ring, block #33.
# Portable + non-destructive: a local sandbox replaces C:\MyProject.

load "../../stzBase.ring"

pr()

cProj = CurrentDir() + "/_t33"
if dirExists(cProj) RemoveFolderRecursive(cProj) ok
QMkdir(cProj)

oProject = new stzFolder(cProj)
oProject {

    ? @@NL( Info() ) + NL

    # 2. Create the project structure (CreateFolders makes siblings without
    #    changing the current position)
    aFolders = ["src", "docs", "tests", "build", "assets"]
    CreateFolders(aFolders)

    ? @@( Folders() ) + NL
    #--> [ "/assets/", "/build/", "/docs/", "/src/", "/tests/" ]

    # 3. Navigate and create sub-structure
    GoTo("src")
    CreateFolders(["models", "views", "controllers"])

    Up()
    GoTo("assets")
    CreateFolders(["images", "css", "js"])

    # Back to root, show the final tree
    Up()
    ShowXT()

    # 5. Comprehensive info
    ? ""
    ? @@NL( Info() ) + NL

    # 6. Search for a pattern across the whole tree
    ? @@( DeepFindFolders("*view*") )
    #--> the "views" folder found under src/

    # 7. Cleanup
    ? DeepRemoveAll() #--> 1
}

if dirExists(cProj) RemoveFolderRecursive(cProj) ok

pf()
# Executed in 0.01 second(s) in Ring 1.23
