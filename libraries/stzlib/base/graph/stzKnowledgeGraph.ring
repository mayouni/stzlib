func StzKnowledgeGraphQ(pcId)
	return new stzKnowledgeGraph(pcId)

	func StzKnowGraphQ(pcId)
		return new stzKnowledgeGraph(pcId)

func IsStzKnowledgeGraph(pObj)
	if isObject(pObj) and classname(pObj) = "stzknowledgegraph"
		return 1
	ok
	return 0

	func IsAStzKnowledgeGraph(pObj)
		return IsStzKnowledgeGraph(pObj)

	func IsStzKnowGraph(pObj)
		return IsStzKnowledgeGraph(pObj)

	func IsAStzKnowGraph(pObj)
		return IsStzKnowledgeGraph(pObj)

# --- .zknw field escaping ---------------------------------------------
# A field may hold | or a line break; written raw, either would split a
# record. Escapes: \\ for \, \p for |, \n and \r for line breaks. The
# scan is BYTE-wise on purpose: every escape is ASCII, and no byte of a
# multi-byte UTF-8 character can equal \ or |, so s[i] is exact and cheap.

func StzKnowEscape(pcField)
	_c_ = "" + pcField
	_cOut_ = ""
	_n_ = len(_c_)
	for _i_ = 1 to _n_
		_ch_ = _c_[_i_]
		if _ch_ = char(92)
			_cOut_ += char(92) + char(92)
		but _ch_ = "|"
			_cOut_ += char(92) + "p"
		but _ch_ = char(10)
			_cOut_ += char(92) + "n"
		but _ch_ = char(13)
			_cOut_ += char(92) + "r"
		else
			_cOut_ += _ch_
		ok
	next
	return _cOut_

func StzKnowUnescape(pcField)
	_c_ = "" + pcField
	_cOut_ = ""
	_n_ = len(_c_)
	_i_ = 1
	while _i_ <= _n_
		_ch_ = _c_[_i_]
		if _ch_ = char(92) and _i_ < _n_
			_nx_ = _c_[_i_ + 1]
			if _nx_ = "p"
				_cOut_ += "|"
			but _nx_ = "n"
				_cOut_ += char(10)
			but _nx_ = "r"
				_cOut_ += char(13)
			else
				_cOut_ += _nx_
			ok
			_i_ += 2
		else
			_cOut_ += _ch_
			_i_++
		ok
	end
	return _cOut_

# One record line -> its unescaped, trimmed fields.
func StzKnowSplit(pcLine)
	_acRaw_ = split("" + pcLine, "|")
	_aOut_ = []
	_n_ = len(_acRaw_)
	for _i_ = 1 to _n_
		_aOut_ + StzKnowUnescape(ring_trim(_acRaw_[_i_]))
	next
	return _aOut_

