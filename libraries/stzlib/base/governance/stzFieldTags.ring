# stzFieldTags -- THE FIELD TAGS OF A WORLD: W3 sovereignty and W4 privacy
# as judged tags (the constitution plane's ZC4: haro/CHARTER.md D35,
# haro/spike/v25/GRAMMAR.md; COMPASS-KERN-01).
#
# A field tagged :personal or :confidential reaches an analytics, a log or
# a model path only when that path declares the safeguards the weave names:
#
#   :analytics  consent + anonymisation     W4.2  usage over personal data
#   :log        retention + redaction       W4.4  a log carries no personal datum
#   :model      on_premise                  W3.3  confidential data does not leave
#                                                 to a model that is not on premise
#
# Otherwise the reach is REFUSED, and the refusal names the weave's rule
# in its words, the article it serves (Art. 5 organizational_sovereignty)
# and the declared regime's own article -- gdpr's, Niger Law 2017-28 as
# Zin's African companion names it, a regime this library has no table for
# as declared, "no regime declared" where there is none. NEVER A DEFAULT:
# no regime ships with Softanza (the 5.7 boundary, as stzGovernance keeps
# it); the world declares its own.
#
#   oT = new stzFieldTags("clinic")
#   oT.Tag("full_name", :personal)
#   oT.DeclareRegime("gdpr")
#   ? oT.MayReach(:model, ["file_no", "full_name"])     # 0
#   ? oT.Why()
#   #--> refused: 'full_name' is personal and 'model' is an ungoverned path (no on_premise)
#   #    -- W3.3 sovereignty: ... [Art. 5 organizational_sovereignty; gdpr: Chapter V]
#   oT.GovernPath(:model, [:on_premise])
#   ? oT.MayReach(:model, ["file_no", "full_name"])     # 1
#
# A REFUSAL IS AN EVENT, NOT A SILENT FAILURE (SOFTANZA_SECURITY.md):
# every refusal builds a stzSecurityEvent of kind data.path.refused that
# carries the field's DESCRIPTOR (field:<name>) and never a value;
# LastEvent() hands it out and RecordTo(ledger) enters it in a ledger.
#
# The three paths are this library's (and HaroBase's column flags, the
# same rung); the voice, the ask and the published world are Haro's at the
# declaring altitude (v0.25). The state lives in the object: a tag set is
# built, handed to one judge and asked; it is not a shared regime like
# stzGovernance's table, and a copy that drifts would fail closed.

