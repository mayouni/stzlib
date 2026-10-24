load "../../stzBase.ring"
load "../_narrated.ring"
decimals(4)

# stzGraphQuery (base/graph/stzGraphQuery.ring) -- the two register rows, run on invented graphs whose answers
# were worked out by hand BEFORE the code was changed. Run from inside this folder:  ring stzGraphQuery_defects_narrated.ring
#
# The people graph, ten nodes n01..n10 in this match order (a node with no age has none at all):
#     id    name     age    city    score (a TEXT, stored as text)
#     n01   Ann      30     Paris   "10"
#     n02   bob      25     Rome    "9"
#     n03   Carl     30     paris   "100"
#     n04   dina     -5     Oslo    "2"
#     n05   Eve      --     Rome    "1"        (no age)
#     n06   Emile    41     Lyon    "20"       (E with an acute accent)
#     n07   ann      25     Rome    "9"
#     n08   aleph-bet-yod (Hebrew)  7.5   Haifa   "3"
#     n09   Zed      100    Oslo    "30"
#     n10   zoe      0      Paris   "4"        (the e carries an acute accent)
#
# The register said: OrderBy never sorts (asc keeps the match order, desc reverses it, because the sorted list
# was dropped and the sort ran on the projected rows, where a field that is not selected reads empty); only the
# first OrderBy was read; ValidateWith("DAG") stored [ [ [ ] ] ] and raised R21 when the query ran.
#
# THE EXPECTED ORDERS, written by hand from the table above (ties keep match order; a missing value goes last
# in both directions; texts compare in lower case by code point, so an accented letter and Hebrew come after z):
#     age asc        n04 n10 n08 n02 n07 n01 n03 n06 n09 n05
#     age desc       n09 n06 n01 n03 n02 n07 n08 n10 n04 n05
#     name asc       n01 n07 n02 n03 n04 n05 n09 n10 n06 n08
#     name desc      n08 n06 n10 n09 n05 n04 n03 n02 n01 n07
#     city asc       n08 n06 n04 n09 n01 n03 n10 n02 n05 n07
#     city, -age     n08 n06 n09 n04 n01 n03 n10 n02 n07 n05
#     score asc      n05 n01 n03 n04 n06 n08 n09 n10 n02 n07      (TEXT order: "10" comes before "9")
#     the old answer for every sort was the match order n01 .. n10, or its reverse for desc.
#
# Every positive carries a negative sibling: the order the old code gave, the order a wrong rule would give.
# ASCII only on the console.

$bGqPwned = 0

# --- 1. ValidateWith: a single text ----------------------------------------------------------------
Scenario("ValidateWith takes a single text: it is stored as a list of one name and the query runs")
	oQ = new stzGraphQuery(GqChain())
	oQ.MatchQ([ :node = "n" ])
	When("ValidateWith(DAG) is called with a single text on a chain a -> b -> c")
	oQ.ValidateWith("DAG")
	aT = oQ.Query()["rule_triggers"]
	Then("one trigger is queued", len(aT), 1)
	Then("it is a validation", GqExact(aT[1][:type], "validate"), 1)
	Then("its validators are a list", isList(aT[1][:validators]), 1)
	Then("of ONE name", len(aT[1][:validators]), 1)
	Then("NEGATIVE: that name is a text, not the [ [ [ ] ] ] the register recorded", isString(aT[1][:validators][1]), 1)
	Then("the name is kept as given", GqExact(aT[1][:validators][1], "DAG"), 1)
	cErr = ""
	nRows = -1
	try
		nRows = len(oQ.Select("n"))
	catch
		cErr = cCatchError
	done
	Then("the run raises nothing (it used to raise R21)", cErr, "")
	Then("and returns the three nodes: a chain is a DAG", nRows, 3)

	oQ = new stzGraphQuery(GqChain())
	oQ.MatchQ([ :node = "n" ])
	oQ.ValidateWith([ "DAG" ])
	cErr = ""
	nRows = -1
	try
		nRows = len(oQ.Select("n"))
	catch
		cErr = cCatchError
	done
	Then("a list of one name still works, and answers the same three nodes", nRows, 3)
	Then("and raises nothing", cErr, "")
	Then("the lower-case spelling dag works as well", GqValidates(GqChain(), "dag"), "")
	Then("and so does the symbol :DAG, which is the text DAG", GqValidates(GqChain(), :DAG), "")
EndScenario()

# --- 2. ValidateWith: a failing group ---------------------------------------------------------------
Scenario("A failing group raises Validation failed with its issues, for a single text and for a list")
	cErr = GqValidates(GqCycle(), "DAG")
	Then("DAG on the cycle a -> b -> c -> a raises", len(cErr) > 0, 1)
	Then("the message starts Validation failed", GqStarts(cErr, "Validation failed:"), 1)
	Then("and carries at least one issue line", StzFindFirst("  - ", cErr) > 0, 1)
	Then("NEGATIVE: the same text on the chain raises nothing", GqValidates(GqChain(), "DAG"), "")
	cErrL = GqValidates(GqCycle(), [ "DAG" ])
	Then("the list form raises the same message as the single text", GqExact(cErrL, cErr), 1)
	Then("the issue names a cycle", StzFindFirst("cycl", StzLower(cErr)) > 0, 1)
	Then("the raise comes from the run, not from the call: ValidateWith itself returned", GqRaisesAtCall(GqCycle(), "DAG"), 0)
EndScenario()

