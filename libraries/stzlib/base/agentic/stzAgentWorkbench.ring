#=====================================================================#
#  STZAGENTWORKBENCH -- the binding of the safe world (ruling 3.2)    #
#  an agent rehearses; only a committing actor changes reality        #
#=====================================================================#
/*
	`Agents That Cannot Hurt You`: "We will not build safe agents. We
	will build a safe world, and let ordinary agents loose inside it."
	The safe world existed -- stzVirtualFileSystem rehearses, stzUpdatePlan
	narrates, validates, takes rejections and commits under scope +
	capability + governance -- and no agent had ever been handed it:
	base/agentic/ contained ZERO references to any of it, while a shipped
	ring: function wrote the estate's real ledger on a tick (measured
	2026-08-22, ruling 3.2). This file is the introduction.

	WHAT A WORKBENCH IS: an stzVirtualFileSystem held in a process-global
	table and reached through FACES that carry only an ID. The table is
	the same shape stzGovernance uses, for the same reason: Ring copies
	objects on assignment, so a twin held in an attribute forks per copy
	and the rehearsal lands in a twin nobody reads. A face is stateless,
	an id survives any copy, and a method-call THROUGH THE TABLE INDEX
	reaches the one live twin. (Probed before it was built: registry
	mutation through the index, plan-from-stored-twin, capability-gated
	commit -- all hold.)

	HOW AN AGENT MEETS IT: oAg.GiveWorkbench() opens one and remembers
	its id. While that agent's Cycle() runs, the id is the AMBIENT
	workbench -- so a ring: function, which receives only (poMemory),
	reaches the bench as StzActiveWorkbenchQ() with no signature change.
	File writes land in the twin; the tick's ONLY export toward reality
	is oAg.GenerateUpdatePlan(), which a COMMITTING ACTOR executes under
	the three gates stzUpdatePlan already holds. The proposer is
	creative; the committer is deterministic and boring on purpose.

	READ-THROUGH, AND ITS ONE HONEST LIMIT: ReadThrough(path) answers
	from the twin when the twin holds the path, answers "" when the twin
	REHEARSED A DELETE of it (a tombstone, read from the history), and
	falls back to real disk otherwise -- so a function sees its own
	rehearsed writes without mirroring the world first. Reads are
	sensing and stay free; only writes are confined to the twin.
	Expression is free, admission is governed.
*/

# [ [ id, oVfs ], ... ] -- the live twins. Reached ONLY through the
# index; never assign a row's [2] to a local and write through it.
$aStzAgentWorkbenches = []
$nStzAgentWorkbenchSeq = 0

# The AMBIENT workbench id: non-zero exactly while a workbench-holding
# agent is mid-Cycle() (stzPIAgent brackets it, restoring the previous
# value on the way out so nested cycles across agents stay correct).
$nStzActiveAgentWorkbench = 0

func StzOpenAgentWorkbench()
	$nStzAgentWorkbenchSeq = $nStzAgentWorkbenchSeq + 1
	$aStzAgentWorkbenches + [ $nStzAgentWorkbenchSeq, new stzVirtualFileSystem() ]
	return $nStzAgentWorkbenchSeq

func StzAgentWorkbenchQ(pnId)
	return new stzAgentWorkbench(pnId)

func StzInWorkbench()
	if $nStzActiveAgentWorkbench > 0
		return 1
	ok
	return 0

func StzActiveWorkbenchQ()
	if $nStzActiveAgentWorkbench = 0
		stzraise("StzActiveWorkbenchQ: no workbench is active -- one exists " +
			"only while a workbench-holding agent is mid-Cycle(). Give the " +
			"agent one (GiveWorkbench) or ask StzInWorkbench() first.")
	ok
	return new stzAgentWorkbench($nStzActiveAgentWorkbench)

# The OWNER's explicit act, same contract as stzGovernance.Release():
# a copy calling it would free a twin every other face is still reading.
func StzCloseAgentWorkbench(pnId)
	_n_ = len($aStzAgentWorkbenches)
	for _i_ = 1 to _n_
		if $aStzAgentWorkbenches[_i_][1] = pnId
			del($aStzAgentWorkbenches, _i_)
			return 1
		ok
	next
	return 0

