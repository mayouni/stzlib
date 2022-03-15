load "stzlib.ring"

/*------------------ # TODO: Add other languages

? StopWordsIn( :english )
? StopWordsIn( :arabic )

/*------------------

cString = "
The Ring is a practical general-purpose multi-paradigm
language. The supported programming paradigms are
imperative, procedural, object-oriented, declarative
using nested structures, functional, meta programming
and natural programming.

The language is portable (Windows, Linux, macOS, Android,
WebAssembly, etc.) and can be used to create Console,
GUI, Web, Games and Mobile applications.

The language is designed to be simple, small and flexible.

Ring is distributed as a Free-Open Source project under
the MIT License.
"

? ">>> Starting..."
StopWordsMustBeRemoved()

StzStringQ(cLongString) {

	? WordFrequency(:ring)	# --> 0.04
	# You can also say FrequencyOfWord(:ring) or FrequencyOfThisWord(:ring)

	? WordsFrequencies([ :ring, :programming, :language ]) # --> [ 0.04, 0.06, 0.06 ]
	
	? WordsAndtheirFrequencies([ :ring, :programming, :language ])
	# --> [ :ring = 0.04, :programming = 0.06, :language = 0.06 ]

}

/*------------------
*/
? Punctuations()
/*
? ">>>"
cString = "Ring is not the Ring you ware but the Ring you program with: that's Ring!"

StzStringQ(cString) {
	? MostFrequentWord()
}

? "..."

/*



	? MostFrequentWord()

		

	? NMostFrequentWords(n)

		? TopNFrequentWords(n)

	? TopTenFrequentWords()

		? Top10FrequentWords()

	? TopFiveFrequentWords()

		? Top5FrequentWords()

	? TopThreeFrequentWords()

		? Top3FrequentWords()


	? LessFrequentWord()

	? NLessFrequentWords(n)

		? BottomNFrequentWords(n)

	? BottomTenFrequentWords()

		? Bottom10FrequentWords()

	? BottomFiveFrequentWords()

		? Bottom5FrequentWords()

	? BottomThreeFrequentWords()

		? Bottom3FrequentWords()
