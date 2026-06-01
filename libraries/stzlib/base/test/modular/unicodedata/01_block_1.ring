# Narrative
# --------
#
# Extracted from stzunicodedatatest.ring, block #1.

load "../../../stzBase.ring"

pr()

# Getting a char by its unicode codepoint
? StzChar(65014) #--> ﷶ
? StzChar(65013) #--> ﷵ

# Taking the way back and getting the unicode
# codepoint of a given char
? Unicode("ﷶ") #--> 65014
? Unicode("ﷵ") #--> 65013


pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.06 second(s) in Ring 1.19
