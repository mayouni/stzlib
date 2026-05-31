# Narrative
# --------
# */
#
# Extracted from stzchartest.ring, block #2.

load "../../../stzBase.ring"

pr()

? isvowel("a") 		# Ring function

? @IsVowel("a") 	# Softanza alternative
? @IsVowel("aie")
? @IsVowel([ "a", "i", "e" ])

? AreVowels("aie")
? AreVowels([ "a", "i", "e" ])

pf()
# Executed in 0.02 second(s)
