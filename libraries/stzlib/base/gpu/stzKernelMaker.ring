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
#   abs min max sqrt exp log sin cos tan floor ceil pow clamp sign fract round
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
	@cBody = ""
	@cWgsl = ""

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

	# Declares the single output vector by name.
	#
	#   pcName     the output's name, stored in lower case and assigned as @Name in the body
	#   returns    the maker itself, so calls chain
	#   warning    a kernel without an output refuses at ToWGSL
	#   see        ForEachElement, OutputName
	def ReturnsVector(pcName)
		@cOut = lower("" + pcName)
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

	# Returns the declared input vectors, lower-cased, in the order declared.
	#
	#   returns    a list of texts
	#   see        TakesVector, ScalarNames
	# Evaluates the description on the CPU over the given vectors and scalars, by the engine's interpreter of the same grammar the transpiler reads; needs no GPU.
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
		_nIn_ = len(@aIns)
		if _nIn_ = 0
			StzRaise("stzKernelMaker: no TakesVector input to evaluate over.")
		ok
		_aFlat_ = []
		_n_ = 0
		for _i_ = 1 to _nIn_
			_v_ = _Binding(paBindings, @aIns[_i_])
			if NOT isList(_v_) or len(_v_) = 0
				StzRaise("stzKernelMaker: vector '" + @aIns[_i_] + "' is missing from the bindings.")
			ok
			if _n_ = 0
				_n_ = len(_v_)
			but len(_v_) != _n_
				StzRaise("stzKernelMaker: vector '" + @aIns[_i_] + "' has " + len(_v_) +
					" elements, the first had " + _n_ + ".")
			ok
			_nV_ = len(_v_)
			for _j_ = 1 to _nV_
				_aFlat_ + _v_[_j_]
			next
		next
		_aScal_ = []
		_nS_ = len(@aScalars)
		for _i_ = 1 to _nS_
			_s_ = _Binding(paBindings, @aScalars[_i_])
			if NOT isNumber(_s_)
				StzRaise("stzKernelMaker: scalar '" + @aScalars[_i_] + "' is missing from the bindings.")
			ok
			_aScal_ + _s_
		next
		_aOut_ = StzEngineGpuSpecEval(This.Spec(), _aFlat_, _nIn_, _n_, _aScal_)
		if len(_aOut_) = 0
			StzRaise("stzKernelMaker: " + StzEngineGpuWgslError())
		ok
		return _aOut_

	# Returns the number of operations the description does per element (one per operator or function call), the work a checker's compute ceiling reads against.
	#
	#   returns    a number, 0 when the description is refused
	#   see        EvaluateOn
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
			_c_ += "in " + @aIns[_i_] + char(10)
		next
		_nL_ = len(@aScalars)
		for _i_ = 1 to _nL_
			_c_ += "scalar " + @aScalars[_i_] + char(10)
		next
		if @cOut != ""
			_c_ += "out " + @cOut + char(10)
		ok
		if @cBody != ""
			_c_ += "body " + @cBody
		ok
		return _c_

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
