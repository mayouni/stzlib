load "../../stzBase.ring"
load "../_narrated.ring"

# Guard for stzHtmlBuilder (DEFECTS.md, stzHtmlBuilder, fixed on fix/hb): AppendToCurrent, Build and
# BuildToFile. ONE cause: the current node was a COPY of the root made at birth (Ring copies an object
# on assignment), so a node appended to "the current node" landed in the copy and Build, Root and
# BuildToFile still showed nothing.
#
# THE FIX the guard holds in place: the document lives in the builder itself (parallel lists, node 1 is
# the root), and the current node is a node NUMBER, readable as a path of child numbers. A returned
# builder (return self) is the same object, so chains see one document.
#
# Every expectation is built by the guard itself from plain text, or from the node class's own
# ToHtml on a tree built apart: never from the builder under test. Accented and Hebrew texts are built
# from char codes and never printed; their assertions compare with strcmp and print 1 or 0 only.

cTmp = currentdir() + "/_hb_build.tmp.html"
remove(cTmp)

cE = char(195) + char(169)                      # e acute, UTF-8
cHeb = char(215) + char(144) + char(215) + char(145) + char(215) + char(146)   # alef bet gimel

Scenario("The three listed defects, each with its negative sibling")
	o = new stzHtmlBuilder()
	p1 = o.CreateNode("p")
	p1.SetText("x")
	o.AppendToCurrent(p1)
	Then("AppendToCurrent: the node appears in Build", Same(o.Build(), "<p>x</p>"), 1)
	d1 = o.CreateNode("div")
	o.AppendToCurrent(d1)
	Then("a second, different node appears after the first", Same(o.Build(), "<p>x</p><div></div>"), 1)
	Then("a node never appended does not appear", Has(o.Build(), "<h1>"), 0)
	aRoot = o.Root().Children()
	Then("Root shows both children", len(aRoot), 2)
	Then("Root shows the first one by tag", aRoot[1].Tag(), "p")
	Then("Root shows the second one by tag", aRoot[2].Tag(), "div")
	o.SetCurrent(o.Root())
	o.AppendToCurrent(o.CreateNode("span"))
	Then("after SetCurrent(Root()) the next node still lands in the document", Same(o.Build(), "<p>x</p><div></div><span></span>"), 1)
	Then("NodeCount counts three nodes, the root not counted", o.NodeCount(), 3)
	o.BuildToFile(cTmp)
	cBack = read(cTmp)
	Then("BuildToFile: the file is not empty", len(cBack) > 0, 1)
	Then("BuildToFile: the file holds the document", Same(cBack, "<p>x</p><div></div><span></span>"), 1)
	remove(cTmp)
	Then("the file is gone after remove", fexists(cTmp), 0)
EndScenario()

Scenario("Chaining: a chain of calls works on one document; a variable assigned from a call is a copy")
	o = new stzHtmlBuilder()
	a = o.CreateNode("a")
	b = o.CreateNode("b")
	c = o.CreateNode("c")
	cChain = o.AppendToCurrent(a).AppendToCurrent(b).Build()
	Then("a chain of two appends and a Build holds both", Same(cChain, "<a></a><b></b>"), 1)
	Then("the variable holds both too (the chain did not work on a copy)", Same(o.Build(), "<a></a><b></b>"), 1)
	o.AppendToCurrentQ(c).AppendToCurrentQ(a)
	Then("the Q form chains as well", Same(o.Build(), "<a></a><b></b><c></c><a></a>"), 1)
	Then("a node never put in does not appear", Has(o.Build(), "<i>"), 0)
	o2 = o.AppendToCurrent(b)
	Then("a variable given the result of a call holds the document as it stands (Ring copies on assignment)", Same(o2.Build(), o.Build()), 1)
	o2.AppendToCurrent(c)
	Then("but it is a copy: what is added to it does not reach the original", Same(o.Build(), "<a></a><b></b><c></c><a></a><b></b>"), 1)
	Then("the copy took it", Same(o2.Build(), "<a></a><b></b><c></c><a></a><b></b><c></c>"), 1)
	o3 = new stzHtmlBuilder()
	o3.AppendToCurrent(a)
	Then("another builder is not touched by the first", Same(o3.Build(), "<a></a>"), 1)
	Then("and the first is not touched by it", Has(o.Build(), "<a></a><b></b><c>"), 1)
