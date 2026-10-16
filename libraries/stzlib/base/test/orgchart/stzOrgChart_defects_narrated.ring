load "../../stzBase.ring"
load "../_narrated.ring"

# stzOrgChart -- the ten register rows, reproduced and then held.
#
# Run it from inside test/orgchart. Every row was built with a real chart (a CEO, two VPs, an analyst,
# departments, two people assigned and two positions left vacant) and judged by reading the chart state:
# the node colours, the subtitle, the node count and the ids the succession check returns. The View calls
# are caught by a subclass that counts the display request and writes no file, and STZ_NO_VIEW is set as
# well, so no window or file is opened whatever happens.
#
# Rows 1-4 read a key that AddPositionXTT never writes (the level and the attributes are flattened into the
# record). Rows 5-8 raised or corrupted the chart. Rows 9 and 10 are placeholders: no header, block or test
# says what they do, so the guard holds that they are harmless and that their siblings work.

if sysget("STZ_NO_VIEW") = ""
	sysset("STZ_NO_VIEW", "1")
ok

# the chart every scenario starts from:
#   ceo (executive, p1)  -> vp1 (management, p2, department sales) -> s1 (staff, vacant, sales)
#                        -> vp2 (management, vacant, department risk)

Scenario("Row 1 and 2 -- the succession check sees a successor set on the node")
	o = Chart("TechCo")
	Then("every filled position is at risk before any successor", @@(o.SuccessionRisk()), @@(["ceo", "vp1"]))
	Then("a vacant position is never at risk", StzFindFirst("vp2", o.SuccessionRisk()), 0)
	Then("a second vacant position is not at risk either", StzFindFirst("s1", o.SuccessionRisk()), 0)
	v = o.ValidateSuccession()
	Then("the check fails", v[:status], "fail")
	Then("one issue per filled position without a successor", v[:issueCount], 2)
	Then("the issue names the position", @@(v[:issues]), @@(["No successor: ceo", "No successor: vp1"]))
	Then("the affected nodes are those positions", @@(v[:affectedNodes]), @@(["ceo", "vp1"]))
	Then("the domain is succession", v[:domain], "succession")

	o.SetNodeProperty("vp1", "successor", "s1")
	Then("a successor set with SetNodeProperty is seen", @@(o.SuccessionRisk()), @@(["ceo"]))
	Then("the position with a successor is no longer at risk", StzFindFirst("vp1", o.SuccessionRisk()), 0)
	Then("the position without one still is", StzFindFirst("ceo", o.SuccessionRisk()), 1)
	v = o.ValidateSuccession()
	Then("the check still fails for the other one", v[:status], "fail")
	Then("with one issue", v[:issueCount], 1)
	Then("naming ceo", @@(v[:issues]), @@(["No successor: ceo"]))
	Then("and one affected node", @@(v[:affectedNodes]), @@(["ceo"]))

	o.SetNodeProperty("ceo", "successor", "vp1")
	Then("when both have a successor nobody is at risk", len(o.SuccessionRisk()), 0)
	v = o.ValidateSuccession()
	Then("the check passes", v[:status], "pass")
	Then("with no issue", v[:issueCount], 0)
	Then("and no affected node", len(v[:affectedNodes]), 0)
EndScenario()

Scenario("Row 1 and 2 -- the succession report follows the same successors")
	o = Chart("TechCo")
	r = o.GenerateSuccessionReport()
	Then("both filled positions are listed before any successor", r[:highRiskCount], 2)
	Then("with the incumbent's name", r[:details][1][:incumbent], "Alice")
	Then("and a high risk level", r[:details][2][:riskLevel], "high")
	o.SetNodeProperty("vp1", "successor", "s1")
	r = o.GenerateSuccessionReport()
	Then("a position with a successor leaves the report", r[:highRiskCount], 1)
	Then("the one left is ceo", r[:details][1][:position], "ceo")
	Then("and the reporter says the same through GenerateReport", o.GenerateReport()[3][:highRiskCount], 1)
EndScenario()

