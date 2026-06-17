# Narrative
# --------
# Folder Status Checks
#
# Extracted from stzfoldertest.ring, block #3.
# Portable: runs against the local testarea fixture.

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t03"
BuildTestArea(cTA)

o1 = new stzFolder(cTA)
o1 {
    ? IsReadable()
    #--> 1

    ? Exists("images")     # a direct sub-folder
    #--> 1

    ? HasFiles() # Or ContainsFiles()
    #--> 1

    ? HasFolders() # Or HasDirs()
    #--> 1
}

RemoveTestArea(cTA)

pf()
# Executed in almost 0 second(s) in Ring 1.23
