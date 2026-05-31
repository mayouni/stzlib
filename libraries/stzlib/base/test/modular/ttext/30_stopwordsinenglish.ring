# Narrative
# --------
# # ? StopWordsIn(:english)
#
# Extracted from stzTtexttest.ring, block #30.

load "../../../stzBase.ring"

? Q("that").IsStopWordIn(:english) #--> TRUE

# ? StopWordsIn(:arabic)
? Q("في").IsStopWordIn(:arabic) #--> TRUE

? Q("that").IsStopWord() #--> TRUE
? Q("في").IsStopWord() #--> TRUE