class stzKnowGraph from stzKnowledgeGraph
# Holds knowledge as facts, triples of subject, predicate and object, in a graph, with queries, laws, proofs and conversations.
#
# A stzKnowledgeGraph is a stzGraph of type semantic: each fact is an edge labelled with its
# predicate between two entity nodes, so every stzGraph method is also available. Facts are set-like
# (adding a known fact is a no-op), but only one fact can link a given ordered pair of entities.
# Laws (:unique, :symmetric, :transitive) are declared per relation with ConstrainRelation: Admit is
# the governed door that checks :unique and records a refusal as a named contradiction, Prove follows
# :transitive, and ValidateOntology checks all three against the facts while ValidateOntologyIssues
# names each break; strict mode makes every fact carry provenance. Prove answers a goal with a
# replayable proof, and the space can hold stzConversation objects that elicit missing facts.
# Knowledge is saved and read as .zknw text. A number of methods carry a warning today.
#
#   receiver   o1 = new stzKnowledgeGraph("zoo"); o1.AddFact("Dog", "is-a", "Animal");
#              o1.AddFact("Cat", "is-a", "Animal"); o1.AddFact("Dog", "eats", "Meat")
#   example    ? @@( o1.Query([ "?x", "is-a", "Animal" ]) )
#              #--> [ "Dog", "Cat" ]
#   see        stzGraph, stzConversation, stzKnowParser
class stzKnowledgeGraph from stzGraph

	@aNamespaces = []
	@aOntology = []
	@bStrictMode = 0        # G8 seed: opt-in knowledge hygiene
	@aFactMeta = []         # provenance per fact: [ :fact, :meta ]
	@aContradictions = []   # named, NEVER silently resolved
	@aoConversations = []   # the stzConversation objects HAPPENING IN this space

	# Builds an empty knowledge graph of type semantic, with no fact, no law and no conversation; the id is folded to lowercase.
	#
	#   returns    nothing; the object is built
	#   note       the id follows the rules of stzGraph: no space, no line break
	#   see        stzGraph.init, AddFact
	def init(pcId)
		super.init(pcId)
		super.SetGraphType("semantic")

		@aNamespaces = []
		@aOntology = []

	# TRUE if the receiver is a knowledge graph, which a stzKnowledgeGraph always is.
	#
	#   returns    TRUE
	#   see        IsAKnowledgeGraph
	def IsKnowledgeGraph()
		return 1

		# TRUE if the receiver is a knowledge graph, spelled with an article; always TRUE here.
		#
		#   returns    TRUE
		#   see        IsKnowledgeGraph
		def IsAKnowledgeGraph()
			return 1

	#--------------------#
	#  TRIPLE INTERFACE  #
	#--------------------#

	# Adds a fact: entity nodes are created for the subject and the object when missing, and an edge labelled with the predicate links them.
	#
	#   pcSubject     The subject of the fact, as text.
	#   pcPredicate   The predicate (the relation) of the fact, as text.
	#   pcObject      The object of the fact, as text.
	#   returns       nothing; the graph changes
	#   note          AddFactXT adds a fact with provenance; AddTriple is another spelling
	#   warning       stating a known fact again does nothing, but a different predicate between the
	#                 same two entities raises an error, and strict mode refuses any fact added this
	#                 way
	#   see           Know, Admit, RemoveFact
	def AddFact(pcSubject, pcPredicate, pcObject)
		# STRICT MODE (G8): once enabled, naked facts are refused --
		# every fact must carry provenance through AddFactXT. Enable
		# strict AFTER loading/ontology-definition (those use AddFact).
		if @bStrictMode
			stzraise("Strict mode: every fact needs provenance -- use AddFactXT(s, p, o, [ :source = ..., :confidence = ... ]).")
		ok
		This._AddFactRaw(pcSubject, pcPredicate, pcObject)

		def AddFactQ(pcSubject, pcPredicate, pcObject)
			This.AddFact(pcSubject, pcPredicate, pcObject)
			return This

		def AddTriple(pcSubject, pcPredicate, pcObject)
			return This.AddFact(pcSubject, pcPredicate, pcObject)

	# Records that an entity is of a type, as the fact entity is-a type, and returns the graph so calls chain.
	#
	#   pcName     the entity name, as text
	#   pcType     the type of the entity, as text
	#   returns    the graph itself
	#   see        KnowRelation, AddFact
	#@ aka  -- domain-modeling verbs (INSTANCE-scoped, chainable) -------------------- Build a domain knowledgebase with NO globals: oKB = new stzKnowledgeGraph("restaurant") oKB.Know("margherita", "dish"). KnowRelation("margherita", "contains", "tomato-sauce"). ConstrainRelation("pairs-with", :Symmetric) The natural-world globals (StzKnow/StzKnowRelation) are a SEPARATE feature -- the default shared world be
	def Know(pcName, pcType)
		This.AddFact(pcName, "is-a", pcType)
		return This

		def KnowEntity(pcName, pcType)
			return This.Know(pcName, pcType)

	# Records a fact, subject predicate object, and returns the graph so calls chain.
	#
	#   pcSubject     The subject of the fact, as text.
	#   pcPredicate   The predicate (the relation) of the fact, as text.
	#   pcObject      The object of the fact, as text.
	#   returns       the graph itself
	#   note          KnowFact is another spelling
	#   see           Know, AddFact
	def KnowRelation(pcSubject, pcPredicate, pcObject)
		This.AddFact(pcSubject, pcPredicate, pcObject)
		return This

		def KnowFact(pcSubject, pcPredicate, pcObject)
			return This.KnowRelation(pcSubject, pcPredicate, pcObject)

	# Declares a law on a relation, such as unique or transitive, once, and returns the graph; an empty relation or law does nothing.
	#
	#   pcRel      The relation (the predicate), as text.
	#   pcLaw      The law, as text: unique, symmetric or transitive.
	#   returns    the graph itself
	#   note       the laws unique and transitive are acted on by Admit and Prove, and all three are
	#              checked against the facts by ValidateOntologyIssues
	#   see        RelationHasLaw, Admit, Prove
	#@ aka  Record a relation LAW on THIS graph's ontology (:Symmetric, :Unique, :Transitive). Prove() reads it for transitive closure; forging a DLM reads it as the domain's laws.
	def ConstrainRelation(pcRel, pcLaw)
		_cR_ = StzLower(ring_trim("" + pcRel))
		_cL_ = StzLower(ring_trim("" + pcLaw))
		if _cR_ = "" or _cL_ = ""
			return This
		ok
		if NOT This.RelationHasLaw(_cR_, _cL_)
			This.DefineProperty(_cR_, [ _cL_ ])
		ok
		return This

		def Constrain(pcRel, pcLaw)
			return This.ConstrainRelation(pcRel, pcLaw)

	def _AddFactRaw(pcSubject, pcPredicate, pcObject)
		# Facts are SET-LIKE: re-asserting a known fact is a quiet no-op
		# (R1, 2026-07-14 -- reloading a .stzknow over a live graph used
		# to die on "Edge already exists"). A DIFFERENT predicate between
		# the same pair still raises: stzGraph stores ONE edge per node
		# pair (known limitation, revisit with multi-edge support).
		_cS_ = StzLower("" + pcSubject)
		_cP_ = StzLower("" + pcPredicate)
		_cO_ = StzLower("" + pcObject)
		# (EdgeExists raises on missing nodes -- only probe when both live)
		if This.NodeExists(_cS_) and This.NodeExists(_cO_)
			if This.EdgeExists(_cS_, _cO_)
				_aEdge_ = This.Edge(_cS_, _cO_)
				if _aEdge_[:label] = _cP_
					return
				ok
				stzraise("Can't add fact: '" + _cS_ + "' and '" + _cO_ + "' already carry the edge '" + _aEdge_[:label] + "' (stzGraph stores one edge per node pair).")
			ok
		ok

		if NOT This.NodeExists(pcSubject)
			This.AddNodeXTT(pcSubject, pcSubject, [:type = "entity"])
		ok

		# Bug fix: previously the object label was @@(pcObject) which
		# wraps strings with literal quote chars ("Animals" -> '"Animals"').
		# Use the raw string so the label round-trips clean.
		if NOT This.NodeExists(pcObject)
			This.AddNodeXTT(pcObject, pcObject, [:type = "entity"])
		ok

		This.AddEdgeXTT(pcSubject, pcObject, pcPredicate, [:type = "fact"])

	# Provenance-carrying add (G8). In STRICT mode :source + :confidence
	# are MANDATORY, and a fact contradicting a :Unique law is REFUSED
	# and RECORDED as a named contradiction -- never silently resolved.
	def AddFactXT(pcSubject, pcPredicate, pcObject, paMeta)
		if @bStrictMode
			if NOT ( isList(paMeta) and HasKey(paMeta, :source) and
			         HasKey(paMeta, :confidence) )
				stzraise("Strict mode: every fact needs provenance -- AddFactXT(s, p, o, [ :source = ..., :confidence = ... ]).")
			ok
			if This.RelationHasLaw(pcPredicate, "unique")
				_cS_ = StzLower("" + pcSubject)
				_cP_ = StzLower("" + pcPredicate)
				_cO_ = StzLower("" + pcObject)
				_aEdges_ = This.Edges()
				_nLen_ = len(_aEdges_)
				for _i_ = 1 to _nLen_
					if _aEdges_[_i_][:from] = _cS_ and
					   _aEdges_[_i_][:label] = _cP_ and
					   _aEdges_[_i_][:to] != _cO_
						@aContradictions + [
							:subject = _cS_,
							:relation = _cP_,
							:existing = _aEdges_[_i_][:to],
							:attempted = _cO_,
							:source = paMeta[:source]
						]
						return 0
					ok
				next
			ok
		ok
		This._AddFactRaw(pcSubject, pcPredicate, pcObject)
		@aFactMeta + [
			:fact = [ StzLower("" + pcSubject), StzLower("" + pcPredicate),
			          StzLower("" + pcObject) ],
			:meta = paMeta
		]
		return 1

	# Offers a fact through the governed door: one that breaks a unique law is refused and noted, any other is added with its provenance.
	#
	#   pcSubject     The subject of the fact, as text.
	#   pcPredicate   The predicate (the relation) of the fact, as text.
	#   pcObject      The object of the fact, as text.
	#   paMeta        The provenance, as a hash list such as [ :source = "vet", :confidence = 0.9 ].
	#   returns       a hash list [ :admitted, :why ]: admitted is 1 or 0 and why says so in a
	#                 sentence
	#   note          a structural refusal, such as a different predicate already linking the pair,
	#                 is returned as a refusal and does not raise
	#   see           AddFact, Contradictions, FactMeta
	#@ aka  -- GOVERNED ADMISSION (instance-scoped) --------------------------------- The door a conversation / agent / importer admits facts through: the LAW is checked, the verdict is EXPLAINED, and a refusal is RECORDED as a named contradiction -- never silently resolved (G8). Admission is governed because it comes through THIS door, not because a global flag is set -- so a scoped domain graph governs itse
	def Admit(pcSubject, pcPredicate, pcObject, paMeta)
		_cS_ = StzLower("" + pcSubject)
		_cP_ = StzLower("" + pcPredicate)
		_cO_ = StzLower("" + pcObject)

		# :Unique -- a subject bears at most ONE object for this relation
		if This.RelationHasLaw(_cP_, "unique")
			_aEdges_ = This.Edges()
			_nE_ = len(_aEdges_)
			for _i_ = 1 to _nE_
				if _aEdges_[_i_][:from] = _cS_ and _aEdges_[_i_][:label] = _cP_ and
				   _aEdges_[_i_][:to] != _cO_
					_cWhy_ = "'" + _cS_ + "' already bears '" + _cP_ + "' (to '" +
						_aEdges_[_i_][:to] + "'); the relation is :Unique"
					@aContradictions + [ :subject = _cS_, :relation = _cP_,
						:existing = _aEdges_[_i_][:to], :attempted = _cO_,
						:source = This._MetaSource(paMeta) ]
					return [ :admitted = 0, :why = _cWhy_ ]
				ok
			next
		ok

		# a structural conflict (stzGraph holds one edge per node pair) is a
		# REFUSAL too, not a crash -- the elicitation door must stay alive.
		try
			This._AddFactRaw(pcSubject, pcPredicate, pcObject)
		catch
			return [ :admitted = 0, :why = cCatchError ]
		done

		if isList(paMeta) and len(paMeta) > 0
			@aFactMeta + [ :fact = [ _cS_, _cP_, _cO_ ], :meta = paMeta ]
		ok
		return [ :admitted = 1,
			:why = "admitted: '" + _cS_ + "' " + _cP_ + " '" + _cO_ + "'" ]

	def _MetaSource(paMeta)
		if isList(paMeta) and HasKey(paMeta, :source)
			return "" + paMeta[:source]
		ok
		return "unknown"

	# Opens a named conversation inside the space; raises an error for an empty name or a name already in use.
	#
	#   pcConvName   The conversation name, as text; case is ignored.
	#   returns      nothing; the space changes
	#   note         AddConversationQ returns the new conversation so a goal can be set on it at
	#                once
	#   see          AddConversationQ, ConversationQ, Conversations
	#@ aka  -- CONVERSATIONS IN THIS SPACE (composition) ----------------------------- A knowledge space HOLDS its conversations: an elicitation is an EPISODE that happens INSIDE the space it grows -- never a session that owns a space. So the space is the door for everything that needs knowledge (AskIn / ReplyIn / GapsIn / ConcludeIn hand THIS graph, live, into the session); session-only state is reached thro
	def AddConversation(pcConvName)
		_cN_ = ring_trim("" + pcConvName)
		if _cN_ = ""
			stzraise("A conversation needs a name.")
		ok
		if This.HasConversation(_cN_)
			stzraise("A conversation '" + _cN_ + "' already exists in this space.")
		ok
		@aoConversations + StzConversationQ(_cN_)

	# The SAME act, returning the NEW conversation so you can chain onto it:
	#   oKB.AddConversationQ("setup").SetGoal(oGoal)
	# The verb says what you DO (add), the Q says what you GET BACK (the new
	# object). Use ConversationQ(name) when you mean "the one already there".

	def AddConversationQ(pcConvName)
		This.AddConversation(pcConvName)
		return @aoConversations[This._ConvIndex(pcConvName)]

	# Opens several named conversations, one per name, in order; a name already in use raises an error.
	#
	#   pacNames   The conversation names, as a list of text.
	#   returns    nothing; the space changes
	#   see        AddConversation
	def AddConversations(pacNames)
		if NOT isList(pacNames)
			stzraise("AddConversations() takes a list of names.")
		ok
		_n_ = len(pacNames)
		for _i_ = 1 to _n_
			This.AddConversation(pacNames[_i_])
		next

		def AddConversationsQ(pacNames)
			This.AddConversations(pacNames)
			return This

	# Closes the named conversation and returns the graph; an unknown name raises an error.
	#
	#   pcConvName   The conversation name, as text; case is ignored.
	#   returns      the graph itself
	#   see          RemoveAllConversations, AddConversation
	def RemoveConversation(pcConvName)
		del(@aoConversations, This._ConvIndexOrRaise(pcConvName))
		return This

	# Closes every conversation held by the space and returns the graph.
	#
	#   returns    the graph itself
	#   see        RemoveConversation
	def RemoveAllConversations()
		@aoConversations = []
		return This

	# Returns the stzConversation held under that name, to work on its goal and turns; an unknown name raises an error.
	#
	#   pcConvName   The conversation name, as text; case is ignored.
	#   returns      a stzConversation
	#   see          AddConversation, Conversations
	def ConversationQ(pcConvName)
		return @aoConversations[This._ConvIndexOrRaise(pcConvName)]

	# Returns the topics of the conversations held by the space, in the order opened.
	#
	#   returns    a list of text
	#   see        NumberOfConversations, OpenConversations
	def Conversations()
		_ac_ = []
		_n_ = len(@aoConversations)
		for _i_ = 1 to _n_
			_ac_ + @aoConversations[_i_].Topic()
		next
		return _ac_

	# Returns how many conversations the space holds.
	#
	#   returns    a number
	#   see        Conversations
	def NumberOfConversations()
		return len(@aoConversations)

	# TRUE if a conversation of that name is held; the name is matched without regard to case.
	#
	#   pcConvName   The conversation name, as text; case is ignored.
	#   returns      TRUE or FALSE
	#   see          AddConversation, Conversations
	def HasConversation(pcConvName)
		return This._ConvIndex(pcConvName) > 0

	# what is happening in this space, at a glance
	def ConversationsXT()
		_a_ = []
		_n_ = len(@aoConversations)
		for _i_ = 1 to _n_
			_a_ + [
				:name = @aoConversations[_i_].Topic(),
				:goal = @aoConversations[_i_].GoalState(),
				:turns = @aoConversations[_i_].NumberOfTurns(),
				:checkpoints = len(@aoConversations[_i_].AllCheckpoints())
			]
		next
		return _a_

	# Returns the topics of the conversations still pursuing their goal, neither fulfilled nor revoked.
	#
	#   returns    a list of text
	#   see        Conversations, GapsIn
	#@ aka  the sessions still working (a goal neither fulfilled nor revoked)
	def OpenConversations()
		_ac_ = []
		_n_ = len(@aoConversations)
		for _i_ = 1 to _n_
			if @aoConversations[_i_].IsPursuingGoal()
				_ac_ + @aoConversations[_i_].Topic()
			ok
		next
		return _ac_

	# Returns what the conversation's goal still lacks in this space, as [ subject, relation, why ] triples; an unknown name raises an error.
	#
	#   pcConvName   The conversation name, as text; case is ignored.
	#   returns      a list of triples
	#   note         a conversation with no goal raises an error
	#   see          AskIn, ReplyIn, ConcludeIn
	#@ aka  -- the wise-coding loop, driven BY the space (This goes in live) --
	def GapsIn(pcConvName)
		return @aoConversations[This._ConvIndexOrRaise(pcConvName)].Gaps(This)

	# Returns the next question born from the first gap of the conversation's goal; empty text when nothing is left to ask.
	#
	#   pcConvName   The conversation name, as text; case is ignored.
	#   returns      text
	#   note         a conversation with no goal raises an error
	#   see          GapsIn, ReplyIn
	def AskIn(pcConvName)
		return @aoConversations[This._ConvIndexOrRaise(pcConvName)].NextQuestion(This)

	def AskInXT(pcConvName)
		return @aoConversations[This._ConvIndexOrRaise(pcConvName)].NextQuestionXT(This)

	# Passes an answer to the conversation, which admits the facts it implies through the governed door and reports what happened.
	#
	#   pcConvName   The conversation name, as text; case is ignored.
	#   pAnswer      The reply: a text, a list of texts, or numbers that pick the proposed options.
	#   returns      a hash list [ :admitted, :refused, :narration, :goalstate ]
	#   note         raises an error when no question was asked first
	#   see          AskIn, GapsIn
	def ReplyIn(pcConvName, pAnswer)
		return @aoConversations[This._ConvIndexOrRaise(pcConvName)].Reply(This, pAnswer)

	# Writes the space as a .zknw file once the conversation's goal has no gap left, and returns 1; gaps left or a revoked goal raise an error.
	#
	#   pcConvName   The conversation name, as text; case is ignored.
	#   pcKnowFile   The knowledge file to write, as text; .zknw is added when missing.
	#   returns      1
	#   see          GapsIn, WriteToKnowFile
	def ConcludeIn(pcConvName, pcKnowFile)
		return @aoConversations[This._ConvIndexOrRaise(pcConvName)].Conclude(This, pcKnowFile)

	def _ConvIndex(pcConvName)
		_cN_ = StzLower(ring_trim("" + pcConvName))
		_n_ = len(@aoConversations)
		for _i_ = 1 to _n_
			if StzLower(@aoConversations[_i_].Topic()) = _cN_
				return _i_
			ok
		next
		return 0

	def _ConvIndexOrRaise(pcConvName)
		_i_ = This._ConvIndex(pcConvName)
		if _i_ = 0
			stzraise("No conversation '" + pcConvName + "' in this space -- AddConversation('" + pcConvName + "') first.")
		ok
		return _i_

	# Turns strict mode on or off: in strict mode a fact must carry provenance, so AddFact is refused.
	#
	#   bOnOff     1 to turn strict mode on, 0 to turn it off.
	#   returns    nothing; the setting changes
	#   see        EnableStrictMode, DisableStrictMode, IsStrict
	def SetStrictMode(bOnOff)
		@bStrictMode = bOnOff

		# Turns strict mode on, so every fact must be added with provenance.
		#
		#   returns    nothing; the setting changes
		#   note       turn it on after loading the facts, which use AddFact
		#   see        SetStrictMode, IsStrict
		def EnableStrictMode()
			@bStrictMode = 1

		# Turns strict mode off, the default, so facts may be added without provenance.
		#
		#   returns    nothing; the setting changes
		#   see        SetStrictMode, IsStrict
		def DisableStrictMode()
			@bStrictMode = 0

	# TRUE if strict mode is on; it is off by default.
	#
	#   returns    TRUE or FALSE (1 or 0)
	#   see        SetStrictMode
	def IsStrict()
		return @bStrictMode

	# Returns the refused attempts recorded so far, each as [ :subject, :relation, :existing, :attempted, :source ].
	#
	#   returns    a list of hash lists
	#   see        Admit, FactMeta
	def Contradictions()
		return @aContradictions

	# Returns the provenance recorded for facts, each as a hash list [ :fact, :meta ] holding the triple and its metadata.
	#
	#   returns    a list of hash lists
	#   see        MetaOfFact, Admit
	def FactMeta()
		return @aFactMeta

	# Removes the link between the subject and the object, whatever the predicate says; the two entity nodes stay.
	#
	#   pcSubject     The subject of the fact, as text.
	#   pcPredicate   The predicate (the relation) of the fact, as text.
	#   pcObject      The object of the fact, as text.
	#   returns       nothing; the graph changes
	#   warning       the predicate is ignored, so naming a wrong predicate still removes the fact
	#                 that links the pair, and without an error
	#   see           RemoveTriple, AddFact
	def RemoveFact(pcSubject, pcPredicate, pcObject)
		This.RemoveThisEdge(pcSubject, pcObject)

		# Removes the link between the subject and the object whatever the predicate; another spelling of the removal.
		#
		#   pcSubject     The subject of the fact, as text.
		#   pcPredicate   The predicate (the relation) of the fact, as text.
		#   pcObject      The object of the fact, as text.
		#   returns       nothing; the graph changes
		#   warning       the predicate is ignored, so a wrong predicate still removes the fact
		#                 between the pair
		#   see           RemoveFact
		def RemoveTriple(pcSubject, pcPredicate, pcObject)
			This.RemoveFact(pcSubject, pcPredicate, pcObject)

	# Returns every fact as a [ subject, predicate, object ] triple, with the entity names as they were first written.
	#
	#   returns    a list of triples
	#   note       Triples is another spelling
	#   see        Query, Relations
	def Facts()
		_aFacts_ = []
		_aEdges_ = This.Edges()

		# Node :id is stored lowercased (stzGraph normalises for
		# case-insensitive lookup) but :label preserves the original
		# casing passed in by AddFact. We return labels so callers
		# get the same strings they put in.
		_nLen_ = len(_aEdges_)
		for _i_ = 1 to _nLen_
			_aEdge_ = _aEdges_[_i_]
			_cFromLabel_ = This.Node(_aEdge_[:from])[:label]
			_cToLabel_   = This.Node(_aEdge_[:to])[:label]
			_aFacts_ + [_cFromLabel_, _aEdge_[:label], _cToLabel_]
		end

		return _aFacts_

		def Triples()
			return This.Facts()

	#-------------------#
	#  QUERY INTERFACE  #
	#-------------------#

	# Answers a pattern [ subject, predicate, object ]: the matching names for one variable, name pairs for two, 1 or 0 when none is a variable.
	#
	#   paPattern   A pattern [ subject, predicate, object ]; a subject or object starting with ? is
	#               a variable.
	#   returns     a list of names or of pairs, or 1 or 0
	#   note        a variable starts with ?; the predicate cannot be a variable; in a pattern
	#               without variable the predicate must be written in lowercase
	#   see         QueryPath, Facts, Prove
	def Query(paPattern)
		# Pattern: ["?x", :IsA, "Animals"] or ["Dogs", :Eats, "?what"]
		# stzGraph stores edge :from / :to / :label all lowercased
		# for case-insensitive matching; bound terms here have to
		# be lowercased before comparing so the user-facing pattern
		# (which uses the original casing) still matches.

		_cSubject_ = paPattern[1]
		_cPredicate_ = paPattern[2]
		_cObject_ = paPattern[3]

		_acResults_ = []
		_aEdges_ = This.Edges()
		_nLen_ = len(_aEdges_)

		_bSubjVar_ = (isString(_cSubject_) and StzLeft(_cSubject_, 1) = "?")
		_bObjVar_ = (isString(_cObject_) and StzLeft(_cObject_, 1) = "?")

		# Lowercase any bound terms once, up front. StzLower is codepoint-aware
		# (byte lower() doesn't fold multibyte case, so a 'Café' fact wouldn't
		# match a 'CAFÉ' query).
		_cSubjLow_ = ""
		if isString(_cSubject_) and NOT _bSubjVar_
			_cSubjLow_ = StzLower(_cSubject_)
		ok
		_cObjLow_ = ""
		if isString(_cObject_) and NOT _bObjVar_
			_cObjLow_ = StzLower(_cObject_)
		ok
		_cPredLow_ = _cPredicate_
		if isString(_cPredicate_)
			_cPredLow_ = StzLower(_cPredicate_)
		ok

		if _bSubjVar_ and _bObjVar_
			# Both variables: return all subject-object pairs for predicate.
			# Convert IDs back to original-case node labels.
			for _i_ = 1 to _nLen_
				if _aEdges_[_i_][:label] = _cPredLow_
					_cFromLab_ = This.Node(_aEdges_[_i_][:from])[:label]
					_cToLab_   = This.Node(_aEdges_[_i_][:to])[:label]
					_acResults_ + [ _cFromLab_, _cToLab_ ]
				ok
			next

		but _bSubjVar_
			for _i_ = 1 to _nLen_
				if _aEdges_[_i_][:to] = _cObjLow_ and _aEdges_[_i_][:label] = _cPredLow_
					_cFromLab_ = This.Node(_aEdges_[_i_][:from])[:label]
					if StzFindFirst(_cFromLab_, _acResults_) = 0
						_acResults_ + _cFromLab_
					ok
				ok
			next

		but _bObjVar_
			for _i_ = 1 to _nLen_
				if _aEdges_[_i_][:from] = _cSubjLow_ and _aEdges_[_i_][:label] = _cPredLow_
					_cToLab_ = This.Node(_aEdges_[_i_][:to])[:label]
					if StzFindFirst(_cToLab_, _acResults_) = 0
						_acResults_ + _cToLab_
					ok
				ok
			next
			
		else
			# Both bound - check existence
			if This.EdgeExists(_cSubject_, _cObject_)
				_aEdge_ = This.Edge(_cSubject_, _cObject_)
				if _aEdge_[:label] = _cPredicate_
					return 1
				ok
			ok
			return 0
		ok
		
		return _acResults_

	# Answers the first pattern of a list of patterns and ignores the rest, so it is no multi-step query yet.
	#
	#   paaPatterns   A list of patterns, each [ subject, predicate, object ].
	#   returns       the answer of the first pattern, as Query gives it; [ ] for an empty list
	#   note          the binding of a variable across patterns is not implemented
	#   see           Query
	def QueryPath(paaPatterns)
		# Multi-hop: [["?x", :IsA, "Animals"], ["?x", :Eats, "?food"]]
		
		if len(paaPatterns) = 0
			return []
		ok
		
		# Execute first pattern
		_aResults_ = This.Query(paaPatterns[1])
		
		# For multi-pattern queries, would need variable binding logic
		# Basic implementation returns first pattern results
		
		return _aResults_

	#-------------------#
	#  ENTITY ANALYSIS  #
	#-------------------#

	# Returns the distinct predicates that leave an entity, in order of first appearance, in lowercase.
	#
	#   pcEntity   The entity, as text; case is ignored.
	#   returns    a list of text
	#   see        Relations, SimilarTo
	def Predicates(pcEntity)
		# Edge :from / :label are stored lowercased; lowercase the
		# query term once so case-insensitive lookups still match.
		_cPenE_ = StzLower(pcEntity)
		_acPredicates_ = []
		_aEdges_ = This.Edges()

		_nLen_ = len(_aEdges_)
		for _i_ = 1 to _nLen_
			if _aEdges_[_i_][:from] = _cPenE_
				if StzFindFirst(_acPredicates_, _aEdges_[_i_][:label]) = 0
					_acPredicates_ + _aEdges_[_i_][:label]
				ok
			ok
		next

		return _acPredicates_

		def PredicatesOf(pcEntity)
			return This.Predicates(pcEntity)

	# Returns what an entity points to as [ predicate, object ] pairs, the object with the name as first written.
	#
	#   pcEntity   The entity, as text; case is ignored.
	#   returns    a list of pairs
	#   note       RelationsOf is another spelling
	#   see        Predicates, Facts
	def Relations(pcEntity)
		_cRelE_ = StzLower(pcEntity)
		_aRelations_ = []
		_aEdges_ = This.Edges()

		_nLen_ = len(_aEdges_)
		for _i_ = 1 to _nLen_
			if _aEdges_[_i_][:from] = _cRelE_
				# Recover the to-node's original-case label.
				_cToLab_ = This.Node(_aEdges_[_i_][:to])[:label]
				_aRelations_ + [_aEdges_[_i_][:label], _cToLab_]
			ok
		next

		return _aRelations_

		def RelationsOf(pcEntity)
			return This.Relations(pcEntity)

	# Returns the other entities that share at least one predicate with the given one, as [ name, shared count ] pairs.
	#
	#   pcEntity   The entity, as text; case is ignored.
	#   returns    a list of pairs
	#   see        Predicates, Relations
	def SimilarTo(pcEntity)
		_aMyPredicates_ = This.Predicates(pcEntity)
		_cSimE_ = StzLower(pcEntity)
		_acSimilar_ = []
		_aNodes_ = This.Nodes()

		_nNodeLen_ = len(_aNodes_)
		for _i_ = 1 to _nNodeLen_
			_cNodeId_ = _aNodes_[_i_][:id]

			if _cNodeId_ != _cSimE_
				_aTheirPredicates_ = This.Predicates(_cNodeId_)
				_nOverlap_ = 0

				_nMyLen_ = len(_aMyPredicates_)
				for _j_ = 1 to _nMyLen_
					if StzFindFirst(_aTheirPredicates_, _aMyPredicates_[_j_]) > 0
						_nOverlap_++
					ok
				next

				if _nOverlap_ > 0
					# Use the node's original-case label.
					_cNodeLab_ = _aNodes_[_i_][:label]
					_acSimilar_ + [_cNodeLab_, _nOverlap_]
				ok
			ok
		next

		return _acSimilar_

		def SimilarEntities(pcEntity)
			return This.SimilarTo(pcEntity)

	#--------------------#
	#  ONTOLOGY SUPPORT  #
	#--------------------#

	# Declares a class as a subclass of another, as the fact class subclassof superclass.
	#
	#   pcSuperClass   the parent class, as text
	#   returns        nothing; the graph changes
	#   see            AddFact, DefineProperty
	def DefineClass(pcClass, pcSuperClass)
		This.AddFact(pcClass, :SubClassOf, pcSuperClass)

	# Adds an entry to the ontology: a property or relation with a list of laws; the entry is added even when a law is already declared.
	#
	#   pcProperty      The property or relation to define, as text.
	#   paConstraints   The laws to declare, as a list of text such as [ "unique", "transitive" ].
	#   returns         nothing; the ontology changes
	#   see             ConstrainRelation, Ontology, RelationHasLaw
	def DefineProperty(pcProperty, paConstraints)
		@aOntology + [
			:property = pcProperty,
			:constraints = paConstraints
		]

	# Returns the ontology as a list of hash lists [ :property, :constraints ], in the order declared.
	#
	#   returns    a list of hash lists
	#   see        DefineProperty, RelationHasLaw
	def Ontology()
		return @aOntology

	# Returns 1 when the facts break no law that the ontology declares, and 0 when at least one law is broken.
	#
	#   returns    1 or 0, where 1 also holds for an empty ontology and for an empty graph
	#   note       the three laws are unique, symmetric and transitive; a warning, such as a relation
	#              that no fact uses, does not make the ontology invalid; the graph is not changed
	#   see        ValidateOntologyIssues, Ontology, RelationHasLaw
	def ValidateOntology()
		_aIss_ = This.ValidateOntologyIssues()
		_nIss_ = len(_aIss_)
		for _i_ = 1 to _nIss_
			if _aIss_[_i_][:severity] = "error"
				return 0
			ok
		next
		return 1

	# Returns the problems between the ontology and the facts, as hash lists of the rule-report shape; [ ] when there is none.
	#
	#   returns    a list of hash lists [ :rule, :subject, :where, :severity, :message ]; the subject is
	#              always knowledge; the severity is error for a broken law and warning for advice;
	#              the rule is relation_unique, relation_symmetric or relation_transitive for a broken
	#              law, law_unknown for a law of another name, and relation_unused for a declared
	#              relation that no fact uses
	#   note       the issues follow the order of the ontology, then unique, symmetric and transitive,
	#              then the facts; relations are matched without regard to case and names are shown
	#              in lowercase; transitive asks the shortcut of every two facts in a row, so a cycle
	#              ends and a return to the start asks nothing; at most 10000 issues are given for
	#              one relation and law; a property declared with a schema, such as a type or a
	#              maximum, is checked for use only, as its meaning is not defined; the graph is
	#              not changed
	#   see        ValidateOntology, Ontology, ConstrainRelation
	def ValidateOntologyIssues()
		_aIssues_ = []
		_aView_ = This._OntologyView()
		_nProps_ = len(_aView_)
		if _nProps_ = 0
			return _aIssues_
		ok

		_pRel_ = StzEngineHashMapNew()
		_pPair_ = StzEngineHashMapNew()
		if _pRel_ = "" or _pPair_ = ""
			stzraise("The ontology check needs the engine hash map, which is not available.")
		ok

		# One pass over the facts: the edges of each declared relation, and the edge of each ordered pair.
		_aaRelEdges_ = []
		for _i_ = 1 to _nProps_
			StzEngineHashMapPutInt(_pRel_, _aView_[_i_][:property], _i_)
			_aaRelEdges_ + []
		next
		_aEdges_ = This.Edges()
		_nE_ = len(_aEdges_)
		_acLab_ = []
		for _e_ = 1 to _nE_
			_cLab_ = StzLower("" + _aEdges_[_e_][:label])
			_acLab_ + _cLab_
			StzEngineHashMapPutInt(_pPair_, _aEdges_[_e_][:from] + char(1) + _aEdges_[_e_][:to], _e_)
			if StzEngineHashMapHasKey(_pRel_, _cLab_)
				_k_ = StzEngineHashMapGetInt(_pRel_, _cLab_)
				_aaRelEdges_[_k_] + _e_
			ok
		next

		_nCap_ = 10000
		for _p_ = 1 to _nProps_
			_cRel_ = _aView_[_p_][:property]
			_nRE_ = len(_aaRelEdges_[_p_])

			# a law of another name
			_nUnk_ = len(_aView_[_p_][:unknown])
			for _j_ = 1 to _nUnk_
				_aIssues_ + [ :rule = "law_unknown", :subject = "knowledge", :where = _cRel_,
					:severity = "warning",
					:message = "'" + _cRel_ + "' declares the law '" + _aView_[_p_][:unknown][_j_] +
						"', which is none of unique, symmetric or transitive." ]
			next

			# unique: a subject bears at most one object
			if ring_find(_aView_[_p_][:laws], "unique") > 0
				_pS_ = StzEngineHashMapNew()
				_acSubj_ = []
				_aaObj_ = []
				for _q_ = 1 to _nRE_
					_nEp_ = _aaRelEdges_[_p_][_q_]
					_cF_ = _aEdges_[_nEp_][:from]
					if StzEngineHashMapHasKey(_pS_, _cF_)
						_k_ = StzEngineHashMapGetInt(_pS_, _cF_)
					else
						_acSubj_ + _cF_
						_aaObj_ + []
						_k_ = len(_acSubj_)
						StzEngineHashMapPutInt(_pS_, _cF_, _k_)
					ok
					_aaObj_[_k_] + _aEdges_[_nEp_][:to]
				next
				StzEngineHashMapFree(_pS_)
				_nS_ = len(_acSubj_)
				for _q_ = 1 to _nS_
					_nO_ = len(_aaObj_[_q_])
					if _nO_ >= 2
						_cList_ = ""
						_nShown_ = _nO_
						if _nShown_ > 5
							_nShown_ = 5
						ok
						for _j_ = 1 to _nShown_
							if _j_ > 1
								_cList_ += ", "
							ok
							_cList_ += _aaObj_[_q_][_j_]
						next
						if _nO_ > 5
							_cList_ += ", and " + (_nO_ - 5) + " more"
						ok
						_aIssues_ + [ :rule = "relation_unique", :subject = "knowledge",
							:where = _acSubj_[_q_], :severity = "error",
							:message = "'" + _acSubj_[_q_] + "' bears '" + _cRel_ + "' to " + _nO_ +
								" objects (" + _cList_ + "), and the relation is unique." ]
					ok
				next
			ok

			# symmetric: a fact a r b asks for b r a
			if ring_find(_aView_[_p_][:laws], "symmetric") > 0
				_nSym_ = 0
				for _q_ = 1 to _nRE_
					_nEp_ = _aaRelEdges_[_p_][_q_]
					_cF_ = _aEdges_[_nEp_][:from]
					_cT_ = _aEdges_[_nEp_][:to]
					if _cF_ = _cT_
						loop
					ok
					_cOther_ = ""
					_cKey_ = _cT_ + char(1) + _cF_
					if StzEngineHashMapHasKey(_pPair_, _cKey_)
						_nRv_ = StzEngineHashMapGetInt(_pPair_, _cKey_)
						if _acLab_[_nRv_] = _cRel_
							loop
						ok
						_cOther_ = _acLab_[_nRv_]
					ok
					_cMsg_ = "'" + _cF_ + "' " + _cRel_ + " '" + _cT_ + "' has no reverse: '" + _cT_ + "' " +
						_cRel_ + " '" + _cF_ + "' is missing"
					if _cOther_ != ""
						_cMsg_ += ", and the pair already links '" + _cT_ + "' to '" + _cF_ + "' with '" +
							_cOther_ + "'"
					ok
					_cMsg_ += "."
					_nSym_++
					if _nSym_ > _nCap_
						_aIssues_ + [ :rule = "relation_symmetric", :subject = "knowledge", :where = _cRel_,
							:severity = "error",
							:message = "more than " + _nCap_ + " facts of '" + _cRel_ + "' have no reverse; the rest are not listed." ]
						exit
					ok
					_aIssues_ + [ :rule = "relation_symmetric", :subject = "knowledge", :where = _cF_,
						:severity = "error", :message = _cMsg_ ]
				next
			ok

			# transitive: two facts a r b and b r c ask for a r c
			if ring_find(_aView_[_p_][:laws], "transitive") > 0
				_pOut_ = StzEngineHashMapNew()
				_pMiss_ = StzEngineHashMapNew()
				_aaAdj_ = []
				for _q_ = 1 to _nRE_
					_nEp_ = _aaRelEdges_[_p_][_q_]
					_cF_ = _aEdges_[_nEp_][:from]
					if StzEngineHashMapHasKey(_pOut_, _cF_)
						_k_ = StzEngineHashMapGetInt(_pOut_, _cF_)
					else
						_aaAdj_ + []
						_k_ = len(_aaAdj_)
						StzEngineHashMapPutInt(_pOut_, _cF_, _k_)
					ok
					_aaAdj_[_k_] + _nEp_
				next
				_nTr_ = 0
				_bFull_ = 0
				for _q_ = 1 to _nRE_
					_nEp_ = _aaRelEdges_[_p_][_q_]
					_cA_ = _aEdges_[_nEp_][:from]
					_cB_ = _aEdges_[_nEp_][:to]
					if NOT StzEngineHashMapHasKey(_pOut_, _cB_)
						loop
					ok
					_k_ = StzEngineHashMapGetInt(_pOut_, _cB_)
					_nAdj_ = len(_aaAdj_[_k_])
					for _j_ = 1 to _nAdj_
						_cC_ = _aEdges_[_aaAdj_[_k_][_j_]][:to]
						if _cC_ = _cA_
							loop
						ok
						_cKey_ = _cA_ + char(1) + _cC_
						if StzEngineHashMapHasKey(_pPair_, _cKey_)
							_nRv_ = StzEngineHashMapGetInt(_pPair_, _cKey_)
							if _acLab_[_nRv_] = _cRel_
								loop
							ok
						ok
						if StzEngineHashMapHasKey(_pMiss_, _cKey_)
							loop
						ok
						StzEngineHashMapPutInt(_pMiss_, _cKey_, 1)
						_nTr_++
						if _nTr_ > _nCap_
							_aIssues_ + [ :rule = "relation_transitive", :subject = "knowledge", :where = _cRel_,
								:severity = "error",
								:message = "more than " + _nCap_ + " links of '" + _cRel_ + "' are missing; the rest are not listed." ]
							_bFull_ = 1
							exit
						ok
						_aIssues_ + [ :rule = "relation_transitive", :subject = "knowledge", :where = _cA_,
							:severity = "error",
							:message = "'" + _cA_ + "' " + _cRel_ + " '" + _cB_ + "' and '" + _cB_ + "' " + _cRel_ +
								" '" + _cC_ + "', so '" + _cA_ + "' " + _cRel_ + " '" + _cC_ + "' is missing." ]
					next
					if _bFull_
						exit
					ok
				next
				StzEngineHashMapFree(_pOut_)
				StzEngineHashMapFree(_pMiss_)
			ok

			# a declared relation that no fact uses
			if _nRE_ = 0
				_aIssues_ + [ :rule = "relation_unused", :subject = "knowledge", :where = _cRel_,
					:severity = "warning",
					:message = "'" + _cRel_ + "' is declared in the ontology, and no fact uses it." ]
			ok
		next

		StzEngineHashMapFree(_pRel_)
		StzEngineHashMapFree(_pPair_)
		return _aIssues_

	# The ontology grouped by property, in order of first declaration: [ :property, :laws, :unknown, :items ].
	# A property may be declared by several entries (ConstrainRelation adds one per law). Laws and
	# unknown laws are lowercase and appear once; :items is every constraint as text, in order. A
	# constraint that is a pair (a schema such as type = number) is shown as key=value and is no law.
	def _OntologyView()
		_acNames_ = []
		_aaLaws_ = []
		_aaUnk_ = []
		_aaItems_ = []
		_nOnt_ = len(@aOntology)
		for _i_ = 1 to _nOnt_
			_cProp_ = StzLower(ring_trim("" + @aOntology[_i_][:property]))
			_nP_ = ring_find(_acNames_, _cProp_)
			if _nP_ = 0
				_acNames_ + _cProp_
				_aaLaws_ + []
				_aaUnk_ + []
				_aaItems_ + []
				_nP_ = len(_acNames_)
			ok
			_aCons_ = []
			if isList(@aOntology[_i_][:constraints])
				_aCons_ = @aOntology[_i_][:constraints]
			but isString(@aOntology[_i_][:constraints])
				_aCons_ + @aOntology[_i_][:constraints]
			ok
			_nC_ = len(_aCons_)
			for _j_ = 1 to _nC_
				if isString(_aCons_[_j_])
					_cLaw_ = StzLower(ring_trim(_aCons_[_j_]))
					if _cLaw_ = ""
						loop
					ok
					if _cLaw_ = "unique" or _cLaw_ = "symmetric" or _cLaw_ = "transitive"
						if ring_find(_aaLaws_[_nP_], _cLaw_) = 0
							_aaLaws_[_nP_] + _cLaw_
							_aaItems_[_nP_] + _cLaw_
						ok
					else
						if ring_find(_aaUnk_[_nP_], _cLaw_) = 0
							_aaUnk_[_nP_] + _cLaw_
							_aaItems_[_nP_] + _cLaw_
						ok
					ok
				but isList(_aCons_[_j_]) and len(_aCons_[_j_]) = 2
					_xV_ = _aCons_[_j_][2]
					if isString(_xV_) or isNumber(_xV_)
						_cV_ = "" + _xV_
					else
						_cV_ = @@(_xV_)
					ok
					_aaItems_[_nP_] + ("" + _aCons_[_j_][1] + "=" + _cV_)
				ok
			next
		next
		_aView_ = []
		_nN_ = len(_acNames_)
		for _i_ = 1 to _nN_
			_aView_ + [ :property = _acNames_[_i_], :laws = _aaLaws_[_i_], :unknown = _aaUnk_[_i_],
				:items = _aaItems_[_i_] ]
		next
		return _aView_

	# TRUE if the ontology declares that law for the relation; both are matched without regard to case.
	#
	#   pcRel      The relation (the predicate), as text.
	#   pcLaw      The law, as text: unique, symmetric or transitive.
	#   returns    TRUE or FALSE (1 or 0)
	#   see        ConstrainRelation, DefineProperty
	#@ aka  Does the ontology declare this LAW for this relation? (Laws land here through DefineProperty(rel, [ law ]) -- the R1 home of :unique / :symmetric / :transitive.)
	def RelationHasLaw(pcRel, pcLaw)
		_cR_ = StzLower("" + pcRel)
		_cL_ = StzLower("" + pcLaw)
		_nLen_ = len(@aOntology)
		for _i_ = 1 to _nLen_
			if StzLower("" + @aOntology[_i_][:property]) = _cR_
				_aCons_ = @aOntology[_i_][:constraints]
				_nC_ = len(_aCons_)
				for _j_ = 1 to _nC_
					if StzLower("" + _aCons_[_j_]) = _cL_
						return 1
					ok
				next
			ok
		next
		return 0

	#-----------------------------------------------#
	#  PROOF (G4 seed: structured derivation trace)  #
	#-----------------------------------------------#

	# Tries to prove a goal [ subject, relation, object ] from the recorded facts and the transitive law, and returns a replayable proof.
	#
	#   paPattern   A pattern [ subject, predicate, object ]; a subject or object starting with ? is
	#               a variable.
	#   returns     a hash list [ :verdict, :goal, :steps, :narration, :certainty ]; the verdict is
	#               1 or 0 and the certainty is always 1
	#   note        the goal is shown in lowercase, and a transitive chain is searched to a depth of
	#               16
	#   see         Query, ConstrainRelation
	#@ aka  Prove([ subject, relation, object ]) -> a STRUCTURED, replayable proof: [ :verdict, :goal, :steps, :narration, :certainty ]. Each step: [ :kind ("fact"|"law"|"chain-link"), :fact, :narration ]. Deterministic over recorded facts + declared laws, so certainty is 1 WHATEVER the verdict (a certain no is still certain, LAW 3).
	def Prove(paPattern)
		_cS_ = StzLower("" + paPattern[1])
		_cP_ = StzLower("" + paPattern[2])
		_cO_ = StzLower("" + paPattern[3])
		_aSteps_ = []

		# 1. a direct recorded fact proves the goal in one step
		_aEdges_ = This.Edges()
		_nLen_ = len(_aEdges_)
		for _i_ = 1 to _nLen_
			if _aEdges_[_i_][:from] = _cS_ and _aEdges_[_i_][:label] = _cP_ and
			   _aEdges_[_i_][:to] = _cO_
				_aSteps_ + [ :kind = "fact", :fact = [ _cS_, _cP_, _cO_ ],
					:narration = "recorded fact: '" + _cS_ + "' " + _cP_ +
					" '" + _cO_ + "'" ]
				return [ :verdict = 1, :goal = [ _cS_, _cP_, _cO_ ],
					:steps = _aSteps_, :narration = "proved: direct fact",
					:certainty = 1 ]
			ok
		next

		# 2. a lawful TRANSITIVE chain proves it link by link
		if This.RelationHasLaw(_cP_, "transitive")
			_acChain_ = This._ProveChainNodes(_cP_, _cS_, _cO_)
			_nC_ = len(_acChain_)
			if _nC_ > 1
				_aSteps_ + [ :kind = "law", :fact = [ _cP_, "is", "transitive" ],
					:narration = "law: '" + _cP_ + "' is :Transitive" ]
				for _i_ = 1 to _nC_ - 1
					_aSteps_ + [ :kind = "chain-link",
						:fact = [ _acChain_[_i_], _cP_, _acChain_[_i_ + 1] ],
						:narration = "recorded fact: '" + _acChain_[_i_] + "' " +
						_cP_ + " '" + _acChain_[_i_ + 1] + "'" ]
				next
				return [ :verdict = 1, :goal = [ _cS_, _cP_, _cO_ ],
					:steps = _aSteps_,
					:narration = "proved: " + JoinXT(_acChain_, " " + _cP_ + " "),
					:certainty = 1 ]
			ok
		ok

		return [ :verdict = 0, :goal = [ _cS_, _cP_, _cO_ ], :steps = [],
			:narration = "not derivable: no recorded fact or lawful chain gives '" +
			_cS_ + "' " + _cP_ + " '" + _cO_ + "'",
			:certainty = 1 ]

	# BFS over pcRel-labeled edges from pcFrom toward pcTo (depth-capped);
	# the node chain [ from, ..., to ] or [] when no path exists.
	def _ProveChainNodes(pcRel, pcFrom, pcTo)
		_aFront_ = []
		_aSeed_ = [ pcFrom ]
		_aFront_ + _aSeed_
		_acSeen_ = [ pcFrom ]
		_nDepth_ = 0
		_aEdges_ = This.Edges()
		_nE_ = len(_aEdges_)
		while len(_aFront_) > 0 and _nDepth_ < 16
			_nDepth_++
			_aNext_ = []
			_nF_ = len(_aFront_)
			for _f_ = 1 to _nF_
				_aPath_ = _aFront_[_f_]
				_cNode_ = _aPath_[len(_aPath_)]
				for _i_ = 1 to _nE_
					if _aEdges_[_i_][:from] = _cNode_ and _aEdges_[_i_][:label] = pcRel
						_cTo_ = _aEdges_[_i_][:to]
						_aNew_ = _aPath_
						_aNew_ + _cTo_
						if _cTo_ = pcTo
							return _aNew_
						ok
						if ring_find(_acSeen_, _cTo_) = 0
							_acSeen_ + _cTo_
							_aNext_ + _aNew_
						ok
					ok
				next
			next
			_aFront_ = _aNext_
		end
		return []

	#---------------------------#
	#  KNOWLEDGE GRAPH EXPLAIN  #
	#---------------------------#

	# Describes the knowledge graph in sections, from its counts, facts, entities, predicates, ontology and computed insights.
	#
	#   returns    a hash list [ :type, :structure, :facts, :entities, :predicates, :ontology, :patterns,
	#              :insights ]: :type and :structure are text and the others are lists of text
	#   note       the first 5 facts, in the order added; the 10 entities with most links (in plus
	#              out), then by name; the 10 predicates with most facts, then by name; the
	#              ontology property by property; the density and whether a cycle exists; and the
	#              insights: the most connected entity, the ontology issues of ValidateOntologyIssues,
	#              entities without a fact, and refused attempts; the answer is the same on every
	#              call, and the graph is not changed; no fact is inferred
	#   warning    drawn through GraphCanvas, a knowledge graph shows no predicate on its edges and
	#              no arrowheads, because the canvas draws every edge as a plain line; Dot() with
	#              graphviz draws each fact as an edge labelled with its predicate
	#   see        Facts, Ontology, ValidateOntologyIssues, Prove
	def Explain()
		_aNodes_ = This.Nodes()
		_aEdges_ = This.Edges()
		_nNodes_ = len(_aNodes_)
		_nFacts_ = len(_aEdges_)

		_aExplanation_ = [
			:type = "Knowledge Graph",
			:structure = 'Knowledge graph "' + This.Id() + '" contains ' + _nNodes_ + " " +
				This._Plural(_nNodes_, "entity", "entities") + " and " + _nFacts_ + " " +
				This._Plural(_nFacts_, "fact", "facts") + ".",
			:facts = [],
			:entities = [],
			:predicates = [],
			:ontology = [],
			:patterns = [],
			:insights = []
		]

		# One pass over the facts: links per entity and uses per predicate
		_pNode_ = StzEngineHashMapNew()
		_anIn_ = []
		_anOut_ = []
		for _i_ = 1 to _nNodes_
			StzEngineHashMapPutInt(_pNode_, _aNodes_[_i_][:id], _i_)
			_anIn_ + 0
			_anOut_ + 0
		next
		_pPred_ = StzEngineHashMapNew()
		_acPred_ = []
		_anPred_ = []
		for _i_ = 1 to _nFacts_
			_nF_ = StzEngineHashMapGetInt(_pNode_, _aEdges_[_i_][:from])
			_nT_ = StzEngineHashMapGetInt(_pNode_, _aEdges_[_i_][:to])
			_anOut_[_nF_] = _anOut_[_nF_] + 1
			_anIn_[_nT_] = _anIn_[_nT_] + 1
			_cLab_ = StzLower("" + _aEdges_[_i_][:label])
			if StzEngineHashMapHasKey(_pPred_, _cLab_)
				_k_ = StzEngineHashMapGetInt(_pPred_, _cLab_)
				_anPred_[_k_] = _anPred_[_k_] + 1
			else
				_acPred_ + _cLab_
				_anPred_ + 1
				StzEngineHashMapPutInt(_pPred_, _cLab_, len(_acPred_))
			ok
		next
		StzEngineHashMapFree(_pPred_)

		# Facts: the first five, as written
		if _nFacts_ = 0
			_aExplanation_[:facts] + "No facts defined yet"
		else
			_nShow_ = _nFacts_
			if _nShow_ > 5
				_nShow_ = 5
			ok
			for _i_ = 1 to _nShow_
				_nF_ = StzEngineHashMapGetInt(_pNode_, _aEdges_[_i_][:from])
				_nT_ = StzEngineHashMapGetInt(_pNode_, _aEdges_[_i_][:to])
				_aExplanation_[:facts] + (_aNodes_[_nF_][:label] + " " + _aEdges_[_i_][:label] + " " +
					_aNodes_[_nT_][:label])
			next
			if _nFacts_ > 5
				_aExplanation_[:facts] + ("... and " + (_nFacts_ - 5) + " more facts")
			ok
		ok

		# Predicates: most used first, ties by name (the sort key is the padded count, then the name)
		_nP_ = len(_acPred_)
		if _nP_ = 0
			_aExplanation_[:predicates] + "No predicates yet"
		else
			_acKeys_ = []
			for _i_ = 1 to _nP_
				_acKeys_ + (right("0000000" + (9999999 - _anPred_[_i_]), 7) + _acPred_[_i_])
			next
			_acKeys_ = sort(_acKeys_)
			_nShow_ = _nP_
			if _nShow_ > 10
				_nShow_ = 10
			ok
			for _i_ = 1 to _nShow_
				_nUse_ = 9999999 - (0 + left(_acKeys_[_i_], 7))
				_aExplanation_[:predicates] + (right(_acKeys_[_i_], len(_acKeys_[_i_]) - 7) + ": " + _nUse_ + " " +
					This._Plural(_nUse_, "fact", "facts"))
			next
			if _nP_ > 10
				_aExplanation_[:predicates] + ("... and " + (_nP_ - 10) + " more predicates")
			ok
		ok

		# Entities: most links first, ties by name
		_cMost_ = ""
		_nMost_ = 0
		_nIsolated_ = 0
		if _nNodes_ = 0
			_aExplanation_[:entities] + "No entities yet"
		else
			_acKeys_ = []
			for _i_ = 1 to _nNodes_
				_nDeg_ = _anIn_[_i_] + _anOut_[_i_]
				if _nDeg_ = 0
					_nIsolated_++
				ok
				_acKeys_ + (right("0000000" + (9999999 - _nDeg_), 7) + _aNodes_[_i_][:id])
			next
			_acKeys_ = sort(_acKeys_)
			_nShow_ = _nNodes_
			if _nShow_ > 10
				_nShow_ = 10
			ok
			for _i_ = 1 to _nShow_
				_nDeg_ = 9999999 - (0 + left(_acKeys_[_i_], 7))
				_k_ = StzEngineHashMapGetInt(_pNode_, right(_acKeys_[_i_], len(_acKeys_[_i_]) - 7))
				if _i_ = 1
					_cMost_ = _aNodes_[_k_][:label]
					_nMost_ = _nDeg_
				ok
				_aExplanation_[:entities] + (_aNodes_[_k_][:label] + ": " + _nDeg_ + " " +
					This._Plural(_nDeg_, "link", "links") + " (" + _anIn_[_k_] + " in, " + _anOut_[_k_] + " out)")
			next
			if _nNodes_ > 10
				_aExplanation_[:entities] + ("... and " + (_nNodes_ - 10) + " more entities")
			ok
		ok
		StzEngineHashMapFree(_pNode_)

		# Ontology: property by property
		_aView_ = This._OntologyView()
		_nProps_ = len(_aView_)
		if _nProps_ = 0
			_aExplanation_[:ontology] + "No formal ontology defined"
		else
			_aExplanation_[:ontology] + ("Ontology declares " + _nProps_ + " " +
				This._Plural(_nProps_, "property", "properties") + ".")
			for _i_ = 1 to _nProps_
				_aExplanation_[:ontology] + (_aView_[_i_][:property] + ": " + JoinXT(_aView_[_i_][:items], ", "))
			next
		ok

		# Patterns: density and cycles
		if _nNodes_ > 0
			_nPct_ = floor(This.NodeDensity() * 100 + 0.5)
			if _nPct_ < 25
				_aExplanation_[:patterns] + ("Graph is sparse (" + _nPct_ + "% density)")
			but _nPct_ > 75
				_aExplanation_[:patterns] + ("Graph is highly connected (" + _nPct_ + "% density)")
			else
				_aExplanation_[:patterns] + ("Moderate connectivity (" + _nPct_ + "% density)")
			ok
			if This.HasCyclicDependencies()
				_aExplanation_[:patterns] + "Circular relationships found (cycles)"
			else
				_aExplanation_[:patterns] + "Acyclic structure (no cycles)"
			ok
		ok

		# Insights: each one computed from the facts and the ontology
		if _nFacts_ > 0
			_aExplanation_[:insights] + ("Most connected entity: " + _cMost_ + " (" + _nMost_ + " " +
				This._Plural(_nMost_, "link", "links") + ")")
		ok
		if _nProps_ > 0
			_aIssues_ = This.ValidateOntologyIssues()
			_nIss_ = len(_aIssues_)
			if _nIss_ = 0
				_aExplanation_[:insights] + "The ontology holds against the facts"
			else
				_nErr_ = 0
				for _i_ = 1 to _nIss_
					if _aIssues_[_i_][:severity] = "error"
						_nErr_++
					ok
				next
				_nWarn_ = _nIss_ - _nErr_
				_aExplanation_[:insights] + ("Ontology: " + _nErr_ + " " + This._Plural(_nErr_, "error", "errors") +
					", " + _nWarn_ + " " + This._Plural(_nWarn_, "warning", "warnings"))
				_nShow_ = _nIss_
				if _nShow_ > 5
					_nShow_ = 5
				ok
				for _i_ = 1 to _nShow_
					_aExplanation_[:insights] + _aIssues_[_i_][:message]
				next
				if _nIss_ > 5
					_aExplanation_[:insights] + ("... and " + (_nIss_ - 5) + " more issues")
				ok
			ok
		ok
		if _nNodes_ > 0 and _nIsolated_ > 0
			_aExplanation_[:insights] + ("" + _nIsolated_ + " " + This._Plural(_nIsolated_, "entity has", "entities have") +
				" no fact")
		ok
		_nRef_ = len(@aContradictions)
		if _nRef_ > 0
			_aExplanation_[:insights] + ("" + _nRef_ + " " + This._Plural(_nRef_, "attempt was", "attempts were") +
				" refused and recorded as contradictions")
		ok

		return _aExplanation_

	def _Plural(pnCount, pcOne, pcMany)
		if pnCount = 1
			return pcOne
		ok
		return pcMany

	#----------------------------------#
	#  MANAGING *.zknw file format     #
	#  (legacy .stzknow still READS)  #
	#----------------------------------#

	# Reads knowledge from a .zknw or .stzknow file, or from its text, and merges its facts, laws and contradictions into this graph.
	#
	#   pSource    the path of a .zknw or .stzknow file, or the text of a knowledge file that starts
	#              with a knowledge header
	#   returns    a hash list [ :merged, :refused ]: the number of facts added and the refused ones
	#              as [ s, p, o, why ]
	#   note       LoadKnow is another spelling; text with no header raises error R13, and a strict
	#              graph refuses the facts that carry no provenance
	#   see        ExportToKnow, AddFact
	def ImportKnow(pSource)
	    if isString(pSource)
	        if StzRight(pSource, 5) = ".zknw" or StzRight(pSource, 8) = ".stzknow"
	            _oParser_ = new stzKnowParser()
	            _oLoaded_ = _oParser_.ParseFile(pSource)
	        else
	            _oParser_ = new stzKnowParser()
	            _oLoaded_ = _oParser_.Parse(pSource)
	        ok
	        return This._MergeKnowledgeBase(_oLoaded_)
	    ok
	    return [ :merged = 0, :refused = [] ]
	
	    def LoadKnow(pSource)
		return This.ImportKnow(pSource)

	# Returns the knowledge as .zknw text: its facts, then the provenance, the contradictions and the laws when there are any.
	#
	#   returns    text
	#   see        WriteToKnowFile, ImportKnow
	#@ aka  PROVENANCE SURVIVES A SAVE (stzlib-security, HaroBase rung 1). A fact's source and confidence, and every contradiction the graph refused, used to be dropped here: the file kept the bare triples, so knowledge read back from disk no longer said where it came from -- and a STRICT graph could not even load its own export. Two sections now carry them:
	def ExportToKnow()
	    _cKnow_ = 'knowledge "' + @cId + '"' + char(10) + char(10)
	    _cKnow_ += "facts" + char(10)
	    _aFacts_ = This.Facts()
	    _nFacts2Len_ = len(_aFacts_)
	    for _iLoopFacts2_ = 1 to _nFacts2Len_
	    	_aFact_ = _aFacts_[_iLoopFacts2_]
	        _cKnow_ += "    " + StzKnowEscape(_aFact_[1]) + " | " + StzKnowEscape(_aFact_[2]) +
	                   " | " + StzKnowEscape(_aFact_[3]) + char(10)
	    end
	    _nM_ = len(@aFactMeta)
	    if _nM_ > 0
	        _cKnow_ += char(10) + "provenance" + char(10)
	        for _iM_ = 1 to _nM_
	            _aT_ = @aFactMeta[_iM_][:fact]
	            _aMeta_ = @aFactMeta[_iM_][:meta]
	            if NOT isList(_aMeta_)  loop  ok
	            _cTriple_ = StzKnowEscape(_aT_[1]) + " | " + StzKnowEscape(_aT_[2]) + " | " + StzKnowEscape(_aT_[3])
	            _nK_ = len(_aMeta_)
	            for _iK_ = 1 to _nK_
	                if NOT (isList(_aMeta_[_iK_]) and len(_aMeta_[_iK_]) = 2)  loop  ok
	                _xV_ = _aMeta_[_iK_][2]
	                if isNumber(_xV_)
	                    _cType_ = "number"
	                    _cVal_ = "" + _xV_
	                else
	                    _cType_ = "text"
	                    if isString(_xV_)  _cVal_ = _xV_  else  _cVal_ = @@(_xV_)  ok
	                ok
	                _cKnow_ += "    " + _cTriple_ + " | " + StzKnowEscape("" + _aMeta_[_iK_][1]) +
	                           " | " + _cType_ + " | " + StzKnowEscape(_cVal_) + char(10)
	            next
	        next
	    ok
	    _nC_ = len(@aContradictions)
	    if _nC_ > 0
	        _cKnow_ += char(10) + "contradictions" + char(10)
	        for _iC_ = 1 to _nC_
	            _aC_ = @aContradictions[_iC_]
	            _cKnow_ += "    " + StzKnowEscape("" + _aC_[:subject]) + " | " + StzKnowEscape("" + _aC_[:relation]) +
	                       " | " + StzKnowEscape("" + _aC_[:existing]) + " | " + StzKnowEscape("" + _aC_[:attempted]) +
	                       " | " + StzKnowEscape("" + _aC_[:source]) + char(10)
	        next
	    ok
	    # the LAWS travel with the knowledge (R1: ontology section --
	    # "relation | law" lines; the parser re-arms them on load)
	    if len(@aOntology) > 0
	        _cKnow_ += char(10) + "ontology" + char(10)
	        _nOnt1Len_ = len(@aOntology)
	        for _iLoopOnt1_ = 1 to _nOnt1Len_
	            _aCons_ = @aOntology[_iLoopOnt1_][:constraints]
	            _nCons1Len_ = len(_aCons_)
	            for _jLoopCons1_ = 1 to _nCons1Len_
	                _cKnow_ += "    " + @aOntology[_iLoopOnt1_][:property] +
	                           " | " + _aCons_[_jLoopCons1_] + char(10)
	            next
	        next
	    ok
	    return _cKnow_
	
	# Writes the knowledge to a file as .zknw text, adding the .zknw extension when it is missing.
	#
	#   pcFilename   The file name, as text; .zknw is added when missing.
	#   returns      nothing; a file is written
	#   see          ExportToKnow, ImportKnow
	def WriteToKnowFile(pcFilename)
	    if StzRight(pcFilename, 5) != ".zknw"
	        pcFilename += ".zknw"
	    ok
	    write(pcFilename, This.ExportToKnow())
	
	    # Writes the knowledge to a .zknw file; another spelling of the write.
	    #
	    #   pcFileName   The file name, as text; .zknw is added when missing.
	    #   returns      nothing; a file is written
	    #   see          WriteToKnowFile
	    def WriteKnowFile(pcFileName)
		This.WriteToKnowFile(pcFilename)

	# Facts arrive WITH their provenance (AddFactXT), so a strict graph
	# applies its own rules to them: a fact without :source and :confidence
	# is refused, a :Unique conflict is refused and recorded -- and the
	# refusals are RETURNED, never silently dropped. The other graph's
	# recorded contradictions are carried over.
	# Returns [ :merged = n, :refused = [ [ s, p, o, why ], ... ] ].
	def _MergeKnowledgeBase(oOther)
	    _nMerged_ = 0
	    _aRefused_ = []
	    _aFacts_ = oOther.Facts()
	    _nFacts1Len_ = len(_aFacts_)
	    for _iLoopFacts1_ = 1 to _nFacts1Len_
	    	_aFact_ = _aFacts_[_iLoopFacts1_]
	        _aMeta_ = oOther.MetaOfFact(_aFact_[1], _aFact_[2], _aFact_[3])
	        if len(_aMeta_) > 0
	            try
	                _nOk_ = This.AddFactXT(_aFact_[1], _aFact_[2], _aFact_[3], _aMeta_)
	                if _nOk_ = 1
	                    _nMerged_++
	                else
	                    _aRefused_ + [ _aFact_[1], _aFact_[2], _aFact_[3], "contradicts a :Unique law (recorded)" ]
	                ok
	            catch
	                _aRefused_ + [ _aFact_[1], _aFact_[2], _aFact_[3], cCatchError ]
	            done
	        but @bStrictMode
	            _aRefused_ + [ _aFact_[1], _aFact_[2], _aFact_[3], "strict mode: no provenance" ]
	        else
	            This.AddFact(_aFact_[1], _aFact_[2], _aFact_[3])
	            _nMerged_++
	        ok
	    end
	    _aOtherC_ = oOther.Contradictions()
	    _nOC_ = len(_aOtherC_)
	    for _iOC_ = 1 to _nOC_
	        if NOT This._HasContradiction(_aOtherC_[_iOC_])
	            @aContradictions + _aOtherC_[_iOC_]
	        ok
	    next
	    # the ontology (laws) merges too -- deduped per (property, law)
	    _aOnt_ = oOther.Ontology()
	    _nOnt2Len_ = len(_aOnt_)
	    for _iLoopOnt2_ = 1 to _nOnt2Len_
	        _aCons_ = _aOnt_[_iLoopOnt2_][:constraints]
	        _nCons2Len_ = len(_aCons_)
	        for _jLoopCons2_ = 1 to _nCons2Len_
	            if NOT This.RelationHasLaw("" + _aOnt_[_iLoopOnt2_][:property], "" + _aCons_[_jLoopCons2_])
	                This.DefineProperty(_aOnt_[_iLoopOnt2_][:property], [ _aCons_[_jLoopCons2_] ])
	            ok
	        next
	    next
	    return [ :merged = _nMerged_, :refused = _aRefused_ ]

	def _HasContradiction(paC)
	    _n_ = len(@aContradictions)
	    for _i_ = 1 to _n_
	        _a_ = @aContradictions[_i_]
	        if "" + _a_[:subject] = "" + paC[:subject] and "" + _a_[:relation] = "" + paC[:relation] and
	           "" + _a_[:existing] = "" + paC[:existing] and "" + _a_[:attempted] = "" + paC[:attempted] and
	           "" + _a_[:source] = "" + paC[:source]
	            return 1
	        ok
	    next
	    return 0

	# Returns the provenance recorded for a fact, as [ name, value ] pairs; [ ] when none; the match ignores case.
	#
	#   pcS        the subject of the fact
	#   pcP        the predicate of the fact
	#   pcO        the object of the fact
	#   returns    a list of pairs
	#   see        FactMeta, Admit
	#@ aka  The provenance recorded for a fact ([] when none). The match ignores case, as the graph's own nodes do.
	def MetaOfFact(pcS, pcP, pcO)
	    _cS_ = StzLower("" + pcS)
	    _cP_ = StzLower("" + pcP)
	    _cO_ = StzLower("" + pcO)
	    _n_ = len(@aFactMeta)
	    for _i_ = 1 to _n_
	        _aT_ = @aFactMeta[_i_][:fact]
	        if _aT_[1] = _cS_ and _aT_[2] = _cP_ and _aT_[3] = _cO_
	            if isList(@aFactMeta[_i_][:meta])  return @aFactMeta[_i_][:meta]  ok
	            return []
	        ok
	    next
	    return []

	# Parser hooks: rebuild what a .zknw file recorded, as it was recorded.
	def _RestoreFactMeta(pcS, pcP, pcO, pcKey, xValue)
	    _aKey_ = [ StzLower("" + pcS), StzLower("" + pcP), StzLower("" + pcO) ]
	    _n_ = len(@aFactMeta)
	    for _i_ = 1 to _n_
	        _aT_ = @aFactMeta[_i_][:fact]
	        if _aT_[1] = _aKey_[1] and _aT_[2] = _aKey_[2] and _aT_[3] = _aKey_[3]
	            @aFactMeta[_i_][:meta] + [ "" + pcKey, xValue ]
	            return
	        ok
	    next
	    @aFactMeta + [ :fact = _aKey_, :meta = [ [ "" + pcKey, xValue ] ] ]

	def _RestoreContradiction(paC)
	    if NOT This._HasContradiction(paC)
	        @aContradictions + paC
	    ok

