# THE PROGRAM AS A WHOLE -- the courses it declares, and a text read the
# same from a CRLF checkout as from an LF tree.
#
#   1. MATH-COURSEFOLDER-01: the program counts its courses. Every course
#      program.zknw declares is a folder with a course.zknw, and every
#      course folder is declared: a plane that adds a course (math did)
#      is seen by this gate, never silently outside it. No number is
#      hard-coded -- the gate prints the courses it found
#   2. MATH-FINDING-EDU-INST-01: every text a reader of the module
#      returns is the same from a file written with CRLF (what a fresh
#      Windows checkout holds under autocrlf) as from one written with
#      LF. The gates passed for weeks on the author's LF tree and failed
#      on a fresh checkout of main; the readers strip the CR now, and
#      this proves it on a scratch copy of each
#
# Run from this folder: ring program_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"

t0 = clock()
cProg = "../../education/program"
oP = StzProgramQ(cProg)
EduProgClean()

#---------------------------------------------------------------------------
Scenario("1. The program counts its courses")
acDeclared = oP.Courses()
acOnDisk = StzEngineDirListDirs(cProg + "/courses")
? "    declared: " + @@(acDeclared)
? "    on disk:  " + @@(acOnDisk)
Then("at least the three courses of the first slices are declared", StzFindFirst("elementary-introduction", acDeclared) > 0 and
	StzFindFirst("zindara-missions", acDeclared) > 0 and StzFindFirst("governed-agents", acDeclared) > 0, 1)
acNoFolder = []
for i = 1 to len(acDeclared)
	if StzFindFirst(acDeclared[i], acOnDisk) = 0
		acNoFolder + acDeclared[i]
	ok
next
Then("every declared course is a folder", @@(acNoFolder), "[ ]")
acUndeclared = []
for i = 1 to len(acOnDisk)
	if StzFindFirst(acOnDisk[i], acDeclared) = 0
		acUndeclared + acOnDisk[i]
	ok
next
Then("every course folder is declared (no course the program does not know)", @@(acUndeclared), "[ ]")
acNoManifest = []
for i = 1 to len(acDeclared)
	if NOT fexists(cProg + "/courses/" + acDeclared[i] + "/course.zknw")
		acNoManifest + acDeclared[i]
	ok
next
Then("every course has its course.zknw", @@(acNoManifest), "[ ]")
acCannotOpen = []
for i = 1 to len(acDeclared)
	try
		oP.CourseQ(acDeclared[i])
	catch
		acCannotOpen + acDeclared[i]
	done
next
Then("every course opens through the program", @@(acCannotOpen), "[ ]")
Then("a course the program does not declare cannot be opened (negative sibling)", EduProgRefuses(oP, "no-such-course"), 1)
EndScenario()

#---------------------------------------------------------------------------
t2 = clock()
Scenario("2. A text is the same from a CRLF checkout as from an LF tree")
oEx = oP.CourseQ("elementary-introduction").ExerciseQ("ex-01-01")
# the copies keep the exercise id as their folder name: its facts are keyed by it
StzEduCopyTree(oEx.Folder(), "t_edu_prog/lf/ex-01-01")
EduProgCrlfCopy("t_edu_prog/lf/ex-01-01", "t_edu_prog/crlf/ex-01-01")
Then("the scratch copy really holds CRLF (not CR CR LF, not LF)",
	StzFindFirst(char(13) + char(10), read("t_edu_prog/crlf/ex-01-01/task.en.md")) > 0 and
	StzFindFirst(char(13) + char(13), read("t_edu_prog/crlf/ex-01-01/task.en.md")) = 0, 1)
oLf = StzExerciseQ("t_edu_prog/lf/ex-01-01")
oCr = StzExerciseQ("t_edu_prog/crlf/ex-01-01")
acLangs = oP.Languages()
acDrift = []
for i = 1 to len(acLangs)
	if oCr.Task(acLangs[i]) != oLf.Task(acLangs[i])
		acDrift + acLangs[i]
	ok
