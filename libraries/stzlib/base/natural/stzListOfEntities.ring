# THE WORLD (NATURAL_VISION step 3) -- the single shared entity registry.
# Everything that NAMES a thing feeds it, everything that WONDERS about a
# thing queries it:
#   - Naturally() named objects  ("call it basket")   -> StzKnow, automatic
#   - stzText.RegisterNamedEntities()  (NER)          -> StzKnow, explicit
#   - stzChainOfTruth's _@ entity hook                -> AddEntity (legacy)
#   - WhatIs("basket")                                -> [ "list" ]
# Declared HERE (the world IS a list of entities); stzChainOfTruth used to
# own it, which put the knowledge floor inside one legacy surface.
$oWorldEntities = new stzListOfEntities
$aStzSuppositions = []   # the HYPOTHETICAL overlay (see SupposeQ below)
$oStzWhatIsDoc = NULL   # lazy self-doc index for the WhatIs library fallback
$aStzRelations = []      # the world's EDGES: triples [ from, relation, to ]
$aStzRelationRules = []  # graph laws per relation: [ relation, :Unique | :Symmetric | :Transitive ]

func WorldEntities()
	return $oWorldEntities

	func @WorldEntities()
		return $oWorldEntities

# Idempotent world registration: the same (name, type) pair registers ONCE
# and silently -- unlike AddEntity, which raises on duplicates. Returns 1
# when the entity was new, 0 when it was already known. Naturally() calls
# this on every code regeneration, so silence on repeats is the contract.

func StzKnow(pcName, pcType)
	return StzKnowXT(pcName, pcType, [])

	func @StzKnow(pcName, pcType)
		return StzKnowXT(pcName, pcType, [])

func StzKnowXT(pcName, pcType, paProps)
	if NOT ( isString(pcName) and isString(pcType) )
		return 0
	ok
	_cName_ = StzLower(trim(pcName))
	_cType_ = StzLower(trim(pcType))
	if _cName_ = ""
		return 0
	ok
	if _cType_ = ""
		_cType_ = "undefined"
	ok
	# exact (name, type) PAIR check -- AddEntity's own guard tests name and
	# type independently, which both over-fires and raises; the world wants
	# quiet idempotence
	_aAll_ = $oWorldEntities.Entities()
	_nAll_ = len(_aAll_)
	for _i_ = 1 to _nAll_
		if _aAll_[_i_][:name] = _cName_ and _aAll_[_i_][:type] = _cType_
			return 0
		ok
	next
	_aEnt_ = [ [ "name", _cName_ ], [ "type", _cType_ ] ]
	if isList(paProps)
		_nP_ = len(paProps)
		for _i_ = 1 to _nP_
			if isList(paProps[_i_]) and len(paProps[_i_]) = 2 and isString(paProps[_i_][1])
				_aEnt_ + [ StzLower(paProps[_i_][1]), paProps[_i_][2] ]
			ok
		next
	ok
	_oEnt_ = new stzEntity(_aEnt_)
	# AppendEntity bypasses AddEntity's raise-on-duplicate; the PAIR check
	# above already guaranteed uniqueness
	$oWorldEntities.AppendEntity(_oEnt_.Content())
	# R1 dual-write: the default knowledge graph grows alongside the world
	_StzDKGAddFactOnce(_cName_, "is-a", _cType_)
	return 1

	func @StzKnowXT(pcName, pcType, paProps)
		return StzKnowXT(pcName, pcType, paProps)

# THE HYPOTHETICAL CONTEXT (the SupposeQ frontier): an assumption is an
# OVERLAY on the world, never a commitment -- the world stays clean while
# the discourse reasons "as if". The reasoning primitive of an agent:
#
#     SupposeQ("tomato").IsAQ(:Fruit)      # "Suppose tomato is a fruit"
#     ? WhatIs("tomato")                    #--> [ "fruit" ]  (while supposed)
#     ForgetSuppositions()                  # discard -- the world unchanged
#     CommitSuppositions()                  # ...or conclude: StzKnow each
#
# Suppose -> ask -> commit or forget: deterministic sandboxed reasoning.

