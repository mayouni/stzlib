#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZPARCEL                      #
#--------------------------------------------------------------#
#                                                              #
#   Description  : stzParcel -- the ONLY thing that passes     #
#                  between the stages of a flow. An immutable,  #
#                  replayable, memoisable value that carries    #
#                  its type, its provenance (which faculty,     #
#                  which implementation, which version), its    #
#                  evidence, its cost and a content key.        #
#                  A stage yields a parcel its court accepted,  #
#                  or a REFUSAL parcel naming the rule it failed#
#                  (design: SOFTANZA_MODEL_FLOW.md section 3).  #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

# The evidential register (LAW 3): certain / probable / apparent / unknown.
# A parcel whose producer cannot state a confidence says :unknown -- it never
# invents one.

func StzParcelQ(pcType, pValue)
	_oP_ = new stzParcel(pcType, pValue)
	return _oP_

# A refusal is a parcel too: type "refusal", the findings in the house shape
# [ :rule, :subject, :where, :severity, :message ] (the value is the list of findings).
func StzRefusalParcelQ(pcWhere, pcRule, pcMessage)
	_oP_ = new stzParcel("refusal", [])
	_oP_._MakeRefusal([ [ :rule = pcRule, :subject = "model-flow", :where = pcWhere,
			     :severity = :error, :message = pcMessage ] ])
	return _oP_

# canonical text of any value, so equal values hash equal
func StzParcelCanonical(pValue)
	if isString(pValue) return "s:" + pValue ok
	if isNumber(pValue) return "n:" + pValue ok
	return "l:" + @@(pValue)

