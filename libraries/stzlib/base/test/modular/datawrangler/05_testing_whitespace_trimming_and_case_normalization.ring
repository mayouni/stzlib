# Narrative
# --------
# Testing whitespace trimming and case normalization
#
# Extracted from stzdatawranglertest.ring, block #5.

load "../../../stzBase.ring"


pr()

# Data with whitespace and case issues
aMesyData = ["  John DOE  ", "mary smith", "  BOB WILSON  ", "alice BROWN"]
o1 = new stzDataWrangler(aMesyData, [])


# Trim whitespace
nTrimmed = o1.TrimWhitespace()

	# Values trimmed
	? nTrimmed
	#--> 2

	? @@(o1.GetData()) + NL
	#--> [ "John DOE", "mary smith", "BOB WILSON", "alice BROWN" ]

# Normalize case to title case
nNormalized = o1.NormalizeCase("title")

	# Values normalized
	? nNormalized
	#--> 2

	# Normalised content
	? @@(o1.GetData())
	#--> [ "John Doe", "Mary Smith", "Bob Wilson", "Alice Brown" ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

#===================================#
#  TEST SECTION 3: DATA VALIDATION  #
#===================================#
