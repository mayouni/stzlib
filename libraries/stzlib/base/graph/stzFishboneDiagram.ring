#=====================================================================#
#  STZFISHBONEDIAGRAM -- DN20: a fishbone is an effect, its categories #
#  of cause, and the causes on them; every position a datum            #
#=====================================================================#
/*
	ISHIKAWA'S DIAGRAM. One effect at the head, a spine running into it,
	a bone for each category of cause leaning toward the head from above
	and below by turns, and on each bone a rib for every cause, its name
	at the rib's free end. Nothing in it is solved: a bone's length
	follows from how many causes it carries, a bone's place on the spine
	from how wide its neighbours are, and every pixel from those numbers
	by arithmetic. The solver reports "nothing to lay out", and the
	picture is still a mathematical diagram -- it carries marks, sits in a
	storyboard, is judged by the one gate and renders through Rendition()
	like everything else. The Gantt and the timeline are the precedent.

	WHAT A FISHBONE IS HERE:

	    DOMAIN     Effect, the head; Spine; Category, a bone; Cause, a rib
	               on a bone. Up(Category) says which side of the spine a
	               bone leans from.

	    SUBSTANCE  built from the effect's name and a list of categories
	               -- [ name, [ cause, cause, ... ] ] each. The builder
	               gives every bone a length that seats its ribs a name's
	               height apart, measures every name, spaces the bones so
	               that two bones on one side never overlap in what they
	               carry, leans them at sixty degrees toward the head, and
	               puts every number on its object as data.

	    STYLE      the spine as one line with a head into the effect's
	               box; a bone as a line with a head at the spine; a rib as
	               a short level line off its bone with the cause's name at
	               its free end; a category's name past its bone's end.

	WHAT THE DOMAIN OWES THE GATE -- the mistakes people make in a cause
	analysis, and none of them is visible in a drawing that draws what it
	is given:

	    every_bone_carries_a_cause     a category with nothing under it
	                                   is where the analysis stopped
	    a_cause_is_named_once          one cause listed under two
	                                   categories is one cause, not two
	    the_effect_is_not_its_own_cause  the effect written among the
	                                   causes explains nothing

	Each names things by the names the author gave them, and each
	registers itself into the math governance from this file.

	WHAT IS SAID PLAINLY: causes have no sub-causes here -- a rib carries
	a name and nothing hangs off a rib; the six Ms are a convention the
	author may follow and this domain does not impose; weights, votes and
	the "five whys" are not here.
*/

StzRegisterMathRuleSet("fishbone", StzFishboneRuleSet())

#---------------------------------------------------------------------#
#  THE DOMAIN                                                          #
#---------------------------------------------------------------------#

func StzFishboneDomain()
	_o_ = new stzMathDomain("fishbone")
	_o_.AddType("Effect")
	_o_.AddType("Spine")
	_o_.AddType("Category")
	_o_.AddType("Cause")
	_o_.AddPredicate("Up", [ "Category" ])
	# A FAULT IS DRAWN, NOT HIDDEN: an empty bone in the colour of a
	# fault; a cause listed twice, and the effect among the causes, named
	# in it. The rules judge from the names; the gate holds the marks.
	_o_.AddPredicate("Empty", [ "Category" ])
	_o_.AddPredicate("Twice", [ "Cause" ])
	_o_.AddPredicate("Circular", [ "Cause" ])
	return _o_

# the geometry's constants: the bones lean at sixty degrees toward the
# head, a rib is this long, a name stands this far from what it names
func StzFishboneAngle()
	return 60

func StzFishboneRibLength()
	return 26

# THE ONE PLACE THE TYPE SIZE IS WRITTEN. The builder MEASURES a label to
# space the picture and the style DRAWS it, and until 2026-09-12 each
# carried its own number. Raising the type found them instantly: the
# builder went on spacing names as if they were 11 points while the style
# drew them at 17, so every name overlapped its neighbour by the
# difference. Both read these now, and a size can no longer drift from the
# thing it measures.
func StzFishboneCauseSize()
	return 18

func StzFishboneCategorySize()
	return 20

#---------------------------------------------------------------------#
#  THE SUBSTANCE, FROM THE EFFECT AND ITS CATEGORIES                   #
#---------------------------------------------------------------------#

# pcEffect: the effect's name. paCategories: [ name, [ cause, ... ] ]
# each, in the order they stand along the spine from the tail. Objects
# are h (the effect), s (the spine), c1..cN and u1..uM; a thing's LABEL
# is the name given.
func StzFishboneFromCauses(pcEffect, paCategories)
	return StzFishboneFromCausesXT(NULL, pcEffect, paCategories)

