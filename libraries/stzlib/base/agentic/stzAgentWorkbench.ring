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

# Gives an agent a safe world to rehearse file changes in: writes land in memory, and only an update plan leads toward the disk.
#
# A workbench is an in-memory virtual file system kept in a process-wide table and reached through
# faces that carry only its id, so copies of a face all reach the one live twin. The rehearsal verbs
# record operations, and the inspection methods read the twin and never the disk. ReadThrough
# answers from the twin first, an empty text for a path the rehearsal deleted, and the real disk
# otherwise. The only export toward reality is GenerateUpdatePlan, which a committing actor executes
# under the plan's scope, capability and governance gates. Open one with StzOpenAgentWorkbench, or
# give it to an agent with GiveWorkbench; the owner closes it with StzCloseAgentWorkbench.
#
#   receiver   o1 = StzAgentWorkbenchQ(StzOpenAgentWorkbench())
#   example    o1.SetActor("kitchen-bot")
#              o1.CreateFile("/shop/orders.txt", "milk")
#              o1.WriteFile("/shop/orders.txt", "milk, eggs")
#              ? o1.ContentOf("/shop/orders.txt")
#              #--> milk, eggs
#              ? o1.NumberOfOperations()
#              #--> 2
#              o1.DeleteFile("/shop/orders.txt")
#              ? len(o1.ReadThrough("/shop/orders.txt"))
#              #--> 0
#              ? o1.WasDeleted("/shop/orders.txt")
#              #--> 1
#   see        stzPIAgent, stzVirtualFileSystem, stzUpdatePlan
class stzAgentWorkbench from stzObject

	@nId = 0

	# Builds a face onto an open workbench, a rehearsal file system held in memory, reached by its numeric id.
	#
	#   pnId       the id returned by StzOpenAgentWorkbench or by Id
	#   returns    nothing; the object is built
	#   note       the face holds only the id, so copies of it all reach the same one workbench
	#   warning    an id with no open workbench raises an error naming the id at construction, not
	#              at the first write
	#   see        Id, SetActor
	def init(pnId)
		@nId = 0 + pnId
		This._Slot()   # a face onto a bench that does not exist raises NOW,
	# Returns the number of the workbench this face reaches.
	#
	#   returns    a number
	#   see        init
	#@ aka  at construction, not at the first write
	def Id()
		return @nId

	# Stamps the workbench with the name of whoever proposes the changes, so the history and the plan show an author.
	#
	#   pcName     the actor's name, shown in brackets after each rehearsed operation
	#   returns    the face itself, so calls chain
	#   see        HistoryText, GenerateUpdatePlan
	#@ aka  Stamp the twin's actor so every rehearsed operation carries WHO proposed it -- the plan's narration then reads as a history with authors, not a list of anonymous changes.
	def SetActor(pcName)
		$aStzAgentWorkbenches[This._Slot()][2].SetActor(pcName)
		return This

	# Rehearses creating a file with some text; nothing touches the disk.
	#
	#   pcPath      the path of the file
	#   pcContent   its text
	#   returns     the face itself, so calls chain
	#   note        creating a path that already exists is accepted and replaces its content; a
	#               later Validate of the plan reports problems with reality
	#   see         WriteFile, Exists, ContentOf
	#@ aka  -- rehearsal verbs: every one reaches the live twin THROUGH the -- table index, never through a copy ------------------------------
	def CreateFile(pcPath, pcContent)
		$aStzAgentWorkbenches[This._Slot()][2].CreateFile(pcPath, pcContent)
		return This

	# Rehearses writing text into a file; nothing touches the disk.
	#
	#   pcPath      the path of the file
	#   pcContent   the new text
	#   returns     the face itself, so calls chain
	#   note        writing a path the workbench does not hold creates it
	#   see         CreateFile, ContentOf
	def WriteFile(pcPath, pcContent)
		$aStzAgentWorkbenches[This._Slot()][2].WriteFile(pcPath, pcContent)
		return This

	# Rehearses creating a folder; nothing touches the disk.
	#
	#   pcPath     the path of the folder
	#   returns    the face itself, so calls chain
	#   see        DeleteFolder, Exists
	def CreateFolder(pcPath)
		$aStzAgentWorkbenches[This._Slot()][2].CreateFolder(pcPath)
		return This

	# Rehearses deleting a file, leaving a mark that ReadThrough reads as an empty file.
	#
	#   pcPath     the path of the file
	#   returns    the face itself, so calls chain
	#   note       deleting a path nobody holds is accepted; Validate on the plan reports that the
	#              target is absent in reality
	#   see        DeleteFolder, WasDeleted
	def DeleteFile(pcPath)
		$aStzAgentWorkbenches[This._Slot()][2].DeleteFile(pcPath)
		return This

	# Rehearses deleting a folder; nothing touches the disk.
	#
	#   pcPath     the path of the folder
	#   returns    the face itself, so calls chain
	#   see        DeleteFile, WasDeleted
	def DeleteFolder(pcPath)
		$aStzAgentWorkbenches[This._Slot()][2].DeleteFolder(pcPath)
		return This

	# Rehearses copying a file inside the workbench.
	#
	#   pcFrom     the source path
	#   pcTo       the path of the copy
	#   returns    the face itself, so calls chain
	#   note       a source the workbench does not hold is accepted, and Validate on the plan
	#              reports it as absent in reality
	#   see        MoveFile, MirrorFile
	def CopyFile(pcFrom, pcTo)
		$aStzAgentWorkbenches[This._Slot()][2].CopyFile(pcFrom, pcTo)
		return This

	# Rehearses moving a file; the source path then counts as deleted.
	#
	#   pcFrom     the source path
	#   pcTo       the destination path
	#   returns    the face itself, so calls chain
	#   see        CopyFile, WasDeleted
	def MoveFile(pcFrom, pcTo)
		$aStzAgentWorkbenches[This._Slot()][2].MoveFile(pcFrom, pcTo)
		return This

	# Copies a real file's text into the workbench so it can be changed there; the disk file is only read.
	#
	#   pcPath     the path of a real file
	#   returns    the face itself, so calls chain
	#   note       a path that does not exist on disk is ignored and records nothing
	#   see        ReadThrough, WriteFile
	def MirrorFile(pcPath)
		$aStzAgentWorkbenches[This._Slot()][2].MirrorFile(pcPath)
		return This

	# TRUE if the workbench itself holds the path; the real disk is not asked.
	#
	#   pcPath     the path to test
	#   returns    TRUE or FALSE
	#   see        ExistsThrough, ContentOf
	#@ aka  -- free inspection (reads the TWIN, not disk) ---------------------
	def Exists(pcPath)
		return $aStzAgentWorkbenches[This._Slot()][2].Exists(pcPath)

	# Returns the text the workbench holds for a path; the real disk is not asked.
	#
	#   pcPath     the path of a rehearsed file
	#   returns    a text; empty when the workbench holds no such path
	#   see        ReadThrough, Exists
	def ContentOf(pcPath)
		return $aStzAgentWorkbenches[This._Slot()][2].ContentOf(pcPath)

	# Returns how many operations have been rehearsed.
	#
	#   returns    a number
	#   see        HistoryText, GenerateUpdatePlan
	def NumberOfOperations()
		return $aStzAgentWorkbenches[This._Slot()][2].NumberOfOperations()

	# Returns the rehearsal as numbered lines, each with its actor, ready to read or log.
	#
	#   returns    a multi-line text starting with Rehearsed operations (n):
	#   see        NumberOfOperations, SetActor
	def HistoryText()
		return $aStzAgentWorkbenches[This._Slot()][2].HistoryText()

	# TRUE if the rehearsal deleted or moved the path away and the workbench does not hold it now.
	#
	#   pcPath     the path to test
	#   returns    TRUE or FALSE
	#   note       a path deleted and then created again is held, so the answer is FALSE
	#   see        ReadThrough, ExistsThrough
	#@ aka  -- read-through: twin first, tombstones second, disk last ---------
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

	# Returns a file's text as the agent should see it: the workbench's own copy first, an empty text for a deleted path, otherwise the real disk.
	#
	#   pcPath     the path to read
	#   returns    a text
	#   note       reading is free and never changes the workbench; only writes are confined to it
	#   see        ExistsThrough, ContentOf, MirrorFile
	def ReadThrough(pcPath)
		if This.Exists(pcPath) = 1
			return This.ContentOf(pcPath)
		ok
		if This.WasDeleted(pcPath) = 1
			return ""
		ok
		return StzFileRead(pcPath)

	# TRUE if the file exists as the agent should see it: held by the workbench, or not deleted and present on the real disk.
	#
	#   pcPath     the path to test
	#   returns    TRUE or FALSE
	#   see        ReadThrough, Exists
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

	# Returns the rehearsal as an update plan, the one export toward reality, to be validated and committed by an actor that holds the authority.
	#
	#   returns    a stzUpdatePlan listing every rehearsed operation
	#   note       the plan is built from the history: Validate on it reports operations that do not
	#              match the real files
	#   see        NumberOfOperations, HistoryText
	#@ aka  -- the ONE export toward reality ----------------------------------
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
