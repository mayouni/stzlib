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

#--

func StzSemanticLexicon()

	if $bStzSemLexiconBuilt
		return $aStzSemLexicon
	ok

	_aBags_ = []

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
	# by the reflect layer. For each METHOD_* operation, collect the aka text
	# of the method AND of its form family (Uppercase / Uppercased /
	# IsUppercased...), exactly the _ActionsXT lesson: forms share the ID.

	_aRecs_ = []
	_aCls_ = [ "stzString", "stzList", "stzNumber" ]
	for _i_ = 1 to 3
		_aH_ = _StzHarvestChain(_aCls_[_i_])
		_nH_ = len(_aH_)
		for _j_ = 1 to _nH_
			_aRecs_ + _aH_[_j_]
		next
	next

	_nOps_ = len($aSemanticOperations)
	_nR_ = len(_aRecs_)

	for _i_ = 1 to _nOps_
		_aOp_ = $aSemanticOperations[_i_]
		_cId_ = _aOp_[:semantic_id]
		if left(_cId_, 7) != "METHOD_" or NOT HasKey(_aOp_, :stz_method)
			loop
		ok
		_cMeth_ = _aOp_[:stz_method]
		for _j_ = 1 to _nR_
			_aRec_ = _aRecs_[_j_]
			if len(_aRec_) >= 3 and _aRec_[3] != "" and
			   _StzSemInFamily(_aRec_[1], _cMeth_)
				_StzSemBagAdd(_aBags_, _cId_, _aRec_[3])
			ok
		next
	next

	$aStzSemLexicon = _aBags_
	$bStzSemLexiconBuilt = TRUE
	return $aStzSemLexicon

	func @StzSemanticLexicon()
		return StzSemanticLexicon()

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
	if _nBest_ > 0 and _nBest_ > _nSecond_   # strict unique winner only
		_cResolved_ = _aLex_[_nBestIdx_][1]
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

func _StzSemOpKnown(pcId)
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

# Is method-name pcName a FORM of canonical method pcMethod?
# Uppercase -> Uppercased / IsUppercased; Trim -> Trimmed (doubled consonant).

func _StzSemInFamily(pcName, pcMethod)
	_n_ = lower(pcName)
	_m_ = lower(pcMethod)
	if _n_ = _m_ or _n_ = (_m_ + "d") or _n_ = (_m_ + "ed") or
	   _n_ = (_m_ + right(_m_, 1) + "ed")
		return TRUE
	ok
	if left(_n_, 2) = "is" and StzLen(_n_) > 2
		return _StzSemInFamily(right(_n_, len(_n_) - 2), _m_)
	ok
	return FALSE
