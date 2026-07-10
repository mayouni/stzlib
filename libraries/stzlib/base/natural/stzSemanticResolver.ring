#---------------------------------------------------------------------------#
#  stzSemanticResolver -- ONE lexicon shared by the natural-programming     #
#  stack (stzNatural execution) and the reflection stack (Ask/Explain)      #
#                                                                           #
#  THE UNIFICATION PROTOTYPE. Softanza held the same lexical fact --        #
#  "these surface words mean this canonical action" -- in three copies:     #
#                                                                           #
#     1. stzNatural's :semantic_mappings ("uppercase" -> METHOD_UPPERCASE)  #
#     2. stzNaturalCode's _ActionsXT form glossary (Uppercase, Uppercased,  #
#        IsUppercased, InUppercase, Uppercasing -- one action, five forms)  #
#     3. the #@ aka retrieval tags in class sources ("all caps, capitals")  #
#                                                                           #
#  This file merges the three into ONE semantic-ID-keyed lexicon, then      #
#  exposes StzResolveSemantic(word): the fallback stzNatural consults for   #
#  words missing from its dictionary. Lexical IDF scoring decides first     #
#  (deterministic, no model needed); when a neural model is loaded, an      #
#  embedding rescue catches paraphrases that share no surface token.        #
#                                                                           #
#  Net effect: Naturally("Create a string with 'softanza' Capitals it")     #
#  executes METHOD_UPPERCASE although "capitals" appears nowhere in the     #
#  semantic dictionary -- it is recovered from the Uppercase #@ aka tags.   #
#---------------------------------------------------------------------------#

$aStzSemLexicon = []        # [ [ cSemanticId, cBagOfWords ], ... ]
$bStzSemLexiconBuilt = FALSE
$aStzSemResolveMemo = []    # [ [ cWord, cResolvedId ], ... ] (failures memoized as "")

$aStzSemHarvestRecs = []    # cached reflect harvest [ name, desc, aka, owner, class ]
$bStzSemHarvested = FALSE
$bStzSemOpsGrown = FALSE    # $aSemanticOperations grown from the harvest yet?
$aStzSemExactNames = []     # [ [ lowered stz_method, semantic_id ], ... ]
$aStzSemOpIds = []          # flat id list backing _StzSemOpKnown (ring_find speed)
$nStzSemCacheSig = 0        # cache signature (combined source sizes)
$aStzSemLangLex = []        # multilingual packs: [ [ cCode, aBags, aExact ], ... ]

#--

# The reflect harvest of the three natural-facing classes, cached once and
# shared by the operation growth AND the lexicon build.

func _StzSemHarvest()
	if $bStzSemHarvested
		return $aStzSemHarvestRecs
	ok
	_aCls_ = [ "stzString", "stzList", "stzNumber" ]
	for _i_ = 1 to 3
		_aH_ = _StzHarvestChain(_aCls_[_i_])
		_nH_ = len(_aH_)
		for _j_ = 1 to _nH_
			_aRec_ = _aH_[_j_]
			while len(_aRec_) < 5
				_aRec_ + ""
			end
			_aRec_ + _aCls_[_i_]
			$aStzSemHarvestRecs + _aRec_
		next
	next
	$bStzSemHarvested = TRUE
	return $aStzSemHarvestRecs

# GROW $aSemanticOperations FROM THE HARVEST. Every ACTIVE-form method of
# stzString / stzList / stzNumber with arity <= 2 becomes an executable
# METHOD_* operation -- the active form is exactly Naturally()'s semantic
# model (transform one object through steps), so passives, predicates,
# fluents and the other forms stay out. Hand-authored operations are never
# overridden. Also (re)builds the exact-name map used by the resolver.

func StzGrowSemanticOperations()

	if $bStzSemOpsGrown
		return
	ok
	$bStzSemOpsGrown = TRUE

	# flat id list -- _StzSemOpKnown must stay O(ring_find), not a hashlist
	# scan, or growth goes quadratic over ~2000 candidates
	$aStzSemOpIds = []
	_nOps_ = len($aSemanticOperations)
	for _i_ = 1 to _nOps_
		$aStzSemOpIds + $aSemanticOperations[_i_][:semantic_id]
	next

	# warm start: grown ops + final lexicon bags persisted under doc/
	# (harvesting + arity-scanning three big sources costs seconds; the
	# cache signature is the combined source size, so any edit rebuilds)
	$nStzSemCacheSig = _StzSemCacheSig()
	if _StzSemLoadCache($nStzSemCacheSig)
		_StzSemBuildExactMap()
		return
	ok

	_aRecs_ = _StzSemHarvest()
	_nR_ = len(_aRecs_)

	# CONSTRUCT-AND-VERIFY: only names that are REAL methods of a live
	# instance may become operations (the harvest can carry phantom names
	# from nested defs and parent-file noise -- calling those would R14).
	_aLive_ = []
	_aLive_ + [ "stzstring", _StzSemMethodsOf("new stzString('')") ]
	_aLive_ + [ "stzlist",   _StzSemMethodsOf("new stzList([])") ]
	_aLive_ + [ "stznumber", _StzSemMethodsOf("new stzNumber(0)") ]

	# arity maps per owner class, built lazily (one source pass each)
	_aArity_ = []    # [ [ ownerLower, aMap ], ... ]

	for _i_ = 1 to _nR_
		_aRec_ = _aRecs_[_i_]
		_cName_ = _aRec_[1]

		if NOT isalpha(_cName_) or StzLen(_cName_) < 3
			loop
		ok
		# Ring/class plumbing is never a natural action
		if ring_find([ "init", "operator", "braceend", "bracestart" ], lower(_cName_)) > 0
			loop
		ok
		# The function-forms grammar decides the operation KIND:
		#   active / deep / plural      -> "action" (mutates the object)
		#   passive / predicate / IsNot -> "query"  (RETURNS a value: the
		#      result concept -- "Is it empty", "its Reversed copy")
		#   fluent (Q) is excluded: its purpose is chaining, and natural
		#      sequencing already chains; extended/conditional/statement
		#      (XT/W/X) carry special parameter grammars -- out for now.
		_aForm_ = _StzFormOf(_cName_)
		_cKind_ = ""
		if ring_find([ "active", "deep", "plural" ], _aForm_[1]) > 0
			_cKind_ = "action"
		but ring_find([ "passive", "predicate", "negative" ], _aForm_[1]) > 0
			_cKind_ = "query"
		ok
		if _cKind_ = ""
			loop
		ok
		# must be callable on a live instance of the harvested class
		_aClsMeths_ = []
		_nLv_ = len(_aLive_)
		for _v_ = 1 to _nLv_
			if _aLive_[_v_][1] = lower(_aRec_[6])
				_aClsMeths_ = _aLive_[_v_][2]
				exit
			ok
		next
		if ring_find(_aClsMeths_, lower(_cName_)) = 0
			loop
		ok

		_cId_ = "METHOD_" + upper(_cName_)
		_nAt_ = ring_find($aStzSemOpIds, _cId_)   # index-aligned with ops
		if _nAt_ > 0
			# same verb proven callable on ANOTHER class (RemoveDuplicates
			# lives on both stzString and stzList): widen :applies_to of
			# the grown op so the codegen guard admits both. NB: read-
			# modify-write -- Ring copies lists on plain assignment.
			if HasKey($aSemanticOperations[_nAt_], :grown)
				_aTo_ = $aSemanticOperations[_nAt_][:applies_to]
				if ring_find(_aTo_, _aRec_[6]) = 0
					_aTo_ + _aRec_[6]
					$aSemanticOperations[_nAt_][:applies_to] = _aTo_
				ok
			ok
			loop
		ok

		_cOwner_ = _aRec_[4]
		if _cOwner_ = ""
			_cOwner_ = _aRec_[6]
		ok
		_aMap_ = _StzSemArityMapFor(_aArity_, _cOwner_)
		_nAr_ = _StzSemArityLookup(_aMap_, lower(_cName_))
		if _nAr_ < 0 or _nAr_ > 2
			loop
		ok

		# SEMANTIC PROBE (the Host & Ostvold lesson, run forward): a
		# 0-arity "active"-form name that is really a GETTER -- probing a
		# sample instance shows no mutation but a returned value -- is
		# reclassified as a QUERY, so "Take its content"-style narration
		# answers instead of silently no-oping. Verb-headed and output-
		# ish names are trusted without probing (probing Show() would
		# print during growth).
		if _cKind_ = "action" and _nAr_ = 0 and
		   NOT _StzSemVerbHeaded(_cName_) and
		   NOT _StzSemOutputish(_cName_)
			_cObs_ = _StzSemProbeBehavior(_aRec_[6], _cName_)
			if _cObs_ = "getter"
				_cKind_ = "query"
			ok
		ok

		_cSig_ = "@var." + _cName_ + "("
		for _k_ = 1 to _nAr_
			_cSig_ += "@param" + _k_
			if _k_ < _nAr_
				_cSig_ += ", "
			ok
		next
		_cSig_ += ")"

		_aOp_ = []
		_aOp_ + [ "semantic_id", _cId_ ]
		_aOp_ + [ "stz_method", _cName_ ]
		_aOp_ + [ "stz_signature", _cSig_ ]
		_aOp_ + [ "applies_to", [ _aRec_[6] ] ]
		if _nAr_ > 0
			_aOp_ + [ "requires_params", _nAr_ ]
		ok
		_aOp_ + [ "kind", _cKind_ ]
		_aOp_ + [ "grown", 1 ]
		$aSemanticOperations + _aOp_
		$aStzSemOpIds + _cId_
	next

	_StzSemBuildExactMap()

	func @StzGrowSemanticOperations()
		StzGrowSemanticOperations()

# Exact-name map over ALL operations (hand-authored + grown): the resolver
# prefers a deterministic exact hit over IDF scoring, so base verbs can
# never be lost to score ties as the lexicon grows.

func _StzSemBuildExactMap()
	$aStzSemExactNames = []
	_nOps_ = len($aSemanticOperations)
	for _i_ = 1 to _nOps_
		_aOp_ = $aSemanticOperations[_i_]
		if HasKey(_aOp_, :stz_method)
			$aStzSemExactNames + [ lower(_aOp_[:stz_method]), _aOp_[:semantic_id] ]
		ok
	next

# One source pass per owner class: [ [ lowered def name, arity ], ... ].

