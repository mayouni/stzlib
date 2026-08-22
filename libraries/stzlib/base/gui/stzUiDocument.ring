#---------------------------------------------------------------------------#
#  STZUIDOCUMENT -- a .panel file: the interface AS TEXT, parsed and judged. #
#---------------------------------------------------------------------------#
#
#     oU = new stzUiDocument(cTextOrPath)
#     ? oU.IsClean()                     # the court's verdict
#     ? oU.Diagnostics()                 # ...and its findings, C2-shaped
#     oP = oU.ToPanel()                  # a laid-out stzPanel
#     ? oU.ToRml()                       # the projection, inspectable
#     ? oU.ToText()                      # the canonical print (round-trips)
#
# WHAT .panel IS (SOFTANZA_GUI_PLAN.md §4b): the plane's AUTHORED surface.
# §4 forbids hand-writing RML and StzZui forbids hand-writing meanings,
# which left nothing a person may write. This file format is that thing:
# the file is the CONTRACT, and RML (native) or HTML (web) are its
# projections. It declares the projection only -- boxes, sizes, colours --
# and never a meaning: there is no :Danger here and there never may be.
#
# IT CONFORMS TO THE GRAMMAR COMMONS (C6 v1.0, ringua/docs/commons.md):
# DEFINE <KIND> <name> ( fields ) RATIONALE "...", `--` comments,
# case-sensitive UPPER_SNAKE keywords (every compare is strcmp, never
# Ring's case-lax `=` -- the commons names that exact trap), [ a, b, c ]
# lists with trailing comma, double-quoted strings, lower_snake names.
# Four kinds, closed: PANEL (exactly one), BOX, TEXT, STYLE. The court
# carries the commons' four birth-checks: closure, reference resolution,
# duplicate declaration, round trip.
#
# THE EMITTER IS THE ARGUMENT. Its defaults absorb every divergence G1
# paid to find: explicit display on every element, the root sized to the
# panel, a font-family always declared, --rmlui-direction for rtl, every
# tag XML-closed -- and, deliberately better than raw CSS: WIDTH 210
# MEANS 210 (flex-shrink: 0 rides along; a size a person declares is a
# floor, not a basis), and WRAP yes brings align-content: flex-start.
#
# QML's ergonomics informed this; its shape did not survive contact with
# the family's law. Structure is CHILDREN [a, b, c] and EVERY BOX HAS A
# NAME -- an anonymous box is what makes accessibility and hit-testing
# retrofits instead of queries. Bindings and states are G5's, on the
# reactive layer, never on an embedded script engine.

func StzUiDocumentQ(pcTextOrPath)
	return new stzUiDocument(pcTextOrPath)

