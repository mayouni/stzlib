# _measure_termination.ring -- what the termination aids buy, and what they cost, on the K4 twenty tasks.
#
#     ring _measure_termination.ring <model-needle> <arm> [maxtasks] [maxtokens]
#
#   arm: base | rp11 | rp13 | rp15 | stop4 | endbias | rp11stop6 | rp13stop6 ...   (the table at the foot of this file)
#
# Greedy (temperature 0, seed 0), the Ring++ grammar ON, one worked example in the prompt: the shape the Ring++ session's
# local K4 used for Qwen2.5-Coder-1.5B (ENGINE_NOTES.md: 12 of 20 programs wrote their end marker with the grammar, 5 of 20 passed).
# The twenty tasks, their prompts and the grammar are DATA in _k4/ (README.txt there); nothing here depends on ringpp's tooling,
# only on the Ring++ runtime BINARY to judge a program (set RNXC, or the default path below; absent -> pass is reported as -1).
#
# Per task, one line  R|arm|task|seconds|tokens|ended|stopped|complete|shown|pass  appended to _k4/results/<model>_<arm>.txt,
# and a task that already has its line is SKIPPED, so a run a power cut stopped goes on where it was.
#   ended    the program wrote its end marker line  <<END>>
#   stopped  :StopOnRepeat ended the answer
#   complete the grammar was satisfied where generation stopped
#   shown    the program prints the right answer on the shown data
#   pass     it prints the right answer on the shown data AND on hidden data (so printing the shown answer fails)
# The CPU's speed is part of the record: run  python bench/heartbeat.py  (exit 1 = throttled) and note it beside the numbers.

load "../../stzBase.ring"
load "_modelpick.ring"

cNeedle   = sysargv[3]
cArm      = sysargv[4]
nMaxTasks = 20
nMaxTok   = 320
if len(sysargv) >= 5 nMaxTasks = 0 + sysargv[5] ok
if len(sysargv) >= 6 nMaxTok = 0 + sysargv[6] ok

cRnxc = "D:\GitHub\ringpp\runtime\package\ringpp-win64\bin\rnxc.exe"
cEnv = sysget("RNXC")
if cEnv != "" cRnxc = cEnv ok

cDir = "_k4/"
cResDir = cDir + "results/"
if NOT direxists(cResDir) system("mkdir _k4\results") ok
cWork = sysget("TEMP") + "\_k4_measure"
if NOT direxists(cWork) system("mkdir " + char(34) + cWork + char(34)) ok

# ---- the arms --------------------------------------------------------------------------------
aArms = [
	[ "base",      [] ],
	[ "rp11",      [ [ :RepeatPenalty, 1.1 ] ] ],
	[ "rp13",      [ [ :RepeatPenalty, 1.3 ] ] ],
	[ "rp15",      [ [ :RepeatPenalty, 1.5 ] ] ],
	[ "stop4",     [ [ :StopOnRepeat, 4 ] ] ],
	[ "endbias",   [ [ :EndBias, 4 ] ] ],
	[ "rp11stop6", [ [ :RepeatPenalty, 1.1 ], [ :StopOnRepeat, 6 ] ] ],
	[ "rp13stop6", [ [ :RepeatPenalty, 1.3 ], [ :StopOnRepeat, 6 ] ] ]
]
aOpts = []
bKnown = 0
for i = 1 to len(aArms)
	if aArms[i][1] = cArm aOpts = aArms[i][2] bKnown = 1 ok
next
if bKnown = 0 ? "unknown arm " + cArm bye ok

