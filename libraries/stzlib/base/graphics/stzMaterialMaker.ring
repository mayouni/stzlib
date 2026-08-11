#---------------------------------------------------------------------------#
#  STZMATERIALMAKER -- describe how a surface should look; the engine       #
#  generates and validates the shader. The stzKernelMaker of pixels.        #
#---------------------------------------------------------------------------#
#
#     oM = new stzMaterialMaker
#     oM.TakesColor(:base)
#     oM.TakesScalar(:glow)
#     oM.ForEachFragment('{ @out = base * (1.0 + glow * @normal.y) }')
#     ? oM.ToWGSL()                      # the generated shader, verbatim
#
#     oScene.SetMaterial(oM, [ :base = "#e0a030", :glow = 0.6 ])
#
# The body is LITERAL (the W lessons, as in stzKernelMaker): ONE assignment
# `@out = expression`, where the expression may use the declared colours
# and scalars by BARE NAME, numbers, + - * / % ( ) , the same 16-function
# whitelist, and the FRAGMENT BUILTINS -- what the rasterizer knows at this
# pixel and the material did not have to compute:
#
#     @normal    vec3, interpolated and re-normalized
#     @position  vec3, the fragment in world space
#     @uv        vec2, the mesh's texture coordinates
#     @lambert   f32, the diffuse term against the scene's light
#     @color     vec4, the instance's own colour
#
# Swizzles ride along (@normal.y, @color.rgb) because that is how a
# surface is actually described. Anything else REFUSES at ToWGSL() time
# with a message naming the offender.
#
# The transpiler lives in the ENGINE (gpu_wgsl.zig) -- any binding gets
# it; this class is one face. And what it emits is a COMPLETE shader on
# the render layer's 3D contract, so a material is a pipeline you can run,
# not a fragment nobody can bind.
#
# Authoring needs NO device: a material can be written and inspected on a
# GPU-less machine, and only rendering it wants hardware.

func StzMaterialMakerQ()
	return new stzMaterialMaker

class stzMaterialMaker from stzObject

	@aColors = []
	@aScalars = []
	@aTextures = []
	@cBody = ""
	@cWgsl = ""

	def init()

	def TakesColor(pcName)
		@aColors + lower("" + pcName)
		@cWgsl = ""

	def TakesColorQ(pcName)
		This.TakesColor(pcName)
		return This

	def TakesScalar(pcName)
		@aScalars + lower("" + pcName)
		@cWgsl = ""

	def TakesScalarQ(pcName)
		This.TakesScalar(pcName)
		return This

	# A texture is a PICTURE the material reads, not a value it carries:
	# declared here, bound to an image at SetMaterial time, and read in the
	# body with sample(name, @uv). The sampler is never named, because a
	# sampler is not a surface property.
	def TakesTexture(pcName)
		@aTextures + lower("" + pcName)
		@cWgsl = ""

	def TakesTextureQ(pcName)
		This.TakesTexture(pcName)
		return This

	def ForEachFragment(pcW)
		@cBody = "" + pcW
		@cWgsl = ""

	def ForEachFragmentQ(pcW)
		This.ForEachFragment(pcW)
		return This

	def ColorNames()
		return @aColors

	def ScalarNames()
		return @aScalars

	def TextureNames()
		return @aTextures

	# The engine's spec format -- the declarations, collapsed. Exposed for
	# transparency and for the guard.
	def Spec()
		_c_ = ""
		_nL_ = len(@aColors)
		for _i_ = 1 to _nL_
			_c_ += "color " + @aColors[_i_] + char(10)
		next
		_nL_ = len(@aScalars)
		for _i_ = 1 to _nL_
			_c_ += "scalar " + @aScalars[_i_] + char(10)
		next
		_nL_ = len(@aTextures)
		for _i_ = 1 to _nL_
			_c_ += "texture " + @aTextures[_i_] + char(10)
		next
		if @cBody != ""
			_c_ += "body " + @cBody
		ok
		return _c_

	# Transpile (engine-side) and cache. Raises with the engine's refusal
	# message on a bad description -- the transpile is documented BY ITS
	# OUTPUT, so nothing about the shader is hidden.
	def ToWGSL()
		if @cWgsl != ""
			return @cWgsl
		ok
		_cW_ = StzEngineGpuWgslFragment(This.Spec())
		if _cW_ = ""
			StzRaise("stzMaterialMaker: " + StzEngineGpuWgslError())
		ok
		@cWgsl = _cW_
		return @cWgsl

	# The declared values, flattened the way the shader's struct expects:
	# every colour as four numbers in declaration order, then every scalar.
	# A missing binding RAISES by name -- a Ring hashlist answers 0 for an
	# absent key, and a material silently shaded with black is worse than
	# one that refuses.
	def ParamsFrom(paBindings)
		_a_ = []
		_nL_ = len(@aColors)
		for _i_ = 1 to _nL_
			_v_ = _BindingValue(paBindings, @aColors[_i_])
			if isNull(_v_)
				StzRaise("stzMaterialMaker: colour '" + @aColors[_i_] +
					"' has no value (give [ :" + @aColors[_i_] + " = '#rrggbb' ]).")
			ok
			_n_ = StzColorToNumber(_v_)
			_a_ + (floor(_n_ / 16777216) % 256 / 255.0)
			_a_ + (floor(_n_ / 65536) % 256 / 255.0)
			_a_ + (floor(_n_ / 256) % 256 / 255.0)
			_a_ + ((_n_ % 256) / 255.0)
		next
		_nL_ = len(@aScalars)
		for _i_ = 1 to _nL_
			_v_ = _BindingValue(paBindings, @aScalars[_i_])
			if NOT isNumber(_v_)
				StzRaise("stzMaterialMaker: scalar '" + @aScalars[_i_] +
					"' has no value (give [ :" + @aScalars[_i_] + " = 0.5 ]).")
			ok
			_a_ + _v_
		next
		return _a_

	# The declared TEXTURES as engine handles, in declaration order -- the
	# order the shader's bindings were laid out in. Same refusal discipline
	# as the values: a missing texture RAISES by name rather than binding
	# handle 0, which would report as a panic at submit.
	def TexturesFrom(paBindings)
		_a_ = []
		_nL_ = len(@aTextures)
		for _i_ = 1 to _nL_
			_v_ = _BindingValue(paBindings, @aTextures[_i_])
			if NOT (isNumber(_v_) and _v_ > 0)
				StzRaise("stzMaterialMaker: texture '" + @aTextures[_i_] +
					"' has no image (give [ :" + @aTextures[_i_] +
					" = oImage.Handle() ]).")
			ok
			_a_ + _v_
		next
		return _a_