func StzFishboneFromCausesXT(poFont, pcEffect, paCategories)
	_oS_ = new stzMathSubstance(StzFishboneDomain())
	_cEff_ = ring_trim("" + pcEffect)
	if _cEff_ = ""
		stzraise("StzFishboneFromCauses: a fishbone needs an effect to explain.")
	ok
	_nC_ = len(paCategories)
	if _nC_ = 0
		stzraise("StzFishboneFromCauses: a fishbone needs at least one category of cause.")
	ok
	_nSin_ = sin(StzFishboneAngle() * 3.14159265 / 180)
	_nCos_ = cos(StzFishboneAngle() * 3.14159265 / 180)
	_nRib_ = StzFishboneRibLength()
	_nRow_ = StzFishboneCauseSize() * 1.35 + 8       # a name's height and air

	# EVERY BONE IS MEASURED FIRST: its length seats its ribs a row apart,
	# and its width is what it carries -- the bone's own reach along the
	# spine, a rib, and the widest name at a rib's end, or half the
	# category's name past the bone's end, whichever is wider
	_anLen_ = []
	_anWide_ = []
	_nWide_ = 0
	for _i_ = 1 to _nC_
		_a_ = paCategories[_i_]
		if len(_a_) < 1 or ring_trim("" + _a_[1]) = ""
			stzraise("StzFishboneFromCauses: category " + _i_ + " needs a name.")
		ok
		_aCz_ = []
		if len(_a_) >= 2 and isList(_a_[2])  _aCz_ = _a_[2]  ok
		_nK_ = len(_aCz_)
		_nL_ = (_nK_ + 1) * _nRow_ / _nSin_
		if _nL_ < 96  _nL_ = 96  ok
		_anLen_ + _nL_
		_nMaxN_ = 0
		for _j_ = 1 to _nK_
			_nNw_ = _FbWidth(poFont, "" + _aCz_[_j_], StzFishboneCauseSize())
			if _nNw_ > _nMaxN_  _nMaxN_ = _nNw_  ok
		next
		_nW1_ = _nL_ * _nCos_ + _nRib_ + 6 + _nMaxN_
		_nW2_ = _nL_ * _nCos_ + _FbWidth(poFont, "" + _a_[1], StzFishboneCategorySize()) / 2
		_nW_ = _nW1_
		if _nW2_ > _nW_  _nW_ = _nW2_  ok
		_anWide_ + _nW_
		if _nW_ > _nWide_  _nWide_ = _nW_  ok
	next

	# THE BONES ARE SPACED SO THAT TWO ON ONE SIDE NEVER MEET. Bones
	# alternate sides, so a bone's neighbour on its own side is two
	# places along; the pitch is half the widest carry and some air, and
	# the first bone stands its own width from the tail.
	_nPitch_ = _nWide_ / 2 + 18
	if _nPitch_ < 110  _nPitch_ = 110  ok
	_nTail_ = 30
	_nX1_ = _nTail_ + _nWide_ + 4
	_nUp_ = 0
	_nDown_ = 0
	for _i_ = 1 to _nC_
		_nReach_ = _anLen_[_i_] * _nSin_ + StzFishboneCategorySize() * 1.35 + 22
		if _i_ % 2 = 1
			if _nReach_ > _nUp_  _nUp_ = _nReach_  ok
		else
			if _nReach_ > _nDown_  _nDown_ = _nReach_  ok
		ok
	next
	if _nDown_ < 40  _nDown_ = 40  ok
	_nMid_ = 16 + _nUp_
	_nH_ = _nMid_ + _nDown_ + 16

	# the head: the effect's name in a box the spine runs into
	_nHw_ = _FbWidth(poFont, _cEff_, StzFishboneCategorySize()) + 28
	_nHx0_ = _nX1_ + (_nC_ - 1) * _nPitch_ + _nPitch_ / 2 + 12
	_nW_ = _nHx0_ + _nHw_ + 20
	_oS_.Declare("Effect", "h")
	_oS_.Label("h", _cEff_)
	_oS_.SetData("h", "x", _nHx0_ + _nHw_ / 2)
	_oS_.SetData("h", "y", _nMid_)
	_oS_.SetData("h", "w", _nHw_)
	_oS_.SetData("h", "hh", 60)
	_oS_.SetData("h", "x0", _nHx0_)
	_oS_.Declare("Spine", "s")
	_oS_.Label("s", "")
	_oS_.SetData("s", "x0", _nTail_)
	_oS_.SetData("s", "x1", _nHx0_ - 1)
	_oS_.SetData("s", "y", _nMid_)
	_oS_.SetData("s", "paperw", _nW_)
	_oS_.SetData("s", "paperh", _nH_)

	# the bones and their ribs
	_nU_ = 0
	for _i_ = 1 to _nC_
		_a_ = paCategories[_i_]
		_aCz_ = []
		if len(_a_) >= 2 and isList(_a_[2])  _aCz_ = _a_[2]  ok
		_nK_ = len(_aCz_)
		_nL_ = _anLen_[_i_]
		_bUp_ = (_i_ % 2 = 1)
		_nSg_ = 1
		if _bUp_  _nSg_ = -1  ok
		_nSx_ = _nX1_ + (_i_ - 1) * _nPitch_
		_nEx_ = _nSx_ - _nL_ * _nCos_
		_nEy_ = _nMid_ + _nSg_ * _nL_ * _nSin_
		_oS_.Declare("Category", "c" + _i_)
		_oS_.Label("c" + _i_, "" + _a_[1])
		if _bUp_  _oS_.Assert("Up", [ "c" + _i_ ])  ok
		_oS_.SetData("c" + _i_, "sx", _nSx_)
		_oS_.SetData("c" + _i_, "sy", _nMid_)
		_oS_.SetData("c" + _i_, "ex", _nEx_)
		_oS_.SetData("c" + _i_, "ey", _nEy_)
		_oS_.SetData("c" + _i_, "len", _nL_)
		_oS_.SetData("c" + _i_, "causes", _nK_)
		_oS_.SetData("c" + _i_, "nx", _nEx_)
		_oS_.SetData("c" + _i_, "ny", _nEy_ + _nSg_ * (StzFishboneCategorySize() * 0.7 + 8))
		if _nK_ = 0  _oS_.Assert("Empty", [ "c" + _i_ ])  ok
		# the ribs: evenly along the bone, the first cause outermost, each
		# a level line off the bone toward the tail with its name at the end
		for _j_ = 1 to _nK_
			_nU_++
			_cN_ = "" + _aCz_[_j_]
			_nS_ = _nL_ * (_nK_ + 1 - _j_) / (_nK_ + 1)
			_nPx_ = _nSx_ - _nS_ * _nCos_
			_nPy_ = _nMid_ + _nSg_ * _nS_ * _nSin_
			_nNw_ = _FbWidth(poFont, _cN_, StzFishboneCauseSize())
			_oS_.Declare("Cause", "u" + _nU_)
			_oS_.Label("u" + _nU_, _cN_)
			_oS_.SetData("u" + _nU_, "cat", _i_)
			_oS_.SetData("u" + _nU_, "rank", _j_)
			_oS_.SetData("u" + _nU_, "px", _nPx_)
			_oS_.SetData("u" + _nU_, "py", _nPy_)
			_oS_.SetData("u" + _nU_, "qx", _nPx_ - _nRib_)
			_oS_.SetData("u" + _nU_, "nx", _nPx_ - _nRib_ - 5 - _nNw_ / 2)
			_oS_.SetData("u" + _nU_, "nw", _nNw_)
			if StzLower(ring_trim(_cN_)) = StzLower(_cEff_)
				_oS_.Assert("Circular", [ "u" + _nU_ ])
			ok
		next
	next

	# a cause listed under two categories is marked on every listing
	_ac_ = _oS_.ObjectsOfType("Cause")
	for _i_ = 1 to len(_ac_)
		for _j_ = 1 to len(_ac_)
			if _i_ = _j_  loop  ok
			if _oS_.DataOf(_ac_[_i_], "cat") = _oS_.DataOf(_ac_[_j_], "cat")  loop  ok
			if StzLower(ring_trim(_oS_.LabelOf(_ac_[_i_]))) = StzLower(ring_trim(_oS_.LabelOf(_ac_[_j_])))
				_oS_.Assert("Twice", [ _ac_[_i_] ])
				exit
			ok
		next
	next
	return _oS_