EndScenario()

Scenario("Nesting: append, go inside, append a child, come back out")
	o = new stzHtmlBuilder()
	d = o.CreateNode("div")
	p = o.CreateNode("p")
	p.SetText("x")
	o.AppendToCurrent(d).GoToLastChild().AppendToCurrent(p).GoUp()
	Then("the paragraph is inside the div", Same(o.Build(), "<div><p>x</p></div>"), 1)
	Then("the position is back at the root", len(o.CurrentPath()), 0)
	o.AppendToCurrent(o.CreateNode("hr"))
	Then("a node added after coming out lands beside the div", Same(o.Build(), "<div><p>x</p></div><hr></hr>"), 1)
	Then("and not inside it", Has(o.Build(), "<p>x<hr>"), 0)
	Then("the paragraph sits one level down", Has(o.Build(), "<div><p>x</p></div>"), 1)
	o.SetCurrent([ 1 ])
	o.AppendToCurrent(o.CreateNode("em"))
	Then("a path takes the next node into the div", Same(o.Build(), "<div><p>x</p><em></em></div><hr></hr>"), 1)
	Then("the current path is the one that was set", @@(o.CurrentPath()), "[ 1 ]")
	o.GoToLastChild()
	Then("the last child of the div is the em", @@(o.CurrentPath()), "[ 1, 2 ]")
	o.GoUp().GoUp()
	Then("two steps up are the root", @@(o.CurrentPath()), "[ ]")
	o.GoUp()
	Then("a step above the root stays at the root and raises nothing", @@(o.CurrentPath()), "[ ]")
	o.SetCurrent([ 1, 2 ]).GoToRoot()
	Then("GoToRoot comes back from anywhere", @@(o.CurrentPath()), "[ ]")
EndScenario()

Scenario("SetCurrent with a node: found by what it contains, the last added first")
	o = new stzHtmlBuilder()
	ul = o.CreateNode("ul")
	li1 = o.CreateNode("li")
	li1.SetText("one")
	li2 = o.CreateNode("li")
	li2.SetText("two")
	o.AppendToCurrent(ul).GoToLastChild().AppendToCurrent(li1).AppendToCurrent(li2).GoToRoot()
	o.SetCurrent(li1)
	Then("a node already in the document becomes current, at its place", @@(o.CurrentPath()), "[ 1, 1 ]")
	o.SetCurrent(li2)
	Then("the other one as well", @@(o.CurrentPath()), "[ 1, 2 ]")
	o.SetCurrent(o.Root())
	Then("Root() makes the root current", @@(o.CurrentPath()), "[ ]")
	ulFull = o.CreateNode("ul")
	ulFull.AppendChild(li1)
	ulFull.AppendChild(li2)
	o.SetCurrent(ulFull)
	Then("the list node found by its contents, children included", @@(o.CurrentPath()), "[ 1 ]")
	cMsg = Raises(o, "o.SetCurrent(ul)")
	Then("the empty list node, which was appended before it had children, is not in the document", len(cMsg) > 0, 1)
	o.AppendToCurrent(li1)
	o.SetCurrent(li1)
	Then("of two equal nodes the one added last wins", @@(o.CurrentPath()), "[ 1, 3 ]")
	o.SetCurrent([ 1 ])
	cMsg = Raises(o, 'o.SetCurrent(o.CreateNode("table"))')
	Then("a node that is not in the document raises an error", len(cMsg) > 0, 1)
	Then("and the position did not move", @@(o.CurrentPath()), "[ 1 ]")
	li3 = o.CreateNode("li")
	li3.SetText("one")
	li3.SetAttr("class", "x")
	cMsg = Raises(o, "o.SetCurrent(li3)")
	Then("a node that differs by an attribute only is not the one in the document", len(cMsg) > 0, 1)
