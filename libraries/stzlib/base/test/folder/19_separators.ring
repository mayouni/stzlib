# Narrative
# --------
# Softanza uses "/" as a separator but gives access to the system separator
#
# Extracted from stzfoldertest.ring, block #19.
# Portable: runs against the local testarea fixture.

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t19"
BuildTestArea(cTA)

o1 = new stzFolder(cTA)

? o1.Separator()
#--> /

? o1.SystemSeparator() # On Windows
#--> \

? o1.Path() # All outputs use the "/" separator
#--> <testarea> (with "/" separators)

# NOTE: You can enter paths with either '/' or '\' and Softanza
# understands them indifferently.

? @@( o1.FindFile("/test.txt") )
#--> [ "/test.txt" ]

? @@( o1.FindFile("\test.txt") )
#--> [ "/test.txt" ]

KillTestArea(cTA)

pf()
# Executed in 0.01 second(s) in Ring 1.23
