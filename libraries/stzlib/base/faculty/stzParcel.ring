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

	def init(pcType, pValue)
		@cType = pcType
		@vValue = pValue
		@cKey = StzEngineCryptoSha256(pcType + "|" + StzParcelCanonical(pValue))

	  #-- reading (data) ------------------------------------------------------

	def Type()
		return @cType

	def Value()
		return @vValue

	def IsRefusal()
		return @bRefusal

	def Findings()
		return @aFindings

	def Certainty()
		return @cCertainty

	def P()
		return @nP

	def Provenance()
		return @aProvenance

	# The chain of "faculty:implementation" that made this parcel, oldest first.
	def Chain()
		_a_ = []
		_n_ = len(@aProvenance)
		for _i_ = 1 to _n_
			add(_a_, @aProvenance[_i_][:faculty] + ":" + @aProvenance[_i_][:implementation])
		next
		return _a_

	def Cost()
		return @aCost

	def Key()
		return @cKey

	def Trace()
		return @cTrace

	# One sentence per step: what ran, as what kind, with what confidence.
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

	def CiteFindings()
		_c_ = ""
		_n_ = len(@aFindings)
		for _i_ = 1 to _n_
			if _c_ != "" _c_ += " / " ok
			_c_ += @aFindings[_i_][:rule] + " at " + @aFindings[_i_][:where] + ": " + @aFindings[_i_][:message]
		next
		return _c_

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
