#---------------------------------------------------------------------------#
#  STZKERNELMAKER -- describe an elementwise GPU computation; the engine    #
#  generates and validates the WGSL kernel. The stzRegexMaker of compute.   #
#---------------------------------------------------------------------------#
#
#     k = new stzKernelMaker
#     k.TakesVector(:A)
#     k.TakesVector(:B)
#     k.TakesScalar(:alpha)
#     k.ReturnsVector(:C)
#     k.ForEachElement('{ @C = alpha * @A + @B }')
#     ? k.ToWGSL()          # the generated kernel, verbatim -- nothing hidden
#
# The body is LITERAL (the W lessons): ONE assignment `@Out = expression`,
# where the expression may use declared vectors as @Name, declared scalars
# by bare name, numbers, + - * / % ( ) and this function set:
#   abs min max sqrt exp log sin cos tan tanh floor ceil pow clamp sign fract round
# and the choice when(condition, value if true, value if false) (GL0).
# Ints (GL0): TakesIntVector, TakesIntScalar and ReturnsIntVector declare
# whole numbers; int(...) and float(...) convert between the two types.
# Vectors (GL0): vec2/vec3/vec4(...), .x .zyx, dot length distance normalize
# cross reflect; TakesVectorOf(:p, :vec3) and ReturnsVectorOf(:q, :vec2)
# declare buffers of them, N numbers per element.
# The whole language, with the group lines (Shared, Stage, Reduce, Tiles,
# Accumulate, Width), is in SOFTANZA_GPU_KERNELS.md beside this file.
# Anything else REFUSES at ToWGSL() time with a message naming the offender.
# The transpiler itself lives in the ENGINE (gpu_wgsl.zig) -- any binding
# gets it; this class is one face.
#
# Limits (the ops binding contract): up to 5 input vectors, 14 scalars,
# exactly one output vector. All values are f32 on the device.

func StzKernelMakerQ()
	return new stzKernelMaker