# --- 3. ValidateWith: two groups --------------------------------------------------------------------
Scenario("Two groups: each is checked, and one failing group is enough")
	Then("dag and reachability on the chain both pass", GqValidates(GqChain(), [ "dag", "reachability" ]), "")
	cC = GqValidates(GqCycle(), [ "dag", "reachability" ])
	Then("the cycle is connected, reachability passes, dag fails: it raises", GqStarts(cC, "Validation failed:"), 1)
	cS = GqValidates(GqSplit(), [ "dag", "reachability" ])
	Then("a -> b with c alone is acyclic and NOT connected: it raises through reachability", GqStarts(cS, "Validation failed:"), 1)
	Then("NEGATIVE: dag alone on that split graph passes", GqValidates(GqSplit(), "dag"), "")
	Then("NEGATIVE: reachability alone on the cycle passes", GqValidates(GqCycle(), "reachability"), "")
	cB = GqValidates(GqBoth(), [ "dag", "reachability" ])
	Then("x -> y -> x with z alone fails both groups", GqStarts(cB, "Validation failed:"), 1)
	Then("and the message holds the issues of BOTH groups: two issue lines at least", GqCountLines(cB, "  - ") >= 2, 1)
	Then("NEGATIVE: the cycle alone gives fewer issue lines than both together", GqCountLines(cC, "  - ") < GqCountLines(cB, "  - "), 1)
EndScenario()

# --- 4. ValidateWith: the matched subgraph only -------------------------------------------------------
Scenario("The check runs on the matched subgraph, not on the whole graph")
	g = new stzGraph("two")
	g.AddNodeXT("a", "Bad") g.AddNodeXT("b", "Bad") g.AddNodeXT("c", "Bad")
	g.AddEdgeXT("a", "b", "e") g.AddEdgeXT("b", "c", "e") g.AddEdgeXT("c", "a", "e")
	g.AddNodeXT("d", "Ok") g.AddNodeXT("e", "Ok") g.AddNodeXT("f", "Ok")
	g.AddEdgeXT("d", "e", "e") g.AddEdgeXT("e", "f", "e")
	oQ = new stzGraphQuery(g)
	oQ.MatchQ([ :node = "n", :labeled = "Ok" ])
	oQ.ValidateWith("dag")
	cErr = ""
	nRows = -1
	try
		nRows = len(oQ.Select("n"))
	catch
		cErr = cCatchError
	done
	Then("the three Ok nodes form a chain: DAG passes although the graph has a cycle", cErr, "")
	Then("and the three rows come back", nRows, 3)
	oQ = new stzGraphQuery(g)
	oQ.MatchQ([ :node = "n", :labeled = "Bad" ])
	oQ.ValidateWith("dag")
	cErr = ""
	try
		oQ.Select("n")
	catch
		cErr = cCatchError
	done
	Then("NEGATIVE: the three Bad nodes are the cycle: DAG raises", GqStarts(cErr, "Validation failed:"), 1)
EndScenario()

# --- 5. ValidateWith: bad input raises at registration ------------------------------------------------
Scenario("Bad input to ValidateWith raises when it is called, and queues nothing")
	Then("a list of lists", GqCallRaises("lol"), 1)
	Then("a list that holds a number", GqCallRaises("num_in_list"), 1)
	Then("an empty list", GqCallRaises("empty_list"), 1)
	Then("an empty text", GqCallRaises("empty_text"), 1)
	Then("a text of spaces only", GqCallRaises("blank_text"), 1)
	Then("a number", GqCallRaises("number"), 1)
	Then("a list with an empty name in it", GqCallRaises("empty_name"), 1)
	Then("a list holding an empty list", GqCallRaises("nested_empty"), 1)
	Then("a list of pairs (a hash list)", GqCallRaises("pairs"), 1)
	Then("NEGATIVE: a good text raises nothing", GqCallRaises("ok_text"), 0)
	Then("NEGATIVE: a good list raises nothing", GqCallRaises("ok_list"), 0)
	oQ = new stzGraphQuery(GqChain())
	oQ.MatchQ([ :node = "n" ])
	try
		oQ.ValidateWith([ [ "dag" ] ])
	catch
		cErr = cCatchError
	done
	Then("the message names the method", StzFindFirst("ValidateWith", cErr) > 0, 1)
	Then("and nothing was queued by the bad call", len(oQ.Query()["rule_triggers"]), 0)
	Then("so the run that follows is a plain query: three rows", len(oQ.Select("n")), 3)
EndScenario()

# --- 6. ValidateWith: unknown names, no evaluation, the Q form ------------------------------------------
Scenario("An unknown group name loads no rule and passes; a name is never evaluated; the Q form chains")
	Then("a name no rule group has passes on the chain", GqValidates(GqChain(), "nosuchgroup"), "")
	Then("it also passes on the cycle: no rule was loaded, so nothing fails", GqValidates(GqCycle(), "nosuchgroup"), "")
	Then("NEGATIVE: an unknown name next to a real one does not hide the real failure", GqStarts(GqValidates(GqCycle(), [ "nosuchgroup", "dag" ]), "Validation failed:"), 1)
	Then("a name that looks like code runs nothing", GqValidates(GqChain(), "$bGqPwned = 1"), "")
	Then("the global that code would have set is still 0", $bGqPwned, 0)
	oQ = new stzGraphQuery(GqChain())
	oQ2 = oQ.MatchQ([ :node = "n" ]).ValidateWithQ("dag")
	Then("ValidateWithQ returns the query, so the chain goes on to Select", len(oQ2.Select("n")), 3)
	oQ = new stzGraphQuery(GqChain())
	oQ2 = oQ.MatchQ([ :node = "n" ]).ValidateWithQ([ "dag", "reachability" ])
	Then("and takes a list as well", len(oQ2.Select("n")), 3)
EndScenario()

