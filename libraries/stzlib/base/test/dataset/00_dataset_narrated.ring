load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzDataSet -- descriptive statistics.
# Integer-valued results are asserted exactly; inherently-fractional ones
# are rounded to 2 decimals (Rnd2) to avoid float-equality flakiness.

Scenario("Core descriptive statistics")
    Given("the dataset [10,15,20,25,30,35,40]")
    o = Ds([ 10, 15, 20, 25, 30, 35, 40 ])
    Then("Mean is 25", o.Mean(), 25)
    Then("Median is 25", o.Median(), 25)
    Then("Range is 30 (max-min)", o.Range(), 30)
    Then("Sum is 175", o.Sum(), 175)
    Then("Min is 10", o.Min(), 10)
    Then("Max is 40", o.Max(), 40)
    Then("Count is 7", o.Count(), 7)
    Then("StandardDeviation ~ 10.80", Rnd2(o.StandardDeviation()), 10.8)
    Then("Variance ~ 116.67", Rnd2(o.Variance()), 116.67)
    Then("CoVar ~ 43.20", Rnd2(o.CoVar()), 43.2)
EndScenario()

Scenario("Alternative means")
    Given("the dataset [2,8,32]")
    o = Ds([ 2, 8, 32 ])
    Then("GeometricMean is 8 (cube root of 512)", Rnd2(o.GeometricMean()), 8)
    Then("HarmonicMean ~ 4.57", Rnd2(o.HarmonicMean()), 4.57)
EndScenario()

# --- Regression guards added this session ---

Scenario("Data-type detection")
    Given("a numeric and a categorical dataset")
    Then("all-numbers -> numeric", Ds([ 1, 2, 3 ]).DataType(), "numeric")
    Then("all-strings -> categorical", Ds([ "a", "b", "a" ]).DataType(), "categorical")
EndScenario()

Scenario("Missing-value detection is list-safe (R21 guard)")
    Given("a dataset")
    o = Ds([ 2, 4, 6 ])
    Then("an empty string is missing", o._IsMissing(""), TRUE)
    Then("a number is not missing", o._IsMissing(5), FALSE)
    Then("a nested list is NOT a missing marker", o._IsMissing([ 1, 2 ]), FALSE)
EndScenario()

Scenario("Construction tolerates nested-list items (R21 guard)")
    Given("data containing a sublist: [1,[2,3],4]")
    Then("it constructs without crashing (count 3)", Ds([ 1, [ 2, 3 ], 4 ]).Count(), 3)
EndScenario()

Scenario("TrendAnalysis returns a list of segments (formatter R21 guard)")
    Given("a numeric sample")
    Then("the result is a list", isList(Ds([ 1, 3, 2, 5, 4 ]).TrendAnalysis()), TRUE)
EndScenario()

Scenario("Single-dataset plans skip pairwise steps gracefully (R19 guard)")
    Given("a dataset with no paired second dataset")
    o = Ds([ 1, 2, 3 ])
    Then("CorrelationWith needs a paired dataset", o._NeedsPairedDataset("CorrelationWith"), TRUE)
    Then("RankCorrelationWith needs a paired dataset", o._NeedsPairedDataset("RankCorrelationWith"), TRUE)
    Then("Mean does NOT need a paired dataset", o._NeedsPairedDataset("Mean"), FALSE)
EndScenario()

Summary()

func Ds aList
    return new stzDataSet(aList)

func Rnd2 n
    return floor(n * 100 + 0.5) / 100
