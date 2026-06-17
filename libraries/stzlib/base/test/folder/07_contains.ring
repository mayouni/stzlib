# Narrative
# --------
# Checking for Specific Content
#
# Extracted from stzfoldertest.ring, block #7.
# Portable: runs against the local testarea fixture.

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t07"
BuildTestArea(cTA)

o1 = new stzFolder(cTA)
o1 {
    ? Contains("images") # Or Has()
    #--> 1

    ? ContainsFile("test.txt")
    #--> 1

    ? ContainsFolder("images") # Or ContainsDir()
    #--> 1

    ? DeepContains("notes") # found deep under images/
    #--> 1
}

RemoveTestArea(cTA)

pf()
# Executed in 0.01 second(s) in Ring 1.23