# ---- the tasks ---------------------------------------------------------------------------------
# tasks.txt: "@@T01" opens a block; "@a" "@b" "@ea" "@eb" open its four sections. (Ring's split() cuts on every character of a
# multi-character delimiter, so the file is read line by line.)
aLines = split(read(cDir + "tasks.txt"), char(10))
aTask = []
cBlock = ""
cBlockId = ""
for i = 1 to len(aLines)
	cL = _mTrimEnd(aLines[i])
	if left(cL, 2) = "@@"
		if cBlockId != ""
			aP = _mSections(cBlock)
			add(aTask, [ cBlockId, aP[1], aP[2], aP[3], aP[4] ])      # id, shown data, hidden data, expected shown, expected hidden
		ok
		cBlockId = right(cL, len(cL) - 2)
		cBlock = cL + char(10)
	else
		cBlock += cL + char(10)
	ok
next
if cBlockId != ""
	aP = _mSections(cBlock)
	add(aTask, [ cBlockId, aP[1], aP[2], aP[3], aP[4] ])
ok

if _mpLoad(cNeedle) = 0 ? "NOLOAD " + cNeedle bye ok
cModelTag = lower(cNeedle)
cGrammar = read(cDir + "ringpp.gbnf")
cOutFile = cResDir + cModelTag + "_" + cArm + "_" + nMaxTok + ".txt"
cDone = ""
if fexists(cOutFile) cDone = read(cOutFile) ok

? "MODEL " + cNeedle + "  ARM " + cArm + "  grammar enforced at the sampler: " + StzConstrainedDecodingSupported()
nEnded = 0 nPass = 0 nShown = 0 nStopped = 0 nRun = 0 nSec = 0 nTok = 0
nTasks = min([nMaxTasks, len(aTask)])
for i = 1 to nTasks
	cId = aTask[i][1]
	if StzFindFirst("R|" + cArm + "|" + cId + "|", cDone) > 0
		cLine = _mLineFor(cDone, "R|" + cArm + "|" + cId + "|")
		? cLine
		_mTally(cLine)
		loop
	ok
	cPrompt = read(cDir + "p_" + cId + ".txt")
	aOpt = [ [ :MaxTokens, nMaxTok ], [ :Temperature, 0 ], [ :Seed, 0 ], [ :Grammar, cGrammar ] ]
	for j = 1 to len(aOpts) add(aOpt, aOpts[j]) next
	t0 = clock()
	cOut = StzGenerateXT(cPrompt, aOpt)
	nS = (clock() - t0) / clockspersecond()
	aRun = StzLastGrammarRun()
	bEnded = (StzFindFirst("<<END>>", cOut) > 0)
	cBody = _mBody(cOut)
	cProg = aTask[i][2] + char(10) + cBody
	nShownOk = -1
	nPassOk = -1
	if fexists(cRnxc)
		cA = _mNorm(_mRun(cProg, cId + "a"))
		nShownOk = (cA = aTask[i][4])
		cProgB = aTask[i][3] + char(10) + cBody
		cB2 = _mNorm(_mRun(cProgB, cId + "b"))
		nPassOk = (nShownOk = 1 and cB2 = aTask[i][5])
	ok
	cLine = "R|" + cArm + "|" + cId + "|" + nS + "|" + aRun[:steps] + "|" + bEnded + "|" + StzLastGenerationStoppedOnRepeat() + "|" + aRun[:complete] + "|" + nShownOk + "|" + nPassOk
	write(cOutFile, cDone + cLine + char(10))
	cDone = cDone + cLine + char(10)
	? cLine
	_mTally(cLine)
next
? "SUMMARY " + cModelTag + " " + cArm + "  tasks=" + nRun + "  ended=" + nEnded + "  stopped=" + nStopped + "  shown=" + nShown + "  pass=" + nPass + "  seconds=" + nSec + "  tokens=" + nTok

# ---- helpers ------------------------------------------------------------------------------------
# (functions come last: in Ring, whatever follows a func belongs to it)

func _mTally(cLine)
	_aF_ = split(cLine, "|")
	nRun++
	nSec += 0 + _aF_[4]
	nTok += 0 + _aF_[5]
	if _aF_[6] = "1" nEnded++ ok
	if _aF_[7] = "1" nStopped++ ok
	if _aF_[9] = "1" nShown++ ok
	if _aF_[10] = "1" nPass++ ok