# --- 7. OrderBy: numbers ----------------------------------------------------------------------------------
Scenario("OrderBy sorts numerically: ascending and descending, ties keep the match order")
	Then("the match order is n01 .. n10 (the control: no OrderBy)", GqOrder(""), "n01,n02,n03,n04,n05,n06,n07,n08,n09,n10")
	Then("age asc, by the hand-written order (ties 25: n02 n07; 30: n01 n03)", GqOrder("n.age asc"), "n04,n10,n08,n02,n07,n01,n03,n06,n09,n05")
	Then("age desc, by the hand-written order (ties keep match order in descending too)", GqOrder("n.age desc"), "n09,n06,n01,n03,n02,n07,n08,n10,n04,n05")
	Then("NEGATIVE: asc is no longer the match order", GqOrder("n.age asc") != GqOrder(""), 1)
	Then("NEGATIVE: desc is no longer the match order reversed", GqOrder("n.age desc") != "n10,n09,n08,n07,n06,n05,n04,n03,n02,n01", 1)
	Then("the negative number -5 is first when ascending: n04", GqFirst("n.age asc"), "n04")
	Then("and the negative number is the last NUMBER when descending (n05 has no age)", GqNth("n.age desc", 9), "n04")
	Then("the decimal 7.5 sits between 0 and 25 when ascending", GqNth("n.age asc", 3), "n08")
	Then("the zero sits between -5 and 7.5", GqNth("n.age asc", 2), "n10")
	Then("100 beats 41 as a number (a text order would put 41 after 100)", GqNth("n.age asc", 9), "n09")
EndScenario()

# --- 8. OrderBy: missing last --------------------------------------------------------------------------------
Scenario("A row without the property sorts last, ascending AND descending")
	Then("n05 has no age: last when ascending", GqLast("n.age asc"), "n05")
	Then("and last when descending", GqLast("n.age desc"), "n05")
	Then("NEGATIVE: it is not first in either direction", GqFirst("n.age asc") != "n05" and GqFirst("n.age desc") != "n05", 1)
	g = new stzGraph("kinds")
	g.AddNodeXTT("k1", "K", [ :v = "x" ])
	g.AddNodeXTT("k2", "K", [ :v = "" ])
	g.AddNodeXTT("k3", "K", [ :v = 5 ])
	g.AddNodeXTT("k4", "K", [ :w = 1 ])
	g.AddNodeXTT("k5", "K", [ :v = [ 1, 2 ] ])
	g.AddNodeXTT("k6", "K", [ :v = 2 ])
	oQ = new stzGraphQuery(g)
	oQ.MatchQ([ :node = "n" ])
	oQ.OrderBy("n.v", "asc")
	Then("a number, a text, a list: numbers 2 5, then text x, then the list; an empty text and a missing property last",
		GqIds(oQ.Select("n")), "k6,k3,k1,k5,k2,k4")
	oQ = new stzGraphQuery(g)
	oQ.MatchQ([ :node = "n" ])
	oQ.OrderBy("n.v", "desc")
	Then("descending turns the three kinds round and still puts the empty and the missing last",
		GqIds(oQ.Select("n")), "k5,k1,k3,k6,k2,k4")
EndScenario()

# --- 9. OrderBy: text, case, accents, Hebrew -----------------------------------------------------------------
Scenario("Texts compare without regard to case, by code point: accents and Hebrew come after z")
	Then("name asc, by the hand-written order: ann and Ann tie (match order n01 n07), then bob .. zoe, then Emile, then Hebrew",
		GqOrder("n.name asc"), "n01,n07,n02,n03,n04,n05,n09,n10,n06,n08")
	Then("name desc: Hebrew first, ties ann/Ann keep match order at the end", GqOrder("n.name desc"), "n08,n06,n10,n09,n05,n04,n03,n02,n01,n07")
	Then("NEGATIVE: a case-SENSITIVE order would put every capital before every small letter: Ann, Carl, Eve, Zed first",
		GqOrder("n.name asc") != "n01,n03,n05,n09,n07,n02,n04,n10,n06,n08", 1)
	Then("city asc: Paris, paris, Paris tie as one city (n01 n03 n10), Rome three (n02 n05 n07)", GqOrder("n.city asc"), "n08,n06,n04,n09,n01,n03,n10,n02,n05,n07")
	Then("the accented Emile (n06) sorts after zoe (n10) and before the Hebrew name (n08)", (GqPos("n.name asc", "n06") > GqPos("n.name asc", "n10")) and (GqPos("n.name asc", "n06") < GqPos("n.name asc", "n08")), 1)
	Then("NEGATIVE: Emile is not placed with the Es (before Eve n05)", GqPos("n.name asc", "n06") > GqPos("n.name asc", "n05"), 1)
EndScenario()

# --- 10. OrderBy: a numeric text ------------------------------------------------------------------------------
Scenario("A property stored as a text is a text: the numeric text 10 comes before 9")
	Then("the score is stored as a text", isString(GqGraph().Node("n01")[:properties][:score]), 1)
	Then("the age is stored as a number", isNumber(GqGraph().Node("n01")[:properties][:age]), 1)
	Then("score asc is the TEXT order: 1 10 100 2 20 3 30 4 9 9", GqOrder("n.score asc"), "n05,n01,n03,n04,n06,n08,n09,n10,n02,n07")
	Then("NEGATIVE: it is not the numeric order 1 2 3 4 9 9 10 20 30 100", GqOrder("n.score asc") != "n05,n04,n08,n10,n02,n07,n01,n06,n09,n03", 1)
	Then("score desc is the text order turned round, ties keep match order", GqOrder("n.score desc"), "n02,n07,n10,n09,n08,n06,n04,n03,n01,n05")
EndScenario()