func _StzSemArityMapFor(paMemo, pcOwner)
	_cKey_ = lower(pcOwner)
	_n_ = len(paMemo)
	for _i_ = 1 to _n_
		if paMemo[_i_][1] = _cKey_
			return paMemo[_i_][2]
		ok
	next
	_aMap_ = []
	_cSrc_ = _StzResolveSource(pcOwner)
	if _cSrc_ != "" and fexists(_cSrc_)
		_aLines_ = str2list(read(_cSrc_))
		_nL_ = len(_aLines_)
		for _i_ = 1 to _nL_
			_cT_ = trim(_aLines_[_i_])
			if len(_cT_) >= 4 and lower(left(_cT_, 4)) = "def "
				_cDefName_ = lower(_StzDefName(_cT_))
				_nAr_ = 0
				_p1_ = substr(_cT_, "(")
				if _p1_ > 0
					_p2_ = _StzLastPos(_cT_, ")")
					if _p2_ > _p1_ + 1
						_cP_ = substr(_cT_, _p1_ + 1, _p2_ - _p1_ - 1)
						if trim(_cP_) != ""
							_nAr_ = len(_StzSplitOnChar(_cP_, ","))
						ok
					ok
				ok
				_aMap_ + [ _cDefName_, _nAr_ ]
			ok
		next
	ok
	paMemo + [ _cKey_, _aMap_ ]
	return _aMap_

#--- LINEARIZATION (the GF lesson, lightweight) -----------------------------
# One abstract syntax, many surfaces: the canonical way to SAY a semantic id
# in a given language -- its first dictionary word, else the first written
# :phrases variant, else the English reading. Powers the multilingual
# Understood() paraphrase.

func StzLinearizeId(pcLang, pcSemId)
	_cLang_ = StzLower(pcLang)
	if _cLang_ != "en"
		_aW_ = StzMappingWordsOf(_cLang_, pcSemId, 1)
		if len(_aW_) > 0
			return _aW_[1]
		ok
		_n_ = len($aLanguageDefinitions)
		for _i_ = 1 to _n_
			_aDef_ = $aLanguageDefinitions[_i_]
			if StzLower(_aDef_[:code]) != _cLang_ or NOT HasKey(_aDef_, :phrases)
				loop
			ok
			_aPh_ = _aDef_[:phrases]
			_nP_ = len(_aPh_)
			for _j_ = 1 to _nP_
				if _aPh_[_j_][:semantic] = pcSemId
					_aV_ = _StzSplitOnChar(_aPh_[_j_][:words], ",")
					if len(_aV_) > 0
						return trim(_aV_[1])
					ok
				ok
			next
			exit
		next
	ok
	# English / fallback reading
	_aW_ = StzMappingWordsOf("en", pcSemId, 1)
	if len(_aW_) > 0
		return _aW_[1]
	ok
	_nOps_ = len($aSemanticOperations)
	for _i_ = 1 to _nOps_
		if $aSemanticOperations[_i_][:semantic_id] = pcSemId and
		   HasKey($aSemanticOperations[_i_], :stz_method)
			return lower(_StzSplitCamel($aSemanticOperations[_i_][:stz_method]))
		ok
	next
	return StzLower(pcSemId)

	func @StzLinearizeId(pcLang, pcSemId)
		return StzLinearizeId(pcLang, pcSemId)

#--- PACK TEMPLATE EXPORTER + COVERAGE (the Citrine lesson) -----------------
# A translator should produce a new language pack by FILLING A DATA FILE,
# never by reading internals. The exporter emits a valid, ready-to-fill
# StzAddNaturalLanguage() skeleton with the English reference words beside
# every slot; the coverage report says which semantic ids a pack still
# misses relative to the reference id set.

# The reference id set: the structural roles + every id the English
# dictionary covers + every id any shipped pack addresses via :phrases.

func _StzSemReferenceIds()
	_aIds_ = [ "CREATE_OBJECT", "OBJECT_STRING", "OBJECT_LIST", "OBJECT_NUMBER",
	           "VALUE_INDICATOR", "NAME_INDICATOR", "SWITCH_OBJECT",
	           "KEEP_INDICATOR", "OUTPUT_DISPLAY" ]
	_n_ = len($aLanguageDefinitions)
	for _i_ = 1 to _n_
		_aDef_ = $aLanguageDefinitions[_i_]
		if HasKey(_aDef_, :semantic_mappings)
			_aM_ = _aDef_[:semantic_mappings]
			_nM_ = len(_aM_)
			for _j_ = 1 to _nM_
				_cId_ = _aM_[_j_][:semantic]
				if ( left(_cId_, 7) = "METHOD_" or left(_cId_, 9) = "MODIFIER_" ) and
				   ring_find(_aIds_, _cId_) = 0
					_aIds_ + _cId_
				ok
			next
		ok
		if HasKey(_aDef_, :phrases)
			_aPh_ = _aDef_[:phrases]
			_nP_ = len(_aPh_)
			for _j_ = 1 to _nP_
				if ring_find(_aIds_, _aPh_[_j_][:semantic]) = 0
					_aIds_ + _aPh_[_j_][:semantic]
				ok
			next
		ok
	next
	return _aIds_

# English reference words for an id, comma-joined (for the # en: comments).

func _StzSemEnRefOf(pcId)
	_aW_ = StzMappingWordsOf("en", pcId, 4)
	_c_ = ""
	_n_ = len(_aW_)
	for _i_ = 1 to _n_
		_c_ += _aW_[_i_]
		if _i_ < _n_ _c_ += ", " ok
	next
	if _c_ = ""
		# a grown id: the split-camel reading of its method name
		_nOps_ = len($aSemanticOperations)
		for _i_ = 1 to _nOps_
			if $aSemanticOperations[_i_][:semantic_id] = pcId and
			   HasKey($aSemanticOperations[_i_], :stz_method)
				_c_ = lower(_StzSplitCamel($aSemanticOperations[_i_][:stz_method]))
				exit
			ok
		next
	ok
	return _c_

func StzExportPackTemplate(pcCode, pcName)

	if NOT ( isString(pcCode) and isString(pcName) )
		StzRaise("Incorrect params! pcCode and pcName must be strings.")
	ok
	StzGrowSemanticOperations()
	_nl_ = char(10)
	_q_ = char(34)
	_c_ = ""
	_c_ += "# Softanza natural-language pack -- " + pcName + " (" + pcCode + ")" + _nl_
	_c_ += "# ------------------------------------------------------------------" + _nl_
	_c_ += "# HOW TO FILL: put your language word(s) between the empty quotes." + _nl_
	_c_ += "# One word per :natural line (duplicate a line for synonyms); multi-" + _nl_
	_c_ += "# word expressions go in the :phrases section, comma-separated." + _nl_
	_c_ += "# Delete any line you cannot translate -- partial packs work fine." + _nl_
	_c_ += "# The en: comments show the English reference for each slot." + _nl_
	_c_ += "# Load the finished file (or paste it) and the language is live." + _nl_
	_c_ += _nl_
	_c_ += "StzAddNaturalLanguage([" + _nl_
	_c_ += char(9) + ":code = " + _q_ + pcCode + _q_ + "," + _nl_
	_c_ += char(9) + ":name = " + _q_ + StzLower(pcName) + _q_ + "," + _nl_
	_c_ += char(9) + ":script = " + _q_ + "latin" + _q_ + ",   # or arabic, cyrillic, ..." + _nl_
	_c_ += _nl_
	_c_ += char(9) + "# Small words your language skips over (articles, fillers," + _nl_
	_c_ += char(9) + "# politeness): they are ignored during interpretation." + _nl_
	_c_ += char(9) + ":ignored_words = [ " + _q_ + _q_ + ", " + _q_ + _q_ + ", " + _q_ + _q_ + " ]," + _nl_
	_c_ += _nl_
	_c_ += char(9) + "# MORPHOLOGY (optional -- uncomment what your language needs):" + _nl_
	_c_ += char(9) + "# :prefix_articles     = [ " + _q_ + _q_ + " ],   # attached articles (Arabic al-, French l-apostrophe)" + _nl_
	_c_ += char(9) + "# :prefix_conjunctions = [ " + _q_ + _q_ + " ],   # attached and/so (Arabic wa-/fa-)" + _nl_
	_c_ += char(9) + "# :prefix_prepositions = [ " + _q_ + _q_ + " ],   # fused with/for (Arabic bi-/li-; verified strips only)" + _nl_
	_c_ += char(9) + "# :suffix_pronouns     = [ " + _q_ + _q_ + " ],   # attached it/them (Arabic -ha/-hu; Turkish case endings)" + _nl_
	_c_ += char(9) + "# :strip_marks         = [ StzChar(0) ],   # writing marks deleted anywhere (diacritics, stretch)" + _nl_
	_c_ += char(9) + "# :digit_map           = [ [ StzChar(0), " + _q_ + "0" + _q_ + " ] ],   # your digits -> ASCII" + _nl_
	_c_ += char(9) + "# WORD ORDER (uncomment for SOV-family languages):" + _nl_
	_c_ += char(9) + "# :object_before_create = 1,   # value and object word BEFORE the creation verb" + _nl_
	_c_ += char(9) + "# :params_before_verb   = 1,   # parameters BEFORE their action verb" + _nl_
	_c_ += _nl_
	_c_ += char(9) + ":semantic_mappings = [" + _nl_

	_aStruct_ = [ "CREATE_OBJECT", "OBJECT_STRING", "OBJECT_LIST", "OBJECT_NUMBER",
	              "VALUE_INDICATOR", "NAME_INDICATOR", "SWITCH_OBJECT",
	              "KEEP_INDICATOR", "OUTPUT_DISPLAY" ]
	_aIds_ = _StzSemReferenceIds()
	_nI_ = len(_aIds_)
	for _i_ = 1 to _nI_
		_cId_ = _aIds_[_i_]
		_cRef_ = _StzSemEnRefOf(_cId_)
		_c_ += char(9) + char(9) + "[:natural = " + _q_ + _q_ + ", :semantic = " + _q_ + _cId_ + _q_ + "],"
		if _cRef_ != ""
			_c_ += "   # en: " + _cRef_
		ok
		_c_ += _nl_
		if _cId_ = "OUTPUT_DISPLAY" and _i_ < _nI_
			_c_ += _nl_ + char(9) + char(9) + "# --- the action verbs ---" + _nl_
		ok
	next
	_c_ += char(9) + "]," + _nl_
	_c_ += _nl_
	_c_ += char(9) + "# Multi-word expressions of your language, comma-separated per id" + _nl_
	_c_ += char(9) + "# (these also power fuzzy matching and suggestions):" + _nl_
	_c_ += char(9) + ":phrases = [" + _nl_
	for _i_ = 1 to _nI_
		_cId_ = _aIds_[_i_]
		if ring_find(_aStruct_, _cId_) > 0
			loop
		ok
		_cRef_ = _StzSemEnRefOf(_cId_)
		_c_ += char(9) + char(9) + "[:semantic = " + _q_ + _cId_ + _q_ + ", :words = " + _q_ + _q_ + "],"
		if _cRef_ != ""
			_c_ += "   # en: " + _cRef_
		ok
		_c_ += _nl_
	next
	_c_ += char(9) + "]" + _nl_
	_c_ += "])" + _nl_
	return _c_

	func @StzExportPackTemplate(pcCode, pcName)
		return StzExportPackTemplate(pcCode, pcName)

