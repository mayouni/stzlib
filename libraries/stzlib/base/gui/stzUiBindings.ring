#---------------------------------------------------------------------------#
#  STZUIBINDINGS -- a declared value changes, and the screen follows.        #
#---------------------------------------------------------------------------#
#
#     DEFINE TEXT readout ( CONTENT "BEARING {bearing}   RANGE {range} km" )
#
#     oB = new stzUiBindings(oDoc, oPanel)
#     oB.Set(:bearing, "042.9")          # the screen changes here
#     oB.SetMany([ :bearing = "137.4", :range = "8.20" ])
#
# G5 of SOFTANZA_GUI_PLAN.md, second clause. The first clause -- Softanza
# declarations to RML/RCSS -- shipped early, with G1, because §4 had left
# nothing a person may write. This is what remained: the binding.
#
# WHY A PLACEHOLDER IN A STRING, and not a new kind of value. The Grammar
# Commons fixes what a field value may BE -- a string, a number, an
# identifier, a list -- and `CONTENT @bearing` would mint a fifth kind for
# one plane's convenience. `"{bearing}"` is an ordinary string, so the
# format is unchanged, every existing document still parses, and the
# court's round-trip fixpoint still holds. QML and every template language
# reached the same place.
#
# WHAT THIS REPLACES, and both said so in their own comments: an app that
# reacted used to build a WHOLE NEW DOCUMENT -- `stzScenePanel.Shows` for
# the in-scene tier, the showcase viewer's reload for the desktop one.
#
# WHAT A BINDING ACTUALLY BUYS, measured rather than assumed, because the
# obvious claim turned out to be false:
#
#   IT IS NOT FEWER SHAPED STRINGS. Changing one label of six re-shapes
#   all six, whichever engine call is used, because that is RmlUi's
#   invalidation granularity: a text change dirties the document. Style
#   changes ARE surgical -- a colour re-shapes one string, a background
#   none -- and the guard measures all three.
#
#   IT IS THAT THE DOCUMENT SURVIVES. No re-parse, no new context, no
#   font re-registration, no accessibility tree rebuilt -- and FOCUS,
#   hover and event routing stay where they were. A rebuild loses all of
#   that, which is a correctness difference and not a cost one. A form
#   that re-declared itself to update a status line used to throw away
#   the user's place in it.
#
# THIS CLASS COMPUTES NO MEANINGS. It substitutes text and sets RCSS
# properties. Which values exist, and which are refusable, is StzZui's --
# there is no :Danger here and there may never be.

func StzUiBindingsQ(poDoc, poPanel)
	return new stzUiBindings(poDoc, poPanel)