# a name's drawn width and a little air, by the font when there is one
func _FbWidth(poFont, pcText, pnSize)
	if isObject(poFont)  return poFont.WidthOf(pcText, pnSize) + 6  ok
	return StzLen(pcText) * pnSize * 0.55 + 6

func StzFishbonePaperOf(poSubstance)
	return [ poSubstance.DataOf("s", "paperw"), poSubstance.DataOf("s", "paperh") ]

#---------------------------------------------------------------------#
#  THE STYLE -- no constraint, no unknown, every position a datum      #
#---------------------------------------------------------------------#

func StzFishboneStyle(pnW, pnH)
	_o_ = new stzMathStyle()
	_o_.SetCanvas(pnW, pnH)
	_o_.SetMargin(10)
	# the spine runs from the tail into the head's box, with a head
	_o_.ForAll("Spine s", [
		[ :shape, "s.icon", :line, [ :x1 = "s.x0", :y1 = "s.y", :x2 = "s.x1", :y2 = "s.y",
		                             :stroke = "neutral", :strokeWidth = 2, :arrow = "end" ] ] ])
	# the effect in its box, the box painted after the spine's head
	_o_.ForAll("Effect h", [
		[ :shape, "h.box", :rect, [ :cx = "h.x", :cy = "h.y", :w = "h.w", :h = "h.hh",
		                            :fill = "primary", :stroke = "background", :strokeWidth = 1 ] ],
		[ :shape, "h.text", :text, [ :cx = "h.x", :cy = "h.y", :size = StzFishboneCategorySize(),
		                             :fill = [ :on, "h.box" ] ] ],
		[ :layer, "h.text", :above, "h.box" ] ])
	# a bone leans from its end to the spine, with a head at the spine;
	# its category's name stands past its end
	_o_.ForAll("Category c", [
		[ :shape, "c.icon", :line, [ :x1 = "c.ex", :y1 = "c.ey", :x2 = "c.sx", :y2 = "c.sy",
		                             :stroke = "neutral", :strokeWidth = 1.5, :arrow = "end" ] ],
		[ :shape, "c.text", :text, [ :cx = "c.nx", :cy = "c.ny", :size = StzFishboneCauseSize(),
		                             :fill = [ :on, "paper" ] ] ] ])
	# a rib is a level line off its bone toward the tail, and its cause's
	# name stands at its free end
	_o_.ForAll("Cause u", [
		[ :shape, "u.icon", :line, [ :x1 = "u.qx", :y1 = "u.py", :x2 = "u.px", :y2 = "u.py",
		                             :stroke = "neutral", :strokeWidth = 1 ] ],
		[ :shape, "u.text", :text, [ :cx = "u.nx", :cy = "u.py", :size = 18,
		                             :fill = [ :on, "paper" ] ] ] ])
	# A FAULT IS DRAWN: an empty bone in the colour of a fault; a cause
	# listed twice, and the effect among its own causes, named on it
	_o_.ForAllWhere("Category c", "Empty(c)", [
		[ :delete, "c.icon" ],
		[ :shape, "c.icon", :line, [ :x1 = "c.ex", :y1 = "c.ey", :x2 = "c.sx", :y2 = "c.sy",
		                             :stroke = "danger", :strokeWidth = 1.5, :arrow = "end" ] ] ])
	# ...ON A PLATE, not in a coloured word: the colour of a fault against
	# light paper is under the 3:1 the gate holds every name to, so the
	# name stands on a plate of that colour in whichever of black and
	# white reads on it -- the fault is seen and the name is read.
	_o_.ForAllWhere("Cause u", "Twice(u)", [
		[ :delete, "u.text" ],
		[ :shape, "u.plate", :rect, [ :cx = "u.nx", :cy = "u.py", :w = "u.nw", :h = 18,
		                              :fill = "danger", :stroke = "danger", :strokeWidth = 1 ] ],
		[ :shape, "u.text", :text, [ :cx = "u.nx", :cy = "u.py", :size = 18, :fill = [ :on, "u.plate" ] ] ],
		[ :layer, "u.text", :above, "u.plate" ] ])
	_o_.ForAllWhere("Cause u", "Circular(u)", [
		[ :delete, "u.text" ],
		[ :shape, "u.plate", :rect, [ :cx = "u.nx", :cy = "u.py", :w = "u.nw", :h = 18,
		                              :fill = "danger", :stroke = "danger", :strokeWidth = 1 ] ],
		[ :shape, "u.text", :text, [ :cx = "u.nx", :cy = "u.py", :size = 18, :fill = [ :on, "u.plate" ] ] ],
		[ :layer, "u.text", :above, "u.plate" ] ])
	return _o_