func StzExportPackTemplateToFile(pcCode, pcName, pcFilePath)
	_c_ = StzExportPackTemplate(pcCode, pcName)
	write(pcFilePath, _c_)
	return pcFilePath

	func @StzExportPackTemplateToFile(pcCode, pcName, pcFilePath)
		return StzExportPackTemplateToFile(pcCode, pcName, pcFilePath)

# COVERAGE: which reference ids does a language address (dictionary word OR
# phrase entry)? Returns [ :language, :covered, :total, :missing ].

func StzPackCoverage(pcLang)
	_cLang_ = StzLower(pcLang)
	_aIds_ = _StzSemReferenceIds()
	_aCovered_ = []
	_n_ = len($aLanguageDefinitions)
	for _i_ = 1 to _n_
		_aDef_ = $aLanguageDefinitions[_i_]
		if StzLower(_aDef_[:code]) != _cLang_
			loop
		ok
		if HasKey(_aDef_, :semantic_mappings)
			_aM_ = _aDef_[:semantic_mappings]
			_nM_ = len(_aM_)
			for _j_ = 1 to _nM_
				if trim(_aM_[_j_][:natural]) != "" and
				   ring_find(_aCovered_, _aM_[_j_][:semantic]) = 0
					_aCovered_ + _aM_[_j_][:semantic]
				ok
			next
		ok
		if HasKey(_aDef_, :phrases)
			_aPh_ = _aDef_[:phrases]
			_nP_ = len(_aPh_)
			for _j_ = 1 to _nP_
				if trim(_aPh_[_j_][:words]) != "" and
				   ring_find(_aCovered_, _aPh_[_j_][:semantic]) = 0
					_aCovered_ + _aPh_[_j_][:semantic]
				ok
			next
		ok
		exit
	next
	_aMissing_ = []
	_nI_ = len(_aIds_)
	_nCov_ = 0
	for _i_ = 1 to _nI_
		if ring_find(_aCovered_, _aIds_[_i_]) > 0
			_nCov_++
		else
			_aMissing_ + _aIds_[_i_]
		ok
	next
	return [ :language = _cLang_, :covered = _nCov_, :total = _nI_,
	         :missing = _aMissing_ ]

	func @StzPackCoverage(pcLang)
		return StzPackCoverage(pcLang)

#--- SUGGESTION VOCABULARY (powers the predictive suggest API) --------------
# The Ginseng/PENG lesson: the strongest CNL UX device is showing what CAN
# be said next. These pools feed prefix completion.

# English: natural phrases for the operations -- the split-camel reading of
# each method name ("RemoveDuplicates" -> "remove duplicates"), filtered by
# an optional prefix, capped. Actions before queries, shortest first.

func StzSuggestVerbPhrases(pcPrefix, pnMax)
	StzSemanticLexicon()
	_cP_ = StzLower(trim(pcPrefix))
	_nP_ = len(_cP_)
	_aAct_ = []
	_aQry_ = []
	_nOps_ = len($aSemanticOperations)
	for _i_ = 1 to _nOps_
		_aOp_ = $aSemanticOperations[_i_]
		if NOT HasKey(_aOp_, :stz_method)
			loop
		ok
		_cPh_ = lower(_StzSplitCamel(_aOp_[:stz_method]))
		if _nP_ > 0 and left(_cPh_, _nP_) != _cP_
			loop
		ok
		if HasKey(_aOp_, :kind) and _aOp_[:kind] = "query"
			_aQry_ + _cPh_
		else
			_aAct_ + _cPh_
		ok
	next
	_aAct_ = _StzSemShortestFirst(_aAct_)
	_aQry_ = _StzSemShortestFirst(_aQry_)
	_aOut_ = []
	_n_ = len(_aAct_)
	for _i_ = 1 to _n_
		if len(_aOut_) >= pnMax exit ok
		if ring_find(_aOut_, _aAct_[_i_]) = 0
			_aOut_ + _aAct_[_i_]
		ok
	next
	_n_ = len(_aQry_)
	for _i_ = 1 to _n_
		if len(_aOut_) >= pnMax exit ok
		if ring_find(_aOut_, _aQry_[_i_]) = 0
			_aOut_ + _aQry_[_i_]
		ok
	next
	return _aOut_

	func @StzSuggestVerbPhrases(pcPrefix, pnMax)
		return StzSuggestVerbPhrases(pcPrefix, pnMax)

# Pack languages: the pack's own written phrases (the :phrases entries) plus
# its dictionary words, prefix-filtered.

func StzPackPhrases(pcLang, pcPrefix, pnMax)
	_cLang_ = StzLower(pcLang)
	_cP_ = StzLower(trim(pcPrefix))
	_nP_ = len(_cP_)
	_aOut_ = []
	_n_ = len($aLanguageDefinitions)
	for _i_ = 1 to _n_
		_aDef_ = $aLanguageDefinitions[_i_]
		if StzLower(_aDef_[:code]) != _cLang_
			loop
		ok
		if HasKey(_aDef_, :semantic_mappings)
			_aM_ = _aDef_[:semantic_mappings]
			_nM_ = len(_aM_)
			for _j_ = 1 to _nM_
				if left(_aM_[_j_][:semantic], 7) = "METHOD_" or
				   _aM_[_j_][:semantic] = "OUTPUT_DISPLAY"
					_w_ = StzLower(_aM_[_j_][:natural])
					if ( _nP_ = 0 or left(_w_, _nP_) = _cP_ ) and
					   ring_find(_aOut_, _w_) = 0 and len(_aOut_) < pnMax
						_aOut_ + _w_
					ok
				ok
			next
		ok
		if HasKey(_aDef_, :phrases)
			_aPh_ = _aDef_[:phrases]
			_nPh_ = len(_aPh_)
			for _j_ = 1 to _nPh_
				_aVars_ = _StzSplitOnChar(_aPh_[_j_][:words], ",")
				_nV_ = len(_aVars_)
				for _k_ = 1 to _nV_
					_w_ = StzLower(trim(_aVars_[_k_]))
					if _w_ != "" and ( _nP_ = 0 or left(_w_, _nP_) = _cP_ ) and
					   ring_find(_aOut_, _w_) = 0 and len(_aOut_) < pnMax
						_aOut_ + _w_
					ok
				next
			next
		ok
		exit
	next
	return _aOut_

	func @StzPackPhrases(pcLang, pcPrefix, pnMax)
		return StzPackPhrases(pcLang, pcPrefix, pnMax)

# Words of a semantic id in a language's dictionary (for state suggestions).

func StzMappingWordsOf(pcLang, pcSemId, pnMax)
	_cLang_ = StzLower(pcLang)
	_aOut_ = []
	_n_ = len($aLanguageDefinitions)
	for _i_ = 1 to _n_
		_aDef_ = $aLanguageDefinitions[_i_]
		if StzLower(_aDef_[:code]) != _cLang_ or NOT HasKey(_aDef_, :semantic_mappings)
			loop
		ok
		_aM_ = _aDef_[:semantic_mappings]
		_nM_ = len(_aM_)
		for _j_ = 1 to _nM_
			if _aM_[_j_][:semantic] = pcSemId and len(_aOut_) < pnMax
				_aOut_ + StzLower(_aM_[_j_][:natural])
			ok
		next
		exit
	next
	return _aOut_

	func @StzMappingWordsOf(pcLang, pcSemId, pnMax)
		return StzMappingWordsOf(pcLang, pcSemId, pnMax)

func _StzSemShortestFirst(paList)
	_n_ = len(paList)
	_aPairs_ = []
	for _i_ = 1 to _n_
		_aPairs_ + [ len(paList[_i_]), paList[_i_] ]
	next
	_aPairs_ = SortListsOn(_aPairs_, 1)
	_aOut_ = []
	for _i_ = 1 to _n_
		_aOut_ + _aPairs_[_i_][2]
	next
	return _aOut_

#--- RUNTIME TEACHING (the Voxelurn lesson, deterministic) ------------------
# 'When I say purge I mean remove duplicates': resolve the MEANING through
# the existing machinery, then register the new word as an exact synonym in
# the live lexicon. Session-scoped (packs and caches are untouched).

func StzTeachSynonym(pcLang, pcWord, pcMeaning)

	if NOT ( isString(pcWord) and isString(pcMeaning) )
		StzRaise("Incorrect params! pcWord and pcMeaning must be strings.")
	ok
	_cLang_ = StzLower(pcLang)
	_w_ = StzLower(trim(pcWord))
	if _w_ = ""
		return ""
	ok

	# resolve the meaning: exact joined phrase first, then per-word scoring
	_aTok_ = _StzSplitOnChar(StzLower(trim(pcMeaning)), " ")
	_cJoin_ = ""
	_aClean_ = []
	_nT_ = len(_aTok_)
	for _i_ = 1 to _nT_
		_t_ = trim(_aTok_[_i_])
		if _t_ != "" and ring_find($aStzStopwords, _t_) = 0
			_cJoin_ += _t_
			_aClean_ + _t_
		ok
	next
	_cId_ = StzSemanticExactIdInLang(_cLang_, _cJoin_)
	if _cId_ = ""
		_cId_ = StzResolveSemanticInLang(_cLang_, _cJoin_)
	ok
	if _cId_ = "" and len(_aClean_) > 1 and _cLang_ != "en"
		_cId_ = StzResolveSemanticPhraseInLang(_cLang_, _aClean_)
	ok
	if _cId_ = "" and len(_aClean_) > 0
		_cId_ = StzResolveSemanticInLang(_cLang_, _aClean_[len(_aClean_)])
	ok
	if _cId_ = ""
		return ""
	ok

	# register the synonym + refresh any memoized result for the word
	if _cLang_ = "en"
		StzSemanticLexicon()
		$aStzSemExactNames + [ _w_, _cId_ ]
	else
		_aLex_ = _StzSemLangEntry(_cLang_)
		if len(_aLex_) > 0
			_StzSemLangExactAdd(_aLex_[3], _w_, _cId_)
			if ring_find(_aLex_[9], _w_) = 0
				_aLex_[9] + _w_
			ok
		ok
	ok
	_nM_ = len($aStzSemResolveMemo)
	for _i_ = 1 to _nM_
		if $aStzSemResolveMemo[_i_][1] = _w_
			$aStzSemResolveMemo[_i_][2] = _cId_
		ok
	next
	return _cId_

	func @StzTeachSynonym(pcLang, pcWord, pcMeaning)
		return StzTeachSynonym(pcLang, pcWord, pcMeaning)