# Describes an elementwise GPU computation with vectors, scalars and one assignment, and has the engine generate and check the WGSL kernel.
#
# Declare the inputs with TakesVector, the parameters with TakesScalar, the output with
# ReturnsVector and the body with ForEachElement, an assignment such as { @C = alpha * @A + @B }.
# ToWGSL returns the generated kernel verbatim, nothing hidden, and needs no GPU, so kernels can be
# written and inspected on a machine without one. Anything outside the declared names and the
# allowed functions refuses at ToWGSL with a message naming it. Limits: up to 5 input vectors, 14
# scalars and exactly one output; every value is f32 on the device. Hand the maker to stzGpu to run
# it.
#
#   receiver   o1 = new stzKernelMaker o1.TakesVector(:A) o1.TakesVector(:B) o1.TakesScalar(:alpha)
#              o1.ReturnsVector(:C) o1.ForEachElement("{ @C = alpha * @A + @B }")
#   example    ? @@( o1.InputNames() )
#              #--> [ "a", "b" ]
#              ? o1.OutputName()
#              #--> c
#              ? len(o1.ToWGSL()) > 100
#              #--> 1
#   see        stzGpu, stzGpuBuffer
class stzKernelMaker from stzObject

	@aIns = []
	@aScalars = []
	@cOut = ""
	@aIntNames = [] # GL0: the inputs and scalars declared to hold ints
	@bIntOut = 0
	@aVecWords = [] # GL0 (typed buffers): [ name, "vec3" ] for an input of vectors
	@cOutVec = ""
	@cBody = ""
	@cWgsl = ""
	@cGuard = ""
	@cWidth = ""
	@aShared = []
	@aSchedule = []

	# Creates an empty kernel description, to be filled with the vectors, scalars, output and body of an elementwise computation.
	#
	#   returns    nothing; the object is built
	#   see        TakesVector, ToWGSL
	def init()

	# Declares an input vector by name; a kernel takes up to 5.
	#
	#   pcName     the vector's name, stored in lower case and used as @Name in the body
	#   returns    the maker itself, so calls chain
	#   warning    declaring a vector clears the cached kernel text
	#   see        TakesScalar, ForEachElement
	def TakesVector(pcName)
		@aIns + lower("" + pcName)
		@cWgsl = ""
		return This

	# Declares a scalar parameter by name; a kernel takes up to 14.
	#
	#   pcName     the scalar's name, stored in lower case and used bare in the body
	#   returns    the maker itself, so calls chain
	#   warning    declaring a scalar clears the cached kernel text
	#   see        TakesVector, ForEachElement
	def TakesScalar(pcName)
		@aScalars + lower("" + pcName)
		@cWgsl = ""
		return This

	# Declares an input vector of whole numbers, read in the body as an int (GL0).
	#
	#   pcName     the vector's name, stored in lower case and used as @Name in the body
	#   returns    the maker itself, so calls chain
	#   note       the buffer still holds floats: each element is read through int(), toward zero, so a
	#              value crosses exactly up to 16,777,216; an int and a float meet only through
	#              int(...) or float(...)
	#   see        TakesVector, TakesIntScalar, ReturnsIntVector
	def TakesIntVector(pcName)
		This.TakesVector(pcName)
		@aIntNames + lower("" + pcName)
		return This

	# Declares a scalar parameter that holds a whole number, read in the body as an int (GL0).
	#
	#   pcName     the scalar's name, stored in lower case and used bare in the body
	#   returns    the maker itself, so calls chain
	#   see        TakesScalar, TakesIntVector
	def TakesIntScalar(pcName)
		This.TakesScalar(pcName)
		@aIntNames + lower("" + pcName)
		return This

	# Declares an input whose elements are of a type: :float, :int, or :vec2, :vec3, :vec4, a vector of floats per element (GL0).
	#
	#   pcName     the input's name, stored in lower case and used as @Name in the body
	#   pcType     :float, :int, :vec2, :vec3 or :vec4
	#   returns    the maker itself, so calls chain
	#   note       an input of vec3s is bound as a list of three-number lists, one per element, and
	#              travels packed, three floats per element; @Name is the element's vector and
	#              @Name[k] another element's, a zero vector outside
	#   see        TakesVector, TakesIntVector, ReturnsVectorOf
	def TakesVectorOf(pcName, pcType)
		_c_ = lower("" + pcType)
		if _c_ = "int"
			return This.TakesIntVector(pcName)
		ok
		This.TakesVector(pcName)
		if _c_ != "float"
			@aVecWords + [ lower("" + pcName), _c_ ]
		ok
		return This

	# Declares the single output with elements of a type: :float, :int, or :vec2, :vec3, :vec4 (GL0).
	#
	#   pcName     the output's name, stored in lower case and assigned as @Name in the body
	#   pcType     :float, :int, :vec2, :vec3 or :vec4
	#   returns    the maker itself, so calls chain
	#   note       an output of vec3s comes back as three numbers per element, in a row: the
	#              body's value must be a vec3
	#   see        ReturnsVector, TakesVectorOf
	def ReturnsVectorOf(pcName, pcType)
		_c_ = lower("" + pcType)
		if _c_ = "int"
			return This.ReturnsIntVector(pcName)
		ok
		This.ReturnsVector(pcName)
		if _c_ != "float"
			@cOutVec = _c_
		ok
		return This

	# Returns how many numbers one element of an input holds: 1, or a vector's 2 to 4 (GL0).
	#
	#   pcName     the input's name
	#   returns    a number, read by the engine from the description
	#   see        OutputWidth, TakesVectorOf
	def InputWidth(pcName)
		_c_ = lower("" + pcName)
		_nL_ = len(@aIns)
		for _i_ = 1 to _nL_
			if @aIns[_i_] = _c_
				return StzEngineGpuSpecInWidth(This.Spec(), _i_)
			ok
		next
		return 1

	# Returns how many numbers one element of the output holds: 1, or a vector's 2 to 4 (GL0).
	#
	#   returns    a number, read by the engine from the description
	#   see        InputWidth, ReturnsVectorOf
	def OutputWidth()
		return StzEngineGpuSpecOutWidth(This.Spec())

	# Declares the single output vector as holding whole numbers: the body's value is an int (GL0).
	#
	#   pcName     the output's name, stored in lower case and assigned as @Name in the body
	#   returns    the maker itself, so calls chain
	#   note       the value is written as a float, so a result crosses exactly up to 16,777,216
	#   see        ReturnsVector, TakesIntVector
	def ReturnsIntVector(pcName)
		This.ReturnsVector(pcName)
		@bIntOut = 1
		return This

	# Declares the single output vector by name.
	#
	#   pcName     the output's name, stored in lower case and assigned as @Name in the body
	#   returns    the maker itself, so calls chain
	#   warning    a kernel without an output refuses at ToWGSL
	#   see        ForEachElement, OutputName
	def ReturnsVector(pcName)
		@cOut = lower("" + pcName)
		@bIntOut = 0
		@cOutVec = ""
		@cWgsl = ""
		return This

	# Sets the body: one assignment from an expression over the declared vectors, scalars, numbers and a fixed set of functions.
	#
	#   pcW        the body in braces, such as '{ @C = alpha * @A + @B }'
	#   returns    the maker itself, so calls chain
	#   warning    the expression may call abs, min, max, sqrt, exp, log, sin, cos, tan, floor,
	#              ceil, pow, clamp, sign, fract and round; anything else refuses at ToWGSL naming
	#              the offender
	#   see        ToWGSL, Spec
	def ForEachElement(pcW)
		@cBody = "" + pcW
		@cWgsl = ""
		return This

	# Sets the bounds guard the kernel runs under, as a boolean text over the element index.
	#
	#   pcW        the guard, a text like { @i < n }, or "none" (also :none)
	#   returns    the object itself
	#   note       in the learner's own words: a boolean over @i (the element index), n (the element count),
	#              the scalars and the inputs, such as { @i > 0 and @i < n - 1 }
	#   note       KP0 (2026-10-24): without this call the engine guards with i < n as it always did;
	#              with none, the kernel writes every thread's element and a checker's NaN margin
	#              catches the ones past the region; the comparisons < <= > >= == != and the words
	#              and / or are admitted here and in the condition of a when, nowhere else
	#   see        ForEachElement, WithoutGuard
	def Guard(pcW)
		@cGuard = lower("" + pcW)
		@cWgsl = ""
		return This

	# Declares an array of floats in the workgroup's shared memory, which the threads of one group write in a stage and read after it.
	#
	#   pcName     the array's name, read in an expression as @Name[index]
	#   nSize      the number of floats, from 1 to 1024 (a group has 16 KB of shared memory in all)
	#   returns    the object itself
	#   note       KP3 (2026-10-27): WGSL fills it with zeros when the group starts
	#   see        Stage, Reduce
	def Shared(pcName, nSize)
		@aShared + ("shared " + lower("" + pcName) + " " + nSize)
		@cWgsl = ""
		return This

	# Adds a stage to the schedule: every thread of the group writes one slot of a shared array, then all wait at a barrier.
	#
	#   pcW        the write in braces, such as '{ @t[@l] = @a }' -- the slot, then the value
	#   returns    the object itself
	#   note       a stage may read the inputs, the group's names (@l, @g, @lx, @ly, @row, @col), the
	#              scalars and the OTHER shared arrays; reading the array it writes is refused, because
	#              the threads would race
	#   see        Shared, Reduce, Tiles
	def Stage(pcW)
		@aSchedule + ("stage " + pcW)
		@cWgsl = ""
		return This

	# Adds a reduce to the schedule: the halving tree over a shared array, with a barrier at each step; the result lands in slot 0.
	#
	#   pcName     the shared array, whose size is a power of two up to 256
	#   pcOp       sum, max or min
	#   returns    the object itself
	#   see        Stage, Shared
	def Reduce(pcName, pcOp)
		@aSchedule + ("reduce " + lower("" + pcName) + " " + lower("" + pcOp))
		@cWgsl = ""
		return This

	# Opens the tiles loop: the stages and the accumulate added after this call repeat, the variable counting from 0.
	#
	#   pcVar      the loop variable's name, read bare in the stages after it
	#   pcCount    the number of turns in braces, over scalars, n and numbers only: '{ k / 16 }'
	#   returns    the object itself
	#   note       the count must be the same for every thread, or a barrier inside the loop would wait
	#              for threads that left it
	#   see        Accumulate, Width
	def Tiles(pcVar, pcCount)
		@aSchedule + ("tiles " + lower("" + pcVar) + " " + pcCount)
		@cWgsl = ""
		return This

	# Adds the accumulate line inside the tiles loop: each thread's running value @acc, kept across turns and read by the body.
	#
	#   pcW        the update in braces, such as '{ @acc = @acc + sum(j, 0, 16, @x[j] * @y[j]) }'
	#   returns    the object itself
	#   see        Tiles
	def Accumulate(pcW)
		@aSchedule + ("accumulate " + pcW)
		@cWgsl = ""
		return This

	# Makes the output a matrix of the given width, worked in 16 x 16 tiles: each group computes one tile, and @row and @col name a thread's cell.
	#
	#   pW         a declared scalar's name or a number, a multiple of 16
	#   returns    the object itself
	#   note       the element count must be a whole number of 16-row tiles of that width
	#   see        Tiles
	def Width(pW)
		@cWidth = lower("" + pW)
		@cWgsl = ""
		return This

	# Omits the bounds guard: every thread writes its element, including the threads past n in the last workgroup.
	#
	#   returns    the object itself
	#   see        Guard
	def WithoutGuard()
		return This.Guard("none")

	# Returns the guard line as given, or an empty text when the engine's default guard applies.
	#
	#   returns    a text
	#   see        Guard
	def GuardText()
		return @cGuard

	# Evaluates the description on the CPU over the given vectors and scalars, with the engine's interpreter; needs no GPU.
	#
	# The interpreter reads the same grammar the transpiler reads, from the same parser.
	#
	#   paBindings   the input vectors by name (lists of numbers, one length) and the scalars by name
	#   returns      a list of numbers, one per element -- what the kernel must produce
	#   note         GK6 (2026-10-24): this is the checker's reference for a user kernel and the puzzle
	#                grader's CPU half; the arithmetic is f32 with WGSL's meanings (% truncates,
	#                round goes to even); the operation count per element is OperationsPerElement()
	#   warning      raises with the engine's message when the description is refused or a vector is
	#                missing or ragged
	#   see          ToWGSL, OperationsPerElement
	def EvaluateOn(paBindings)
		return This.EvaluateOnWith(paBindings, [])

	# Does the same as EvaluateOn with options, such as the number of elements to produce.
	#
	#   paBindings   the inputs and scalars by name; the inputs may differ in length
	#   paOptions    :n the output count, when it is not the first input's length (a first pass of partials writes fewer elements than its input holds)
	#   returns      a list of n numbers
	#   see          EvaluateOn
	def EvaluateOnWith(paBindings, paOptions)
		return This._EvaluateOn(paBindings, paOptions, 0)

	# Runs the description on the CPU over the given inputs with the sanitizer watching, and returns what it found.
	#
	#   paBindings   the input vectors and the scalars by name, as EvaluateOn takes them
	#   returns      a list of texts, one per defect kind found, each naming the line, the threads and
	#                the slot; an empty list when the description is clean
	#   note         GZ0 (2026-10-28): four defects the device runs without a word -- two threads of one
	#                stage writing one slot (a race: the device keeps any one write), a stage writing
	#                past its array (dropped), a read past a shared array (it reads 0), a read of a slot
	#                no stage wrote (it reads the zero the kernel filled; a max or min reduce counts it,
	#                a sum does not). A description with no shared memory is clean by construction
	#   see          SanitizeOnWith, EvaluateOn
	def SanitizeOn(paBindings)
		return This.SanitizeOnWith(paBindings, [])

	# Does the same as SanitizeOn with options, such as the number of elements to produce.
	#
	#   paBindings   the input vectors and the scalars by name
	#   paOptions    :n the output count, as EvaluateOnWith takes it
	#   returns      a list of texts, empty when the description is clean
	#   see          SanitizeOn
	def SanitizeOnWith(paBindings, paOptions)
		This._EvaluateOn(paBindings, paOptions, 1)
		_aLines_ = []
		_aR_ = StzSplit(StzEngineGpuSanitizeReport(), char(10))
		_nR_ = len(_aR_)
		for _i_ = 1 to _nR_
			if _aR_[_i_] != ""
				_aLines_ + _aR_[_i_]
			ok
		next
		return _aLines_

	def _EvaluateOn(paBindings, paOptions, bSanitize)
		_nIn_ = len(@aIns)
		if _nIn_ = 0
			StzRaise("stzKernelMaker: no TakesVector input to evaluate over.")
		ok
		# GL0: the interpreter reads the description before the bindings are looked up,
		# so a refused description is refused in the interpreter's own words
		StzEngineGpuSpecFlops(This.Spec())
		_cErr_ = StzEngineGpuWgslError()
		if _cErr_ != ""
			StzRaise("stzKernelMaker: " + _cErr_)
		ok
		_aFlat_ = []
		_aLens_ = []
		_n_ = 0
		for _i_ = 1 to _nIn_
			_v_ = _Binding(paBindings, @aIns[_i_])
			if NOT isList(_v_) or len(_v_) = 0
				StzRaise("stzKernelMaker: vector '" + @aIns[_i_] + "' is missing from the bindings.")
			ok
			# GL0 (typed buffers): an input of vectors is a list of rows, or the rows flat
			_nW_ = This.InputWidth(@aIns[_i_])
			_v_ = _StzKernelFlat(_v_)
			if _n_ = 0
				_n_ = floor(len(_v_) / _nW_)
			ok
			if len(_v_) % _nW_ != 0
				StzRaise("stzKernelMaker: vector '" + @aIns[_i_] + "' holds " + len(_v_) + " numbers, not a whole number of its " + _nW_ + "-number elements.")
			ok
			_nV_ = len(_v_)
			_aLens_ + _nV_
			for _j_ = 1 to _nV_
				_aFlat_ + _v_[_j_]
			next
		next
		_nOpt_ = _Binding(paOptions, "n")
		if isNumber(_nOpt_) and _nOpt_ > 0
			_n_ = _nOpt_
		ok
		_aScal_ = []
		_nS_ = len(@aScalars)
		for _i_ = 1 to _nS_
			_s_ = _Binding(paBindings, @aScalars[_i_])
			if NOT isNumber(_s_)
				StzRaise("stzKernelMaker: scalar '" + @aScalars[_i_] + "' is missing from the bindings.")
			ok
			_aScal_ + _s_
		next
		if bSanitize
			StzEngineGpuSpecSanitizeNext()
		ok
		_aOut_ = StzEngineGpuSpecEval(This.Spec(), _aFlat_, _aLens_, _n_, _aScal_)
		if len(_aOut_) = 0
			StzRaise("stzKernelMaker: " + StzEngineGpuWgslError())
		ok
		return _aOut_

	# Returns the number of operations the last EvaluateOn executed in all, loops included.
	#
	#   returns    a number
	#   note       the work a checker's compute ceiling reads against for this description over those inputs
	#   see        EvaluateOn, OperationsPerElement
	def OperationsExecuted()
		return StzEngineGpuSpecEvalFlops()

	# Returns the number of operations the description does per element, a sum counted once and not per iteration.
	#
	#   returns    a number, 0 when the description is refused
	#   note       one per operator or function call
	#   see        EvaluateOn, OperationsExecuted
	def OperationsPerElement()
		return StzEngineGpuSpecFlops(This.Spec())

	def _Binding(paBindings, cName)
		_n_ = len(paBindings)
		for _i_ = 1 to _n_
			if isList(paBindings[_i_]) and len(paBindings[_i_]) = 2 and lower("" + paBindings[_i_][1]) = cName
				return paBindings[_i_][2]
			ok
		next
		return NULL

	# Returns the body text as given to ForEachElement, or an empty text when none was given yet.
	def Body()
		return @cBody

	# Returns the declared input vectors, lower-cased, in the order declared.
	#
	#   returns    a list of texts
	#   see        ScalarNames, TakesScalar
	def InputNames()
		return @aIns

	# Returns the declared scalars, lower-cased, in the order declared.
	#
	#   returns    a list of texts
	#   see        TakesScalar, InputNames
	def ScalarNames()
		return @aScalars

	# Returns the declared output vector, lower-cased; empty when none is declared.
	#
	#   returns    a text
	#   see        ReturnsVector
	def OutputName()
		return @cOut

	# Returns the declarations in the engine's spec format: one in, scalar or out line each, then the body.
	#
	#   returns    a text of several lines
	#   warning    an empty maker gives an empty text
	#   see        ToWGSL
	#@ aka  The engine's spec format -- the declarations, collapsed. Exposed for transparency and for the guard.
	def Spec()
		_c_ = ""
		_nL_ = len(@aIns)
		for _i_ = 1 to _nL_
			_c_ += "in " + @aIns[_i_] + This._IntWord(@aIns[_i_]) + char(10)
		next
		_nL_ = len(@aScalars)
		for _i_ = 1 to _nL_
			_c_ += "scalar " + @aScalars[_i_] + This._IntWord(@aScalars[_i_]) + char(10)
		next
		if @cOut != ""
			_c_ += "out " + @cOut
			if @bIntOut
				_c_ += " int"
			ok
			if @cOutVec != ""
				_c_ += " " + @cOutVec
			ok
			_c_ += char(10)
		ok
		if @cWidth != ""
			_c_ += "width " + @cWidth + char(10)
		ok
		_nL_ = len(@aShared)
		for _i_ = 1 to _nL_
			_c_ += @aShared[_i_] + char(10)
		next
		_nL_ = len(@aSchedule)
		for _i_ = 1 to _nL_
			_c_ += @aSchedule[_i_] + char(10)
		next
		if @cGuard != ""
			_c_ += "guard " + @cGuard + char(10)
		ok
		if @cBody != ""
			_c_ += "body " + @cBody
		ok
		return _c_

	def _IntWord(pcName)
		_nL_ = len(@aIntNames)
		for _i_ = 1 to _nL_
			if @aIntNames[_i_] = pcName
				return " int"
			ok
		next
		_nL_ = len(@aVecWords)
		for _i_ = 1 to _nL_
			if @aVecWords[_i_][1] = pcName
				return " " + @aVecWords[_i_][2]
			ok
		next
		return ""

	# Returns the WGSL compute kernel the engine generates from the declarations, after checking them; needs no GPU.
	#
	#   returns    a text, the kernel source
	#   note       run: only the text transpiler of the engine, no device was opened
	#   warning    raises an error with the engine's message for a missing output, an unknown name
	#              or a function outside the list; the text is cached until a declaration changes
	#   see        Spec, ForEachElement
	#@ aka  Transpile (engine-side) and cache. Pure text work: needs NO device, so kernels can be authored and inspected on GPU-less machines. Raises with the engine's refusal message on a bad description.
	def ToWGSL()
		if @cWgsl != ""
			return @cWgsl
		ok
		_cW_ = StzEngineGpuWgslElementwise(This.Spec())
		if _cW_ = ""
			StzRaise("stzKernelMaker: " + StzEngineGpuWgslError())
		ok
		@cWgsl = _cW_
		return @cWgsl
