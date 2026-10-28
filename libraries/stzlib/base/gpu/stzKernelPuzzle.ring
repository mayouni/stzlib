#---------------------------------------------------------------------------#
#  STZKERNELPUZZLE -- a kernel puzzle of the Learning System, graded by     #
#  the checker: the learner's description against the puzzle's reference,  #
#  interpreted on the CPU, at a visible shape and a hidden one, with the    #
#  NaN margin that names a store past the region (KP1 of the GPU plan).    #
#---------------------------------------------------------------------------#
#
# A puzzle is an exercise folder under
#   base/education/program/courses/kernel-puzzles/exercises/<id>/
# in the Learning System's own shape (exercise.zknw, task.<lang>.md,
# promise.ring, right/, wrong/) plus two texts the grammar reads:
#   reference.txt   the description the learner's kernel must match
#   starter.txt     where the learner starts; it FAILS "waiting for your
#                   implementation" until a body is written
# and facts in exercise.zknw that build the data:
#   kp-01 | elements | 4000          the output count n
#   kp-01 | input-a  | ramp          an input vector and its recipe
#   kp-01 | scalar-alpha | 2.5       a scalar and its value
#   kp-01 | input-length-a | 16000   an input longer than n (a stencil, a sum)
# Recipes: ramp (0, 1, 2, ...), half (0, 0.5, 1, ...), mod13 ((i * 7) % 13),
# ones, tenths ((i % 10) / 10). The browser runner builds the same data from
# the same facts, so the two runners grade one spec to one verdict.
#
# The verdict is ONE WORD or a short phrase the promise can match:
#   verified · mismatch at element K · mismatch-hidden at element K ·
#   write-outside at element K · impossible · refused: <why> ·
#   race at line L · waiting for your implementation
# A race is named before anything runs: two threads of one stage writing one
# slot leave the device free to keep either write, so no comparison of values
# can stand for it (GZ0). Sanitize() gives the sentence behind it, and the
# quieter defects the device runs without a word.
# On a machine without a device the grading is the interpreter's alone, at
# both shapes, in the same words; a store past the region cannot be seen
# there (the margin needs a device). GradeOnCpu is that path, callable.

func StzKernelPuzzleQ(pcId)
	return new stzKernelPuzzle(pcId)

# The folder the puzzles live in, from the engine directory the library discovered at load.
func StzKernelPuzzlesFolder()
	_nSlash_ = 0
	_nL_ = len($cEngineDir)
	for _i_ = 1 to _nL_
		if $cEngineDir[_i_] = "/"
			_nSlash_ = _i_
		ok
	next
	return StzLeft($cEngineDir, _nSlash_ - 1) + "/base/education/program/courses/kernel-puzzles/exercises"

# Builds a stzKernelMaker from a description text, so a description read from a file or typed in a page becomes a maker.
#
# The text holds the lines a maker's Spec() writes: in, scalar, out, guard, body and the group lines.
#
#   pcSpec     the description, one directive per line
#   returns    a stzKernelMaker
#   note       KP1 (2026-10-24): the bridge between the two runners; Spec() of the result is the
#              text again, line for line
#   see        stzKernelMaker.Spec
# GL0: a declaration's name and its type word, from 'a', 'a int', 'a float' or
# 'a vec3'; another word is kept on the name, for the engine to refuse.
func _StzKernelDecl(pcRest)
	_c_ = ring_trim(pcRest)
	_acW_ = StzSplit(_c_, " ")
	if len(_acW_) = 2
		_cT_ = lower(_acW_[2])
		if _cT_ = "int" or _cT_ = "float" or _cT_ = "vec2" or _cT_ = "vec3" or _cT_ = "vec4"
			return [ _acW_[1], _cT_ ]
		ok
	ok
	return [ _c_, "float" ]

# GL0 (typed buffers): rows of an input of vectors, flat -- a flat list is kept.
func _StzKernelFlat(paV)
	if len(paV) = 0 or NOT isList(paV[1])
		return paV
	ok
	_a_ = []
	_nL_ = len(paV)
	for _i_ = 1 to _nL_
		_nC_ = len(paV[_i_])
		for _j_ = 1 to _nC_
			_a_ + paV[_i_][_j_]
		next
	next
	return _a_

