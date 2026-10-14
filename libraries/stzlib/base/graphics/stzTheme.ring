#---------------------------------------------------------------------------#
#  STZTHEME -- a theme is DATA, and data can leave Ring                      #
#  (C5 of SOFTANZA_COLOR_SYSTEM.md)                                          #
#---------------------------------------------------------------------------#
#
#     oT = new stzTheme(:pro)
#
#     ? oT.ColorOf(:Danger)          # "#FF0000" -- resolved, not an expression
#     ? oT.StepOf(:Danger, :Surface) # the C2 role step
#     ? oT.OnColorOf(:Danger)        # what can be READ on its solid
#
#     write("theme.css",  oT.ToCSS())    # custom properties, for a web face
#     write("theme.json", oT.ToJSON())   # design tokens, for any tool
#     write("theme.ring", oT.ToRing())   # a literal, for embedding
#
# WHY THIS EXISTS. A theme was trapped in Ring. A product whose UI is partly
# Ring (stzApp, canvas, diagrams) and partly web (stzzui) therefore had TWO
# colour definitions, and two definitions of one thing drift -- which is not
# a hypothetical here: this library shipped two colour TABLES that disagreed
# about what "blue" meant, and §1 of the colour plan is the receipt.
#
# WHAT IS EXPORTED, and why it is more than the six role names. A web face
# needs `--stz-danger-surface` and `--stz-on-danger` as much as it needs
# `--stz-danger`, because those are what a component actually paints with.
# So every role goes out with its four C2 steps and its pair, RESOLVED to
# hex -- the far side has no resolver and must not need one.
#
# THE KILL CRITERION, from the plan: "if a round trip does not reproduce the
# same rendered colours, the export is decorative." So FromCSS exists, and
# the guard renders both and compares PIXELS. A file that merely parses
# proves nothing.

func StzThemeQ(pcName)
	return new stzTheme(pcName)

# The variable prefix, in one place: a web face greps for it, and a rename
# that happened in three files would strand one of them.
func StzThemeCssPrefix()
	return "--stz-"

# THESE TWO LIVE ABOVE THE CLASS, and that is structural rather than
# stylistic. A Ring file is read as statements, then FUNCTIONS, then
# CLASSES -- a func written after the first `class` is not a global at all,
# and calling it raises R3 "calling function without definition" from a
# file that plainly contains it.

# Read a Softanza theme CSS back into [ [ token, hex ], ... ].
#
# This exists for ONE reason: the plan's kill criterion. "If a round trip
# does not reproduce the same rendered colours, the export is decorative" --
# and a round trip needs a way back. It is deliberately narrow: it reads
# what ToCSS writes, not CSS in general.
func StzThemeFromCSS(pcCss)
	_p_ = StzThemeCssPrefix()
	_a_ = []
	_aLine2_ = StzSplit(pcCss, char(10))
	_nLine2_ = len(_aLine2_)
	for _iLine2_ = 1 to _nLine2_
		_line_ = _aLine2_[_iLine2_]
		_l_ = StzTrim(_line_)
		if len(_l_) < len(_p_)  loop  ok
		if StzSubStr(_l_, 1, len(_p_)) != _p_  loop  ok
		_nC_ = StzFindFirst(":", _l_)
		if _nC_ = 0  loop  ok
		_name_ = StzTrim(StzSubStr(_l_, len(_p_) + 1, _nC_ - len(_p_) - 1))
		_val_ = StzTrim(StzSubStr(_l_, _nC_ + 1, len(_l_) - _nC_))
		_val_ = StzTrim(StzReplace(_val_, ";", ""))
		if _name_ != "" and _val_ != ""
			_a_ + [ _name_, _val_ ]
		ok
	next
	return _a_

# The value of one token from a parsed export, or "" -- so a round-trip
# guard reads the far side the way a web face would.
func StzThemeTokenOf(paTokens, pcName)
	_c_ = StzLower("" + pcName)
	_aT1_ = paTokens
	_nT1_ = len(_aT1_)
	for _iT1_ = 1 to _nT1_
		_t_ = _aT1_[_iT1_]
		if StzLower("" + _t_[1]) = _c_  return _t_[2]  ok
	next
	return ""