EndScenario()

Scenario("A node that already has children, the same node twice, and a deep spot after other appends")
	o = new stzHtmlBuilder()
	t = o.CreateNode("table")
	tr = o.CreateNode("tr")
	td = o.CreateNode("td")
	td.SetText("c")
	tr.AppendChild(td)
	tr.AppendChild(td)
	t.AppendChild(tr)
	o.AppendToCurrent(t)
	cRef = t.ToHtml()
	Then("the tree arrives whole, with its children and grandchildren", Same(o.Build(), cRef), 1)
	Then("the reference itself is what a person would write", Same(cRef, "<table><tr><td>c</td><td>c</td></tr></table>"), 1)
	Then("four nodes in all", o.NodeCount(), 4)
	o.AppendToCurrent(t)
	Then("the same node twice gives two copies", Same(o.Build(), cRef + cRef), 1)
	Then("eight nodes now", o.NodeCount(), 8)
	o.SetCurrent([ 1, 1 ])
	o.AppendToCurrent(td)
	cExp = "<table><tr><td>c</td><td>c</td><td>c</td></tr></table>" + cRef
	Then("a node added deep in the tree goes to the first table only", Same(o.Build(), cExp), 1)
	o.SetCurrent([ 2, 1, 2 ])
	o.AppendToCurrent(o.CreateNode("b"))
	cExp = "<table><tr><td>c</td><td>c</td><td>c</td></tr></table><table><tr><td>c</td><td>c<b></b></td></tr></table>"
	Then("and one deep in the second table goes there only", Same(o.Build(), cExp), 1)
	Then("the first table has no b", Has(o.Build(), "<td>c</td><b>"), 0)
	t.SetText("late")
	Then("changing the original after the append is not seen in the document", Has(o.Build(), "late"), 0)
EndScenario()

Scenario("Build equals the node classes' own serialisation, with no escaping of its own")
	o = new stzHtmlBuilder()
	ref = new stzHtmlBuildNode("")
	h = o.CreateNode("h1")
	h.SetText("a < b & c > d")
	h.SetAttr("title", 'say "hi" & <go>')
	h.SetAttr("data-x", "1")
	h.SetAttr("data-x", "2")
	o.AppendToCurrent(h)
	ref.AppendChild(h)
	Then("the text and the attributes are written as the node writes them", Same(o.Build(), ref.ToHtml()), 1)
	# RX1 (2026-10-22): text is escaped when the document is written, and so is
	# an attribute value; SetMarkup is the one door that writes as given
	Then("the text is escaped: a < reads as &lt;", Has(o.Build(), "a &lt; b &amp; c &gt; d"), 1)
	Then("the quote of the attribute is escaped too", Has(o.Build(), 'say &quot;hi&quot; &amp; &lt;go&gt;'), 1)
	Then("an attribute set twice is written twice, as the node does", Has(o.Build(), 'data-x="1" data-x="2"'), 1)
	Then("the node class and the builder agree on Root", Same(o.Root().ToHtml(), ref.ToHtml()), 1)
	Then("ToHtml on the builder is Build", Same(o.ToHtml(), o.Build()), 1)
	Then("a made-up difference is detected by Same", Same(o.Build(), ref.ToHtml() + "x"), 0)
	Then("a case difference is detected by Same", Same("<P>", "<p>"), 0)
EndScenario()

