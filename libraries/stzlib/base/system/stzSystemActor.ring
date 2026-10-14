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

# Stands for whoever acts on a system and carries the capability kinds that decide what it may commit.
#
# An actor holds a set of capability kinds from one lattice: effectful, sensing, compute and
# inference, the same lattice as stzSystemCapabilities and stzAgentGraph. Whether a plan may commit
# is decided against it, and the load-bearing rule is that a language-model actor holds only
# inference: it can propose, but Can(effectful) is FALSE so it can commit nothing that touches
# reality. Expression is free, admission is governed. The posture (trusted, external or sandboxed)
# is the second axis of the same gate.
#
#   receiver   o1 = new stzSystemActor("planner", [ "sensing", "compute" ])
#   example    ? o1.Can("sensing")
#              #--> 1
#              ? o1.IsEffectful()
#              #--> 0
#              o1.GrantKind("effectful")
#              ? o1.IsEffectful()
#              #--> 1
#              ? o1.Posture()
#              #--> trusted
#   see        stzSystemCapabilities, stzSystemProfile, stzNode
class stzSystemActor from stzObject

	@cName = ""
	@aKinds = []
	@cPosture = "trusted"

	# Creates an actor with a name and a set of capability kinds, trusted by default.
	#
	#   pcName     the actor's name
	#   paKinds    the capability kinds to grant, from effectful, sensing, compute and inference
	#   returns    nothing; the object is built
	#   warning    an unknown kind raises an error
	#   see        GrantKind, Can
	def init(pcName, paKinds)
		@cName = "" + pcName
		This.SetKinds(paKinds)

	# Returns the actor's name.
	#
	#   returns    a text
	#   see        SetName
	def Name()
		return @cName

	# Changes the actor's name.
	#
	#   pcName     the new name
	#   returns    the actor itself, so calls chain
	#   see        Name
	def SetName(pcName)
		@cName = "" + pcName
		return This

	# Returns the four capability kinds the lattice knows: effectful, sensing, compute and inference.
	#
	#   returns    a list of texts
	#   see        Kinds, GrantKind
	#@ aka  The closed lattice -- the same kinds an operation is coloured with and a system capability is classified into.
	def KnownKinds()
		return [ "effectful", "sensing", "compute", "inference" ]

	# Returns the capability kinds this actor holds, in the order granted.
	#
	#   returns    a list of texts
	#   see        KnownKinds, NumberOfKinds
	def Kinds()
		return @aKinds

	# Replaces the actor's capability kinds with a list, granting them one by one.
	#
	#   paKinds    the capability kinds to hold, from effectful, sensing, compute and inference
	#   returns    the actor itself, so calls chain
	#   warning    an unknown kind raises an error; a value that is not a list leaves the actor with
	#              no kinds
	#   see        GrantKind, Kinds
	def SetKinds(paKinds)
		@aKinds = []
		if isList(paKinds)
			_n_ = len(paKinds)
			for _i_ = 1 to _n_
				This.GrantKind(paKinds[_i_])
			next
		ok
		return This

	# Adds a capability kind to the actor; granting one it already holds changes nothing.
	#
	#   pcKind     the kind to grant, matched without regard to case
	#   returns    the actor itself, so calls chain
	#   warning    an unknown kind raises an error naming the four known ones
	#   see        RevokeKind, Can
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

	# Removes a capability kind from the actor; a kind it does not hold changes nothing.
	#
	#   pcKind     the kind to remove, matched without regard to case
	#   returns    the actor itself, so calls chain
	#   see        GrantKind, Can
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

	# TRUE if the actor holds a capability kind.
	#
	#   pcKind     the kind to test, matched without regard to case
	#   returns    TRUE or FALSE
	#   see        IsEffectful, GrantKind
	#@ aka  Does the actor hold this capability kind?
	def Can(pcKind)
		return This._InList(This._Norm(pcKind), @aKinds) > 0

		def Holds(pcKind)
			return This.Can(pcKind)

	# TRUE if the actor may change the outside world, that is holds the effectful kind.
	#
	#   returns    TRUE or FALSE
	#   warning    a language-model actor holds only inference, so it can propose a plan but commit
	#              nothing
	#   see        Can
	#@ aka  The one that decides whether a plan may cross: can this actor cause effects at all?
	def IsEffectful()
		return This.Can("effectful")

	# Returns the actor's posture: trusted, external or sandboxed; trusted by default.
	#
	#   returns    a text
	#   see        SetPosture
	def Posture()
		return @cPosture

	# Sets the actor's posture.
	#
	#   pcPosture   trusted, external or sandboxed, matched without regard to case
	#   returns     the actor itself, so calls chain
	#   warning     any other word raises an error
	#   see         Posture
	def SetPosture(pcPosture)
		_c_ = This._Norm(pcPosture)
		if This._InList(_c_, [ "trusted", "external", "sandboxed" ]) = 0
			StzRaise("A posture is trusted, external, or sandboxed.")
		ok
		@cPosture = _c_
		return This

	# Returns how many capability kinds the actor holds.
	#
	#   returns    a number
	#   see        Kinds
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

	# Prints three lines that describe the actor: its name and posture, its capabilities, and whether it can effect reality.
	#
	#   returns    nothing; it prints
	#   see        Kinds, Posture
	def Show()
		? "Actor '" + @cName + "'  posture: " + @cPosture
		? "  capabilities: " + _StzJoinComma(@aKinds)
		? "  can effect reality: " + This.IsEffectful()