#--- SEMANTIC PROBING + NAMING LINT ----------------------------------------
# Form says what a method SHOULD do; probing observes what it DOES. Calling
# a 0-arity method on a sample instance and comparing content before/after
# classifies it empirically: "mutator" (content changed), "getter" (content
# intact, value returned), "silent" (neither). Growth uses this to reclass
# noun-headed getters as queries; StzNamingLint() reports every method
# whose FORM contradicts its observed behavior (the naming-bug detector).

func _StzSemSampleExpr(pcClass)
	_c_ = lower(pcClass)
	if _c_ = "stzstring"
		return "new stzString('ab ba')"
	but _c_ = "stzlist"
		return "new stzList([ 2, 1, 2 ])"
	but _c_ = "stznumber"
		return "new stzNumber(7)"
	ok
	return ""

func _StzSemProbeBehavior(pcClass, pcMethod)
	_cNew_ = _StzSemSampleExpr(pcClass)
	if _cNew_ = ""
		return "unknown"
	ok
	_cObs_ = "unknown"
	try
		eval("_oPrb_ = " + _cNew_)
		_xBefore_ = @@( _oPrb_.Content() )
		eval("_vPrbRet_ = _oPrb_." + pcMethod + "()")
		_xAfter_ = @@( _oPrb_.Content() )
		if _xAfter_ != _xBefore_
			_cObs_ = "mutator"
		else
			_bHas_ = FALSE
			if isNumber(_vPrbRet_)
				_bHas_ = TRUE
			but isString(_vPrbRet_) and _vPrbRet_ != ""
				_bHas_ = TRUE
			but isList(_vPrbRet_) and len(_vPrbRet_) > 0
				_bHas_ = TRUE
			ok
			if _bHas_
				_cObs_ = "getter"
			else
				_cObs_ = "silent"
			ok
		ok
	catch
	done
	return _cObs_

# names that read as commands even when noun-shaped analysis is unsure
func _StzSemVerbHeaded(pcName)
	return _StzVerbLookup(lower(_StzFirstCamelWord(pcName))) != ""

func _StzSemOutputish(pcName)
	_c_ = lower(pcName)
	_aOut_ = [ "show", "print", "display", "viz", "log", "debug", "trace" ]
	_n_ = len(_aOut_)
	for _i_ = 1 to _n_
		if left(_c_, len(_aOut_[_i_])) = _aOut_[_i_]
			return TRUE
		ok
	next
	return FALSE

func _StzFirstCamelWord(pcName)
	_cOut_ = ""
	_n_ = len(pcName)
	for _i_ = 1 to _n_
		_nA_ = ascii(pcName[_i_])
		if _i_ > 1 and _nA_ >= 65 and _nA_ <= 90
			exit
		ok
		_cOut_ += pcName[_i_]
	next
	return _cOut_

# THE NAMING LINT: probe every 0-arity method of the three natural-facing
# classes and report each one whose observed behavior contradicts its
# grammatical form. Returns [ [class, name, form, observed], ... ]:
#   active-form  that only reads      -> flagged (should be a noun/passive)
#   passive-form that MUTATES         -> flagged (breaks the copy contract)

func StzNamingLint()
	_aOut_ = []
	_aRecs_ = _StzSemHarvest()
	_nR_ = len(_aRecs_)
	_aArity_ = []
	_aSeen_ = []
	for _i_ = 1 to _nR_
		_aRec_ = _aRecs_[_i_]
		_cName_ = _aRec_[1]
		_cKey_ = lower(_aRec_[6]) + ":" + lower(_cName_)
		if NOT isalpha(_cName_) or ring_find(_aSeen_, _cKey_) > 0
			loop
		ok
		_aSeen_ + _cKey_
		_aForm_ = _StzFormOf(_cName_)
		if _aForm_[1] != "active" and _aForm_[1] != "passive"
			loop
		ok
		if _StzSemOutputish(_cName_)
			loop
		ok
		_cOwner_ = _aRec_[4]
		if _cOwner_ = ""
			_cOwner_ = _aRec_[6]
		ok
		_aMap_ = _StzSemArityMapFor(_aArity_, _cOwner_)
		if _StzSemArityLookup(_aMap_, lower(_cName_)) != 0
			loop
		ok
		_cObs_ = _StzSemProbeBehavior(_aRec_[6], _cName_)
		if _aForm_[1] = "active" and _cObs_ = "getter" and
		   NOT _StzSemVerbHeaded(_cName_)
			_aOut_ + [ _aRec_[6], _cName_, "active", "getter" ]
		but _aForm_[1] = "passive" and _cObs_ = "mutator"
			_aOut_ + [ _aRec_[6], _cName_, "passive", "mutator" ]
		ok
	next
	return _aOut_

	func @StzNamingLint()
		return StzNamingLint()

# The lowered method names of a live instance (Ring's methods() is the
# ground truth of callability).

func _StzSemMethodsOf(pcNewExpr)
	_aOut_ = []
	try
		eval("_oObj_ = " + pcNewExpr)
		_aM_ = methods(_oObj_)
		_nM_ = len(_aM_)
		for _i_ = 1 to _nM_
			_aOut_ + lower(_aM_[_i_])
		next
	catch
	done
	return _aOut_

func _StzSemArityLookup(paMap, pcName)
	_n_ = len(paMap)
	for _i_ = 1 to _n_
		if paMap[_i_][1] = pcName
			return paMap[_i_][2]
		ok
	next
	return -1

func StzSemanticLexicon()

	if $bStzSemLexiconBuilt
		return $aStzSemLexicon
	ok

	# grow $aSemanticOperations from the harvest FIRST, so every source
	# below (and the bags themselves) covers the grown operations too
	StzGrowSemanticOperations()

	_aBags_ = []

	# -- Source 0: each operation's own method name, camel-split ("MultiplyBy"
	# -> "multiply by"), so grown verbs are findable by their name words.

	_nOps_ = len($aSemanticOperations)
	for _i_ = 1 to _nOps_
		_aOp_ = $aSemanticOperations[_i_]
		_cId_ = _aOp_[:semantic_id]
		if left(_cId_, 7) = "METHOD_" and HasKey(_aOp_, :stz_method)
			_StzSemBagAdd(_aBags_, _cId_, lower(_StzSplitCamel(_aOp_[:stz_method])))
		ok
	next

	# -- Source 1: invert the English :semantic_mappings (authoritative seed).
	# Only action-like IDs take part: resolving an unknown word to an OBJECT_*
	# or VALUE_INDICATOR could corrupt program structure, so those are excluded.

	_nL_ = len($aLanguageDefinitions)
	for _i_ = 1 to _nL_
		_aLang_ = $aLanguageDefinitions[_i_]
		if _aLang_[:code] != "en"
			loop
		ok
		_aMaps_ = _aLang_[:semantic_mappings]
		_nM_ = len(_aMaps_)
		for _j_ = 1 to _nM_
			_cId_ = _aMaps_[_j_][:semantic]
			if _StzSemIdEligible(_cId_)
				_StzSemBagAdd(_aBags_, _cId_, _aMaps_[_j_][:natural])
			ok
		next
	next

	# -- Source 2: the _ActionsXT form glossary (stzNaturalCode.ring). Each
	# entry lists the FORM FAMILY of one canonical action (active, passive,
	# interrogative, progressive...) -- fold every form into the action's bag.

	_nA_ = len(_ActionsXT)
	for _i_ = 1 to _nA_
		_cId_ = "METHOD_" + upper(_ActionsXT[_i_][1])
		if NOT _StzSemOpKnown(_cId_)
			loop
		ok
		_aForms_ = _ActionsXT[_i_][2]
		_nF_ = len(_aForms_)
		for _j_ = 1 to _nF_
			_StzSemBagAdd(_aBags_, _cId_, lower(_aForms_[_j_]))
		next
	next

	# -- Source 3: the #@ aka retrieval tags, harvested from the class sources
	# by the reflect layer. Each record's aka is folded into the operation of
	# its form-family BASE (Uppercased / IsUppercased -> METHOD_UPPERCASE),
	# exactly the _ActionsXT lesson: all forms of one action share the ID.

	_aRecs_ = _StzSemHarvest()
	_nR_ = len(_aRecs_)

	for _j_ = 1 to _nR_
		_aRec_ = _aRecs_[_j_]
		if len(_aRec_) < 3 or _aRec_[3] = ""
			loop
		ok
		# FORM-SLOTTED folding: a PREDICATE'S aka is predicate-specific
		# ("is it shouting" asks, it does not mutate) -- fold it into the
		# record's OWN query operation when grown. Voice-neutral words on
		# actives/passives keep feeding the family's ACTION (a bare
		# imperative "Capitals it" should mutate, per the imperative
		# default of natural narration).
		_aFm_ = _StzFormOf(_aRec_[1])
		if _aFm_[1] = "predicate" or _aFm_[1] = "negative"
			_cOwnId_ = "METHOD_" + upper(_aRec_[1])
			if _StzSemOpKnown(_cOwnId_)
				_StzSemBagAdd(_aBags_, _cOwnId_, _aRec_[3])
				loop
			ok
		ok
		_aCands_ = _StzSemBaseCands(_aRec_[1])
		_nC_ = len(_aCands_)
		for _k_ = 1 to _nC_
			_cId_ = "METHOD_" + upper(_aCands_[_k_])
			if _StzSemOpKnown(_cId_)
				_StzSemBagAdd(_aBags_, _cId_, _aRec_[3])
				exit
			ok
		next
	next

	$aStzSemLexicon = _aBags_
	$bStzSemLexiconBuilt = TRUE
	_StzSemSaveCache($nStzSemCacheSig)
	return $aStzSemLexicon

	func @StzSemanticLexicon()
		return StzSemanticLexicon()

#--- CACHE (grown operations + final lexicon bags) ------------------------
# Lives in natural/cache/ -- a natural-module artifact travels WITH the
# module (the natural stack is slated to move into the engine later).

func _StzSemCachePath()
	_cB_ = _StzBaseDir()
	if _cB_ = ""
		return ""
	ok
	_cDir_ = _cB_ + "/natural/cache"
	try
		StzMakeDir(_cDir_)
	catch
	done
	return _cDir_ + "/semantic_ops.stzcache"

# Signature = combined byte size of the three harvested sources; any edit
# to them changes the size and forces a rebuild.

func _StzSemCacheSig()
	_n_ = 0
	_aCls_ = [ "stzString", "stzList", "stzNumber" ]
	for _i_ = 1 to 3
		_cSrc_ = _StzResolveSource(_aCls_[_i_])
		if _cSrc_ != "" and fexists(_cSrc_)
			_n_ += len(read(_cSrc_))
		ok
	next
	return _n_