# Holds a named colour theme as plain data, with every role resolved to hex, and exports it as CSS, JSON or a Ring list.
#
# A theme fills in eight roles: primary, success, warning, danger, info, muted, neutral and
# background. Each role except background carries four steps, surface, border, solid and text, and
# the colour that reads best on its solid step. Tokens flattens the theme to 43 name and colour
# pairs and ToCSS, ToJSON and ToRing all write from that one list, so the exports cannot disagree. A
# misspelt theme raises an error rather than exporting wrong colours. The themes are neutral, light,
# dark, vibrant, pro, access, print, gray, lightgray and darkgray.
#
#   receiver   o1 = new stzTheme(:pro)
#   example    ? o1.Name()
#              #--> pro
#              ? o1.ColorOf(:Primary)
#              #--> #4D4DC9
#              ? o1.StepOf(:Primary, :Surface)
#              #--> #EAEDFF
#              ? len(o1.Tokens())
#              #--> 43
#              ? o1.Tokens()[1][1]
#              #--> primary
#              ? StzThemeTokenOf(StzThemeFromCSS(o1.ToCSS()), "primary")
#              #--> #4D4DC9
#   see        stzColor, stzCanvas, stzGraphCanvas
class stzTheme from stzObject

	@cName = ""

	# Builds a theme by name, keeping its name in lower case.
	#
	#   pcName     the theme name, in any letter case, one of neutral, light, dark, vibrant, pro,
	#              access, print, gray, lightgray or darkgray
	#   returns    nothing; the object is built
	#   note       StzThemeQ builds the same object
	#   warning    an empty name raises error stzTheme: name a theme, and an unknown name such as
	#              nope raises error stzTheme: ... is not a theme, with the list of the ten themes,
	#              so a misspelt theme never exports plausible wrong colours
	#   see        Name, Roles
	def init(pcName)
		_c_ = StzLower("" + pcName)
		if _c_ = ""
			StzRaise("stzTheme: name a theme -- " +
				StzJoinWith(StzColorThemes(), ", ") + ".")
		ok
		# a theme that does not exist must REFUSE, not answer the neutral
		# fallback: a caller exporting a misspelt theme would otherwise ship
		# a file full of plausible wrong colours.
		if StzThemeColor(_c_, :primary) = ""
			StzRaise("stzTheme: '" + _c_ + "' is not a theme. The themes " +
				"are: " + StzJoinWith(StzColorThemes(), ", ") + ".")
		ok
		@cName = _c_

	# Returns the lower-case name of the theme.
	#
	#   returns    the name as text, such as pro
	#   see        Roles
	def Name()
		return @cName

	# Returns the roles a theme fills in: primary, success, warning, danger, info, muted, neutral and background.
	#
	#   returns    a list of eight role names as text
	#   note       background is a surface: it has a colour but no steps and no on-colour
	#   see        ColorOf, Tokens
	#@ aka  The roles a theme fills in. Background is one of them and is NOT a standalone colour -- see StzThemeRoles vs StzSemanticColors.
	def Roles()
		return StzThemeRoles()

	# Returns the colour a theme gives to a role, as a hex code.
	#
	#   pcRole     the role, as a symbol or a text such as :Danger
	#   returns    the colour as text such as #4D4DC9; an empty text for a role the theme does not
	#              have
	#   note       it is always resolved to hex, never left as an expression, because the far side
	#              of an export has no resolver
	#   see        StepOf, OnColorOf, Tokens
	#@ aka  -- reading it ----------------------------------------------------------
	def ColorOf(pcRole)
		_e_ = StzThemeColor(@cName, pcRole)
		if _e_ = ""  return ""  ok
		return StzResolveColor(_e_)

	# Returns one of the four steps of a role's colour, Surface, Border, Solid or Text, as a hex code.
	#
	#   pcRole     the role, such as :Danger
	#   pcStep     the step, one of :Surface, :Border, :Solid or :Text
	#   returns    the colour as text; an empty text for an unknown role or step
	#   note       the steps are the same hue at four lightnesses, from palest to deepest text
	#   see        ColorOf, OnColorOf
	#@ aka  The C2 step of a role, through this theme's colour for it.
	def StepOf(pcRole, pcStep)
		_e_ = StzThemeColor(@cName, pcRole)
		if _e_ = ""  return ""  ok
		_l_ = StzRoleStepL(pcStep)
		if _l_ < 0  return ""  ok
		return StzColorAtLightness(_e_, _l_)

	# Returns the colour that reads best as text on the solid step of a role.
	#
	#   pcRole     the role whose solid step is the background
	#   returns    the colour as a hex code chosen for contrast; an empty text for an unknown role
	#   note       the choice is measured against the solid step, not guessed
	#   see        StepOf, ColorOf
	#@ aka  What can be READ on that role's solid -- measured, not guessed.
	def OnColorOf(pcRole)
		_s_ = This.StepOf(pcRole, :Solid)
		if _s_ = ""  return ""  ok
		return StzResolveColor(StzBestTextOn(_s_)[1])

	# Returns the whole theme flattened to name and colour pairs, the list every export is written from.
	#
	#   returns    a list of [ name, hex ] pairs: 43 for a theme, each role as role, role-surface,
	#              role-border, role-solid, role-text and on-role, and background alone
	#   note       CSS, JSON and Ring all read this one list, so the three cannot disagree about
	#              which tokens exist
	#   see        ToCSS, ToJSON, ToRing
	#@ aka  [ [ name, hex ], ... ] -- the whole theme flattened, and the ONE place that decides what an export contains. CSS, JSON and Ring all read it, so the three cannot disagree about which tokens exist.
	def Tokens()
		_a_ = []
		_aR2_ = This.Roles()
		_nR2_ = len(_aR2_)
		for _iR2_ = 1 to _nR2_
			_r_ = _aR2_[_iR2_]
			_cR_ = StzLower("" + _r_)
			_base_ = This.ColorOf(_r_)
			if _base_ = ""  loop  ok
			_a_ + [ _cR_, _base_ ]
			# background is a surface, not a thing that carries text or has
			# steps -- emitting steps for it would be four tokens nobody can
			# use
			if _cR_ = "background"  loop  ok
			_aS1_ = StzRoleStepNames()
			_nS1_ = len(_aS1_)
			for _iS1_ = 1 to _nS1_
				_s_ = _aS1_[_iS1_]
				_a_ + [ _cR_ + "-" + StzLower("" + _s_), This.StepOf(_r_, _s_) ]
			next
			_a_ + [ "on-" + _cR_, This.OnColorOf(_r_) ]
		next
		return _a_

	# Returns the theme as CSS custom properties in a :root block, every token under the --stz- prefix.
	#
	#   returns    a text starting with a comment naming the theme
	#   note       StzThemeFromCSS reads the text back as [ name, hex ] pairs, and StzThemeTokenOf
	#              reads one token from them
	#   see        Tokens, ToJSON
	#@ aka  -- exporting -----------------------------------------------------------
	def ToCSS()
		_p_ = StzThemeCssPrefix()
		_c_ = "/* Softanza theme: " + @cName + " */" + char(10)
		_c_ += ":root {" + char(10)
		_aT1_ = This.Tokens()
		_nT1_ = len(_aT1_)
		for _iT1_ = 1 to _nT1_
			_t_ = _aT1_[_iT1_]
			_c_ += "  " + _p_ + _t_[1] + ": " + _t_[2] + ";" + char(10)
		next
		_c_ += "}" + char(10)
		return _c_

	# Returns the theme as a JSON object with the theme name and a tokens table, for design tools.
	#
	#   returns    a text holding a theme key and a tokens object
	#   see        Tokens, ToCSS
	def ToJSON()
		_c_ = "{" + char(10) + '  "theme": "' + @cName + '",' + char(10)
		_c_ += '  "tokens": {' + char(10)
		_a_ = This.Tokens()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_c_ += '    "' + _a_[_i_][1] + '": "' + _a_[_i_][2] + '"'
			if _i_ < _n_  _c_ += ","  ok
			_c_ += char(10)
		next
		_c_ += "  }" + char(10) + "}" + char(10)
		return _c_

	# Returns the theme as the source of a Ring list literal that can be written to a file and loaded.
	#
	#   returns    a text starting with a comment and an assignment named aTheme followed by the
	#              capitalised name
	#   note       a dash in a token name becomes an underscore, as in :primary_surface
	#   see        Tokens, ToCSS
	def ToRing()
		_c_ = "# Softanza theme: " + @cName + char(10)
		_c_ += "aTheme" + StzUpper(StzSubStr(@cName, 1, 1)) +
			StzSubStr(@cName, 2, len(@cName) - 1) + " = [" + char(10)
		_a_ = This.Tokens()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_c_ += '	:' + StzReplace(_a_[_i_][1], "-", "_") +
				' = "' + _a_[_i_][2] + '"'
			if _i_ < _n_  _c_ += ","  ok
			_c_ += char(10)
		next
		_c_ += "]" + char(10)
		return _c_