Scenario("Row 1 and 2 -- what is NOT a successor")
	o = Chart("TechCo")
	o.SetNodeProperty("vp1", "successor", "")
	Then("an empty successor does not count", @@(o.SuccessionRisk()), @@(["ceo", "vp1"]))
	o.SetNodeProperty("vp2", "successor", "s1")
	Then("a successor on a vacant position changes nothing for the filled ones", @@(o.SuccessionRisk()), @@(["ceo", "vp1"]))
	o.SetNodeProperty("ceo", "boss", "nobody")
	Then("another property is not a successor", @@(o.SuccessionRisk()), @@(["ceo", "vp1"]))
	o.SetNodeProperty("ceo", "successor", "   ")
	Then("a blank successor does not count", StzFindFirst("ceo", o.SuccessionRisk()), 1)
	o.SetNodeProperty("ceo", "successor", ["vp1", "vp2"])
	Then("a list of successors counts", StzFindFirst("ceo", o.SuccessionRisk()), 0)
EndScenario()

Scenario("Row 1 and 2 -- a successor given when the position is added")
	o = new stzOrgChart("TechCo")
	o.AddPositionXTT("ceo", "CEO", [ :level = "executive", :successor = "vp1" ])
	o.AddPositionXTT("vp1", "VP", [ :level = "management" ])
	o.AddPersonXT("p1", "Alice")
	o.AddPersonXT("p2", "Bob")
	o.AssignPerson("p1", "ceo")
	o.AssignPerson("p2", "vp1")
	Then("the record key successor counts", @@(o.SuccessionRisk()), @@(["vp1"]))
	Then("and the check names the other one", @@(o.ValidateSuccession()[:issues]), @@(["No successor: vp1"]))

	e = new stzOrgChart("Empty")
	e.AddExecutiveXT("ceo", "CEO")
	Then("a chart with no filled position has no risk", len(e.SuccessionRisk()), 0)
	Then("and passes the succession check", e.ValidateSuccession()[:status], "pass")
EndScenario()

Scenario("Row 3 -- the vacancy report gives the real level of each vacant position")
	o = Chart("TechCo")
	r = o.GenerateVacancyReport()
	Then("two positions are vacant", r[:vacancyCount], 2)
	Then("the rate is a half", r[:vacancyRate], 50)
	Then("one detail per vacant position", len(r[:details]), 2)
	Then("the first is vp2", r[:details][1][:position], "vp2")
	Then("a management position reports the level management", r[:details][1][:level], "management")
	Then("the second is s1", r[:details][2][:position], "s1")
	Then("a staff position reports the level staff", r[:details][2][:level], "staff")
	Then("the title is read", r[:details][1][:title], "VP Ops")
	Then("the department is read", r[:details][1][:department], "risk")

	o.AddExecutiveXT("cfo", "CFO")
	o.AddPosition("misc")
	r = o.GenerateVacancyReport()
	Then("four positions are vacant now", r[:vacancyCount], 4)
	Then("an executive position reports the level executive", r[:details][3][:level], "executive")
	Then("a position added with no level reports staff", r[:details][4][:level], "staff")
	Then("(known) a chart with no position raises error R1, since the rate divides by zero",
		StzFindFirst("R1", Runs(new stzOrgChart("Empty"), "GenerateVacancyReport()")) > 0, 1)
	Then("the alias VacancyReport gives the same details", @@(o.VacancyReport()[:details]), @@(r[:details]))
	Then("the report built by GenerateReport carries them too", o.GenerateReport()[2][:details][3][:level], "executive")
EndScenario()