next
Then("the task, in all four languages, is the same text", @@(acDrift), "[ ]")
Then("...and holds no CR", StzFindFirst(char(13), oCr.Task("fr")), 0)
Then("the first line of the task is the title, with no trailing CR", StzRight(StzSplit(oCr.Task("fr"), char(10))[1], 1) != char(13), 1)
Then("the promises are the same", @@(oCr.Promises()), @@(oLf.Promises()))
Then("the facts of exercise.zknw are read from the CRLF file (not an empty, vacuous match)", @@(oCr.NeededSteps()), @@([ "finds", "applies" ]))
Then("...and are the same as from the LF one", @@(oCr.NeededSteps()), @@(oLf.NeededSteps()))
Then("a right answer written with CRLF still passes the checker (it ran)",
	oCr.Check(read(oCr.RightAnswers()[1])).Passed(), 1)

When("an exercise's gaps.<lang>.md is written with CRLF")
EduProgWriteGaps("t_edu_prog/crlf/ex-01-01")
Then("its question is read without the CR", oCr.GapText("reduces", "en"), "A question?")
Then("...and a line the file lacks is still red, not a CR-shaped answer", EduProgGapRed(oCr, "compares", "en"), 1)

When("a project brief is written with CRLF")
StzEngineDirCreatePath("t_edu_prog/project-x")
write("t_edu_prog/project-x/brief.en.md", "# A project" + char(13) + char(10) + char(13) + char(10) + "Do the thing." + char(13) + char(10))
Then("its brief is read without the CR", StzFindFirst(char(13), StzProjectQ("t_edu_prog/project-x").Brief("en")), 0)

When("a chapter is written with CRLF (the parser always stripped it; kept as the regression it is)")
cCh = oP.CourseQ("elementary-introduction").ChapterFile("find-then-apply", "en")
write("t_edu_prog/ch-crlf.md", StzReplace(StzReplace(read(cCh), char(13), ""), char(10), char(13) + char(10)))
oChLf = new stzChapter(cCh, "en")
oChCr = new stzChapter("t_edu_prog/ch-crlf.md", "en")
Then("the title is the same", oChCr.Title(), oChLf.Title())
Then("the cells are the same, count and content", oChCr.NumberOfCells() = oChLf.NumberOfCells() and @@(oChCr.Cell(1)) = @@(oChLf.Cell(1)), 1)
Then("the promises of every cell are the same", @@(oChCr.CellPromises(2)), @@(oChLf.CellPromises(2)))
Then("the recap's first bullet is the same", oChCr.RecapAchieved(), oChLf.RecapAchieved())
EndScenario()
? "  [time] scenario 2: " + ((clock() - t2) / clockspersecond()) + " s"

EduProgClean()
? ""
? "  [time] whole guard: " + ((clock() - t0) / clockspersecond()) + " s"
Summary()

#===========================================================================
func EduProgClean()
	StzEduRemoveTree("t_edu_prog")

# Opens a course the program does not declare; returns 1 when it is refused.
func EduProgRefuses(poP, pcSlug)
	_bRed_ = 0
	try
		poP.CourseQ(pcSlug)
	catch
		_bRed_ = 1
	done
	return _bRed_

func EduProgGapRed(poEx, pcStep, pcLang)
	_bRed_ = 0
	try
		poEx.GapText(pcStep, pcLang)
	catch
		_bRed_ = 1
	done
	return _bRed_

func EduProgWriteGaps(pcFolder)
	write(pcFolder + "/gaps.en.md", "reduces: A question?" + char(13) + char(10))

# Every text file of a folder, rewritten with CRLF line ends, into another.
func EduProgCrlfCopy(pcFrom, pcTo)
	StzEngineDirCreatePath(pcTo)
	_acF_ = StzEngineDirListFiles(pcFrom)
	for _i_ = 1 to len(_acF_)
		write(pcTo + "/" + _acF_[_i_], StzReplace(StzReplace(read(pcFrom + "/" + _acF_[_i_]), char(13), ""), char(10), char(13) + char(10)))
	next
	_acD_ = StzEngineDirListDirs(pcFrom)
	for _i_ = 1 to len(_acD_)
		EduProgCrlfCopy(pcFrom + "/" + _acD_[_i_], pcTo + "/" + _acD_[_i_])
	next
