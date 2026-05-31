# Narrative
# --------
# cText = "John is the son of John second.
#
# Extracted from stzTtexttest.ring, block #28.

load "../../../stzBase.ring"

Second son of John second is William second."

StzTextQ(cText) {
? "#1"
	? NumberOfWords() #--> 15
	? UniqueWords()	#--> [ "john", "is", "the", "son", "of", "second", "william" ]
? "#2"
	? WordsAndTheirFrequencies()
	#--> [ [ "john", 0.20 ], [ "is", 0.13 ], [ "the", 0.07 ],
	# 	[ "son", 0.13 ], [ "of", 0.13 ], [ "second", 0.20 ],
	# 	[ "william", 0.27 ] ]
	#     ]
? "#3"
	? UniqueWordsFrequencies()
	#--> [ 0.20, 0.13, 0.07, 0.13, 0.13, 0.27, 0.07 ]
? "#4"
	? WordFrequency(:son)		#--> 0.13
	? WordAndItsFrequency(:son) 	#--> [ :son, 0.13 ]
? "#5"
	? TheseWordsFrequencies([ :son, :second, :john ])
	#--> [ 0.13, 0.27, 0.20 ]
? "#6"
	? TheseWordsAndTheirFrequencies([ :son, :second, :john ])
	#--> [ :son = 0.13, :second = 0.27, :john = 0.20 ]
? "#7"
	? WordsHavingThisFrequency(0.13)
	#--> [ "is", "son", "of" ]
? "#8"
	? WordsHavingTheseFrequencies([ 0.13, 0.20 ])
	#--> [ "is", "son", "of", "john", "second" ]
? "#9"
	? FequenciesAndTheirWords([ 0.13, 0.20 ])
	#--> [ "0.13" = [ "is", "son", "of" ], "0.20" = [ "john", "second" ] ]
 ? "#10"
	? NMostFrequentWords(3) #--> [ "william", "john", "second" ]
	# You can also say ? Top3FrequentWords()
? "#11"
	? NMostFrequentWordsAndTheirFrequencies(3)
	#--> [ "william" = 0.27, "john" = 0.20, "second" = 0.20 ]

}
