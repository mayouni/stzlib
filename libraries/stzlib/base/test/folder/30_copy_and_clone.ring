# Narrative
# --------
# Copy and Clone
#
# Extracted from stzfoldertest.ring, block #30.
# Portable: runs against the local testarea fixture (the original cloned a
# handle on C:\Windows\System32).

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t30"
BuildTestArea(cTA)

o1 = new stzFolder(cTA)
o2 = o1.Copy() # Or Clone()

# Original path
? o1.Path()
#--> <testarea>

# Copy points at the same path
? o2.Path()
#--> <testarea>

RemoveTestArea(cTA)

pf()
# Executed in almost 0 second(s) in Ring 1.23