func _StzSemLoadCache(nSig)
	_cPath_ = _StzSemCachePath()
	if _cPath_ = "" or NOT fexists(_cPath_)
		return FALSE
	ok
	_c_ = read(_cPath_)
	if _c_ = ""
		return FALSE
	ok
	_aLines_ = str2list(_c_)
	if len(_aLines_) < 1
		return FALSE
	ok
	_cSig_ = trim(_aLines_[1])
	if len(_cSig_) < 6 or left(_cSig_, 5) != "SIG4 "
		return FALSE
	ok
	if number(substr(_cSig_, 6, len(_cSig_) - 5)) != nSig
		return FALSE
	ok
	_aBags_ = []
	_nl_ = len(_aLines_)
	for _i_ = 2 to _nl_
		_ln_ = _aLines_[_i_]
		if trim(_ln_) = ""
			loop
		ok
		_aP_ = _StzSplitOnChar(_ln_, char(1))
		if _aP_[1] = "OP" and len(_aP_) >= 7
			_aOp_ = []
			_aOp_ + [ "semantic_id", _aP_[2] ]
			_aOp_ + [ "stz_method", _aP_[3] ]
			_aOp_ + [ "stz_signature", _aP_[4] ]
			_aOp_ + [ "applies_to", _StzSplitOnChar(_aP_[5], ";") ]
			_nAr_ = number(_aP_[6])
			if _nAr_ > 0
				_aOp_ + [ "requires_params", _nAr_ ]
			ok
			_aOp_ + [ "kind", _aP_[7] ]
			_aOp_ + [ "grown", 1 ]
			$aSemanticOperations + _aOp_
			$aStzSemOpIds + _aP_[2]
		but _aP_[1] = "LX" and len(_aP_) >= 3
			_aBags_ + [ _aP_[2], _aP_[3] ]
		ok
	next
	if len(_aBags_) = 0
		return FALSE
	ok
	$aStzSemLexicon = _aBags_
	$bStzSemLexiconBuilt = TRUE
	return TRUE

func _StzSemSaveCache(nSig)
	_cPath_ = _StzSemCachePath()
	if _cPath_ = ""
		return
	ok
	_c_ = "SIG4 " + nSig + nl
	_nOps_ = len($aSemanticOperations)
	for _i_ = 1 to _nOps_
		_aOp_ = $aSemanticOperations[_i_]
		if NOT HasKey(_aOp_, :grown)
			loop
		ok
		_nAr_ = 0
		if HasKey(_aOp_, :requires_params)
			_nAr_ = _aOp_[:requires_params]
		ok
		_cKind_ = "action"
		if HasKey(_aOp_, :kind)
			_cKind_ = _aOp_[:kind]
		ok
		_aTo_ = _aOp_[:applies_to]
		_cTo_ = ""
		_nTo_ = len(_aTo_)
		for _k_ = 1 to _nTo_
			_cTo_ += _aTo_[_k_]
			if _k_ < _nTo_
				_cTo_ += ";"
			ok
		next
		_c_ += "OP" + char(1) + _aOp_[:semantic_id] + char(1) +
		       _aOp_[:stz_method] + char(1) + _aOp_[:stz_signature] + char(1) +
		       _cTo_ + char(1) + _nAr_ + char(1) + _cKind_ + nl
	next
	_nB_ = len($aStzSemLexicon)
	for _i_ = 1 to _nB_
		_cBag_ = StzReplace($aStzSemLexicon[_i_][2], nl, " ")
		_c_ += "LX" + char(1) + $aStzSemLexicon[_i_][1] + char(1) + _cBag_ + nl
	next
	try
		write(_cPath_, _c_)
	catch
	done

# Resolve one natural word (or short phrase) to a canonical semantic ID.
# Returns "" when nothing wins CLEARLY -- ambiguity must degrade to a
# literal, never to a guessed action.

func StzResolveSemantic(pcWord)

	if NOT isString(pcWord)
		return ""
	ok

	_w_ = lower(trim(pcWord))

	if StzLen(_w_) < 3
		return ""
	ok

	# @define / recall@ markers stay dictionary-only
	if left(_w_, 1) = "@" or right(_w_, 1) = "@"
		return ""
	ok

	# memo (failures included, so repeated unknowns cost nothing)
	_nMemo_ = len($aStzSemResolveMemo)
	for _i_ = 1 to _nMemo_
		if $aStzSemResolveMemo[_i_][1] = _w_
			return $aStzSemResolveMemo[_i_][2]
		ok
	next

	_aLex_ = StzSemanticLexicon()
	_nLex_ = len(_aLex_)
	if _nLex_ = 0
		return ""
	ok

	# -- Exact pass: the word IS an operation's method name. Deterministic
	# and immune to score ties, however large the grown lexicon gets.
	_nEx_ = len($aStzSemExactNames)
	for _i_ = 1 to _nEx_
		if $aStzSemExactNames[_i_][1] = _w_
			_cId_ = $aStzSemExactNames[_i_][2]
			$aStzSemResolveMemo + [ _w_, _cId_ ]
			return _cId_
		ok
	next

	_aTexts_ = []
	for _i_ = 1 to _nLex_
		_aTexts_ + _aLex_[_i_][2]
	next

	# -- Lexical pass: IDF scoring over the merged bags (deterministic).
	_aScores_ = _StzLexScoreAllIdf(_w_, _aTexts_)
	_nBest_ = 0
	_nSecond_ = 0
	_nBestIdx_ = 0
	_nS_ = len(_aScores_)
	for _i_ = 1 to _nS_
		_n_ = _aScores_[_i_][2]
		if _n_ > _nBest_
			_nSecond_ = _nBest_
			_nBest_ = _n_
			_nBestIdx_ = _aScores_[_i_][1]
		but _n_ > _nSecond_
			_nSecond_ = _n_
		ok
	next

	_cResolved_ = ""
	if _nBest_ > 0 and (_nBest_ - _nSecond_) > 0.002
		# clear unique winner (the 0.002 margin absorbs the scorer's
		# tiny shorter-document bonus, which must never decide meaning)
		_cResolved_ = _aLex_[_nBestIdx_][1]
	but _nBest_ > 0
		# FORM-SLOT tie-break: voice-neutral operation words now live in
		# BOTH the action's bag and its predicate/passive twin's. On a
		# (near-)tie, the IMPERATIVE DEFAULT of narration decides: if
		# exactly ONE of the tied bags is an ACTION, take it
		# ("capitals" mutates; predicate-specific "shouting" stays
		# unique and never reaches this branch).
		_aTied_ = []
		for _i_ = 1 to _nS_
			if _aScores_[_i_][2] >= (_nBest_ - 0.002)
				_aTied_ + _aLex_[_aScores_[_i_][1]][1]
			ok
		next
		_cAct_ = ""
		_nActs_ = 0
		_nT_ = len(_aTied_)
		for _i_ = 1 to _nT_
			if _StzSemKindOf(_aTied_[_i_]) = "action"
				_nActs_++
				_cAct_ = _aTied_[_i_]
			ok
		next
		if _nActs_ = 1
			_cResolved_ = _cAct_
		ok
	ok

	# -- Neural rescue: only when lexical found nothing and a model is loaded.
	# Catches paraphrases sharing no surface token ("curved" -> rounded).
	if _cResolved_ = "" and StzHasNeuralModel()
		_nBest_ = 0
		_nSecond_ = 0
		_nBestIdx_ = 0
		for _i_ = 1 to _nLex_
			_n_ = StzSemanticSimilarity(_w_, _aLex_[_i_][2])
			if _n_ > _nBest_
				_nSecond_ = _nBest_
				_nBest_ = _n_
				_nBestIdx_ = _i_
			but _n_ > _nSecond_
				_nSecond_ = _n_
			ok
		next
		if _nBest_ >= 0.55 and (_nBest_ - _nSecond_) >= 0.05
			_cResolved_ = _aLex_[_nBestIdx_][1]
		ok
	ok

	$aStzSemResolveMemo + [ _w_, _cResolved_ ]
	return _cResolved_

	func @StzResolveSemantic(pcWord)
		return StzResolveSemantic(pcWord)

#--- MULTILINGUAL PACKS ----------------------------------------------------
# A language pack is a DATA block keyed by the SAME semantic IDs as English:
# one semantic core, many linguistic skins (the stzNatural design promise).
# Registering a pack feeds three layers at once:
#   1. $aLanguageDefinitions (ToSemantic: exact dictionary words)
#   2. a per-language EXACT-PHRASE map (multi-word naturalness --
#      "enlève les doublons" / "أزل التكرارات" -> METHOD_REMOVEDUPLICATES)
#   3. per-language word BAGS (single-word fallback -- "doublons" alone)
# Because the map is ID-keyed, packs cover GROWN operations for free.
# ($aStzSemLangLex is declared with the top-of-file globals.)

# Register (or replace) a natural language at devtime OR runtime.
# aDef = [ :code, :name, :script, :ignored_words, :semantic_mappings,
#          :phrases = [ [ :semantic = ID, :words = "phrase, phrase, ..." ], ... ] ]

