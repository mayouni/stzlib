# Narrative
# --------
# Testing with empty dataset
#
# Extracted from stzdatawranglertest.ring, block #20.

load "../../../stzBase.ring"


pr()

# TESTING WITH EMPTY DATASET

aEmptyData = []
aHeaders = []

o1 = new stzDataWrangler(aEmptyData, aHeaders)

aEmptyProfile = o1.GetDataProfile()
? "• Empty data structure: " + aEmptyProfile[:structure]
? "• Row count: " + aEmptyProfile[:rows]
#-->
'
• Empty data structure: empty
• Row count: 0
'

# Try to execute plan on empty data
? ""
aEmptyResult = o1.ExecutePlan("clean", FALSE)
? "• Plan execution on empty data: " + aEmptyResult[:summary]

pf()
# • Plan execution on empty data: 2 successful, 2 errorss