# --- 11. OrderBy: two keys ------------------------------------------------------------------------------------
Scenario("Several OrderBy calls are successive keys: the first call is the primary one")
	Then("city asc then age desc, by the hand-written order", GqOrder("n.city asc|n.age desc"), "n08,n06,n09,n04,n01,n03,n10,n02,n07,n05")
	Then("NEGATIVE: city asc alone leaves the Oslo pair n04 n09 in match order", GqOrder("n.city asc"), "n08,n06,n04,n09,n01,n03,n10,n02,n05,n07")
	Then("the second key only breaks ties: Oslo is n09 (100) before n04 (-5) with age desc", GqPos("n.city asc|n.age desc", "n09") < GqPos("n.city asc|n.age desc", "n04"), 1)
	Then("age asc then name asc: the ties are broken by name (ann n07 before bob n02; Ann n01 before Carl n03)", GqOrder("n.age asc|n.name asc"), "n04,n10,n08,n07,n02,n01,n03,n06,n09,n05")
	Then("NEGATIVE: that differs from the age-only order, which keeps n02 before n07", GqOrder("n.age asc|n.name asc") != GqOrder("n.age asc"), 1)
	Then("age asc then name desc: the ties 25 and 30 are broken by name, descending (bob before ann; Carl before Ann)",
		GqOrder("n.age asc|n.name desc"), "n04,n10,n08,n02,n07,n03,n01,n06,n09,n05")
	Then("three keys: city asc, age desc, name asc (Rome 25: ann n07 before bob n02)", GqOrder("n.city asc|n.age desc|n.name asc"), "n08,n06,n09,n04,n01,n03,n10,n07,n02,n05")
	Then("the missing age is last inside its city group (Rome: n02 n07 then n05)", GqPos("n.city asc|n.age desc", "n05") > GqPos("n.city asc|n.age desc", "n07"), 1)
EndScenario()

# --- 12. OrderBy: Skip and Limit after the sort ----------------------------------------------------------------
Scenario("Skip and Limit cut the SORTED rows")
	Then("age asc, skip 2, limit 3: the third to fifth of the sorted order", GqOrder("n.age asc||2|3"), "n08,n02,n07")
	Then("NEGATIVE: not the third to fifth of the match order, n03 n04 n05", GqOrder("n.age asc||2|3") != "n03,n04,n05", 1)
	Then("age desc, skip 1, limit 2", GqOrder("n.age desc||1|2"), "n06,n01")
	Then("limit alone: the three youngest", GqOrder("n.age asc||0|3"), "n04,n10,n08")
	Then("skip alone: all but the two youngest", GqOrder("n.age asc||2|0"), "n08,n02,n07,n01,n03,n06,n09,n05")
	Then("a skip beyond the rows leaves nothing", GqOrder("n.age asc||20|0"), "")
EndScenario()

# --- 13. OrderByAsc and OrderByDesc -------------------------------------------------------------------------------
Scenario("OrderByAsc and OrderByDesc take the field alone")
	oQ = new stzGraphQuery(GqGraph())
	oQ.MatchQ([ :node = "n" ])
	oQ.OrderByAsc("n.age")
	Then("OrderByAsc is the ascending sort", GqIds(oQ.Select("n")), "n04,n10,n08,n02,n07,n01,n03,n06,n09,n05")
	oQ = new stzGraphQuery(GqGraph())
	oQ.MatchQ([ :node = "n" ])
	oQ.OrderByDesc("n.age")
	Then("OrderByDesc is the descending sort", GqIds(oQ.Select("n")), "n09,n06,n01,n03,n02,n07,n08,n10,n04,n05")
	oQ = new stzGraphQuery(GqGraph())
	oQ2 = oQ.MatchQ([ :node = "n" ]).OrderByAscQ("n.city").OrderByDescQ("n.age")
	Then("the Q forms chain, and a second key is added in call order", GqIds(oQ2.Select("n")), "n08,n06,n09,n04,n01,n03,n10,n02,n07,n05")
	oQ = new stzGraphQuery(GqGraph())
	oQ.MatchQ([ :node = "n" ])
	oQ.OrderByAsc("n.age")
	oQ.OrderByDesc("n.name")
	Then("both mix with each other", GqIds(oQ.Select("n")), "n04,n10,n08,n02,n07,n03,n01,n06,n09,n05")
	Then("NEGATIVE: OrderByDesc is not the ascending one", GqIds(oQ.Select("n")) != "n04,n10,n08,n02,n07,n01,n03,n06,n09,n05", 1)
	oQ = new stzGraphQuery(GqGraph())
	oQ.MatchQ([ :node = "n" ])
	cErr = ""
	try
		oQ.OrderByAsc(5)
	catch
		cErr = cCatchError
	done
	Then("a field that is not text raises when called", len(cErr) > 0, 1)
	Then("and queues no key", len(oQ.Query()["order_by"]), 0)
EndScenario()

# --- 14. OrderBy: the direction word, the arguments ------------------------------------------------------------------
Scenario("The direction words, an unknown word, a non-text, one argument")
	Then("ascending", GqOrder("n.age ascending"), GqOrder("n.age asc"))
	Then("inascending", GqOrder("n.age inascending"), GqOrder("n.age asc"))
	Then("descending", GqOrder("n.age descending"), GqOrder("n.age desc"))
	Then("indescending", GqOrder("n.age indescending"), GqOrder("n.age desc"))
	Then("upper case DESC", GqOrder("n.age DESC"), GqOrder("n.age desc"))
	Then("mixed case Descending", GqOrder("n.age Descending"), GqOrder("n.age desc"))
	Then("an unknown word means asc (documented)", GqOrder("n.age sideways"), GqOrder("n.age asc"))
	Then("NEGATIVE: and so it is not desc", GqOrder("n.age sideways") != GqOrder("n.age desc"), 1)
	oQ = new stzGraphQuery(GqGraph())
	oQ.MatchQ([ :node = "n" ])
	oQ.OrderBy("n.age", 5)
	Then("a direction that is not text means asc", GqIds(oQ.Select("n")), GqOrder("n.age asc"))
	oQ = new stzGraphQuery(GqGraph())
	oQ.MatchQ([ :node = "n" ])
	cErr = ""
	try
		oQ.OrderBy("n.age")
	catch
		cErr = cCatchError
	done
	Then("one argument raises R19: Ring has no default parameter", StzFindFirst("R19", cErr) > 0, 1)
	Then("OrderBy with a field that is not text raises when called", GqCallRaises("ob_number"), 1)
	Then("OrderBy with an empty field raises when called", GqCallRaises("ob_empty"), 1)
	Then("NEGATIVE: a good call raises nothing", GqCallRaises("ob_ok"), 0)
	Then("a field without a dot is read from the alias of the last pattern, as Where does", GqOrder("age asc"), GqOrder("n.age asc"))
	Then("a field of an alias the query does not bind leaves the match order", GqOrder("zz.age asc"), "n01,n02,n03,n04,n05,n06,n07,n08,n09,n10")
