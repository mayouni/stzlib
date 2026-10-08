#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZCHAPTER                  #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : A CHAPTER is a narration whose every cell   #
#                  RUNS. It stores no output; it is judged by  #
#                  running its cells against their promises.   #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# Format: the house narration markdown (charter 5.3) -- `# Title`,
# `##` sections, fenced ```ring cells whose `#--> value` lines are
# PROMISES, `{{exercise:<id>}}` references, and a `## Recap` section.
# A fenced ```output / ```text / ```console block is a STORED OUTPUT
# and is counted, so the guard can refuse it (law 2).
#
# Run(world) runs ALL cells in ONE fresh process (the PX fast path),
# each inside try/catch so one failing cell does not hide the others.
# ObserveWhere() then runs the same cells WITHOUT the library, in plain
# Ring: a cell that still runs and keeps its promises there needs
# nothing but the core Ring VM -- which is what RingScript runs in a
# browser. That mark is OBSERVED, never typed by an author.

func StzChapterQ(pcFile, pcLang)
	return new stzChapter(pcFile, pcLang)

class stzChapter from stzObject

	@cFile = ""
	@cLang = ""
	@cTitle = ""
	@aBlocks = []        # [ :prose, text ] [ :cell, n ] [ :exercise, id ] [ :fence, text ]
	@acCells = []
	@acExercises = []
	@nStoredOutputs = 0
	@acOutput = []       # per cell, from the last Run()
	@acError = []
	@anKept = []         # 1 kept, 0 broken, -1 no promise
	@bRan = 0
	@acWhere = []        # per cell "browser" | "desktop", from ObserveWhere()

	# Reads a chapter's markdown file and splits it at once into prose, runnable cells, exercise references and stored-output fences.
	#
	#   pcFile     the path of the chapter file, NN-<id>.<lang>.md
	#   pcLang     the language code of this edition, used only to read the chapter's id from the
	#              file name and to report Language
	#   returns    nothing; the object is built
	#   note       the chapter's title is its first line that starts with "# "
	#   warning    raises error R35 (the file cannot be opened) when pcFile does not exist; the
	#              cells are not run here
	#   see        Blocks, Run
	def init(pcFile, pcLang)
		@cFile = pcFile
		@cLang = pcLang
		This._Parse()

	def _Parse()
		_acLines_ = StzSplit(StzReplace(read(@cFile), char(13), ""), char(10))
		_nState_ = 0     # 0 prose, 1 ring cell, 2 other fence
		_cBuf_ = ""
		_cProse_ = ""
		_nL_ = len(_acLines_)
		for _i_ = 1 to _nL_
			_c_ = _acLines_[_i_]
			_t_ = ring_trim(_c_)
			if _nState_ = 0
				if StzLeft(_t_, 3) = "```"
					if _cProse_ != ""
						@aBlocks + [ :prose, _cProse_ ]
						_cProse_ = ""
					ok
					_cInfo_ = StzLower(ring_trim(StzRight(_t_, StzLen(_t_) - 3)))
					_cBuf_ = ""
					if _cInfo_ = "ring"
						_nState_ = 1
					else
						_nState_ = 2
						if _cInfo_ = "output" or _cInfo_ = "text" or _cInfo_ = "console" or _cInfo_ = "out"
							@nStoredOutputs++
						ok
					ok
				but StzLeft(_t_, 11) = "{{exercise:" and StzRight(_t_, 2) = "}}"
					if _cProse_ != ""
						@aBlocks + [ :prose, _cProse_ ]
						_cProse_ = ""
					ok
					_cId_ = StzMid(_t_, 12, StzLen(_t_) - 13)
					@acExercises + _cId_
					@aBlocks + [ :exercise, _cId_ ]
				else
					if @cTitle = "" and StzLeft(_t_, 2) = "# "
						@cTitle = ring_trim(StzRight(_t_, StzLen(_t_) - 2))
					ok
					_cProse_ += _c_ + char(10)
				ok
			else
				if StzLeft(_t_, 3) = "```"
					if _nState_ = 1
						@acCells + _cBuf_
						@aBlocks + [ :cell, len(@acCells) ]
					else
						@aBlocks + [ :fence, _cBuf_ ]
					ok
					_nState_ = 0
				else
					_cBuf_ += _c_ + char(10)
				ok
			ok
		next
		if _cProse_ != ""
			@aBlocks + [ :prose, _cProse_ ]
		ok

	# Returns the path the chapter was read from, exactly as given.
	#
	#   returns    a text
	#   see        Id, Language
	#@ aka  -- what the chapter is
	def File()
		return @cFile

	# Returns the chapter's id, read from its file name by removing the NN- number prefix and the .<lang>.md tail.
	#
	#   returns    a text such as find-then-apply
	#   warning    a file name that does not end with .<lang>.md for the language given keeps the
	#              .md tail: 99-plain.en.md opened as fr gives plain.en.md
	#   see        File, Language
	#@ aka  The chapter id, read from the file name NN-<id>.<lang>.md
	def Id()
		_c_ = _EduLastSegment(@cFile)
		_cTail_ = "." + @cLang + ".md"
		if StzRight(_c_, StzLen(_cTail_)) = _cTail_
			_c_ = StzLeft(_c_, StzLen(_c_) - StzLen(_cTail_))
		ok
		_nDash_ = StzFindFirst("-", _c_)
		if _nDash_ > 0
			_c_ = StzRight(_c_, StzLen(_c_) - _nDash_)
		ok
		return _c_

	# Returns the language code this edition of the chapter was opened with.
	#
	#   returns    a text such as en
	#   see        Id
	def Language()
		return @cLang

	# Returns the chapter's title, the text of its first "# " line.
	#
	#   returns    a text; an empty text when the file has no such line
	#   see        Id, RecapAchieved
	def Title()
		return @cTitle

	# Returns the chapter in reading order as pairs of a kind and a value: prose, cell, exercise or fence.
	#
	#   returns    a list of pairs; a cell pair holds the cell's number, an exercise pair its id, a
	#              prose or fence pair its text
	#   see        Cells, ExerciseIds
	def Blocks()
		return @aBlocks

	# Returns the source of every runnable cell, the ring fences, with their #--> lines.
	#
	#   returns    a list of text, in reading order
	#   see        Cell, NumberOfCells
	def Cells()
		return @acCells

	# Returns how many runnable ring cells the chapter holds.
	#
	#   returns    a number
	#   see        Cells, NumberOfPromises
	def NumberOfCells()
		return len(@acCells)

	# Returns the source of one runnable cell, with its #--> lines.
	#
	#   n          the cell's number, from 1
	#   returns    a text
	#   warning    raises an index error (R2) for a number below 1 or above NumberOfCells
	#   see        Cells, CellPromises
	def Cell(n)
		return @acCells[n]

	# Returns the values a cell promises, the text after each #--> line.
	#
	#   n          the cell's number, from 1
	#   returns    a list of text; [ ] when the cell carries no promise
	#   warning    raises an index error (R2) for a number below 1 or above NumberOfCells
	#   see        Cell, NumberOfPromises
	def CellPromises(n)
		return StzEduPromisesIn(@acCells[n])

	# Returns the ids of the exercises the chapter points to with {{exercise:id}} lines.
	#
	#   returns    a list of text, in reading order
	#   see        Blocks
	def ExerciseIds()
		return @acExercises

	# Returns how many fenced blocks of stored output the chapter holds: fences marked output, text, console or out.
	#
	#   returns    a number; a guard refuses a chapter where it is above 0, because a chapter must
	#              show no output it did not just produce
	#   see        HasStoredOutput
	def NumberOfStoredOutputs()
		return @nStoredOutputs

	# TRUE if the chapter holds at least one fenced block of stored output.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfStoredOutputs
	def HasStoredOutput()
		return @nStoredOutputs > 0

	# Returns the names the chapter's cells call, read from the code: what the chapter teaches.
	#
	#   returns    a list of text without repeats, in order of first use; a name is a word of four
	#              characters or more written right before "(", so a class name after new is
	#              included and sort is not
	#   see        Cells, RecapAchieved
	#@ aka  -- running it
	def CalledNames()
		_acRes_ = []
		_nL_ = len(@acCells)
		for _i_ = 1 to _nL_
			_acN_ = _EduCalledNames(@acCells[_i_])
			_nN_ = len(_acN_)
			for _j_ = 1 to _nN_
				if StzFindFirst(_acN_[_j_], _acRes_) = 0
					_acRes_ + _acN_[_j_]
				ok
			next
		next
		return _acRes_

	# Returns the first bullet of the chapter's last "## " section, without its bold label, joined on one line.
	#
	#   returns    a text; an empty text when the file has no "## " section
	#   warning    the last "## " section is taken whatever its title, so a chapter that does not
	#              end with its recap returns the first bullet of that other section
	#   see        Title, CalledNames
	#@ aka  The first bullet of the recap -- what the chapter achieved, in the chapter's own language, without its bold label. The recap is the chapter's last section in every edition.
	def RecapAchieved()
		_acLines_ = StzSplit(StzReplace(read(@cFile), char(13), ""), char(10))
		_nL_ = len(_acLines_)
		_nStart_ = 0
		for _i_ = 1 to _nL_
			if StzLeft(_acLines_[_i_], 3) = "## "
				_nStart_ = _i_
			ok
		next
		if _nStart_ = 0
			return ""
		ok
		_cRes_ = ""
		_bIn_ = 0
		for _i_ = _nStart_ + 1 to _nL_
			_c_ = _acLines_[_i_]
			if StzLeft(_c_, 2) = "- "
				if _bIn_
					exit
				ok
				_bIn_ = 1
				_cRes_ = ring_trim(StzRight(_c_, StzLen(_c_) - 2))
			but _bIn_
				if ring_trim(_c_) = ""
					exit
				ok
				_cRes_ += " " + ring_trim(_c_)
			ok
		next
		if StzLeft(_cRes_, 2) = "**"
			_acParts_ = StzSplit(_cRes_, "**")
			_cRes_ = ""
			_nP_ = len(_acParts_)
			for _i_ = 3 to _nP_
				_cRes_ += _acParts_[_i_]
			next
			_cRes_ = ring_trim(_cRes_)
		ok
		return _cRes_

	def _Program(pbWithLibrary, pcWorldFile)
		_c_ = ""
		if pbWithLibrary
			_c_ += 'load "' + StzEduBaseFile() + '"' + char(10)
			# every edition of a chapter may show all four languages, so the
			# Hausa supplement is loaded whatever the chapter's own language
			_c_ += 'EduPrepareLanguage("ha")' + char(10)
			if pcWorldFile != ""
				_c_ += 'EduUseWorld("' + pcWorldFile + '")' + char(10)
			ok
		ok
		_nL_ = len(@acCells)
		for _i_ = 1 to _nL_
			_c_ += '? "@@EDU-CELL ' + _i_ + '@@"' + char(10)
			_c_ += "try" + char(10) + @acCells[_i_] + char(10)
			_c_ += "catch" + char(10) + '? "@@EDU-ERROR@@ " + cCatchError' + char(10) + "done" + char(10)
		next
		_c_ += '? "@@EDU-END@@"' + char(10)
		return _c_

	# [ outputs, errors ] per cell, from one process's stdout.
	def _Split(pcOut)
		_acOut_ = []
		_acErr_ = []
		_nL_ = len(@acCells)
		for _i_ = 1 to _nL_
			_acOut_ + ""
			_acErr_ + "(not reached)"
		next
		_n_ = 0
		_acLines_ = StzSplit(StzReplace(pcOut, char(13), ""), char(10))
		_nLines_ = len(_acLines_)
		for _i_ = 1 to _nLines_
			_c_ = _acLines_[_i_]
			if StzLeft(_c_, 11) = "@@EDU-CELL "
				_n_ = 0 + StzMid(_c_, 12, StzLen(_c_) - 13)
				_acErr_[_n_] = ""
			but StzLeft(_c_, 11) = "@@EDU-END@@"
				_n_ = 0
			but StzLeft(_c_, 13) = "@@EDU-ERROR@@"
				if _n_ > 0
					_acErr_[_n_] = ring_trim(StzRight(_c_, StzLen(_c_) - 13))
				ok
			else
				if _n_ > 0
					_acOut_[_n_] += _c_ + char(10)
				ok
			ok
		next
		return [ _acOut_, _acErr_ ]

	# Returns the Ring program that Run executes, for a runner that batches several chapters.
	#
	#   pcWorldFile   the path of a world file to use, or an empty text for none
	#   returns       a text: it loads the library by absolute path, prepares Hausa, optionally uses
	#                 a world, then runs every cell inside its own try/catch between @@EDU-CELL
	#                 markers
	#   warning       nothing is run by this call
	#   see           Run, WhereProgram
	#@ aka  The program Run() executes, for a runner that batches chapters.
	def RunProgram(pcWorldFile)
		return This._Program(1, pcWorldFile)

	# Returns the plain-Ring program that ObserveWhere executes: the same cells, without the library and without a world.
	#
	#   returns    a text
	#   warning    nothing is run by this call
	#   see        ObserveWhere, RunProgram
	#@ aka  The plain-Ring program ObserveWhere() executes.
	def WhereProgram()
		return This._Program(0, "")

	# Runs every cell in one fresh process with the library loaded and records each cell's output, error and promise verdict.
	#
	#   pcWorldFile   the path of a world file for the cells that read the world, or an empty text
	#                 for none
	#   returns       nothing; RunQ is the same call and returns the chapter
	#   note          the cells run on the desktop only
	#   warning       a failing cell does not stop the others; with no world, a cell that asks for
	#                 one fails with "No world is in use" and the chapter is then not AllCellsRan;
	#                 the child process loads the whole library, so a run takes seconds
	#   see           AcceptRun, CellKept, AllPromisesKept
	def Run(pcWorldFile)
		This.AcceptRun(StzEduRunProgram(This._Program(1, pcWorldFile)))

	# Takes the result of RunProgram run elsewhere, [ stdout, exit code, stderr ], and records each cell's output, error and promise verdict.
	#
	#   paRun      the list [ stdout, exit code, stderr ] of the run
	#   returns    nothing
	#   warning    a cell the output never reached keeps the error "(not reached)" and an empty
	#              output; the exit code is not read
	#   see        Run, RunProgram
	#@ aka  Takes the [ stdout, exit, stderr ] of RunProgram() run elsewhere.
	def AcceptRun(paRun)
		_aR_ = paRun
		_aS_ = This._Split(_aR_[1] + _aR_[3])
		@acOutput = _aS_[1]
		@acError = _aS_[2]
		@anKept = []
		_nL_ = len(@acCells)
		for _i_ = 1 to _nL_
			_acP_ = StzEduPromisesIn(@acCells[_i_])
			if len(_acP_) = 0
				@anKept + -1
			else
				_aM_ = StzEduMatchPromises(_acP_, @acOutput[_i_], @acError[_i_])
				@anKept + _aM_[:kept]
			ok
		next
		@bRan = 1

		def RunQ(pcWorldFile)
			This.Run(pcWorldFile)
			return This

	# TRUE if Run or AcceptRun has been called on this chapter.
	#
	#   returns    TRUE or FALSE
	#   see        Run, AcceptRun
	def HasRun()
		return @bRan

	# Returns what one cell printed in the last run, one line per print, each ended by a line break.
	#
	#   n          the cell's number, from 1
	#   returns    a text
	#   warning    raises an index error (R2) before any run, and for a number out of range
	#   see        CellError, CellKept
	def CellOutput(n)
		return @acOutput[n]

	# Returns the error one cell raised in the last run.
	#
	#   n          the cell's number, from 1
	#   returns    a text; an empty text when the cell ran cleanly, and "(not reached)" for a cell
	#              the run never got to
	#   warning    raises an index error (R2) before any run
	#   see        CellRan, CellOutput
	def CellError(n)
		return @acError[n]

	# TRUE if one cell raised no error in the last run.
	#
	#   n          the cell's number, from 1
	#   returns    TRUE or FALSE
	#   warning    raises an index error (R2) before any run
	#   see        CellError, AllCellsRan
	def CellRan(n)
		return @acError[n] = ""

	# Returns whether one cell kept its promises in the last run.
	#
	#   n          the cell's number, from 1
	#   returns    1 when every #--> value was printed in order, 0 when one was not, -1 when the
	#              cell carries no promise
	#   warning    raises an index error (R2) before any run
	#   see        CellPromises, AllPromisesKept
	#@ aka  1 kept, 0 broken, -1 the cell carries no promise
	def CellKept(n)
		return @anKept[n]

	# TRUE if no cell raised an error in the last run.
	#
	#   returns    TRUE or FALSE
	#   warning    raises an index error (R2) before any run
	#   see        CellRan, AllPromisesKept
	def AllCellsRan()
		_nL_ = len(@acCells)
		for _i_ = 1 to _nL_
			if @acError[_i_] != ""
				return 0
			ok
		next
		return 1

	# TRUE if no cell broke a promise in the last run; cells without a promise do not count.
	#
	#   returns    TRUE or FALSE; TRUE before any run, because nothing is broken yet
	#   warning    call HasRun first: before a run the answer says nothing about the chapter
	#   see        AllCellsRan, CellKept
	def AllPromisesKept()
		_nL_ = len(@anKept)
		for _i_ = 1 to _nL_
			if @anKept[_i_] = 0
				return 0
			ok
		next
		return 1

	# Returns how many #--> promises the chapter's cells hold in all.
	#
	#   returns    a number; it needs no run
	#   see        CellPromises, WorldDependentCells
	def NumberOfPromises()
		_n_ = 0
		_nL_ = len(@acCells)
		for _i_ = 1 to _nL_
			_n_ += len(StzEduPromisesIn(@acCells[_i_]))
		next
		return _n_

	# Returns the numbers of the cells that carry no promise, whose output depends on the world and so may not be shown on a page.
	#
	#   returns    a list of numbers; [ ] before any run
	#   warning    a cell that carries no promise is listed whether or not it ran
	#   see        CellKept, NumberOfPromises
	#@ aka  Cells that ran but carry no promise: their output depends on the world, so no page may ever show one.
	def WorldDependentCells()
		_anRes_ = []
		_nL_ = len(@anKept)
		for _i_ = 1 to _nL_
			if @anKept[_i_] = -1
				_anRes_ + _i_
			ok
		next
		return _anRes_

	# Runs the cells in plain Ring, without the library, and marks each one browser or desktop from what happened.
	#
	#   returns    nothing
	#   note       the mark is observed, never typed by an author; the cells run on the desktop only
	#   warning    a cell is marked browser when it raised no error and either carries no promise or
	#              keeps its promises; a cell that calls any library class is therefore marked
	#              desktop, which is every cell of chapter 1
	#   see        AcceptWhere, RunsWhere, Where
	#@ aka  -- where each cell can run, observed
	def ObserveWhere()
		This.AcceptWhere(StzEduRunProgram(This._Program(0, "")))

	# Takes the result of WhereProgram run elsewhere, [ stdout, exit code, stderr ], and marks each cell browser or desktop.
	#
	#   paRun      the list [ stdout, exit code, stderr ] of the plain-Ring run
	#   returns    nothing
	#   warning    the exit code is not read
	#   see        ObserveWhere, WhereProgram
	#@ aka  Takes the [ stdout, exit, stderr ] of WhereProgram() run elsewhere.
	def AcceptWhere(paRun)
		_aR_ = paRun
		_aS_ = This._Split(_aR_[1] + _aR_[3])
		@acWhere = []
		_nL_ = len(@acCells)
		for _i_ = 1 to _nL_
			_cW_ = "desktop"
			if _aS_[2][_i_] = ""
				_acP_ = StzEduPromisesIn(@acCells[_i_])
				if len(_acP_) = 0
					_cW_ = "browser"
				else
					_aM_ = StzEduMatchPromises(_acP_, _aS_[1][_i_], "")
					if _aM_[:kept] = 1
						_cW_ = "browser"
					ok
				ok
			ok
			@acWhere + _cW_
		next

	# Returns where one cell was observed to run.
	#
	#   n          the cell's number, from 1
	#   returns    browser or desktop, as text
	#   warning    raises an error saying where a cell runs is observed, never assumed, when
	#              ObserveWhere or AcceptWhere has not been called
	#   see        Where, ObserveWhere
	def RunsWhere(n)
		if len(@acWhere) = 0
			StzRaise("Where a cell runs is observed, never assumed: call ObserveWhere() first.")
		ok
		return @acWhere[n]

	# Returns the observed place of every cell, in order.
	#
	#   returns    a list of text, browser or desktop; [ ] before ObserveWhere
	#   see        RunsWhere, ObserveWhere
	def Where()
		return @acWhere
