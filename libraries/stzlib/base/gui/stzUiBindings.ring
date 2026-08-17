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

class stzUiBindings from stzObject

	@oDoc = NULL
	@oPanel = NULL
	@aTemplates = []    # [ [ elementName, templateString, [names...] ], ... ]
	@aValues = []       # [ [ name, value ], ... ]
	@nApplied = 0

	def init(poDoc, poPanel)
		if NOT (isObject(poDoc) and isObject(poPanel))
			StzRaise("stzUiBindings: give an stzUiDocument and its stzPanel.")
		ok
		@oDoc = poDoc
		@oPanel = poPanel
		This._Harvest()

	#-- what the document declared -----------------------------------------

	# Every placeholder name the document mentions, in first-seen order.
	# A caller can ask this BEFORE setting anything, which is how a screen
	# says what it needs rather than failing when it does not get it.
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

	# The elements that carry a placeholder at all.
	def BoundElements()
		_a_ = []
		_n_ = len(@aTemplates)
		for _i_ = 1 to _n_
			_a_ + @aTemplates[_i_][1]
		next
		return _a_

	def IsBound(pcName)
		return This._Has(This.Names(), "" + pcName)

	# Names the document uses but nothing has given a value to. Rendering
	# them as empty is the right default -- a screen with a blank field is
	# better than a screen that refuses to appear -- but a caller that
	# wants to be strict can ask.
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

	def ValueOf(pcName)
		_i_ = This._ValueIndex("" + pcName)
		if _i_ = 0
			return ""
		ok
		return @aValues[_i_][2]

	#-- the one verb --------------------------------------------------------

	# Give a name a value. Every element whose template mentions it is
	# re-rendered and set; nothing else is touched.
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

	# Push every template again, whatever changed. What a caller does
	# after loading a screen, to fill it in one go.
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

	# How many element updates have actually been pushed. The honest
	# counter: a binding that quietly matched nothing would otherwise look
	# exactly like one that worked.
	def TimesApplied()
		return @nApplied

	# What one element's text would be, right now. Inspectable without
	# touching the panel, which is what makes the substitution testable
	# separately from the rendering.
	def RenderOf(pcElement)
		_n_ = len(@aTemplates)
		for _i_ = 1 to _n_
			if @aTemplates[_i_][1] = "" + pcElement
				return This._Render(@aTemplates[_i_][2])
			ok
		next
		return ""

	#-- style, which IS surgical -------------------------------------------
	#
	# Text updates re-shape the whole document; style updates do not. Kept
	# as its own verb rather than folded into Set(), because the two have
	# genuinely different costs and a caller choosing between them should
	# see which is which.

	def SetStyle(pcElement, pcProperty, pcValue)
		if NOT @oPanel.SetStyleOf(pcElement, pcProperty, pcValue)
			return FALSE
		ok
		@nApplied++
		return TRUE

	def SetStyleQ(pcElement, pcProperty, pcValue)
		This.SetStyle(pcElement, pcProperty, pcValue)
		return This

	# Hand the element back to the stylesheet.
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
