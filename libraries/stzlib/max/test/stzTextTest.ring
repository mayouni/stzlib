load "../stzmax.ring"

pron()

o1 = new stzText("ring programming, best of programming!")
? o1.FindAllCS("programming", :CS = FALSE)
#--> [ 6, 27 ]

proff()

/*--------------- Chars() VS Letters()

pron()

str = "Пи++е́тو**שָׁ ب d ("
? @@( SQ(str).Chars() ) # Uses stzString
#--> [ "П", "и", "+", "+", "е", "́", "т", "و", "*", "*", "ש", "ָ", "ׁ", " ", "ب", " ", "d", " ", "(" ]

? @@( TQ(str).Letters() ) # Uses stzText
#--> [ "П", "и", "е", "т", "و", "ש", "ب", "d" ]

proff()

/*========================

# Arabic Shaddah ("ّ ") is a considedred by Unicode as a diacritic,
# say a special vocal sign that decorates the consonent letters like
# a, e, and i in latin languages.

? StzCharQ(ArabicShaddah()).IsArabicDiacritic() #--> TRUE

# Which is not correct. In fact, diacrirtcs in arabic are:
? @@( Arabic7araket() ) # [ "ُ ", "َ ", "ِ ", "ْ " ]

# As you see, ("ّ ") is not one of them. That's because the Shaddah
# is actually a letter and NOT a diacritic:

? StzCharQ(ArabicShaddah()).IsLetter() #--> TRUE

# In fact, Arabs use it as a short form for a stressed letter like the "د" in
# the word "مودّتي" (that we read as "mawaDDati" --> with a stressed D)

# Hence, when we ask Softanza for the list of letters in this word:

txt = "مودّتي"
? @@( TQ(txt).Letters() )
#--> Gives ["م", "و", "د", " ّ", "ت", "ي" ]

# the ("ّ ") is managed here as a letter a part. Softanza even help you to get
# Bua more explicit result, by replacing the shaddach char by the letter it
# actually represents:

? @@( TQ(txt).LettersXT([ :ManageArabicShaddah = TRUE ]) )
#o--> [ "م", "و", "د", "د", "ت", "ي" ]

/*------------------ // Retest after adding ReplaceAllCharsW() in stzString

? StzTextQ("évènement").DiacriticsRemoved()
? StzTextQ("Zoölogy").DiacriticsRemoved()

/*------------------ // Retest after adding ReplaceAllCharsW() in stzString

? StzTextQ("مُسْتَحَقَّاتُُ").Scripts()
? StzTextQ("مُسْتَحَقَّاتُُ").Script()


? StzTextQ("مُسْتَحَقَّاتُُ").DiacriticsRemoved()

? StzTextQ("مُسْتَحَقَّاتُُ").RemoveDiacriticsQ().Content()

/*-------------------

? StringIsStzClassName("stzlist")
? StzStringQ("stzlist").IsStzClassName()

/*------------------

? StzStringQ("和平").Script() #--> :Han

? StzStringQ("和平 210").Script() #--> :Han
? StzStringQ("和平 210").Scripts() #--> [ :Han, :Common ]

? StzStringQ("和平 is 'peace' in chineese!").Script() #--> :Hybrid
? StzStringQ("和平 is 'peace' in chineese!").Scripts() #--> [ :Han, :Common, :Latin ]
#--> Returns :Hybrid

/*------------------

? StzStringQ("سلام").ScriptIs(:Arabic) #--> TRUE
? StzStringQ("Peace").ScriptIs(:Latin) #--> TRUE
? StzStringQ("和平").ScriptIs(:Han) #--> TRUE (China)
? StzStringQ("શાંતિ").ScriptIs(:Gujarati) #--> TRUE (India, Pakistan)

/*--------------------

# Is this arabic word diacriticized?
? StzStringQ("سَلَامُُ").ContainsDiacritics() # TRUE

# The word contains some letters and diacritics
# Let's see what is the script of one letter

? StzStringQ("س").Script() #--> :Arabic

# And what is the script of a diacritic, the Fat7ah
# for example (the small line above the letter سَـ
? StzStringQ(ArabicFat7ah()).Script() #--> :Inherited

# In fact, Unicode considers it as an inherited script
# because it inherits is script from a previous char.

# Now, if we ask for the script of the hole word, that
# contains both arabic letters (arabic script) and
# inherited scripts (the arabic diacritics), Softanza
# makes no mistaks (and corrects Unicode in this regard)
# and says it is an arabic script

? StzStringQ("سَلَامُُ").Script() #--> :Arabic

# And even if you include some chars belonging to
# :Common script, like space for example, the result
# is as expected, an :Arabic script
? StzStringQ("السَّلَامُ عَلَيْكُمْ").Script() #--> :Arabic
? StzStringQ("السلام عليكم").Script() #--> :Arabic

/*--------------------

# Now, let's see how diacritics can be removed from a french text
? StzStringQ("C'était un énoncé accentuée, à vrai-dire, extrâ!").DiacriticsRemoved()
# and than from an arabic text
? StzStringQ("السَّلَامُ عَلَيْكُمْ").DiacriticsRemoved()

# Which is a useful feature when you are building the index of a search
# application, since diacritics corrospond to sound variations of the
# main letters.

/*-------------------

? StzStringQ(" 4  ُ  ").Scripts() #--> [ :Common, :Inherited ]
? StzStringQ(" 4  ُ  ").Script()	 #--> :Inherited

/*-------------------

? StzStringQ(" 4  ُ  ").IsScript(:Hybrid) #--> TRUE
? StzStringQ("  ").IsScript(:Common) #--> TRUE
? StzStringQ(ArabicDhammah()).IsScript(:Inherited) #--> TRUE

/*-------------------

o1 = new stzString("latin 4  ُ  ")
? o1.Scripts()
? o1.Script()

? StzStringQ("latin 4  ُ  ").ScriptIs(:Latin)

/*-------------------

o1 = new stzString("Abc285XY&من")
? o1.Scripts()
? o1.ScriptIs(:Hybrid)


/*==================

StzTextQ("Programming Without Code Technology") {

	? Initials()
	#--> [ "P", "W", "C", "T" ]

	? InitialsAsString()
	#--> PWCT

	# Or you can return any type you need using the QR() construct:
	? InitialsQR(:stzString).Content()
}

/*==================

str = "
“General Punctuation”! ; This means there is more to know, right?!
Well.. there is a set of supplemental “Punctuation” in Unicode.
"

StzTextQ(str) {

	? NumberOfPunctuations() #--> 12
	? Punctuations() #--> [ "“", "”", "!", ";", ",", "?", "!", ":", "”", "." ]

	? NumberOfUniquePunctuations() #--> 7
	? UniquePunctuations() #--> [ "“", "”", "!", ";", ",", "?", "." ]

	? NumberOfGeneralPunctuations() #--> 4
	? GeneralPunctuations() #--> [ "“", "”", "“", "”" ]

	? NumberOfSupplementalPunctuations() #--> 0
	? SupplementalPunctuations() #--> [ ]

}

/*-----------------

str = "
ليكن هذا النّصّ العربّي، هل من قارئ له؟ لا؟! لا بأس: سنحاول...
"

StzTextQ(str) {

	? NumberOfPunctuations() #--> 8
	? Punctuations() #--> [ "،","؟","؟","!",":",".",".","." ]

	? NumberOfUniquePunctuations() #--> 5
	? UniquePunctuations() #--> [ "،","؟","!",":","." ]

	? NumberOfGeneralPunctuations() #--> 0
	? GeneralPunctuations() #--> [ ]

	? NumberOfSupplementalPunctuations() #--> 0
	? SupplementalPunctuations() #--> [ ]

}

/*-----------------..........................................................



str = StzStringQ('').FromURL("https://ring-lang.github.io/doc1.16/qt.html")

StzTextQ(str) {
	? Punctuations()
}

/*-----------------

# Softanza makes its best to accurately identify words inside a string.

//? StzTextQ("Softanza: playing with words!!").Words()
#--> [ :softanza, :playing, :with, :words, 1001, times ]

# Or even more complex string like this:

//? StzTextQ('Softanza: "playing" with words 1001 times!!').Words()
#--> [ :softanza, :playing, :with, :words, 1001, times ]

# And you can avoid some words like this:
//? StzTextQ('Softanza: "playing" with words 1001 times!!').WordsExcept([ "with", "1001" ])
#--> [ :softanza, :playing, :words, times ]

# For a given language (english by default), you can avoid stop-words alltogether:

StopWordsMustBeRemoved()
? StzTextQ('Softanza: "playing" with words 1001 times!!').Words()
#--> [ :softanza, :playing, :words, 1001, times ]

#NOTE that :with has been removed from the output. That's because
# it figures in the EnglisgStopWords() list defined by default
# (containing thousands of stopwords, not only for english but
# for a dozen of other langauges).

# If you don't want this, then you need just to avoid
# StopWordsMustBeRemoved() instructions # or you can do it
# explicitly like this:

StopWordsMustNotBeRemoved()
? StzTextQ('Softanza: "playing" with words 1001 times!!').Words()
#--> [ :softanza, :playing, :words, :with, 1001, times ]

# and you can see the word :with in the output again.

/*-----------------

# In rality, this word identification process is time-consuming for
# large texts. This will be enhanced in the future, but for now,
# you can instruct Softanza to adopt a quicker route, with less
# constraints, by using one of these two nstructions:

IdentifiyWordsInQuickMode()

str = StzStringQ('').FromURL("https://ring-lang.github.io/doc1.16/qt.html")
? StzTextQ(str).Words() #--> [ ... ]

# Quiet quick, isn't it? But if we say:

IdentifyWordsInStrictMode()
? StzTextQ(str).Words() #--> [ ... ]

# Then you will get a more accurate result but takes mutch more time!

# The idea is that library lets you make your own choice and think of
# the acceptable balance, for you actual needs, between accuracy
# and performance!

/*----------------- TODO

# Besides this, and for total control on how Softanza does its job,
# other useful instructions are provided to fine-tune the inherent
# words identification process (see examples below).

# Like their StopWordsMustBeRemoved() and StopWordsMustNotBeRemoved()
# sister instructions, they are defined at the global level, to make
# them easy to use, and will affect any function related to words,
# like NumberOfWords(), FindWords(), Words(), ReplaceWord(), etc.

? CharsAllowedInStartOfWord()
? CharsNotAllowedInStartOfWord()
? SubstringsAllowedInStartOfWord()
? SubstringsNotAllowedInStartOfWord()
? "---"
? CharsAllowedInsideWord()
? CharsNotAllowedInsideWord()
? SubstringsAllowedInsideWord()
? SubstringsNotAllowedInsideWord()
? "---"
? CharsAllowedInEndOfWord()
? CharsNotAllowedInEndOfWord()
? SubstringsAllowedInEndOfWord()
? SubstringsNotAllowedInEndOfWord()

# Hence, those instructions define what king of chars,
# in plus of letters themselves, should be considered
# by softanza in identifying words...

/*----------------- //////////////////////////////////////

# Finally, to bettter undersand what happens internally
# while Softanza analyses a text and try to recognize
# its words, these are the two simple steps performed:

# First, The instructions we saw in the above section, are used to
# generate a list of all possible instances of a given word
# in start, middle and and end of sentence. Like this:


? PossibleInstancesOfWord("Mahmoud")

# Then, those instances are searched one by one inside the text, so
# we can find all the possible forms the word takes in the text.

/*---------------

StzTextQ("mahmoud, ahmed, mohamed, Mahmoud, mahmoud, ahmed.") {
	FindAllOccurrencesOfWordCS(pcWord, pCaseSensitive)
}

/*---------------

o1 = new stzText("Let's meet in Tunis next month!")
o1.ReplaceWord("Tunis", :With = "Cairo")
? o1.Content()

/*--------------

// ReplaceWord --> ReplaceWords --> ReplaceWordsWithMarquers --> ReplaceWordsWithMarquersXT
// --> ReplaceWordCS
StzTextQ("mahmoud, ahmed, mohamed, Mahmoud, mahmoud, ahmed.") {
	ReplaceWordsWithMarquers()
	//ReplaceWordsCS(["mahmoud"], :With = ["Mansour"], :CS = FALSE)
	//? Content()
}

/*--------------

StzTextQ("mahmoud, ahmed, mohamed, Mahmoud, mahmoud, ahmed.") {
	ReplaceWordsWithMarquersXT([
		:By = :OrderOfOccurrenceOfWords,
		:Except = [],
		:StopWords = :MustNotBeRemoved
	])
	#--> "#1, #2, #3, #4, #5, #6."
}

/*------------

o1 = new stzText("Ring is not the Ring you ware but the Ring you program with!")
o1.ReplaceWordsCS( [ :ring ], [ :Watch ], :CS = FALSE )
? o1.Content()

/*
ReplaceManyWordsCS(pacWords, pacNewWords, pCaseSensitive)
ReplaceEachWordCS(pacWords, pacNewWords, pCaseSensitive)
ReplaceAllOccurrencesOfWordsCS(pacWords, pacNewWords, pCaseSensitive)

/*----------------------

cText = "John is the son of John second. 
Second son of John second is William second."

StopWordsMustBeRemoved()

StzTextQ(cText) {
	? Words()
}

/*----------------------

cText = "John is the son of John second. 
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

/*-------------- ////// BACK HERE ////////

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

/*----------------------

# ? StopWordsIn(:english)
? Q("that").IsStopWordIn(:english) #--> TRUE

# ? StopWordsIn(:arabic)
? Q("في").IsStopWordIn(:arabic) #--> TRUE

? Q("that").IsStopWord() #--> TRUE
? Q("في").IsStopWord() #--> TRUE

/*----------------------

? Q("that").LanguageIfStopWord() 	#--> :English
? Q("في").LanguageIfStopWord() 		#--> :Arabic

/*----------------------

? StzTextQ("Kırşehir").DiacriticsRemoved() #--> "Kirsehir" / Turkish
? StzTextQ("Þingvellir").DiacriticsRemoved() #--> "Pingvellir" / Iceland
? stzTextQ("Malmö").DiacriticsRemoved() #--> "Malmo"	/ Swidesh

/*----------------- ///// ERRROR /////

# When you try to remove the diacritics of the german word "München"
? StzTextgQ("München").DiacriticsRemoved() #--> "Munchen"

# Softanza tries its best and returns "Munchen".

# But this is not correct, since an e should be added after the u that
# replaced ü. To make it right, you need to inform Softanza about the
# locale to use as a context for the undiacritization operation.

# Hence, you should say:
? StzTextQ("München").DiacriticsRemovedInLocale([ :Language = :German ]) # "Muenchen"

# and you're done with the correct answer!

/*-----------------

o1 = new stzText("A la recherche du temps perdu")
? o1.Words()
? o1.WordsPositions()
? o1.WordsAndTheirPositions()

/*----------------- ok

StzTextQ( "Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl !" ) {
	? OnlyArabic()
	#--> Returns: "حنين جميلة وعمرها 7 سنوات !"

	? OnlyLatin()
	#--> Returns: "Hanine is a nice 7 years-old girl!"
}


/*-------------- REFACTORED: FIXING IS IN PROGRESS

//TODO >>> stzLocale

o1 = new stzText("this is my first experience with that company")
#o1 = new stzString("من عالمك إلى عالمي على مسؤوليّتي")
? o1.RemoveStopWordsInQ(:Latin).Content()


/*--------------

o1 = new stzString("this is just عربي latin script")
? o1.ToStzText().Scripts()
#--> [
#	:latin,
#	:common,
#	:arabic
#    ]

/*-------------- ERROR: FIXING IN PROGRESS

o1 = new stzText("Ring 17")
? o1.IsWord() #--> TRUE

o1 = new stzText("Ring_17")
? o1.IsWord() #--> TRUE

o1 = new stzText("حُسَيْــــنْ")
? o1.IsArabicWord()

? StringIsWord("حُسَيْــــنْ")

/*-------------

o1 = new stzText("softanza")
? o1.ContainsOnlyLetters() #--> TRUE

/*--------------

o1 = new stzText("Python Ruby Ring Julia")
? o1.ContainsWord("Ring")


/*-----------------

o1 = new stzText("Ring Python Ruby Julia")
? o1.WordsQR(:stzString).Content()
