# Narrative
# --------
# Error handling
#
# Extracted from stzdatetimetest.ring, block #61.

load "../../../stzBase.ring"


pr()

oTest = StzDateTimeQ("2024-03-15 14:30:00")

? oTest.ToStringXT("INVALID_FORMAT")
#--> ERROR: The pattern name you provided does not exist in stzRegexData file.

? oTest.ToStringXT(:NonExistentFormat)
#--> ERROR: The pattern name you provided does not exist in stzRegexData file.

pf()

#===================================================================#
#  USAGE EXAMPLES OF CREATION A STZDATETIME OBJECT FROM EPOCH TIME  #
#==================================================================="