func SupposeQ(pcName)
	return new stzSupposition(pcName)

func SuppositionsSoFar()
	return $aStzSuppositions

func ForgetSuppositions()
	$aStzSuppositions = []

func CommitSuppositions()
	_nSup_ = len($aStzSuppositions)
	for _iSup_ = 1 to _nSup_
		StzKnow($aStzSuppositions[_iSup_][1], $aStzSuppositions[_iSup_][2])
	next
	$aStzSuppositions = []
	return _nSup_

# WhatIs: the world query from the oldest Softanza vision --
#   ? WhatIs("apple")  #--> [ "fruit", "company" ]
# Returns the list of TYPES the world knows for that name; [] when the
# world has never heard of it.

# WhatIs -- ONE interrogative family, TWO knowledge sources: the entity
# WORLD answers first (types, suppositions overlay included); when the
# world is silent, the LIBRARY answers through Ask()'s retrieval
# pipeline (self-doc corpus), accepting only NAME-EXACT method hits --
# deterministic, no guessing.
func WhatIs(pcName)
	if NOT isString(pcName)
		return []
	ok
	_cName_ = StzLower(trim(pcName))
	_aOut_ = _StzWorldTypesOf(_cName_)
	# the world's EDGES answer too: "capital-of france"
	_aRel_ = RelationsOf(_cName_)
	_nRel_ = len(_aRel_)
	for _i_ = 1 to _nRel_
		_aOut_ + (_aRel_[_i_][1] + " " + _aRel_[_i_][2])
	next
	if len(_aOut_) > 0
		return _aOut_
	ok
	# the world is silent -- ask the LIBRARY: a deterministic name-sites
	# sweep over the wide doc index, reporting EVERY class that defines
	# the method (grouped per distinct method name)
	_aSites_ = _StzWhatIsDocIndex()._NameSites(_cName_)
	_nS_ = len(_aSites_)
	if _nS_ = 0
		return []
	ok
	_aGrp_ = []   # [ methodName, [classes...], description ]
	for _i_ = 1 to _nS_
		_cMn_ = _aSites_[_i_][2]
		_bF_ = 0
		_nG_ = len(_aGrp_)
		for _j_ = 1 to _nG_
			if _aGrp_[_j_][1] = _cMn_
				if ring_find(_aGrp_[_j_][2], _aSites_[_i_][1]) = 0
					_aGrp_[_j_][2] + _aSites_[_i_][1]
				ok
				# keep the RICHEST description across the sites: a
				# real doc (own or inherited) beats a bare section
				# anchor from another class
				if isString(_aSites_[_i_][3]) and
				   len(_aSites_[_i_][3]) > len(_aGrp_[_j_][3])
					_aGrp_[_j_][3] = _aSites_[_i_][3]
				ok
				_bF_ = 1
				exit
			ok
		next
		if _bF_ = 0
			_cD_ = ""
			if isString(_aSites_[_i_][3])
				_cD_ = _aSites_[_i_][3]
			ok
			_aGrp_ + [ _cMn_, [ _aSites_[_i_][1] ], _cD_ ]
		ok
	next
	_nG_ = len(_aGrp_)
	for _i_ = 1 to _nG_
		_cCls_ = ""
		_nC_ = len(_aGrp_[_i_][2])
		for _j_ = 1 to _nC_
			if _j_ > 1
				_cCls_ += ", "
			ok
			_cCls_ += _aGrp_[_i_][2][_j_]
		next
		# readable block: bullet line, description indented on its
		# own line, a blank line after -- printing the list breathes
		_cAns_ = "- the method " + _aGrp_[_i_][1] + " (on " + _cCls_ + ")"
		if _aGrp_[_i_][3] != ""
			_cAns_ += nl + "  " + _aGrp_[_i_][3]
		ok
		if _i_ < _nG_
			_cAns_ += nl   # separator BETWEEN blocks only, none trailing
		ok
		_aOut_ + _cAns_
	next
	return _aOut_

	func @WhatIs(pcName)
		return WhatIs(pcName)