# Reads the text or file of a knowledge document and builds the stzKnowledgeGraph it records.
#
# The document is a knowledge header with the quoted id of the graph, then sections: facts, one
# subject | relation | object line each, ontology, provenance and contradictions. The parser keeps
# no state, and it is what ImportKnow uses behind the scenes. A document with sections but no header
# raises error R13, and a fact line that does not hold exactly three parts is skipped.
#
#   receiver   o1 = new stzKnowParser() cText = 'knowledge "pantry"' + char(10) + "facts" + char(10)
#              + "rice | isa | grain" + char(10) + "tea | isa | leaf"
#   example    oKg = o1.Parse(cText)
#              ? oKg.Id()
#              #--> pantry
#              ? @@( oKg.Facts() )
#              #--> [ [ "rice", "isa", "grain" ], [ "tea", "isa", "leaf" ] ]
#   see        stzKnowledgeGraph
class stzKnowParser from stzObject
    # Builds a parser for knowledge files; it keeps no state between parses.
    #
    #   returns    nothing; the object is built
    #   note       one parser can read any number of texts and files
    #   see        Parse, ParseFile
    def init()
    # Reads a .zknw knowledge file from disk and builds the knowledge graph it describes.
    #
    #   pcFilename   the path of the file to read
    #   returns      a stzKnowledgeGraph; an empty text for a file with no content
    #   note         the file is read whole and handed to Parse; it does not check the extension
    #   warning      a path that cannot be opened raises error R35 Can't create/open the file; a
    #                file with no knowledge header raises error R13 Object is required, as Parse
    #                does
    #   see          Parse, ImportKnow
    #@ aka  stateless parser; shields stzObject's 1-arg init so `new stzKnowParser()` works (R1 fix, 2026-07-14 -- the ImportKnow path was dead with R19 before this)
    def ParseFile(pcFilename)
        _cContent_ = read(pcFilename)
        return This.Parse(_cContent_)
    
    # Reads the text of a knowledge file and builds the knowledge graph it describes.
    #
    #   pcContent   the text, a header line such as knowledge "name" followed by sections facts,
    #               ontology, provenance and contradictions
    #   returns     a stzKnowledgeGraph named by the quoted id in the header; an empty text when the
    #               text has no content
    #   note        blank lines and lines starting with # are ignored; the text of an empty or
    #               comment-only file answers an empty text, not a graph
    #   warning     text with facts but no knowledge header raises error R13 Object is required,
    #               because the graph is only made when the header is met; a fact line with other
    #               than three parts is skipped without a message
    #   see         ParseFile, ExportToKnow
    def Parse(pcContent)
        _oKG_ = ""
        _acLines_ = split(pcContent, char(10))
        _cSection_ = ""
        
        _nAcLines1Len_ = len(_acLines_)
        for _iLoopAcLines1_ = 1 to _nAcLines1Len_
        	_cLine_ = _acLines_[_iLoopAcLines1_]
            _cLine_ = trim(_cLine_)
            if _cLine_ = "" or StzLeft(_cLine_, 1) = "#"
                loop
            ok
            
            if StzFindFirst("knowledge ", _cLine_)
                _cId_ = This._ExtractQuoted(_cLine_)
                _oKG_ = new stzKnowledgeGraph(_cId_)
            
            but _cLine_ = "namespaces"
                _cSection_ = "namespaces"
            but _cLine_ = "ontology"
                _cSection_ = "ontology"
            but _cLine_ = "facts"
                _cSection_ = "facts"
            but _cLine_ = "rules"
                _cSection_ = "rules"
            but _cLine_ = "provenance"
                _cSection_ = "provenance"
            but _cLine_ = "contradictions"
                _cSection_ = "contradictions"
            
            but _cSection_ = "facts" and StzFindFirst("|", _cLine_)
                _aParts_ = StzKnowSplit(_cLine_)
                if len(_aParts_) = 3
                    _oKG_.AddFact(_aParts_[1], _aParts_[2], _aParts_[3])
                ok

            but _cSection_ = "provenance" and StzFindFirst("|", _cLine_)
                _aParts_ = StzKnowSplit(_cLine_)
                if len(_aParts_) = 6
                    if _aParts_[5] = "number"
                        _xV_ = 0 + _aParts_[6]
                    else
                        _xV_ = _aParts_[6]
                    ok
                    _oKG_._RestoreFactMeta(_aParts_[1], _aParts_[2], _aParts_[3], _aParts_[4], _xV_)
                ok

            but _cSection_ = "contradictions" and StzFindFirst("|", _cLine_)
                _aParts_ = StzKnowSplit(_cLine_)
                if len(_aParts_) = 5
                    _oKG_._RestoreContradiction([ :subject = _aParts_[1], :relation = _aParts_[2],
                        :existing = _aParts_[3], :attempted = _aParts_[4], :source = _aParts_[5] ])
                ok

            but _cSection_ = "ontology" and StzFindFirst("|", _cLine_)
                _aParts_ = split(_cLine_, "|")
                if len(_aParts_) = 2
                    _oKG_.DefineProperty(trim(_aParts_[1]), [ trim(_aParts_[2]) ])
                ok
            ok
        end
        
        return _oKG_
    
    def _ExtractQuoted(_cLine_)
        _nStart_ = StzFindFirst('"', _cLine_)
        if _nStart_ = 0 return "" ok
        _nEnd_ = StzMid(_cLine_, _nStart_ + 1, StzLen(_cLine_) - _nStart_)
        _nEnd_ = StzFindFirst('"', _nEnd_)
        return StzMid(_cLine_, _nStart_ + 1, _nEnd_ - 1)
