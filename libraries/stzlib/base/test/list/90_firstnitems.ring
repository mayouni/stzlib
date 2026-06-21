# Narrative
# --------
# Grabbing the first and last N items of a thousand-element list.
#
# A 1000-item list of "R_ING" is wrapped in a stzList and normalised with
# StringifyLowercaseAndReplace("_", "♥"): every item is stringified and
# lowercased ("R_ING" -> "r_ing"), then the SUBSTRING "_" is replaced by
# the multibyte heart, giving "r♥ing". FirstNItems(3) and LastNItems(3)
# then slice just the head and tail -- the Softanza idiom for peeking at
# the ends of a large collection without scanning the whole thing.
#
# Extracted from stzlisttest.ring, block #90.

load "../../stzBase.ring"

pr()

aLargeList = []
for i = 1 to 1_000
	aLargeList + "R_ING"
next

o1 = new stzList(aLargeList)
o1.StringifyLowercaseAndReplace("_", "♥")

? o1.FirstNItems(3)
#--> [ "r♥ing", "r♥ing", "r♥ing" ]

? o1.LastNItems(3)
#--> [ "r♥ing", "r♥ing", "r♥ing" ]

pf()
# Executed in 0.05 second(s) in Ring 1.22
# Executed in 0.10 second(s) in Ring 1.19 (64 bits)
# Executed in 0.09 second(s) in Ring 1.19 (32 bits)
# Executed in 0.12 second(s) in Ring 1.17