EndScenario()

# --- 15. OrderBy: a field that is not selected, and Select forms ---------------------------------------------------------
Scenario("The sort does not need the field to be selected")
	oQ = new stzGraphQuery(GqGraph())
	oQ.MatchQ([ :node = "n" ])
	oQ.OrderBy("n.age", "asc")
	aRows = oQ.Select("n.city")
	Then("select city, sort by age: the cities in age order (a row of the projection holds no age)",
		GqValsEq(aRows, "n.city", [ "Oslo", "Paris", "Haifa", "Rome", "Rome", "Paris", "paris", "Lyon", "Oslo", "Rome" ]), 1)
	Then("NEGATIVE: not the cities in match order", GqValsEq(aRows, "n.city", [ "Paris", "Rome", "paris", "Oslo", "Rome", "Lyon", "Rome", "Haifa", "Oslo", "Paris" ]), 0)
	oQ = new stzGraphQuery(GqGraph())
	oQ.MatchQ([ :node = "n" ])
	oQ.OrderBy("n.age", "desc")
	oQ.Execute()
	Then("Execute and Result: the same rows, sorted, without any Select", GqIds(oQ.Result()), "n09,n06,n01,n03,n02,n07,n08,n10,n04,n05")
	oQ = new stzGraphQuery(GqGraph())
	oQ.MatchQ([ :node = "n" ])
	oQ.OrderBy("n.age", "asc")
	aRows = oQ.Select("*")
	Then("Select * is sorted too", GqIds(aRows), "n04,n10,n08,n02,n07,n01,n03,n06,n09,n05")
	oQ = new stzGraphQuery(GqGraph())
	oQ.MatchQ([ :node = "n" ])
	oQ.OrderBy("n.age", "asc")
	aRows = oQ.Select([ "n.age", :as = "years" ])
	Then("a renamed field projects and sorts", GqValsEq(aRows, "years", [ -5, 0, 7.5, 25, 25, 30, 30, 41, 100, "" ]), 1)
EndScenario()

# --- 16. Distinct with OrderBy ----------------------------------------------------------------------------------------------
# The Where keeps the nine nodes that have an age: Distinct compares a number with a text loosely, and 0 and the empty
# text are one value to it (a separate defect, listed in the commit message and not fixed here), so n05 stays out.
Scenario("Distinct comes after the sort and keeps the first of each group of equal rows")
	oQ = new stzGraphQuery(GqGraph())
	oQ.MatchQ([ :node = "n", :where = [ "age", ">", -1000 ] ])
	oQ.DistinctQ().OrderBy("n.name", "asc")
	aRows = oQ.Select("n.age")
	Then("ages by name order are 30 25 25 30 -5 100 0 41 7.5: the first of each value stays",
		GqValsEq(aRows, "n.age", [ 30, 25, -5, 100, 0, 41, 7.5 ]), 1)
	oQ = new stzGraphQuery(GqGraph())
	oQ.MatchQ([ :node = "n", :where = [ "age", ">", -1000 ] ])
	oQ.DistinctQ().OrderBy("n.age", "desc")
	aRows = oQ.Select("n.age")
	Then("distinct ages sorted descending", GqValsEq(aRows, "n.age", [ 100, 41, 30, 25, 7.5, 0, -5 ]), 1)
	oQ = new stzGraphQuery(GqGraph())
	oQ.MatchQ([ :node = "n", :where = [ "age", ">", -1000 ] ])
	oQ.Distinct()
	aRows = oQ.Select("n.age")
	Then("NEGATIVE: without OrderBy the same Distinct gives the match order 30 25 -5 41 7.5 100 0",
		GqValsEq(aRows, "n.age", [ 30, 25, -5, 41, 7.5, 100, 0 ]), 1)
	oQ = new stzGraphQuery(GqGraph())
	oQ.MatchQ([ :node = "n", :where = [ "age", ">", -1000 ] ])
	oQ.DistinctQ().OrderBy("n.age", "asc")
	oQ.Skip(1)
	oQ.Limit(3)
	aRows = oQ.Select("n.age")
	Then("Skip and Limit come after Distinct: the 2nd to 4th distinct ages", GqValsEq(aRows, "n.age", [ 0, 7.5, 25 ]), 1)
	oQ = new stzGraphQuery(GqGraph())
	oQ.MatchQ([ :node = "n" ])
	oQ.DistinctQ().OrderBy("n.city", "asc")
	aRows = oQ.Select("n.city")
	Then("Distinct on texts after a text sort: Paris and paris are two values to Distinct, both kept, in sorted order",
		GqValsEq(aRows, "n.city", [ "Haifa", "Lyon", "Oslo", "Paris", "paris", "Rome" ]), 1)
