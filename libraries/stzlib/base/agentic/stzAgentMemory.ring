# R5 -- stzAgentMemory: an agent's memory HOLDS a knowledge graph (LAW 5)
# In nature a memory HOLDS knowledge -- not the inverse -- so this is a
# COMPOSITION, never an IS-A: the memory owns its OWN stzKnowledgeGraph
# (governed, provable, persistable) and gives the agent a thin face onto it.
# No new machinery: what a memory holds is knowledge (R1).
#
#   oMem = new stzAgentMemory("waiter")
#   oMem.Learn("table-4", "wants", "water")
#   ? oMem.Fact("table-4", "wants", "water")   #--> 1
#   ? oMem.Recall("table-4", "wants")          #--> [ "water" ]

# Holds what an agent knows as facts in its own knowledge graph, each one carrying where and when it was learned.
#
# A memory owns a stzKnowledgeGraph, named mem-<agent>, rather than being one: it gives the agent a
# thin face of subject, predicate, object triples. Text is folded to lower case on the way in, so
# Fact and Recall ignore case. Every fact records its source (agent:<name> unless the caller says
# otherwise) and the time learned; nothing invents a confidence. Save and Restore carry the facts
# and their provenance through a .zknw knowledge file. Restore must be given the full file name with
# the extension.
#
#   receiver   o1 = new stzAgentMemory("waiter")
#   example    o1.Learn("table-4", "wants", "water")
#              ? o1.Fact("table-4", "wants", "water")
#              #--> 1
#              ? @@( o1.Recall("table-4", "wants") )
#              #--> [ "water" ]
#              ? o1.ProvenanceOf("table-4", "wants", "water")[1][2]
#              #--> agent:waiter
#   see        stzKnowledgeGraph, stzAgentSkill, stzPIAgent
class stzAgentMemory from stzObject

	@oKG = ""
	@cAgent = ""

	# Builds an empty memory for the named agent, backed by its own knowledge graph called mem-<name>.
	#
	#   pcAgentName   the owning agent's name, recorded as the source of every fact it learns
	#   returns       nothing; the object is built
	#   see           Learn, GraphQ
	def init(pcAgentName)
		@cAgent = "" + pcAgentName
		@oKG = new stzKnowledgeGraph("mem-" + pcAgentName)

	# Returns the knowledge graph the memory holds, for queries the memory face does not offer.
	#
	#   returns    a stzKnowledgeGraph
	#   see        Prove, Save
	def GraphQ()
		return @oKG

	# Stores one fact as a subject, predicate, object triple, in lower case, with the owning agent and the time as its provenance.
	#
	#   pcS        the subject
	#   pcP        the predicate
	#   pcO        the object
	#   returns    the memory itself, so calls chain
	#   note       learning a fact already held adds nothing; LearnXT takes the caller's own
	#              provenance, such as [ :source = "sensor-3", :confidence = 0.8 ], and defaults
	#              :source to agent:<name>
	#   see        Fact, Forget
	#@ aka  A learned fact carries its PROVENANCE: which agent learned it (:source = "agent:<name>") and when (:learnedat, epoch ms). It used to carry nothing, so a memory read back could not say where a belief came from. No :confidence is invented -- nobody stated one; LearnXT takes the caller's own.
	def Learn(pcS, pcP, pcO)
		return This.LearnXT(pcS, pcP, pcO, [])

	# Learn with the caller's provenance (e.g. [ :source = "sensor-3",
	# :confidence = 0.8 ]); :source defaults to this agent, :learnedat to now.
	def LearnXT(pcS, pcP, pcO, paMeta)
		_aMeta_ = []
		if isList(paMeta)
			_n_ = len(paMeta)
			for _i_ = 1 to _n_
				_aMeta_ + paMeta[_i_]
			next
		ok
		if NOT HasKey(_aMeta_, :source)
			_aMeta_ + [ "source", "agent:" + @cAgent ]
		ok
		if NOT HasKey(_aMeta_, :learnedat)
			_aMeta_ + [ "learnedat", StzEngineTimeNowMs() ]
		ok
		@oKG.AddFactXT(StzLower("" + pcS), StzLower("" + pcP), StzLower("" + pcO), _aMeta_)
		return This

	# Returns where a fact came from: the source, the learning time and any confidence recorded with it.
	#
	#   pcS        the subject
	#   pcP        the predicate
	#   pcO        the object
	#   returns    a hash list [ :source, :learnedat ] plus :confidence when given; an empty list
	#              for an unknown fact
	#   note       the source keeps the agent name as it was given
	#   see        Fact
	#@ aka  Where a fact came from -- the provenance recorded when it was learned.
	def ProvenanceOf(pcS, pcP, pcO)
		return @oKG.MetaOfFact(pcS, pcP, pcO)

	# TRUE if the memory holds that exact triple; case is ignored.
	#
	#   pcS        the subject
	#   pcP        the predicate
	#   pcO        the object
	#   returns    TRUE or FALSE
	#   see        Recall, Learn
	def Fact(pcS, pcP, pcO)
		_cS_ = StzLower("" + pcS)
		_cP_ = StzLower("" + pcP)
		_cO_ = StzLower("" + pcO)
		_aE_ = @oKG.Edges()
		_n_ = len(_aE_)
		for _i_ = 1 to _n_
			if _aE_[_i_][:from] = _cS_ and _aE_[_i_][:label] = _cP_ and
			   _aE_[_i_][:to] = _cO_
				return 1
			ok
		next
		return 0

	# Returns every object the memory holds for a subject and predicate, in the order learned.
	#
	#   pcS        the subject
	#   pcP        the predicate
	#   returns    a list of text; empty when nothing is known
	#   see        Fact, Learn
	def Recall(pcS, pcP)
		_cS_ = StzLower("" + pcS)
		_cP_ = StzLower("" + pcP)
		_acO_ = []
		_aE_ = @oKG.Edges()
		_n_ = len(_aE_)
		for _i_ = 1 to _n_
			if _aE_[_i_][:from] = _cS_ and _aE_[_i_][:label] = _cP_
				_acO_ + _aE_[_i_][:to]
			ok
		next
		return _acO_

	# Removes one fact; forgetting a fact that is not held changes nothing.
	#
	#   pcS        the subject
	#   pcP        the predicate
	#   pcO        the object
	#   returns    the memory itself, so calls chain
	#   see        Learn, NumberOfFacts
	def Forget(pcS, pcP, pcO)
		@oKG.RemoveFact(StzLower("" + pcS), StzLower("" + pcP), StzLower("" + pcO))
		return This

	# Returns how many facts the memory holds.
	#
	#   returns    a number
	#   see        Learn, Forget
	def NumberOfFacts()
		return len(@oKG.Facts())

	# Asks the graph to prove a triple from recorded facts and lawful chains, with the reasoning narrated.
	#
	#   paTriple   a list [ subject, predicate, object ], in lower case
	#   returns    a hash list [ :verdict, :goal, :steps, :narration, :certainty ]; verdict is 1
	#              when proved, 0 when not derivable
	#   see        Fact, GraphQ
	def Prove(paTriple)
		return @oKG.Prove(paTriple)

	# Writes the memory, provenance included, to a knowledge file, adding the extension .zknw when it is missing.
	#
	#   pcFile     the path of the file to write
	#   returns    nothing; a file is written
	#   note       pass a name ending in .zknw to both Save and Restore
	#   warning    Restore needs the full name: a file saved as mem is written as mem.zknw, and
	#              Restore of mem raises error R13 Object is required because the name is read as
	#              the text of a knowledge file
	#   see        Restore, GraphQ
	def Save(pcFile)
		return @oKG.WriteToKnowFile(pcFile)

	# Reads a saved memory back, provenance included, and merges its facts into this memory.
	#
	#   pcFile     the path of a .zknw file
	#   returns    a hash list [ :merged, :refused ]; refused rows are [ s, p, o, why ]
	#   note       merged counts the facts read, including ones already held
	#   see        Save, Learn
	#@ aka  Read a saved memory back, provenance included. Returns the merge report [ :merged, :refused ]. (Not "Load": a Ring keyword.)
	def Restore(pcFile)
		return @oKG.ImportKnow("" + pcFile)