# --- GRAPH-GOVERNED RELATIONS -----------------------------------------
# The entity world grows EDGES: named relations between entities,
# governed by deterministic graph LAWS declared per relation:
#   :Unique     -- a given FROM bears the relation ONCE (a country has
#                  one capital); a second declaration is REFUSED with Why
#   :Symmetric  -- knowing a-R-b auto-knows b-R-a (married-to)
#   :Transitive -- AreRelated() walks the chain (part-of: piston ->
#                  engine -> car), narrating the path in Why()
# Deterministic, hence CERTAIN in the evidential register.

func StzKnowRelation(pcFrom, pcRel, pcTo)
	if NOT (isString(pcFrom) and isString(pcRel) and isString(pcTo))
		return 0
	ok
	_cF_ = StzLower(trim(pcFrom))
	_cR_ = StzLower(trim(pcRel))
	_cT_ = StzLower(trim(pcTo))
	if _cF_ = "" or _cR_ = "" or _cT_ = ""
		return 0
	ok
	$nStzLastCertainty = 1
	# the :Unique law: one FROM, one edge of this relation
	if _StzRelationHasRule(_cR_, :Unique)
		_n_ = len($aStzRelations)
		for _i_ = 1 to _n_
			if $aStzRelations[_i_][1] = _cF_ and $aStzRelations[_i_][2] = _cR_ and
			   $aStzRelations[_i_][3] != _cT_
				$cStzLastWhyB = "no: '" + _cF_ + "' already bears '" + _cR_ +
					"' (to '" + $aStzRelations[_i_][3] + "'; the relation is :Unique)"
				return 0
			ok
		next
	ok
	_StzAddRelationTriple(_cF_, _cR_, _cT_)
	if _StzRelationHasRule(_cR_, :Symmetric)
		_StzAddRelationTriple(_cT_, _cR_, _cF_)
	ok
	$cStzLastWhyB = "yes: '" + _cF_ + "' " + _cR_ + " '" + _cT_ + "'"
	return 1

	func @StzKnowRelation(pcFrom, pcRel, pcTo)
		return StzKnowRelation(pcFrom, pcRel, pcTo)

func _StzAddRelationTriple(pcF, pcR, pcT)
	_n_ = len($aStzRelations)
	for _i_ = 1 to _n_
		if $aStzRelations[_i_][1] = pcF and $aStzRelations[_i_][2] = pcR and
		   $aStzRelations[_i_][3] = pcT
			return
		ok
	next
	$aStzRelations + [ pcF, pcR, pcT ]
	# R1 dual-write: the default knowledge graph records the same edge
	_StzDKGAddFactOnce(pcF, pcR, pcT)

# Declare a graph LAW for a relation (:Unique / :Symmetric / :Transitive).
# :Symmetric applies RETROACTIVELY (existing edges gain their reverses).
func StzConstrainRelation(pcRel, pcRule)
	_cR_ = StzLower(trim(pcRel))
	_cL_ = StzLower(trim("" + pcRule))
	if _cR_ = "" or _cL_ = ""
		return 0
	ok
	if NOT _StzRelationHasRule(_cR_, _cL_)
		$aStzRelationRules + [ _cR_, _cL_ ]
	ok
	# R1: the law also lives on the default knowledge graph -- recorded
	# in its ontology and, where derivational, armed as a stzGraphRule
	StzKGConstrainRelation(_cR_, _cL_)
	if _cL_ = "symmetric"
		_n_ = len($aStzRelations)
		for _i_ = 1 to _n_
			if $aStzRelations[_i_][2] = _cR_
				_StzAddRelationTriple($aStzRelations[_i_][3], _cR_, $aStzRelations[_i_][1])
			ok
		next
	ok
	return 1

