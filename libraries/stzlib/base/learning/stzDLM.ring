# R4 step 7 -- stzDLM: THE DOMAIN LANGUAGE MODEL (Foundry rung 1)
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.9 + the DLM ruling: the
#  generic artifact the Model Foundry produces -- any project ships
#  its DLM FREE to its domain's users.)
#
#   StzKnow("margherita", "dish") ...            # the brain (R1)
#   oDLM = StzForgeDLM("restaurant")             # compose-and-go
#   ? oDLM.Ask("what is margherita")             # deterministic answers
#   ? oDLM.Complete("margherita")                # domain-valid continuations
#   ? oDLM.GenerateCorpus()                      # facts as sentences --
#                                                # rung 2's teacher-free seed
#   oDLM.Save("restaurant")                      # -> restaurant.zdlm
#   oD2 = StzLoadDLM("restaurant.zdlm")          # SELF-CONTAINED: answers
#                                                # without the original KG
#
# RUNG 1 = ZERO NEURONS: vocabulary, facts and laws forged from the
# knowledge graph; every answer is a graph lookup with Why and
# certainty 1; everything outside the domain REFUSES (LAW 3). The
# neural rung (2) trains on GenerateCorpus() -- no remote teacher.

func StzForgeDLM(pcDomain)
	_oD_ = new stzDLM(pcDomain)
	_oD_.ForgeFrom(DefaultKnowledgeGraph())
	return _oD_

func StzLoadDLM(pcFile)
	_cContent_ = StzReplace(read(pcFile), char(13), "")
	_acLines_ = StzSplit(_cContent_, char(10))
	_oD_ = new stzDLM("")
	_cSection_ = ""
	_nLen_ = len(_acLines_)
	for _i_ = 1 to _nLen_
		_cL_ = ring_trim(_acLines_[_i_])
		if _cL_ = ""
			loop
		ok
		if StzLeft(_cL_, 4) = 'dlm '
			_acQ_ = StzSplit(_cL_, '"')
			if len(_acQ_) >= 2
				_oD_.SetDomain(_acQ_[2])
			ok
		but _cL_ = "entities"
			_cSection_ = "entities"
		but _cL_ = "relations"
			_cSection_ = "relations"
		but _cL_ = "facts"
			_cSection_ = "facts"
		but _cL_ = "laws"
			_cSection_ = "laws"
		but _cL_ = "goldens"
			_cSection_ = "goldens"
		but _cSection_ = "entities"
			_acP_ = StzSplit(_cL_, "|")
			if len(_acP_) = 2
				_oD_.LearnEntity(ring_trim(_acP_[1]), ring_trim(_acP_[2]))
			ok
		but _cSection_ = "relations"
			_oD_.LearnRelation(_cL_)
		but _cSection_ = "facts"
			_acP_ = StzSplit(_cL_, "|")
			if len(_acP_) = 3
				_oD_.LearnFact(ring_trim(_acP_[1]), ring_trim(_acP_[2]),
					ring_trim(_acP_[3]))
			ok
		but _cSection_ = "laws"
			_acP_ = StzSplit(_cL_, "|")
			if len(_acP_) = 2
				_oD_.LearnLaw(ring_trim(_acP_[1]), ring_trim(_acP_[2]))
			ok
		but _cSection_ = "goldens"
			_acP_ = StzSplit(_cL_, "|")
			if len(_acP_) = 2
				_oD_.AddGolden(ring_trim(_acP_[1]), ring_trim(_acP_[2]))
			ok
		ok
	next
	return _oD_


