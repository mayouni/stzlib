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

class stzKernelMaker from stzObject

	@aIns = []
	@aScalars = []
	@cOut = ""
	@cBody = ""
	@cWgsl = ""

	def init()

	def TakesVector(pcName)
		@aIns + lower("" + pcName)
		@cWgsl = ""
		return This

	def TakesScalar(pcName)
		@aScalars + lower("" + pcName)
		@cWgsl = ""
		return This

	def ReturnsVector(pcName)
		@cOut = lower("" + pcName)
		@cWgsl = ""
		return This

	def ForEachElement(pcW)
		@cBody = "" + pcW
		@cWgsl = ""
		return This

	def InputNames()
		return @aIns

	def ScalarNames()
		return @aScalars

	def OutputName()
		return @cOut

	# The engine's spec format -- the declarations, collapsed. Exposed for
	# transparency and for the guard.
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

	# Transpile (engine-side) and cache. Pure text work: needs NO device,
	# so kernels can be authored and inspected on GPU-less machines.
	# Raises with the engine's refusal message on a bad description.
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
