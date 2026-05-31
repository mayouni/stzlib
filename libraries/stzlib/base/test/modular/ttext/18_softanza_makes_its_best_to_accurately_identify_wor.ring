# Narrative
# --------
# # Softanza makes its best to accurately identify words inside a string.
#
# Extracted from stzTtexttest.ring, block #18.

load "../../../stzBase.ring"


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
