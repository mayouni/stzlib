#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZSYSTEMACTOR            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Phase 4 of the System Foundation -- the     #
#                  ACTOR whose authority gates the crossing.   #
#                  An actor carries a set of capability KINDS  #
#                  (effectful / sensing / compute / inference) #
#                  -- the SAME lattice as stzSystemCapabilities #
#                  (Phase 1b) and stzAgentGraph. Whether a     #
#                  plan may commit is decided against it.      #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# The authority axis of the scope model. An actor's capability kinds drive BOTH
# questions the foundation asks: "which of a system's capabilities may this actor
# exercise" (stzSystemProfile.CapabilitiesForActorKinds, Phase 1b) AND "may this
# actor commit this plan" (stzUpdatePlan.Execute, Phase 4). One vocabulary.
#
# The load-bearing rule (5.7): an LLM actor's effect-capability set is EMPTY. So
# LLMActor() holds only "inference" -- it can propose a plan, but Can("effectful")
# is false, so it can commit NOTHING that touches reality. Expression is free;
# admission is governed.

  #=============#
 #  FUNCTIONS  #
#=============#

func StzSystemActorQ()
	return new stzSystemActor("", [])

func SystemActor(pcName, paKinds)
	return new stzSystemActor(pcName, paKinds)

# Factory actors -- capability sets mirror stzAgentGraph exactly.

func HumanActor(pcName)
	_o_ = new stzSystemActor(pcName, [ "effectful", "compute", "sensing" ])
	_o_.SetPosture("trusted")
	return _o_

func PIActor(pcName)
	_o_ = new stzSystemActor(pcName, [ "effectful", "compute", "sensing" ])
	_o_.SetPosture("trusted")
	return _o_

func GuardianActor(pcName)
	_o_ = new stzSystemActor(pcName, [ "compute", "sensing" ])
	_o_.SetPosture("external")
	return _o_

func LLMActor(pcName)
	_o_ = new stzSystemActor(pcName, [ "inference" ])
	_o_.SetPosture("sandboxed")
	return _o_

func ToolActor(pcName)
	_o_ = new stzSystemActor(pcName, [ "compute" ])
	_o_.SetPosture("external")
	return _o_


  #==================#
 #  STZSYSTEMACTOR  #
#==================#

class stzSystemActor from stzObject

	@cName = ""
	@aKinds = []
	@cPosture = "trusted"

	def init(pcName, paKinds)
		@cName = "" + pcName
		This.SetKinds(paKinds)

	def Name()
		return @cName

	def SetName(pcName)
		@cName = "" + pcName
		return This

	# The closed lattice -- the same kinds an operation is coloured with and a
	# system capability is classified into.
	def KnownKinds()
		return [ "effectful", "sensing", "compute", "inference" ]

	def Kinds()
		return @aKinds

	def SetKinds(paKinds)
		@aKinds = []
		if isList(paKinds)
			_n_ = len(paKinds)
			for _i_ = 1 to _n_
				This.GrantKind(paKinds[_i_])
			next
		ok
		return This

	def GrantKind(pcKind)
		_c_ = This._Norm(pcKind)
		if This._InList(_c_, This.KnownKinds()) = 0
			StzRaise("Unknown capability kind: '" + _c_ +
				 "'. Known: effectful, sensing, compute, inference.")
		ok
		if This._InList(_c_, @aKinds) = 0
			@aKinds + _c_
		ok
		return This

	def RevokeKind(pcKind)
		_c_ = This._Norm(pcKind)
		_aNew_ = []
		_n_ = len(@aKinds)
		for _i_ = 1 to _n_
			if @aKinds[_i_] != _c_
				_aNew_ + @aKinds[_i_]
			ok
		next
		@aKinds = _aNew_
		return This

	# Does the actor hold this capability kind?
	def Can(pcKind)
		return This._InList(This._Norm(pcKind), @aKinds) > 0

		def Holds(pcKind)
			return This.Can(pcKind)

	# The one that decides whether a plan may cross: can this actor cause
	# effects at all?
	def IsEffectful()
		return This.Can("effectful")

	def Posture()
		return @cPosture

	def SetPosture(pcPosture)
		_c_ = This._Norm(pcPosture)
		if This._InList(_c_, [ "trusted", "external", "sandboxed" ]) = 0
			StzRaise("A posture is trusted, external, or sandboxed.")
		ok
		@cPosture = _c_
		return This

	def NumberOfKinds()
		return len(@aKinds)

	def _Norm(pKind)
		return StzLower(ring_trim("" + pKind))

	def _InList(pItem, paList)
		_n_ = len(paList)
		for _i_ = 1 to _n_
			if paList[_i_] = pItem
				return _i_
			ok
		next
		return 0

	def Show()
		? "Actor '" + @cName + "'  posture: " + @cPosture
		? "  capabilities: " + _StzJoinComma(@aKinds)
		? "  can effect reality: " + This.IsEffectful()
