# AN ENTITY-RELATIONSHIP DIAGRAM, NARRATED -- DN15 of the graph plane
# (SOFTANZA_GRAPH_PLANE_PLAN.md).
#
# A schema is entities with keys and attributes, and relations between
# them with a cardinality at each end. The picture is a notation over the
# graph plane: crow's feet for the many end, a bar for the mandatory one,
# a circle for the optional, a junction for a many-to-many resolved. Four
# rules say what a schema may not do -- an entity with no key, a foreign
# key to an entity nobody drew, a one-to-many with no key behind it, a
# participation mark that contradicts the column's nullability.
#
# This guide RUNS: the schema is read back through its own queries, and
# every rule is asked through the diagram's own governance.
#
#   Run:  ring er_narrated.ring

load "../../stzBase.ring"
load "gg_er_scenes.ring"

if NOT StzGraphicsDevice()
	? "(no device -- a notation picture is rendered as it is built, so this guide is UNJUDGED here)"
	return
ok

nPass = 0
nFail = 0
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
OPT = [ :Font = FONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]

? "-- Scene 1: a shop -- customers, orders, lines, products, tags --"
oE = StzErScene01(OPT)
? "   " + len(oE.Entities()) + " entities (one a junction), " + len(oE.Relations()) + " relations"
chk("six entities and five relations", len(oE.Entities()) = 6 and len(oE.Relations()) = 5)
? "   the many-to-many between Product and Tag is drawn RESOLVED: two one-to-many into ProductTag,"
? "   which holds a key referencing each side -- the way a schema draws it"

? ""
? "-- Scene 2: four rules about a schema, and a sound one passes them --"
aF = oE.GovernanceFindings()
? "   entity_has_key, foreign_key_resolves, relation_backed_by_key, participation_matches_nullability"
say(aF)
chk("the shop has nothing wrong with it", len(aF) = 0 and oE.GovernanceIsSound())

? ""
? "-- Scene 3: the same shop with four things wrong, and a note that owes nothing --"
? "   Order has no key; a foreign key points at 'custmer'; customer-order has no"
? "   key behind it; product-tag is many-to-many with no junction. And a note,"
? "   which is not an entity and owes no key -- the rules' boundary."
oW = StzErScene02(OPT)
aW = oW.GovernanceFindings()
say(aW)
chk("the entity with no key is named", hits(aW, "entity_has_key") >= 1 and has(aW, "Order"))
chk("the foreign key to nowhere is named with its target", hits(aW, "foreign_key_resolves") = 1 and has(aW, "custmer"))
chk("a relation with no key behind it is caught", hits(aW, "relation_backed_by_key") >= 1)
chk("the note is left alone -- no finding names it", NOT has(aW, "draft of"))
chk("and the schema is not sound", NOT oW.GovernanceIsSound())

? ""
? "-- Scene 4: participation held to the column --"
? "   an employee may have no department and the column allows it; a ticket may"
? "   have no assignee, says the mark, and the column does not; an invoice"
? "   always has an account, says the mark, and the column may be empty."
oP = StzErSceneParticipation(OPT)
aP = oP.GovernanceFindings()
say(aP)
chk("the two marks that contradict their columns are caught, and the one that agrees is not",
    hits(aP, "participation_matches_nullability") = 2 and has(aP, "Ticket") and has(aP, "Invoice") and NOT has(aP, "Employee"))

? ""
? "-- Scene 5: the pictures --"
oE.LastCanvas().ToPNG("guide_er.png")
oW.LastCanvas().ToPNG("guide_er_witness.png")
? "   wrote guide_er.png and guide_er_witness.png"

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
