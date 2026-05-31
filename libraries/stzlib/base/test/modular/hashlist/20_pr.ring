# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #20.

load "../../../stzBase.ring"


# The keys of a hashlist must be unique. Otherwise you won't be able to
# create the hashlist objectS

o1 = new stzHashList([ :name = "Brad", :job = "actor", :job = "singer" ])
#--> Error message: The list you provided is not a hash list!

pf()