class stzUiDocument from stzObject

	@aDecls = []        # [ [ :kind, :name, :fields, :rationale, :line ], ... ]
	@aDiags = []        # C2-shaped: [ :code, :severity, :message, :line ]
	@cSource = ""
	@bParsed = FALSE
	@cFontPath = ""    # see UseFont
	@aDirMap = []      # [ [ name, "ltr"|"rtl" ], ... ] -- rebuilt per emit

	# The closed field sets -- closure is a birth-check, so these lists ARE
	# the law of v0.1. Lowercase here because field KEYWORDS are validated
	# case-sensitively during parse; these drive the per-kind check.
	# SATISFIES appears on the three ELEMENT kinds and not on STYLE. The
	# founding inversion's test is "every UI ELEMENT must trace to at
	# least one intent", and a STYLE is not an element -- it is a bag of
	# properties other declarations borrow. A style that claimed to
	# satisfy an intent would let one intent be traced through a thing
	# that never appears on screen.
	@aPanelFields = [ "SIZE", "DIRECTION", "FONT", "BACKGROUND", "CHILDREN",
		"PADDING", "GAP", "ALIGN", "JUSTIFY", "TEXT_DIRECTION", "TEXT_ALIGN",
		"ROLE", "LABEL", "SATISFIES" ]
	@aBoxFields = [ "DIRECTION", "WRAP", "WIDTH", "HEIGHT", "PADDING",
		"MARGIN", "GAP", "ALIGN", "JUSTIFY", "BACKGROUND", "CHILDREN",
		"STYLE", "TEXT_DIRECTION", "TEXT_ALIGN", "FOCUSABLE", "ROLE", "LABEL",
		"SATISFIES" ]
	@aTextFields = [ "CONTENT", "SIZE", "COLOR", "PADDING", "MARGIN",
		"STYLE", "TEXT_DIRECTION", "TEXT_ALIGN", "FOCUSABLE", "ROLE", "LABEL",
		"SATISFIES" ]
	@aStyleFields = [ "DIRECTION", "WRAP", "WIDTH", "HEIGHT", "PADDING",
		"MARGIN", "GAP", "ALIGN", "JUSTIFY", "BACKGROUND", "SIZE", "COLOR",
		"TEXT_ALIGN", "TEXT_DIRECTION", "FOCUSABLE", "ROLE", "LABEL" ]

	# THE ROLE VOCABULARY, closed, and deliberately small for v0.1.
	#
	# A role is not a MEANING and this plane still computes none: it does
	# not decide colour, emphasis or refusal, and there is no :Danger
	# here. It is the accessibility PROJECTION's own term -- the word a
	# platform API needs to say what a region is -- in the same family as
	# `display: block`, and it is what lets Softanza EMIT a tree where a
	# browser can only infer one.
	#
	# Every name here exists in ARIA and in AccessKit's 182-role schema,
	# so nothing has to be invented at the adapter. Growth is by adding a
	# name the platforms already know, never by minting one.
	@aRoles = [ "group", "heading", "label", "paragraph", "button", "link",
		"checkbox", "radio", "textbox", "list", "listitem", "image",
		"separator", "toolbar", "status", "dialog", "tablist", "tab",
		"window" ]

	def init(pcTextOrPath)
		_c_ = "" + pcTextOrPath
		if len(_c_) < 260 and StzFindFirst(char(10), _c_) = 0 and fexists(_c_)
			_c_ = read(_c_)
		ok
		@cSource = _c_
		This._Parse()
		if len(This.Errors()) = 0
			This._Court()
		ok
		# The direction map is built HERE, not inside ToRml. It was a side
		# effect of emitting at first, which made DirectionOf() answer
		# "ltr" until something had rendered -- an ordering trap for every
		# caller that only wanted to ask a question.
		_dP_ = This.PanelDecl()
		if len(_dP_) > 0
			This._MapDirection(_dP_,
				This._IdField(_dP_[:fields], "TEXT_DIRECTION", "ltr"))
		ok

	#-- the verdict ---------------------------------------------------------

	def Diagnostics()
		return @aDiags

	def Errors()
		_a_ = []
		_n_ = len(@aDiags)
		for _i_ = 1 to _n_
			if @aDiags[_i_][:severity] = "error"
				_a_ + @aDiags[_i_]
			ok
		next
		return _a_

	def IsClean()
		return len(This.Errors()) = 0

	# One line per finding, for a human at a terminal.
	def Report()
		_c_ = ""
		_n_ = len(@aDiags)
		for _i_ = 1 to _n_
			_a_ = @aDiags[_i_]
			_c_ += _a_[:severity] + " " + _a_[:code] + " (line " +
				_a_[:line] + "): " + _a_[:message] + char(10)
		next
		return _c_

	#-- inspection ----------------------------------------------------------

	def Declarations()
		return @aDecls

	def DeclOf(pcName)
		_n_ = len(@aDecls)
		for _i_ = 1 to _n_
			if strcmp(@aDecls[_i_][:name], "" + pcName) = 0
				return @aDecls[_i_]
			ok
		next
		return []

	def PanelDecl()
		_n_ = len(@aDecls)
		for _i_ = 1 to _n_
			if strcmp(@aDecls[_i_][:kind], "PANEL") = 0
				return @aDecls[_i_]
			ok
		next
		return []

	def Names()
		_a_ = []
		_n_ = len(@aDecls)
		for _i_ = 1 to _n_
			_a_ + @aDecls[_i_][:name]
		next
		return _a_

	# [ [ id, content, size, color, isRtl ], ... ] for every TEXT -- the G1
	# bridge: the font engine is a stub until G2, so a caller paints the
	# glyphs itself at BoxOf(id) with the graphics plane's own pipeline.
	# This method disappears into the emitter when G2 lands.
	def TextsToPaint()
		_a_ = []
		_n_ = len(@aDecls)
		for _i_ = 1 to _n_
			_d_ = @aDecls[_i_]
			if strcmp(_d_[:kind], "TEXT") = 0
				_aF_ = This._EffectiveFields(_d_)
				_nSz_ = This._NumField(_aF_, "SIZE", 14)
				_cCol_ = This._StrField(_aF_, "COLOR", "#e8e8e8")
				_bRtl_ = strcmp(This._IdField(_aF_, "TEXT_DIRECTION", ""), "rtl") = 0
				_a_ + [ _d_[:name], This._StrField(_aF_, "CONTENT", ""),
					_nSz_, _cCol_, _bRtl_ ]
			ok
		next
		return _a_

	#-- the canonical print (round-trip fixpoint) ---------------------------

	def ToText()
		_c_ = "-- interface.panel -- " + This._HeaderSentence() + char(10) + char(10)
		_n_ = len(@aDecls)
		for _i_ = 1 to _n_
			_d_ = @aDecls[_i_]
			_c_ += "DEFINE " + _d_[:kind] + " " + _d_[:name] + " (" + char(10)
			_aF_ = _d_[:fields]
			_nF_ = len(_aF_)
			for _j_ = 1 to _nF_
				_c_ += "  " + _aF_[_j_][1] + " " + This._PrintValue(_aF_[_j_][2])
				if _j_ < _nF_
					_c_ += ","
				ok
				_c_ += char(10)
			next
			_c_ += ') RATIONALE "' + _d_[:rationale] + '"' + char(10) + char(10)
		next
		return _c_

	def _HeaderSentence()
		_d_ = This.PanelDecl()
		if len(_d_) > 0
			return _d_[:rationale]
		ok
		return "a Softanza interface."

	def _PrintValue(pVal)
		if isNumber(pVal)
			return "" + pVal
		ok
		if isList(pVal)
			# [ :list, items ] or [ :str, s ] or [ :id, s ]
			if len(pVal) = 2 and isString(pVal[1])
				if strcmp(pVal[1], ":str") = 0
					return '"' + pVal[2] + '"'
				ok
				if strcmp(pVal[1], ":id") = 0
					return pVal[2]
				ok
				if strcmp(pVal[1], ":list") = 0
					_c_ = "["
					_aI_ = pVal[2]
					_nI_ = len(_aI_)
					for _k_ = 1 to _nI_
						if _k_ > 1
							_c_ += ", "
						ok
						_c_ += This._PrintValue(_aI_[_k_])
					next
					return _c_ + "]"
				ok
			ok
		ok
		return "" + pVal

	#-- the projection ------------------------------------------------------

	# The RML this document means. The defaults here are §4b's table: every
	# divergence G1 found is absorbed so the author never sees it.
	def ToRml()
		if NOT This.IsClean()
			StzRaise("stzUiDocument.ToRml: the document is not clean -- " +
				"ask Report() why. Refusing to project a broken contract.")
		ok
		_dP_ = This.PanelDecl()
		_aPF_ = _dP_[:fields]

		_cCss_ = ""
		# the ROOT: sized to the panel (divergence 3), a font always
		# declared (divergence 5), flex like everything else
		_cFont_ = This._StrField(_aPF_, "FONT", "default")
		_cRootDir_ = This.DirectionOf(_dP_[:name])
		_cCss_ += "body { box-sizing: border-box; display: flex; flex-direction: " +
			This._FlexFlow(This._IdField(_aPF_, "DIRECTION", "column"), _cRootDir_) +
			"; width: 100%; height: 100%; font-family: " + _cFont_ +
			"; font-size: 14px; --rmlui-direction: " + _cRootDir_ +
			"; text-align: " +
			This._ResolveAlign(This._IdField(_aPF_, "TEXT_ALIGN", "start"), _cRootDir_) + ";" +
			This._CssCommon(_aPF_, TRUE) + " }" + char(10)

		_n_ = len(@aDecls)
		for _i_ = 1 to _n_
			_d_ = @aDecls[_i_]
			if strcmp(_d_[:kind], "BOX") = 0 or strcmp(_d_[:kind], "TEXT") = 0
				_cCss_ += "#" + _d_[:name] + " { " +
					This._CssOf(_d_) + " }" + char(10)
			ok
		next

		_cBody_ = This._MarkupOf(_dP_)
		return "<rml><head><style>" + char(10) + _cCss_ +
			"</style></head><body>" + _cBody_ + "</body></rml>"

	def _MarkupOf(pDecl)
		_c_ = ""
		_aKids_ = This._ChildrenOf(pDecl)
		_nK_ = len(_aKids_)
		for _i_ = 1 to _nK_
			_dK_ = This.DeclOf(_aKids_[_i_])
			if strcmp(_dK_[:kind], "TEXT") = 0
				# XML-closed always (divergence 2); the content is the
				# element's text, entity-escaped
				_c_ += '<div id="' + _dK_[:name] + '">' +
					This._Escape(This._StrField(This._EffectiveFields(_dK_), "CONTENT", "")) +
					'</div>'
			else
				_cInner_ = This._MarkupOf(_dK_)
				if _cInner_ = ""
					_c_ += '<div id="' + _dK_[:name] + '"/>'
				else
					_c_ += '<div id="' + _dK_[:name] + '">' + _cInner_ + '</div>'
				ok
			ok
		next
		return _c_

	#-- direction, and everything that follows from it ----------------------
	#
	# ONE declaration flips a screen. `TEXT_DIRECTION rtl` on the panel
	# makes every descendant right-to-left: text right-aligns, rows read
	# right to left, and the shaper is told the base direction. A box may
	# override it for its own subtree (a Latin code block inside an Arabic
	# page), and that override inherits downward in turn.
	#
	# This is §2.3's promise -- "RTL is a parameter threaded through the
	# layout protocol, not a feature added later" -- kept in the emitter
	# because RmlUi will not keep it: its direction property touches
	# exactly one line of its layout, a dirty flag that feeds the shaper.
	# Flutter needed a dedicated PR across its core layout files for this;
	# here it is a walk over a tree that already exists.

	def _MapDirection(pDecl, pcInherited)
		_cDir_ = This._IdField(This._EffectiveFields(pDecl), "TEXT_DIRECTION", pcInherited)
		if strcmp(_cDir_, "rtl") != 0 and strcmp(_cDir_, "ltr") != 0
			_cDir_ = pcInherited
		ok
		# whether this element FLIPPED relative to its parent, which is
		# the only case where an inherited alignment would be wrong
		@aDirMap + [ pDecl[:name], _cDir_, strcmp(_cDir_, pcInherited) != 0 ]
		_aKids_ = This._ChildrenOf(pDecl)
		_nK_ = len(_aKids_)
		for _i_ = 1 to _nK_
			_dK_ = This.DeclOf(_aKids_[_i_])
			if len(_dK_) > 0
				This._MapDirection(_dK_, _cDir_)
			ok
		next

	# The direction in force for a declaration -- its own, or the nearest
	# ancestor's. Answers "ltr" for anything the panel does not reach.
	def DirectionOf(pcName)
		_n_ = len(@aDirMap)
		for _i_ = 1 to _n_
			if strcmp(@aDirMap[_i_][1], "" + pcName) = 0
				return @aDirMap[_i_][2]
			ok
		next
		return "ltr"

	def IsRtl(pcName)
		return strcmp(This.DirectionOf(pcName), "rtl") = 0

	# TRUE when this element's direction differs from its parent's.
	def _FlipsDirection(pcName)
		_n_ = len(@aDirMap)
		for _i_ = 1 to _n_
			if strcmp(@aDirMap[_i_][1], "" + pcName) = 0
				return @aDirMap[_i_][3]
			ok
		next
		return FALSE

	# start/end are DIRECTION-RELATIVE, which is the vocabulary a format
	# that takes RTL seriously should speak; RCSS only knows left/right,
	# so the resolution happens here. An author who writes TEXT_ALIGN end
	# gets the trailing edge in either direction, and never has to write
	# two stylesheets.
	def _ResolveAlign(pcAlign, pcDir)
		_bRtl_ = strcmp(pcDir, "rtl") = 0
		if strcmp(pcAlign, "start") = 0
			return iif(_bRtl_, "right", "left")
		ok
		if strcmp(pcAlign, "end") = 0
			return iif(_bRtl_, "left", "right")
		ok
		if strcmp(pcAlign, "center") = 0 or strcmp(pcAlign, "justify") = 0
			return pcAlign
		ok
		return iif(_bRtl_, "right", "left")

	# A row in an RTL subtree reads right to left. Without this a sidebar
	# declared first still sits on the left of an Arabic screen, which is
	# the layout equivalent of left-aligned Arabic text -- and it is the
	# reason TEXT_DIRECTION alone was not enough.
	def _FlexFlow(pcFlow, pcDir)
		if strcmp(pcDir, "rtl") != 0
			return pcFlow
		ok
		if strcmp(pcFlow, "row") = 0
			return "row-reverse"
		ok
		if strcmp(pcFlow, "row-reverse") = 0
			return "row"
		ok
		return pcFlow

	# The CSS of one BOX or TEXT, style bag merged, defaults applied.
	def _CssOf(pDecl)
		_aF_ = This._EffectiveFields(pDecl)
		_bBox_ = strcmp(pDecl[:kind], "BOX") = 0

		# border-box ALWAYS: an author who declares WIDTH 210 and
		# PADDING 20 means a 210-pixel region with padding inside it, the
		# way every modern toolkit reads a size. CSS's content-box default
		# would make the box 250 and nothing at the call site would say
		# why -- the first .panel screenshot had exactly that sidebar.
		_c_ = "box-sizing: border-box; "

		_cDir_ = This.DirectionOf(pDecl[:name])
		# the shaper's base-direction hint (divergence 1: RCSS rejects the
		# CSS spelling). It reaches the font engine and NOTHING else --
		# every visible RTL consequence below is the emitter's.
		_c_ += "--rmlui-direction: " + _cDir_ + "; "

		# explicit display ALWAYS (divergence 4): a BOX with children is a
		# flex container; everything else is block. A row in an RTL subtree
		# becomes row-reverse, or a sidebar declared first still sits on
		# the left of an Arabic screen.
		if _bBox_ and len(This._ChildrenOf(pDecl)) > 0
			_c_ += "display: flex; flex-direction: " +
				This._FlexFlow(This._IdField(_aF_, "DIRECTION", "column"), _cDir_) + ";"
		else
			_c_ += "display: block;"
		ok

		# Alignment is emitted ONLY where it is decided, and inherits
		# everywhere else. Emitting it on every element instead looked
		# harmless and silently broke the ordinary case: a TEXT_ALIGN on
		# a CARD did nothing, because the text inside it carried its own
		# resolved `left` and overrode the parent. Three tiles side by
		# side made it obvious; no assertion had.
		#
		# Two cases decide it. The element declares TEXT_ALIGN -- then it
		# means it. Or the element FLIPS direction relative to its parent
		# -- then an inherited `left` would survive a flip to rtl and put
		# Arabic on the wrong edge.
		if len(This._RawField(_aF_, "TEXT_ALIGN")) > 0 or This._FlipsDirection(pDecl[:name])
			_c_ += " text-align: " +
				This._ResolveAlign(This._IdField(_aF_, "TEXT_ALIGN", "start"), _cDir_) + ";"
		ok

		# FOCUSABLE puts the box in the tab ring AND under the arrow keys.
		#
		# RCSS spells the first `tab-index: auto`, which reads as
		# "wherever the engine likes" and means the opposite -- it is the
		# opt in. The second is `nav: auto`, and it defaults to NONE, so
		# arrow keys do nothing at all until it is set. An author who
		# declares a thing focusable means both: the WAI-ARIA APG
		# contract this plane adopted is one tab stop per composite with
		# ARROWS WITHIN, and half of that silently absent is exactly the
		# kind of gap Rule 80 exists to forbid.
		if strcmp(This._IdField(_aF_, "FOCUSABLE", "no"), "yes") = 0
			_c_ += " tab-index: auto; nav: auto;"
		ok

		# sizes: a number MEANS the number (flex-shrink: 0 rides along);
		# "n%" passes through; `fill` grows into the leftover
		_c_ += This._CssSize(_aF_, "WIDTH", "width")
		_c_ += This._CssSize(_aF_, "HEIGHT", "height")
		_vW_ = This._RawField(_aF_, "WIDTH")
		_vH_ = This._RawField(_aF_, "HEIGHT")
		if (len(_vW_) > 0 and isNumber(_vW_[2])) or
		   (len(_vH_) > 0 and isNumber(_vH_[2]))
			_c_ += " flex-shrink: 0;"
		ok

		if _bBox_ and strcmp(This._IdField(_aF_, "WRAP", "no"), "yes") = 0
			# align-content rides along, or wrapped lines spread down the
			# whole container -- the showcase bug, defaulted away
			_c_ += " flex-wrap: wrap; align-content: flex-start;"
		ok

		_c_ += This._CssCommon(_aF_, _bBox_)

		if NOT _bBox_
			_nSz_ = This._NumField(_aF_, "SIZE", 0)
			if _nSz_ > 0
				_c_ += " font-size: " + _nSz_ + "px;"
			ok
			_cCol_ = This._StrField(_aF_, "COLOR", "")
			if _cCol_ != ""
				_c_ += " color: " + _cCol_ + ";"
			ok
		ok
		return _c_

	# Fields shared by boxes, texts and the root.
	def _CssCommon(paFields, pbBox)
		_c_ = ""
		_cBg_ = This._StrField(paFields, "BACKGROUND", "")
		if _cBg_ != ""
			_c_ += " background: " + _cBg_ + ";"
		ok
		_nPad_ = This._NumField(paFields, "PADDING", -1)
		if _nPad_ >= 0
			_c_ += " padding: " + _nPad_ + "px;"
		ok
		_nMar_ = This._NumField(paFields, "MARGIN", -1)
		if _nMar_ >= 0
			_c_ += " margin: " + _nMar_ + "px;"
		ok
		_nGap_ = This._NumField(paFields, "GAP", -1)
		if _nGap_ >= 0
			_c_ += " gap: " + _nGap_ + "px;"
		ok
		_cAl_ = This._IdField(paFields, "ALIGN", "")
		if _cAl_ != ""
			_c_ += " align-items: " + This._FlexWord(_cAl_) + ";"
		ok
		_cJu_ = This._IdField(paFields, "JUSTIFY", "")
		if _cJu_ != ""
			_c_ += " justify-content: " + This._FlexWord(_cJu_) + ";"
		ok
		return _c_

	def _FlexWord(pcWord)
		if strcmp(pcWord, "start") = 0
			return "flex-start"
		ok
		if strcmp(pcWord, "end") = 0
			return "flex-end"
		ok
		if strcmp(pcWord, "between") = 0
			return "space-between"
		ok
		return pcWord     # center passes through

	def _CssSize(paFields, pcField, pcCss)
		_v_ = This._RawField(paFields, pcField)
		if len(_v_) = 0
			return ""
		ok
		_val_ = _v_[2]
		if isNumber(_val_)
			# a declared px size is a FLOOR, not a basis; the caller adds
			# flex-shrink: 0 when it sees a numeric size
			return " " + pcCss + ": " + _val_ + "px;"
		ok
		if isList(_val_) and strcmp(_val_[1], ":str") = 0
			return " " + pcCss + ": " + _val_[2] + ";"
		ok
		if isList(_val_) and strcmp(_val_[1], ":id") = 0 and strcmp(_val_[2], "fill") = 0
			return " flex: 1 1 auto;"
		ok
		return ""

	def _Escape(pcText)
		_c_ = StzReplace(pcText, "&", "&amp;")
		_c_ = StzReplace(_c_, "<", "&lt;")
		_c_ = StzReplace(_c_, ">", "&gt;")
		return _c_

	#-- to a living panel ---------------------------------------------------

	# Bind the family a document's FONT field names to real bytes. Called
	# before ToPanel so the layout is measured with the glyphs it will be
	# painted with -- which is G2's whole point.
	def UseFont(pcPathOrBytes)
		@cFontPath = "" + pcPathOrBytes

	def UseFontQ(pcPathOrBytes)
		This.UseFont(pcPathOrBytes)
		return This

	def FontFamily()
		_d_ = This.PanelDecl()
		if len(_d_) = 0
			return "app"
		ok
		return This._StrField(_d_[:fields], "FONT", "app")

	# Does this document declare anything to READ? A panel of boxes does
	# not need a font; a panel with a single label does.
	def _HasText()
		_n_ = len(@aDecls)
		for _i_ = 1 to _n_
			if strcmp(@aDecls[_i_][:kind], "TEXT") = 0
				return TRUE
			ok
		next
		return FALSE

	def ToPanel()
		if NOT This.IsClean()
			StzRaise("stzUiDocument.ToPanel: the document is not clean -- " +
				"ask Report() why.")
		ok
		_dP_ = This.PanelDecl()
		_aSz_ = This._RawField(_dP_[:fields], "SIZE")
		_nW_ = 800
		_nH_ = 600
		if len(_aSz_) > 0 and isList(_aSz_[2]) and strcmp(_aSz_[2][1], ":list") = 0
			_aI_ = _aSz_[2][2]
			if len(_aI_) = 2
				_nW_ = _aI_[1]
				_nH_ = _aI_[2]
			ok
		ok
		_oP_ = new stzPanel(_nW_, _nH_)
		# the face FIRST: RmlUi measures during LoadMarkup, so a font
		# registered afterwards would lay the document out on stub widths
		# and then paint it with real glyphs -- the one mismatch this
		# phase exists to make impossible
		# A DECLARED FONT WITH NO FONT FILE IS REFUSED, because the
		# alternative is a screen with no words on it and no error
		# anywhere. RmlUi lays out NO TEXT AT ALL when the family it was
		# told to use was never registered -- divergence 5 in §3 -- so
		# every label silently disappears while the boxes render
		# perfectly.
		#
		# It cost the author a screenshot to find: the showcase viewer
		# called UseFont on the document it started with, and its RELOAD
		# path built a new document without one. Press R, and the
		# interface lost its words.
		#
		# The panel's own `TextIsWhole` invariant cannot see this. It
		# asserts that every string MEASURED became a mesh, and here
		# nothing is measured at all -- 0 equals 0. An invariant about
		# what happened to the work is blind to the work never being
		# asked for, which is worth remembering the next time one is
		# written.
		# ...and ONLY when the document actually has words. A screen of
		# plain boxes needs no font, and refusing one would be the
		# over-broad kind of check that teaches people to route around
		# the court. The condition is "this document declares TEXT and
		# was given nothing to draw it with".
		if @cFontPath = "" and This.FontFamily() != "" and This._HasText()
			StzRaise("stzUiDocument.ToPanel: this document declares " +
				"FONT " + char(34) + This.FontFamily() + char(34) +
				" but no font file was given. Call UseFont(path) BEFORE " +
				"ToPanel() -- RmlUi measures during load, and a family " +
				"it cannot resolve lays out no text at all, which would " +
				"give you a screen of empty boxes and no error.")
		ok
		if @cFontPath != ""
			_oP_.UseFont(This.FontFamily(), @cFontPath)
		ok
		_oP_.LoadMarkup(This.ToRml())
		_oP_.Layout()
		return _oP_

	#-- the parser ----------------------------------------------------------
	#
	# Token-based over BYTES: every structural character is ASCII, so
	# multibyte content inside strings passes through untouched.

	def _Parse()
		@aDecls = []
		@aDiags = []
		@bParsed = TRUE
		_aT_ = This._Tokenize()
		if _aT_ = NULL
			return          # tokenizer already filed its diagnostic
		ok
		_n_ = len(_aT_)
		_i_ = 1
		while _i_ <= _n_
			# closure: exactly one verb at top level
			if NOT This._IsTok(_aT_[_i_], "DEFINE")
				This._Err("UNKNOWN_DECLARATION", _aT_[_i_][3],
					"Expected DEFINE, got '" + _aT_[_i_][2] + "'. The verb " +
					"set is closed -- a .panel file declares and does nothing else.")
				return
			ok
			_i_++
			if _i_ > _n_ or _aT_[_i_][1] != "id"
				This._Err("UNKNOWN_DECLARATION", This._LineAt(_aT_, _i_),
					"DEFINE needs a KIND (PANEL, BOX, TEXT or STYLE).")
				return
			ok
			_cKind_ = _aT_[_i_][2]
			if NOT (strcmp(_cKind_, "PANEL") = 0 or strcmp(_cKind_, "BOX") = 0 or
			        strcmp(_cKind_, "TEXT") = 0 or strcmp(_cKind_, "STYLE") = 0)
				This._Err("UNKNOWN_DECLARATION", _aT_[_i_][3],
					"Unknown kind '" + _cKind_ + "'. The kinds are closed: " +
					"PANEL, BOX, TEXT, STYLE.")
				return
			ok
			_i_++
			if _i_ > _n_ or _aT_[_i_][1] != "id"
				This._Err("MISSING_NAME", This._LineAt(_aT_, _i_),
					"DEFINE " + _cKind_ + " needs a lower_snake name.")
				return
			ok
			_cName_ = _aT_[_i_][2]
			_nLine_ = _aT_[_i_][3]
			_i_++
			if _i_ > _n_ or _aT_[_i_][1] != "("
				This._Err("MISSING_FIELDS", _nLine_,
					"DEFINE " + _cKind_ + " " + _cName_ + " needs ( fields ).")
				return
			ok
			_i_++
			_aFields_ = []
			while _i_ <= _n_ and _aT_[_i_][1] != ")"
				if _aT_[_i_][1] != "id"
					This._Err("BAD_FIELD", _aT_[_i_][3],
						"Expected a field keyword, got '" + _aT_[_i_][2] + "'.")
					return
				ok
				_cF_ = _aT_[_i_][2]
				_nFLine_ = _aT_[_i_][3]
				_i_++
				# Ring passes scalars by value, so the parser hands back
				# [ value, nextIndex ] instead of mutating an index param
				_r_ = This._ParseValue(_aT_, _i_)
				if _r_ = NULL
					This._Err("BAD_VALUE", _nFLine_,
						"Field " + _cF_ + " has no readable value.")
					return
				ok
				_i_ = _r_[2]
				_aFields_ + [ _cF_, _r_[1], _nFLine_ ]
				if _i_ <= _n_ and _aT_[_i_][1] = ","
					_i_++
				ok
			end
			if _i_ > _n_
				This._Err("MISSING_FIELDS", _nLine_,
					"DEFINE " + _cKind_ + " " + _cName_ + " never closes its ( .")
				return
			ok
			_i_++    # past )
			# RATIONALE -- mandatory, the commons' one legislated element
			_cR_ = ""
			if _i_ <= _n_ and This._IsTok(_aT_[_i_], "RATIONALE")
				_i_++
				if _i_ <= _n_ and _aT_[_i_][1] = "str"
					_cR_ = _aT_[_i_][2]
					_i_++
				ok
			ok
			if _cR_ = ""
				This._Err("MISSING_RATIONALE", _nLine_,
					"DEFINE " + _cKind_ + " " + _cName_ + " carries no " +
					'RATIONALE "..." -- every declaration says why it exists.')
			ok
			@aDecls + [ :kind = _cKind_, :name = _cName_, :fields = _aFields_,
				:rationale = _cR_, :line = _nLine_ ]
		end

	# value := number | string | identifier | [ value, ... ]
	# Answers [ parsedValue, nextIndex ] or NULL; parsedValue is a number,
	# [":str", s], [":id", s] or [":list", items]. The wrapper exists
	# because Ring passes scalars by value: the caller needs the index back.
	def _ParseValue(paT, pnI)
		_n_ = len(paT)
		if pnI > _n_
			return NULL
		ok
		_t_ = paT[pnI]
		if _t_[1] = "num"
			return [ 0 + _t_[2], pnI + 1 ]
		ok
		if _t_[1] = "str"
			return [ [ ":str", _t_[2] ], pnI + 1 ]
		ok
		if _t_[1] = "id"
			return [ [ ":id", _t_[2] ], pnI + 1 ]
		ok
		if _t_[1] = "["
			pnI++
			_aItems_ = []
			while pnI <= _n_ and paT[pnI][1] != "]"
				_r_ = This._ParseValue(paT, pnI)
				if _r_ = NULL
					return NULL
				ok
				_aItems_ + _r_[1]
				pnI = _r_[2]
				if pnI <= _n_ and paT[pnI][1] = ","
					pnI++
				ok
			end
			if pnI > _n_
				return NULL
			ok
			return [ [ ":list", _aItems_ ], pnI + 1 ]
		ok
		return NULL

	# tokens: [ type, text, line ] with type in num/str/id/( )/[ ]/,
	def _Tokenize()
		_aT_ = []
		_c_ = @cSource
		_n_ = len(_c_)
		_i_ = 1
		_nLine_ = 1
		while _i_ <= _n_
			_ch_ = substr(_c_, _i_, 1)
			_nA_ = ascii(_ch_)
			if _ch_ = char(10)
				_nLine_++
				_i_++
				loop
			ok
			if _ch_ = " " or _ch_ = char(9) or _ch_ = char(13)
				_i_++
				loop
			ok
			# -- comment to end of line
			if _ch_ = "-" and _i_ < _n_ and substr(_c_, _i_ + 1, 1) = "-"
				while _i_ <= _n_ and substr(_c_, _i_, 1) != char(10)
					_i_++
				end
				loop
			ok
			if _ch_ = '"'
				_nStart_ = _i_ + 1
				_i_++
				while _i_ <= _n_ and substr(_c_, _i_, 1) != '"'
					if substr(_c_, _i_, 1) = char(10)
						_nLine_++
					ok
					_i_++
				end
				if _i_ > _n_
					This._Err("BAD_STRING", _nLine_, "A string never closes.")
					return NULL
				ok
				_aT_ + [ "str", substr(_c_, _nStart_, _i_ - _nStart_), _nLine_ ]
				_i_++
				loop
			ok
			if _ch_ = "(" or _ch_ = ")" or _ch_ = "[" or _ch_ = "]" or _ch_ = ","
				_aT_ + [ _ch_, _ch_, _nLine_ ]
				_i_++
				loop
			ok
			# number (with optional leading - and decimal point)
			if (_nA_ >= 48 and _nA_ <= 57) or
			   (_ch_ = "-" and _i_ < _n_ and ascii(substr(_c_, _i_ + 1, 1)) >= 48 and
			    ascii(substr(_c_, _i_ + 1, 1)) <= 57)
				_nStart_ = _i_
				_i_++
				while _i_ <= _n_
					_nB_ = ascii(substr(_c_, _i_, 1))
					if (_nB_ >= 48 and _nB_ <= 57) or _nB_ = 46
						_i_++
					else
						exit
					ok
				end
				_aT_ + [ "num", substr(_c_, _nStart_, _i_ - _nStart_), _nLine_ ]
				loop
			ok
			# identifier / keyword: letters, digits, _
			if (_nA_ >= 65 and _nA_ <= 90) or (_nA_ >= 97 and _nA_ <= 122) or _ch_ = "_"
				_nStart_ = _i_
				_i_++
				while _i_ <= _n_
					_nB_ = ascii(substr(_c_, _i_, 1))
					if (_nB_ >= 65 and _nB_ <= 90) or (_nB_ >= 97 and _nB_ <= 122) or
					   (_nB_ >= 48 and _nB_ <= 57) or _nB_ = 95
						_i_++
					else
						exit
					ok
				end
				_aT_ + [ "id", substr(_c_, _nStart_, _i_ - _nStart_), _nLine_ ]
				loop
			ok
			This._Err("BAD_CHARACTER", _nLine_,
				"Character '" + _ch_ + "' has no place in .panel.")
			return NULL
		end
		return _aT_

	def _IsTok(paTok, pcWord)
		return paTok[1] = "id" and strcmp(paTok[2], pcWord) = 0

	def _LineAt(paT, pnI)
		if pnI <= len(paT)
			return paT[pnI][3]
		ok
		if len(paT) > 0
			return paT[len(paT)][3]
		ok
		return 0

	#-- the court -----------------------------------------------------------

	def _Court()
		# exactly one PANEL
		_nPanels_ = 0
		_n_ = len(@aDecls)
		for _i_ = 1 to _n_
			if strcmp(@aDecls[_i_][:kind], "PANEL") = 0
				_nPanels_++
			ok
		next
		if _nPanels_ = 0
			This._Err("NO_PANEL", 0, "A .panel file declares exactly one " +
				"PANEL; this one declares none.")
		ok
		if _nPanels_ > 1
			This._Err("MANY_PANELS", 0, "A .panel file declares exactly one " +
				"PANEL; this one declares " + _nPanels_ + ".")
		ok

		# duplicate declarations
		for _i_ = 1 to _n_
			for _j_ = _i_ + 1 to _n_
				if strcmp(@aDecls[_i_][:name], @aDecls[_j_][:name]) = 0
					This._Err("DUPLICATE_DECLARATION", @aDecls[_j_][:line],
						"'" + @aDecls[_j_][:name] + "' is declared twice " +
						"(first at line " + @aDecls[_i_][:line] + ").")
				ok
			next
		next

		# per-kind closed field sets + reference resolution
		for _i_ = 1 to _n_
			_d_ = @aDecls[_i_]
			_aAllowed_ = This._AllowedFields(_d_[:kind])
			_aF_ = _d_[:fields]
			_nF_ = len(_aF_)
			for _j_ = 1 to _nF_
				_bKnown_ = FALSE
				_nA_ = len(_aAllowed_)
				for _k_ = 1 to _nA_
					if strcmp(_aF_[_j_][1], _aAllowed_[_k_]) = 0
						_bKnown_ = TRUE
					ok
				next
				if NOT _bKnown_
					This._Err("UNKNOWN_FIELD", _aF_[_j_][3],
						_d_[:kind] + " " + _d_[:name] + " has no field '" +
						_aF_[_j_][1] + "'. The field set is closed.")
				ok
			next

			# ROLE comes from the closed vocabulary. An unknown role is
			# an error rather than a pass-through: a platform adapter
			# cannot map a word nobody has ever defined, and a screen
			# reader saying nothing is worse than one saying "group".
			_vR_ = This._RawField(_aF_, "ROLE")
			if len(_vR_) > 0
				_cR_ = This._IdField(_aF_, "ROLE", "")
				_bKnownRole_ = FALSE
				_nR_ = len(@aRoles)
				for _k_ = 1 to _nR_
					if strcmp(_cR_, @aRoles[_k_]) = 0
						_bKnownRole_ = TRUE
					ok
				next
				if NOT _bKnownRole_
					This._Err("UNKNOWN_ROLE", _d_[:line],
						_d_[:name] + " declares ROLE '" + _cR_ + "', which " +
						"is not in the closed vocabulary. A platform adapter " +
						"cannot map a role nobody has defined.")
				ok
			ok

			# A LITERAL COLOUR IS A MEANING THAT ESCAPED, and this is the
			# plane's first WARNING rather than an error: it is accepted,
			# recorded, and refused at G6.
			#
			# StzZui filed this, and its reason is a thing this project
			# has already watched happen: Rule 118, Rule 3 and the
			# graphics engine independently derived the same five
			# semantic values and drifted into three incompatible
			# spellings, because the engine shipped before the law had a
			# seam to bind to. `stzDiagramColor.ring:45` still hard-codes
			# :Success = "green" and :Danger = "red" -- the pair that
			# INVERTS in Chinese, Japanese, Korean and Taiwanese
			# financial convention.
			#
			# Every hex literal written between now and G6 is a meaning
			# with no record of what it meant, and someone has to guess
			# it back later. Warning now costs one check; the corpus
			# grows with a marked trail instead of a silent one.
			#
			# THE SHOWCASE RAISES ABOUT TWENTY OF THESE. That is the
			# check working, not misfiring.
			This._ColourWarn(_d_, _aF_, "COLOR")
			This._ColourWarn(_d_, _aF_, "BACKGROUND")

			# CHILDREN names resolve, and never to a STYLE or the PANEL
			_aKids_ = This._ChildrenOf(_d_)
			_nK_ = len(_aKids_)
			for _j_ = 1 to _nK_
				_dK_ = This.DeclOf(_aKids_[_j_])
				if len(_dK_) = 0
					This._Err("DANGLING_REFERENCE", _d_[:line],
						_d_[:name] + " lists child '" + _aKids_[_j_] +
						"', which is declared nowhere.")
				but strcmp(_dK_[:kind], "STYLE") = 0 or strcmp(_dK_[:kind], "PANEL") = 0
					This._Err("DANGLING_REFERENCE", _d_[:line],
						_d_[:name] + " lists '" + _aKids_[_j_] + "' as a " +
						"child, but it is a " + _dK_[:kind] + ".")
				ok
			next

			# STYLE references resolve to a STYLE
			_v_ = This._RawField(_aF_, "STYLE")
			if len(_v_) > 0 and isList(_v_[2]) and strcmp(_v_[2][1], ":id") = 0
				_dS_ = This.DeclOf(_v_[2][2])
				if len(_dS_) = 0 or strcmp(_dS_[:kind], "STYLE") != 0
					This._Err("DANGLING_REFERENCE", _d_[:line],
						_d_[:name] + " wears STYLE '" + _v_[2][2] +
						"', which is not a declared STYLE.")
				ok
			ok
		next

		# one parent per box, and no orphans among BOX/TEXT
		_aSeen_ = []
		for _i_ = 1 to _n_
			_aKids_ = This._ChildrenOf(@aDecls[_i_])
			_nK_ = len(_aKids_)
			for _j_ = 1 to _nK_
				_nS_ = len(_aSeen_)
				for _k_ = 1 to _nS_
					if strcmp(_aSeen_[_k_], _aKids_[_j_]) = 0
						This._Err("MANY_PARENTS", @aDecls[_i_][:line],
							"'" + _aKids_[_j_] + "' is a child of two parents; " +
							"a box lives in one place.")
					ok
				next
				_aSeen_ + _aKids_[_j_]
			next
		next
		for _i_ = 1 to _n_
			_d_ = @aDecls[_i_]
			if strcmp(_d_[:kind], "BOX") = 0 or strcmp(_d_[:kind], "TEXT") = 0
				_bHasParent_ = FALSE
				_nS_ = len(_aSeen_)
				for _k_ = 1 to _nS_
					if strcmp(_aSeen_[_k_], _d_[:name]) = 0
						_bHasParent_ = TRUE
					ok
				next
				if NOT _bHasParent_
					This._Err("ORPHAN", _d_[:line],
						_d_[:name] + " is declared but no CHILDREN list " +
						"places it anywhere.")
				ok
			ok
		next

		# no cycles: walk down from the panel; a name seen on the way down
		# refusing is cheaper than a stack overflow at emit time
		_dP_ = This.PanelDecl()
		if len(_dP_) > 0
			This._WalkForCycles(_dP_, [])
		ok

	def _WalkForCycles(pDecl, paTrail)
		_nT_ = len(paTrail)
		for _i_ = 1 to _nT_
			if strcmp(paTrail[_i_], pDecl[:name]) = 0
				This._Err("CHILD_CYCLE", pDecl[:line],
					"'" + pDecl[:name] + "' contains itself through its children.")
				return
			ok
		next
		_aTrail_ = []
		for _i_ = 1 to _nT_
			_aTrail_ + paTrail[_i_]
		next
		_aTrail_ + pDecl[:name]
		_aKids_ = This._ChildrenOf(pDecl)
		_nK_ = len(_aKids_)
		for _i_ = 1 to _nK_
			_dK_ = This.DeclOf(_aKids_[_i_])
			if len(_dK_) > 0
				This._WalkForCycles(_dK_, _aTrail_)
			ok
		next

	# The closed role vocabulary, for a caller that wants to offer it.
	def Roles()
		return @aRoles

	#-- the intent slot: parsed, recorded, DELIBERATELY UNRESOLVED --------
	#
	# StzZui's finding 2. The founding inversion says every UI element
	# must trace to at least one intent, and until a phase binds a panel
	# to a flow, every element in every file is an orphan by that test.
	# The request was not to build the binding -- it was to let the FIELD
	# EXIST NOW, so a file written this month is complete when the
	# binding lands rather than needing a pass over every declaration.
	#
	# THE FINDING OFFERED A CHEAPER ANSWER AND IT DOES NOT APPLY. It said
	# to look at Roles() first, because if that were already an intent
	# concept the slot belonged beside it. It is not: Roles() is a closed
	# ARIA vocabulary whose own comment says "a role is NOT a meaning" --
	# it is the accessibility projection's term, in the family of
	# `display: block`. An intent is the opposite kind of thing. So the
	# finding's own proposal is what is built.
	#
	# NOTHING IS RESOLVED. There is no .zui to resolve against from here,
	# and resolution stays StzZui's. The court checks the SHAPE of a name
	# and nothing else -- an intent this plane cannot find is not an
	# error, because this plane is not where intents live.
	#
	# AND NO WARNING ON AN ORPHAN. Every existing document would raise on
	# every element, which is noise rather than a trail, and the finding
	# did not ask for one. `Orphans()` answers the question instead, so
	# the inversion's test is available the moment anyone wants it.

	# The intents one declaration claims to satisfy, [] when it claims
	# none.
	def IntentsOf(pcName)
		_d_ = This.DeclOf(pcName)
		if len(_d_) = 0
			return []
		ok
		return This._IdListField(_d_[:fields], "SATISFIES")

	# Every intent named anywhere in the document, in first-seen order.
	# What a later binding phase reads to know what to look for.
	def SatisfiedIntents()
		_a_ = []
		_n_ = len(@aDecls)
		for _i_ = 1 to _n_
			_aI_ = This._IdListField(@aDecls[_i_][:fields], "SATISFIES")
			_nI_ = len(_aI_)
			for _j_ = 1 to _nI_
				if NOT This._HasName(_a_, _aI_[_j_])
					_a_ + _aI_[_j_]
				ok
			next
		next
		return _a_

	# The ELEMENTS that trace to no intent -- the founding inversion's own
	# test, answerable now and without resolving anything. STYLE
	# declarations are absent by construction, not by omission.
	def Orphans()
		_a_ = []
		_n_ = len(@aDecls)
		for _i_ = 1 to _n_
			_d_ = @aDecls[_i_]
			if strcmp(_d_[:kind], "STYLE") = 0
				loop
			ok
			if len(This._IdListField(_d_[:fields], "SATISFIES")) = 0
				_a_ + _d_[:name]
			ok
		next
		return _a_

	def TracesToIntent(pcName)
		return len(This.IntentsOf(pcName)) > 0

	def _AllowedFields(pcKind)
		if strcmp(pcKind, "PANEL") = 0
			return @aPanelFields
		ok
		if strcmp(pcKind, "BOX") = 0
			return @aBoxFields
		ok
		if strcmp(pcKind, "TEXT") = 0
			return @aTextFields
		ok
		return @aStyleFields

	#-- field access --------------------------------------------------------

	def _RawField(paFields, pcName)
		_n_ = len(paFields)
		for _i_ = 1 to _n_
			if strcmp(paFields[_i_][1], pcName) = 0
				return paFields[_i_]
			ok
		next
		return []

	# fields with the STYLE bag folded in, local fields winning
	def _EffectiveFields(pDecl)
		_aF_ = pDecl[:fields]
		_v_ = This._RawField(_aF_, "STYLE")
		if len(_v_) = 0 or NOT isList(_v_[2]) or strcmp(_v_[2][1], ":id") != 0
			return _aF_
		ok
		_dS_ = This.DeclOf(_v_[2][2])
		if len(_dS_) = 0
			return _aF_
		ok
		_aOut_ = []
		_aSF_ = _dS_[:fields]
		_nS_ = len(_aSF_)
		for _i_ = 1 to _nS_
			if len(This._RawField(_aF_, _aSF_[_i_][1])) = 0
				_aOut_ + _aSF_[_i_]
			ok
		next
		_nF_ = len(_aF_)
		for _i_ = 1 to _nF_
			_aOut_ + _aF_[_i_]
		next
		return _aOut_

	def _NumField(paFields, pcName, pnDefault)
		_v_ = This._RawField(paFields, pcName)
		if len(_v_) > 0 and isNumber(_v_[2])
			return _v_[2]
		ok
		return pnDefault

	def _StrField(paFields, pcName, pcDefault)
		_v_ = This._RawField(paFields, pcName)
		if len(_v_) > 0 and isList(_v_[2]) and strcmp(_v_[2][1], ":str") = 0
			return _v_[2][2]
		ok
		return pcDefault

	def _IdField(paFields, pcName, pcDefault)
		_v_ = This._RawField(paFields, pcName)
		if len(_v_) > 0 and isList(_v_[2]) and strcmp(_v_[2][1], ":id") = 0
			return _v_[2][2]
		ok
		return pcDefault

	def _ChildrenOf(pDecl)
		_v_ = This._RawField(pDecl[:fields], "CHILDREN")
		_a_ = []
		if len(_v_) > 0 and isList(_v_[2]) and strcmp(_v_[2][1], ":list") = 0
			_aI_ = _v_[2][2]
			_nI_ = len(_aI_)
			for _i_ = 1 to _nI_
				if isList(_aI_[_i_]) and strcmp(_aI_[_i_][1], ":id") = 0
					_a_ + _aI_[_i_][2]
				ok
			next
		ok
		return _a_

	# A list of identifiers, or a SINGLE identifier read as a list of one.
	# Both forms are accepted because `SATISFIES transfer_funds` is what a
	# person writes for the common case, and forcing brackets round one
	# name is the kind of ceremony that makes a format tiring.
	def _IdListField(paFields, pcName)
		_v_ = This._RawField(paFields, pcName)
		_a_ = []
		if len(_v_) = 0
			return _a_
		ok
		if isList(_v_[2]) and strcmp(_v_[2][1], ":list") = 0
			_aI_ = _v_[2][2]
			_nI_ = len(_aI_)
			for _i_ = 1 to _nI_
				if isList(_aI_[_i_]) and strcmp(_aI_[_i_][1], ":id") = 0
					_a_ + _aI_[_i_][2]
				ok
			next
		but isList(_v_[2]) and strcmp(_v_[2][1], ":id") = 0
			_a_ + _v_[2][2]
		ok
		return _a_

	def _HasName(paList, pcItem)
		_n_ = len(paList)
		for _i_ = 1 to _n_
			if paList[_i_] = pcItem
				return TRUE
			ok
		next
		return FALSE

	def _Err(pcCode, pnLine, pcMsg)
		@aDiags + [ :code = pcCode, :severity = "error", :message = pcMsg,
			:line = pnLine, :cites = [], :language = "panel" ]

	# One colour field of one declaration. Split out because two fields
	# ask the same question and a court that repeats itself drifts.
	def _ColourWarn(pDecl, paFields, pcField)
		_v_ = This._RawField(paFields, pcField)
		if len(_v_) = 0
			return
		ok
		_c_ = This._StrField(paFields, pcField, "")
		if len(_c_) = 0 or _c_[1] != "#"
			return
		ok
		This._Warn("LITERAL_COLOUR", pDecl[:line],
			pDecl[:name] + " declares " + pcField + " " + _c_ +
			", a colour that names no meaning. Accepted for now and " +
			"refused at G6: a hex value carries no record of what it " +
			"meant, so the meaning has to be guessed back later.")

	# THE PLANE'S FIRST WARNING, and the distinction is the point. An
	# error refuses to project; a warning records and lets the document
	# through. The C2 envelope already carried `severity`, so this needed
	# no new shape -- only the first thing worth saying that is not a
	# refusal.
	def _Warn(pcCode, pnLine, pcMsg)
		@aDiags + [ :code = pcCode, :severity = "warning", :message = pcMsg,
			:line = pnLine, :cites = [], :language = "panel" ]
