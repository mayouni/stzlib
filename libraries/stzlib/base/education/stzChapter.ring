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

	#-- what the chapter is

	def File()
		return @cFile

	def Language()
		return @cLang

	def Title()
		return @cTitle

	def Blocks()
		return @aBlocks

	def Cells()
		return @acCells

	def NumberOfCells()
		return len(@acCells)

	def Cell(n)
		return @acCells[n]

	def CellPromises(n)
		return StzEduPromisesIn(@acCells[n])

	def ExerciseIds()
		return @acExercises

	def NumberOfStoredOutputs()
		return @nStoredOutputs

	def HasStoredOutput()
		return @nStoredOutputs > 0

	#-- running it

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

	# The program Run() executes, for a runner that batches chapters.
	def RunProgram(pcWorldFile)
		return This._Program(1, pcWorldFile)

	# The plain-Ring program ObserveWhere() executes.
	def WhereProgram()
		return This._Program(0, "")

	def Run(pcWorldFile)
		This.AcceptRun(StzEduRunProgram(This._Program(1, pcWorldFile)))

	# Takes the [ stdout, exit, stderr ] of RunProgram() run elsewhere.
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

	def HasRun()
		return @bRan

	def CellOutput(n)
		return @acOutput[n]

	def CellError(n)
		return @acError[n]

	def CellRan(n)
		return @acError[n] = ""

	# 1 kept, 0 broken, -1 the cell carries no promise
	def CellKept(n)
		return @anKept[n]

	def AllCellsRan()
		_nL_ = len(@acCells)
		for _i_ = 1 to _nL_
			if @acError[_i_] != ""
				return 0
			ok
		next
		return 1

	def AllPromisesKept()
		_nL_ = len(@anKept)
		for _i_ = 1 to _nL_
			if @anKept[_i_] = 0
				return 0
			ok
		next
		return 1

	def NumberOfPromises()
		_n_ = 0
		_nL_ = len(@acCells)
		for _i_ = 1 to _nL_
			_n_ += len(StzEduPromisesIn(@acCells[_i_]))
		next
		return _n_

	# Cells that ran but carry no promise: their output depends on the
	# world, so no page may ever show one.
	def WorldDependentCells()
		_anRes_ = []
		_nL_ = len(@anKept)
		for _i_ = 1 to _nL_
			if @anKept[_i_] = -1
				_anRes_ + _i_
			ok
		next
		return _anRes_

	#-- where each cell can run, observed

	def ObserveWhere()
		This.AcceptWhere(StzEduRunProgram(This._Program(0, "")))

	# Takes the [ stdout, exit, stderr ] of WhereProgram() run elsewhere.
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

	def RunsWhere(n)
		if len(@acWhere) = 0
			StzRaise("Where a cell runs is observed, never assumed: call ObserveWhere() first.")
		ok
		return @acWhere[n]

	def Where()
		return @acWhere
