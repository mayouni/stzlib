# Narrative
# --------
# #narration: case sensitivity in Softanza
#
# Extracted from stzStringTest.ring, block #47.

load "../../stzBase.ring"


pr()

# Do you know that case sensitivity is supported in Softanza,
# not only on stzString but also on stzList ?!

# Look how we can fin an item case-sensitively:

o1 = new stzList([ "emm", "EMM", "eMm", "EMM" ])

? o1.Find("EMM") # Same as FindCS("EMM", :CS = TRUE)
#--> [ 2, 4 ]

? o1.FindCS("EMM", :CS = FALSE)
#--> [ 1, 2, 3, 4 ]

# In fact, all items are equal when case sensitivity is not considered (set to FALSE)!
# In the same way, the size of the list can be counted in a case-sensity way:

? o1.NumberOfItems()
#--> 4

? o1.NumberOfItemsCS(FALSE)
#--> 1

# Now, softanza digs deeper and applies CaseSensitiviy on some other
# non trivial corners of the stzList class : the Content() method!

? o1.Content() # Same as ContentCS(TRUE)
#--> [ "emm", "EMM", "eMm", "EMM" ]

? o1.ContentCS(FALSE)
#--> [ "emm" ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.19
