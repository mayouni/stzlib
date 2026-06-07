# Narrative
# --------
# #narration BETWEEN vs BOUNDEDBY
#
# Extracted from stzccodetest.ring, block #4.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()
#                         7  10
# BETWEEN ~>           xxx[--v----------------]xxx
o1 = new stzString("___<<<ring>>>___<<<softanza>>>___")
# BOUNDEDBY ~>         xxx[--]xxx   xxx[------]xxx
        
# In Softanza, BETWEEN returns the substring between
# two substrings or positions

? o1.Between("<<<", ">>>") # Or SubStringBetween()
#--> "ring>>>___<<<softanza"

? o1.Between(6, 11) + NL # Equivalent to Section(7, 10)
#--> "ring"

# But BOUNDEDBY returns the substrings bounded by
# two other substrings, like this:

? o1.BoundedBy([ "<<<", ">>>" ])
#--> [ "ring", "softanza" ]

pf()
# Executed in almost 0 second(s) in Ring 1.26 (Backed by StzEngine)
# Executed in 0.01 second(s) in Ring 1.21