# the whole picture in one call
func StzFishboneDiagram(poFont, pcEffect, paCategories)
	_oS_ = StzFishboneFromCausesXT(poFont, pcEffect, paCategories)
	_aP_ = StzFishbonePaperOf(_oS_)
	_o_ = new stzMathDiagram(StzFishboneDomain(), _oS_, StzFishboneStyle(_aP_[1], _aP_[2]))
	if isObject(poFont)  _o_.SetFont(poFont, 12)  ok
	return _o_

#---------------------------------------------------------------------#
#  THE RULES, INTO THE ONE GATE -- every one about the analysis        #
#---------------------------------------------------------------------#

func _FbIsFishbone(poDg)
	if NOT isObject(poDg)  return FALSE  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return FALSE  ok
	return StzLower("" + poDg.Substance().DomainQ().Name_()) = "fishbone"

func _FbScope(poDg, pcType, pcPrefix)
	_r_ = []
	if NOT _FbIsFishbone(poDg)  return _r_  ok
	_ac_ = poDg.Substance().ObjectsOfType(pcType)
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _FbCounter(poDg, pcPrefix)
	_r_ = []
	if NOT isObject(poDg) or _FbIsFishbone(poDg)  return _r_  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return _r_  ok
	_ac_ = poDg.Substance().ObjectNames()
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _FbName(poS, pcObj)
	_c_ = poS.LabelOf(pcObj)
	if _c_ = ""  _c_ = pcObj  ok
	return _c_

