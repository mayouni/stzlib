# Narrative
# --------
# Data Parsing - choosing appropriate behavior:
#
# Extracted from stzregexmakertest.ring, block #50.

load "../../stzBase.ring"


pr()

o1 = new stzRegexMaker

# :shortest for individual items
o1.AddMatchLength("\w+", :shortest)  # Split "item1,item2" into separate matches

# :longest for full entries
o1.AddMatchLength(".+", :longest)    # Capture "key=value" as single entry

# :complete for fixed formats
o1.AddMatchLength("\d+", :complete)  # Match complete number without backtracking

? o1.Pattern()
#--> \w++?.++\d+++

pf()
# Executed in almost 0 second(s) in Ring 1.22
