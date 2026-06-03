# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #4.

load "../../stzBase.ring"


# Create a 1D list and set all items to 1000

myList = 1:1_000_0//00

FastProUpdate(myList, :set = [ :All, :with = 1000 ])
? ShowShort(myList)
#--> [ 1000, 1000, 1000, "...", 1000, 1000, 1000 ]

# In RinFastPro
# updateList(myList, :set, :items, 1000)


pf()
# Executed in 0.37 second(s) in Ring 1.25
# Executed in 0.34 second(s) in Ring 1.22
