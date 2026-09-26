#=====================================================================#
#  STZMATHNOTATION -- the notation of a label, $...$ (DN10), moved     #
#  from base/graph/stzMathDiagram.ring on 2026-09-26 (decision 6 of   #
#  base/math/CHARTER.md: notation is mathematics, the draw path is not) #
#=====================================================================#
#
# THE CUT, AND NOTHING ELSE. This file is lines 1230-1473 of
# stzMathDiagram.ring as they stood at edae36a05, moved whole: the same
# table, the same reader, the same refusals, the same run list
# [ cText, nDx, nDy, nSize ] that _DrawShape's text branch and
# _MeasureTextAt in the diagram still consume. A probe over sixteen labels
# and the DN10 section of gg_adversarial ran before and after the move and
# answered the same bytes. Functions resolve at call time in Ring, so this
# file loads after the diagram and the diagram's two callers find them.
#
# WHAT GROWS HERE NEXT (M1's last step): fractions, roots, sums with their
# limits, and matrices -- as stacked runs within the same contract. A run
# KIND (a rule line for a fraction bar) would change the contract, and is
# routed to graphics (MATH-NOTATION-RULE-01) rather than cut.

#---------------------------------------------------------------------#
#  NOTATION IN A LABEL (DN10)                                          #
#---------------------------------------------------------------------#

# A LABEL MAY CARRY MATHEMATICAL NOTATION, written between dollar signs
# as TeX has written it for forty years: "the area is $a^2$" or
# "$\\alpha \\le \\beta$". Text outside the dollars is prose and is left
# exactly alone.
#
# WHAT THIS IS NOT. It is not TeX, and calling it TeX would be the kind
# of overclaim this project refuses. TeX is a typesetting system; this
# is a reader for the notation the pictures in this library actually
# need -- superscripts, subscripts, Greek letters and the common
# operators -- laid out with the font that is already measuring every
# other label. Everything outside that is REFUSED BY NAME, so an author
# who writes \\frac is told it is not here rather than shown a label
# with a stray word in it.
#
# WHY IT NEEDED NOTHING FROM THE SOLVER. A label reaches the solver as a
# BOX, and it always has. Notation changes what is inside the box and how
# tall it is; a superscript raises the ascent and a subscript lowers the
# descent, and the constraint machinery goes on holding a rectangle off
# the ink exactly as before. That is why this arrives as a slice of the
# text layer and not as a feature of the plane.
#
# A LABEL BECOMES RUNS: [ cText, nDx, nDy, nSize ], a piece of string at
# an offset from the label's own left edge and baseline, at its own size.
# The renderer draws each run; the measurer takes their union. One list,
# two consumers, no second description of the same thing.

# The symbols this reader knows, by their TeX names. A closed table: an
# unknown command is an error and never a guess, because a label that
# silently drops a word is worse than one that refuses to be drawn.
func StzNotationSymbol(pcName)
	_c_ = "" + pcName
	_a_ = [
		[ "alpha", "α" ], [ "beta", "β" ], [ "gamma", "γ" ], [ "delta", "δ" ],
		[ "epsilon", "ε" ], [ "zeta", "ζ" ], [ "eta", "η" ], [ "theta", "θ" ],
		[ "iota", "ι" ], [ "kappa", "κ" ], [ "lambda", "λ" ], [ "mu", "μ" ],
		[ "nu", "ν" ], [ "xi", "ξ" ], [ "pi", "π" ], [ "rho", "ρ" ],
		[ "sigma", "σ" ], [ "tau", "τ" ], [ "phi", "φ" ], [ "chi", "χ" ],
		[ "psi", "ψ" ], [ "omega", "ω" ],
		[ "Gamma", "Γ" ], [ "Delta", "Δ" ], [ "Theta", "Θ" ], [ "Lambda", "Λ" ],
		[ "Xi", "Ξ" ], [ "Pi", "Π" ], [ "Sigma", "Σ" ], [ "Phi", "Φ" ],
		[ "Psi", "Ψ" ], [ "Omega", "Ω" ],
		[ "le", "≤" ], [ "ge", "≥" ], [ "ne", "≠" ], [ "approx", "≈" ],
		[ "equiv", "≡" ], [ "pm", "±" ], [ "mp", "∓" ], [ "times", "×" ],
		[ "div", "÷" ], [ "cdot", "·" ], [ "to", "→" ], [ "gets", "←" ],
		[ "mapsto", "↦" ], [ "infty", "∞" ], [ "deg", "°" ], [ "sqrt", "√" ],
		[ "angle", "∠" ], [ "perp", "⊥" ], [ "parallel", "∥" ],
		[ "in", "∈" ], [ "notin", "∉" ], [ "subset", "⊂" ], [ "subseteq", "⊆" ],
		[ "cup", "∪" ], [ "cap", "∩" ], [ "emptyset", "∅" ],
		[ "sum", "∑" ], [ "prod", "∏" ], [ "int", "∫" ], [ "partial", "∂" ],
		[ "nabla", "∇" ], [ "forall", "∀" ], [ "exists", "∃" ],
		[ "prime", "′" ], [ "ldots", "…" ], [ "cong", "≅" ], [ "sim", "∼" ],
		[ "propto", "∝" ], [ "therefore", "∴" ], [ "circ", "∘" ] ]
	for _i_ = 1 to len(_a_)
		if _a_[_i_][1] = _c_  return _a_[_i_][2]  ok
	next
	return ""

