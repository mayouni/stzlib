#=====================================================================#
#  STZTUKEYSTORY -- findings and a fit, told; computes nothing        #
#  (SOFTANZA_TUKEY_PLAN.md 2.6 and TK5; plane stzlib-math, M4d)        #
#=====================================================================#
/*
	The narrative half of the Tukey tier, under the honesty law of the
	plan's 2.6: the story PERFORMS NO ARITHMETIC. Every number in its
	prose is read from the fit (Common, Effects, ResidualScale, Sweeps,
	the table's size) or from a finding's message in the rule report,
	and IsHonest() proves it on the story itself: every numeral token in
	Text() is a token the sources carry, or the story says which is not.

	    oFit = StzTukeyFitQ(aRows)
	    oFit.Polish()
	    oRep = StzTukeyReportQ("deaths", [ oFit ])
	    oSt = StzTukeyStoryQ(oFit, oRep)
	    ? oSt.Text()
	    ? oSt.IsHonest()
	    #--> 1

	Told on stzTranscript (the class stzNarration became, DN9a): each
	paragraph a system line, the verdict a verdict line with certainty 1,
	because nothing here was guessed. There is NO LLM face: the plan's TK5
	kill criterion says the LLM path does not ship if templated prose
	reads well enough, and it does -- a capability the plane does not need.
*/

# the numeral tokens of a text: maximal runs of digits with one inner dot,
# the sign left to the words (a "-3" in prose is the token "3" carried by
# the source as "-3", matched by _TsAbs)
func _TsNumerals(pcText)
	_ac_ = []
	_c_ = ""
	_n_ = len(pcText)
	for _i_ = 1 to _n_
		_ch_ = pcText[_i_]
		if isdigit(_ch_) or (_ch_ = "." and _c_ != "" and _i_ < _n_ and isdigit(pcText[_i_ + 1]))
			_c_ += _ch_
		else
			if _c_ != ""  _ac_ + _c_  ok
			_c_ = ""
		ok
	next
	if _c_ != ""  _ac_ + _c_  ok
	return _ac_

# does a source carry the token as a negative?
func _TsAbs(pcTok, pacSources)
	return StzFindFirst("-" + pcTok, pacSources)

func StzTukeyStoryQ(poFit, poReport)
	return new stzTukeyStory(poFit, poReport)