func StzAddNaturalLanguage(aDef)

	if NOT ( isList(aDef) and HasKey(aDef, :code) and HasKey(aDef, :name) )
		StzRaise("Incorrect param! aDef must be a language definition with at least :code and :name.")
	ok
	_cCode_ = StzLower(aDef[:code])

	# upsert into the dictionary-side definitions
	_bDone_ = FALSE
	_nL_ = len($aLanguageDefinitions)
	for _i_ = 1 to _nL_
		if StzLower($aLanguageDefinitions[_i_][:code]) = _cCode_
			$aLanguageDefinitions[_i_] = aDef
			_bDone_ = TRUE
			exit
		ok
	next
	if NOT _bDone_
		$aLanguageDefinitions + aDef
	ok

	# build the resolver-side lexicon from :phrases
	_aIgn_ = []
	if HasKey(aDef, :ignored_words)
		_aI_ = aDef[:ignored_words]
		_nI_ = len(_aI_)
		for _i_ = 1 to _nI_
			_aIgn_ + StzLower(_aI_[_i_])
		next
	ok

	# MORPHOLOGY (optional): languages where articles attach as prefixes
	# (Arabic al-, French l'/d') and pronouns attach as suffixes (Arabic
	# -ha/-hu). Tokens are CANONICALIZED (affixes stripped) on BOTH the
	# registration side and the query side, so the writer may say
	# "remove-its-duplicates" as ONE inflected word and still match.
	_aArt_ = []
	if HasKey(aDef, :prefix_articles)
		_aArt_ = aDef[:prefix_articles]
	ok
	_aSuf_ = []
	if HasKey(aDef, :suffix_pronouns)
		_aSuf_ = aDef[:suffix_pronouns]
	ok
	# attached conjunctions (Arabic wa-/fa- glue to the NEXT word:
	# "wa-iqlib-ha") -- stripped before the article
	_aConj_ = []
	if HasKey(aDef, :prefix_conjunctions)
		_aConj_ = aDef[:prefix_conjunctions]
	ok
	# attached prepositions (Arabic bi-/li- fuse with their noun:
	# "bi-al-takrarat"). RISKY affixes: many words legitimately start
	# with these letters, so they are stripped ONLY on the verified
	# path (construct-and-verify: the remaining base must be a word
	# the language already knows).
	_aPrep_ = []
	if HasKey(aDef, :prefix_prepositions)
		_aPrep_ = aDef[:prefix_prepositions]
	ok
	# marks deleted ANYWHERE in a token before matching: Arabic tashkeel
	# (tanween, fatha, shadda, ...) and the tatweel stretch character --
	# writers use them freely ("qa'imatan" with tanween, "bi--" stretched)
	_aMarks_ = []
	if HasKey(aDef, :strip_marks)
		_aMarks_ = aDef[:strip_marks]
	ok

	_aBags_ = []
	_aExact_ = []
	if HasKey(aDef, :phrases)
		_aPh_ = aDef[:phrases]
		_nP_ = len(_aPh_)
		for _i_ = 1 to _nP_
			_cId_ = _aPh_[_i_][:semantic]
			_aVars_ = _StzSplitOnChar(_aPh_[_i_][:words], ",")
			_nV_ = len(_aVars_)
			for _j_ = 1 to _nV_
				_aTok_ = _StzSemLangTokens(_aVars_[_j_], _aIgn_, _aArt_, _aSuf_, _aConj_, _aMarks_)
				if len(_aTok_) = 0
					loop
				ok
				_cJoin_ = ""
				_cBag_ = ""
				_nT_ = len(_aTok_)
				for _k_ = 1 to _nT_
					_cJoin_ += _aTok_[_k_]
					_cBag_ += _aTok_[_k_]
					if _k_ < _nT_
						_cBag_ += " "
					ok
				next
				_StzSemLangExactAdd(_aExact_, _cJoin_, _cId_)
				_StzSemBagAdd(_aBags_, _cId_, _cBag_)
			next
		next
	ok

	# KNOWN BASES: every canonical word this language recognizes --
	# mapping words, exact-phrase keys, bag tokens. The verified affix
	# stripper only accepts a strip chain that lands on one of these.
	_aKnown_ = []
	if HasKey(aDef, :semantic_mappings)
		_aM_ = aDef[:semantic_mappings]
		_nM_ = len(_aM_)
		for _i_ = 1 to _nM_
			_cW_ = _StzSemLangNorm(StzLower(_aM_[_i_][:natural]), _aMarks_)
			_cW_ = _StzSemLangCanon(_cW_, _aArt_, _aSuf_, _aConj_)
			if _cW_ != "" and ring_find(_aKnown_, _cW_) = 0
				_aKnown_ + _cW_
			ok
		next
	ok
	_nE_ = len(_aExact_)
	for _i_ = 1 to _nE_
		if ring_find(_aKnown_, _aExact_[_i_][1]) = 0
			_aKnown_ + _aExact_[_i_][1]
		ok
	next
	_nB_ = len(_aBags_)
	for _i_ = 1 to _nB_
		_aTk_ = _StzSplitOnChar(_aBags_[_i_][2], " ")
		_nT_ = len(_aTk_)
		for _j_ = 1 to _nT_
			if _aTk_[_j_] != "" and ring_find(_aKnown_, _aTk_[_j_]) = 0
				_aKnown_ + _aTk_[_j_]
			ok
		next
	next

	# upsert the language lexicon (morphology kept for query-side canon)
	_aEntry_ = [ _cCode_, _aBags_, _aExact_, _aArt_, _aSuf_, _aConj_, _aMarks_,
	             _aPrep_, _aKnown_ ]
	_bDone_ = FALSE
	_nX_ = len($aStzSemLangLex)
	for _i_ = 1 to _nX_
		if $aStzSemLangLex[_i_][1] = _cCode_
			$aStzSemLangLex[_i_] = _aEntry_
			_bDone_ = TRUE
			exit
		ok
	next
	if NOT _bDone_
		$aStzSemLangLex + _aEntry_
	ok
	return TRUE

	func @StzAddNaturalLanguage(aDef)
		return StzAddNaturalLanguage(aDef)

func StzHasLanguagePack(pcLang)
	_c_ = StzLower(pcLang)
	_n_ = len($aStzSemLangLex)
	for _i_ = 1 to _n_
		if $aStzSemLangLex[_i_][1] = _c_
			return TRUE
		ok
	next
	return FALSE

	func @StzHasLanguagePack(pcLang)
		return StzHasLanguagePack(pcLang)

func StzNaturalLanguages()
	_aOut_ = []
	_n_ = len($aLanguageDefinitions)
	for _i_ = 1 to _n_
		_aOut_ + $aLanguageDefinitions[_i_][:code]
	next
	return _aOut_

	func @StzNaturalLanguages()
		return StzNaturalLanguages()

# Language-aware resolution: English uses the full unified lexicon
# (dictionary + _ActionsXT + aka + grown names); pack languages use their
# registered exact map + word-membership over the pack bags. Deterministic
# and script-agnostic (plain token equality -- no stemming assumptions).

func StzResolveSemanticInLang(pcLang, pcWord)

	_cLang_ = StzLower(pcLang)
	if _cLang_ = "en"
		return StzResolveSemantic(pcWord)
	ok
	_aLex_ = _StzSemLangEntry(_cLang_)
	if len(_aLex_) = 0 or NOT isString(pcWord)
		return ""
	ok
	_w_ = StzLower(trim(pcWord))
	if StzLen(_w_) < 2
		return ""
	ok

	# canonical form: marks deleted, then VERIFIED affix stripping (any
	# chain landing on a known base -- wa+bi+al+word), falling back to
	# the one-shot canon
	_w_ = _StzSemLangNorm(_w_, _aLex_[7])
	_cV_ = _StzSemLangCanonVerified(_w_, _aLex_)
	if _cV_ != ""
		_w_ = _cV_
	else
		_w_ = _StzSemLangCanon(_w_, _aLex_[4], _aLex_[5], _aLex_[6])
	ok

	# the language's own DICTIONARY, consulted with the canonical form:
	# a pronoun-suffixed dictionary verb resolves without any pack phrase
	# (action-like ids only -- structural ids stay dictionary-exact)
	_cId_ = _StzSemLangMappingGet(_cLang_, _w_, _aLex_)
	if _cId_ != ""
		StzGrowSemanticOperations()
		return _cId_
	ok

	# exact single-word / joined-phrase hit
	_cId_ = _StzSemLangExactGet(_aLex_[3], _w_)
	if _cId_ != ""
		# a pack can target a GROWN id -- make sure the operations
		# table is grown before codegen looks the id up
		StzGrowSemanticOperations()
		return _cId_
	ok

	# ONE RANKER FOR ALL LANGUAGES: the same IDF discipline English gets,
	# over the pack bags (Unicode-safe: bags are pre-tokenized on spaces),
	# with the strict unique-winner rule
	_cId_ = _StzSemLangIdfBest([ _w_ ], _aLex_[2])
	if _cId_ != ""
		StzGrowSemanticOperations()
		return _cId_
	ok

	# neural rescue, exactly as English enjoys it: only when the lexical
	# passes found nothing and a model is loaded
	if StzHasNeuralModel()
		_aBags_ = _aLex_[2]
		_nB_ = len(_aBags_)
		_nBest_ = 0
		_nSecond_ = 0
		_nBestIdx_ = 0
		for _i_ = 1 to _nB_
			_n_ = StzSemanticSimilarity(_w_, _aBags_[_i_][2])
			if _n_ > _nBest_
				_nSecond_ = _nBest_
				_nBest_ = _n_
				_nBestIdx_ = _i_
			but _n_ > _nSecond_
				_nSecond_ = _n_
			ok
		next
		if _nBest_ >= 0.55 and (_nBest_ - _nSecond_) >= 0.05
			StzGrowSemanticOperations()
			return _aBags_[_nBestIdx_][1]
		ok
	ok
	return ""

	func @StzResolveSemanticInLang(pcLang, pcWord)
		return StzResolveSemanticInLang(pcLang, pcWord)

# Exact joined-phrase lookup, language-aware (used by phrase resolution).

func StzSemanticExactIdInLang(pcLang, pcJoined)
	_cLang_ = StzLower(pcLang)
	if _cLang_ = "en"
		return StzSemanticExactId(pcJoined)
	ok
	_aLex_ = _StzSemLangEntry(_cLang_)
	if len(_aLex_) = 0
		return ""
	ok
	_cId_ = _StzSemLangExactGet(_aLex_[3], StzLower(trim(pcJoined)))
	if _cId_ != ""
		# grown ids need the grown operations table at codegen time
		StzGrowSemanticOperations()
	ok
	return _cId_

	func @StzSemanticExactIdInLang(pcLang, pcJoined)
		return StzSemanticExactIdInLang(pcLang, pcJoined)

# Scored phrase resolution for pack languages: when no exact join matched,
# the same IDF discipline decides -- rare pack words carry the phrase
# ("vire les doublons": the unlisted verb contributes nothing, the rare
# 'doublons' decides). Strict unique winner, action ids by construction.
# acWords arrive already canonicalized by the engine.

func StzResolveSemanticPhraseInLang(pcLang, pacWords)
	_cLang_ = StzLower(pcLang)
	if _cLang_ = "en"
		return ""
	ok
	_aLex_ = _StzSemLangEntry(_cLang_)
	if len(_aLex_) = 0
		return ""
	ok
	_cId_ = _StzSemLangIdfBest(pacWords, _aLex_[2])
	if _cId_ != ""
		StzGrowSemanticOperations()
	ok
	return _cId_

	func @StzResolveSemanticPhraseInLang(pcLang, pacWords)
		return StzResolveSemanticPhraseInLang(pcLang, pacWords)

# IDF over the pack bags, Unicode-safe (bags are pre-tokenized on spaces).
# Score of a bag = sum of idf of the query words it contains; smoothed
# idf = 1 + ln(nBags / df)-ish via 1/(df). Strict unique winner or "".