# Does this label carry notation at all? A label with no dollar sign is
# prose, and takes the path it has always taken.
func StzHasNotation(pcText)
	return StzFindFirst("$", "" + pcText) > 0

# A LABEL AS RUNS, plus the box they occupy:
#   [ aRuns, nWidth, nAscent, nDescent ]
# The font is asked for every piece, so the box is measured and never
# estimated -- which is what lets a name with a superscript keep its
# clearances honestly.
func StzNotationRuns(pcText, pnSize, poFont)
	_aOut_ = []
	_c_ = "" + pcText
	_n_ = len(_c_)
	_i_ = 1
	_x_ = 0
	# outside the dollars is prose; inside is notation
	while _i_ <= _n_
		_d_ = _NtFindFrom(_c_, "$", _i_)
		if _d_ = 0
			_x_ = _NtRun(_aOut_, StzStringSection(_c_, _i_, _n_), _x_, 0, pnSize, poFont)
			_i_ = _n_ + 1
			loop
		ok
		if _d_ > _i_
			_x_ = _NtRun(_aOut_, StzStringSection(_c_, _i_, _d_ - 1), _x_, 0, pnSize, poFont)
		ok
		_e_ = _NtFindFrom(_c_, "$", _d_ + 1)
		if _e_ = 0
			stzraise("StzNotationRuns: a dollar sign opens notation and nothing closes " +
				"it in '" + pcText + "' -- notation is written between two of them.")
		ok
		if _e_ > _d_ + 1
			_x_ = _NtMath(_aOut_, StzStringSection(_c_, _d_ + 1, _e_ - 1), _x_, 0, pnSize, poFont, 1)
		ok
		_i_ = _e_ + 1
	end
	_nA_ = 0
	_nD_ = 0
	for _i_ = 1 to len(_aOut_)
		_m_ = poFont.MetricsOf(_aOut_[_i_][1], _aOut_[_i_][4])
		if _m_[1] - _aOut_[_i_][3] > _nA_  _nA_ = _m_[1] - _aOut_[_i_][3]  ok
		if _m_[2] + _aOut_[_i_][3] > _nD_  _nD_ = _m_[2] + _aOut_[_i_][3]  ok
	next
	return [ _aOut_, _x_, _nA_, _nD_ ]

# one piece of literal text, placed and measured
func _NtRun paRuns, pcText, pnX, pnDy, pnSize, poFont
	if pcText = ""  return pnX  ok
	paRuns + [ pcText, pnX, pnDy, pnSize ]
	return pnX + poFont.WidthOf(pcText, pnSize)

