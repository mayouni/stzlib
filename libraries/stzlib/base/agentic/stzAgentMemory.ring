# R5 -- stzAgentMemory: the agent's memory IS a knowledge graph (LAW 5)
# A thin, agent-facing face over its OWN stzKnowledgeGraph -- governed,
# provable, persistable. No new machinery: memory is knowledge (R1).
#
#   oMem = new stzAgentMemory("waiter")
#   oMem.Learn("table-4", "wants", "water")
#   ? oMem.Fact("table-4", "wants", "water")   #--> 1
#   ? oMem.Recall("table-4", "wants")          #--> [ "water" ]

class stzAgentMemory from stzObject

	@oKG = NULL

	def init(pcAgentName)
		@oKG = new stzKnowledgeGraph("mem-" + pcAgentName)

	def Graph()
		return @oKG

	def Learn(pcS, pcP, pcO)
		@oKG.AddFact(StzLower("" + pcS), StzLower("" + pcP), StzLower("" + pcO))
		return This

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

	def Forget(pcS, pcP, pcO)
		@oKG.RemoveFact(StzLower("" + pcS), StzLower("" + pcP), StzLower("" + pcO))
		return This

	def NumberOfFacts()
		return len(@oKG.Facts())

	def Prove(paTriple)
		return @oKG.Prove(paTriple)

	def Save(pcFile)
		return @oKG.WriteToKnowFile(pcFile)