# GL0 (typed buffers): a flat list of numbers as rows of nW, one per element.
func _StzKernelRows(paV, nW)
	if nW <= 1 or len(paV) = 0 or isList(paV[1])
		return paV
	ok
	_a_ = []
	_nE_ = floor(len(paV) / nW)
	for _i_ = 0 to _nE_ - 1
		_r_ = []
		for _j_ = 1 to nW
			_r_ + paV[_i_ * nW + _j_]
		next
		_a_ + _r_ # Ring appends a list as one element: the row
	next
	return _a_

func StzKernelMakerFromSpec(pcSpec)
	_oK_ = new stzKernelMaker
	_acLines_ = StzSplit(StzReplace(pcSpec, char(13), ""), char(10))
	_nL_ = len(_acLines_)
	for _i_ = 1 to _nL_
		_cLine_ = ring_trim(_acLines_[_i_])
		if _cLine_ = ""
			loop
		ok
		if StzLeft(_cLine_, 3) = "in "
			_aD_ = _StzKernelDecl(StzRight(_cLine_, len(_cLine_) - 3))
			_oK_.TakesVectorOf(_aD_[1], _aD_[2])
		but StzLeft(_cLine_, 7) = "scalar "
			_aD_ = _StzKernelDecl(StzRight(_cLine_, len(_cLine_) - 7))
			if _aD_[2] = "int"
				_oK_.TakesIntScalar(_aD_[1])
			but _aD_[2] = "float"
				_oK_.TakesScalar(_aD_[1])
			else
				_oK_.TakesScalar(_aD_[1] + " " + _aD_[2])
			ok
		but StzLeft(_cLine_, 4) = "out "
			_aD_ = _StzKernelDecl(StzRight(_cLine_, len(_cLine_) - 4))
			_oK_.ReturnsVectorOf(_aD_[1], _aD_[2])
		but StzLeft(_cLine_, 6) = "guard "
			_oK_.Guard(ring_trim(StzRight(_cLine_, len(_cLine_) - 6)))
		but StzLeft(_cLine_, 5) = "body "
			_oK_.ForEachElement(ring_trim(StzRight(_cLine_, len(_cLine_) - 5)))
		but StzLeft(_cLine_, 7) = "shared "
			# the engine checks the size; the face keeps the text as written
			_acW_ = StzSplit(ring_trim(StzRight(_cLine_, len(_cLine_) - 7)), " ")
			if len(_acW_) != 2
				StzRaise("StzKernelMakerFromSpec: a shared line is 'shared NAME SIZE', not '" + _cLine_ + "'.")
			ok
			_oK_.Shared(_acW_[1], _acW_[2])
		but StzLeft(_cLine_, 6) = "stage "
			_oK_.Stage(ring_trim(StzRight(_cLine_, len(_cLine_) - 6)))
		but StzLeft(_cLine_, 7) = "reduce "
			_acW_ = StzSplit(ring_trim(StzRight(_cLine_, len(_cLine_) - 7)), " ")
			if len(_acW_) != 2
				StzRaise("StzKernelMakerFromSpec: a reduce line is 'reduce NAME sum|max|min', not '" + _cLine_ + "'.")
			ok
			_oK_.Reduce(_acW_[1], _acW_[2])
		but StzLeft(_cLine_, 6) = "tiles "
			_cR_ = ring_trim(StzRight(_cLine_, len(_cLine_) - 6))
			_acW_ = StzSplit(_cR_, " ")
			if len(_acW_) < 2
				StzRaise("StzKernelMakerFromSpec: a tiles line is 'tiles VAR { count }', not '" + _cLine_ + "'.")
			ok
			_oK_.Tiles(_acW_[1], ring_trim(StzRight(_cR_, len(_cR_) - len(_acW_[1]))))
		but StzLeft(_cLine_, 11) = "accumulate "
			_oK_.Accumulate(ring_trim(StzRight(_cLine_, len(_cLine_) - 11)))
		but StzLeft(_cLine_, 6) = "width "
			_oK_.Width(ring_trim(StzRight(_cLine_, len(_cLine_) - 6)))
		else
			StzRaise("StzKernelMakerFromSpec: unknown line '" + _cLine_ + "' (in, scalar, out, width, shared, stage, reduce, tiles, accumulate, guard, body).")
		ok
	next
	return _oK_