Scenario("Row 4 -- ResetAllNodeColors restores the level colours")
	o = Chart("TechCo")
	Then("the executive colour in the table is gold", $aOrgColors[:executive], "gold")
	Then("the management colour in the table is blue+", $aOrgColors[:management], "blue+")
	Then("the staff colour in the table is green-", $aOrgColors[:staff], "green-")
	Then("a filled executive position is gold after being assigned", o.NodeProperty("ceo", "color"), "gold")
	Then("a filled management position is blue+", o.NodeProperty("vp1", "color"), "blue+")
	Then("a vacant management position is white", o.NodeProperty("vp2", "color"), "white")
	Then("a vacant staff position is white", o.NodeProperty("s1", "color"), "white")

	o.AddPersonXT("p3", "Carol")
	o.AssignPerson("p3", "s1")
	Then("a staff position is green- once filled", o.NodeProperty("s1", "color"), "green-")

	o.ApplyFocusTo(["vp1", "vp2"])
	Then("the focus colours what was asked", o.NodeProperty("vp1", "color"), o.FocusColor())
	Then("including a vacant position", o.NodeProperty("vp2", "color"), o.FocusColor())
	Then("the others are back to their level colour", o.NodeProperty("ceo", "color"), "gold")
	Then("a filled staff position is back to green-", o.NodeProperty("s1", "color"), "green-")

	o.ResetAllNodeColors()
	Then("after the reset the focused management position is blue+", o.NodeProperty("vp1", "color"), "blue+")
	Then("the executive is gold", o.NodeProperty("ceo", "color"), "gold")
	Then("the staff position is green-", o.NodeProperty("s1", "color"), "green-")
	Then("the vacant position is white again, not the focus colour", o.NodeProperty("vp2", "color"), "white")

	o.AddPosition("misc")
	o.AddPersonXT("p4", "Dan")
	o.AssignPerson("p4", "misc")
	o.ResetAllNodeColors()
	Then("a filled position with no level stays white", o.NodeProperty("misc", "color"), "white")

	o.ColorByDepartment()
	Then("a department colour is painted over the level colour", o.NodeProperty("vp1", "color"), "blue")
	o.ResetAllNodeColors()
	Then("and the reset overwrites it", o.NodeProperty("vp1", "color"), "blue+")
	Then("no node is left in the focus colour", len(Lit(o)), 0)
EndScenario()

Scenario("Row 5 -- ViewNonCompliant validates by the norm and highlights the positions its issues name")
	o = Chart("TechCo")
	n = o.NumberOfNodes()
	cErr = Runs(o, 'ViewNonCompliant("succession")')
	Then("it no longer raises", cErr, "")
	Then("the chart is displayed once", o.ViewsAsked(), 1)
	Then("the filled positions without a successor are highlighted", @@(Lit(o)), @@(["ceo", "vp1"]))
	Then("a position with a successor would not be", StzFindFirst("vp2", Lit(o)), 0)
	Then("no node was added", o.NumberOfNodes(), n)

	o.SetNodeProperty("vp1", "successor", "s1")
	Runs(o, 'ViewNonCompliant("succession")')
	Then("with one successor set only the other one is highlighted", @@(Lit(o)), @@(["ceo"]))

	o.SetNodeProperty("ceo", "successor", "vp1")
	Runs(o, 'ViewNonCompliant("succession")')
	Then("when the norm passes nothing is highlighted", len(Lit(o)), 0)

	Runs(o, 'ViewNonCompliantXT("succession")')
	Then("the XT spelling displays too", o.ViewsAsked(), 4)

	o = Chart("TechCo")
	Then("a norm whose issues name no position highlights none", Runs(o, 'ViewNonCompliant("vacancy")'), "")
	Then("(vacancy counts the vacant positions in its issue)", len(Lit(o)), 0)
	Then("and still displays", o.ViewsAsked(), 1)

	o = Chart("TechCo")
	o.SetTitle("Titled")
	Then("with a title it does not raise", Runs(o, 'ViewNonCompliant("succession")'), "")
	Then("the subtitle names the view", StzFindFirst("Non Compliant", o.Subtitle()) > 0, 1)
	Then("and the highlight is the same", @@(Lit(o)), @@(["ceo", "vp1"]))
EndScenario()

Scenario("Row 5 -- ViewCompliant is the mirror it was written against")
	o = Chart("TechCo")
	Then("ViewCompliant does not raise", Runs(o, 'ViewCompliant("succession")'), "")
	Then("it highlights the positions the issues do not name", @@(Lit(o)), @@(["vp2", "s1"]))
EndScenario()

Scenario("Row 6 -- ViewNotAtRisk highlights every node that is not at risk")
	o = Chart("TechCo")
	n = o.NumberOfNodes()
	Then("it no longer raises", Runs(o, "ViewNotAtRisk()"), "")
	Then("the chart is displayed once", o.ViewsAsked(), 1)
	Then("the nodes not at risk are highlighted, the vacant ones included", @@(Lit(o)), @@(["vp2", "s1"]))
	Then("the at-risk ones are not", StzFindFirst("ceo", Lit(o)) + StzFindFirst("vp1", Lit(o)), 0)

	o.SetNodeProperty("vp1", "successor", "s1")
	Runs(o, "ViewNotAtRisk()")
	Then("a position that gets a successor joins the highlight", @@(Lit(o)), @@(["vp1", "vp2", "s1"]))
	Then("the view is the complement of ViewAtRisk",
		@@(Lit(o)), @@(Complement(o, o.SuccessionRisk())))
	Runs(o, "ViewAtRisk()")
	Then("the at-risk view highlights the rest", @@(Lit(o)), @@(["ceo"]))
	Then("no node was added", o.NumberOfNodes(), n)

	o = Chart("TechCo")
	o.SetTitle("Titled")
	Then("with a title it does not raise", Runs(o, "ViewNotAtRisk()"), "")
	Then("the subtitle names the view", StzFindFirst("Not-at risk", o.Subtitle()) > 0, 1)
	Then("and the highlight is the same", @@(Lit(o)), @@(["vp2", "s1"]))