func _StzRelationHasRule(pcRel, pcRule)
	_cL_ = StzLower(trim("" + pcRule))
	_n_ = len($aStzRelationRules)
	for _i_ = 1 to _n_
		if $aStzRelationRules[_i_][1] = pcRel and $aStzRelationRules[_i_][2] = _cL_
			return 1
		ok
	next
	return 0

# The outgoing edges of an entity: [ [relation, to], ... ]
func RelationsOf(pcName)
	_aOut_ = []
	if NOT isString(pcName)
		return _aOut_
	ok
	_cN_ = StzLower(trim(pcName))
	_n_ = len($aStzRelations)
	for _i_ = 1 to _n_
		if $aStzRelations[_i_][1] = _cN_
			_aOut_ + [ $aStzRelations[_i_][2], $aStzRelations[_i_][3] ]
		ok
	next
	return _aOut_

	func @RelationsOf(pcName)
		return RelationsOf(pcName)

# The relation linking a to b ("" when none). For a :Transitive relation
# the CHAIN counts too -- the path is narrated in Why().
func AreRelated(pcA, pcB)
	if NOT (isString(pcA) and isString(pcB))
		return ""
	ok
	_cA_ = StzLower(trim(pcA))
	_cB_ = StzLower(trim(pcB))
	$nStzLastCertainty = 1
	_n_ = len($aStzRelations)
	# direct edge first
	for _i_ = 1 to _n_
		if $aStzRelations[_i_][1] = _cA_ and $aStzRelations[_i_][3] = _cB_
			$cStzLastWhyB = "yes: '" + _cA_ + "' " + $aStzRelations[_i_][2] +
				" '" + _cB_ + "'"
			return $aStzRelations[_i_][2]
		ok
	next
	# transitive chains, one relation at a time
	_nR_ = len($aStzRelationRules)
	for _i_ = 1 to _nR_
		if $aStzRelationRules[_i_][2] = "transitive"
			_cPath_ = _StzRelationChain($aStzRelationRules[_i_][1], _cA_, _cB_)
			if _cPath_ != ""
				$cStzLastWhyB = "yes: " + _cPath_
				return $aStzRelationRules[_i_][1]
			ok
		ok
	next
	$cStzLastWhyB = "no: nothing relates '" + _cA_ + "' to '" + _cB_ + "'"
	return ""

	func @AreRelated(pcA, pcB)
		return AreRelated(pcA, pcB)

# Walk pcRel edges from pcA toward pcB (depth-capped); the narrated path
# ("piston part-of engine part-of car") or "".
func _StzRelationChain(pcRel, pcA, pcB)
	_aFront_ = [ [ pcA, pcA ] ]   # [ node, path-so-far ]
	_aSeen_ = [ pcA ]
	_nDepth_ = 0
	while len(_aFront_) > 0 and _nDepth_ < 16
		_nDepth_++
		_aNext_ = []
		_nF_ = len(_aFront_)
		for _f_ = 1 to _nF_
			_cNode_ = _aFront_[_f_][1]
			_cPath_ = _aFront_[_f_][2]
			_n_ = len($aStzRelations)
			for _i_ = 1 to _n_
				if $aStzRelations[_i_][1] = _cNode_ and $aStzRelations[_i_][2] = pcRel
					_cTo_ = $aStzRelations[_i_][3]
					_cNewPath_ = _cPath_ + " " + pcRel + " " + _cTo_
					if _cTo_ = pcB
						return _cNewPath_
					ok
					if ring_find(_aSeen_, _cTo_) = 0
						_aSeen_ + _cTo_
						_aNext_ + [ _cTo_, _cNewPath_ ]
					ok
				ok
			next
		next
		_aFront_ = _aNext_
	end
	return ""

