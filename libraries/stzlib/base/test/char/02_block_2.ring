# Narrative
# --------
#
# Extracted from stzchartest.ring, block #2.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

# All the fellowing functions return TRUE

? isvowel("a") 		# Ring function

? @IsVowel("a") 	# Softanza alternative
? @IsVowel("aie")
? @IsVowel([ "a", "i", "e" ])

? AreVowels("aie")
? AreVowels([ "a", "i", "e" ])

pf()
# Executed in almost 0 second(s) in Ring 1.27 (Backed by StzEngine)
# Executed in 0.02 second(s) in older Ring version
