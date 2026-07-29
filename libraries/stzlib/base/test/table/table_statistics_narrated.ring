# stzTable COLUMN STATISTICS -- the table as a customer of the stats engine.
#
# The table engine gives Sum/Avg/Min/Max/Product. Everything richer -- median,
# spread, quartiles, correlation, regression -- is NOT reimplemented in the table
# engine: the table extracts a column once and hands it to stzDataSet, which owns
# the statistics authority (and is itself engine-backed). This is the first step
# of the numeric-foundation retro: turning a deep, unused core into a capability
# the upper modules actually stand on.
#
# Everything below is run for real against the built library.

load "../../stzBase.ring"
load "../_narrated.ring"

decimals(6)

oT = new stzTable([
	[:age,    [20, 25, 30, 35, 40]],
	[:income, [30, 42, 51, 66, 80]],
	[:city,   ["a", "b", "c", "d", "e"]]
])

Scenario("A table now answers the column statistics it could not before")
	# Sum/Avg/Min/Max were already engine-backed on the table. Median, standard
	# deviation, variance and the quartiles arrive through stzDataSet, so the
	# table stops at nothing a one-variable summary would want.
	Then("MedianCol(age) is 30", oT.MedianCol(:age), 30)
	Then("StdDevCol(age) is the sample sigma", NearEq(oT.StdDevCol(:age), 7.905694), TRUE)
	Then("VarianceCol(age) is 62.5", NearEq(oT.VarianceCol(:age), 62.5), TRUE)
	Then("Q1Col(age) is 25", oT.Q1Col(:age), 25)
	Then("Q3Col(age) is 35", oT.Q3Col(:age), 35)
	Then("PercentileCol(age, 50) is the median", oT.PercentileCol(:age, 50), 30)
EndScenario()

Scenario("Describe() summarises every NUMERIC column and skips the rest")
	# IsNumericCol is the gate: a column counts as numeric when every non-null
	# value is a number. The text column is left out of a describe, exactly as it
	# should be.
	Then("age is a numeric column", oT.IsNumericCol(:age), TRUE)
	Then("city is NOT a numeric column", oT.IsNumericCol(:city), FALSE)

	aDesc = oT.Describe()
	Then("two columns are described, not three", len(aDesc), 2)
	Then("...and the text column is not among them",
	     aDesc[1][1] = "age" and aDesc[2][1] = "income", TRUE)

	# a per-column summary is DATA -- a hashlist of the eight numbers
	aInc = oT.DescribeCol(:income)
	Then("DescribeCol(income) counts all five rows", aInc[:count], 5)
	Then("...its mean is 53.8", NearEq(aInc[:mean], 53.8), TRUE)
	Then("...its median is 51", aInc[:median], 51)
	Then("...its min and max frame the column", aInc[:min] = 30 and aInc[:max] = 80, TRUE)
EndScenario()

Scenario("Correlation and regression come through without leaving the table")
	# The table hands two columns to stzDataSet and reads the answer back. No
	# statistics are recomputed here -- the authority is the engine's.
	Then("age and income are strongly correlated",
	     NearEq(oT.CorrelationBetween(:age, :income), 0.996378), TRUE)

	# read at the call site: RegressionOf(y, :On, x)
	aReg = oT.RegressionOf(:income, :On, :age)
	Then("income-on-age slope is 2.48", NearEq(aReg[:slope], 2.48), TRUE)
	Then("...intercept is -20.6", NearEq(aReg[:intercept], -20.6), TRUE)
	Then("...and r-squared is 0.9928", NearEq(aReg[:r_squared], 0.992769), TRUE)

	# the correlation matrix runs over the numeric columns only
	aM = oT.CorrelationMatrix()
	aCols = aM[:columns]
	aMat = aM[:matrix]
	Then("the matrix covers the two numeric columns", len(aCols), 2)
	Then("...its diagonal is 1", aMat[1][1] = 1 and aMat[2][2] = 1, TRUE)
	Then("...and it is symmetric", NearEq(aMat[1][2], aMat[2][1]), TRUE)
EndScenario()

Scenario("It coerces numeric strings and steps over the non-numeric")
	# Real columns are not always clean. A column with numeric strings, a stray
	# label and a null still yields its statistics over the numbers that ARE
	# there -- the coercion is best-effort per column.
	oMixed = new stzTable([ [:vals, ["10", "20", 30, "x", NULL]] ])
	Then("median of the numeric part [10,20,30] is 20", oMixed.MedianCol(:vals), 20)
	Then("the mean ignores the label and the null",
	     NearEq(oMixed.DescribeCol(:vals)[:mean], 20), TRUE)

	# but the column as a whole is NOT numeric (a label lives in it), so a
	# describe would conservatively skip it
	Then("...yet the column as a whole is not numeric", oMixed.IsNumericCol(:vals), FALSE)
EndScenario()

Scenario("DescribeQ() hands back a TABLE object, per the naming law")
	# The plain Describe() returns data; the Q form returns an object -- here a
	# statistic-per-row table, ready to display or chain.
	oQ = oT.DescribeQ()
	Then("DescribeQ is an object", isObject(oQ), TRUE)
	Then("...it is a table", classname(oQ) = "stztable", TRUE)
	Then("...with the eight statistics as rows", len(oQ.Col(:statistic)), 8)
	Then("...and a column per numeric variable", oQ.NumberOfCols(), 3)  # statistic + age + income
EndScenario()

Summary()

#-- local helpers (file scope) ------------------------------------------------

func NearEq(nX, nY)
	return fabs(nX - nY) < 0.0001
