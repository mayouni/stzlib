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
#   waiting for your implementation
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

# Builds a stzKernelMaker from a description text (the in / scalar / out / guard / body lines a maker's Spec() writes), so a description read from a file or typed in a page becomes a maker.
#
#   pcSpec     the description, one directive per line
#   returns    a stzKernelMaker
#   note       KP1 (2026-10-24): the bridge between the two runners; Spec() of the result is the
#              text again, line for line
#   see        stzKernelMaker.Spec
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
			_oK_.TakesVector(ring_trim(StzRight(_cLine_, len(_cLine_) - 3)))
		but StzLeft(_cLine_, 7) = "scalar "
			_oK_.TakesScalar(ring_trim(StzRight(_cLine_, len(_cLine_) - 7)))
		but StzLeft(_cLine_, 4) = "out "
			_oK_.ReturnsVector(ring_trim(StzRight(_cLine_, len(_cLine_) - 4)))
		but StzLeft(_cLine_, 6) = "guard "
			_oK_.Guard(ring_trim(StzRight(_cLine_, len(_cLine_) - 6)))
		but StzLeft(_cLine_, 5) = "body "
			_oK_.ForEachElement(ring_trim(StzRight(_cLine_, len(_cLine_) - 5)))
		else
			StzRaise("StzKernelMakerFromSpec: unknown line '" + _cLine_ + "' (in, scalar, out, guard, body).")
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
					_nLen_ = 0 + _cLen_
				ok
				_aB_ + [ _cName_, This._Recipe(@aFacts[_i_][3], _nLen_) ]
			but StzLeft(_cRel_, 7) = "scalar-"
				_aB_ + [ StzRight(_cRel_, len(_cRel_) - 7), 0 + @aFacts[_i_][3] ]
			ok
		next
		return _aB_

	# Grades a learner's kernel against the reference and answers the verdict in words the promise can match.
	#
	#   pLearner   a stzKernelMaker, or the description as text
	#   returns    a text: verified, mismatch at element K, mismatch-hidden at element K,
	#              write-outside at element K, impossible, refused: why, or waiting for your
	#              implementation
	#   note       with a device, the checker's VerifySpec with the NaN margin; without one, the
	#              interpreter alone at both shapes, and the verdict says so after the word
	def Grade(pLearner)
		_r_ = This._Prepare(pLearner)
		if isString(_r_)
			return _r_
		ok
		_oK_ = _r_
		_oRef_ = StzKernelMakerFromSpec(@cReference)
		_aB_ = This.Bindings()
		_nN_ = This.Elements()
		if StzEngineGpuInit($cStzGpuRuntime) != 0 and StzEngineGpuIsAvailable() != 0
			_oG_ = new stzGpu
			try
				_aV_ = _oG_.VerifySpecWith(_oRef_, _oK_, _aB_, [ :n = _nN_ ])
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
		return This._GradeOnCpu(StzKernelMakerFromSpec(@cReference), _r_, This.Bindings(), This.Elements())

	# A maker ready to grade, or the verdict that ends the grading before any run
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
		for _i_ = 1 to nN
			_r_ = _aR_[_i_]
			_c_ = _aC_[_i_]
			_bRNan_ = NOT (_r_ = _r_)
			_bCNan_ = NOT (_c_ = _c_)
			if _bRNan_ and _bCNan_
				loop
			ok
			if _bRNan_ or _bCNan_ or fabs(_r_ - _c_) > 0.000001
				return "mismatch" + cSuffix + " at element " + _i_
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
			other
				StzRaise("stzKernelPuzzle '" + @cId + "': unknown data recipe '" + pcRecipe + "' (ramp, half, mod13, ones, tenths).")
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
