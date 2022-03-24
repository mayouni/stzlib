
load "stzlib.ring"

/*----------------

o1 = new stzstring("abcDEFgehij")
o1.ReplaceSection(4, 6, :with = "***")
? o1.Content()

/*---------------
*/
o1 = new stzstring("abcDEFgehij")
? o1.Section(4,6)
/*
o1.ReplaceSection(4, 6, :with@ = "Q(@section).Lowercased()")
? o1.Content()

/*

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