# Grades a learner's kernel description against a puzzle of the kernel-puzzles course, by running it: the checker compares it with the puzzle's reference interpreted on the CPU, at the visible shape and a hidden one, with a NaN margin after the output.
#
# A puzzle is a folder in the Learning System's exercise shape with two texts more, reference.txt
# and starter.txt, and data facts in its exercise.zknw. Grade takes a maker or a description text
# and answers one word or a short phrase: verified, mismatch at element K, mismatch-hidden at
# element K, write-outside at element K, impossible, refused: why, or waiting for your
# implementation. Starter, Reference and Task give the learner what the page gives. The browser
# runner of the course grades the same text from the same facts to the same words.
#
#   receiver   o1 = StzKernelPuzzleQ("kp-01")
#   example    ? o1.Elements()
#              ? o1.Grade(StzKernelMakerFromSpec(o1.Reference()))
#   output     4000
#              verified
#
class stzKernelPuzzle from stzObject
	@cId = ""
	@cFolder = ""
	@aFacts = []
	@cReference = ""
	@cStarter = ""

	# Opens a puzzle by its exercise id and reads its facts, reference and starter.
	#
	#   pcId       the exercise folder's name, such as kp-01
	#   warning    raises an error naming the puzzle when the folder, exercise.zknw or
	#              reference.txt is missing
	#   see        Grade
	def init(pcId)
		@cId = lower("" + pcId)
		@cFolder = StzKernelPuzzlesFolder() + "/" + @cId
		if NOT fexists(@cFolder + "/exercise.zknw")
			StzRaise("stzKernelPuzzle: no puzzle '" + @cId + "' (no exercise.zknw at " + @cFolder + ").")
		ok
		if NOT fexists(@cFolder + "/reference.txt")
			StzRaise("stzKernelPuzzle '" + @cId + "': reference.txt is missing; nothing could grade it.")
		ok
		@aFacts = This._FactsOf(read(@cFolder + "/exercise.zknw"))
		@cReference = StzReplace(read(@cFolder + "/reference.txt"), char(13), "")
		if fexists(@cFolder + "/starter.txt")
			@cStarter = StzReplace(read(@cFolder + "/starter.txt"), char(13), "")
		ok

	# Returns the exercise id, lower-cased, as the puzzle was opened.
	#
	#   returns    a text
	#   see        Folder
	def Id()
		return @cId

	# Returns the folder the puzzle was read from.
	#
	#   returns    a text
	#   see        Id
	def Folder()
		return @cFolder

	# Returns the reference description, the text the learner's kernel must match in every element.
	def Reference()
		return @cReference

	# Returns the description the learner starts from.
	def Starter()
		return @cStarter

	# Returns the task text in a language (en, fr, ar, ha), or an empty text when the puzzle has none in it.
	#
	#   pcLang     the language code: en, fr, ar or ha
	#   returns    a text, the task in markdown
	def Task(pcLang)
		_cF_ = @cFolder + "/task." + lower("" + pcLang) + ".md"
		if fexists(_cF_)
			return read(_cF_)
		ok
		return ""

	# Returns the output count n the puzzle grades over.
	def Elements()
		_c_ = This._Fact("elements")
		if _c_ = ""
			return 4096
		ok
		return 0 + _c_

	# Returns the input vectors and the scalars the puzzle binds, built from its facts, as the bindings a maker takes.
	#
	#   returns    a list of [ name, value ] pairs
	#   note       the browser runner builds the same data from the same facts
	def Bindings()
		_aB_ = []
		_nN_ = This.Elements()
		_nL_ = len(@aFacts)
		for _i_ = 1 to _nL_
			_cRel_ = lower(@aFacts[_i_][2])
			if StzLeft(_cRel_, 6) = "input-" and StzLeft(_cRel_, 13) != "input-length-"
				_cName_ = StzRight(_cRel_, len(_cRel_) - 6)
				_nLen_ = _nN_
				_cLen_ = This._Fact("input-length-" + _cName_)
				if _cLen_ != ""
					# a length may NAME a scalar ("the input is as long as m says"): the
					# knowledge graph keeps one edge per node pair, so two facts of one
					# puzzle cannot both point at the node 1024
					if NOT (_cLen_[1] >= "0" and _cLen_[1] <= "9")
						_cLen_ = This._Fact("scalar-" + lower(_cLen_))
					ok
					_nLen_ = 0 + _cLen_
				ok
				# GL0 (typed buffers): an input of vecNs takes N numbers of its recipe per element
				_nW_ = StzKernelMakerFromSpec(@cReference).InputWidth(_cName_)
				_aB_ + [ _cName_, _StzKernelRows(This._Recipe(@aFacts[_i_][3], _nLen_ * _nW_), _nW_) ]
			but StzLeft(_cRel_, 7) = "scalar-"
				_aB_ + [ StzRight(_cRel_, len(_cRel_) - 7), 0 + @aFacts[_i_][3] ]
			ok
		next
		return _aB_

	# Returns the hidden shape's element count when the puzzle declares one, or 0 when the checker derives it.
	#
	#   returns    a number
	#   note       KP3 (2026-10-27): a matrix's hidden shape is another matrix, with its own width and
	#              depth; the facts hidden-elements, hidden-scalar-NAME and hidden-input-length-NAME
	#              give it, and the hidden inputs are the same recipes at those lengths, reversed
	#   see        HiddenBindings
	def HiddenElements()
		_c_ = This._Fact("hidden-elements")
		if _c_ = ""
			return 0
		ok
		return 0 + _c_

	# Returns the hidden shape's inputs and scalars when the puzzle declares one, as the bindings a maker takes.
	#
	#   returns    a list of [ name, value ] pairs; empty when the puzzle declares no hidden shape
	#   see        HiddenElements, Bindings
	def HiddenBindings()
		_nN_ = This.HiddenElements()
		if _nN_ = 0
			return []
		ok
		_aB_ = []
		_nL_ = len(@aFacts)
		for _i_ = 1 to _nL_
			_cRel_ = lower(@aFacts[_i_][2])
			if StzLeft(_cRel_, 6) = "input-" and StzLeft(_cRel_, 13) != "input-length-"
				_cName_ = StzRight(_cRel_, len(_cRel_) - 6)
				_nLen_ = _nN_
				_cLen_ = This._Fact("hidden-input-length-" + _cName_)
				if _cLen_ != ""
					_nLen_ = 0 + _cLen_
				ok
				_aV_ = This._Recipe(@aFacts[_i_][3], _nLen_)
				_aR_ = []
				for _j_ = _nLen_ to 1 step -1
					_aR_ + _aV_[_j_]
				next
				_aB_ + [ _cName_, _aR_ ]
			but StzLeft(_cRel_, 7) = "scalar-"
				_cName_ = StzRight(_cRel_, len(_cRel_) - 7)
				_cH_ = This._Fact("hidden-scalar-" + _cName_)
				if _cH_ = ""
					_aB_ + [ _cName_, 0 + @aFacts[_i_][3] ]
				else
					_aB_ + [ _cName_, 0 + _cH_ ]
				ok
			ok
		next
		return _aB_

	# Returns the allowed difference per element, from the band fact, or 0.000001.
	#
	#   returns    a number
	#   note       an exp or a long sum on the device rounds differently from the CPU; the band is
	#              set from a measurement and written in the puzzle's facts
	def Band()
		_c_ = This._Fact("band")
		if _c_ = ""
			return 0.000001
		ok
		return 0 + _c_

	# Grades a learner's kernel against the reference and answers the verdict in words the promise can match.
	#
	#   pLearner   a stzKernelMaker, or the description as text
	#   returns    a text: verified, mismatch at element K, mismatch-hidden at element K,
	#              write-outside at element K, impossible, refused: why, race at line L, or waiting
	#              for your implementation
	#   note       with a device, the checker's VerifySpec with the NaN margin; without one, the
	#              interpreter alone at both shapes, and the verdict says so after the word
	def Grade(pLearner)
		_r_ = This._Prepare(pLearner)
		if isString(_r_)
			return _r_
		ok
		_oK_ = _r_
		_cRace_ = This._RaceVerdict(_oK_)
		if _cRace_ != ""
			return _cRace_
		ok
		_oRef_ = StzKernelMakerFromSpec(@cReference)
		_aB_ = This.Bindings()
		_nN_ = This.Elements()
		if StzEngineGpuInit($cStzGpuRuntime) != 0 and StzEngineGpuIsAvailable() != 0
			_oG_ = new stzGpu
			_aOpt_ = [ :n = _nN_, :band = This.Band() ]
			if This.HiddenElements() > 0
				_aOpt_ + [ "hidden", [ [ "n", This.HiddenElements() ], [ "bindings", This.HiddenBindings() ] ] ]
			ok
			try
				_aV_ = _oG_.VerifySpecWith(_oRef_, _oK_, _aB_, _aOpt_)
			catch
				return "refused: " + cCatchError
			done
			switch _aV_[:verdict]
			on "verified"
				return "verified"
			on "mismatch"
				return "mismatch at element " + _aV_[:firstbad]
			on "mismatch-hidden"
				return "mismatch-hidden at element " + _aV_[:firstbad]
			on "write-outside"
				return "write-outside at element " + _aV_[:outsideat]
			on "impossible"
				return "impossible"
			other
				return "error"
			end
		ok
		return This._GradeOnCpu(_oRef_, _oK_, _aB_, _nN_)

	# Measures where the learner's kernel stands under this device's two roofs, the copy floor and the compute peak.
	#
	#   pLearner   a stzKernelMaker, or the description as text
	#   returns    a hashlist with :elements, :bytes, :flops, :ms (the best dispatch and sync, on the
	#              wall clock the copy floor is measured with), :gpums (-1 without timestamps), :gbs,
	#              :floorgbs, :bandwidthfraction, :gflops, :peakgflops, :peakfraction and :bound
	#              (memory or compute); or a text when the kernel cannot run (the verdict words of
	#              Grade, or "no device")
	#   note       KP3 (2026-10-27): the size is the puzzle's roofline-elements fact (4,194,304 when
	#              absent); the inputs are filled on the device, so no list crosses; bytes and
	#              operations are the ESSENTIAL ones -- each input read once, the output written once,
	#              the reference's operations per element -- the roofline's convention, so a kernel
	#              that does more than it must shows a smaller fraction
	#   see        Grade
	def Roofline(pLearner)
		_r_ = This._Prepare(pLearner)
		if isString(_r_)
			return _r_
		ok
		_oK_ = _r_
		if NOT (StzEngineGpuInit($cStzGpuRuntime) != 0 and StzEngineGpuIsAvailable() != 0)
			return "no device"
		ok
		_oRef_ = StzKernelMakerFromSpec(@cReference)
		_nN_ = 4194304
		_c_ = This._Fact("roofline-elements")
		if _c_ != ""
			_nN_ = 0 + _c_
		ok
		_nKer_ = StzEngineGpuKernelCompile(_oK_.ToWGSL())
		if _nKer_ = 0
			return "refused: " + StzEngineGpuLastError()
		ok
		_aIds_ = []
		_nIn_ = len(_oRef_.InputNames())
		for _i_ = 1 to _nIn_ + 1
			_nId_ = StzEngineGpuBufferNew(_nN_ * 4)
			if _nId_ = 0
				_FreeIds(_aIds_)
				return "refused: no device buffer of " + (_nN_ * 4) + " bytes"
			ok
			if _i_ <= _nIn_
				StzEngineGpuBufferFillLcg(_nId_, _nN_, 7 + _i_)
			ok
			_aIds_ + _nId_
		next
		_aScal_ = _OrderedScalars(_oRef_, This.Bindings())
		_nBytes_ = (_nIn_ + 1) * _nN_ * 4
		_nFlops_ = _oRef_.OperationsPerElement() * _nN_
		_nSt_ = StzEngineGpuVerifyRoofline(_nKer_, _nN_, _aScal_, _aIds_, ceil(_nN_ / 256.0), _nBytes_, _nFlops_, 7)
		_FreeIds(_aIds_)
		if _nSt_ != 0
			return "refused: the roofline could not run (" + StzEngineGpuLastError() + ")"
		ok
		_cBound_ = "memory"
		if StzEngineGpuVerifyResult(30) = 2
			_cBound_ = "compute"
		ok
		return [
			:elements = _nN_,
			:bytes = _nBytes_,
			:flops = _nFlops_,
			:ms = StzEngineGpuVerifyResult(24),
			:gpums = StzEngineGpuVerifyResult(25),
			:gbs = StzEngineGpuVerifyResult(26),
			:floorgbs = StzEngineGpuVerifyResult(10),
			:bandwidthfraction = StzEngineGpuVerifyResult(27),
			:gflops = StzEngineGpuVerifyResult(28),
			:peakgflops = StzEngineGpuVerifyResult(17),
			:peakfraction = StzEngineGpuVerifyResult(29),
			:bound = _cBound_
		]

	# Grades on the CPU alone, by the interpreter at both shapes, whatever device the machine has.
	#
	#   pLearner   a stzKernelMaker, or the description as text
	#   note       the browser's path when WebGPU is missing, and the guard's way to show the two paths agree
	#   returns    the verdict words as Grade gives them; a store past the region cannot be seen
	#              here (the margin needs a device)
	#   see        Grade
	def GradeOnCpu(pLearner)
		_r_ = This._Prepare(pLearner)
		if isString(_r_)
			return _r_
		ok
		_cRace_ = This._RaceVerdict(_r_)
		if _cRace_ != ""
			return _cRace_
		ok
		return This._GradeOnCpu(StzKernelMakerFromSpec(@cReference), _r_, This.Bindings(), This.Elements())

	# A maker ready to grade, or the verdict that ends the grading before any run
	# Runs the learner's kernel on the CPU with the sanitizer watching, at the puzzle's visible shape, and returns what it found.
	#
	#   pLearner   a stzKernelMaker, or the description as text
	#   returns    a list of texts, one per defect kind, each naming the line, the threads and the slot;
	#              empty when the kernel is clean, or when it cannot be evaluated (Grade says why)
	#   note       GZ0 (2026-10-28): a race is also Grade's verdict; a write or a read past an array,
	#              and a read of a slot nobody wrote, run on the device without a word and are said here
	#   see        Grade
	def Sanitize(pLearner)
		_r_ = This._Prepare(pLearner)
		if isString(_r_)
			return []
		ok
		try
			return _r_.SanitizeOnWith(This.Bindings(), [ :n = This.Elements() ])
		catch
			return []
		done

	def _RaceVerdict(poK)
		try
			poK.SanitizeOnWith(This.Bindings(), [ :n = This.Elements() ])
		catch
			return ""
		done
		if StzEngineGpuSanitizeCount(0) > 0
			return "race at line " + StzEngineGpuSanitizeLine(0)
		ok
		return ""

	def _Prepare(pLearner)
		if isString(pLearner)
			_cText_ = StzReplace(pLearner, char(13), "")
			if ring_trim(_cText_) = "" or ring_trim(_cText_) = ring_trim(@cStarter)
				return "waiting for your implementation"
			ok
			try
				_oK_ = StzKernelMakerFromSpec(_cText_)
			catch
				return "refused: " + cCatchError
			done
		else
			_oK_ = pLearner
		ok
		if _oK_.Body() = ""
			return "waiting for your implementation"
		ok
		# the task's inputs and scalars, in the task's order: one params block serves the
		# learner's kernel and the reference's interpreter alike
		_oRef_ = StzKernelMakerFromSpec(@cReference)
		if @@(_oK_.InputNames()) != @@(_oRef_.InputNames()) or @@(_oK_.ScalarNames()) != @@(_oRef_.ScalarNames())
			return "refused: your inputs " + @@(_oK_.InputNames()) + " and scalars " + @@(_oK_.ScalarNames()) +
				" are not the task's " + @@(_oRef_.InputNames()) + " and " + @@(_oRef_.ScalarNames()) + " in the task's order"
		ok
		try
			_oK_.ToWGSL()
		catch
			return "refused: " + StzReplace(cCatchError, "stzKernelMaker: ", "")
		done
		return _oK_

	# The interpreter alone: both descriptions at the visible shape and the hidden one; an
	# element the reference leaves unwritten must be unwritten in the learner's too
	def _GradeOnCpu(poRef, poK, paB, nN)
		_cV_ = This._CompareOnCpu(poRef, poK, paB, nN, "")
		if _cV_ != "verified"
			return _cV_
		ok
		if This.HiddenElements() > 0
			return This._CompareOnCpu(poRef, poK, This.HiddenBindings(), This.HiddenElements(), "-hidden")
		ok
		# the hidden shape: odd, tile-uneven, the reversed tail of each input
		_nB_ = floor(nN * 5 / 7)
		if _nB_ < 1
			_nB_ = 1
		ok
		if _nB_ > 1 and _nB_ % 2 = 0
			_nB_--
		ok
		_aHid_ = []
		_nL_ = len(paB)
		for _i_ = 1 to _nL_
			if isList(paB[_i_][2])
				_v_ = paB[_i_][2]
				_nLen_ = len(_v_)
				_nHL_ = floor(_nLen_ * _nB_ / nN)
				if _nHL_ < 1
					_nHL_ = 1
				ok
				_h_ = []
				for _j_ = _nLen_ to (_nLen_ - _nHL_ + 1) step -1
					_h_ + _v_[_j_]
				next
				_aHid_ + [ paB[_i_][1], _h_ ]
			else
				_aHid_ + paB[_i_]
			ok
		next
		return This._CompareOnCpu(poRef, poK, _aHid_, _nB_, "-hidden")

	def _CompareOnCpu(poRef, poK, paB, nN, cSuffix)
		_aR_ = poRef.EvaluateOnWith(paB, [ :n = nN ])
		try
			_aC_ = poK.EvaluateOnWith(paB, [ :n = nN ])
		catch
			return "refused: " + StzReplace(cCatchError, "stzKernelMaker: ", "")
		done
		_nBand_ = This.Band()
		# GL0 (typed buffers): W numbers per element of the output, a mismatch named by element
		_nW_ = poRef.OutputWidth()
		for _i_ = 1 to nN * _nW_
			_r_ = _aR_[_i_]
			_c_ = _aC_[_i_]
			_bRNan_ = NOT (_r_ = _r_)
			_bCNan_ = NOT (_c_ = _c_)
			if _bRNan_ and _bCNan_
				loop
			ok
			if _bRNan_ or _bCNan_ or fabs(_r_ - _c_) > _nBand_
				return "mismatch" + cSuffix + " at element " + ceil(_i_ / _nW_)
			ok
		next
		return "verified"

	def _Fact(pcRelation)
		_cR_ = lower(pcRelation)
		_nL_ = len(@aFacts)
		for _i_ = 1 to _nL_
			if lower(@aFacts[_i_][2]) = _cR_
				return @aFacts[_i_][3]
			ok
		next
		return ""

	# The data recipes, the same five the browser runner knows
	def _Recipe(pcRecipe, nLen)
		_a_ = []
		_c_ = lower(ring_trim(pcRecipe))
		for _i_ = 0 to nLen - 1
			switch _c_
			on "ramp"
				_a_ + _i_
			on "half"
				_a_ + (_i_ * 0.5)
			on "mod13"
				_a_ + ((_i_ * 7) % 13)
			on "ones"
				_a_ + 1
			on "tenths"
				_a_ + ((_i_ % 10) / 10.0)
			on "mod7"
				_a_ + ((_i_ * 3) % 7)
			other
				StzRaise("stzKernelPuzzle '" + @cId + "': unknown data recipe '" + pcRecipe + "' (ramp, half, mod13, mod7, ones, tenths).")
			end
		next
		return _a_

	# subject | relation | object lines, the manifest's own shape, read without the graph
	def _FactsOf(pcText)
		_aF_ = []
		_acL_ = StzSplit(StzReplace(pcText, char(13), ""), char(10))
		_nL_ = len(_acL_)
		for _i_ = 1 to _nL_
			_cLine_ = ring_trim(_acL_[_i_])
			if _cLine_ = "" or StzLeft(_cLine_, 1) = "#" or StzLeft(_cLine_, 9) = "knowledge" or _cLine_ = "facts"
				loop
			ok
			_aP_ = StzSplit(_cLine_, "|")
			if len(_aP_) = 3
				_aF_ + [ ring_trim(_aP_[1]), ring_trim(_aP_[2]), ring_trim(_aP_[3]) ]
			ok
		next
		return _aF_
