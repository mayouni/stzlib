# Narrative
# --------
# Specialized Search Methods (visual search)
#
# Extracted from stzfoldertest.ring, block #16.
# Portable: runs against the local testarea fixture.

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t16"
BuildTestArea(cTA)

o1 = new stzFolder(cTA)
o1 {
    # Visual (tree) search for .txt files at the surface
    ? VizSearchFiles("*.txt")
    #--> a tree rooted at the folder with a (target) stat label and the
    #    matching file marked; only the root level is shown (non-deep).

    # Finding surface folders whose name contains 'm'
    ? @@( FindFolders("*m*") )
    #--> [ "/images/", "/music/", "/tempo/" ]
}

RemoveTestArea(cTA)

pf()
# Executed in 0.01 second(s) in Ring 1.23