func ForgetRelations()
	$aStzRelations = []
	$aStzRelationRules = []
	# R1: keep the default knowledge graph in step (entities survive,
	# relation edges and laws go)
	_StzDKGRebuildFromWorld()

# the raw world lookup (entities + the supposition overlay) -- the piece
# the Ask() world door calls, so the two doors can meet without recursion
func _StzWorldTypesOf(pcName)
	if NOT isString(pcName)
		return []
	ok
	_cName_ = StzLower(trim(pcName))
	_aOut_ = []
	_aAll_ = $oWorldEntities.Entities()
	_nAll_ = len(_aAll_)
	for _i_ = 1 to _nAll_
		if _aAll_[_i_][:name] = _cName_ and ring_find(_aOut_, _aAll_[_i_][:type]) = 0
			_aOut_ + _aAll_[_i_][:type]
		ok
	next
	# the hypothetical overlay answers too, while it stands
	_nSup_ = len($aStzSuppositions)
	for _i_ = 1 to _nSup_
		if $aStzSuppositions[_i_][1] = _cName_ and
		   ring_find(_aOut_, $aStzSuppositions[_i_][2]) = 0
			_aOut_ + $aStzSuppositions[_i_][2]
		ok
	next
	return _aOut_

# lazy cross-class doc index for the WhatIs library door. WIDE on
# purpose: WhatIs answers about the LIBRARY, so it sees the main domain
# classes -- unlike Ask()'s lean default set (tuned for the neural
# index). Built once on first use (~4s), instant after.
func _StzWhatIsDocIndex()
	if isObject($oStzWhatIsDoc)
		return $oStzWhatIsDoc
	ok
	$oStzWhatIsDoc = StzLibDocQ([ "stzString", "stzList", "stzNumber",
		"stzChar", "stzText", "stzListOfTexts", "stzListOfStrings",
		"stzListOfNumbers", "stzListOfLists", "stzHashList", "stzTable" ])
	return $oStzWhatIsDoc

# THE WORLD DOOR of Ask(): a "what is X / who is X" question consults
# the entity world. Returns [] or [ name, sentence ].
func _StzWorldDoorEntry(pcQuestion)
	if NOT isString(pcQuestion)
		return []
	ok
	_cQ_ = StzLower(ring_trim(pcQuestion))
	_cQ_ = ring_trim(StzReplace(_cQ_, "?", " "))
	_cN_ = ""
	if StzFindFirst("what is ", _cQ_) = 1
		_cN_ = ring_trim(right(_cQ_, len(_cQ_) - 8))
	but StzFindFirst("who is ", _cQ_) = 1
		_cN_ = ring_trim(right(_cQ_, len(_cQ_) - 7))
	ok
	if _cN_ = ""
		return []
	ok
	_aT_ = _StzWorldTypesOf(_cN_)
	_nT_ = len(_aT_)
	if _nT_ = 0
		return []
	ok
	_cS_ = _cN_ + " is " + _StzArticleFor(_aT_[1]) + " " + _aT_[1]
	for _i_ = 2 to _nT_
		_cS_ += " (and " + _StzArticleFor(_aT_[_i_]) + " " + _aT_[_i_] + ")"
	next
	return [ _cN_, _cS_ ]

# name-exact OR voice-sibling (the library's own form system: active
# Verb() / passive Verbed()) -- deterministic, no fuzzy guessing
func _StzNamesAreFormSiblings(pcA, pcB)
	if pcA = pcB
		return 1
	ok
	if pcA = pcB + "d" or pcA = pcB + "ed" or
	   pcB = pcA + "d" or pcB = pcA + "ed"
		return 1
	ok
	return 0

func _StzArticleFor(pcWord)
	if isString(pcWord) and pcWord != "" and
	   ring_find([ "a", "e", "i", "o", "u" ], StzLower(left(pcWord, 1))) > 0
		return "an"
	ok
	return "a"

