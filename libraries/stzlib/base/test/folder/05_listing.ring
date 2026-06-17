# Narrative
# --------
# Listing Files and Folders
#
# Extracted from stzfoldertest.ring, block #5.
# Portable: runs against the local testarea fixture. Note the listing
# convention -- folders come back lowercased and wrapped in "/.../", files
# lowercased and prefixed with "/".

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t05"
BuildTestArea(cTA)

o1 = new stzFolder(cTA)
o1 {

    ? CountFiles()
    #--> 1

    aFiles = Files()
    ? @@( aFiles )
    #--> [ "/test.txt" ]

    ? CountFolders()
    #--> 5

    aFolders = Folders() # Or Dirs() or SubFolders()
    ? @@( aFolders )
    #--> [ "/docs/", "/images/", "/music/", "/tempo/", "/videos/" ]
}

KillTestArea(cTA)

pf()
# Executed in 0.01 second(s) in Ring 1.23