# NOTATION, READ ONE PIECE AT A TIME. A backslash names a symbol, a caret
# raises what follows and an underscore lowers it, braces group, and
# anything else is itself. Three levels of script are allowed and a
# fourth is refused: a label is a label.
func _NtMath paRuns, pcSrc, pnX, pnDy, pnSize, poFont, pnDepth
	if pnDepth > 3
		stzraise("StzNotationRuns: '" + pcSrc + "' stacks scripts more than three " +
			"deep -- that is an equation rather than a label.")
	ok
	_c_ = "" + pcSrc
	_n_ = len(_c_)
	_i_ = 1
	_x_ = pnX
	_lit_ = ""
	while _i_ <= _n_
		_ch_ = _c_[_i_]
		# char(92), NEVER a backslash literal. Ring collapses \ inside a
		# longer string but leaves "\\" ON ITS OWN as TWO bytes, so comparing
		# a single character to it can never be true -- the same hazard as the
		# NL and TAB constants, and the same cure.
		if _ch_ = char(92)
			_x_ = _NtRun(paRuns, _lit_, _x_, pnDy, pnSize, poFont)
			_lit_ = ""
			_j_ = _i_ + 1
			_name_ = ""
			while _j_ <= _n_ and _NtIsAlpha(_c_[_j_])
				_name_ += _c_[_j_]
				_j_++
			end
			if _name_ = ""
				stzraise("StzNotationRuns: a backslash names a symbol, and '" + pcSrc +
					"' has one naming nothing.")
			ok
			_sym_ = StzNotationSymbol(_name_)
			if _sym_ = ""
				stzraise("StzNotationRuns: this reader does not know '" + char(92) + _name_ +
					"'. It reads superscripts, subscripts, Greek letters and the " +
					"common operators, and refuses everything else by name rather " +
					"than guessing -- see StzNotationSymbol for the whole table.")
			ok
			# AND THE FONT MUST BE ABLE TO DRAW IT. A shaper answers glyph
			# id 0 for a character it has no glyph for, and drawing that
			# puts a hollow box in the picture -- which is the one outcome
			# worse than a refusal, because it looks like a decision. The
			# table maps a name to a character and is the same everywhere;
			# whether the character can be drawn belongs to the font, and
			# is checked against the font actually in use.
			if NOT _NtFontHas(poFont, _sym_, pnSize)
				stzraise("StzNotationRuns: this font has no glyph for '" + char(92) +
					_name_ + "', so drawing it would put a hollow box in the " +
					"picture. Choose a font that carries it, or write it another way.")
			ok
			_x_ = _NtRun(paRuns, _sym_, _x_, pnDy, pnSize, poFont)
			_i_ = _j_
		but _ch_ = "^" or _ch_ = "_"
			_x_ = _NtRun(paRuns, _lit_, _x_, pnDy, pnSize, poFont)
			_lit_ = ""
			_a_ = _NtArg(_c_, _i_ + 1)
			if _a_[1] = ""
				stzraise("StzNotationRuns: '" + _ch_ + "' raises or lowers what comes " +
					"after it, and nothing comes after it in '" + pcSrc + "'.")
			ok
			_sz_ = pnSize * 0.72
			_dy_ = pnDy - pnSize * 0.40
			if _ch_ = "_"  _dy_ = pnDy + pnSize * 0.20  ok
			_x_ = _NtMath(paRuns, _a_[1], _x_, _dy_, _sz_, poFont, pnDepth + 1)
			_i_ = _a_[2]
		but _ch_ = "{" or _ch_ = "}"
			stzraise("StzNotationRuns: braces group what a script raises or lowers, " +
				"and '" + pcSrc + "' has one standing on its own.")
		else
			_lit_ += _ch_
			_i_++
		ok
	end
	_x_ = _NtRun(paRuns, _lit_, _x_, pnDy, pnSize, poFont)
	return _x_

# what a script applies to: a braced group, or the single character
# after it -- TeX's own rule, and the one an author expects
func _NtArg pcSrc, pnFrom
	_n_ = len(pcSrc)
	if pnFrom > _n_  return [ "", pnFrom ]  ok
	if pcSrc[pnFrom] != "{"
		return [ pcSrc[pnFrom], pnFrom + 1 ]
	ok
	_d_ = 0
	_i_ = pnFrom
	while _i_ <= _n_
		if pcSrc[_i_] = "{"  _d_++  ok
		if pcSrc[_i_] = "}"
			_d_--
			if _d_ = 0
				return [ StzStringSection(pcSrc, pnFrom + 1, _i_ - 1), _i_ + 1 ]
			ok
		ok
		_i_++
	end
	stzraise("StzNotationRuns: a brace opens a group and nothing closes it in '" +
		pcSrc + "'.")

# a shaper answers glyph id 0 -- .notdef -- for a character the font
# does not carry
func _NtFontHas poFont, pcSym, pnSize
	_g_ = poFont.GlyphsOf(pcSym, pnSize)
	for _i_ = 1 to len(_g_)
		if _g_[_i_][1] = 0  return FALSE  ok
	next
	return len(_g_) > 0

func _NtIsAlpha pc
	_a_ = ascii(pc)
	return (_a_ >= 65 and _a_ <= 90) or (_a_ >= 97 and _a_ <= 122)

# the next occurrence at or after a position. Ring's own find has no
# from-position form, and slicing the tail to search it is the engine's
# recorded O(position) trap -- so the scan is done here, one byte at a
# time, over a label rather than over a buffer.
func _NtFindFrom pcHay, pcNeedle, pnFrom
	_n_ = len(pcHay)
	_m_ = len(pcNeedle)
	if _m_ = 0 or pnFrom > _n_  return 0  ok
	for _i_ = pnFrom to _n_ - _m_ + 1
		_b_ = TRUE
		for _k_ = 1 to _m_
			if pcHay[_i_ + _k_ - 1] != pcNeedle[_k_]  _b_ = FALSE  exit  ok
		next
		if _b_  return _i_  ok
	next
	return 0
