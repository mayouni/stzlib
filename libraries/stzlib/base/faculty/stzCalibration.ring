#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZCALIBRATION                 #
#--------------------------------------------------------------#
#                                                              #
#   Description  : the calibration ledger. Evidentiality was a  #
#                  declared vocabulary (certain / probable /    #
#                  apparent); this records, for every answer    #
#                  whose truth later became known, the band it  #
#                  was given, the probability it carried and    #
#                  whether it was RIGHT -- so "certain" can be  #
#                  checked to be right more often than          #
#                  "apparent". (COMPASS-JEV-CALIBRATION-01;     #
#                  SOFTANZA_MODEL_FLOW.md section 9.3.)         #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

# rows: [ :faculty, :impl, :band, :p, :correct ]    append-only
$aStzCalibration = []

# The bands, strongest first. A band is the evidential word an answer carried.
func StzCalibrationBands()
	return [ "certain", "probable", "apparent" ]

# the band a probability earns: the SAME thresholds everywhere, so ledgers compare
func StzBandOfProbability(pnP)
	if pnP >= 0.95 return "certain" ok
	if pnP >= 0.75 return "probable" ok
	return "apparent"

func StzRecordCalibration(pcFaculty, pcImpl, pcBand, pnP, pbCorrect)
	add($aStzCalibration, [ :faculty = pcFaculty, :impl = pcImpl, :band = pcBand, :p = pnP, :correct = pbCorrect ])

func StzClearCalibration()
	$aStzCalibration = []

func StzCalibrationRows(pcFaculty, pcImpl)
	_a_ = []
	for _i_ = 1 to len($aStzCalibration)
		_r_ = $aStzCalibration[_i_]
		if (pcFaculty = "" or _r_[:faculty] = pcFaculty) and (pcImpl = "" or _r_[:impl] = pcImpl)
			add(_a_, _r_)
		ok
	next
	return _a_

# -> [ [ band, n, accuracy, meanP ] ... ] in band order; accuracy = share RIGHT among answers given that band
func StzReliability(pcFaculty, pcImpl)
	_aBands_ = StzCalibrationBands()
	_aOut_ = []
	_aRows_ = StzCalibrationRows(pcFaculty, pcImpl)
	for _b_ = 1 to len(_aBands_)
		_n_ = 0 _ok_ = 0 _sp_ = 0
		for _i_ = 1 to len(_aRows_)
			if _aRows_[_i_][:band] = _aBands_[_b_]
				_n_++
				_ok_ += _aRows_[_i_][:correct]
				_sp_ += _aRows_[_i_][:p]
			ok
		next
		_acc_ = -1 _mp_ = -1
		if _n_ > 0
			_acc_ = _ok_ / _n_
			_mp_ = _sp_ / _n_
		ok
		add(_aOut_, [ _aBands_[_b_], _n_, _acc_, _mp_ ])
	next
	return _aOut_

# The guard's question: is a HIGHER band right at least as often as a LOWER one? Returns findings in the house
# shape (empty = calibrated as far as the evidence goes). Bands with fewer than pnMin answers are not judged: a
# verdict on three answers is noise, and the finding says which bands were too thin to judge.
func StzCalibrationFindings(pcFaculty, pcImpl, pnMin)
	_aF_ = []
	_aRel_ = StzReliability(pcFaculty, pcImpl)
	_last_ = ""
	_lastAcc_ = -1
	for _i_ = 1 to len(_aRel_)
		if _aRel_[_i_][2] < pnMin
			if _aRel_[_i_][2] > 0
				_w_ = _StzFlowFinding("calibration-thin", pcFaculty + ":" + pcImpl + " " + _aRel_[_i_][1],
					"only " + _aRel_[_i_][2] + " answer(s) in this band: too few to judge")
				_w_[:severity] = :warning
				add(_aF_, _w_)
			ok
			loop
		ok
		if _lastAcc_ >= 0 and _aRel_[_i_][3] > _lastAcc_ + 0.0001
			add(_aF_, _StzFlowFinding("calibration-inverted", pcFaculty + ":" + pcImpl,
				"band '" + _aRel_[_i_][1] + "' was right " + _aRel_[_i_][3] + " of the time but the HIGHER band '" + _last_ + "' only " + _lastAcc_ +
				": the evidential words do not mean what they say"))
		ok
		_last_ = _aRel_[_i_][1]
		_lastAcc_ = _aRel_[_i_][3]
	next
	return _aF_

# A plain-text reliability table: the diagram's data, readable without a plot. (The plot-plane render of the
# same rows is the instrument the design owes; this is its floor.)
func StzReliabilityText(pcFaculty, pcImpl)
	_aRel_ = StzReliability(pcFaculty, pcImpl)
	_c_ = "reliability of " + pcFaculty + ":" + pcImpl + char(10)
	for _i_ = 1 to len(_aRel_)
		_c_ += "  " + _aRel_[_i_][1] + char(9) + "n=" + _aRel_[_i_][2]
		if _aRel_[_i_][2] > 0
			_nBar_ = floor(_aRel_[_i_][3] * 20)
			_bar_ = ""
			for _k_ = 1 to _nBar_ _bar_ += "#" next
			_c_ += char(9) + "right " + _aRel_[_i_][3] + char(9) + "mean p " + _aRel_[_i_][4] + char(9) + _bar_
		ok
		_c_ += char(10)
	next
	return _c_