EndScenario()

Scenario("Row 7 -- ViewDepartment with a title")
	o = Chart("TechCo")
	n = o.NumberOfNodes()
	Then("without a title it works", Runs(o, 'ViewDepartment("sales")'), "")
	Then("the positions of the department are highlighted", @@(Lit(o)), @@(["vp1", "s1"]))
	Then("another department's position is not", StzFindFirst("vp2", Lit(o)), 0)
	Then("the chart is displayed", o.ViewsAsked(), 1)

	o = Chart("TechCo")
	o.SetTitle("Titled")
	Then("with a title it no longer raises", Runs(o, 'ViewDepartment("sales")'), "")
	Then("the subtitle names the department", o.Subtitle(), "Department 'sales'")
	Then("the same positions are highlighted", @@(Lit(o)), @@(["vp1", "s1"]))
	Then("no node was added", o.NumberOfNodes(), n)

	Runs(o, 'ViewDepartment("risk")')
	Then("another department highlights its own positions", @@(Lit(o)), @@(["vp2"]))
	Then("and renames the subtitle", o.Subtitle(), "Department 'risk'")
	Runs(o, 'ViewDepartment("nowhere")')
	Then("a department nobody belongs to highlights nothing", len(Lit(o)), 0)
	Then("a position with no department gains an empty department key when read", HasKey(o.Position("ceo"), :department), 1)
EndScenario()

Scenario("Row 8 -- ViewPath with a title leaves the chart as it was")
	o = Chart("TechCo")
	n = o.NumberOfNodes()
	Then("without a title it works", Runs(o, 'ViewPath("ceo", "s1")'), "")
	Then("the positions on the path are highlighted", @@(Lit(o)), @@(["ceo", "vp1", "s1"]))
	Then("a position off the path is not", StzFindFirst("vp2", Lit(o)), 0)
	Then("no node was added", o.NumberOfNodes(), n)

	o = Chart("TechCo")
	o.SetTitle("Titled")
	Then("with a title it works", Runs(o, 'ViewPath("ceo", "s1")'), "")
	Then("no stray node was added", o.NumberOfNodes(), n)
	Then("no node has an empty id", EmptyIds(o), 0)
	Then("the subtitle names both ends", o.Subtitle(), "Path from 'ceo' to 's1'")
	Then("the same positions are highlighted", @@(Lit(o)), @@(["ceo", "vp1", "s1"]))

	Runs(o, 'ViewReportingPath("ceo", "vp2")')
	Then("ViewReportingPath is the same view", @@(Lit(o)), @@(["ceo", "vp2"]))
	Runs(o, 'HilightPath("ceo", "vp1")')
	Then("HilightPath too", @@(Lit(o)), @@(["ceo", "vp1"]))
	Runs(o, 'FocusOnPath("vp1", "s1")')
	Then("FocusOnPath too", @@(Lit(o)), @@(["vp1", "s1"]))
	Then("the subtitle follows the ends", o.Subtitle(), "Path from 'vp1' to 's1'")
	Then("the chart still has its nodes", o.NumberOfNodes(), n)
EndScenario()

