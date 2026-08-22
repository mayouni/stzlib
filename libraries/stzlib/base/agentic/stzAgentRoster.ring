#=====================================================================#
#  STZAGENTROSTER -- the estate's own PowerShell mechanisms, ported   #
#  as ring: functions behind rows 1 and 2 of the migration ledger     #
#=====================================================================#
/*
	Backs two declarations that already exist and are not restated here:

		softanza/roster/silence-board.pia
		softanza/roster/ledger-roll.pia

	softanza/roster/MIGRATION.md is the ledger; softanza/prompts/46 is the
	ask. NO NEW RUNTIME: every function below is a plain Ring function
	taking (poMemory), called through the ring:<Fn> door
	stzAgentDeclaration already opened at load. What each one ports is
	named against the live PowerShell source in its own header, never
	restated as a number here -- read dashboard/central.ps1 for the
	thresholds, not this file.

	WHERE THE ESTATE LIVES: never hardcoded. StzRosterEstateRoot() reads
	the STZ_SOFTANZA_ROOT environment variable first (what a narrated
	test sets, pointed at a fixture folder so a test run can never touch
	the live journal or SESSION-LOG.md), and otherwise walks up from the
	working directory looking for a 'softanza' sibling that carries
	protocol/PATHS.md -- PATHS.md is the harness's own single source for
	where every repository lives, so this reads the same landmark
	central.ps1 does rather than a copy of its answer.

	THE SAFE-WORLD DOOR (ruling 3.2, 2026-08-22): this file is the FIRST
	CONSUMER of the workbench binding. Every file write below goes
	through the _StzRosterFile* helpers at the foot of this file: inside
	a workbench-holding agent's tick the write rehearses into the
	agent's stzVirtualFileSystem and reality changes only when a
	committing actor executes the exported stzUpdatePlan; outside one --
	the migration state the live estate still runs -- it is the direct
	write it always was. safeworld_narrated.ring holds the proof both
	worlds produce the same ledger.
*/

#---------------------------------------------------------------------#
#  WHERE THE ESTATE LIVES                                              #
#---------------------------------------------------------------------#

