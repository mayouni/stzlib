# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #185.

load "../../stzBase.ring"


# Let's take this string of text:

o1 = new stzString("<<♥♥♥>>--<<stars>>--<<♥♥♥>>")

# You may want to get the section between two positions:

? o1.BetweenIB(3, 5)
#--> ♥♥♥

# You can also say:
? o1.Section(3, 5)
#--> ♥♥♥

pf()
# Executed in 0.01 second(s) in Ring 1.21
