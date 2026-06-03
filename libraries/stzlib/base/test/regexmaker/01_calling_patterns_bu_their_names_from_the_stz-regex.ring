# Narrative
# --------
# #  CALLING PATTERNS BU THEIR NAMES FROM THE STZ-REGEX LIBRARY  #
#
# Extracted from stzregexmakertest.ring, block #1.

load "../../stzBase.ring"

#==============================================================#

pr()

# Match an Excel array formula
rx(pat(:xlsArrayFormula)) { ? Match("{=SUM(A1:A10)}") }
#--> TRUE

# Retrieve and inspect the pattern
rx(pat(:xlsArrayFormula)) { ? Pattern() + NL }
#--> Outputs the complex regex string

// Request a concise explanation
rx(pat(:xlsArrayFormula)) { ? Explain() + NL }
#--> "Matches an array formula in Excel"

// Request an extended breakdown of the regex
rx(pat(:xlsArrayFormula)) { ? ExplainXT() }
#--> Detailed line-by-line explanation of the regex components.

pf()
# Executed in almost 0 second(s) in Ring 1.22
