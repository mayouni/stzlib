# A FAMILY TREE, NARRATED -- DN18 of the graph plane (SOFTANZA_GRAPH_PLANE_PLAN.md).
#
# A family tree is a tree with TWO PARENTS: people, the unions between
# them, and the children born of a union. The picture is a notation over
# the graph plane -- a union is a small node its partners hang from and
# its children hang under, so the sources settle onto what they feed and
# a long descent is routed beside the ranks it spans. The tree answers
# kinship by walking itself: parents, siblings, ancestors, descendants,
# generation. Five rules say what a family may not be -- a person who is
# their own ancestor, a union of three, a child born of two unions, a
# child older than a parent, partners who are kin.
#
# This guide RUNS: kinship is read back through the tree's own queries,
# and every rule is asked through the diagram's own governance.
#
#   Run:  ring familytree_narrated.ring

load "../../stzBase.ring"
load "gg_family_scenes.ring"

if NOT StzGraphicsDevice()
	? "(no device -- a notation picture is rendered as it is built, so this guide is UNJUDGED here)"
	return
ok

nPass = 0
nFail = 0
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
OPT = [ :Font = FONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]

? "-- Scene 1: three generations --"
oF = StzFamilyScene01(OPT)
? "   " + len(oF.People()) + " people, " + len(oF.Unions()) + " unions"
chk("eight people and three unions -- one of them a parent raising a child alone", len(oF.People()) = 8 and len(oF.Unions()) = 3)
? "   Yara's parents: " + idsText(oF.ParentsOf("yara")) + "; her siblings: " + idsText(oF.SiblingsOf("yara"))
chk("a child of a union has both its partners as parents, and the other children as siblings",
    len(oF.ParentsOf("yara")) = 2 and inList("sami", oF.ParentsOf("yara")) and inList("nour", oF.ParentsOf("yara")) and
    len(oF.SiblingsOf("yara")) = 1 and inList("omar", oF.SiblingsOf("yara")))
? "   Yara's ancestors: " + idsText(oF.AncestorsOf("yara"))
chk("ancestors are walked up through every union", len(oF.AncestorsOf("yara")) = 4 and inList("ali", oF.AncestorsOf("yara")))
? "   Ali's descendants: " + idsText(oF.DescendantsOf("ali"))
chk("descendants are walked down, including the grandchild raised by one parent", len(oF.DescendantsOf("ali")) = 5 and inList("lina", oF.DescendantsOf("ali")))
? "   generations: Ali " + oF.GenerationOf("ali") + ", Sami " + oF.GenerationOf("sami") + ", Lina " + oF.GenerationOf("lina")
chk("a generation is one more than the deepest parent's", oF.GenerationOf("ali") = 1 and oF.GenerationOf("sami") = 2 and oF.GenerationOf("lina") = 3)
? "   Lina's parents: " + idsText(oF.ParentsOf("lina"))
chk("a union of one partner is a parent raising a child alone", len(oF.ParentsOf("lina")) = 1 and inList("leila", oF.ParentsOf("lina")))

? ""
? "-- Scene 2: five rules about a family, and a sound one passes them --"
? "   no_one_is_own_ancestor, union_has_two_partners, child_of_one_union,"
? "   parents_are_older, partners_are_not_kin"
aF1 = oF.GovernanceFindings()
say(aF1)
chk("the three generations draw one WARNING and no error: the union with one partner is a single parent, if that is meant",
    len(aF1) = 1 and "" + aF1[1][:rule] = "union_has_two_partners" and "" + aF1[1][:severity] = "warning")

? ""
? "-- Scene 3: the witness -- a union of three, a child of two unions, a child older than a parent --"
oW = StzFamilySceneWitness(OPT)
aW = oW.GovernanceFindings()
say(aW)
chk("the union of three is caught", hits(aW, "union_has_two_partners") = 1)
chk("the child born of two unions is named", hits(aW, "child_of_one_union") = 1 and has(aW, "Gus"))
chk("the child older than a parent is named with the years", hits(aW, "parents_are_older") >= 1 and has(aW, "Dana"))
chk("the note is left alone", NOT has(aW, "draft"))

? ""
? "-- Scene 4: kin joined, and a person born of their own grandchild -- each on its own --"
oK = StzFamilySceneKin(OPT)
aK = oK.GovernanceFindings()
say(aK)
chk("a father married to his own daughter is caught", hits(aK, "partners_are_not_kin") = 1)
oC = StzFamilySceneCycle(OPT)
aC = oC.GovernanceFindings()
say(aC)
chk("a person who is their own ancestor is caught -- and the walk that finds it terminates",
    hits(aC, "no_one_is_own_ancestor") >= 1)

? ""
? "-- Scene 5: the pictures --"
oF.LastCanvas().ToPNG("guide_familytree.png")
oW.LastCanvas().ToPNG("guide_familytree_witness.png")
? "   wrote guide_familytree.png and guide_familytree_witness.png"

? ""
? "== " + nPass + " passed, " + nFail + " failed =="

#---------------------------------------------------------------------------

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func hits aF, cRule
	_n_ = 0
	for _i_ = 1 to len(aF)
		if StzLower("" + aF[_i_][:rule]) = StzLower(cRule)  _n_++  ok
	next
	return _n_

func has aF, cText
	for _i_ = 1 to len(aF)
		if StzFindFirst(cText, "" + aF[_i_][:message]) > 0  return 1  ok
	next
	return 0

func say aF
	for _i_ = 1 to len(aF)
		? "     " + aF[_i_][:rule] + " -- " + aF[_i_][:message]
	next

func inList cId, aIds
	for _i_ = 1 to len(aIds)
		if StzLower("" + aIds[_i_]) = StzLower("" + cId)  return 1  ok
	next
	return 0

func idsText aIds
	_c_ = ""
	for _i_ = 1 to len(aIds)
		if _i_ > 1  _c_ += ", "  ok
		_c_ += "" + aIds[_i_]
	next
	return _c_
