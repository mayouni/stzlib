# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #17.

load "../../../stzBase.ring"


o1 = new stzString("ring qt softanza pyhton kandaji csharp ring")
o1.ReplaceManyByManyXT([ "ring", "softanza", "kandaji" ], :By = [ "♥", "♥♥" ])

? o1.Content()
#--> ♥ qt ♥♥ pyhton ♥ csharp ♥

pf()
# Executed in 0.01 second(s)

#==== #narration

StartProfiler()

# You can find the positions of any substring occurring between
# two bounds by saying:

o1 = new stzString("txt <<ring>> txt <<php>>")
? @@( o1.FindAnyBoundedBy(["<<",">>"]) )
#--> [7, 20]

# In fact, the substring "ring" occures in position 7 and "php" in position 20.

# Now, if you have the following case where the two bounds are
# the same (equal to "*" here):

o1 = new stzString("*2*45*78*0*")
? @@( o1.FindAnyBoundedBy(["*","*"]) ) # or simply FindAnyBoundedBy("*")
#--> [ 2, 4, 7, 10 ]

# Let's craft a visual explanation of what happened:

	# the positions	:  12345678901
	# the string	: "*2*45*78*0*"
	# the Occurrences:   ^ ^  ^  ^
	#--> [2, 4, 7, 10]


StopProfiler()
# Executed in 0.01 second(s)
