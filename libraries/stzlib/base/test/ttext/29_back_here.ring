# Narrative
# --------
# ////// BACK HERE ////////
#
# Extracted from stzTtexttest.ring, block #29.

load "../../stzBase.ring"


cText = "John is the son of John second. 
Second son of John second is William second."

StopWordsMustBeRemoved()

StzTextQ(cText) {
? "#1"
	? NumberOfWords() #--> 6
	? UniqueWords()	#--> [ "john", "son", "william" ]
? "#2"
	? WordsAndTheirFrequencies()
	#--> [ [ "john", 0.50 ], [ "son", 0.33 ], [ "william", 0.50 ] ]
	#     ]
? "#3"
	? UniqueWordsFrequencies()
	#--> [ 0.50, 0.33, 0.17 ] ERROR in 0.17?
? "#4"
	? WordFrequency(:son)		#--> 0.33
	? WordAndItsFrequency(:son) 	#--> [ :son, 0.33 ]
? "#5"
	? TheseWordsFrequencies([ :son, :second, :john ])
	#--> [ 0.33, 0.67, 0.50 ] !!!!! ERROR : second is a stopword, shouldnt be counted
? "#6"
	? TheseWordsAndTheirFrequencies([ :son, :second, :john ])
	#--> [ :son = 0.33, :second = 0.67, :john = 0.50 ]
? "#7"
	? WordsHavingThisFrequency(0.50)
	#--> [ "john", "william" ]
? "#8"
	? WordsHavingTheseFrequencies([ 0.50, 0.67 ]) # change to [ 0.50, 0.33 ]
	# !--> [ "john", "william", "son" ]
? "#9"
	? FequenciesAndTheirWords([ 0.50, 0.67 ])
	#--> ERROR
 ? "#10"
	? NMostFrequentWords(2) #--> [ "william", "john" ]
	# You can also say ? Top3FrequentWords()
? "#11"
	? NMostFrequentWordsAndTheirFrequencies(2)
	#--> [ "john" = 0.50, "william" = 0.50 ]

}
