# Narrative
# --------
# Edge cases
#
# Extracted from stzadverbtest.ring, block #8.

load "../../../stzBase.ring"


pr()

? Adverb("QUICK")		#--> quickly
? Adverb("  slow  ")		#--> slowly
? Adverb("xyzabc")		#--> xyzabcly

? ""

# Vowel+y test
? Adverb("play")		#--> playily

# Consonant+y test
? Adverb("dry")			#--> drily

pf()
# Executed in 0.26 second(s) in Ring 1.23
# Executed in 0.56 second(s) in Ring 1.22
