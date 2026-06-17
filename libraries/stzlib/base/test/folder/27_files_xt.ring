# Narrative
# --------
# FilesXT, IsFile, name normalisation, and folder-path checks
#
# Extracted from stzfoldertest.ring, block #27.
# Portable: runs against the local testarea fixture.

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t27"
BuildTestArea(cTA)

o1 = new stzFolder(cTA)

? @@( o1.FilesXT() )
#--> [ "<testarea>/test.txt" ]

# Membership by name (case-insensitive, slash-agnostic)
? o1.IsFile("test.txt")
#--> 1

? o1.IsFile("nope.txt")
#--> 0

# Listing-form name normalisers
? o1.NormalizeFileName("test.txt")
#--> /test.txt

? o1.NormalizeFolderName("images") + NL
#--> /images/

? @@( o1.Folders() )
#--> [ "/docs/", "/images/", "/music/", "/tempo/", "/videos/" ]

? o1.IsFolderPath("/images")
#--> 1

? o1.IsFolderPath("images")
#--> 1

RemoveTestArea(cTA)

pf()
# Executed in 0.01 second(s) in Ring 1.23
