# Narrative
# --------
# #narration
#
# Extracted from stzlisttest.ring, block #33.

load "../../../stzBase.ring"


pr()

# The fellowing two code snippets illustrate the use of two similar functions.
# Try to read the code, see the output and identify the difference between them...

# First snippet

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceAnyItemAtPositionsByManyXT([ 3, 5, 7, 9], [ "♥", "♥♥" ])
	
? o1.Content()
#--> [ "ring", "php", "♥", "ruby", "♥♥", "python", "♥", "csharp", "♥♥" ]
	
# Second snippet

o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceItemAtPositionsByManyXT([ 1, 3, 5, 7, 9], "ring", [ "♥", "♥♥" ])

? o1.Content()
#--> [ "♥", "php", "♥♥", "ruby", "♥", "python", "♥♥", "csharp", "♥" ]

# Read how Google Bard answered the question:
# Link: https://bard.google.com/share/fb5fb52af8de

pf()
# Executed in 0.03 second(s)
