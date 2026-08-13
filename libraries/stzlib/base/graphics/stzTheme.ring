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
	for _line_ in StzSplit(pcCss, char(10))
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
	for _t_ in paTokens
		if StzLower("" + _t_[1]) = _c_  return _t_[2]  ok
	next
	return ""

class stzTheme from stzObject

	@cName = ""

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

	def Name()
		return @cName

	# The roles a theme fills in. Background is one of them and is NOT a
	# standalone colour -- see StzThemeRoles vs StzSemanticColors.
	def Roles()
		return StzThemeRoles()

	#-- reading it ----------------------------------------------------------

	# RESOLVED to hex, never left as an expression. The far side of an
	# export has no resolver.
	def ColorOf(pcRole)
		_e_ = StzThemeColor(@cName, pcRole)
		if _e_ = ""  return ""  ok
		return StzResolveColor(_e_)

	# The C2 step of a role, through this theme's colour for it.
	def StepOf(pcRole, pcStep)
		_e_ = StzThemeColor(@cName, pcRole)
		if _e_ = ""  return ""  ok
		_l_ = StzRoleStepL(pcStep)
		if _l_ < 0  return ""  ok
		return StzColorAtLightness(_e_, _l_)

	# What can be READ on that role's solid -- measured, not guessed.
	def OnColorOf(pcRole)
		_s_ = This.StepOf(pcRole, :Solid)
		if _s_ = ""  return ""  ok
		return StzResolveColor(StzBestTextOn(_s_)[1])

	# [ [ name, hex ], ... ] -- the whole theme flattened, and the ONE place
	# that decides what an export contains. CSS, JSON and Ring all read it,
	# so the three cannot disagree about which tokens exist.
	def Tokens()
		_a_ = []
		for _r_ in This.Roles()
			_cR_ = StzLower("" + _r_)
			_base_ = This.ColorOf(_r_)
			if _base_ = ""  loop  ok
			_a_ + [ _cR_, _base_ ]
			# background is a surface, not a thing that carries text or has
			# steps -- emitting steps for it would be four tokens nobody can
			# use
			if _cR_ = "background"  loop  ok
			for _s_ in StzRoleStepNames()
				_a_ + [ _cR_ + "-" + StzLower("" + _s_), This.StepOf(_r_, _s_) ]
			next
			_a_ + [ "on-" + _cR_, This.OnColorOf(_r_) ]
		next
		return _a_

	#-- exporting -----------------------------------------------------------

	def ToCSS()
		_p_ = StzThemeCssPrefix()
		_c_ = "/* Softanza theme: " + @cName + " */" + char(10)
		_c_ += ":root {" + char(10)
		for _t_ in This.Tokens()
			_c_ += "  " + _p_ + _t_[1] + ": " + _t_[2] + ";" + char(10)
		next
		_c_ += "}" + char(10)
		return _c_

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