class stzTukeyStory from stzObject

	@oFit = NULL
	@oReport = NULL
	@acSources = []      # every numeral token the fit and the findings carry

	def init(poFit, poReport)
		if NOT isObject(poFit) or StzLower(ring_classname(poFit)) != "stztukeyfit"
			stzraise("stzTukeyStory: the first argument is an stzTukeyFit.")
		ok
		if NOT poFit.IsPolished()
			stzraise("stzTukeyStory: Polish() the fit first -- a story is told about a fit that exists.")
		ok
		if NOT isObject(poReport) or StzLower(ring_classname(poReport)) != "stzrulereport"
			stzraise("stzTukeyStory: the second argument is an stzRuleReport (StzTukeyReportQ builds one).")
		ok
		@oFit = poFit
		@oReport = poReport

	def Fit()
		return @oFit

	def Report()
		return @oReport

	#-- the paragraphs, each read from a source ----------------------------

	def Paragraphs()
		_ac_ = []
		_ac_ + This._TheFit()
		_ac_ + This._TheEffects()
		_c_ = This._TheFindings()
		if _c_ != ""  _ac_ + _c_  ok
		_ac_ + This._TheVerdict()
		return _ac_

	def Text()
		_ac_ = This.Paragraphs()
		_c_ = ""
		for _i_ = 1 to ring_len(_ac_)
			_c_ += _ac_[_i_] + char(10)
		next
		return _c_

	# on the transcript: paragraphs as system lines, the verdict as a
	# verdict line at certainty 1 -- deterministic, nothing admitted by guess
	def Transcript()
		_o_ = new stzTranscript()
		_ac_ = This.Paragraphs()
		_n_ = ring_len(_ac_)
		for _i_ = 1 to _n_ - 1
			_o_.System(_ac_[_i_])
		next
		_o_.Verdict(_ac_[_n_], 1)
		return _o_

	def _TheFit()
		_cHow_ = "converged in " + @oFit.Sweeps() + " sweep(s)"
		if NOT @oFit.IsConverged()
			_cHow_ = "stopped at the cap of " + @oFit.Sweeps() + " sweep(s) without converging"
		ok
		return "A table of " + @oFit.NumberOfRows() + " rows and " + @oFit.NumberOfColumns() +
			" columns was fitted by median polish, which " + _cHow_ + ". The common value is " +
			This._N(@oFit.Common()) + " and the residuals' fourth-spread, the scale every judgement below is in, is " +
			This._N(@oFit.ResidualScale()) + "."

	def _TheEffects()
		_aRow_ = @oFit.Effects(:Row)
		_aCol_ = @oFit.Effects(:Col)
		_r_ = This._Extremes(_aRow_)
		_c_ = This._Extremes(_aCol_)
		return "The row effects run from " + This._N(_r_[1]) + " at row " + _r_[2] + " to " + This._N(_r_[3]) +
			" at row " + _r_[4] + "; the column effects from " + This._N(_c_[1]) + " at column " + _c_[2] +
			" to " + This._N(_c_[3]) + " at column " + _c_[4] + "."

	# [ min, its index, max, its index ] -- a READ of the list, not a computation on its values
	def _Extremes(paV)
		_iMin_ = 1  _iMax_ = 1
		for _i_ = 2 to ring_len(paV)
			if paV[_i_] < paV[_iMin_]  _iMin_ = _i_  ok
			if paV[_i_] > paV[_iMax_]  _iMax_ = _i_  ok
		next
		return [ paV[_iMin_], _iMin_, paV[_iMax_], _iMax_ ]

	def _TheFindings()
		_aF_ = @oReport.Findings()
		_n_ = ring_len(_aF_)
		if _n_ = 0  return ""  ok
		_c_ = "The report carries " + _n_ + " finding(s)."
		for _i_ = 1 to _n_
			_f_ = _aF_[_i_]
			_cSev_ = "" + _f_[:severity]
			_cLead_ = " A warning"
			if _cSev_ = "error"  _cLead_ = " An error"  ok
			_c_ += _cLead_ + ", " + StzReplace("" + _f_[:rule], "_", " ") + ", at " + ("" + _f_[:where]) + ": " + _f_[:message] + "."
		next
		return _c_

	def _TheVerdict()
		_nE_ = ring_len(@oReport.Errors())
		_nW_ = ring_len(@oReport.Warnings())
		if @oReport.IsSound()
			return "Verdict: the table is sound -- " + _nE_ + " error(s), " + _nW_ + " warning(s); Data = Fit + Residual holds to " +
				This._N(@oFit.Check()) + "."
		ok
		return "Verdict: the table is not sound -- " + _nE_ + " error(s), " + _nW_ + " warning(s); the fit still holds, Data = Fit + Residual to " +
			This._N(@oFit.Check()) + ", and the errors say which cells the fit does not describe."

	# one formatting of a number, shared with the sources so a numeral in
	# the prose is the same token the source would print
	def _N(pn)
		return _FfNum(pn, 4)

	#-- the honesty law, checked on the story itself --------------------------

	# every numeral token the sources carry, formatted the one way
	def SourceNumerals()
		_ac_ = []
		_ac_ + ("" + @oFit.NumberOfRows())
		_ac_ + ("" + @oFit.NumberOfColumns())
		_ac_ + ("" + @oFit.Sweeps())
		_ac_ + This._N(@oFit.Common())
		_ac_ + This._N(@oFit.ResidualScale())
		_ac_ + This._N(@oFit.Check())
		_aRow_ = @oFit.Effects(:Row)
		for _i_ = 1 to ring_len(_aRow_)
			_ac_ + This._N(_aRow_[_i_])
			_ac_ + ("" + _i_)
		next
		_aCol_ = @oFit.Effects(:Col)
		for _i_ = 1 to ring_len(_aCol_)
			_ac_ + This._N(_aCol_[_i_])
			_ac_ + ("" + _i_)
		next
		_aF_ = @oReport.Findings()
		_ac_ + ("" + ring_len(_aF_))
		_ac_ + ("" + ring_len(@oReport.Errors()))
		_ac_ + ("" + ring_len(@oReport.Warnings()))
		for _i_ = 1 to ring_len(_aF_)
			_acT_ = _TsNumerals("" + _aF_[_i_][:where] + " " + _aF_[_i_][:message])
			for _k_ = 1 to ring_len(_acT_)  _ac_ + _acT_[_k_]  next
		next
		return _ac_

	# the numeral tokens of the prose, in order
	def Numerals()
		return _TsNumerals(This.Text())

	# the numerals of the prose that no source carries -- empty when honest
	def Unsourced()
		_acS_ = This.SourceNumerals()
		_acN_ = This.Numerals()
		_ac_ = []
		for _i_ = 1 to ring_len(_acN_)
			if StzFindFirst(_acN_[_i_], _acS_) = 0 and _TsAbs(_acN_[_i_], _acS_) = 0
				_ac_ + _acN_[_i_]
			ok
		next
		return _ac_

	def IsHonest()
		return ring_len(This.Unsourced()) = 0

	def Why()
		_n_ = ring_len(This.Numerals())
		if This.IsHonest()
			return "a Tukey story of " + ring_len(This.Paragraphs()) + " paragraph(s) and " + _n_ +
				" numeral(s), every one read from the fit or a finding"
		ok
		return "a Tukey story of " + ring_len(This.Paragraphs()) + " paragraph(s) and " + _n_ +
			" numeral(s), of which " + ring_len(This.Unsourced()) + " no source carries: " + @@(This.Unsourced())