func _StzSemLangIdfBest(pacWords, paBags)
	_nB_ = len(paBags)
	_nW_ = len(pacWords)
	if _nB_ = 0 or _nW_ = 0
		return ""
	ok
	# tokenize bags once
	_aTok_ = []
	for _i_ = 1 to _nB_
		_aTok_ + _StzSplitOnChar(paBags[_i_][2], " ")
	next
	# document frequency per query word
	_aDf_ = []
	for _j_ = 1 to _nW_
		_nDf_ = 0
		for _i_ = 1 to _nB_
			if ring_find(_aTok_[_i_], pacWords[_j_]) > 0
				_nDf_++
			ok
		next
		_aDf_ + _nDf_
	next
	# score bags
	_nBest_ = 0
	_nSecond_ = 0
	_nBestIdx_ = 0
	for _i_ = 1 to _nB_
		_nScore_ = 0
		for _j_ = 1 to _nW_
			if _aDf_[_j_] > 0 and ring_find(_aTok_[_i_], pacWords[_j_]) > 0
				_nScore_ += (1 / _aDf_[_j_])
			ok
		next
		if _nScore_ > _nBest_
			_nSecond_ = _nBest_
			_nBest_ = _nScore_
			_nBestIdx_ = _i_
		but _nScore_ > _nSecond_
			_nSecond_ = _nScore_
		ok
	next
	if _nBest_ > 0 and _nBest_ > _nSecond_
		return paBags[_nBestIdx_][1]
	ok
	return ""

#--- NATURAL PLANS ----------------------------------------------------------
# An INTENT becomes EXECUTABLE NATURAL CODE. Natural code is the library's
# first-class data medium, so the reflect layer answers "how do I do X?"
# with a runnable narration: a Create line for the live object, then the
# intent's steps split on their connectors. Each step is spoken in the
# same language the intent used -- the unified lexicon resolves it.

func StzNaturalPlanFor(pcIntent, pcTypeWord, pxValue)
	if NOT ( isString(pcIntent) and isString(pcTypeWord) )
		StzRaise("Incorrect params! pcIntent and pcTypeWord must be strings.")
	ok
	# connector normalization -> single "then" separators
	_cI_ = " " + trim(pcIntent) + " "
	_cI_ = StzReplace(_cI_, " and then ", " then ")
	_cI_ = StzReplace(_cI_, ", then ", " then ")
	_cI_ = StzReplace(_cI_, "; ", " then ")
	_cI_ = StzReplace(_cI_, ", ", " then ")
	_aSteps_ = _StzSemSplitOnWord(_cI_, "then")
	_cPlan_ = "Create a " + pcTypeWord + " with " + _StzSemValueLiteral(pxValue)
	_n_ = len(_aSteps_)
	for _i_ = 1 to _n_
		_cS_ = trim(_aSteps_[_i_])
		if _cS_ != ""
			_cPlan_ += nl + _cS_
		ok
	next
	return _cPlan_

	func @StzNaturalPlanFor(pcIntent, pcTypeWord, pxValue)
		return StzNaturalPlanFor(pcIntent, pcTypeWord, pxValue)

func _StzSemValueLiteral(pxValue)
	if isString(pxValue)
		if StzFindFirst(pxValue, "'") > 0
			return '"' + pxValue + '"'
		ok
		return "'" + pxValue + "'"
	but isNumber(pxValue)
		return "" + pxValue
	but isList(pxValue)
		return @@(pxValue)
	ok
	return "''"

# split a padded string on a whole WORD (space-bounded), keeping the pieces

func _StzSemSplitOnWord(pcStr, pcWord)
	_aParts_ = _StzSplitOnChar(StzReplace(pcStr, " " + pcWord + " ", char(1)), char(1))
	return _aParts_

#--- UNDERSTANDABILITY FEEDBACK --------------------------------------------
# A natural system's flexibility is measured by how it behaves when it does
# NOT understand: report the word, and suggest the nearest known one.

# The suggestion vocabulary of a language: dictionary words + exact-phrase
# keys (+ bag tokens for packs). English uses its dictionary + operation
# method names.

func StzSemVocabulary(pcLang)
	_cLang_ = StzLower(pcLang)
	_aOut_ = []
	if _cLang_ = "en"
		StzSemanticLexicon()
		_n_ = len($aStzSemExactNames)
		for _i_ = 1 to _n_
			_aOut_ + $aStzSemExactNames[_i_][1]
		next
	else
		_aLex_ = _StzSemLangEntry(_cLang_)
		if len(_aLex_) > 0
			_aOut_ = _StzSemCopyList(_aLex_[9])   # known bases
		ok
	ok
	# the language's dictionary words, both cases
	_n_ = len($aLanguageDefinitions)
	for _i_ = 1 to _n_
		_aDef_ = $aLanguageDefinitions[_i_]
		if StzLower(_aDef_[:code]) != _cLang_ or NOT HasKey(_aDef_, :semantic_mappings)
			loop
		ok
		_aM_ = _aDef_[:semantic_mappings]
		_nM_ = len(_aM_)
		for _j_ = 1 to _nM_
			_cW_ = StzLower(_aM_[_j_][:natural])
			if ring_find(_aOut_, _cW_) = 0
				_aOut_ + _cW_
			ok
		next
	next
	return _aOut_

	func @StzSemVocabulary(pcLang)
		return StzSemVocabulary(pcLang)

func _StzSemCopyList(paList)
	_aOut_ = []
	_n_ = len(paList)
	for _i_ = 1 to _n_
		_aOut_ + paList[_i_]
	next
	return _aOut_

# Nearest known word by edit distance (<= 2 for ASCII words, <= 4 for
# multibyte scripts where one letter = two bytes). Length + boundary-byte
# prefilters keep the DP off nearly all candidates.

func StzSuggestWord(pcLang, pcWord)
	_w_ = StzLower(trim(pcWord))
	_nW_ = len(_w_)
	if _nW_ < 3
		return ""
	ok
	_nMax_ = 2
	for _i_ = 1 to _nW_
		if ascii(_w_[_i_]) > 127
			_nMax_ = 4
			exit
		ok
	next
	_aVoc_ = StzSemVocabulary(pcLang)
	_n_ = len(_aVoc_)
	_cBest_ = ""
	_nBest_ = _nMax_ + 1
	for _i_ = 1 to _n_
		_cC_ = _aVoc_[_i_]
		_nC_ = len(_cC_)
		if _cC_ = _w_
			loop
		ok
		# prefilters: length window, then a shared boundary byte
		if _nC_ - _nW_ > _nMax_ or _nW_ - _nC_ > _nMax_
			loop
		ok
		if left(_cC_, 1) != left(_w_, 1) and right(_cC_, 1) != right(_w_, 1)
			loop
		ok
		_nD_ = _StzSemEditDistance(_w_, _cC_, _nBest_ - 1)
		if _nD_ >= 0 and _nD_ < _nBest_
			_nBest_ = _nD_
			_cBest_ = _cC_
			if _nBest_ <= 1
				exit
			ok
		ok
	next
	return _cBest_

	func @StzSuggestWord(pcLang, pcWord)
		return StzSuggestWord(pcLang, pcWord)

# Byte-level Levenshtein with a cutoff: returns the distance, or -1 when
# it exceeds pnCut (lets the caller skip hopeless candidates fast).

func _StzSemEditDistance(pcA, pcB, pnCut)
	_nA_ = len(pcA)
	_nB_ = len(pcB)
	_aPrev_ = []
	for _j_ = 0 to _nB_
		_aPrev_ + _j_
	next
	for _i_ = 1 to _nA_
		_aCur_ = [ _i_ ]
		_nMin_ = _i_
		for _j_ = 1 to _nB_
			_nCost_ = 1
			if pcA[_i_] = pcB[_j_]
				_nCost_ = 0
			ok
			_nV_ = _aPrev_[_j_ + 1] + 1          # deletion
			_nV2_ = _aCur_[_j_] + 1              # insertion
			if _nV2_ < _nV_ _nV_ = _nV2_ ok
			_nV2_ = _aPrev_[_j_] + _nCost_       # substitution
			if _nV2_ < _nV_ _nV_ = _nV2_ ok
			_aCur_ + _nV_
			if _nV_ < _nMin_ _nMin_ = _nV_ ok
		next
		if _nMin_ > pnCut
			return -1
		ok
		_aPrev_ = _aCur_
	next
	if _aPrev_[_nB_ + 1] > pnCut
		return -1
	ok
	return _aPrev_[_nB_ + 1]

#--- multilingual private helpers

func _StzSemLangEntry(pcCode)
	_n_ = len($aStzSemLangLex)
	for _i_ = 1 to _n_
		if $aStzSemLangLex[_i_][1] = pcCode
			return $aStzSemLangLex[_i_]
		ok
	next
	return []

# Content tokens of a pack phrase: lowered, marks stripped, this
# language's ignored words dropped, then CANONICALIZED (attached
# conjunction, article and pronoun suffix stripped). Script-agnostic.

func _StzSemLangTokens(pcPhrase, paIgnored, paArticles, paSuffixes, paConjunctions, paMarks)
	_aRaw_ = _StzSplitOnChar(trim(pcPhrase), " ")
	_aOut_ = []
	_n_ = len(_aRaw_)
	for _i_ = 1 to _n_
		_w_ = _StzSemLangNorm(StzLower(trim(_aRaw_[_i_])), paMarks)
		if _w_ = "" or ring_find(paIgnored, _w_) > 0
			loop
		ok
		_aOut_ + _StzSemLangCanon(_w_, paArticles, paSuffixes, paConjunctions)
	next
	return _aOut_

# Delete the language's marks (diacritics, tatweel) ANYWHERE in a token.

func _StzSemLangNorm(pcWord, paMarks)
	_w_ = pcWord
	_n_ = len(paMarks)
	for _i_ = 1 to _n_
		_w_ = StzReplace(_w_, paMarks[_i_], "")
	next
	return _w_

# The canonical (affix-free) form of a token: one attached ARTICLE prefix
# (Arabic al-, French l'/d') and one PRONOUN suffix (Arabic -ha/-hu/-hum)
# stripped, codepoint-safe, only while the remainder keeps >= 2 codepoints.
# Applied identically at registration AND query time, so both sides always
# meet on the same form.

# NB: deliberately BYTE-based (Ring's left/right/len): an affix is stripped
# only after an exact whole-affix byte match, which is UTF-8-safe -- while
# StzLeft/StzRight take BYTE counts although StzLen counts codepoints, so
# mixing them corrupts multibyte words (the trap this replaces). The >= 2
# remainder guard counts CODEPOINTS (StzLen) so it means two real letters.

func _StzSemLangCanon(pcWord, paArticles, paSuffixes, paConjunctions)
	# attached conjunction first (wa-al-takrarat -> al-takrarat), then
	# the article, then the pronoun suffix
	_w_ = _StzSemStripPrefix(pcWord, paConjunctions)
	_w_ = _StzSemStripPrefix(_w_, paArticles)
	_n_ = len(paSuffixes)
	for _i_ = 1 to _n_
		_cS_ = paSuffixes[_i_]
		_nS_ = len(_cS_)
		if len(_w_) > _nS_ and right(_w_, _nS_) = _cS_
			_cRest_ = left(_w_, len(_w_) - _nS_)
			if StzLen(_cRest_) >= 2
				_w_ = _cRest_
				exit
			ok
		ok
	next
	return _w_

