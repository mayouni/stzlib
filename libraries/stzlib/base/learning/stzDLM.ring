# R4 step 7 -- stzDLM: THE DOMAIN LANGUAGE MODEL (Foundry rung 1)
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.9 + the DLM ruling: the
#  generic artifact the Model Foundry produces -- any project ships
#  its DLM FREE to its domain's users.)
#
#   oKB = new stzKnowledgeGraph("restaurant")    # a SCOPED domain brain
#   oKB.Know("margherita", "dish").
#       KnowRelation("margherita", "contains", "tomato-sauce")
#   oDLM = StzDlmQ(oKB)                          # forge from the KB object
#   #   (the DLM's domain is the brain's own id; the Q ctor is Softanza's
#   #    object-creation convention). Or build by hand: StzDlmQ("restaurant").
#   ? oDLM.Ask("what is margherita")             # deterministic answers
#   ? oDLM.Complete("margherita")                # domain-valid continuations
#   ? oDLM.GenerateCorpus()                      # facts as sentences --
#                                                # rung 2's teacher-free seed
#   oDLM.Save("restaurant")                      # -> restaurant.zdlm
#   oD2 = StzDlmQ("")                            # SELF-CONTAINED: it answers
#   oD2.LoadFrom("restaurant.zdlm")              # without the original KG
#
# RUNG 1 = ZERO NEURONS: vocabulary, facts and laws forged from the
# knowledge graph; every answer is a graph lookup with Why and
# certainty 1; everything outside the domain REFUSES (LAW 3). The
# neural rung (2) trains on GenerateCorpus() -- no remote teacher.

# The Q constructor (Softanza's object-creation convention). Polymorphic:
#   StzDlmQ(oKB)      -- oKB a stzKnowledgeGraph: forge a DLM from that
#                        domain brain; the DLM's domain IS the brain's id.
#   StzDlmQ("resto")  -- a plain string: an empty DLM to build by hand.
# Module-oriented: the domain brain is passed in as an OBJECT, never read
# from a hidden global. (A caller who wants the shared natural world passes
# DefaultKnowledgeGraph() itself -- that choice is then explicit.)
func StzDlmQ(pDomainOrKB)
	if IsStzKnowledgeGraph(pDomainOrKB)
		_oD_ = new stzDLM(pDomainOrKB.Id())
		_oD_.ForgeFrom(pDomainOrKB)
		return _oD_
	but isString(pDomainOrKB)
		return new stzDLM(pDomainOrKB)
	ok
	stzraise("StzDlmQ needs a stzKnowledgeGraph (its domain brain) or a " +
		"domain-name string -- build a brain with new stzKnowledgeGraph(id)." +
		"Know(...).KnowRelation(...).")



