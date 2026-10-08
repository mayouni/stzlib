#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLEARNER                  #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : A LEARNER is a folder of their own work and #
#                  their progress, and the progress is written #
#                  ONLY by the checker, with its evidence.     #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
#   <learner>/work/<exercise>.ring    what they submitted, as they wrote it
#   <learner>/progress.zknw           facts, plain text, git-diffable
#
# Law 9 in one sentence: a `passed` fact counts only while the sha256 of
# the work file still equals the evidence the checker recorded when it
# RAN that file. A passed line typed by hand, or a work file changed
# after passing, reads as NOT passed -- the claim is refused, not trusted.

func StzLearnerQ(pcFolder)
	return new stzLearner(pcFolder)

# Holds one learner's folder: the work they submitted and their progress, which only the checker writes, with its evidence.
#
# A learner is a folder: work/<exercise>.ring is what they submitted, as they wrote it, and
# progress.zknw is a plain text file of facts. A pass is recorded only by Submit or SubmitProject,
# after the checker has run the program, and it counts only while the sha256 of the work file (or of
# the project folder) still equals the evidence recorded then: a pass typed by hand, or a file
# changed afterwards, reads as not passed. A level is earned when every exercise of its chapters and
# its project have passed. The checker runs programs on the desktop with Softanza, never in a
# browser, and each submission takes seconds. The fr, ar and ha editions of the course are drafts, 0
# of 35 units reviewed by a person, and no institution has adopted the system yet.
#
#   receiver   StzEduRemoveTree("t_edu_doc/ada"); o1 = new stzLearner("t_edu_doc/ada")
#   example    oC = StzProgramQ("../../education/program").CourseQ("elementary-introduction")
#              oEx = oC.ExerciseQ("ex-01-01")
#              ? o1.ChapterOn(oC)
#              #--> find-then-apply
#              ? o1.Submit(oEx, read(oEx.RightAnswers()[1])).Passed()
#              #--> 1
#              ? o1.HasPassed("ex-01-01")
#              #--> 1
#              ? o1.ChapterOn(oC)
#              #--> a-first-sentence
#   see        stzTutor, stzCohort, stzProject, stzExercise
class stzLearner from stzObject

	@cFolder = ""
	@cId = ""
	@aFacts = []

	# Opens a learner's folder, creating it with its work folder when absent, and reads the progress file if there is one.
	#
	#   pcFolder   the learner's folder: its last segment becomes the learner's id and a trailing
	#              slash is dropped
	#   returns    nothing; the object is built
	#   note       a learner is a folder holding work/ (what they submitted) and progress.zknw
	#              (facts, plain text, git-diffable)
	#   warning    the facts are read once, here: another stzLearner on the same folder is not seen
	#              until Reload, and Submit then writes the whole file from memory, so the object
	#              that did not Reload erases the other's passes (shown: a pass of ex-01-01 was
	#              lost)
	#   see        Id, Folder, Reload, Submit
	def init(pcFolder)
		@cFolder = _EduNoSlash(pcFolder)
		@cId = _EduLastSegment(@cFolder)
		StzEngineDirCreatePath(@cFolder + "/work")
		if fexists(This.ProgressFile())
			@aFacts = _EduFactsOf(This.ProgressFile())
		ok

	# Returns the learner's identifier, which is the last segment of the folder's path.
	#
	#   returns    a text such as ada
	#   see        Folder, ProgressFile
	def Id()
		return @cId

	# Returns the path of the learner's folder as it was given, without a trailing slash.
	#
	#   returns    a text
	#   see        Id, WorkFile, ProgressFile
	def Folder()
		return @cFolder

	# Returns the path of progress.zknw, the plain-text file of facts that only the checker writes.
	#
	#   returns    a text; the file may not exist yet
	#   see        Facts, Reload
	def ProgressFile()
		return @cFolder + "/progress.zknw"

	# Returns the path where the learner's submission for an exercise is kept, exactly as they wrote it.
	#
	#   pcExerciseId   the exercise's id, such as ex-01-01
	#   returns        a text; nothing is read, so the file may not exist
	#   see            Submit, HasTried
	def WorkFile(pcExerciseId)
		return @cFolder + "/work/" + pcExerciseId + ".ring"

	# Returns the progress facts held in memory, as [ subject, predicate, object ] triples of text.
	#
	#   returns    a list of three-item lists; [ ] for a learner with no progress
	#   note       the list is a copy: changing it changes nothing in the learner, and it shows only
	#              what init, Reload and this object's own submissions put there
	#   see        Reload, LastVerdict
	def Facts()
		return @aFacts

	# Runs the checker on a submitted program, records its verdict and evidence in the progress file, and returns the check.
	#
	#   poExercise   the stzExercise to judge the program against
	#   pcCode       the learner's program, as text
	#   returns      the stzExerciseCheck of that run; Passed() says whether every promise was kept
	#   note         the one writer of progress: a verdict is written only after a check that ran; a
	#                pass also records the sha256 of the program as evidence and the time of the
	#                check in milliseconds; a program that stopped with an error is recorded as
	#                error, one that ran but missed a promise as diverged
	#   warning      the checker runs the program in a fresh Ring process with Softanza loaded, on
	#                the desktop only, and each submission takes seconds; the newest verdict
	#                replaces the older one, so a wrong submission after a pass makes HasPassed
	#                FALSE although the old evidence stays in the file; two stzLearner objects on
	#                one folder overwrite each other (see init)
	#   see          SubmitFile, HasPassed, LastVerdict, ChapterOn
	#@ aka  -- the one writer of progress: a check that RAN
	def Submit(poExercise, pcCode)
		# THE FACT SHAPE. The knowledge graph keeps ONE edge per pair of nodes,
		# so `ali | tried | ex` and `ali | passed | ex` cannot both exist --
		# found by this plane's guard, 2026-09-23. Every fact about an attempt
		# therefore hangs off its own subject, and each carries a distinct
		# object (the prefixes keep two equal hashes from being one node):
		#     ali | worked-on | ex-01-01
		#     ex-01-01-by-ali | verdict | passed          (passed | diverged | error)
		#     ex-01-01-by-ali | last-attempt | attempt:<sha256>
		#     ex-01-01-by-ali | evidence | sha256:<sha256>        (only when passed)
		#     ex-01-01-by-ali | checked-at-ms | <epoch ms, UTC>   (only when passed)
		_cEx_ = poExercise.Id()
		write(This.WorkFile(_cEx_), pcCode)
		_oCheck_ = poExercise.Check(pcCode)
		_cKey_ = This._Key(_cEx_)
		This._Add(@cId, "worked-on", _cEx_)
		This._Set(_cKey_, "last-attempt", "attempt:" + _oCheck_.Hash())
		if _oCheck_.Passed()
			This._Set(_cKey_, "verdict", "passed")
			This._Set(_cKey_, "evidence", "sha256:" + _oCheck_.Hash())
			This._Set(_cKey_, "checked-at-ms", "" + _oCheck_.CheckedAtMs())
		but _oCheck_.Error() != ""
			This._Set(_cKey_, "verdict", "error")
		else
			This._Set(_cKey_, "verdict", "diverged")
		ok
		This._Save()
		return _oCheck_

		# Reads a program from a file and submits its text exactly as a typed submission, then returns the check.
		#
		#   poExercise   the stzExercise to judge the program against
		#   pcFile       the path of the file holding the learner's program
		#   returns      the stzExerciseCheck of that run
		#   note         the text is copied to the learner's work folder under the exercise's id
		#   see          Submit, WorkFile
		def SubmitFile(poExercise, pcFile)
			return This.Submit(poExercise, read(pcFile))

	def _Key(pcExerciseId)
		return pcExerciseId + "-by-" + @cId

	# TRUE if the learner has submitted for that exercise and the work file is still on disk.
	#
	#   pcExerciseId   the exercise's id
	#   returns        TRUE or FALSE
	#   note           a project id answers FALSE: a project has no work file, use HasPassedProject
	#   see            Submit, WorkFile, LastVerdict
	def HasTried(pcExerciseId)
		return This._Has(@cId, "worked-on", pcExerciseId) and fexists(This.WorkFile(pcExerciseId))

	# Returns the checker's verdict on the newest submission for an exercise or a project.
	#
	#   pcExerciseId   the exercise's or project's id
	#   returns        passed, diverged (it ran but a promise was missed) or error (it stopped with
	#                  an error); an empty text when nothing was submitted
	#   note           the verdict alone is not proof of a pass: HasPassed also compares the
	#                  evidence
	#   see            HasPassed, Submit
	def LastVerdict(pcExerciseId)
		_acV_ = _EduObjects(@aFacts, This._Key(pcExerciseId), "verdict")
		if len(_acV_) = 0
			return ""
		ok
		return _acV_[1]

	# TRUE if the checker passed the exercise and the work file still hashes to the evidence it recorded then.
	#
	#   pcExerciseId   the exercise's id
	#   returns        TRUE or FALSE
	#   note           a passed line typed by hand into progress.zknw, or a work file edited after
	#                  the pass, answers FALSE: the claim is refused, not trusted (law 9)
	#   see            LastVerdict, Submit, HasEarned
	#@ aka  Passed means: the checker said so AND its evidence still matches the work file. A verdict typed by hand carries no evidence and is refused.
	def HasPassed(pcExerciseId)
		if This.LastVerdict(pcExerciseId) != "passed"
			return 0
		ok
		_acE_ = _EduObjects(@aFacts, This._Key(pcExerciseId), "evidence")
		if len(_acE_) = 0 or NOT fexists(This.WorkFile(pcExerciseId))
			return 0
		ok
		return StzLower(_acE_[1]) = "sha256:" + StzLower(StzEngineCryptoSha256(read(This.WorkFile(pcExerciseId))))

	# Returns the first chapter of the course, in course order, that still has an exercise not passed with evidence.
	#
	#   poCourse   the stzCourse the learner follows
	#   returns    the chapter's id, a text; an empty text once every chapter is passed
	#   note       this is what the tutor's rule 2 means by where the learner is
	#   see        HasPassed, MissingFor
	#@ aka  -- where the learner is
	def ChapterOn(poCourse)
		_acCh_ = poCourse.ChapterIds()
		_nL_ = len(_acCh_)
		for _i_ = 1 to _nL_
			_acEx_ = poCourse.ExercisesOf(_acCh_[_i_])
			_nE_ = len(_acEx_)
			for _j_ = 1 to _nE_
				if NOT This.HasPassed(_acEx_[_j_])
					return _acCh_[_i_]
				ok
			next
		next
		return ""

	# Returns the path where the learner keeps the work for a level project, under projects/.
	#
	#   pcProjectId   the project's id, such as project-s0
	#   returns       a text; nothing is created
	#   see           SubmitProject, HasPassedProject
	#@ aka  -- projects and levels
	def ProjectFolder(pcProjectId)
		return @cFolder + "/projects/" + pcProjectId

	# Runs a project's guard on the learner's project folder and records the verdict, with the folder's hash as evidence.
	#
	#   poProject   the stzProject to judge the folder against
	#   returns     the stzExerciseCheck of the guard's run
	#   note        the evidence is the hash of every file in the folder, so any file added or
	#               changed after the pass makes HasPassedProject FALSE until the folder is
	#               submitted again
	#   warning     raises an error naming the learner and the project when the learner has no
	#               folder for it yet (create ProjectFolder first); the verdict is passed or
	#               diverged, never error; the guard runs on the desktop only
	#   see         HasPassedProject, ProjectFolder, HasEarned, Submit
	#@ aka  The learner's own project folder, judged by the project's guard. As with an exercise, the checker is the only writer of the verdict, and the evidence is the hash of the whole folder.
	def SubmitProject(poProject)
		_cPr_ = poProject.Id()
		_cDir_ = This.ProjectFolder(_cPr_)
		if NOT StzEngineDirExists(_cDir_)
			StzRaise("Learner '" + @cId + "' has no folder for project '" + _cPr_ + "' yet.")
		ok
		_oCheck_ = poProject.Check(_cDir_)
		_cKey_ = _cPr_ + "-by-" + @cId
		This._Add(@cId, "worked-on", _cPr_)
		# `attempt:` and `folder:` keep the two hashes two nodes (one edge per pair)
		This._Set(_cKey_, "last-attempt", "attempt:" + _EduFolderHash(_cDir_))
		if _oCheck_.Passed()
			This._Set(_cKey_, "verdict", "passed")
			This._Set(_cKey_, "evidence", "folder:" + _EduFolderHash(_cDir_))
			This._Set(_cKey_, "checked-at-ms", "" + _oCheck_.CheckedAtMs())
		else
			This._Set(_cKey_, "verdict", "diverged")
		ok
		This._Save()
		return _oCheck_

	# TRUE if the project's guard passed and the learner's whole project folder still hashes to the recorded evidence.
	#
	#   pcProjectId   the project's id
	#   returns       TRUE or FALSE
	#   note          adding even a harmless file to the folder after the pass makes it FALSE (shown
	#                 with an extra file)
	#   see           SubmitProject, HasEarned
	def HasPassedProject(pcProjectId)
		if This.LastVerdict(pcProjectId) != "passed"
			return 0
		ok
		_acE_ = _EduObjects(@aFacts, This._Key(pcProjectId), "evidence")
		_cDir_ = This.ProjectFolder(pcProjectId)
		if len(_acE_) = 0 or NOT StzEngineDirExists(_cDir_)
			return 0
		ok
		return StzLower(_acE_[1]) = "folder:" + StzLower(_EduFolderHash(_cDir_))

	# TRUE if every exercise of the chapters a level needs is passed and its project has passed, each with evidence that still matches.
	#
	#   poProgram   the stzProgram that defines the levels
	#   poCourse    the stzCourse whose chapters count
	#   pcLevel     the level's id, such as s0
	#   returns     TRUE or FALSE; FALSE too for a level that names no project
	#   note        nothing else earns a level: not a score, not a teacher
	#   see         MissingFor, HasPassed, HasPassedProject
	#@ aka  A level is earned when EVERY exercise of the chapters it needs has been passed AND its project has passed -- each with evidence that still matches. Nothing else earns it: not a score, not a teacher.
	def HasEarned(poProgram, poCourse, pcLevel)
		_acCh_ = poProgram.ChaptersForLevel(poCourse, pcLevel)
		_nL_ = len(_acCh_)
		for _i_ = 1 to _nL_
			_acEx_ = poCourse.ExercisesOf(_acCh_[_i_])
			_nE_ = len(_acEx_)
			for _e_ = 1 to _nE_
				if NOT This.HasPassed(_acEx_[_e_])
					return 0
				ok
			next
		next
		_cPr_ = poProgram.LevelFact(pcLevel, "earned-by")
		if _cPr_ = ""
			return 0
		ok
		return This.HasPassedProject(_cPr_)

	# Returns what still stands between the learner and a level: the exercises not passed, then the project if it has not passed.
	#
	#   poProgram   the stzProgram that defines the levels
	#   poCourse    the stzCourse whose chapters count
	#   pcLevel     the level's id, such as s0
	#   returns     a list of ids, exercises first and the project last; [ ] once the level is
	#               earned
	#   see         HasEarned, ChapterOn
	#@ aka  What still stands between the learner and a level, by name.
	def MissingFor(poProgram, poCourse, pcLevel)
		_acRes_ = []
		_acCh_ = poProgram.ChaptersForLevel(poCourse, pcLevel)
		_nL_ = len(_acCh_)
		for _i_ = 1 to _nL_
			_acEx_ = poCourse.ExercisesOf(_acCh_[_i_])
			_nE_ = len(_acEx_)
			for _e_ = 1 to _nE_
				if NOT This.HasPassed(_acEx_[_e_])
					_acRes_ + _acEx_[_e_]
				ok
			next
		next
		_cPr_ = poProgram.LevelFact(pcLevel, "earned-by")
		if _cPr_ != "" and NOT This.HasPassedProject(_cPr_)
			_acRes_ + _cPr_
		ok
		return _acRes_

	# Re-reads progress.zknw from disk, replacing the facts held in memory by what is written there now.
	#
	#   returns    nothing
	#   note       call it before a submission when another object, or a person, may have written
	#              the folder
	#   see        Facts, Submit
	#@ aka  Reloads the facts from disk -- what another object, or a person, wrote.
	def Reload()
		@aFacts = []
		if fexists(This.ProgressFile())
			@aFacts = _EduFactsOf(This.ProgressFile())
		ok

	#-- facts

	def _Has(pcS, pcP, pcO)
		_nL_ = len(@aFacts)
		for _i_ = 1 to _nL_
			if StzLower(@aFacts[_i_][1]) = StzLower(pcS) and StzLower(@aFacts[_i_][2]) = StzLower(pcP) and
			   StzLower(@aFacts[_i_][3]) = StzLower(pcO)
				return 1
			ok
		next
		return 0

	def _Add(pcS, pcP, pcO)
		if NOT This._Has(pcS, pcP, pcO)
			@aFacts + [ pcS, pcP, pcO ]
		ok

	def _Set(pcS, pcP, pcO)
		_aKeep_ = []
		_nL_ = len(@aFacts)
		for _i_ = 1 to _nL_
			if NOT ( StzLower(@aFacts[_i_][1]) = StzLower(pcS) and StzLower(@aFacts[_i_][2]) = StzLower(pcP) )
				_aKeep_ + @aFacts[_i_]
			ok
		next
		_aKeep_ + [ pcS, pcP, pcO ]
		@aFacts = _aKeep_

	def _Save()
		_c_ = 'knowledge "' + @cId + '"' + char(10) + char(10) + "facts" + char(10)
		_nL_ = len(@aFacts)
		for _i_ = 1 to _nL_
			_c_ += "    " + @aFacts[_i_][1] + " | " + @aFacts[_i_][2] + " | " + @aFacts[_i_][3] + char(10)
		next
		write(This.ProgressFile(), _c_)