func _StzSemStripPrefix(pcWord, paPrefixes)
	_w_ = pcWord
	_n_ = len(paPrefixes)
	for _i_ = 1 to _n_
		_cA_ = paPrefixes[_i_]
		_nA_ = len(_cA_)
		if len(_w_) > _nA_ and left(_w_, _nA_) = _cA_
			_cRest_ = right(_w_, len(_w_) - _nA_)
			if StzLen(_cRest_) >= 2
				return _cRest_
			ok
		ok
	next
	return _w_

# The engine's per-token seams (identity for English and for languages
# without morphology data). NORM deletes marks only (safe before ignored-
# word and dictionary checks); CANON = norm + affix stripping (for joins
# and fallback matching).

func StzSemLangNormToken(pcLang, pcWord)
	_cLang_ = StzLower(pcLang)
	if _cLang_ = "en"
		return pcWord
	ok
	_aLex_ = _StzSemLangEntry(_cLang_)
	if len(_aLex_) = 0
		return pcWord
	ok
	return _StzSemLangNorm(pcWord, _aLex_[7])

	func @StzSemLangNormToken(pcLang, pcWord)
		return StzSemLangNormToken(pcLang, pcWord)

func StzSemLangCanonToken(pcLang, pcWord)
	_cLang_ = StzLower(pcLang)
	if _cLang_ = "en"
		return pcWord
	ok
	_aLex_ = _StzSemLangEntry(_cLang_)
	if len(_aLex_) = 0
		return pcWord
	ok
	_w_ = _StzSemLangNorm(pcWord, _aLex_[7])
	# VERIFIED stripping first (any affix chain whose base the language
	# knows -- handles fused forms like wa+bi+al+word); the one-shot
	# unverified canon stays as the compatible fallback.
	_cV_ = _StzSemLangCanonVerified(_w_, _aLex_)
	if _cV_ != ""
		return _cV_
	ok
	return _StzSemLangCanon(_w_, _aLex_[4], _aLex_[5], _aLex_[6])

	func @StzSemLangCanonToken(pcLang, pcWord)
		return StzSemLangCanonToken(pcLang, pcWord)

# CONSTRUCT-AND-VERIFY affix stripping: breadth-first over single strips
# (conjunction / preposition / article prefixes, pronoun suffixes), accepting
# the FIRST chain whose remaining base is a KNOWN word of the language.
# Fewest-strips-first = safest reading. Risky affixes (prepositions) exist
# ONLY here, where a false strip cannot survive verification. Returns ""
# when no verified base is reachable (caller decides the fallback).

func _StzSemLangCanonVerified(pcWord, paLex)
	_aKnown_ = paLex[9]
	if ring_find(_aKnown_, pcWord) > 0
		return pcWord
	ok
	_aQueue_ = [ pcWord ]
	_aSeen_ = [ pcWord ]
	_nDepth_ = 0
	while len(_aQueue_) > 0 and _nDepth_ < 4
		_nDepth_++
		_aNext_ = []
		_nQ_ = len(_aQueue_)
		for _q_ = 1 to _nQ_
			_w_ = _aQueue_[_q_]
			_aCands_ = []
			# one prefix strip per class attempt + one suffix strip
			_aP1_ = _StzSemStripPrefix(_w_, paLex[6])   # conjunction
			_aP2_ = _StzSemStripPrefix(_w_, paLex[8])   # preposition
			_aP3_ = _StzSemStripPrefix(_w_, paLex[4])   # article
			_aCands_ + _aP1_
			_aCands_ + _aP2_
			_aCands_ + _aP3_
			_aCands_ + _StzSemStripSuffix(_w_, paLex[5])
			_nC_ = len(_aCands_)
			for _c_ = 1 to _nC_
				_cNew_ = _aCands_[_c_]
				if _cNew_ = _w_ or ring_find(_aSeen_, _cNew_) > 0
					loop
				ok
				if ring_find(_aKnown_, _cNew_) > 0
					return _cNew_
				ok
				_aSeen_ + _cNew_
				_aNext_ + _cNew_
			next
		next
		_aQueue_ = _aNext_
	end
	return ""

func _StzSemStripSuffix(pcWord, paSuffixes)
	_n_ = len(paSuffixes)
	for _i_ = 1 to _n_
		_cS_ = paSuffixes[_i_]
		_nS_ = len(_cS_)
		if len(pcWord) > _nS_ and right(pcWord, _nS_) = _cS_
			_cRest_ = left(pcWord, len(pcWord) - _nS_)
			if StzLen(_cRest_) >= 2
				return _cRest_
			ok
		ok
	next
	return pcWord

# Consult a language's OWN semantic_mappings with a canonical form --
# action-like ids only (a canonicalized noun must never resolve to an
# OBJECT_* and corrupt program structure). The mapping word is
# canonicalized the SAME way, so both sides always meet.

func _StzSemLangMappingGet(pcCode, pcCanon, paLex)
	_n_ = len($aLanguageDefinitions)
	for _i_ = 1 to _n_
		_aDef_ = $aLanguageDefinitions[_i_]
		if StzLower(_aDef_[:code]) != pcCode
			loop
		ok
		if NOT HasKey(_aDef_, :semantic_mappings)
			return ""
		ok
		_aM_ = _aDef_[:semantic_mappings]
		_nM_ = len(_aM_)
		for _j_ = 1 to _nM_
			_cW_ = _StzSemLangNorm(StzLower(_aM_[_j_][:natural]), paLex[7])
			_cW_ = _StzSemLangCanon(_cW_, paLex[4], paLex[5], paLex[6])
			if _cW_ = pcCanon and _StzSemIdEligible(_aM_[_j_][:semantic])
				return _aM_[_j_][:semantic]
			ok
		next
		return ""
	next
	return ""

# Add an exact entry; a joined phrase claimed by TWO different ids is
# ambiguous -- kill it (safety over coverage, same strict-winner spirit).

func _StzSemLangExactAdd(paExact, pcJoined, pcId)
	_n_ = len(paExact)
	for _i_ = 1 to _n_
		if paExact[_i_][1] = pcJoined
			if paExact[_i_][2] != pcId
				paExact[_i_][2] = ""
			ok
			return
		ok
	next
	paExact + [ pcJoined, pcId ]

func _StzSemLangExactGet(paExact, pcJoined)
	_n_ = len(paExact)
	for _i_ = 1 to _n_
		if paExact[_i_][1] = pcJoined
			return paExact[_i_][2]
		ok
	next
	return ""

# Deterministic exact-name lookup: is this (joined) word EXACTLY an
# operation's method name? Powers multi-word phrase resolution ("remove
# duplicates" -> removeduplicates -> METHOD_REMOVEDUPLICATES). Triggers
# the lazy growth on first use.

func StzSemanticExactId(pcWord)
	if NOT isString(pcWord) or pcWord = ""
		return ""
	ok
	StzSemanticLexicon()
	_w_ = lower(trim(pcWord))
	_n_ = len($aStzSemExactNames)
	for _i_ = 1 to _n_
		if $aStzSemExactNames[_i_][1] = _w_
			return $aStzSemExactNames[_i_][2]
		ok
	next
	return ""

	func @StzSemanticExactId(pcWord)
		return StzSemanticExactId(pcWord)

# Introspection: all candidates with their lexical scores, best first.

func StzResolveSemanticXT(pcWord)

	if NOT isString(pcWord)
		return []
	ok

	_aLex_ = StzSemanticLexicon()
	_nLex_ = len(_aLex_)
	_aTexts_ = []
	for _i_ = 1 to _nLex_
		_aTexts_ + _aLex_[_i_][2]
	next

	_aScores_ = _StzLexScoreAllIdf(lower(trim(pcWord)), _aTexts_)
	_aOut_ = []
	_nS_ = len(_aScores_)
	for _i_ = 1 to _nS_
		if _aScores_[_i_][2] > 0
			_aOut_ + [ _aLex_[_aScores_[_i_][1]][1], _aScores_[_i_][2] ]
		ok
	next

	_aOut_ = reverse(SortListsOn(_aOut_, 2))   # best first
	return _aOut_

	func @StzResolveSemanticXT(pcWord)
		return StzResolveSemanticXT(pcWord)

#--- PRIVATE HELPERS

# Only action-like IDs may be fallback targets: structural IDs (OBJECT_*,
# CREATE_OBJECT, VALUE_INDICATOR, CONTEXT_IGNORED) would corrupt programs.

func _StzSemIdEligible(pcId)
	if left(pcId, 7) = "METHOD_" or left(pcId, 9) = "MODIFIER_" or
	   left(pcId, 7) = "OUTPUT_"
		return TRUE
	ok
	return FALSE

# The KIND of an operation ("action" mutates / "query" returns); hand-
# authored ops without :kind default to action.

func _StzSemKindOf(pcId)
	_n_ = len($aSemanticOperations)
	for _i_ = 1 to _n_
		if $aSemanticOperations[_i_][:semantic_id] = pcId
			if HasKey($aSemanticOperations[_i_], :kind)
				return $aSemanticOperations[_i_][:kind]
			ok
			return "action"
		ok
	next
	return ""

func _StzSemOpKnown(pcId)
	# fast path: the flat id list maintained by StzGrowSemanticOperations()
	if len($aStzSemOpIds) > 0
		return ring_find($aStzSemOpIds, pcId) > 0
	ok
	_n_ = len($aSemanticOperations)
	for _i_ = 1 to _n_
		if $aSemanticOperations[_i_][:semantic_id] = pcId
			return TRUE
		ok
	next
	return FALSE

func _StzSemBagAdd(paBags, pcId, pcWords)
	if pcWords = ""
		return
	ok
	_n_ = len(paBags)
	for _i_ = 1 to _n_
		if paBags[_i_][1] = pcId
			paBags[_i_][2] += " " + pcWords
			return
		ok
	next
	paBags + [ pcId, pcWords ]

# The candidate form-family BASE words of a method name, lowercased --
# the operation a record's aka should fold into. Uppercased -> uppercase;
# IsUppercased -> (strip the predicate is/are/has) -> uppercase; fluent
# UppercaseQ -> uppercase. Reuses the reflect form grammar.

func _StzSemBaseCands(pcName)
	_aF_ = _StzFormOf(pcName)
	if _aF_[1] = "predicate" or _aF_[1] = "negative"
		if _aF_[2] = ""
			return []
		ok
		_aOut_ = [ _aF_[2] ]
		_aDeeper_ = _StzSiblingBases(_aF_[2])
		_nD_ = len(_aDeeper_)
		for _i_ = 1 to _nD_
			if ring_find(_aOut_, _aDeeper_[_i_]) = 0
				_aOut_ + _aDeeper_[_i_]
			ok
		next
		return _aOut_
	ok
	return _StzSiblingBases(pcName)
