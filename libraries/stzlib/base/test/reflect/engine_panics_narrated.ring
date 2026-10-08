load "../../stzBase.ring"
load "../_narrated.ring"

# Calls that used to END THE RING PROCESS (an engine panic, a silent VM exit) or run away
# (a method calling itself until R4). Each would-crash call runs inside try/catch: the
# guard reaching Summary() is itself the proof the process survived.

Scenario("stzDataSet.Percentile refuses a percent outside 0..100 instead of panicking the engine")
	oDS = new stzDataSet([ 1, 2, 3 ])
	Then("a percent inside the range still answers", oDS.Percentile(50), 2)
	Then("0 and 100 are the ends", "" + oDS.Percentile(0) + "/" + oDS.Percentile(100), "1/3")
	cErr = "" try oDS.Percentile(-1) catch cErr = cCatchError done
	Then("-1 raises a normal error (it used to panic stz_stats.dll)", StzFindFirst("0 to 100", cErr) > 0, TRUE)
	cErr = "" try oDS.Percentile(150) catch cErr = cCatchError done
	Then("150 raises a normal error (index out of bounds before)", StzFindFirst("0 to 100", cErr) > 0, TRUE)
	cErr = "" try oDS.Percentile("50") catch cErr = cCatchError done
	Then("a text percent raises a normal error", StzFindFirst("number", cErr) > 0, TRUE)
	When("the engine function is called directly, past the Ring check")
	if isPointer(oDS.@pEngineStats) or isNumber(oDS.@pEngineStats)
		cErr = "" try StzEngineStatsPercentile(oDS.@pEngineStats, -1) catch cErr = cCatchError done
		Then("the engine bridge raises for -1 too", StzFindFirst("percentile", cErr) > 0, TRUE)
		cErr = "" try StzEngineStatsPercentile(oDS.@pEngineStats, 150) catch cErr = cCatchError done
		Then("and for 150", StzFindFirst("percentile", cErr) > 0, TRUE)
		Then("and still answers 50", StzEngineStatsPercentile(oDS.@pEngineStats, 50), 2)
	ok
EndScenario()

Scenario("stzDataSet.WMean is the weighted mean, not a self-call")
	oDS = new stzDataSet([ 1, 2, 3 ])
	cErr = "" n = 0 try n = oDS.WMean([ 1, 1, 1 ]) catch cErr = cCatchError done
	Then("no error is raised (R4 before)", cErr, "")
	Then("equal weights give the plain mean", n, 2)
	Then("weights 1,0,0 give the first value", oDS.WMean([ 1, 0, 0 ]), 1)
	Then("it agrees with WeightedMean", oDS.WMean([ 3, 1, 1 ]), oDS.WeightedMean([ 3, 1, 1 ]))
EndScenario()

Scenario("stzTimeLine.HasMoment and its siblings answer instead of recursing")
	oTL = new stzTimeLine("2024-01-01 00:00:00", "2024-12-31 00:00:00")
	oTL.AddPoint("launch", "2024-03-01 00:00:00")
	cErr = "" b = -1 try b = oTL.HasMoment("launch") catch cErr = cCatchError done
	Then("no error is raised (R4 before)", cErr, "")
	Then("a carried label answers TRUE", b, 1)
	Then("a missing label answers FALSE", oTL.HasMoment("nothing"), 0)
	Then("the label is matched in any case", oTL.HasMoment("LAUNCH"), 1)
	Then("HasInstant agrees", oTL.HasInstant("launch"), 1)
	Then("ContainsMoment agrees", oTL.ContainsMoment("launch"), 1)
	Then("ContainsInstant agrees on a missing label", oTL.ContainsInstant("nothing"), 0)
EndScenario()

Scenario("stzDateTime builds a date before 1970 from a negative month count")
	oDT = new stzDateTime("2024-01-01 00:00:00")
	cErr = "" try oDT.FromMonthsSinceEpoch(-1) catch cErr = cCatchError done
	Then("-1 month raises nothing (it panicked the DLL once)", cErr, "")
	Then("and is December 1969", oDT.ToString(), "1969-12-01 00:00:00")
	oDT.FromMonthsSinceEpoch(-3)
	Then("-3 months is October 1969", oDT.ToString(), "1969-10-01 00:00:00")
	oDT.SetFromEpochMonths(-14)
	Then("SetFromEpochMonths(-14) is November 1968", oDT.ToString(), "1968-11-01 00:00:00")
EndScenario()

Scenario("stzTable.FillCQ returns a filled copy instead of ending the process")
	oT = new stzTable([ [ :a, :b ], [ 1, 2 ], [ 3, 4 ] ])
	cErr = "" oC = "" try oC = oT.FillCQ(0) catch cErr = cCatchError done
	Then("no error is raised", cErr, "")
	Then("the copy is a stzTable", isObject(oC) and classname(oC) = "stztable", TRUE)
	Then("every cell of the copy is 0", @@(oC.Content()), @@([ [ "a", [ 0, 0 ] ], [ "b", [ 0, 0 ] ] ]))
	Then("the table itself is unchanged", @@(oT.Content()), @@([ [ "a", [ 1, 3 ] ], [ "b", [ 2, 4 ] ] ]))
EndScenario()

Scenario("The engine's locale case functions refuse a non-text instead of ending the process")
	Then("a text is still uppercased", StzEngineLocaleToUpper("abc"), "ABC")
	Then("and lowercased", StzEngineLocaleToLower("ABC"), "abc")
	cErr = "" try StzEngineLocaleToUpper(5) catch cErr = cCatchError done
	Then("ToUpper(5) raises a normal error (exit 1 before)", StzFindFirst("must be a text", cErr) > 0, TRUE)
	cErr = "" try StzEngineLocaleToLower(5) catch cErr = cCatchError done
	Then("ToLower(5) raises a normal error", StzFindFirst("must be a text", cErr) > 0, TRUE)
	cErr = "" try StzEngineLocaleToTitlecase([ 1 ]) catch cErr = cCatchError done
	Then("ToTitlecase of a list raises a normal error", StzFindFirst("must be a text", cErr) > 0, TRUE)
EndScenario()

Summary()
