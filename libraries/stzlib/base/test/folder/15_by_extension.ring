# Narrative
# --------
# Files by Extension
#
# Extracted from stzfoldertest.ring, block #15.
# Portable: runs against the local testarea fixture. The extension may be
# given with or without the leading dot.

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t15"
BuildTestArea(cTA)

o1 = new stzFolder(cTA)
o1 {
    # Getting .txt files at the root
    aTxt = FilesByExtension(".txt")
    ? @@( aTxt )
    #--> [ "/test.txt" ]

    # The same, extension without the dot -- both forms work
    aTxt2 = FilesByExtension("txt")
    ? @@( aTxt2 )
    #--> [ "/test.txt" ]
}

KillTestArea(cTA)

pf()
# Executed in almost 0 second(s) in Ring 1.23
