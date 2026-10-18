load "../../stzBase.ring"
load "../_narrated.ring"

# stzDiagram (base/graph/stzDiagram.ring) -- the five register rows, run on one small diagram whose answers were
# worked out by hand BEFORE the code was run:
#
#   nodes   a (weight 5, kind Core, tag hot)   b (weight 2, kind edge)   c (weight 9, tags hot and new)
#   edges   a -> b, b -> c, a -> c
#   rules   heavy = weight from 5 to 10        -> matches a and c
#           ghost = weight equal to 77         -> matches nothing
#
# What each row was: PenWidth read an attribute nothing sets (the setter writes the node pen width);
# NodesWith built a stzGraphQuery with two arguments where its constructor takes one, and the query
# refuses a stzDiagram anyway; propertiesLegend and Explain read the registered rules as objects while
# RegisterVisualRule stores hash lists; SaveToStzDiagInFolder took no folder argument and called a method
# that exists nowhere.
#
# The .stzdiag files are written inside ONE fixture folder, <this folder>/_fixture (or the folder named by
# the environment variable STZ_FX_ROOT, which must itself end in /_fixture), created fresh at the start and
# removed at the end. FxGuard() refuses any path that is relative, has .., or is outside that folder, before
# every write and every delete. Run from inside this folder. ASCII only on the console.

