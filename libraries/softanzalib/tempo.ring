load "stzlib.ring"
#------------------------------------

# IDENTIFYING LISTS INSIDE A STRING

# In many situations (especially in AI and ML applications), you
# may need to host a list inside a string, do whatever operations
# on it as as string, and then evaluate it back, in real time, to
# transform it to a vibrant Ring list again!

# Whatever syntax is used (noramal [_,_,_] or short _:_), Softanza
# can recognize any Ring list you would host inside a string:

? StzStringQ('[1,3]').IsListInString()			#--> TRUE
? StzStringQ('1:3').IsListInString()			#--> TRUE

# It tells you if the syntax used is normal or short:

? StzStringQ('[1,3]').IsListInNormalForm()		#--> TRUE
? StzStringQ('1:3').IsListInShortForm()			#--> TRUE

# And knows about the list beeing continuous or not:

? StzStringQ('[1,3]').IsContinuousListInString()	#--> TRUE
? StzStringQ('1:3').IsContinuousListInString()		#--> TRUE

	# REMINDER: A continuous list can be made of contiguous
	#  chars (base on their unciode codepints) or numbers,
	# and you can identify them using the stzList.IsContinuous():

	? StzListQ(1:3).IsContinuous()		#--> TRUE
	? StzListQ("A":"E").IsContinuous()	#--> TRUE

# Back to list IN STRINGS!

# Not only Softanza can see if the list in string is continuous
# or not, it can also see in what syntax thery are:

? StzStringQ('[1,3]').IsContinuousListInNormalForm()	#--> TRUE
? StzStringQ('1:3').IsContinuousListInShortForm()	#--> TRUE

# Now, what about tranforming one form to another: possible in
# both directions, from normal to short, and from short to normal!

? @@( StzStringQ('[1,3]').ToListInShortForm() )		#--> "1:3"
? @@( StzStringQ('1:3').ToListInNormalForm() )		#--> "[1, 2, 3]"

# And by default, of course, the normal form is used:

? @@( StzStringQ('[1,3]').ToListInString() )		#--> "[1, 2, 3]"
? @@( StzStringQ('1:3').ToListInString() )		#--> "[1, 2, 3]"

# If you prefer (or need) the short form, there is an interesting
# alternative to the ToListInShortForm() alternative that uses
# the simple @C prefix, like this:

? @@( StzStringQ('[1,3]').ToListInString@C() )		#--> "1 : 3"
? @@( StzStringQ('1:3').ToListInString@C() )		#--> "1 : 3"

# Finally, as a "cerise sur le gâteau", you can evaluation
# the string in list in real time like this:

? StzStringQ('1:3').ToList()	#--> [1, 2, 3]




/*----------

o1 = new stzString("In these days, to be happy is a real challenge!
 I'm not sure how problems will leave us a window for this.
 Fortunately, hope will continue to be there.
 Quiet difficult but not impossible.")

? @@(o1.ToStzText().RemovePunctuationQ().

		LowercaseQ().
		SplitQR(" ", :stzListOfStrings).

		YieldQ('[ @str, Sentiment(@str) ]').
		RemoveDuplicatesQ().
		ToStzHashList().Classify() ) # ===> Dbug stzHashList.Classify()

//		Classify() )




//		ClassesAndTheirFrequencies()

//		DominantClass()
//		WeakestClass()

#--> [
# 	:Positive = 0.32
# 	:Neutral  = 0.16
# 	:Negative = 0.52
#    ]


func Sentiment(pcWord)
	# EXAMLE

	# ? Sentiment(:glad) 	#--> :Positive
	# ? Sentiment(:quiet) 	#--> :Neutral
	# ? Sentiment(:problem) 	#--> :Negative

	

	oHashList = new stzHashList([
		:Positive = [
			:happy, :nice, :glad, :beautiful, :wonderful,
			:fortunately, :hope, :sure, :continue ],

		:Neutral = [
			:in, :to, :be, :a, :is, :will, :can, :some,
			:these, :days, :quiet, :real, :us, :window,
			:for, :this, :there, :but
		],

		:Negative = [
			:no, :not, :must, :difficult, :problem, :leave,
			:impossible
		]
	])

	return oHashList.KeyByValueInList(pcWord)