Scenario("Unicode text: accented and Hebrew, built from char codes, never printed")
	o = new stzHtmlBuilder()
	p = o.CreateNode("p")
	p.SetText(cE + cHeb + cE)
	p.SetAttr("title", cHeb)
	o.AppendToCurrent(p)
	cExp = "<p title=" + char(34) + cHeb + char(34) + ">" + cE + cHeb + cE + "</p>"
	Then("Build writes the texts intact", Same(o.Build(), cExp), 1)
	Then("byte length is the sum of the bytes", len(o.Build()), len("<p title=" + char(34) + char(34) + "></p>") + 6 + 2 + 6 + 2)
	Then("an altered letter is detected", Same(o.Build(), cExp + cE), 0)
	o.BuildToFile(cTmp)
	cBack = read(cTmp)
	Then("the file holds the same number of bytes", len(cBack), len(o.Build()))
	Then("the file holds the same bytes", Same(cBack, cExp), 1)
	Then("no byte order mark in front", ascii(cBack[1]) = 239, 0)
	Then("the first byte is the open angle bracket", ascii(cBack[1]), 60)
	remove(cTmp)
EndScenario()

Scenario("The file is exactly the text Build returns: line breaks, a long text, an existing file replaced")
	o = new stzHtmlBuilder()
	pre = o.CreateNode("pre")
	pre.SetText("l1" + char(10) + "l2" + char(13) + char(10) + "l3" + char(13) + char(9) + "end" + char(0) + "z")
	o.AppendToCurrent(pre)
	o.AppendToCurrent(pre)
	cText = o.Build()
	o.BuildToFile(cTmp)
	cBack = read(cTmp)
	Then("same length, line breaks included", len(cBack), len(cText))
	Then("same bytes", Same(cBack, cText), 1)
	Then("the line feed is still one byte", Has(cBack, "l1" + char(10) + "l2"), 1)
	Then("the carriage return and line feed are still two", Has(cBack, "l2" + char(13) + char(10) + "l3"), 1)
	Then("the file does not hold a doubled carriage return", Has(cBack, char(13) + char(13)), 0)
	o2 = new stzHtmlBuilder()
	o2.AppendToCurrent(o2.CreateNode("i"))
	o2.BuildToFile(cTmp)
	Then("an existing file is replaced, not appended to", Same(read(cTmp), "<i></i>"), 1)
	oRet = o2.BuildToFile(cTmp)
	Then("BuildToFile returns the builder, still chainable", Same(oRet.Build(), "<i></i>"), 1)
	cMsg = Raises(o2, 'o2.BuildToFile("")')
	Then("an empty path raises an error", len(cMsg) > 0, 1)
	cMsg = Raises(o2, "o2.BuildToFile(12)")
	Then("a number as the path raises an error", len(cMsg) > 0, 1)
	cMsg = Raises(o2, 'o2.BuildToFile("no_such_folder_hb/sub/x.html")')
	Then("a path that cannot be written raises an error", len(cMsg) > 0, 1)
	remove(cTmp)
EndScenario()

Scenario("An empty document")
	o = new stzHtmlBuilder()
	Then("Build of nothing is the empty text", Same(o.Build(), ""), 1)
	Then("and not another text", Same(o.Build(), " "), 0)
	Then("no node", o.NodeCount(), 0)
	Then("the position is the root", len(o.CurrentPath()), 0)
	Then("Root has no child", len(o.Root().Children()), 0)
	Then("Current has no child", len(o.Current().Children()), 0)
	o.BuildToFile(cTmp)
	Then("BuildToFile writes an empty file", fexists(cTmp), 1)
	Then("whose size is zero", len(read(cTmp)), 0)
	remove(cTmp)
	cMsg = Raises(o, "o.GoToLastChild()")
	Then("going to the last child of an empty root raises an error", len(cMsg) > 0, 1)
EndScenario()