func StzFishboneRuleSet()
	_ao_ = []

	_o1_ = StzPlasticRule("every_bone_carries_a_cause")
	_o1_.SetClaim("no category is left without a cause under it")
	_o1_.SetOrder(56)
	_o1_.SetReads([ "substance" ])
	_o1_.SetScope(func(oDg) { return _FbScope(oDg, "Category", "bone:") })
	_o1_.SetCounter(func(oDg) { return _FbCounter(oDg, "bone:") })
	_o1_.SetClaimCheck(func(oDg, cSub) {
		_cC_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		if _oS_.DataOf(_cC_, "causes") = 0
			return [ FALSE, "'" + _FbName(_oS_, _cC_) + "' carries no cause -- the analysis stopped at the bone" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o1_

	_o2_ = StzPlasticRule("a_cause_is_named_once")
	_o2_.SetClaim("no cause is listed under two categories")
	_o2_.SetOrder(57)
	_o2_.SetReads([ "substance" ])
	_o2_.SetScope(func(oDg) { return _FbScope(oDg, "Cause", "cause:") })
	_o2_.SetCounter(func(oDg) { return _FbCounter(oDg, "cause:") })
	_o2_.SetClaimCheck(func(oDg, cSub) {
		_cU_ = StzStringSection(cSub, 7, len(cSub))
		_oS_ = oDg.Substance()
		_cN_ = StzLower(ring_trim(_oS_.LabelOf(_cU_)))
		_nCat_ = _oS_.DataOf(_cU_, "cat")
		_ac_ = _oS_.ObjectsOfType("Cause")
		for _i_ = 1 to len(_ac_)
			if _ac_[_i_] = _cU_  loop  ok
			if _oS_.DataOf(_ac_[_i_], "cat") = _nCat_  loop  ok
			if StzLower(ring_trim(_oS_.LabelOf(_ac_[_i_]))) = _cN_
				return [ FALSE, "'" + _FbName(_oS_, _cU_) + "' is listed under '" +
					_FbName(_oS_, "c" + _nCat_) + "' and again under '" +
					_FbName(_oS_, "c" + _oS_.DataOf(_ac_[_i_], "cat")) + "' -- one cause, named twice" ]
			ok
		next
		return [ TRUE, "" ]
	})
	_ao_ + _o2_

	_o3_ = StzPlasticRule("the_effect_is_not_its_own_cause")
	_o3_.SetClaim("the effect is not written among its causes")
	_o3_.SetOrder(58)
	_o3_.SetReads([ "substance" ])
	_o3_.SetScope(func(oDg) { return _FbScope(oDg, "Cause", "cause:") })
	_o3_.SetCounter(func(oDg) { return _FbCounter(oDg, "cause:") })
	_o3_.SetClaimCheck(func(oDg, cSub) {
		_cU_ = StzStringSection(cSub, 7, len(cSub))
		_oS_ = oDg.Substance()
		if StzLower(ring_trim(_oS_.LabelOf(_cU_))) = StzLower(ring_trim(_oS_.LabelOf("h")))
			return [ FALSE, "'" + _FbName(_oS_, _cU_) + "' under '" +
				_FbName(_oS_, "c" + _oS_.DataOf(_cU_, "cat")) +
				"' is the effect itself -- it explains nothing" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o3_

	return _ao_