EndScenario()

# --- 17. Edges, an empty result, one row ---------------------------------------------------------------------------------------
Scenario("Edges sort by their own properties, an empty result and one row are fine")
	g = new stzGraph("edges")
	g.AddNodeXTT("a", "P", [ :age = 40 ])
	g.AddNodeXTT("b", "P", [ :age = 20 ])
	g.AddNodeXTT("c", "P", [ :age = 30 ])
	g.AddEdgeXTT("a", "b", "knows", [ :weight = 5 ])
	g.AddEdgeXTT("b", "c", "knows", [ :weight = 9 ])
	g.AddEdgeXTT("c", "a", "knows", [ :weight = 1 ])
	oQ = new stzGraphQuery(g)
	oQ.MatchEdge([ :from = "x", :to = "y" ])
	oQ.OrderBy("edge_data.weight", "desc")
	oQ.Execute()
	aR = oQ.Result()
	Then("three edges", len(aR), 3)
	Then("by weight descending: b->c (9), a->b (5), c->a (1)",
		aR[1]["x"][:id] + aR[1]["y"][:id] + "," + aR[2]["x"][:id] + aR[2]["y"][:id] + "," + aR[3]["x"][:id] + aR[3]["y"][:id], "bc,ab,ca")
	oQ = new stzGraphQuery(g)
	oQ.MatchEdge([ :from = "x", :to = "y" ])
	oQ.OrderBy("y.age", "asc")
	oQ.Execute()
	aR = oQ.Result()
	Then("by the age of the target node, ascending: b (20), c (30), a (40)", aR[1]["y"][:id] + aR[2]["y"][:id] + aR[3]["y"][:id], "bca")
	oQ = new stzGraphQuery(g)
	oQ.MatchQ([ :node = "n", :labeled = "Nobody" ])
	oQ.OrderBy("n.age", "asc")
	cErr = ""
	nRows = -1
	try
		nRows = len(oQ.Select("n"))
	catch
		cErr = cCatchError
	done
	Then("OrderBy on an empty result raises nothing", cErr, "")
	Then("and returns no row", nRows, 0)
	oQ = new stzGraphQuery(g)
	oQ.MatchQ([ :node = "n", :props = [ :age = 30 ] ])
	oQ.OrderBy("n.age", "desc")
	Then("one row is one row", GqIds(oQ.Select("n")), "c")
	oQ = new stzGraphQuery(g)
	oQ.MatchQ([ :node = "n" ])
	oQ.OrderBy("n.age", "asc")
	oQ.Select("n")
	Then("the sort does not touch the graph: still 3 nodes and 3 edges", g.NumberOfNodes() * 10 + g.NumberOfEdges(), 33)
	Then("the definition keeps the key: one order_by entry", len(oQ.Query()["order_by"]), 1)
EndScenario()

# --- 18. Explain, openCypher and a hand-made definition --------------------------------------------------------------------------
Scenario("Explain and ToOpenCypher name every key, and a definition loaded by hand is normalised")
	oQ = new stzGraphQuery(GqGraph())
	oQ.MatchQ([ :node = "n" ])
	oQ.OrderBy("n.city", "asc")
	oQ.OrderBy("n.age", "desc")
	aE = oQ.Explain()
	cSort = ""
	for i = 1 to len(aE)
		if GqExact(aE[i][:step], "orderby")
			cSort = aE[i][:description][1]
		ok
	next
	Then("Explain lists both keys, in call order", GqExact(cSort, "Sort by: n.city ASC, n.age DESC"), 1)
	Then("ToOpenCypher lists both keys", StzFindFirst("ORDER BY n.city ASC, n.age DESC", oQ.ToOpenCypher()) > 0, 1)
	oQ1 = new stzGraphQuery(GqGraph())
	oQ1.MatchQ([ :node = "n" ])
	oQ1.OrderBy("n.age", "desc")
	Then("NEGATIVE: with one key Explain keeps its old form", StzFindFirst("Sort by: n.age DESC", "" + @@(oQ1.Explain())) > 0, 1)
	aDef = oQ1.Query()
	aDef["order_by"][1]["direction"] = "DESC"
	oQ2 = new stzGraphQuery(GqGraph())
	oQ2.SetDefinition(aDef)
	oQ2.Execute()
	Then("a hand-made definition whose direction is written DESC sorts descending", GqIds(oQ2.Result()), "n09,n06,n01,n03,n02,n07,n08,n10,n04,n05")
EndScenario()