func StzListOfEntitiesQ(paList)
	return new stzListOfEntities(paList)

# Error-message dispatcher used by stzListOfEntities.AddEntity*.
# Codes map to the same human-readable messages the original
# (max-tier) module exposed -- keep wording terse but identifiable.
func stzListOfEntitiesError(pcCode)
	switch pcCode
	on :CanNotAddThisEntityTwice
		return "Can't add the same entity twice to a stzListOfEntities."
	on :CanNotAddEntityWithoutName
		return "Can't add an entity without a :name key."
	on :CanNotAddNotAHashList
		return "Can't add a non-hashlist value as an entity."
	other
		return "Unknown stzListOfEntities error: " + pcCode
	off

func IsListOfEntities(paList)
	if CheckingParams()
		if NOT isList(paList)
			StzRaise("Incorrect param type!")
		ok
	ok

	_bResult_ = 1
	_nLen_ = len(paList)

	for i = 1 to _nLen_
		if NOT IsEntity(paList[i])
			_bResult_ = 0
			exit
		ok
	next i

	return _bResult_

	#< @FunctionAlternativeForms

	func @IsListOfEntities(paList)
		return IsListOfEntities(paList)

	func IsAListOfEntities(paList)
		return IsListOfEntities(paList)

	func @IsAListOfEntities(paList)
		return IsListOfEntities(paList)

	#>

class stzEntities from stzListOfEntities

