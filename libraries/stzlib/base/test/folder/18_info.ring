# Narrative
# --------
# Detailed Information
#
# Extracted from stzfoldertest.ring, block #18.
# Portable: runs against the local testarea fixture.

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t18"
BuildTestArea(cTA)

o1 = new stzFolder(cTA)
? @@NL( o1.Info() )
#--> a hashlist describing the folder:
#    name (real case), path, absolutepath, count=6, files=1, folders=5,
#    isempty=0, isreadable=1, isroot=0

RemoveTestArea(cTA)

pf()
# Executed in 0.01 second(s) in Ring 1.23