# Binds {name} placeholders in a document's texts to values, so setting a value changes the screen without rebuilding it.
#
# A placeholder is an ordinary string with braces in it, so the document format is unchanged. Set
# gives a name a value and re-renders only the elements that mention it; SetMany does several at
# once and updates each affected element once; Apply pushes everything. The document survives an
# update, so there is no re-parse, no new font registration and no rebuilt accessibility tree, and
# focus and hover stay where they were. Text changes still re-shape the whole document, style
# changes through SetStyle are surgical. The class substitutes text and sets style properties and
# computes no meanings. Layout needs the engine and a font, no window.
#
#   receiver   oDoc = new stzUiDocument('DEFINE PANEL console ( SIZE [400, 200], DIRECTION column,
#              PADDING 10, CHILDREN [title, readout] ) RATIONALE "A console."' + char(10) + 'DEFINE
#              TEXT title ( CONTENT "NAV - {mode}", SIZE 20 ) RATIONALE "The mode."' + char(10) +
#              'DEFINE TEXT readout ( CONTENT "BEARING {bearing} RANGE {range} km", SIZE 16 )
#              RATIONALE "The numbers."') oDoc.UseFont("C:/Windows/Fonts/segoeui.ttf") oPanel =
#              oDoc.ToPanel() o1 = new stzUiBindings(oDoc, oPanel)
#   example    ? @@( o1.Names() )
#              #--> [ "mode", "bearing", "range" ]
#              o1.Set(:bearing, "042.9")
#              ? o1.RenderOf("readout")
#              #--> BEARING 042.9 RANGE  km
#              ? @@( o1.Unset() )
#              #--> [ "mode", "range" ]
#              o1.SetMany([ :mode = "TRACK", :range = "8.20" ])
#              ? o1.RenderOf("title")
#              #--> NAV - TRACK
#              ? o1.ValueOf("range")
#              #--> 8.20
#              ? o1.TimesApplied()
#              #--> 3
#   see        stzUiDocument, stzPanel, stzScenePanel
class stzUiBindings from stzObject

	@oDoc = NULL
	@oPanel = NULL
	@aTemplates = []    # [ [ elementName, templateString, [names...] ], ... ]
	@aValues = []       # [ [ name, value ], ... ]
	@nApplied = 0

	# Reads every {name} placeholder out of the text declarations of a document, ready to be given values.
	#
	#   poDoc      the stzUiDocument whose CONTENT strings hold placeholders
	#   poPanel    the stzPanel made from it
	#   returns    nothing; the placeholders are harvested when the object is built
	#   note       a placeholder is a name of lower-case letters, digits and underscores in braces;
	#              a lone brace, an empty pair of braces and braces round anything else, such as
	#              {Bad Name}, stay as written
	#   warning    an argument that is not a document and a panel raises error stzUiBindings: give
	#              an stzUiDocument and its stzPanel
	#   see        Names, Set
	def init(poDoc, poPanel)
		if NOT (isObject(poDoc) and isObject(poPanel))
			StzRaise("stzUiBindings: give an stzUiDocument and its stzPanel.")
		ok
		@oDoc = poDoc
		@oPanel = poPanel
		This._Harvest()

	# Returns every placeholder name the document mentions, in the order first met.
	#
	#   returns    a list of text; [ ] when the document has none
	#   note       a screen can say what it needs before anything is set; a name used in two texts
	#              is listed once
	#   see        Unset, IsBound, BoundElements
	#@ aka  -- what the document declared -----------------------------------------
	def Names()
		_a_ = []
		_n_ = len(@aTemplates)
		for _i_ = 1 to _n_
			_aN_ = @aTemplates[_i_][3]
			_nN_ = len(_aN_)
			for _j_ = 1 to _nN_
				if NOT This._Has(_a_, _aN_[_j_])
					_a_ + _aN_[_j_]
				ok
			next
		next
		return _a_

	# Returns the text elements that carry at least one placeholder.
	#
	#   returns    a list of element names in declaration order
	#   see        Names, RenderOf
	#@ aka  The elements that carry a placeholder at all.
	def BoundElements()
		_a_ = []
		_n_ = len(@aTemplates)
		for _i_ = 1 to _n_
			_a_ + @aTemplates[_i_][1]
		next
		return _a_

	# TRUE if the document mentions a placeholder with a name.
	#
	#   pcName     the placeholder name, without braces
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       a name that is not a plain lower-case name, such as Bad Name, is never bound
	#   see        Names, ValueOf
	def IsBound(pcName)
		return This._Has(This.Names(), "" + pcName)

	# Returns the placeholders that have not been given a value yet.
	#
	#   returns    a list of text in the order of Names
	#   note       an unset placeholder renders as empty text, a blank field rather than a screen
	#              that refuses to appear
	#   see        Names, Set
	#@ aka  Names the document uses but nothing has given a value to. Rendering them as empty is the right default -- a screen with a blank field is better than a screen that refuses to appear -- but a caller that wants to be strict can ask.
	def Unset()
		_a_ = []
		_aN_ = This.Names()
		_n_ = len(_aN_)
		for _i_ = 1 to _n_
			if This._ValueIndex(_aN_[_i_]) = 0
				_a_ + _aN_[_i_]
			ok
		next
		return _a_

	# Returns the value last given to a placeholder.
	#
	#   pcName     the placeholder name, without braces
	#   returns    the value as text; an empty text for a name never set
	#   see        Set, Unset
	def ValueOf(pcName)
		_i_ = This._ValueIndex("" + pcName)
		if _i_ = 0
			return ""
		ok
		return @aValues[_i_][2]

	# Gives a placeholder a value and re-renders every element whose text mentions it.
	#
	#   pcName     the placeholder name, without braces
	#   pValue     the value, turned into text
	#   returns    TRUE when every affected element was updated; TRUE also for a name no element
	#              mentions, which changes nothing. SetQ returns the bindings for chaining
	#   note       the value is kept as text, so 7 reads back as 7; SetMany takes a list [ :name =
	#              value, ... ] and updates each affected element once, so a line built from three
	#              values is set once and not three times
	#   see        SetMany, Apply, RenderOf
	#@ aka  -- the one verb --------------------------------------------------------
	def Set(pcName, pValue)
		_c_ = "" + pcName
		_v_ = "" + pValue
		_i_ = This._ValueIndex(_c_)
		if _i_ = 0
			@aValues + [ _c_, _v_ ]
		else
			@aValues[_i_][2] = _v_
		ok
		return This._ApplyThose(_c_)

	def SetQ(pcName, pValue)
		This.Set(pcName, pValue)
		return This

	# Several at once, applying each affected element ONCE. A status line
	# built from three values would otherwise be set three times, and a
	# reader watching it would hear two states that never existed.
	def SetMany(paPairs)
		if NOT isList(paPairs)
			StzRaise("stzUiBindings.SetMany: give [ :name = value, ... ].")
		ok
		_aTouched_ = []
		_n_ = len(paPairs)
		for _i_ = 1 to _n_
			_p_ = paPairs[_i_]
			if NOT (isList(_p_) and len(_p_) = 2)
				loop
			ok
			_c_ = "" + _p_[1]
			_j_ = This._ValueIndex(_c_)
			if _j_ = 0
				@aValues + [ _c_, "" + _p_[2] ]
			else
				@aValues[_j_][2] = "" + _p_[2]
			ok
			_aTouched_ + _c_
		next
		return This._ApplyAffectedBy(_aTouched_)

	def SetManyQ(paPairs)
		This.SetMany(paPairs)
		return This

	# Pushes every bound element to the panel again, whatever changed.
	#
	#   returns    TRUE when every element was updated
	#   note       what to call after loading a screen, to fill it in one go; ApplyQ returns the
	#              bindings for chaining
	#   see        Set, TimesApplied
	#@ aka  Push every template again, whatever changed. What a caller does after loading a screen, to fill it in one go.
	def Apply()
		_a_ = []
		_n_ = len(@aTemplates)
		for _i_ = 1 to _n_
			_a_ + @aTemplates[_i_][1]
		next
		return This._SetThese(_a_)

	def ApplyQ()
		This.Apply()
		return This

	# Returns how many element updates have been pushed to the panel.
	#
	#   returns    a number, starting at 0; each text element updated and each style change adds one
	#   note       an honest counter: a binding that matched nothing leaves it unchanged, as Set of
	#              a name no element mentions does
	#   see        Set, Apply
	#@ aka  How many element updates have actually been pushed. The honest counter: a binding that quietly matched nothing would otherwise look exactly like one that worked.
	def TimesApplied()
		return @nApplied

	# Returns what a bound element's text would be right now, without touching the panel.
	#
	#   pcElement   the name of the text element
	#   returns     the text with the current values put in; an empty text for an element that is
	#               not bound
	#   note        a placeholder with no value reads as empty text, and braces that are not
	#               placeholders are left as written
	#   see         Set, BoundElements
	#@ aka  What one element's text would be, right now. Inspectable without touching the panel, which is what makes the substitution testable separately from the rendering.
	def RenderOf(pcElement)
		_n_ = len(@aTemplates)
		for _i_ = 1 to _n_
			if @aTemplates[_i_][1] = "" + pcElement
				return This._Render(@aTemplates[_i_][2])
			ok
		next
		return ""

	# Sets one style property of an element in the panel, directly.
	#
	#   pcElement    the name of the element
	#   pcProperty   the style property, such as color
	#   pcValue      the value, such as #ff0000
	#   returns      TRUE when the panel took it, FALSE for an element it does not know. SetStyleQ
	#                returns the bindings for chaining
	#   note         a style change is surgical: unlike a text change it does not re-shape the whole
	#                document; each success adds one to TimesApplied
	#   see          ClearStyle, Set
	#@ aka  -- style, which IS surgical -------------------------------------------
	def SetStyle(pcElement, pcProperty, pcValue)
		if NOT @oPanel.SetStyleOf(pcElement, pcProperty, pcValue)
			return FALSE
		ok
		@nApplied++
		return TRUE

	def SetStyleQ(pcElement, pcProperty, pcValue)
		This.SetStyle(pcElement, pcProperty, pcValue)
		return This

	# Hands a style property of an element back to the stylesheet.
	#
	#   pcElement    the name of the element
	#   pcProperty   the style property to give back
	#   returns      TRUE when the panel took it, FALSE for an element it does not know
	#   note         it sets the property to an empty text
	#   see          SetStyle
	#@ aka  Hand the element back to the stylesheet.
	def ClearStyle(pcElement, pcProperty)
		return This.SetStyle(pcElement, pcProperty, "")

	#-- internals -----------------------------------------------------------

	def _Harvest()
		@aTemplates = []
		_aD_ = @oDoc.Declarations()
		_n_ = len(_aD_)
		for _i_ = 1 to _n_
			_d_ = _aD_[_i_]
			if strcmp(_d_[:kind], "TEXT") != 0
				loop
			ok
			_cT_ = @oDoc._StrField(@oDoc._EffectiveFields(_d_), "CONTENT", "")
			_aN_ = This._NamesIn(_cT_)
			if len(_aN_) > 0
				@aTemplates + [ _d_[:name], _cT_, _aN_ ]
			ok
		next

	# The placeholder names in one template, in order.
	#
	# A LONE BRACE IS NOT A PLACEHOLDER. Text saying "use {} for a set" or
	# "{ this is prose" must survive untouched -- an unterminated or empty
	# brace is left exactly as written rather than swallowed, because a
	# template language that eats ordinary punctuation is one people stop
	# writing prose in.
	def _NamesIn(pcTemplate)
		_a_ = []
		_c_ = "" + pcTemplate
		_n_ = len(_c_)
		_i_ = 1
		while _i_ <= _n_
			if _c_[_i_] = "{"
				_j_ = _i_ + 1
				_cN_ = ""
				while _j_ <= _n_ and _c_[_j_] != "}"
					_cN_ += _c_[_j_]
					_j_++
				end
				if _j_ <= _n_ and len(_cN_) > 0 and This._IsPlainName(_cN_)
					if NOT This._Has(_a_, _cN_)
						_a_ + _cN_
					ok
					_i_ = _j_ + 1
					loop
				ok
			ok
			_i_++
		end
		return _a_

	# lower_snake, as the commons requires of every name it governs. A
	# brace holding anything else is prose, not a binding.
	def _IsPlainName(pcName)
		_n_ = len(pcName)
		if _n_ = 0
			return FALSE
		ok
		# ASCII CODES, not string comparison. Ring compares single-char
		# strings NUMERICALLY -- `"b" >= "a"` tries to read both as
		# numbers and raises R41 on the first letter it meets. The trap
		# is quiet in any code that only ever compares digits.
		for _i_ = 1 to _n_
			_nCh_ = ascii(pcName[_i_])
			_bOk_ = (_nCh_ >= 97 and _nCh_ <= 122) or
				(_nCh_ >= 48 and _nCh_ <= 57) or _nCh_ = 95
			if NOT _bOk_
				return FALSE
			ok
		next
		return TRUE

	def _Render(pcTemplate)
		_c_ = "" + pcTemplate
		_aN_ = This._NamesIn(_c_)
		_n_ = len(_aN_)
		for _i_ = 1 to _n_
			_c_ = StzReplace(_c_, "{" + _aN_[_i_] + "}", This.ValueOf(_aN_[_i_]))
		next
		return _c_

	def _ApplyThose(pcName)
		_a_ = []
		_n_ = len(@aTemplates)
		for _i_ = 1 to _n_
			if This._Has(@aTemplates[_i_][3], pcName)
				_a_ + @aTemplates[_i_][1]
			ok
		next
		return This._SetThese(_a_)

	def _ApplyAffectedBy(paNames)
		_a_ = []
		_n_ = len(@aTemplates)
		_nN_ = len(paNames)
		for _i_ = 1 to _n_
			_bHit_ = FALSE
			for _j_ = 1 to _nN_
				if This._Has(@aTemplates[_i_][3], paNames[_j_])
					_bHit_ = TRUE
				ok
			next
			if _bHit_
				_a_ + @aTemplates[_i_][1]
			ok
		next
		return This._SetThese(_a_)

	def _SetThese(paElements)
		_bAll_ = TRUE
		_n_ = len(paElements)
		for _i_ = 1 to _n_
			_cE_ = paElements[_i_]
			_cT_ = ""
			_nT_ = len(@aTemplates)
			for _j_ = 1 to _nT_
				if @aTemplates[_j_][1] = _cE_
					_cT_ = @aTemplates[_j_][2]
				ok
			next
			if NOT @oPanel.SetTextOf(_cE_, This._Render(_cT_))
				_bAll_ = FALSE
			else
				@nApplied++
			ok
		next
		return _bAll_

	def _ValueIndex(pcName)
		_n_ = len(@aValues)
		for _i_ = 1 to _n_
			if @aValues[_i_][1] = pcName
				return _i_
			ok
		next
		return 0

	def _Has(paList, pcItem)
		_n_ = len(paList)
		for _i_ = 1 to _n_
			if paList[_i_] = pcItem
				return TRUE
			ok
		next
		return FALSE