func StzRosterEstateRoot()
	_cEnv_ = EnvVar("STZ_SOFTANZA_ROOT")
	if _cEnv_ != "" and StzDirExists(_cEnv_)
		return _cEnv_
	ok

	_cCur_ = StzReplace(WorkingDirectory(), "\", "/")
	_aParts_ = StzSplit(_cCur_, "/")
	_n_ = len(_aParts_)
	for _i_ = _n_ to 1 step -1
		_aUp_ = []
		for _j_ = 1 to _i_
			_aUp_ + _aParts_[_j_]
		next
		_cUp_ = StzJoinWith(_aUp_, "/")
		if StzFileExists(_cUp_ + "/softanza/protocol/PATHS.md")
			return _cUp_ + "/softanza"
		ok
	next
	return ""

#---------------------------------------------------------------------#
#  SILENCE-BOARD -- expected against last seen, and a page that can    #
#  announce its own death                                              #
#---------------------------------------------------------------------#
# TODAY: dashboard/central.ps1, the SILENCE-BOARD block. Ported here:
# the 10-minute refresh (dashboard/machine.jsonl) and the dead-run
# detector over every repository's .central/runs/. NOT ported: the
# Windows-scheduled-task row -- this build has no engine binding onto
# the task scheduler, and the .pia's own coverage sentence never claims
# it ("repository rows measure EVIDENCE of wakes -- logs and cost
# lines"), so the gap is a stated absence rather than a silent one.

# SAMPLE -- senses only, and resets its own fact every cycle so a
# broken sampler can never coast on a stale green. Fail-open per
# mechanism (a missing machine.jsonl or an unreadable repo just yields
# no row for it); fails to write the heartbeat fact at all only when
# the estate root itself cannot be found, which is the one failure
# with nothing left to be open about.
func BoardSampleHeartbeats(poMemory)
	poMemory.Forget("board", "holds", "heartbeat")

	# "resolved to a path" is not "reached the evidence surface" -- the
	# board's own health is fail-loud, so a root that resolves to
	# somewhere with no dashboard/ at all is exactly the case ANNOUNCE
	# exists for, same as no root resolving at all.
	_cRoot_ = StzRosterEstateRoot()
	if _cRoot_ = "" or NOT StzDirExists(_cRoot_ + "/dashboard")
		return
	ok

	_cMachF_ = _cRoot_ + "/dashboard/machine.jsonl"
	if StzFileExists(_cMachF_)
		_cLast_ = _StzRosterLastLine(StzFileRead(_cMachF_))
		if _cLast_ != ""
			poMemory.Learn("the-10-minute-refresh", "last-seen", _cLast_)
		ok
	ok

	# raw sensing only -- BoardFindDeadRuns is the judge. A repo with no
	# .central/runs/ yields no row, which is not the same claim as "alive".
	_cReposRoot_ = StzPathDirname(_cRoot_)
	_aDirs_ = _StzRosterListDirs(_cReposRoot_)
	_n_ = len(_aDirs_)
	for _i_ = 1 to _n_
		_cRepo_ = _aDirs_[_i_]
		_cRunsDir_ = _cReposRoot_ + "/" + _cRepo_ + "/.central/runs"
		if NOT StzDirExists(_cRunsDir_)
			loop
		ok
		# only a file carrying the wake marker is this guard's subject --
		# CENTRAL's own mirror scar (roster/silence-board.pia header): a
		# detector that judges every *.log as a wake log reports a clean
		# session dead forever.
		_aLogs_ = _StzRosterListLogsDesc(_cRunsDir_)
		_ml_ = len(_aLogs_)
		for _j_ = 1 to _ml_
			_cText_ = StzFileRead(_cRunsDir_ + "/" + _aLogs_[_j_])
			if len(StzFind("=== harness wake", _cText_)) > 0
				poMemory.Learn(_cRepo_, "newest-wake-log", _aLogs_[_j_])
				if len(StzFind("=== finished", _cText_)) > 0
					poMemory.Learn(_cRepo_, "newest-wake-log-finished", "yes")
				else
					poMemory.Learn(_cRepo_, "newest-wake-log-finished", "no")
				ok
				exit
			ok
		next
	next

	poMemory.Learn("board", "holds", "heartbeat")

# CORPSES -- judges what SAMPLE sensed. Split from sampling on purpose:
# a stale verdict from a broken judge must never survive a fresh
# sample, and the two are two skills so neither can quietly stand in
# for the other.
func BoardFindDeadRuns(poMemory)
	poMemory.Forget("board", "ruled", "corpses")

	_cRoot_ = StzRosterEstateRoot()
	if _cRoot_ = ""
		return
	ok
	_cReposRoot_ = StzPathDirname(_cRoot_)
	_aDirs_ = _StzRosterListDirs(_cReposRoot_)
	_n_ = len(_aDirs_)
	for _i_ = 1 to _n_
		_cRepo_ = _aDirs_[_i_]
		_acLog_ = poMemory.Recall(_cRepo_, "newest-wake-log")
		if len(_acLog_) = 0
			loop
		ok
		_acFin_ = poMemory.Recall(_cRepo_, "newest-wake-log-finished")
		if len(_acFin_) > 0 and _acFin_[1] = "no"
			# subject is the repo, never a shared constant: two dead repos
			# whose newest log happens to share a filename must not collide
			# on the same (subject, object) pair the graph keys on.
			poMemory.Learn(_cRepo_, "ruled", "corpse")
		ok
	next

	poMemory.Learn("board", "ruled", "corpses")

# ANNOUNCE -- fires only when SAMPLE could not write its own heartbeat
# this cycle: no-fact where sample writes fact. FAIL-LOUD, because a
# stale page silent about its own staleness is the defect this whole
# row exists to find -- SESSION-LOG.md line 190, "nothing anywhere
# reported the gap".
func BoardAnnounceOwnDeath(poMemory)
	poMemory.Learn("board", "announced", "death")
	? "[silence-board] FAIL-LOUD: no heartbeat this cycle -- announcing " +
		"STALE rather than publishing yesterday's green."

#---------------------------------------------------------------------#
#  LEDGER-ROLL -- relocation of evidence, never retention              #
#---------------------------------------------------------------------#
# TODAY: dashboard/central.ps1, the LEDGER-ROLL block behind -Roll.
# Nothing is ever deleted: a month is moved to an archive path and the
# live file keeps reading fast. FAIL-CLOSED per file: a move this code
# cannot VERIFY leaves the source untouched rather than half-moved.

# RELOCATE -- always attempts, and resets its own facts every cycle for
# the same reason SAMPLE does: a stale "something moved" fact must
# never let PONITER or SAYZERO answer for a cycle that did nothing.
func RollRelocateMonths(poMemory)
	poMemory.Forget("archive", "holds", "month")
	poMemory.Forget("archive", "holds", "journalmonth")
	poMemory.Forget("archive", "holds", "sessionlogmonth")
	poMemory.Forget("roll", "moved", "nothing")

	_cRoot_ = StzRosterEstateRoot()
	if _cRoot_ = ""
		return
	ok
	_cCurMonth_ = _StzRosterCurrentMonth()

	# counts are deliberately NOT written as facts: stzKnowledgeGraph
	# stores one edge per (subject, object) pair regardless of the label
	# on it, so two differently-named counts that happen to land on the
	# same number (both "1", say) would collide on the same pair. What
	# the declared skills need is the yes/no this cycle moved something,
	# never how many.
	_nMovedJ_ = _StzRosterRelocateJournal(poMemory, _cRoot_, _cCurMonth_)
	if _nMovedJ_ > 0
		poMemory.Learn("archive", "holds", "journalmonth")
	ok

	_nArcMonths_ = _StzRosterRelocateSessionLog(poMemory, _cRoot_, _cCurMonth_)
	if _nArcMonths_ > 0
		poMemory.Learn("archive", "holds", "sessionlogmonth")
	ok

	if _nMovedJ_ > 0 or _nArcMonths_ > 0
		poMemory.Learn("archive", "holds", "month")
	ok

# journal/*.md months before the current one -> journal/archive/. Each
# file is written to its destination and RE-READ before the source is
# deleted -- the verify that makes this fail-closed rather than
# fail-and-hope.
func _StzRosterRelocateJournal(poMemory, pcRoot, pcCurMonth)
	_cJDir_ = pcRoot + "/journal"
	if NOT StzDirExists(_cJDir_)
		return 0
	ok
	_cJArc_ = _cJDir_ + "/archive"
	_nMoved_ = 0
	_aFiles_ = StzEngineDirListFiles(_cJDir_)
	_n_ = len(_aFiles_)
	for _i_ = 1 to _n_
		_cName_ = _aFiles_[_i_]
		if StzLower(StzRight(_cName_, 3)) != ".md"
			loop
		ok
		_cMonth_ = StzLeft(_cName_, 7)
		if NOT _StzRosterLooksLikeMonth(_cMonth_)
			loop
		ok
		if _StzRosterMonthKey(_cMonth_) >= _StzRosterMonthKey(pcCurMonth)
			loop
		ok
		_cSrc_ = _cJDir_ + "/" + _cName_
		# the disk listing above cannot see a rehearsed delete: a source
		# already moved IN THE TWIN this cycle would otherwise be re-read
		# as "" and re-archived empty. Absence-through-the-twin skips it.
		if _StzRosterFileExists(_cSrc_) = 0
			loop
		ok
		_StzRosterDirCreate(_cJArc_)
		_cDst_ = _cJArc_ + "/" + _cName_
		_cBody_ = _StzRosterFileRead(_cSrc_)
		_StzRosterFileWrite(_cDst_, _cBody_)
		if _StzRosterFileExists(_cDst_) and _StzRosterFileRead(_cDst_) = _cBody_
			_StzRosterFileDelete(_cSrc_)
			_nMoved_++
		ok
	next
	return _nMoved_

# dashboard/SESSION-LOG.md lines whose date is before the current month
# -> dashboard/archive/SESSION-LOG-<month>.md, grouped by month. Every
# archive append is RE-READ and checked to contain what was just
# written before SESSION-LOG.md itself is rewritten -- a verify that
# fails leaves SESSION-LOG.md completely untouched, because a session
# holds that file open and a half-rolled ledger is worse than an
# unrolled one.
func _StzRosterRelocateSessionLog(poMemory, pcRoot, pcCurMonth)
	_cSlF_ = pcRoot + "/dashboard/SESSION-LOG.md"
	if _StzRosterFileExists(_cSlF_) = 0
		return 0
	ok
	_aLines_ = StzSplit(_StzRosterFileRead(_cSlF_), char(10))
	_aKeep_ = []
	_aByMonth_ = []
	_n_ = len(_aLines_)
	for _i_ = 1 to _n_
		_cClean_ = _aLines_[_i_]
		if StzRight(_cClean_, 1) = char(13)
			_cClean_ = StzLeft(_cClean_, StzLen(_cClean_) - 1)
		ok
		_cLMonth_ = _StzRosterDateLineMonth(_cClean_)
		if _cLMonth_ != "" and _StzRosterMonthKey(_cLMonth_) < _StzRosterMonthKey(pcCurMonth)
			_nAt_ = 0
			_mb_ = len(_aByMonth_)
			for _j_ = 1 to _mb_
				if _aByMonth_[_j_][1] = _cLMonth_
					_nAt_ = _j_
					exit
				ok
			next
			if _nAt_ = 0
				_aByMonth_ + [ _cLMonth_, [ _cClean_ ] ]
			else
				_aByMonth_[_nAt_][2] + _cClean_
			ok
		else
			_aKeep_ + _cClean_
		ok
	next

	_m_ = len(_aByMonth_)
	if _m_ = 0
		return 0
	ok

	_cSlArc_ = pcRoot + "/dashboard/archive"
	_StzRosterDirCreate(_cSlArc_)
	_nOk_ = 0
	for _i_ = 1 to _m_
		_cMth_ = _aByMonth_[_i_][1]
		_cBody_ = StzJoinWith(_aByMonth_[_i_][2], char(10)) + char(10)
		_cArcF_ = _cSlArc_ + "/SESSION-LOG-" + _cMth_ + ".md"
		_StzRosterFileAppend(_cArcF_, _cBody_)
		if len(StzFind(_cBody_, _StzRosterFileRead(_cArcF_))) > 0
			_nOk_++
		ok
	next
	if _nOk_ != _m_
		# fail-closed: at least one archive write could not be verified,
		# so SESSION-LOG.md is left exactly as it was found
		return 0
	ok

	_StzRosterFileWrite(_cSlF_, StzJoinWith(_aKeep_, char(10)))
	return _m_

# POINTER -- fires only when RELOCATE archived at least one SESSION-LOG
# month this cycle. The pointer is half the mechanism, not a courtesy:
# SESSION-LOG.md is a file other sessions hold open, so the roll is
# announced by this line the moment they next read it.
func RollWritePointer(poMemory)
	poMemory.Forget("ledger", "holds", "pointer")
	if poMemory.Fact("archive", "holds", "sessionlogmonth") = 0
		return
	ok
	_cRoot_ = StzRosterEstateRoot()
	if _cRoot_ = ""
		return
	ok
	_cSlF_ = _cRoot_ + "/dashboard/SESSION-LOG.md"
	if _StzRosterFileExists(_cSlF_) = 0
		return
	ok

	_cPtr_ = "> Rolled " + StzToday() + ": entries before " +
		_StzRosterCurrentMonth() +
		" moved to dashboard/archive/SESSION-LOG-<month>.md. Nothing " +
		"deleted -- relocation of evidence, not retention."

	_aLines_ = StzSplit(_StzRosterFileRead(_cSlF_), char(10))
	_aOut_ = []
	_bIn_ = 0
	_n_ = len(_aLines_)
	for _i_ = 1 to _n_
		_aOut_ + _aLines_[_i_]
		if _bIn_ = 0 and StzLeft(ring_trim(_aLines_[_i_]), 2) = "# "
			_aOut_ + _cPtr_
			_bIn_ = 1
		ok
	next
	if _bIn_ = 0
		_aOut2_ = [ _cPtr_ ]
		for _i_ = 1 to _n_
			_aOut2_ + _aLines_[_i_]
		next
		_aOut_ = _aOut2_
	ok

	_StzRosterFileWrite(_cSlF_, StzJoinWith(_aOut_, char(10)))
	poMemory.Learn("ledger", "holds", "pointer")

# SAYZERO -- fires only when RELOCATE found nothing to move. The
# explicit fact is the point: a pass that prints nothing when it moves
# nothing is indistinguishable from a pass that is not running
# (SESSION-LOG.md line 218), so the zero outcome is a RECORD here, not
# an absence.
func RollReportNothingMoved(poMemory)
	poMemory.Learn("roll", "moved", "nothing")

#---------------------------------------------------------------------#
#  THE SAFE-WORLD DOOR (ruling 3.2) -- private to this file            #
#---------------------------------------------------------------------#
# Every write-path function above reaches files through these helpers,
# so the SAME code serves two worlds. Inside a workbench-holding
# agent's tick (StzInWorkbench), a write REHEARSES into the agent's
# stzVirtualFileSystem and reality waits for a committed stzUpdatePlan;
# outside one -- the migration state the live estate still runs -- it
# is the direct write it always was. Reads go THROUGH the twin so a
# function sees its own rehearsed writes, and a rehearsed delete reads
# as absence rather than as the disk's still-standing copy.
#
# This file is the binding's FIRST CONSUMER on purpose: its relocate
# hand-rolled write-then-verify-then-delete against the estate's real
# ledger, which ruling 3.2 named "the right instinct in the wrong
# place". Under a workbench the same verify runs against the twin, and
# the one check that actually needs reality -- did the commit land --
# belongs to the plan's Execute(), once, audited, for every agent.

func _StzRosterFileRead(pcPath)
	if StzInWorkbench()
		return StzActiveWorkbenchQ().ReadThrough(pcPath)
	ok
	return StzFileRead(pcPath)

func _StzRosterFileWrite(pcPath, pcBody)
	if StzInWorkbench()
		StzActiveWorkbenchQ().WriteFile(pcPath, pcBody)
	else
		StzFileWrite(pcPath, pcBody)
	ok

func _StzRosterFileExists(pcPath)
	if StzInWorkbench()
		return StzActiveWorkbenchQ().ExistsThrough(pcPath)
	ok
	return StzFileExists(pcPath)

func _StzRosterFileDelete(pcPath)
	if StzInWorkbench()
		StzActiveWorkbenchQ().DeleteFile(pcPath)
	else
		StzFileDelete(pcPath)
	ok

func _StzRosterFileAppend(pcPath, pcBody)
	if StzInWorkbench()
		_oWb_ = StzActiveWorkbenchQ()
		_cCur_ = ""
		if _oWb_.ExistsThrough(pcPath) = 1
			_cCur_ = _oWb_.ReadThrough(pcPath)
		ok
		_oWb_.WriteFile(pcPath, _cCur_ + pcBody)
	else
		StzFileAppend(pcPath, pcBody)
	ok

# idempotent: neither world records a second creation of a folder that
# is already there
func _StzRosterDirCreate(pcPath)
	if StzInWorkbench()
		_oWb_ = StzActiveWorkbenchQ()
		if _oWb_.Exists(pcPath) = 0 and NOT StzDirExists(pcPath)
			_oWb_.CreateFolder(pcPath)
		ok
	else
		if NOT StzDirExists(pcPath)
			StzDirCreatePath(pcPath)
		ok
	ok

#---------------------------------------------------------------------#
#  SHARED HELPERS -- private to this file                              #
#---------------------------------------------------------------------#

func _StzRosterListDirs(pcPath)
	_aOut_ = []
	if NOT StzDirExists(pcPath)
		return _aOut_
	ok
	_aRaw_ = StzEngineDirListDirs(pcPath)
	_n_ = len(_aRaw_)
	for _i_ = 1 to _n_
		_cN_ = _aRaw_[_i_]
		if _cN_ = "." or _cN_ = ".."
			loop
		ok
		_aOut_ + _cN_
	next
	return _aOut_

func _StzRosterListLogsDesc(pcDir)
	_aAll_ = StzEngineDirListFiles(pcDir)
	_aLogs_ = []
	_n_ = len(_aAll_)
	for _i_ = 1 to _n_
		_cN_ = _aAll_[_i_]
		if StzLower(StzRight(_cN_, 4)) = ".log"
			_aLogs_ + _cN_
		ok
	next
	_aLogs_ = sort(_aLogs_)
	_aDesc_ = []
	_m_ = len(_aLogs_)
	for _i_ = _m_ to 1 step -1
		_aDesc_ + _aLogs_[_i_]
	next
	return _aDesc_

func _StzRosterLastLine(pcContent)
	_aLines_ = StzSplit(pcContent, char(10))
	_n_ = len(_aLines_)
	for _i_ = _n_ to 1 step -1
		_cL_ = ring_trim(_aLines_[_i_])
		if _cL_ != ""
			return _cL_
		ok
	next
	return ""

func _StzRosterCurrentMonth()
	_oT_ = StzTodayQ()
	return "" + _oT_.Year() + "-" + _oT_.MonthNumberInString()

# "yyyy-MM" -> year*100+month, comparable as a plain number. Ring's >=/<=
# coerce a string operand to a number (R41 on anything that is not purely
# digits), so "2000-01" >= "2026-08" cannot be compared directly -- this is
# the numeric key both month comparisons in this file go through instead.
func _StzRosterMonthKey(pcYYYYMM)
	return (0 + StzLeft(pcYYYYMM, 4)) * 100 + (0 + StzRight(pcYYYYMM, 2))

func _StzRosterIsDigit(pcCh)
	return (pcCh >= "0" and pcCh <= "9")

func _StzRosterLooksLikeMonth(pcCand)
	if StzLen(pcCand) != 7
		return 0
	ok
	if StzMid(pcCand, 5, 1) != "-"
		return 0
	ok
	for _i_ = 1 to 4
		if NOT _StzRosterIsDigit(pcCand[_i_])
			return 0
		ok
	next
	for _i_ = 6 to 7
		if NOT _StzRosterIsDigit(pcCand[_i_])
			return 0
		ok
	next
	return 1

# "yyyy-MM" when pcLine opens with a SESSION-LOG date stamp
# ("yyyy-MM-dd "), "" otherwise.
func _StzRosterDateLineMonth(pcLine)
	if StzLen(pcLine) < 11
		return ""
	ok
	if NOT _StzRosterLooksLikeMonth(StzLeft(pcLine, 7))
		return ""
	ok
	if StzMid(pcLine, 8, 1) != "-"
		return ""
	ok
	if NOT _StzRosterIsDigit(pcLine[9]) or NOT _StzRosterIsDigit(pcLine[10])
		return ""
	ok
	if StzMid(pcLine, 11, 1) != " "
		return ""
	ok
	return StzLeft(pcLine, 7)