class stzAgentWorkbench from stzObject

	@nId = 0

	def init(pnId)
		@nId = 0 + pnId
		This._Slot()   # a face onto a bench that does not exist raises NOW,
		               # at construction, not at the first write

	def Id()
		return @nId

	# Stamp the twin's actor so every rehearsed operation carries WHO
	# proposed it -- the plan's narration then reads as a history with
	# authors, not a list of anonymous changes.
	def SetActor(pcName)
		$aStzAgentWorkbenches[This._Slot()][2].SetActor(pcName)
		return This

	#-- rehearsal verbs: every one reaches the live twin THROUGH the
	#-- table index, never through a copy ------------------------------

	def CreateFile(pcPath, pcContent)
		$aStzAgentWorkbenches[This._Slot()][2].CreateFile(pcPath, pcContent)
		return This

	def WriteFile(pcPath, pcContent)
		$aStzAgentWorkbenches[This._Slot()][2].WriteFile(pcPath, pcContent)
		return This

	def CreateFolder(pcPath)
		$aStzAgentWorkbenches[This._Slot()][2].CreateFolder(pcPath)
		return This

	def DeleteFile(pcPath)
		$aStzAgentWorkbenches[This._Slot()][2].DeleteFile(pcPath)
		return This

	def DeleteFolder(pcPath)
		$aStzAgentWorkbenches[This._Slot()][2].DeleteFolder(pcPath)
		return This

	def CopyFile(pcFrom, pcTo)
		$aStzAgentWorkbenches[This._Slot()][2].CopyFile(pcFrom, pcTo)
		return This

	def MoveFile(pcFrom, pcTo)
		$aStzAgentWorkbenches[This._Slot()][2].MoveFile(pcFrom, pcTo)
		return This

	def MirrorFile(pcPath)
		$aStzAgentWorkbenches[This._Slot()][2].MirrorFile(pcPath)
		return This

	#-- free inspection (reads the TWIN, not disk) ---------------------

	def Exists(pcPath)
		return $aStzAgentWorkbenches[This._Slot()][2].Exists(pcPath)

	def ContentOf(pcPath)
		return $aStzAgentWorkbenches[This._Slot()][2].ContentOf(pcPath)

	def NumberOfOperations()
		return $aStzAgentWorkbenches[This._Slot()][2].NumberOfOperations()

	def HistoryText()
		return $aStzAgentWorkbenches[This._Slot()][2].HistoryText()

	#-- read-through: twin first, tombstones second, disk last ---------

	# Did the rehearsal remove this path? Only asked when the twin does
	# not hold it -- a path deleted and then re-created is simply held.
	def WasDeleted(pcPath)
		if This.Exists(pcPath) = 1
			return 0
		ok
		_aH_ = $aStzAgentWorkbenches[This._Slot()][2].History()
		_n_ = len(_aH_)
		for _i_ = 1 to _n_
			_cT_ = _aH_[_i_].Type()
			if _cT_ = "delete_file" or _cT_ = "delete_folder"
				if _aH_[_i_].Param("path") = pcPath
					return 1
				ok
			but _cT_ = "move_file"
				if _aH_[_i_].Param("from") = pcPath
					return 1
				ok
			ok
		next
		return 0

	def ReadThrough(pcPath)
		if This.Exists(pcPath) = 1
			return This.ContentOf(pcPath)
		ok
		if This.WasDeleted(pcPath) = 1
			return ""
		ok
		return StzFileRead(pcPath)

	def ExistsThrough(pcPath)
		if This.Exists(pcPath) = 1
			return 1
		ok
		if This.WasDeleted(pcPath) = 1
			return 0
		ok
		if StzFileExists(pcPath) = 1
			return 1
		ok
		return 0

	#-- the ONE export toward reality ----------------------------------

	# The rehearsal as a governed crossing artifact: narrated, ranked,
	# re-validated, rejectable per step, committed under scope +
	# capability + governance by whoever holds the executor's authority.
	def GenerateUpdatePlan()
		return $aStzAgentWorkbenches[This._Slot()][2].GenerateUpdatePlan()

	#-- internals ------------------------------------------------------

	def _Slot()
		if @nId = 0
			stzraise("stzAgentWorkbench: this face has no id -- it was built " +
				"with a paren-less `new stzAgentWorkbench`, which skips init(). " +
				"Use StzAgentWorkbenchQ(id).")
		ok
		_n_ = len($aStzAgentWorkbenches)
		for _i_ = 1 to _n_
			if $aStzAgentWorkbenches[_i_][1] = @nId
				return _i_
			ok
		next
		stzraise("stzAgentWorkbench: no workbench with id " + @nId +
			" -- it was never opened, or the owner closed it " +
			"(StzCloseAgentWorkbench). Open one with StzOpenAgentWorkbench().")
