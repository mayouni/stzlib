load "stdlib.ring"

# RX3 -- the dead-link guard on the agent door: AGENTS.md and its skills.
#
# Every path the door names must exist, and every command in a bash fence must
# be one this guard knows how to check: `cd DIR` (the folder exists), `ring FILE`
# (the file exists in that folder), `zig build` (build.zig is in that folder).
# A path is any backtick token holding a slash or ending in .md .ring .py .zig
# .json, with no space, no placeholder in angle brackets, no glob and no URL.
#
# This guard loads NO library on purpose: it runs in a FRESH CHECKOUT, with no
# engine built, CRLF and all, because a gate that passes only in the tree it was
# written in is not passing. Ring's own stdlib gives direxists; everything else
# is a builtin. It prints the narrated banner itself and exits with the count
# of failures, so a runner can read it.
#
# LIMITS, printed too: a command is checked for its shape and its targets, not
# executed; the skills' paths are checked, the grind-err skill's commands are not
# (they are the loop's own lines, not the door's), and only its tokens holding a
# slash are read as paths; a token starting with ../ is relative to a test folder
# and is not judged.

cRoot = "../../../../../"
aDoor = [ "AGENTS.md",
          ".claude/skills/narrated-guard/SKILL.md",
          ".claude/skills/ring-traps/SKILL.md",
          ".claude/skills/fast-path/SKILL.md" ]
aPathsOnly = [ ".claude/skills/grind-err/SKILL.md" ]
nPass = 0
nFail = 0
nPaths = 0
nCmds = 0

? "SCENARIO: every path the door names exists, and every command it gives can run"
for i = 1 to len(aDoor)
	JudgeFile(aDoor[i], 1)
next
for i = 1 to len(aPathsOnly)
	JudgeFile(aPathsOnly[i], 0)
next
? "  (" + nPaths + " paths and " + nCmds + " commands read; a command is checked for shape and targets, not executed)"
? "SCENARIO: the door is short and routes"
cDoor = read(cRoot + "AGENTS.md")
nLines = len(str2list(cDoor))
Verdict("AGENTS.md is about 150 lines (" + nLines + ")", nLines <= 170)
Verdict("it names CLAUDE.md as the law", substr(cDoor, "CLAUDE.md") > 0)
Verdict("it lists stz check as planned, never built", substr(cDoor, "**planned** and not built") > 0)
Verdict("it names Testoor's three exit codes", substr(cDoor, "**0**") > 0 and substr(cDoor, "**1**") > 0 and substr(cDoor, "**2**") > 0)
Verdict("it names its own guard", substr(cDoor, "agents_door_narrated.ring") > 0)
? "SCENARIO: the negative sibling: a dead link is read as a path and found absent"
Verdict("the token rule reads no/such/file.md as a path", IsPathToken("no/such/file.md") = 1)
Verdict("and it is absent from the checkout", NOT (fexists(cRoot + "no/such/file.md") or direxists(cRoot + "no/such/file.md")))
Verdict("a placeholder <topic> is not read as a path", IsPathToken("ring x.ring --topic <topic>") = 0)
? ""
? "================================================"
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "================================================"
if nFail > 0
	? "STATUS: FAILED"
else
	? "STATUS: OK"
ok
shutdown(nFail)

func Verdict(cText, bOk)
	if bOk
		? "  THEN  " + cText + "  [PASS]"
		nPass++
	else
		? "  THEN  " + cText + "  [FAIL]"
		nFail++
	ok

func JudgeFile(cFile, bCommands)
	? "  GIVEN " + cFile
	if NOT fexists(cRoot + cFile)
		Verdict("the file exists", 0)
		return
	ok
	Verdict("the file exists", 1)
	cText = read(cRoot + cFile)
	aLines = str2list(cText)
	bFence = 0
	bBash = 0
	for i = 1 to len(aLines)
		cL = aLines[i]
		cT = trim(cL)
		if left(cT, 3) = "```"
			if bFence = 0
				bFence = 1
				bBash = (trim(substr(cT, 4)) = "bash")
			else
				bFence = 0
				bBash = 0
			ok
			loop
		ok
		if bFence = 1
			if bBash = 1 and bCommands = 1 and cT != ""
				JudgeCommand(cFile, cT)
			ok
			loop
		ok
		JudgeTokens(cFile, cL, bCommands)
	next

func JudgeTokens(cFile, cLine, bCommands)
	n = len(cLine)
	i = 1
	while i <= n
		if cLine[i] = "`"
			j = i + 1
			while j <= n and cLine[j] != "`"
				j++
			end
			if j > n
				exit
			ok
			cTok = substr(cLine, i + 1, j - i - 1)
			if IsPathToken(cTok) and (bCommands = 1 or substr(cTok, "/") > 0)
				nPaths++
				cP = cTok
				if right(cP, 1) = "/"
					cP = left(cP, len(cP) - 1)
				ok
				bOk = fexists(cRoot + cP) or direxists(cRoot + cP)
				Verdict(cFile + " names " + cTok, bOk)
			ok
			i = j + 1
		else
			i++
		ok
	end

func IsPathToken(cTok)
	if cTok = "" or substr(cTok, " ") > 0 or substr(cTok, "<") > 0 or
	   substr(cTok, "*") > 0 or substr(cTok, "://") > 0 or left(cTok, 1) = "-" or
	   left(cTok, 1) = ":" or left(cTok, 3) = "../"
		return 0
	ok
	if substr(cTok, "/") > 0
		return 1
	ok
	for cExt in [ ".md", ".ring", ".py", ".zig", ".json" ]
		if right(cTok, len(cExt)) = cExt
			return 1
		ok
	next
	return 0

func JudgeCommand(cFile, cCmd)
	nCmds++
	cDir = ""
	aParts = split(cCmd, "&&")
	for k = 1 to len(aParts)
		cP = trim(aParts[k])
		if left(cP, 3) = "cd "
			cDir = trim(substr(cP, 4))
			Verdict(cFile + " command: folder " + cDir + " exists", direxists(cRoot + cDir))
		but left(cP, 5) = "ring "
			aW = split(trim(substr(cP, 6)), " ")
			cR = aW[1]
			cFull = cRoot + cDir + "/" + cR
			if cDir = ""
				cFull = cRoot + cR
			ok
			Verdict(cFile + " command: ring " + cR + " exists in " + cDir, fexists(cFull))
		but left(cP, 9) = "zig build"
			Verdict(cFile + " command: build.zig is in " + cDir, fexists(cRoot + cDir + "/build.zig"))
		else
			Verdict(cFile + " command of a known shape: " + cP, 0)
		ok
	next