class stzListOfEntities from stzList
	@aListOfEntities = []

	def init(paList)
		if isList(paList) and
		   ( Q(paList).IsEmpty() or Q(paList).IsListOfHashLists() )
			@aListOfEntities = paList
		else
			StzRaise("Can't create the stzListOfEntities object! You must provide a list of hashlists.")
		ok

	def Content()
		return @aListOfEntities

		def Value()
			return Content()

	def Copy()
		return new stzListOfEntities(This.Content())

	def ListOfEntities()
		return This.Content()

		def Entities()
			return This.ListOfEntities()

	def AddEntity(paEntity)
		if @IsHashList(paEntity)
			if HasKey(paEntity, :name)

				if This.ContainsName(paEntity[:name]) and
				   This.ContainsType(paEntity[:type])
					StzRaise(stzListOfEntitiesError(:CanNotAddThisEntityTwice))
				else
					paEntity[:name] = StzLower(paEntity[:name])
					paEntity[:type] = StzLower(paEntity[:type])
					@aListOfEntities + paEntity
				ok

			else
				StzRaise(stzListOfEntitiesError(:CanNotAddEntityWithoutName))
			ok
		else
			StzRaise(stzListOfEntitiesError(:CanNotAddNotAHashList))
		ok

		def AppendEntity(paEntity)
		@aListOfEntities + paEntity

	def AddEntities(paEntities)
			_nEntities1Len_ = len(paEntities)
			for _iLoopEntities1_ = 1 to _nEntities1Len_
				_aEntity_ = paEntities[_iLoopEntities1_]
				This.AddEntity(_aEntity_)
			next

	def EntitiesNames()
		_aResult_ = []
		_aThisEntities9_ = This.Entities()
		_nThisEntities9Len_ = len(_aThisEntities9_)
		for _iLoopThisEntities9_ = 1 to _nThisEntities9Len_
			_aEntity_ = _aThisEntities9_[_iLoopThisEntities9_]
			_aResult_ + _aEntity_[:name]
		next
		return _aResult_

		def Names()
			return This.EntitiesNames()

	def EntitiesTypes()
		_aResult_ = []
		_aThisEntities8_ = This.Entities()
		_nThisEntities8Len_ = len(_aThisEntities8_)
		for _iLoopThisEntities8_ = 1 to _nThisEntities8Len_
			_aEntity_ = _aThisEntities8_[_iLoopThisEntities8_]
			_aResult_ + _aEntity_[:type]
		next
		return _aResult_

		def Types()
			return This.EntitiesTypes()

	def UniqueTypes()
		# Was `StzListQ(...).Duplicates()` -- double bug:
		# (1) Duplicates() only exists in the monolithic archive,
		#     never ported to modular stzList -> R14 unreachable.
		# (2) Even if it existed, Duplicates would return the DUPED
		#     items, not the uniques -- inverted semantics relative
		#     to the method name.
		return StzListQ( This.Types() ).Unique()

	def EntityN(_n_)
		if _n_ > 0 and _n_ <= This.NumberOfEntities()
			return This.Entities()[_n_]
		else
			StzRaise("Index out of range!")
		ok

		def Entity(_n_)
			return This.EntityN(_n_)

	def FirstEntity()
		if This.NumberOfEntities() > 0
			return This.EntityN(1)
		else
			StzRaise("List is empty!")
		ok

	def LastEntity()
		if This.NumberOfEntities() > 0
			return This.EntityN( This.NumberOfEntities() )
		else
			StzRaise("List is empty!")
		ok

	def NumberOfEntities()
		return len( This.Entities() )

		def Size()
			return This.NumberOfEntities()

		def Count()
			return This.NumberOfEntities()

	def IsEmpty()
		return This.NumberOfEntities() = 0

	def RemoveEntity(pcName)
		_n_ = This.FindEntityByName(pcName)
		if _n_ > 0
			del(@aListOfEntities, _n_)
		else
			StzRaise("Entity not found!")
		ok

		def RemoveEntityN(_n_)
			if _n_ > 0 and _n_ <= This.NumberOfEntities()
				del(@aListOfEntities, _n_)
			else
				StzRaise("Index out of range!")
			ok

	def FindEntityByName(pcName)
		_n_ = 0
		_aThisEntities7_ = This.Entities()
		_nThisEntities7Len_ = len(_aThisEntities7_)
		for _iLoopThisEntities7_ = 1 to _nThisEntities7Len_
			_aEntity_ = _aThisEntities7_[_iLoopThisEntities7_]
			_n_++
			if _aEntity_[:name] = StzLower(pcName)
				return _n_
			ok
		next
		return 0

	def FindEntitiesByType(pcType)
		_aResult_ = []
		_n_ = 0
		_aThisEntities6_ = This.Entities()
		_nThisEntities6Len_ = len(_aThisEntities6_)
		for _iLoopThisEntities6_ = 1 to _nThisEntities6Len_
			_aEntity_ = _aThisEntities6_[_iLoopThisEntities6_]
			_n_++
			if _aEntity_[:type] = StzLower(pcType)
				_aResult_ + _n_
			ok
		next
		return _aResult_

	def EntitiesOfType(pcType)
		_aResult_ = []
		_aThisEntities5_ = This.Entities()
		_nThisEntities5Len_ = len(_aThisEntities5_)
		for _iLoopThisEntities5_ = 1 to _nThisEntities5Len_
			_aEntity_ = _aThisEntities5_[_iLoopThisEntities5_]
			if _aEntity_[:type] = StzLower(pcType)
				_aResult_ + _aEntity_
			ok
		next
		return _aResult_

	def ContainsEntity(pcName)
		return This.FindEntityByName(pcName) > 0

		def HasEntity(pcName)
			return This.ContainsEntity(pcName)

	def ContainsName(pcName)
		_bResult_ = 0
		_aThisEntities4_ = This.Entities()
		_nThisEntities4Len_ = len(_aThisEntities4_)
		for _iLoopThisEntities4_ = 1 to _nThisEntities4Len_
			_aEntity_ = _aThisEntities4_[_iLoopThisEntities4_]
			if _aEntity_[:name] = StzLower(pcName)
				_bResult_ = 1
				exit
			ok
		next
		return _bResult_

		def HasName(pcName)
			return This.ContainsName(pcName)

	def ContainsType(pcType)
		_bResult_ = 0
		_aThisEntities3_ = This.Entities()
		_nThisEntities3Len_ = len(_aThisEntities3_)
		for _iLoopThisEntities3_ = 1 to _nThisEntities3Len_
			_aEntity_ = _aThisEntities3_[_iLoopThisEntities3_]
			if _aEntity_[:type] = StzLower(pcType)
				_bResult_ = 1
				exit
			ok
		next
		return _bResult_

		def HasType(pcType)
			return This.ContainsType(pcType)

	def CountByType(pcType)
		_nCount_ = 0
		_aThisEntities2_ = This.Entities()
		_nThisEntities2Len_ = len(_aThisEntities2_)
		for _iLoopThisEntities2_ = 1 to _nThisEntities2Len_
			_aEntity_ = _aThisEntities2_[_iLoopThisEntities2_]
			if _aEntity_[:type] = StzLower(pcType)
				_nCount_++
			ok
		next
		return _nCount_

	def Clear()
		@aListOfEntities = []

	def SortByName()
		# Sort hashlists by the :name key value. No stzList SortedBy --
		# do it inline with a hoisted-length pass + insertion sort over
		# the small entity list (usually < a few hundred items).
		_aData_ = @aListOfEntities
		_nLen_ = len(_aData_)
		for _i_ = 2 to _nLen_
			_oCur_ = _aData_[_i_]
			_j_ = _i_ - 1
			while _j_ >= 1 and strcmp(_aData_[_j_][:name], _oCur_[:name]) > 0
				_aData_[_j_ + 1] = _aData_[_j_]
				_j_--
			end
			_aData_[_j_ + 1] = _oCur_
		next
		@aListOfEntities = _aData_

	def SortByType()
		_aData_ = @aListOfEntities
		_nLen_ = len(_aData_)
		for _i_ = 2 to _nLen_
			_oCur_ = _aData_[_i_]
			_j_ = _i_ - 1
			while _j_ >= 1 and strcmp(_aData_[_j_][:type], _oCur_[:type]) > 0
				_aData_[_j_ + 1] = _aData_[_j_]
				_j_--
			end
			_aData_[_j_ + 1] = _oCur_
		next
		@aListOfEntities = _aData_

	# Cuts the entities of one type into their own list -- an OBJECT,
	# hence Q. For the plain data, EntitiesOfType() already answers.
	def FilterByTypeQ(pcType)
		return new stzListOfEntities( This.EntitiesOfType(pcType) )

	def Show()
		? "List of Entities (" + This.NumberOfEntities() + " entities):"
		? "================================================"
		
		if This.IsEmpty()
			? "(empty)"
		else
			_n_ = 0
			_aThisEntities1_ = This.Entities()
			_nThisEntities1Len_ = len(_aThisEntities1_)
			for _iLoopThisEntities1_ = 1 to _nThisEntities1Len_
				_aEntity_ = _aThisEntities1_[_iLoopThisEntities1_]
				_n_++
				_oEntity_ = new stzEntity(_aEntity_)
				? "" + _n_ + ". " + _oEntity_.Name() + " (" + _oEntity_.Type() + ")"
			next
		ok

class stzSupposition
	@cName = ""

	def init(pcName)
		@cName = StzLower(trim(pcName))

	# "Suppose X IS A fruit" -- records the assumption in the overlay
	def IsAQ(pcType)
		_cT_ = StzLower(trim("" + pcType))
		_nSp_ = len($aStzSuppositions)
		for _iSp_ = 1 to _nSp_
			if $aStzSuppositions[_iSp_][1] = @cName and
			   $aStzSuppositions[_iSp_][2] = _cT_
				return This
			ok
		next
		$aStzSuppositions + [ @cName, _cT_ ]
		return This

	# "...and (is) a company" -- the conjunction keeps supposing
	def AndQ()
		return This

	def Name()
		return @cName