# Carries a value between the stages of a flow together with its provenance, certainty, cost and content key.
#
# A parcel is the only thing that passes between stages. It has no public setter: the library fills
# its evidence, provenance and cost when a faculty runs, so it can be read and replayed but not
# edited. A stage yields either a parcel its court accepted or a refusal parcel whose value is the
# list of findings, which is why a refusal can travel through a flow like any other value. Certainty
# and probability are what the implementation stated, and unknown when it stated none; they are not
# a judgment made by a person.
#
#   receiver   o1 = StzParcelQ("label", "odd")
#   example    ? o1.Type()
#              #--> label
#              ? o1.IsRefusal()
#              #--> 0
#              ? o1.Certainty()
#              #--> unknown
#              o2 = StzRefusalParcelQ("stage x", "my-rule", "something failed")
#              ? o2.Why()
#              #--> REFUSED: my-rule at stage x: something failed
#   see        stzFaculty, stzFlow
class stzParcel from stzObject

	@cType = ""
	@vValue = ""
	@bRefusal = 0
	@aFindings = []
	@cCertainty = "unknown"
	@nP = -1                     # -1 = no probability stated
	@aProvenance = []            # one [ :faculty, :implementation, :version, :kind, :detail ] per step
	@aCost = [ :ms = 0, :tokens_in = 0, :tokens_out = 0 ]
	@cKey = ""
	@cTrace = ""

	# Builds a parcel of a payload type around a value, with a content key and no provenance yet.
	#
	#   pcType     the payload type of the value, such as text or label
	#   pValue     the value the parcel carries
	#   returns    nothing; the object is built
	#   note       the key is a SHA-256 of the type and the value, so two parcels of the same type
	#              and value share it until a run seals it over the chain
	#   warning    nothing judges the value here: the courts judge it when a faculty makes the
	#              parcel, and a parcel built by hand has certainty unknown, no probability and an
	#              empty chain
	#   see        StzParcelQ, StzRefusalParcelQ
	def init(pcType, pValue)
		@cType = pcType
		@vValue = pValue
		@cKey = StzEngineCryptoSha256(pcType + "|" + StzParcelCanonical(pValue))

	# Returns the payload type of the parcel, or refusal when it is a refusal.
	#
	#   returns    a text such as label, number or refusal
	#   see        Value, IsRefusal
	#@ aka  -- reading (data) ------------------------------------------------------
	def Type()
		return @cType

	# Returns the payload the parcel carries.
	#
	#   returns    the value, whatever its type; for a refusal, the list of findings
	#   note       a parcel has no setter, so the value cannot change after it is built
	#   see        Type, Findings
	def Value()
		return @vValue

	# TRUE if the parcel is a refusal: the court rejected the answer, or a stage or the registry could not answer.
	#
	#   returns    TRUE or FALSE
	#   note       a refusal is a parcel too, so a flow can carry it without raising
	#   see        Findings, CiteFindings, Why
	def IsRefusal()
		return @bRefusal

	# Returns the findings a refusal carries, in the house shape.
	#
	#   returns    a list of findings, each [ rule, subject, where, severity, message ]; [ ] for a
	#              parcel that is not a refusal
	#   see        CiteFindings, IsRefusal
	def Findings()
		return @aFindings

	# Returns the evidential word the producer stated for the answer.
	#
	#   returns    a text: unknown unless the implementation stated certain, probable or apparent
	#   note       the word is whatever the implementation declared and the class never invents one;
	#              it is not judged by a person, and a floor says unknown unless it states more
	#   see        P, Why
	def Certainty()
		return @cCertainty

	# Returns the probability the producer stated for the answer, or -1 when it stated none.
	#
	#   returns    a number from 0 to 1, or -1
	#   note       it is the producer's own figure, kept as given; calibration is checked separately
	#              against the goldens, not by a person
	#   see        Certainty, Cost
	def P()
		return @nP

	# Returns one row for every step that made the parcel, oldest first.
	#
	#   returns    a list of rows, each a list of [ key, value ] pairs: faculty, implementation,
	#              version, kind, detail; [ ] for a parcel built by hand
	#   note       the detail of a floor that answered after a model failed says it fell back and
	#              why
	#   see        Chain, Why
	def Provenance()
		return @aProvenance

	# Returns the steps that made the parcel as faculty:implementation texts, oldest first.
	#
	#   returns    a list of text such as clean:smart-clean
	#   note       a parcel from the last stage of a flow lists every stage before it
	#   see        Provenance, Why
	#@ aka  The chain of "faculty:implementation" that made this parcel, oldest first.
	def Chain()
		_a_ = []
		_n_ = len(@aProvenance)
		for _i_ = 1 to _n_
			add(_a_, @aProvenance[_i_][:faculty] + ":" + @aProvenance[_i_][:implementation])
		next
		return _a_

	# Returns what producing the answer cost.
	#
	#   returns    a list of [ key, value ] pairs: ms, tokens_in and tokens_out
	#   note       the token counts are whatever the implementation stated, and 0 when it stated
	#              none
	#   warning    the milliseconds are read from Ring's clock around the call, so a fast stand-in
	#              function reads 0
	#   see        Provenance, P
	def Cost()
		return @aCost

	# Returns the content key of the parcel: a SHA-256 in hexadecimal.
	#
	#   returns    a text of 64 characters
	#   note       once sealed by a run the key covers the type, the value and the chain, so the
	#              same value made by two implementations has two keys
	#   see        Content, Chain
	def Key()
		return @cKey

	# Returns the flow and stage that produced the parcel, set only by a flow run.
	#
	#   returns    a text such as tidy-sort-loud:sort; an empty text outside a flow
	#   see        Chain, Key
	def Trace()
		return @cTrace

	# Returns one sentence per step that made the parcel, with the certainty at the end; for a refusal, the findings.
	#
	#   returns    a text such as conf -> m1 (model) [stand-in], ending with the certainty; for a
	#              refusal, REFUSED: followed by CiteFindings
	#   note       the certainty shown is the one the producer stated, not a judgment of quality
	#   see        CiteFindings, Provenance, Certainty
	#@ aka  One sentence per step: what ran, as what kind, with what confidence.
	def Why()
		if @bRefusal = 1
			return "REFUSED: " + This.CiteFindings()
		ok
		_c_ = ""
		_n_ = len(@aProvenance)
		for _i_ = 1 to _n_
			_aS_ = @aProvenance[_i_]
			if _c_ != "" _c_ += "; " ok
			_c_ += _aS_[:faculty] + " -> " + _aS_[:implementation] + " (" + _aS_[:kind] + ")"
			if _aS_[:detail] != "" _c_ += " [" + _aS_[:detail] + "]" ok
		next
		return _c_ + " | certainty " + @cCertainty

	# Returns the findings written as one line each part, rule then place then message.
	#
	#   returns    a text such as my-rule at stage x: something failed, parts joined by a slash; an
	#              empty text when there are none
	#   see        Findings, Why
	def CiteFindings()
		_c_ = ""
		_n_ = len(@aFindings)
		for _i_ = 1 to _n_
			if _c_ != "" _c_ += " / " ok
			_c_ += @aFindings[_i_][:rule] + " at " + @aFindings[_i_][:where] + ": " + @aFindings[_i_][:message]
		next
		return _c_

	# Returns a summary of what identifies the parcel, without its value.
	#
	#   returns    a list of [ key, value ] pairs: type, refusal, certainty, chain and key
	#   see        Key, Chain, Type
	def Content()
		return [ [ "type", @cType ], [ "refusal", @bRefusal ], [ "certainty", @cCertainty ],
			 [ "chain", This.Chain() ], [ "key", @cKey ] ]

	  #-- building (internal: a parcel has no public setter) --------------------

	def _MakeRefusal(paFindings)
		@bRefusal = 1
		@aFindings = paFindings
		@vValue = paFindings

	def _SetEvidence(pcCertainty, pnP)
		@cCertainty = pcCertainty
		@nP = pnP

	def _SetProvenance(paProvenance)
		@aProvenance = paProvenance

	def _SetCost(paCost)
		@aCost = paCost

	def _SetTrace(pcTrace)
		@cTrace = pcTrace

	# Seal the key over the type, the value AND the provenance chain: two parcels with the same value
	# made by different implementations are different parcels.
	def _SealKey()
		@cKey = StzEngineCryptoSha256(@cType + "|" + StzParcelCanonical(@vValue) + "|" + @@(This.Chain()))