$cFx = StzReplace(currentdir(), "\", "/") + "/_fixture"
if sysget("STZ_FX_ROOT") != ""
	$cFx = StzReplace(sysget("STZ_FX_ROOT"), "\", "/")
ok
if FxRootOk() = 0
	? "GUARD: the fixture root is not acceptable: " + $cFx
	shutdown(9)
ok
FxRemoveRoot()
StzDirCreatePath($cFx)

Scenario("The general pen width (PenWidth)")
	Given("a fresh diagram")
	d = Mk()
	Then("the pen width is 1 until set", d.PenWidth(), 1)
	When("SetPenWidth(4) is called")
	d.SetPenWidth(4)
	Then("PenWidth answers 4", d.PenWidth(), 4)
	Then("the edge width did not move (the setter writes the node width only)", d.EdgePenWidth(), 1)
	When("SetNodePenWidth(2) is called, which sets both widths")
	d.SetNodePenWidth(2)
	Then("PenWidth answers 2", d.PenWidth(), 2)
	Then("the edge width followed", d.EdgePenWidth(), 2)
	bNum = isNumber(d.PenWidth())
	Then("PenWidth is a plain number", bNum, 1)
EndScenario()

Scenario("Nodes whose property satisfies a comparison (NodesWith)")
	Given("a (weight 5, kind Core), b (weight 2, kind edge), c (weight 9)")
	d = Mk()
	Then("weight > 4 gives a and c", @@(d.NodesWith("weight", ">", 4)), '[ "a", "c" ]')
	Then("weight = 2 gives b", @@(d.NodesWith("weight", "=", 2)), '[ "b" ]')
	Then("weight != 5 gives b and c", @@(d.NodesWith("weight", "!=", 5)), '[ "b", "c" ]')
	Then("weight <= 5 gives a and b", @@(d.NodesWith("weight", "<=", 5)), '[ "a", "b" ]')
	Then("weight >= 9 gives c", @@(d.NodesWith("weight", ">=", 9)), '[ "c" ]')
	Then("weight < 2 gives nothing", @@(d.NodesWith("weight", "<", 2)), '[ ]')
	Then("kind = Core gives a", @@(d.NodesWith("kind", "=", "Core")), '[ "a" ]')
	n1 = len(d.NodesWith("kind", "=", "core"))
	Then("kind = core (other case) gives nothing: equality is exact", n1, 0)
	Then("kind contains OR gives a (case ignored)", @@(d.NodesWith("kind", "contains", "OR")), '[ "a" ]')
	Then("kind startswith ED gives b", @@(d.NodesWith("kind", "startswith", "ED")), '[ "b" ]')
	Then("kind endswith GE gives b", @@(d.NodesWith("kind", "endswith", "GE")), '[ "b" ]')
	Then("kind endswith ED gives nothing", @@(d.NodesWith("kind", "endswith", "ED")), '[ ]')
	Then("weight in [2, 9] gives b and c", @@(d.NodesWith("weight", "in", [ 2, 9 ])), '[ "b", "c" ]')
	Then("weight not_in [2, 9] gives a", @@(d.NodesWith("weight", "not_in", [ 2, 9 ])), '[ "a" ]')
	When("the property does not exist on any node")
	Then("the answer is empty", @@(d.NodesWith("nokey", "=", 1)), '[ ]')
	Then("kind != x skips node c, which has no kind", @@(d.NodesWith("kind", "!=", "x")), '[ "a", "b" ]')
	When("the value has the wrong type")
	Then("weight > text gives nothing", @@(d.NodesWith("weight", ">", "4")), '[ ]')
	Then("weight = text gives nothing", @@(d.NodesWith("weight", "=", "5")), '[ ]')
	Then("kind contains a number gives nothing", @@(d.NodesWith("kind", "contains", 5)), '[ ]')
	When("the comparison is unknown")
	cErr = ""
	try
		d.NodesWith("weight", "~~", 1)
	catch
		cErr = cCatchError
	done
	bRaised = StzFindFirst("Unknown comparison", cErr) > 0
	Then("an error names the comparison", bRaised, 1)
	Then("the siblings still answer: NodesWithProperty", @@(d.NodesWithProperty("weight")), '[ "a", "b", "c" ]')
	Then("the siblings still answer: NodesWithTag", @@(d.NodesWithTag("hot")), '[ "a", "c" ]')
EndScenario()

Scenario("No visual rule: the legend and the explanation say so")
	Given("a diagram with no rule")
	d = Mk()
	a = d.propertiesLegend()
	Then("the legend is the heading and a blank line", @@(a), '[ "=== properties LEGEND ===", "" ]')
	e = d.Explain()
	Then("Explain says no rule is defined", e[:rules], "No visual rules defined.")
	Then("Explain says what the diagram holds", e[:structure], "Diagram 'flow' contains 3 nodes and 3 edges.")
	Then("Explain says nothing was matched", e[:effects], "No rules matched any elements.")
EndScenario()

Scenario("A registered visual rule (propertiesLegend, Explain)")
	Given("the rule heavy registered, and not yet applied")
	d = Mk()
	d.RegisterVisualRule("heavy", [ :conditionType = "property_range", :conditionParams = [ "weight", 5, 10 ],
		:effects = [ [ "fillcolor", "red" ], [ "penwidth", 3 ] ] ])
	e = d.Explain()
	Then("Explain lists the rule by its name", e[:rules], "Applied 1 visual rule(s): heavy")
	Then("nothing is affected before ApplyVisualRules", e[:effects], "No rules matched any elements.")
	a = d.propertiesLegend()
	Then("the legend has the heading, a blank line, and 5 lines for the rule", len(a), 7)
	Then("the heading", a[1], "=== properties LEGEND ===")
	Then("the condition line", a[3], "When: property_range")
	Then("the parameters line", a[4], '  Params: [ "weight", 5, 10 ]')
	Then("a text effect", a[5], "  -> fillcolor: red")
	Then("a numeric effect", a[6], "  -> penwidth: 3")
	Then("the rule ends on a blank line", a[7], "")
	When("ApplyVisualRules runs")
	d.ApplyVisualRules()
	e = d.Explain()
	Then("Explain counts the two nodes a and c", e[:effects], "2 node(s) enhanced.")
	Then("the affected nodes are a and c", @@(d.NodesAffectedByVisualRules()), '[ "a", "c" ]')
	When("a second rule is registered that matches nothing (weight equal to 77)")
	d.RegisterVisualRule("ghost", [ :conditionType = "property_equals", :conditionParams = [ "weight", 77 ],
		:effects = [ [ "fillcolor", "blue" ] ] ])
	d.ApplyVisualRules()
	e = d.Explain()
	Then("Explain lists both names", e[:rules], "Applied 2 visual rule(s): heavy, ghost")
	Then("the effects did not change: the ghost rule affects nothing", e[:effects], "2 node(s) enhanced.")
	a = d.propertiesLegend()
	Then("the legend grew by 4 lines", len(a), 11)
	Then("the second condition line", a[8], "When: property_equals")
	Then("the second effect", a[10], "  -> fillcolor: blue")
	Then("the summary agrees on 2 rules", len(d.VisualRulesApplied()), 2)
EndScenario()

Scenario("A rule that matches nothing at all")
	Given("only the ghost rule")
	d = Mk()
	d.RegisterVisualRule("ghost", [ :conditionType = "property_equals", :conditionParams = [ "weight", 77 ],
		:effects = [ [ "fillcolor", "blue" ] ] ])
	d.ApplyVisualRules()
	e = d.Explain()
	Then("Explain still lists the rule", e[:rules], "Applied 1 visual rule(s): ghost")
	Then("and reports that it affected nothing", e[:effects], "No rules matched any elements.")
	n = len(d.NodesAffectedByVisualRules())
	Then("no node is affected", n, 0)
	When("a rule with no effects and no parameters is registered")
	d.RegisterVisualRule("bare", [ :conditionType = "tag_exists", :conditionParams = [], :effects = [] ])
	a = d.propertiesLegend()
	Then("the legend shows its condition only (heading, blank, 4 lines for ghost, 2 for bare)", len(a), 8)
	Then("the bare rule's condition", a[7], "When: tag_exists")
EndScenario()

Scenario("Saving the diagram into a folder (SaveToStzDiagInFolder)")
	Given("a missing nested folder inside the fixture")
	d = Mk()
	cFolder = FxP("deep/er")
	Then("the folder does not exist yet", StzDirExists(cFolder), 0)
	When("the diagram is saved there")
	cPath = d.SaveToStzDiagInFolder(cFolder)
	Then("the answer is the path of the file", cPath, cFolder + "/flow.stzdiag")
	Then("the folder was created", StzDirExists(cFolder), 1)
	Then("the file exists", StzEngineFileExists(cPath), 1)
	cText = FxReadAt(cPath)
	cWanted = d.stzdiag()
	cPlain = StzReplace(cText, char(13), "")
	Then("the file holds the diagram text (the console's line ends aside)", cPlain, cWanted)
	When("the file is read back into an empty diagram")
	r = new stzDiagram("empty")
	r.ImportDiag(cText)
	Then("the name is restored", r.Name(), "flow")
	Then("the three nodes are back", @@(r.NodesIds()), '[ "a", "b", "c" ]')
	Then("the three edges are back", r.EdgeCount(), 3)
	Then("an edge is back", r.EdgeExists("a", "c"), 1)

	When("the same folder is used again (it exists now)")
	cPath2 = d.SaveToStzDiagInFolder(cFolder)
	Then("the same path comes back", cPath2, cPath)
	Then("the folder is reused and the file is still there", StzEngineFileExists(cPath2), 1)

	When("a second diagram named Other is saved in the same folder")
	o2 = new stzDiagram("Other")
	o2.AddNode("z")
	cPath3 = o2.SaveToStzDiagInFolder(cFolder)
	Then("its file name is the folded name", cPath3, cFolder + "/other.stzdiag")
	cAgain = FxReadAt(cPath)
	Then("the first file is untouched", cAgain, cText)

	When("the folder is given with a trailing slash, and with backslashes")
	cPath4 = d.SaveToStzDiagInFolder(cFolder + "/")
	Then("a trailing slash gives the same path", cPath4, cPath)
	cBack = StzReplace(cFolder, "/", "\")
	cPath5 = d.SaveToStzDiagInFolder(cBack)
	Then("backslashes give the same path", cPath5, cPath)

	When("the diagram changes and is saved again")
	d.AddNode("zz")
	d.SaveToStzDiagInFolder(cFolder)
	cNew = FxReadAt(cPath)
	bHasZz = StzFindFirst("zz", cNew) > 0
	Then("the file is replaced", bHasZz, 1)

	When("the folder argument is empty or not a text")
	cE1 = ""
	try
		d.SaveToStzDiagInFolder("")
	catch
		cE1 = cCatchError
	done
	b1 = StzFindFirst("pcFolder must be a non-empty string", cE1) > 0
	Then("an empty folder name raises", b1, 1)
	cE2 = ""
	try
		d.SaveToStzDiagInFolder(12)
	catch
		cE2 = cCatchError
	done
	b2 = StzFindFirst("pcFolder must be a non-empty string", cE2) > 0
	Then("a number raises", b2, 1)
EndScenario()

FxGuard($cFx, 1)
StzDirDeleteAll($cFx)
Summary()

func Mk()
	d = new stzDiagram("flow")
	d.AddNodeXTT("a", "Alpha", [ :weight = 5, :kind = "Core", :tags = [ "hot" ] ])
	d.AddNodeXTT("b", "Beta", [ :weight = 2, :kind = "edge" ])
	d.AddNodeXTT("c", "Gamma", [ :weight = 9, :tags = [ "hot", "new" ] ])
	d.Connect("a", "b")
	d.Connect("b", "c")
	d.Connect("a", "c")
	return d

#------------------------------------------------------------------------------------------
# Fixture helpers. Every path the library sees comes from FxP(); every destructive step is
# behind FxGuard().
#------------------------------------------------------------------------------------------

func FxRootOk()
	c = $cFx
	if NOT isString(c)
		return 0
	ok
	if len(c) < 20
		return 0
	ok
	if StzFindFirst("..", c) > 0
		return 0
	ok
	if StzRight(c, 9) != "/_fixture"
		return 0
	ok
	if c[2] != ":" or c[3] != "/"
		return 0
	ok
	return 1

# Refuses (and stops the process) any path that is not strictly inside the fixture root.
func FxGuard(cPath, bAllowRoot)
	if FxRootOk() = 0
		? "GUARD REFUSED: bad fixture root"
		shutdown(9)
	ok
	if NOT isString(cPath) or cPath = ""
		? "GUARD REFUSED: not a path"
		shutdown(9)
	ok
	p = StzReplace(cPath, "\", "/")
	if StzFindFirst("..", p) > 0
		? "GUARD REFUSED: contains .."
		shutdown(9)
	ok
	if p[2] != ":" or p[3] != "/"
		? "GUARD REFUSED: not absolute"
		shutdown(9)
	ok
	if bAllowRoot = 1 and p = $cFx
		return 1
	ok
	nRoot = len($cFx)
	if len(p) <= nRoot + 1 or left(p, nRoot + 1) != $cFx + "/"
		? "GUARD REFUSED: outside the fixture: " + p
		shutdown(9)
	ok
	return 1

func FxP(cRel)
	p = $cFx + "/" + cRel
	FxGuard(p, 0)
	return p

func FxReadAt(cPath)
	FxGuard(cPath, 0)
	return StzEngineFileRead(cPath)

func FxRemoveRoot()
	if StzEngineDirExists($cFx) = 1
		FxGuard($cFx, 1)
		StzDirDeleteAll($cFx)
	ok
