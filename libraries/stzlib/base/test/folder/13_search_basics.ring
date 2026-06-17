# Narrative
# --------
# Basic Search Operations
#
# Extracted from stzfoldertest.ring, block #13.
# Portable: runs against the local testarea fixture (the original searched
# C:\Windows\System32 for *.exe).

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t13"
BuildTestArea(cTA)

o1 = new stzFolder(cTA)
o1 {
    # Finding .txt files at the surface (root) level
    acTxt = FindFiles("*.txt")
    ? @@( acTxt )
    #--> [ "/test.txt" ]

    # The same search across the whole tree
    ? @@NL( DeepFindFiles("*.txt") )
    #-->
    '
    [
    	"/test.txt",
    	"/tempo/temp1.txt",
    	"/tempo/temp2.txt",
    	"/images/notes/howto.txt",
    	"/images/notes/sources.txt"
    ]
    '
}

RemoveTestArea(cTA)

pf()
# Executed in 0.01 second(s) in Ring 1.23