Scenario("A wide document (500 children) and a deep one (100 levels), and how long they take")
	o = new stzHtmlBuilder()
	nT0 = clock()
	for i = 1 to 500
		oNd = o.CreateNode("li")
		oNd.SetText("n" + i)
		o.AppendToCurrent(oNd)
	next
	nAppend = (clock() - nT0) / clockspersecond()
	cExp = ""
	for i = 1 to 500
		cExp += "<li>n" + i + "</li>"
	next
	nT1 = clock()
	cBuilt = o.Build()
	nBuild = (clock() - nT1) / clockspersecond()
	Then("500 appends: 500 nodes", o.NodeCount(), 500)
	Then("the text is the 500 items in order", Same(cBuilt, cExp), 1)
	Then("the first and the last item are there", Has(cBuilt, "<li>n1</li><li>n2</li>") * Has(cBuilt, "<li>n499</li><li>n500</li>"), 1)
	Then("501 is not", Has(cBuilt, "n501"), 0)
	Then("500 appends take under 5 seconds", nAppend < 5, 1)
	Then("Build of 500 takes under 5 seconds", nBuild < 5, 1)
	oD = new stzHtmlBuilder()
	cOpen = ""
	cClose = ""
	nT2 = clock()
	for i = 1 to 100
		nd = oD.CreateNode("d" + i)
		oD.AppendToCurrent(nd).GoToLastChild()
		cOpen += "<d" + i + ">"
		cClose = "</d" + i + ">" + cClose
	next
	nDeep = (clock() - nT2) / clockspersecond()
	Then("100 levels deep: the nesting is exact", Same(oD.Build(), cOpen + cClose), 1)
	Then("the position is 100 steps down", len(oD.CurrentPath()), 100)
	Then("all of them are first children", Sum1(oD.CurrentPath()), 100)
	Then("100 nested appends take under 5 seconds", nDeep < 5, 1)
	oD.GoToRoot()
	Then("back at the root in one call", len(oD.CurrentPath()), 0)
	# one node appended with 100 levels already in it (the recursion of the copy-in)
	top = new stzHtmlBuildNode("t")
	oInner = ""
	for i = 99 to 1 step -1
		oLvl = new stzHtmlBuildNode("e" + i)
		if i < 99
			oLvl.AppendChild(oInner)
		ok
		oInner = oLvl
	next
	top.AppendChild(oInner)
	oE = new stzHtmlBuilder()
	oE.AppendToCurrent(top)
	Then("a node arriving with 100 levels inside is copied whole", Same(oE.Build(), top.ToHtml()), 1)
	Then("100 nodes, the root not counted", oE.NodeCount(), 100)
EndScenario()

Scenario("Copies of the builder are independent documents; snapshots do not write back")
	o = new stzHtmlBuilder()
	o.AppendToCurrent(o.CreateNode("a"))
	o2 = o
	o2.AppendToCurrent(o2.CreateNode("b"))
	Then("a copy has the document of the original at the time of the copy", Has(o2.Build(), "<a></a>"), 1)
	Then("it took the new node", Same(o2.Build(), "<a></a><b></b>"), 1)
	Then("the original did not (Ring copied the object on assignment)", Same(o.Build(), "<a></a>"), 1)
	rt = o.Root()
	rt.AppendChild(o.CreateNode("zzz"))
	Then("a snapshot from Root() written to does not reach the builder", Has(o.Build(), "zzz"), 0)
	cu = o.Current()
	cu.SetText("t")
	Then("nor one from Current()", Same(o.Build(), "<a></a>"), 1)
	d = o.CreateNode("n")
	Then("Node is CreateNode", d.Tag(), "n")
	Then("a created node has no content", d.ToHtml(), "<n></n>")
	o.SetCurrentQ([ 1 ]).AppendToCurrentQ(d)
	Then("SetCurrentQ chains", Same(o.Build(), "<a><n></n></a>"), 1)
EndScenario()

