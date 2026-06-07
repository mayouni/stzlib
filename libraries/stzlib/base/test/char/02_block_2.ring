# Narrative
# --------
#
# Extracted from stzchartest.ring, block #2.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? isvowel("a") 		# Ring function

? @IsVowel("a") 	# Softanza alternative
? @IsVowel("aie")
? @IsVowel([ "a", "i", "e" ])

? AreVowels("aie")
? AreVowels([ "a", "i", "e" ])

pf()
# Executed in 0.02 second(s)
