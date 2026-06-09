# Narrative
# --------
# Testing with all missing values
#
# Extracted from stzdatawranglertest.ring, block #22.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

# TESTING WITH ALL MISSING VALUES

aAllMissingData = [
    [ '', "NULL", "" ],
    [ "NA", '', "n/a" ],
    [ '', "NULL", "" ]
]
aAllMissingHeaders = [ "Col1", "Col2", "Col3" ]

o1 = new stzDataWrangler(aAllMissingData, aAllMissingHeaders)

? "Profile before handling missing values:"
aBeforeMissing = o1.GetDataProfile()
? "• Missing values: " + aBeforeMissing[:missing_values]

# Try different missing value strategies
nProcessed = o1.HandleMissingValues("fill_zero")
? ""
? "After filling with zeros:"
? "• Values processed: " + nProcessed
aAfterMissing = o1.GetDataProfile()
? "• Remaining missing values: " + aAfterMissing[:missing_values]

#-->
'
Profile before handling missing values:
• Missing values: 9

After filling with zeros:
• Values processed: 9
• Remaining missing values: 0
'

pf()
# Executed in almost 0 second(s) in Ring 1.22

#===============================#
#  TEST SECTION 10: PERFORMANCE #
#===============================#