# Holds a world's field tags and the safeguards its data paths declare, and judges whether tagged fields may reach a path.
#
# A field is tagged personal or confidential. A path is one of analytics, log and model, and each has the
# safeguards Zin's weaves give it; a path declaring all of them admits tagged fields, any other refuses them.
# Every verdict is explained by Why, which names the weave's rule, the article and the declared regime's own
# article; a refusal also builds a security event.
#
#   receiver   o1 = new stzFieldTags("clinic") o1.Tag("full_name", :personal) o1.DeclareRegime("gdpr")
#   example    ? o1.MayReach(:model, ["full_name"])
#              #--> 0
#              ? o1.Why()
#              #--> refused: 'full_name' is personal and 'model' is an ungoverned path (no on_premise) -- W3.3 sovereignty: confidential data does not leave to a model that is not on premise [Art. 5 organizational_sovereignty; gdpr: Chapter V]
#              o1.GovernPath(:model, [:on_premise])
#              ? o1.MayReach(:model, ["full_name"])
#              #--> 1
#   see        stzGovernance, stzSecurityEvent, stzSecurityLedger
class stzFieldTags from stzObject

	@tName = ""
	@aTags = []          # [ [field, tag], ... ]
	@aPaths = []         # [ [path, [safeguards...]], ... ]
	@cRegime = ""
	@cWhy = ""
	@oLastEvent = NULL

	# Builds an empty tag set under a name, with no regime and no governed path.
	#
	#   pcName     the world's name, as text
	#   returns    nothing; the object is built
	#   see        Tag, DeclareRegime, GovernPath, MayReach
	def init(pcName)
		@tName = "" + pcName

	# Returns the tag set's name.
	#
	#   returns    a text
	def Name_()
		return @tName

	# Returns the sentence that explains the last verdict.
	#
	#   returns    a text beginning with "allowed:" or "refused:"; the empty text before any verdict
	#   see        MayReach
	def Why()
		return @cWhy

	# Tags a field as personal or confidential, replacing an earlier tag.
	#
	#   pcField    the field's name, kept in lower case
	#   pcTag      :personal or :confidential
	#   returns    the tag set itself, so calls chain
	#   warning    a tag outside the two raises an error: the tags are closed
	#   see        TagOf, Tags
	def Tag(pcField, pcTag)
		_cT_ = StzLower(ring_trim("" + pcTag))
		if _cT_ != "personal" and _cT_ != "confidential"
			stzraise("A field tag is personal or confidential; '" + _cT_ + "' is neither.")
		ok
		_cF_ = StzLower(ring_trim("" + pcField))
		_n_ = len(@aTags)
		for _i_ = 1 to _n_
			if @aTags[_i_][1] = _cF_
				@aTags[_i_][2] = _cT_
				return This
			ok
		next
		@aTags + [ _cF_, _cT_ ]
		return This

	# Returns a field's tag.
	#
	#   pcField    the field's name
	#   returns    "personal", "confidential", or the empty text when the field is untagged
	def TagOf(pcField)
		_cF_ = StzLower(ring_trim("" + pcField))
		_n_ = len(@aTags)
		for _i_ = 1 to _n_
			if @aTags[_i_][1] = _cF_
				return @aTags[_i_][2]
			ok
		next
		return ""

	# Returns every tag as pairs of field and tag.
	#
	#   returns    a list of [field, tag] pairs, in the order they were declared
	def Tags()
		return @aTags

	# Declares the regime the world stands under, whose own article a refusal names.
	#
	#   pcRegime   the regime's name, as text: gdpr, niger_2017_28, or any name the world declares
	#   returns    the tag set itself, so calls chain
	#   note       no regime is a default: a refusal under none says "no regime declared"
	#   see        Regime
	def DeclareRegime(pcRegime)
		@cRegime = StzLower(ring_trim("" + pcRegime))
		return This

	# Returns the declared regime, or the empty text.
	#
	#   returns    a text
	def Regime()
		return @cRegime

	# Returns the three paths a tagged field is judged on.
	#
	#   returns    ["analytics", "log", "model"]
	def Paths()
		return [ "analytics", "log", "model" ]

	# Returns the safeguards a path needs before a tagged field may reach it.
	#
	#   pcPath     analytics, log or model
	#   returns    a list of safeguard names
	#   warning    a path outside the three raises an error: the paths are closed
	def SafeguardsNeededBy(pcPath)
		_cP_ = This._Path(pcPath)
		if _cP_ = "analytics"
			return [ "consent", "anonymisation" ]
		but _cP_ = "log"
			return [ "retention", "redaction" ]
		ok
		return [ "on_premise" ]

	# Declares the safeguards a path holds, replacing an earlier declaration.
	#
	#   pcPath          analytics, log or model
	#   pacSafeguards   the safeguards the path holds, among the ones it needs
	#   returns         the tag set itself, so calls chain
	#   warning         a safeguard that is not the path's raises an error
	#   see             SafeguardsOf, SafeguardsNeededBy
	def GovernPath(pcPath, pacSafeguards)
		_cP_ = This._Path(pcPath)
		_aNeed_ = This.SafeguardsNeededBy(_cP_)
		_aGiven_ = []
		_n_ = len(pacSafeguards)
		for _i_ = 1 to _n_
			_cS_ = StzLower(ring_trim("" + pacSafeguards[_i_]))
			_bKnown_ = 0
			for _j_ = 1 to len(_aNeed_)
				if _aNeed_[_j_] = _cS_
					_bKnown_ = 1
				ok
			next
			if _bKnown_ = 0
				stzraise("'" + _cS_ + "' is not a safeguard of the " + _cP_ + " path; it needs " + This._Join(_aNeed_, " and ") + ".")
			ok
			_aGiven_ + _cS_
		next
		_m_ = len(@aPaths)
		for _i_ = 1 to _m_
			if @aPaths[_i_][1] = _cP_
				@aPaths[_i_][2] = _aGiven_
				return This
			ok
		next
		@aPaths + [ _cP_, _aGiven_ ]
		return This

	# Returns the safeguards a path declares.
	#
	#   pcPath     analytics, log or model
	#   returns    a list of safeguard names, empty when the path is ungoverned
	def SafeguardsOf(pcPath)
		_cP_ = This._Path(pcPath)
		_m_ = len(@aPaths)
		for _i_ = 1 to _m_
			if @aPaths[_i_][1] = _cP_
				return @aPaths[_i_][2]
			ok
		next
		return []

	# Judges whether the fields may reach a path: an untagged field always may; a tagged one only when the path declares every safeguard it needs.
	#
	#   pcPath      analytics, log or model
	#   pacFields   the fields that would reach it
	#   returns     1 when every field may reach the path, 0 when one is refused; Why explains either
	#   note        a refusal names the weave's rule, the article it serves and the declared regime's
	#               own article, and builds a security event (LastEvent)
	#   see         Why, LastEvent, GovernPath
	def MayReach(pcPath, pacFields)
		_cP_ = This._Path(pcPath)
		_aNeed_ = This.SafeguardsNeededBy(_cP_)
		_aHas_ = This.SafeguardsOf(_cP_)
		_aMissing_ = []
		for _i_ = 1 to len(_aNeed_)
			_bHas_ = 0
			for _j_ = 1 to len(_aHas_)
				if _aHas_[_j_] = _aNeed_[_i_]
					_bHas_ = 1
				ok
			next
			if _bHas_ = 0
				_aMissing_ + _aNeed_[_i_]
			ok
		next
		@oLastEvent = NULL
		_n_ = len(pacFields)
		for _i_ = 1 to _n_
			_cF_ = StzLower(ring_trim("" + pacFields[_i_]))
			_cT_ = This.TagOf(_cF_)
			if _cT_ = ""
				loop
			ok
			if len(_aMissing_) = 0
				@cWhy = "allowed: '" + _cF_ + "' is " + _cT_ + " and the " + _cP_ + " path is governed (" + This._Join(_aHas_, ", ") + ")"
				loop
			ok
			_cHow_ = ""
			if len(_aHas_) = 0
				_cHow_ = "an ungoverned path (no " + This._Join(_aNeed_, ", no ") + ")"
			else
				_cHow_ = "a path governed in part (" + This._Join(_aMissing_, ", ") + " missing)"
			ok
			@cWhy = "refused: '" + _cF_ + "' is " + _cT_ + " and '" + _cP_ + "' is " + _cHow_ + " -- " + This._Rule(_cP_) + This._RegimeTail(_cP_)
			@oLastEvent = StzSecurityRefusal("data.path.refused", @tName, "field:" + _cF_, @cWhy)
			return 0
		next
		if substr(@cWhy, "allowed: '") != 1 or _n_ = 0
			@cWhy = "allowed: no field of [" + This._Join(This._Lower(pacFields), ", ") + "] is tagged"
		ok
		return 1

	# Returns the security event the last refusal built, or NULL after an allowed reach.
	#
	#   returns    a stzSecurityEvent of kind data.path.refused, or NULL
	#   see        RecordTo
	def LastEvent()
		return @oLastEvent

	# Records the last refusal's event in a security ledger.
	#
	#   poLedger   a stzSecurityLedger
	#   returns    the tag set itself, so calls chain
	#   note       does nothing after an allowed reach
	def RecordTo(poLedger)
		if not isNull(@oLastEvent)
			poLedger.Record(@oLastEvent)
		ok
		return This

	#-- the closed words and the words of a refusal ----------------------------

	def _Path(pcPath)
		_cP_ = StzLower(ring_trim("" + pcPath))
		if _cP_ != "analytics" and _cP_ != "log" and _cP_ != "model"
			stzraise("A data path is analytics, log or model; '" + _cP_ + "' is none of them.")
		ok
		return _cP_

	def _Rule(pcPath)
		if pcPath = "analytics"
			return "W4.2 privacy: usage over personal data is analytics, which needs consent and anonymisation"
		but pcPath = "log"
			return "W4.4 privacy: a log carries no personal datum without a retention limit and redaction"
		ok
		return "W3.3 sovereignty: confidential data does not leave to a model that is not on premise"

	# the regime's own article beside the constitution's -- the same table Haro's meta-court keeps
	# (haro_lib.ring, StzuRegimeTail): the declared regime, never a default
	def _RegimeTail(pcPath)
		_cTail_ = ""
		if @cRegime = ""
			_cTail_ = "no regime declared"
		but @cRegime = "gdpr"
			if pcPath = "analytics"
				_cTail_ = "gdpr: Article 7"
			but pcPath = "log"
				_cTail_ = "gdpr: Article 5(1)(e)"
			else
				_cTail_ = "gdpr: Chapter V"
			ok
		but @cRegime = "niger_2017_28"
			_cTail_ = "Niger Law 2017-28"
		else
			_cTail_ = "regime '" + @cRegime + "' as declared, which Softanza has no article table for"
		ok
		return " [Art. 5 organizational_sovereignty; " + _cTail_ + "]"

	def _Join(pacWords, pcSep)
		_c_ = ""
		for _i_ = 1 to len(pacWords)
			if _i_ > 1
				_c_ += pcSep
			ok
			_c_ += "" + pacWords[_i_]
		next
		return _c_

	def _Lower(pacWords)
		_a_ = []
		for _i_ = 1 to len(pacWords)
			_a_ + StzLower(ring_trim("" + pacWords[_i_]))
		next
		return _a_