func _mLineFor(cText, cKey)
	_aL_ = split(cText, char(10))
	for _k_ = 1 to len(_aL_)
		if left(_aL_[_k_], len(cKey)) = cKey return _aL_[_k_] ok
	next
	return ""

# the four sections of one task block: shown data, hidden data, expected shown, expected hidden
# (NOTE: a Ring function that assigns a name the main script also uses WRITES THE MAIN SCRIPT'S VARIABLE -- hence _x_ locals.)
func _mSections(cBlock)
	_aOut_ = [ "", "", "", "" ]
	_aL_ = split(cBlock, char(10))
	_nCur_ = 0
	for _k_ = 2 to len(_aL_)
		_cL_ = _aL_[_k_]
		if _cL_ = "@a"       _nCur_ = 1 loop ok
		if _cL_ = "@b"       _nCur_ = 2 loop ok
		if _cL_ = "@ea"      _nCur_ = 3 loop ok
		if _cL_ = "@eb"      _nCur_ = 4 loop ok
		if _nCur_ > 0
			if _aOut_[_nCur_] != "" _aOut_[_nCur_] += char(10) ok
			_aOut_[_nCur_] += _cL_
		ok
	next
	for _k_ = 1 to 4 _aOut_[_k_] = _mTrimEnd(_aOut_[_k_]) next
	return _aOut_

func _mTrimEnd(cIn)
	_c_ = cIn
	while len(_c_) > 0 and (_c_[len(_c_)] = char(10) or _c_[len(_c_)] = char(13) or _c_[len(_c_)] = " ")
		_c_ = left(_c_, len(_c_) - 1)
	end
	return _c_

# the generated text up to its end marker, with code fences dropped
func _mBody(cIn)
	_c_ = cIn
	_nE_ = StzFindFirst("<<END>>", _c_)
	if _nE_ > 0 _c_ = left(_c_, _nE_ - 1) ok
	_aL_ = split(_c_, char(10))
	_cR_ = ""
	for _k_ = 1 to len(_aL_)
		if left(trim(_aL_[_k_]), 3) != "```"
			_cR_ += _aL_[_k_] + char(10)
		ok
	next
	return _cR_

func _mNorm(cIn)
	_aL_ = split(StzReplace(cIn, char(13) + char(10), char(10)), char(10))
	_cR_ = ""
	for _k_ = 1 to len(_aL_)
		_cR_ += _mTrimEnd(_aL_[_k_]) + char(10)
	next
	return _mTrimEnd(_cR_)

# run a Ring++ program on rnxc with a 10-second limit (a generated program may loop forever).
# The limit lives in a tiny PowerShell runner written once beside the programs (no "$" may travel through a command string).
func _mRun(cProgram, cTag)
	_cF_ = cWork + char(92) + "p_" + cTag + ".ring"
	_cO_ = cWork + char(92) + "o_" + cTag + ".txt"
	_cPs_ = cWork + char(92) + "runner.ps1"
	if NOT fexists(_cPs_)
		write(_cPs_, "param([string]$exe,[string]$prog,[string]$out)" + char(10) +
			"$p = Start-Process -FilePath $exe -ArgumentList $prog -PassThru -NoNewWindow -RedirectStandardOutput $out -RedirectStandardError ($out + '.err')" + char(10) +
			"if (-not $p.WaitForExit(10000)) { $p.Kill() }" + char(10))
	ok
	write(_cF_, cProgram)
	if fexists(_cO_) remove(_cO_) ok
	StzEngineSystemRunXT("powershell -NoProfile -ExecutionPolicy Bypass -File " + _cPs_ + " " + cRnxc + " " + _cF_ + " " + _cO_)
	if fexists(_cO_) return read(_cO_) ok
	return ""
