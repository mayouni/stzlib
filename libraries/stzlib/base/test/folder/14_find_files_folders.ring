# Narrative
# --------
# Specialized Search Methods (FindFiles / FindFolders)
#
# Extracted from stzfoldertest.ring, block #14.
# Portable: runs against the local testarea fixture.

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t14"
BuildTestArea(cTA)

o1 = new stzFolder(cTA)
o1 {
    # Finding deep .png files
    aPng = DeepFindFiles("*.png")
    ? len(aPng)
    #--> 2

    # Finding surface folders whose name contains 'm'
    aM = FindFolders("*m*")
    ? @@( aM )
    #--> [ "/images/", "/music/", "/tempo/" ]
}

KillTestArea(cTA)

pf()
# Executed in 0.01 second(s) in Ring 1.23