# --- 19. 5,000 rows, timed -----------------------------------------------------------------------------------------------------------
Scenario("5,000 rows sort in n log n: correct against an independent oracle, and the cost does not square")
	nBig = 5000
	nSmall = 1250
	gBig = GqRamp(nBig)
	gSmall = GqRamp(nSmall)

	nT = clock()
	oQ = new stzGraphQuery(gBig)
	oQ.MatchQ([ :node = "n" ])
	nBase5 = len(oQ.Select("n"))
	nTBase5 = (clock() - nT) / clockspersecond()

	nT = clock()
	oQ = new stzGraphQuery(gBig)
	oQ.MatchQ([ :node = "n" ])
	oQ.OrderBy("n.v", "asc")
	aRows = oQ.Select("n")
	nTSort5 = (clock() - nT) / clockspersecond()

	nT = clock()
	oQ = new stzGraphQuery(gSmall)
	oQ.MatchQ([ :node = "n" ])
	oQ.OrderBy("n.v", "asc")
	aSmall = oQ.Select("n")
	nTSort1 = (clock() - nT) / clockspersecond()

	? "  measured: 5000 rows no sort " + nTBase5 + " s, 5000 rows sorted " + nTSort5 + " s, 1250 rows sorted " + nTSort1 + " s"
	Then("all 5000 rows come back", len(aRows), 5000)
	Then("and 1250 for the small graph", len(aSmall), 1250)

	# the oracle: the value v of row i is (i * 7919) mod 1009; sorting the numbers v * 100000 + i is a TOTAL order,
	# so Ring's own sort of numbers gives the unique stable answer, with no call to the class
	aKeys = []
	for i = 1 to nBig
		aKeys + (((i * 7919) % 1009) * 100000 + i)
	next
	aKeys = sort(aKeys)
	nOk = 1
	for i = 1 to nBig
		nWantIdx = aKeys[i] % 100000
		if GqExact(aRows[i]["n"][:id], "r" + nWantIdx) = 0
			nOk = 0
			exit
		ok
	next
	Then("the 5000 rows are in the order of the oracle: ascending v, ties by match order", nOk, 1)

	oQ = new stzGraphQuery(gBig)
	oQ.MatchQ([ :node = "n" ])
	oQ.OrderBy("n.v", "desc")
	aRowsD = oQ.Select("n")
	aKeysD = []
	for i = 1 to nBig
		aKeysD + (((1008 - ((i * 7919) % 1009)) * 100000) + i)
	next
	aKeysD = sort(aKeysD)
	nOk = 1
	for i = 1 to nBig
		nWantIdx = aKeysD[i] % 100000
		if GqExact(aRowsD[i]["n"][:id], "r" + nWantIdx) = 0
			nOk = 0
			exit
		ok
	next
	Then("and descending: v descending, the ties still by match order", nOk, 1)
	Then("NEGATIVE: the first row of the ascending sort is not the first row of the graph", GqExact(aRows[1]["n"][:id], "r1"), 0)

	# THE BANDS come from the line printed above, measured 2026-10-24 on this machine: 0.53 s to match and project 5000 rows,
	# 2.44 s with the sort, 0.70 s for 1250 rows with the sort (5000 / 1250 = 3.5, where a quadratic sort gives about 16).
	Then("the sorted 5000 rows come back within the band (measured 2.4 s; under 12 s on a loaded machine)", nTSort5 < 12, 1)
	Then("a quadratic sort would cost 16 times the 1250-row time for 4 times the rows; this one stays under 9 times",
		nTSort5 < 9 * nTSort1, 1)
	Then("the sort is a few times the cost of matching and projecting alone, not orders more (measured 4.6; under 10 here)",
		nTSort5 < 10 * nTBase5 + 1, 1)
EndScenario()

Summary()

#------------------------------ helpers ------------------------------------------------------------------

func GqGraph()
	gqG = new stzGraph("people")
	gqG.AddNodeXTT("n01", "P", [ :name = "Ann",   :age = 30,  :city = "Paris", :score = "10" ])
	gqG.AddNodeXTT("n02", "P", [ :name = "bob",   :age = 25,  :city = "Rome",  :score = "9" ])
	gqG.AddNodeXTT("n03", "P", [ :name = "Carl",  :age = 30,  :city = "paris", :score = "100" ])
	gqG.AddNodeXTT("n04", "P", [ :name = "dina",  :age = -5,  :city = "Oslo",  :score = "2" ])
	gqG.AddNodeXTT("n05", "P", [ :name = "Eve",   :city = "Rome", :score = "1" ])
	gqG.AddNodeXTT("n06", "P", [ :name = "Émile", :age = 41,  :city = "Lyon",  :score = "20" ])
	gqG.AddNodeXTT("n07", "P", [ :name = "ann",   :age = 25,  :city = "Rome",  :score = "9" ])
	gqG.AddNodeXTT("n08", "P", [ :name = "אבי",   :age = 7.5, :city = "Haifa", :score = "3" ])
	gqG.AddNodeXTT("n09", "P", [ :name = "Zed",   :age = 100, :city = "Oslo",  :score = "30" ])
	gqG.AddNodeXTT("n10", "P", [ :name = "zoé",   :age = 0,   :city = "Paris", :score = "4" ])
	return gqG

func GqChain()
	gqG = new stzGraph("chain")
	gqG.AddNodeXT("a", "x") gqG.AddNodeXT("b", "x") gqG.AddNodeXT("c", "x")
	gqG.AddEdgeXT("a", "b", "e") gqG.AddEdgeXT("b", "c", "e")
	return gqG

func GqCycle()
	gqG = new stzGraph("cycle")
	gqG.AddNodeXT("a", "x") gqG.AddNodeXT("b", "x") gqG.AddNodeXT("c", "x")
	gqG.AddEdgeXT("a", "b", "e") gqG.AddEdgeXT("b", "c", "e") gqG.AddEdgeXT("c", "a", "e")
	return gqG

func GqSplit()
	gqG = new stzGraph("split")
	gqG.AddNodeXT("a", "x") gqG.AddNodeXT("b", "x") gqG.AddNodeXT("c", "x")
	gqG.AddEdgeXT("a", "b", "e")
	return gqG

func GqBoth()
	gqG = new stzGraph("both")
	gqG.AddNodeXT("x", "x") gqG.AddNodeXT("y", "x") gqG.AddNodeXT("z", "x")
	gqG.AddEdgeXT("x", "y", "e") gqG.AddEdgeXT("y", "x", "e")
	return gqG

func GqRamp(n)
	gqG = new stzGraph("ramp")
	for gqI = 1 to n
		gqG.AddNodeXTT("r" + gqI, "R", [ :v = ((gqI * 7919) % 1009) ])
	next
	return gqG

# the message of the raise when the query runs (ValidateWith + Select), or "" when nothing is raised
func GqValidates(oGraph, pValidators)
	gqQ = new stzGraphQuery(oGraph)
	gqQ.MatchQ([ :node = "n" ])
	gqQ.ValidateWith(pValidators)
	gqE = ""
	try
		gqQ.Select("n")
	catch
		gqE = cCatchError
	done
	return gqE

