# Narrative
# --------
# When Vr() is given a duplicated name (here :name2 appears
# twice), the LAST assignment wins. So binding the three slots
# to "Hussein", "Haneen", "Teeba" with names :name1 / :name2 /
# :name2 leaves v(:name2) == "Teeba" (not "Haneen").
#
# Extracted from stznamedvarstest.ring, the head dedupe block.

load "../../../stzBase.ring"

pr()

# Last assignment wins with duplicate names
Vr([ :name1, :name2, :name2 ]) '=' Vl([ "Hussein", "Haneen", "Teeba" ])
? v(:name2)
#--> Teeba

pf()
