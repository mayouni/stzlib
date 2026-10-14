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

# Describes how a surface should look, as declared colours, scalars and textures and one fragment expression, and has the engine write the shader.
#
# You declare what the material takes, TakesColor, TakesScalar and TakesTexture, and write the body
# once as @out = expression, where the expression uses the declared names, numbers, the arithmetic
# operators, a whitelist of functions and the fragment builtins @normal, @position, @uv, @lambert
# and @color. ToWGSL has the engine transpile it to a complete shader and refuses a bad description
# with a message naming the offender. ParamsFrom and TexturesFrom flatten the values a scene binds.
# Authoring needs no GPU: only rendering the material wants hardware, and this class never renders.
#
#   receiver   o1 = new stzMaterialMaker o1.TakesColor(:base) o1.TakesScalar(:glow)
#              o1.ForEachFragment('{ @out = base * (1.0 + glow * @normal.y) }')
#   example    ? @@( o1.ColorNames() )
#              #--> [ "base" ]
#              ? o1.Spec()
#              #--> color base
#              scalar glow
#              body { @out = base * (1.0 + glow * @normal.y) }
#              ? len(o1.ParamsFrom([ :base = "#e0a030", :glow = 0.6 ]))
#              #--> 5
#              ? left(o1.ToWGSL(), 6)
#              #--> struct
#   see        stzScene, stzMesh, stzKernelMaker
class stzMaterialMaker from stzObject

	@aColors = []
	@aScalars = []
	@aTextures = []
	@cBody = ""
	@cWgsl = ""

	# Builds an empty material description with no colours, scalars, textures or body.
	#
	#   returns    nothing; the object is built
	#   note       StzMaterialMakerQ builds the same object; no device is needed to author a
	#              material
	#   see        TakesColor, ForEachFragment
	def init()

	# Declares a colour the material carries, usable by bare name in the body.
	#
	#   pcName     the name of the colour, in any letter case
	#   returns    nothing; the name is added in lower case. TakesColorQ returns the maker for
	#              chaining
	#   note       the name is appended even if already declared, and the generated shader is
	#              cleared so ToWGSL builds it again
	#   see        TakesScalar, ColorNames, ParamsFrom
	def TakesColor(pcName)
		@aColors + lower("" + pcName)
		@cWgsl = ""

	def TakesColorQ(pcName)
		This.TakesColor(pcName)
		return This

	# Declares a number the material carries, usable by bare name in the body.
	#
	#   pcName     the name of the scalar, in any letter case
	#   returns    nothing; the name is added in lower case. TakesScalarQ returns the maker for
	#              chaining
	#   see        TakesColor, ScalarNames, ParamsFrom
	def TakesScalar(pcName)
		@aScalars + lower("" + pcName)
		@cWgsl = ""

	def TakesScalarQ(pcName)
		This.TakesScalar(pcName)
		return This

	# Declares a picture the material reads, to be bound to an image when the material is set.
	#
	#   pcName     the name of the texture, in any letter case
	#   returns    nothing; the name is added in lower case. TakesTextureQ returns the maker for
	#              chaining
	#   note       the body reads it with sample(name, @uv) and never names the sampler
	#   see        TakesColor, TextureNames, TexturesFrom
	#@ aka  A texture is a PICTURE the material reads, not a value it carries: declared here, bound to an image at SetMaterial time, and read in the body with sample(name, @uv). The sampler is never named, because a sampler is not a surface property.
	def TakesTexture(pcName)
		@aTextures + lower("" + pcName)
		@cWgsl = ""

	def TakesTextureQ(pcName)
		This.TakesTexture(pcName)
		return This

	# Sets the body that computes the colour of each pixel, one assignment of the form @out = expression.
	#
	#   pcW        the body text, with the declared colours and scalars by bare name, numbers, the
	#              operators + - * / % and parentheses, the whitelisted functions and the builtins
	#              @normal, @position, @uv, @lambert and @color
	#   returns    nothing; the body is stored. ForEachFragmentQ returns the maker for chaining
	#   note       the text is kept as given and judged only by ToWGSL
	#   see        ToWGSL, Spec
	def ForEachFragment(pcW)
		@cBody = "" + pcW
		@cWgsl = ""

	def ForEachFragmentQ(pcW)
		This.ForEachFragment(pcW)
		return This

	# Returns the colours declared so far, in declaration order.
	#
	#   returns    a list of lower-case names; [ ] when none
	#   see        ScalarNames, TextureNames
	def ColorNames()
		return @aColors

	# Returns the scalars declared so far, in declaration order.
	#
	#   returns    a list of lower-case names; [ ] when none
	#   see        ColorNames, TextureNames
	def ScalarNames()
		return @aScalars

	# Returns the textures declared so far, in declaration order.
	#
	#   returns    a list of lower-case names; [ ] when none
	#   note       the order is the order the shader's bindings are laid out in
	#   see        ColorNames, ScalarNames
	def TextureNames()
		return @aTextures

	# Returns the declarations collapsed into the engine's spec text, one color, scalar or texture line each, then the body.
	#
	#   returns    a multi-line text; an empty text for an empty maker
	#   note       exposed for transparency and for guards; the body line is body followed by the
	#              text
	#   see        ToWGSL, ForEachFragment
	#@ aka  The engine's spec format -- the declarations, collapsed. Exposed for transparency and for the guard.
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

	# Asks the engine to turn the description into a complete WGSL shader, and keeps the answer.
	#
	#   returns    the shader source as text
	#   note       the shader declares the frame, instance and material structures and one binding
	#              for each declared texture and its sampler; no device is needed to produce it,
	#              only to run it
	#   warning    an empty body raises error stzMaterialMaker: no body (ForEachFragment missing); a
	#              name that is neither declared nor a whitelisted function, such as zork, raises
	#              error stzMaterialMaker: unknown name ... with the offender named
	#   see        Spec, ParamsFrom
	#@ aka  Transpile (engine-side) and cache. Raises with the engine's refusal message on a bad description -- the transpile is documented BY ITS OUTPUT, so nothing about the shader is hidden.
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

	# Returns the values of the declared colours and scalars flattened as the shader's structure expects them.
	#
	#   paBindings   a hash list giving a value for every declared name, colours as hex text such as
	#                #e0a030 and scalars as numbers
	#   returns      a list of numbers: four per colour in declaration order, red, green, blue and
	#                alpha from 0 to 1, then one per scalar
	#   note         #e0a030 gives 0.88, 0.63, 0.19 and 1; the alpha of a colour with no alpha is 1
	#   warning      a colour or a scalar with no binding raises error stzMaterialMaker: colour ...
	#                has no value (or scalar ... has no value), instead of answering the 0 that a
	#                missing hash key would give
	#   see          TexturesFrom, TakesColor
	#@ aka  The declared values, flattened the way the shader's struct expects: every colour as four numbers in declaration order, then every scalar. A missing binding RAISES by name -- a Ring hashlist answers 0 for an absent key, and a material silently shaded with black is worse than one that refuses.
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

	# Returns the engine handles of the declared textures, in declaration order.
	#
	#   paBindings   a hash list giving a handle above 0 for every declared texture, such as [
	#                :albedo = oImage.Handle() ]
	#   returns      a list of numbers, one per texture
	#   note         binding handle 0 would only fail later, as a panic at submit
	#   warning      a texture with no binding, or one that is not a handle above 0, raises error
	#                stzMaterialMaker: texture ... has no image
	#   see          ParamsFrom, TakesTexture
	#@ aka  The declared TEXTURES as engine handles, in declaration order -- the order the shader's bindings were laid out in. Same refusal discipline as the values: a missing texture RAISES by name rather than binding handle 0, which would report as a panic at submit.
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