# 1 when ValidateWith itself raises at the call
func GqRaisesAtCall(oGraph, pValidators)
	gqQ = new stzGraphQuery(oGraph)
	gqQ.MatchQ([ :node = "n" ])
	gqR = 0
	try
		gqQ.ValidateWith(pValidators)
	catch
		gqR = 1
	done
	return gqR

# 1 when the named call raises at registration; the case names are the table of this guard
func GqCallRaises(cCase)
	gqQ = new stzGraphQuery(GqChain())
	gqQ.MatchQ([ :node = "n" ])
	gqR = 0
	try
		if cCase = "lol"
			gqQ.ValidateWith([ [ "dag" ] ])
		but cCase = "num_in_list"
			gqQ.ValidateWith([ "dag", 5 ])
		but cCase = "empty_list"
			gqQ.ValidateWith([])
		but cCase = "empty_text"
			gqQ.ValidateWith("")
		but cCase = "blank_text"
			gqQ.ValidateWith("   ")
		but cCase = "number"
			gqQ.ValidateWith(5)
		but cCase = "empty_name"
			gqQ.ValidateWith([ "dag", "" ])
		but cCase = "nested_empty"
			gqQ.ValidateWith([ [] ])
		but cCase = "pairs"
			gqQ.ValidateWith([ :a = 1 ])
		but cCase = "ok_text"
			gqQ.ValidateWith("dag")
		but cCase = "ok_list"
			gqQ.ValidateWith([ "dag", "reachability" ])
		but cCase = "ob_number"
			gqQ.OrderBy(5, "asc")
		but cCase = "ob_empty"
			gqQ.OrderBy("", "asc")
		but cCase = "ob_ok"
			gqQ.OrderBy("n.age", "asc")
		ok
	catch
		gqR = 1
	done
	return gqR

# the ids, in result order, of a query over the people graph described by a spec:
#   "n.age asc|n.city desc||skip|limit"   keys separated by |, then an empty part, then skip and limit
func GqOrder(cSpec)
	gqQ = new stzGraphQuery(GqGraph())
	gqQ.MatchQ([ :node = "n" ])
	if cSpec != ""
		gqParts = split(cSpec, "|")
		gqSkip = 0
		gqLimit = 0
		gqN = len(gqParts)
		# a spec with a cut has the form  <keys>||skip|limit ; read skip and limit from the end
		if gqN >= 3
			if GqIsDigits(gqParts[gqN]) and GqIsDigits(gqParts[gqN - 1])
				gqSkip = 0 + gqParts[gqN - 1]
				gqLimit = 0 + gqParts[gqN]
				gqN = gqN - 2
			ok
		ok
		for gqI = 1 to gqN
			if len(gqParts[gqI]) > 0
				gqKey = split(gqParts[gqI], " ")
				gqQ.OrderBy(gqKey[1], gqKey[2])
			ok
		next
		if gqSkip > 0
			gqQ.Skip(gqSkip)
		ok
		if gqLimit > 0
			gqQ.Limit(gqLimit)
		ok
	ok
	return GqIds(gqQ.Select("n"))

func GqIsDigits(gqC)
	if len(gqC) = 0
		return 0
	ok
	for gqI = 1 to len(gqC)
		gqA = ascii(gqC[gqI])
		if gqA < 48 or gqA > 57
			return 0
		ok
	next
	return 1

func GqNth(cSpec, n)
	gqIds = split(GqOrder(cSpec), ",")
	if n > len(gqIds)
		return ""
	ok
	return gqIds[n]

func GqFirst(cSpec)
	return GqNth(cSpec, 1)

func GqLast(cSpec)
	gqIds = split(GqOrder(cSpec), ",")
	return gqIds[len(gqIds)]

func GqPos(cSpec, cId)
	gqIds = split(GqOrder(cSpec), ",")
	for gqI = 1 to len(gqIds)
		if GqExact(gqIds[gqI], cId)
			return gqI
		ok
	next
	return 0

# the ids of rows of the form [ [ "n", node ] ]
func GqIds(aRows)
	gqC = ""
	gqRows = len(aRows)
	for gqI = 1 to gqRows
		if gqI > 1
			gqC += ","
		ok
		gqC += aRows[gqI]["n"][:id]
	next
	return gqC

# 1 when two texts are the same bytes: the length, then strcmp (exact, case-sensitive)
func GqExact(a, b)
	if NOT (isString(a) and isString(b))
		return 0
	ok
	if len(a) != len(b)
		return 0
	ok
	return strcmp(a, b) = 0

func GqStarts(c, cPrefix)
	if len(c) < len(cPrefix)
		return 0
	ok
	return strcmp(left(c, len(cPrefix)), cPrefix) = 0

func GqCountLines(c, cMark)
	gqCount = 0
	gqLines = split(c, char(10))
	for gqI = 1 to len(gqLines)
		if len(gqLines[gqI]) >= len(cMark)
			if strcmp(left(gqLines[gqI], len(cMark)), cMark) = 0
				gqCount++
			ok
		ok
	next
	return gqCount

# 1 when the value under cKey in every row equals the expected list, number against number, text exactly
func GqValsEq(aRows, cKey, aExp)
	if len(aRows) != len(aExp)
		return 0
	ok
	for gqI = 1 to len(aRows)
		gqV = aRows[gqI][cKey]
		gqE = aExp[gqI]
		if isNumber(gqE)
			if NOT isNumber(gqV)
				return 0
			ok
			if gqV != gqE
				return 0
			ok
		else
			if GqExact(gqV, gqE) = 0
				return 0
			ok
		ok
	next
	return 1