Scenario("Bad parameters raise an error and change nothing")
	o = new stzHtmlBuilder()
	o.AppendToCurrent(o.CreateNode("a"))
	cMsg = Raises(o, "o.AppendToCurrent(5)")
	Then("a number is not a node", len(cMsg) > 0, 1)
	cMsg = Raises(o, 'o.AppendToCurrent("<p></p>")')
	Then("a text is not a node", len(cMsg) > 0, 1)
	cMsg = Raises(o, "o.AppendToCurrent([ 1 ])")
	Then("a list is not a node", len(cMsg) > 0, 1)
	cMsg = Raises(o, "o.AppendToCurrent(new stzObject)")
	Then("another object is not a node", len(cMsg) > 0, 1)
	Then("the document is unchanged", Same(o.Build(), "<a></a>"), 1)
	cMsg = Raises(o, "o.SetCurrent([ 2 ])")
	Then("a path past the last child raises an error", len(cMsg) > 0, 1)
	cMsg = Raises(o, "o.SetCurrent([ 0 ])")
	Then("a path step of zero raises an error", len(cMsg) > 0, 1)
	cMsg = Raises(o, "o.SetCurrent([ 1.5 ])")
	Then("a fractional step raises an error", len(cMsg) > 0, 1)
	cMsg = Raises(o, 'o.SetCurrent([ "x" ])')
	Then("a text step raises an error", len(cMsg) > 0, 1)
	cMsg = Raises(o, "o.SetCurrent(5)")
	Then("a number raises an error", len(cMsg) > 0, 1)
	Then("the position is still the root", len(o.CurrentPath()), 0)
	cMsg = Raises(o, "o.SetCurrent([ 1 ])")
	Then("a valid path raises nothing", cMsg, "")
	Then("and moves", @@(o.CurrentPath()), "[ 1 ]")
	cMsg = Raises(o, "o.GoToLastChild()")
	Then("the leaf has no child to go to", len(cMsg) > 0, 1)
	Then("the position stays", @@(o.CurrentPath()), "[ 1 ]")
EndScenario()

Scenario("The node class, as a builder user touches it")
	n = new stzHtmlBuildNode("ul")
	Then("Tag", n.Tag(), "ul")
	Then("an empty node is an empty element", n.ToHtml(), "<ul></ul>")
	Then("Attrs of a node with none is the empty list", len(n.Attrs()), 0)
	r = n.SetText("t")
	Then("SetText returns the node, which is chainable", Same(r.ToHtml(), "<ul>t</ul>"), 1)
	Then("Text", n.Text(), "t")
	n.SetTextQ("u").SetAttr("id", "i1").SetAttr("class", "k")
	Then("SetTextQ and SetAttr chain", Same(n.ToHtml(), '<ul id="i1" class="k">u</ul>'), 1)
	Then("Attrs lists the pairs in order", @@(n.Attrs()), '[ [ "id", "i1" ], [ "class", "k" ] ]')
	a = n.Attrs()
	a + [ "x", "y" ]
	Then("Attrs is a copy: a change to it does not reach the node", len(n.Attrs()), 2)
	li = new stzHtmlBuildNode("li")
	n.AppendChild(li)
	n.Append(li)
	Then("AppendChild and Append add children in order", Same(n.ToHtml(), '<ul id="i1" class="k">u<li></li><li></li></ul>'), 1)
	Then("Children counts them", len(n.Children()), 2)
	Then("ChildrenHtml is the children only", Same(n.ChildrenHtml(), "<li></li><li></li>"), 1)
	li.SetText("late")
	Then("a child changed after it was appended is not changed in the node (a copy)", Has(n.ToHtml(), "late"), 0)
	oCont = new stzHtmlBuildNode("")
	oCont.AppendChild(li)
	Then("a tag-less container writes only its children", Same(oCont.ToHtml(), "<li>late</li>"), 1)
EndScenario()

Summary()

remove(cTmp)

# byte-exact equality. Ring's strcmp STOPS AT THE FIRST NUL (the file test holds end + NUL + z), so
# strcmp is only the quick reject: then length, then every byte.
func Same(a, b)
	if strcmp(a, b) != 0
		return 0
	ok
	if len(a) != len(b)
		return 0
	ok
	h_nLen = len(a)
	for h_nQ = 1 to h_nLen
		if ascii(a[h_nQ]) != ascii(b[h_nQ])
			return 0
		ok
	next
	return 1

func Has(cHost, cNeedle)
	return substr(cHost, cNeedle) > 0

func Sum1(aPath)
	nS = 0
	nL = len(aPath)
	for k = 1 to nL
		nS += aPath[k]
	next
	return nS

func Raises(o, cCode)
	try
		eval(cCode)
		return ""
	catch
		return cCatchError
	done