Scenario("Row 9 and 10 -- the two placeholders are harmless, their siblings work")
	o = Chart("TechCo")
	n = o.NumberOfNodes()
	cBefore = @@(Colors(o))
	Then("ViewNodeWithProperties does not raise", Runs(o, 'ViewNodeWithProperties(["level", "department"])'), "")
	Then("it displays nothing", o.ViewsAsked(), 0)
	Then("it colours nothing", @@(Colors(o)), cBefore)
	Then("ViewNodesWithTags does not raise", Runs(o, 'ViewNodesWithTags(["a", "b"])'), "")
	Then("it displays nothing", o.ViewsAsked(), 0)
	Then("it colours nothing", @@(Colors(o)), cBefore)
	Then("neither adds a node", o.NumberOfNodes(), n)

	o.SetNodeProperty("vp1", "tags", ["key", "sales"])
	o.SetNodeProperty("s1", "tags", ["sales"])
	Runs(o, 'ViewNodesWithTag("key")')
	Then("ViewNodesWithTag highlights the nodes holding the tag", @@(Lit(o)), @@(["vp1"]))
	Runs(o, 'ViewNodesWithTag("sales")')
	Then("every node holding it", @@(Lit(o)), @@(["vp1", "s1"]))
	Runs(o, 'ViewNodesWithTag("absent")')
	Then("a tag nobody holds highlights nothing", len(Lit(o)), 0)
	Runs(o, 'ViewNodesWithProperty("department", "risk")')
	Then("ViewNodesWithProperty highlights by a property value", @@(Lit(o)), @@(["vp2"]))
	Then("so the displayed views are the counted ones", o.ViewsAsked(), 4)
EndScenario()

Scenario("The edges of the family -- positions with no record, and the chart is not altered by reading")
	o = Chart("TechCo")
	cRec = @@(o.Positions())
	o.SuccessionRisk()
	o.ValidateSuccession()
	o.GenerateVacancyReport()
	o.ResetAllNodeColors()
	Then("the position records are unchanged by the checks", @@(o.Positions()), cRec)
	Then("the validation still has its five default norms", len(o.Validators()), 5)
	Then("the whole Validate runs with succession in it", len(o.Validate()[:results]), 5)
	Then("and the succession verdict is the one SuccessionRisk gives",
		o.Validate()[:results][5][:issueCount], len(o.SuccessionRisk()))
EndScenario()

Summary()

#--------------------------------------------------------------------

func Chart(cTitle)
	o = new stzOrgChartProbe(cTitle)
	o.AddExecutiveXT("ceo", "CEO")
	o.AddManagerXT("vp1", "VP Sales")
	o.AddManagerXT("vp2", "VP Ops")
	o.AddStaffXT("s1", "Analyst")
	o.ReportsTo("vp1", "ceo")
	o.ReportsTo("vp2", "ceo")
	o.ReportsTo("s1", "vp1")
	o.SetPositionDepartment("vp1", "sales")
	o.SetPositionDepartment("s1", "sales")
	o.SetPositionDepartment("vp2", "risk")
	o.AddPersonXT("p1", "Alice")
	o.AddPersonXT("p2", "Bob")
	o.AssignPerson("p1", "ceo")
	o.AssignPerson("p2", "vp1")
	return o

# the error text of a call, "" when it ran
func Runs(o, cCall)
	cErr = ""
	try
		eval("o." + cCall)
	catch
		cErr = cCatchError
	done
	return cErr

# the ids of the nodes painted with the focus colour, in node order
func Lit(o)
	aIds = []
	aNodes = o.Nodes()
	nLen = len(aNodes)
	for i = 1 to nLen
		if o.NodeProperty(aNodes[i]["id"], "color") = o.FocusColor()
			aIds + aNodes[i]["id"]
		ok
	next
	return aIds

func EmptyIds(o)
	nEmpty = 0
	aNodes = o.Nodes()
	nLen = len(aNodes)
	for i = 1 to nLen
		if aNodes[i]["id"] = ""
			nEmpty++
		ok
	next
	return nEmpty

func Colors(o)
	aCols = []
	aNodes = o.Nodes()
	nLen = len(aNodes)
	for i = 1 to nLen
		aCols + [ aNodes[i]["id"], o.NodeProperty(aNodes[i]["id"], "color") ]
	next
	return aCols

# every node id that is not in the list, in node order
func Complement(o, acIds)
	aOut = []
	aNodes = o.Nodes()
	nLen = len(aNodes)
	for i = 1 to nLen
		if StzFindFirst(aNodes[i]["id"], acIds) = 0
			aOut + aNodes[i]["id"]
		ok
	next
	return aOut

# an org chart that counts the display requests and writes no file
class stzOrgChartProbe from stzOrgChart

	@nViews = 0

	def View()
		@nViews++

	def ViewsAsked()
		return @nViews
