# Narrative
# --------
# Testing outlier detection
#
# Extracted from stzdatawranglertest.ring, block #8.

load "../../stzBase.ring"


pr()

# Create data with clear outliers

aOutlierData = [
    ["Product A", 100, 25.50],
    ["Product B", 150, 30.75],
    ["Product C", 120, 28.00],

    ["Product D", 9999, 500.00],  # Clear outlier

    ["Product E", 110, 26.25],
    ["Product F", 130, 29.50],

    ["Product G", -50, -10.00]    # Another outlier
]

aOutlierHeaders = [ "Product", "Quantity", "Price" ]

o1 = new stzDataWrangler(aOutlierData, aOutlierHeaders)

? BoxRound("OUTLIER DETECTION")
aOutliers = o1.DetectOutliers(2.0)  # Using Z-score threshold of 2.0
? "Outliers detected: " + len(aOutliers)

for outlier in aOutliers
    ? "  • Row " + outlier[1] + ", " + aOutlierHeaders[outlier[2]] + ": " + outlier[3] + " (Z-score: " + outlier[4] + ")"
next

#-->
'
Outliers detected: 2
  • Row 4, Quantity: 9999 (Z-score: 2.27)
  • Row 4, Price: 500 (Z-score: 2.26)
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

#=======================================#
#  TEST SECTION 4: DATA TRANSFORMATION  #
#=======================================#
