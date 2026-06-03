# Narrative
# --------
# Testing with larger dataset
#
# Extracted from stzdatawranglertest.ring, block #23.
#ERR TIMEOUT (>15s)

load "../../stzBase.ring"


pr()

# Generate larger dataset for performance testing
aLargeHeaders = ["ID", "Name", "Score", "Category", "Date"]
aLargeData = []

for i = 1 to 100_000
    aRow = []
    aRow + i  # ID
    aRow + "User" + i  # Name
    aRow + random(100) + 1  # Score (1-100)
    aRow + ["A", "B", "C", "D"][random(4) + 1]  # Category
    aRow + "2023-" + (random(12) + 1) + "-" + (random(28) + 1)  # Date
    
    # Introduce some quality issues
    if i % 50 = 0  # Every 50th record has issues
        aRow[2] = ""  # Missing name
    ok
    if i % 75 = 0  # Every 75th record has issues
        aRow[3] = -1  # Invalid score
    ok
    
    aLargeData + aRow
next

? "Generated dataset: " + len(aLargeData) + " rows × " + len(aLargeHeaders) + " columns"

o1 = new stzDataWrangler(aLargeData, aLargeHeaders)

? "Executing comprehensive analysis plan..."
nStartTime = clock()
aLargeResult = o1.ExecutePlan("analyze", FALSE)
nEndTime = clock()
nExecutionTime = (nEndTime - nStartTime) / clockspersecond()

? "Performance results:"
? "• Execution time: " + nExecutionTime + " seconds"
? "• Processing rate: " + (len(aLargeData) / nExecutionTime) + " rows/second"


//? "• Plan result: " + aLargeResult[:summary] #TODO See why aLargeResult = ""!

pf()
# Executed in 2.02 second(s) in Ring 1.22

#=========================================#
#  TEST SECTION 11: REAL-WORLD SCENARIOS  #
#=========================================#