class stzDLM from stzObject

	@cDomain = ""
	@aEntities = []     # [ name, type ] pairs (a name may bear several)
	@acRelations = []
	@aFacts = []        # [ s, p, o ]
	@aLaws = []         # [ relation, law ]
	@aGoldens = []      # [ question, expected answer ]
	@cWhy = ""

	def init(pcDomain)
		@cDomain = "" + pcDomain

	def SetDomain(pcDomain)
		@cDomain = "" + pcDomain

	def Domain()
		return @cDomain

	#-- forging -------------------------------------------------------------

	def ForgeFrom(poKG)
		_aF_ = poKG.Facts()
		_n_ = len(_aF_)
		for _i_ = 1 to _n_
			_cS_ = StzLower("" + _aF_[_i_][1])
			_cP_ = StzLower("" + _aF_[_i_][2])
			_cO_ = StzLower("" + _aF_[_i_][3])
			if _cP_ = "is-a" or _cP_ = "isa" or _cP_ = "is_a"
				This.LearnEntity(_cS_, _cO_)
			else
				This.LearnFact(_cS_, _cP_, _cO_)
			ok
		next
		_aOnt_ = poKG.Ontology()
		_n_ = len(_aOnt_)
		for _i_ = 1 to _n_
			_aCons_ = _aOnt_[_i_][:constraints]
			_nC_ = len(_aCons_)
			for _j_ = 1 to _nC_
				This.LearnLaw(StzLower("" + _aOnt_[_i_][:property]),
					StzLower("" + _aCons_[_j_]))
			next
		next
		return This

	def LearnEntity(pcName, pcType)
		_n_ = len(@aEntities)
		for _i_ = 1 to _n_
			if @aEntities[_i_][1] = pcName and @aEntities[_i_][2] = pcType
				return This
			ok
		next
		@aEntities + [ pcName, pcType ]
		return This

	def LearnRelation(pcRel)
		if ring_find(@acRelations, pcRel) = 0
			@acRelations + pcRel
		ok
		return This

	def LearnFact(pcS, pcP, pcO)
		_n_ = len(@aFacts)
		for _i_ = 1 to _n_
			if @aFacts[_i_][1] = pcS and @aFacts[_i_][2] = pcP and
			   @aFacts[_i_][3] = pcO
				return This
			ok
		next
		@aFacts + [ pcS, pcP, pcO ]
		This.LearnRelation(pcP)
		return This

	def LearnLaw(pcRel, pcLaw)
		_n_ = len(@aLaws)
		for _i_ = 1 to _n_
			if @aLaws[_i_][1] = pcRel and @aLaws[_i_][2] = pcLaw
				return This
			ok
		next
		@aLaws + [ pcRel, pcLaw ]
		return This

	def Lexicon()
		_acE_ = []
		_acT_ = []
		_n_ = len(@aEntities)
		for _i_ = 1 to _n_
			if ring_find(_acE_, @aEntities[_i_][1]) = 0
				_acE_ + @aEntities[_i_][1]
			ok
			if ring_find(_acT_, @aEntities[_i_][2]) = 0
				_acT_ + @aEntities[_i_][2]
			ok
		next
		return [ :entities = _acE_, :types = _acT_, :relations = @acRelations ]

	#-- the language surface -------------------------------------------------

	# deterministic domain answering: a graph lookup that SPEAKS --
	# and REFUSES outside its domain (LAW 3)
	def Ask(pcQuestion)
		_aX_ = This.AskXT(pcQuestion)
		return _aX_[:answer]

	def AskXT(pcQuestion)
		_cQ_ = " " + StzLower(ring_trim("" + pcQuestion)) + " "
		_cQ_ = StzReplace(StzReplace(_cQ_, "?", " "), "'", " ")

		# the mentioned entity (longest match wins)
		_cE_ = ""
		_n_ = len(@aEntities)
		for _i_ = 1 to _n_
			_cCand_ = @aEntities[_i_][1]
			if len(StzFind(" " + _cCand_ + " ", _cQ_)) > 0
				if StzLen(_cCand_) > StzLen(_cE_)
					_cE_ = _cCand_
				ok
			ok
		next
		# also allow subjects that only appear in facts
		_nF_ = len(@aFacts)
		for _i_ = 1 to _nF_
			if len(StzFind(" " + @aFacts[_i_][1] + " ", _cQ_)) > 0
				if StzLen(@aFacts[_i_][1]) > StzLen(_cE_)
					_cE_ = @aFacts[_i_][1]
				ok
			ok
		next

		# the mentioned relation
		_cR_ = ""
		_nR_ = len(@acRelations)
		for _i_ = 1 to _nR_
			_cCandR_ = StzReplace(@acRelations[_i_], "-", " ")
			if len(StzFind(@acRelations[_i_], _cQ_)) > 0 or
			   len(StzFind(_cCandR_, _cQ_)) > 0
				_cR_ = @acRelations[_i_]
			ok
		next

		if _cE_ = ""
			@cWhy = "no domain entity recognized"
			return [ :answer = "That is outside the '" + @cDomain +
				"' domain (I know " + len(This.Lexicon()[:entities]) +
				" entities and " + len(@acRelations) + " relations).",
				:certainty = 1, :why = @cWhy, :refused = 1 ]
		ok

		# "what is E" -> its types
		if _cR_ = "" or len(StzFind("what is", _cQ_)) > 0
			_acT_ = []
			for _i_ = 1 to _n_
				if @aEntities[_i_][1] = _cE_
					_acT_ + @aEntities[_i_][2]
				ok
			next
			if len(_acT_) > 0
				@cWhy = "recorded fact: '" + _cE_ + "' is-a " + JoinXT(_acT_, ", ")
				return [ :answer = StzUpper(StzLeft(_cE_, 1)) +
					StzRight(_cE_, StzLen(_cE_) - 1) + " is a " +
					JoinXT(_acT_, " and a ") + ".",
					:certainty = 1, :why = @cWhy, :refused = 0 ]
			ok
		ok

		# "E <relation> ?" -> the objects (direct, then lawful chain)
		if _cR_ != ""
			_acO_ = []
			for _i_ = 1 to _nF_
				if @aFacts[_i_][1] = _cE_ and @aFacts[_i_][2] = _cR_
					_acO_ + @aFacts[_i_][3]
				ok
			next
			if len(_acO_) > 0
				@cWhy = "recorded fact(s): '" + _cE_ + "' " + _cR_ + " " +
					JoinXT(_acO_, ", ")
				return [ :answer = StzUpper(StzLeft(_cE_, 1)) +
					StzRight(_cE_, StzLen(_cE_) - 1) + " " + _cR_ + " " +
					JoinXT(_acO_, " and ") + ".",
					:certainty = 1, :why = @cWhy, :refused = 0 ]
			ok
			@cWhy = "no recorded '" + _cR_ + "' fact for '" + _cE_ + "'"
			return [ :answer = "I hold no '" + _cR_ + "' knowledge about '" +
				_cE_ + "'.", :certainty = 1, :why = @cWhy, :refused = 1 ]
		ok

		@cWhy = "entity known, question shape not"
		return [ :answer = "I know '" + _cE_ + "', but not what you ask about it.",
			:certainty = 1, :why = @cWhy, :refused = 1 ]

	# domain-valid continuations (the constrained-grammar spirit):
	# an entity completes with its relations; a relation with its
	# objects; a fragment with matching entities
	def Complete(pcPartial)
		_cP_ = StzLower(ring_trim("" + pcPartial))
		_acOut_ = []
		_nF_ = len(@aFacts)
		# entity -> relations it bears
		for _i_ = 1 to _nF_
			if @aFacts[_i_][1] = _cP_
				if ring_find(_acOut_, @aFacts[_i_][2]) = 0
					_acOut_ + @aFacts[_i_][2]
				ok
			ok
		next
		if len(_acOut_) > 0
			return _acOut_
		ok
		# relation -> its known objects
		for _i_ = 1 to _nF_
			if @aFacts[_i_][2] = _cP_
				if ring_find(_acOut_, @aFacts[_i_][3]) = 0
					_acOut_ + @aFacts[_i_][3]
				ok
			ok
		next
		if len(_acOut_) > 0
			return _acOut_
		ok
		# fragment -> entities starting with it
		_n_ = len(@aEntities)
		for _i_ = 1 to _n_
			if StzLeft(@aEntities[_i_][1], StzLen(_cP_)) = _cP_
				if ring_find(_acOut_, @aEntities[_i_][1]) = 0
					_acOut_ + @aEntities[_i_][1]
				ok
			ok
		next
		return _acOut_

	# every fact rendered as a sentence -- RUNG 2's teacher-free
	# training corpus (correct by construction: these ARE the facts)
	def GenerateCorpus()
		_acOut_ = []
		_n_ = len(@aEntities)
		for _i_ = 1 to _n_
			_acOut_ + (@aEntities[_i_][1] + " is a " + @aEntities[_i_][2] + ".")
		next
		_nF_ = len(@aFacts)
		for _i_ = 1 to _nF_
			_acOut_ + (@aFacts[_i_][1] + " " + @aFacts[_i_][2] + " " +
				@aFacts[_i_][3] + ".")
		next
		return _acOut_

	# R4 step 8 -- the word-level DOMAIN TOKENIZER: a closed domain
	# earns a closed vocabulary (id 1 = <unk>, then entities, types,
	# relations, and every corpus word). The neural rung trains over
	# these ids; the deterministic rung already speaks them.
	def Tokenizer()
		_acV_ = [ "<unk>" ]
		_aLex_ = This.Lexicon()
		_acAll_ = _aLex_[:entities]
		_n_ = len(_acAll_)
		for _i_ = 1 to _n_
			if ring_find(_acV_, _acAll_[_i_]) = 0
				_acV_ + _acAll_[_i_]
			ok
		next
		_acAll_ = _aLex_[:types]
		_n_ = len(_acAll_)
		for _i_ = 1 to _n_
			if ring_find(_acV_, _acAll_[_i_]) = 0
				_acV_ + _acAll_[_i_]
			ok
		next
		_acAll_ = _aLex_[:relations]
		_n_ = len(_acAll_)
		for _i_ = 1 to _n_
			if ring_find(_acV_, _acAll_[_i_]) = 0
				_acV_ + _acAll_[_i_]
			ok
		next
		_acSents_ = This.GenerateCorpus()
		_nS_ = len(_acSents_)
		for _s_ = 1 to _nS_
			_acW_ = StzSplit(StzReplace(StzLower(_acSents_[_s_]), ".", ""), " ")
			_nW_ = len(_acW_)
			for _w_ = 1 to _nW_
				_cW_ = ring_trim(_acW_[_w_])
				if _cW_ != "" and ring_find(_acV_, _cW_) = 0
					_acV_ + _cW_
				ok
			next
		next
		return _acV_

	def Tokenize(pcText)
		_acV_ = This.Tokenizer()
		_acW_ = StzSplit(StzReplace(StzLower(ring_trim("" + pcText)), ".", ""), " ")
		_aOut_ = []
		_nW_ = len(_acW_)
		for _w_ = 1 to _nW_
			_cW_ = ring_trim(_acW_[_w_])
			if _cW_ != ""
				_nId_ = ring_find(_acV_, _cW_)
				if _nId_ = 0
					_nId_ = 1
				ok
				_aOut_ + _nId_
			ok
		next
		return _aOut_

	def Why()
		return @cWhy

	#-- goldens ---------------------------------------------------------------

	def AddGolden(pcQuestion, pcExpected)
		@aGoldens + [ "" + pcQuestion, "" + pcExpected ]
		return This

	def RunGoldens()
		_nPass_ = 0
		_aFailed_ = []
		_n_ = len(@aGoldens)
		for _i_ = 1 to _n_
			_cGot_ = This.Ask(@aGoldens[_i_][1])
			if _cGot_ = @aGoldens[_i_][2]
				_nPass_++
			else
				_aFailed_ + [ :question = @aGoldens[_i_][1],
					:expected = @aGoldens[_i_][2], :got = _cGot_ ]
			ok
		next
		return [ :total = _n_, :passed = _nPass_, :failed = _aFailed_ ]

	#-- persistence (*.zdlm -- SELF-CONTAINED) ---------------------------------
	# (extension ruling 2026-07-14: Softanza formats are z + a short
	#  abbreviation -- .zdlm, .zknw, .zcnv, .zrlz)

	def Save(pcFile)
		if StzRight(pcFile, 5) != ".zdlm"
			pcFile += ".zdlm"
		ok
		_c_ = 'dlm "' + @cDomain + '"' + NL
		_c_ += "entities" + NL
		_n_ = len(@aEntities)
		for _i_ = 1 to _n_
			_c_ += "    " + @aEntities[_i_][1] + " | " + @aEntities[_i_][2] + NL
		next
		_c_ += "relations" + NL
		_n_ = len(@acRelations)
		for _i_ = 1 to _n_
			_c_ += "    " + @acRelations[_i_] + NL
		next
		_c_ += "facts" + NL
		_n_ = len(@aFacts)
		for _i_ = 1 to _n_
			_c_ += "    " + @aFacts[_i_][1] + " | " + @aFacts[_i_][2] + " | " +
				@aFacts[_i_][3] + NL
		next
		_c_ += "laws" + NL
		_n_ = len(@aLaws)
		for _i_ = 1 to _n_
			_c_ += "    " + @aLaws[_i_][1] + " | " + @aLaws[_i_][2] + NL
		next
		_c_ += "goldens" + NL
		_n_ = len(@aGoldens)
		for _i_ = 1 to _n_
			_c_ += "    " + @aGoldens[_i_][1] + " | " + @aGoldens[_i_][2] + NL
		next
		write(pcFile, _c_)
		return pcFile
