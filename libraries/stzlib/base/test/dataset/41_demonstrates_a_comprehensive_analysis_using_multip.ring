# Narrative
# --------
# Demonstrates a comprehensive analysis using multiple pillars.
#
# Extracted from stzdatasettest.ring, block #41.

load "../../stzBase.ring"


pr()

# Setting up sales data for 10 months and their corresponding month numbers

# Sales figures from month 1 to 10
oSales = new stzDataSet([ 100, 120, 140, 160, 180, 200, 220, 240, 260, 280 ])
# Months numbered 1 to 10
oMonth = new stzDataSet([ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ])

# Showing the average sales across all months
? oSales.Mean()
#--> 190  // Average sales is 190 units

# Showing the average after removing 20% of extreme values (highs and lows)
? oSales.TrimmedMean(20)
#--> 190  // Still 190, meaning no big outliers affect the average

# Showing how much sales vary from the average (higher number = more variation)
? oSales.StandardDeviation() + NL
#--> 60.5530  // Sales fluctuate by about 60.55 units


# Summarizing sales spread (like a snapshot of how sales are distributed)
? @@NL( oSales.BoxPlotStats() ) + NL
#--> [
#	[ "min", 100 ],          ~> Lowest sales: 100 units
#	[ "q1", 145 ],           ~> 25% of sales are below 145 units
#	[ "median", 190 ],       ~> Middle value: half the sales are below 190
#	[ "q3", 235 ],           ~> 75% of sales are below 235 units
#	[ "max", 280 ],          ~> Highest sales: 280 units
#	[ "whisker_low", 100 ],  ~> Lower typical range starts at 100
#	[ "whisker_high", 280 ], ~> Upper typical range ends at 280
#	[ "iqr", 90 ]            ~> Middle 50% of sales range from 145 to 235 (spread of 90 units)
# ]

# Showing the sales trend over months (how sales change with time)
? @@NL( oMonth.RegressionCoefficients(oSales) ) + NL
#--> [
#	[ "slope", 20 ],         ~> Sales grow by 20 units each month
#	[ "intercept", 80 ],     ~> Starting point: sales would be 80 at month 0
#	[ "r_squared", 1 ]       ~> Perfect fit: sales follow this trend exactly
# ]

# Checking if sales follow a normal (bell-shaped) pattern
? @@NL( oSales.NormalityTest() )
#--> [
#	[ "test", "heuristic" ],   ~> Method used to test the pattern
#	[ "skewness", 0 ],         ~> Symmetry: 0 means perfectly balanced
#	[ "kurtosis", -4.0616 ],   ~> Flatness: negative means flatter than a bell curve
#	[ "p_value", 0.0172 ],     ~> Statistical check: low value suggests not normal
#	[ "is_normal", 0 ]         ~> Result: 0 means sales don’t follow a normal pattern
# ]

pf()
# Executed in 0.0060 second(s) in Ring 1.24

#=====================================#
#  TESTING THE ANALYTICS Plan SYSTEM  #
#=====================================#
