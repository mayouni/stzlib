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

Summary()

func Ds aList
    return new stzDataSet(aList)

func Rnd2 n
    return floor(n * 100 + 0.5) / 100