# Answers questions about one small domain from recorded facts, refuses everything outside it, and can train a tiny neural model on its own sentences.
#
# The first rung has no neurons: entities, relations and facts are kept as lists, every answer is a
# lookup with a reason, and a question about anything unknown is refused with the domain's name
# rather than guessed. It can be filled by hand, forged from a knowledge graph with StzDlmQ, and
# saved to a self-contained .zdlm file that another model reads back with LoadFrom. The second rung
# is a bigram network trained only on the sentences GenerateCorpus renders from the facts, with no
# remote teacher; it predicts and generates words but does not own the truth, which stays with Ask.
# Known limits today: names learned by hand are matched in lower case only, and the recorded laws
# are saved but not applied by Ask.
#
#   receiver   o1 = new stzDLM("restaurant")
#   example    o1.LearnEntity("margherita", "dish")
#              o1.LearnEntity("basil", "ingredient")
#              o1.LearnFact("margherita", "contains", "basil")
#              ? o1.Ask("what is margherita")
#              #--> Margherita is a dish.
#              ? o1.Ask("margherita contains?")
#              #--> Margherita contains basil.
#              ? o1.Ask("what is the weather")
#              #--> That is outside the 'restaurant' domain (I know 2 entities and 1 relations).
#              ? o1.Complete("margherita")[1]
#              #--> contains
#   see        stzKnowledgeGraph, StzDlmQ
class stzDLM from stzObject

	@cDomain = ""
	@aEntities = []     # [ name, type ] pairs (a name may bear several)
	@acRelations = []
	@aFacts = []        # [ s, p, o ]
	@aLaws = []         # [ relation, law ]
	@aGoldens = []      # [ question, expected answer ]
	@cWhy = ""
	# RUNG 2 -- the neural bigram LM (trained teacher-free on the corpus)
	@oNeural = ""
	@acNeuralVocab = []
	@bNeuralTrained = 0
	@cNeuralWhy = ""

	# Builds an empty domain language model for a named domain, to be filled by hand or forged from a knowledge graph.
	#
	#   pcDomain   the domain name, which answers that are refused quote
	#   returns    nothing; the object is built
	#   note       StzDlmQ forges one straight from a stzKnowledgeGraph, taking the graph's id as
	#              the domain
	#   see        SetDomain, ForgeFrom, Save
	def init(pcDomain)
		@cDomain = "" + pcDomain

	# Renames the domain the model answers for.
	#
	#   pcDomain   the new domain name
	#   returns    nothing
	#   see        Domain, init
	def SetDomain(pcDomain)
		@cDomain = "" + pcDomain

	# Returns the domain name.
	#
	#   returns    a text
	#   see        SetDomain
	def Domain()
		return @cDomain

	# Fills the model from a knowledge graph: is-a facts become entities, other facts become facts, constraints become laws, in lower case.
	#
	#   poKG       the stzKnowledgeGraph to forge from
	#   returns    the model itself, so calls chain
	#   note       the domain name is not changed; nothing already learned is duplicated
	#   see        LearnEntity, LearnFact, LearnLaw
	#@ aka  -- forging -------------------------------------------------------------
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

	# Adds an entity of a given type, so the model can say what it is.
	#
	#   pcName     the entity's name
	#   pcType     its type
	#   returns    the model itself, so calls chain
	#   note       an entity may bear several types; the same pair twice is kept once
	#   warning    a name written with capitals is stored as written, but Ask and Complete lower-
	#              case what they are given, so Pizza learned by hand is never found: learn lower-
	#              case names
	#   see        LearnFact, Lexicon, Ask
	def LearnEntity(pcName, pcType)
		_n_ = len(@aEntities)
		for _i_ = 1 to _n_
			if @aEntities[_i_][1] = pcName and @aEntities[_i_][2] = pcType
				return This
			ok
		next
		@aEntities + [ pcName, pcType ]
		return This

	# Adds a relation name the model may be asked about.
	#
	#   pcRel      the relation's name, such as contains
	#   returns    the model itself, so calls chain
	#   note       LearnFact adds its relation by itself
	#   see        LearnFact, Lexicon
	def LearnRelation(pcRel)
		if ring_find(@acRelations, pcRel) = 0
			@acRelations + pcRel
		ok
		return This

	# Adds a fact of the form subject, relation, object, and the relation with it.
	#
	#   pcS        the subject
	#   pcP        the relation
	#   pcO        the object
	#   returns    the model itself, so calls chain
	#   note       the same triple twice is kept once
	#   warning    names written with capitals are stored as written and are not found by Ask or
	#              Complete, which lower-case their input
	#   see        LearnEntity, LearnRelation, Ask
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

	# Records a law of a relation, such as transitive, which is saved with the model.
	#
	#   pcRel      the relation the law governs
	#   pcLaw      the law's name
	#   returns    the model itself, so calls chain
	#   note       the same pair twice is kept once
	#   warning    no method of the model reads the laws today: Ask answers from the recorded facts
	#              only, so a transitive law adds no chained answer
	#   see        ForgeFrom, Save
	def LearnLaw(pcRel, pcLaw)
		_n_ = len(@aLaws)
		for _i_ = 1 to _n_
			if @aLaws[_i_][1] = pcRel and @aLaws[_i_][2] = pcLaw
				return This
			ok
		next
		@aLaws + [ pcRel, pcLaw ]
		return This

	# Returns the model's vocabulary: its entities, their types and its relations.
	#
	#   returns    a hash list with the keys entities, types and relations, each a list of texts
	#   see        LearnEntity, Tokenizer
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

	# Answers a question from the recorded facts, or refuses when it is outside the domain.
	#
	#   pcQuestion   the question, in lower or upper case
	#   returns      a text, the answer or the refusal
	#   note         what is X lists the types of X; X followed by a relation lists its objects; the
	#                reason of the last call is in Why
	#   warning      a question that names no known entity gets a refusal that quotes the domain and
	#                the counts, not an invented answer; an entity learned with capitals is not
	#                recognized
	#   see          Why, Complete, AddGolden
	#@ aka  -- the language surface -------------------------------------------------
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

	# Returns what may follow a word: an entity's relations, a relation's objects, or the entities that start with a fragment.
	#
	#   pcPartial   the entity, relation or fragment, lower-cased before matching
	#   returns     a list of texts; an empty list when nothing matches
	#   note        the three readings are tried in that order and the first with a result wins
	#   see         Ask, Lexicon
	#@ aka  domain-valid continuations (the constrained-grammar spirit): an entity completes with its relations; a relation with its objects; a fragment with matching entities
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

	# Returns every entity and fact as a short sentence, the teacher-free training text of the neural rung.
	#
	#   returns    a list of texts
	#   note       an entity gives name is a type, and a fact gives subject relation object
	#   see        TrainNeuralRung, Tokenizer
	#@ aka  every fact rendered as a sentence -- RUNG 2's teacher-free training corpus (correct by construction: these ARE the facts)
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

	# Returns the closed vocabulary of the domain, with the unknown-word marker first.
	#
	#   returns    a list of texts, the first being <unk>
	#   see        Tokenize, Lexicon
	#@ aka  R4 step 8 -- the word-level DOMAIN TOKENIZER: a closed domain earns a closed vocabulary (id 1 = <unk>, then entities, types, relations, and every corpus word). The neural rung trains over these ids; the deterministic rung already speaks them.
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

	# Returns the vocabulary position of each word of a text.
	#
	#   pcText     the text to split into words
	#   returns    a list of numbers, one for each word
	#   note       a word outside the vocabulary gives 1, the position of <unk>; text is lower-cased
	#              and full stops are dropped
	#   see        Tokenizer
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

	# Returns the reason behind the last Ask.
	#
	#   returns    a text; empty before any question
	#   see        Ask
	def Why()
		return @cWhy

	# Trains a small bigram network on the domain's own sentences, so that it can predict which word follows which.
	#
	#   nEpochs    the number of passes over the corpus
	#   returns    the model itself, so calls chain
	#   note       no remote teacher is used; the deterministic answers of Ask are not affected
	#   warning    raises an error when the domain holds nothing to learn
	#   see        NextToken, NeuralWhy, GenerateCorpus
	#@ aka  -- RUNG 2: the NEURAL domain LM ----------------------------------------- A neural BIGRAM language model: one-hot(current token) -> softmax over the domain vocabulary -> next token. Trained ONLY on GenerateCorpus() (sentences correct-by-construction), no remote teacher -- the whole point of the Foundry: a project's own knowledge becomes a model that GENERATES domain text. Rung 1 (deterministic Ask
	def TrainNeuralRung(nEpochs)
		if nEpochs < 1
			nEpochs = 300
		ok
		_acV_ = This.Tokenizer()
		_nV_ = len(_acV_)
		if _nV_ < 2
			stzraise("Nothing to train: the domain corpus is empty.")
		ok
		# bigram (current -> next) pairs from the corpus, one-hot encoded
		_aIn_ = []
		_aTg_ = []
		_acS_ = This.GenerateCorpus()
		_nS_ = len(_acS_)
		for _s_ = 1 to _nS_
			_aIds_ = This.Tokenize(_acS_[_s_])
			_nT_ = len(_aIds_)
			for _t_ = 1 to _nT_ - 1
				_aIn_ + This._OneHot(_aIds_[_t_], _nV_)
				_aTg_ + This._OneHot(_aIds_[_t_ + 1], _nV_)
			next
		next
		if len(_aIn_) = 0
			stzraise("No bigrams to train on.")
		ok
		# a pure softmax layer over one-hot input IS a neural bigram LM
		# (multinomial logistic regression -> the corpus bigram law)
		_oNet_ = new stzNeuralNetwork([ :Inputs = _nV_ ])
		_oNet_.AddDenseLayer(_nV_, :Softmax)
		_oTr_ = new stzTrainer()
		_oTr_.SetLearningRate(0.5)
		_oTr_.Train(_oNet_, _aIn_, _aTg_, nEpochs)
		@oNeural = _oNet_
		@acNeuralVocab = _acV_
		@bNeuralTrained = 1
		@cNeuralWhy = "neural bigram rung: " + len(_aIn_) + " pairs over a " +
			_nV_ + "-word vocab; " + _oTr_.Why()
		return This

	# TRUE if the neural rung has been trained.
	#
	#   returns    TRUE or FALSE
	#   see        TrainNeuralRung
	def IsNeuralTrained()
		return @bNeuralTrained

	# Returns a summary of the last training: pairs, vocabulary size, epochs and loss.
	#
	#   returns    a text; empty before training
	#   see        TrainNeuralRung
	def NeuralWhy()
		return @cNeuralWhy

	# Returns the word the neural rung predicts to follow a word.
	#
	#   pcWord     the word, lower-cased before use
	#   returns    a text
	#   note       a bigram sees one word, so it predicts the most frequent follower of the corpus
	#   warning    raises an error before TrainNeuralRung; a word outside the vocabulary is read as
	#              the unknown marker
	#   see        NextTokenConfidence, NeuralGenerate
	#@ aka  the token (string) the neural rung predicts to follow a word
	def NextToken(pcWord)
		if not @bNeuralTrained
			stzraise("Train the neural rung first: TrainNeuralRung(n).")
		ok
		_nId_ = ring_find(@acNeuralVocab, StzLower(ring_trim("" + pcWord)))
		if _nId_ = 0
			_nId_ = 1
		ok
		_aP_ = @oNeural.Predict(This._OneHot(_nId_, len(@acNeuralVocab)))
		return @acNeuralVocab[This._ArgMax(_aP_)]

	# Returns the probability the neural rung gives to the word it predicts.
	#
	#   pcWord     the word, lower-cased before use
	#   returns    a number between 0 and 1
	#   warning    raises an error before TrainNeuralRung
	#   see        NextToken
	#@ aka  the neural rung's confidence in its predicted next token (a real probability -- softmax normalizes over the whole vocabulary)
	def NextTokenConfidence(pcWord)
		if not @bNeuralTrained
			stzraise("Train the neural rung first: TrainNeuralRung(n).")
		ok
		_nId_ = ring_find(@acNeuralVocab, StzLower(ring_trim("" + pcWord)))
		if _nId_ = 0
			_nId_ = 1
		ok
		_aP_ = @oNeural.Predict(This._OneHot(_nId_, len(@acNeuralVocab)))
		return _aP_[This._ArgMax(_aP_)]

	# Returns a seed word followed by the words the neural rung predicts one after the other.
	#
	#   pcSeed     the first word
	#   nSteps     how many words to add
	#   returns    a text of words separated by spaces
	#   note       the rung learns word transitions of the corpus and does not own the truth, which
	#              stays with Ask; the text can wander
	#   warning    raises an error before TrainNeuralRung
	#   see        NextToken
	#@ aka  greedy generation: a seed word + nSteps neural next-tokens
	def NeuralGenerate(pcSeed, nSteps)
		if nSteps < 1
			nSteps = 4
		ok
		_cCur_ = StzLower(ring_trim("" + pcSeed))
		_acOut_ = [ _cCur_ ]
		for _i_ = 1 to nSteps
			_cNext_ = This.NextToken(_cCur_)
			_acOut_ + _cNext_
			_cCur_ = _cNext_
		next
		return JoinXT(_acOut_, " ")

	# Writes the trained neural rung to a GGUF file.
	#
	#   pcFile     the path of the file to write
	#   returns    the path of the file written
	#   warning    raises an error before TrainNeuralRung
	#   see        TrainNeuralRung
	#@ aka  export the trained neural rung as a real .gguf (the Foundry artifact)
	def ExportNeuralGguf(pcFile)
		if not @bNeuralTrained
			stzraise("Train the neural rung first: TrainNeuralRung(n).")
		ok
		return @oNeural.ExportToGguf(pcFile, @cDomain + "-bigram")

	def _OneHot(nId, nV)
		_a_ = []
		for _i_ = 1 to nV
			if _i_ = nId
				_a_ + 1
			else
				_a_ + 0
			ok
		next
		return _a_

	def _ArgMax(paV)
		_nArg_ = 1
		_nMax_ = paV[1]
		_n_ = len(paV)
		for _i_ = 2 to _n_
			if paV[_i_] > _nMax_
				_nMax_ = paV[_i_]
				_nArg_ = _i_
			ok
		next
		return _nArg_

	# Records a question with the answer it must always give, to be checked by RunGoldens.
	#
	#   pcQuestion   the question to ask
	#   pcExpected   the exact answer expected
	#   returns      nothing; use AddGoldenQ to chain
	#   note         the same pair twice is kept twice
	#   see          RunGoldens, Ask
	#@ aka  -- goldens ---------------------------------------------------------------
	def AddGolden(pcQuestion, pcExpected)
		@aGoldens + [ "" + pcQuestion, "" + pcExpected ]

		def AddGoldenQ(pcQuestion, pcExpected)
			This.AddGolden(pcQuestion, pcExpected)
			return This

	# Asks every recorded question and compares each answer with the expected one.
	#
	#   returns    a hash list with the keys total, passed and failed, the last a list of hash lists
	#              with question, expected and got
	#   see        AddGolden, Ask
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

	# Reads a saved bundle into this model, so it answers without the original graph.
	#
	#   pcFile     the path of a bundle written by Save
	#   returns    the model itself, so calls chain
	#   note       it adds to what the model already holds and sets the domain name from the file; a
	#              name with a vertical bar was not saved readable and is dropped silently
	#   warning    raises an error when the file cannot be opened
	#   see        Save
	#@ aka  -- persistence (*.zdlm -- SELF-CONTAINED) --------------------------------- (extension ruling 2026-07-14: Softanza formats are z + a short abbreviation -- .zdlm, .zknw, .zcnv, .zrlz)
	def LoadFrom(pcFile)
	_cContent_ = StzReplace(read(pcFile), char(13), "")
		_acLines_ = StzSplit(_cContent_, char(10))
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
					This.SetDomain(_acQ_[2])
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
					This.LearnEntity(ring_trim(_acP_[1]), ring_trim(_acP_[2]))
				ok
			but _cSection_ = "relations"
				This.LearnRelation(_cL_)
			but _cSection_ = "facts"
				_acP_ = StzSplit(_cL_, "|")
				if len(_acP_) = 3
					This.LearnFact(ring_trim(_acP_[1]), ring_trim(_acP_[2]),
						ring_trim(_acP_[3]))
				ok
			but _cSection_ = "laws"
				_acP_ = StzSplit(_cL_, "|")
				if len(_acP_) = 2
					This.LearnLaw(ring_trim(_acP_[1]), ring_trim(_acP_[2]))
				ok
			but _cSection_ = "goldens"
				_acP_ = StzSplit(_cL_, "|")
				if len(_acP_) = 2
					This.AddGolden(ring_trim(_acP_[1]), ring_trim(_acP_[2]))
				ok
			ok
		next
		return This

	# Writes the domain, entities, relations, facts, laws and goldens to a text bundle.
	#
	#   pcFile     the path to write
	#   returns    the path written, with the .zdlm extension added when missing
	#   note       a name that contains a vertical bar cannot be read back by LoadFrom; the neural
	#              rung is not saved
	#   see        LoadFrom
	def Save(pcFile)
		if StzRight(pcFile, 5) != ".zdlm"
			pcFile += ".zdlm"
		ok
		_c_ = 'dlm "' + @cDomain + '"' + char(10)
		_c_ += "entities" + char(10)
		_n_ = len(@aEntities)
		for _i_ = 1 to _n_
			_c_ += "    " + @aEntities[_i_][1] + " | " + @aEntities[_i_][2] + char(10)
		next
		_c_ += "relations" + char(10)
		_n_ = len(@acRelations)
		for _i_ = 1 to _n_
			_c_ += "    " + @acRelations[_i_] + char(10)
		next
		_c_ += "facts" + char(10)
		_n_ = len(@aFacts)
		for _i_ = 1 to _n_
			_c_ += "    " + @aFacts[_i_][1] + " | " + @aFacts[_i_][2] + " | " +
				@aFacts[_i_][3] + char(10)
		next
		_c_ += "laws" + char(10)
		_n_ = len(@aLaws)
		for _i_ = 1 to _n_
			_c_ += "    " + @aLaws[_i_][1] + " | " + @aLaws[_i_][2] + char(10)
		next
		_c_ += "goldens" + char(10)
		_n_ = len(@aGoldens)
		for _i_ = 1 to _n_
			_c_ += "    " + @aGoldens[_i_][1] + " | " + @aGoldens[_i_][2] + char(10)
		next
		write(pcFile, _c_)
		return pcFile
