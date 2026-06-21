# Narrative
# --------
# IsMultilingualString(): is this hashlist a set of translations?
#
# A multilingual string is a hashlist whose KEYS are language names or
# abbreviations and whose VALUES are the translated strings -- e.g.
# [ :english = "house", :french = "maison", :arabic = "منزل" ] or the
# abbreviated [ :en = ..., :fr = ..., :ar = ... ]. Every value must be a
# string and every key a recognised language identifier.
#
# Extracted from stzlisttest.ring, block #628.

load "../../stzBase.ring"

pr()

o1 = new stzList([ :english = "house", :french = "maison", :arabic = "منزل" ])
? o1.IsMultilingualString()
#--> TRUE

o1 = new stzList([ :en = "house", :fr = "maison", :ar = "منزل" ])
? o1.IsMultilingualString()
#--> TRUE

pf()
# Executed in almost 0 second(s)
