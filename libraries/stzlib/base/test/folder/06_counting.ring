# Narrative
# --------
# Counting Contents
#
# Extracted from stzfoldertest.ring, block #6.
# Portable: runs against the local testarea fixture (reproducible counts,
# unlike the original which walked C:\Program Files).

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t06"
BuildTestArea(cTA)

o1 = new stzFolder(cTA)
o1 {

    # Counting files and folders at the current (root) level

    ? Count() # Or CountFilesAndFolders()
    #--> 6

    ? CountFiles()
    #--> 1

    ? CountFolders() # Or CountDirs()
    #--> 5

    # Counting files and folders in depth (recursively)

    ? DeepCount()
    #--> 14

    ? DeepCountFiles()
    #--> 7

    ? DeepCountFolders()
    #--> 7
}

KillTestArea(cTA)

pf()
# Executed in 0.01 second(s) in Ring 1.23
