# PROBE TK4 -- MEASURE the shape statistics before any threshold is written:
# skewness as Tukey's mid-summary ((F_lo + F_hi) / 2 - M) / F-spread, tail
# weight as the letter-spread ratio E-spread / F-spread (Gaussian 1.7054),
# and the spread-versus-level slope, each on 20 seeded batches of _a_ class
# that should NOT fire and 20 of _a_ class that should.
load "../../stzBase.ring"

_nSeed_ = 12345
for n in [ 50, 200 ]
	? "n = " + n
	? "  skew    normal " + _PbRange("normal", n, "skew") + "  uniform " + _PbRange("uniform", n, "skew") + "  t2 " + _PbRange("t2", n, "skew")
	? "  skew    exponential " + _PbRange("exponential", n, "skew") + "  lognormal " + _PbRange("lognormal", n, "skew")
	? "  tail/G  normal " + _PbRange("normal", n, "tail") + "  uniform " + _PbRange("uniform", n, "tail") + "  exponential " + _PbRange("exponential", n, "tail")
	? "  tail/G  t2 " + _PbRange("t2", n, "tail") + "  cauchy " + _PbRange("cauchy", n, "tail") + "  lognormal " + _PbRange("lognormal", n, "tail")
next

# spread versus level: five groups whose medians climb; spreads constant (no) or proportional (yes)
for bP in [ 0, 1 ]
	_nMin_ = 0  _nMax_ = 0
	for _k_ = 1 to 20
		_r_ = StzTukeySpreadLevel(_PbGroups(bP, 0.5))
		_v_ = _r_[:slope]
		if _k_ = 1  _nMin_ = _v_  _nMax_ = _v_  ok
		if _v_ < _nMin_  _nMin_ = _v_  ok
		if _v_ > _nMax_  _nMax_ = _v_  ok
	next
	? "spread-level slope, proportional=" + bP + "  [" + _FfNum(_nMin_, 4) + " .. " + _FfNum(_nMax_, 4) + "]"
next


# SECOND STAGE: the outer letters. Skew as the mean drift of the F, E and D
# mid-summaries from M over the F-spread; tail weight as the D-spread over
# the F-spread against the Gaussian's 2.2745. Then, at each n, the null
# classes' extreme and how many positive batches clear it.
for _nn_ in [ 100, 200, 400 ]
	? "n = " + _nn_
	_PbSeparate("skew3", _nn_, [ "normal", "uniform", "t2" ], [ "exponential", "lognormal" ])
	_PbSeparate("tailD", _nn_, [ "normal", "uniform" ], [ "t2", "cauchy" ])
next

func _PbU()
	_nSeed_ = (_nSeed_ * 16807) % 2147483647
	return _nSeed_ / 2147483647

func _PbGaussian()
	_u1_ = _PbU()  _u2_ = _PbU()
	return sqrt(-2 * log(_u1_)) * cos(2 * 3.14159265358979 * _u2_)

func _PbBatch(_cKind_, _nCount_)
	_a_ = []
	for _i_ = 1 to _nCount_
		if _cKind_ = "normal"
			_a_ + _PbGaussian()
		but _cKind_ = "uniform"
			_a_ + (_PbU() * 10)
		but _cKind_ = "exponential"
			_a_ + (-log(1 - _PbU()))
		but _cKind_ = "lognormal"
			_a_ + exp(_PbGaussian())
		but _cKind_ = "t2"
			_z_ = _PbGaussian()
			_g1_ = _PbGaussian()
			_g2_ = _PbGaussian()
			_v_ = _g1_ * _g1_ + _g2_ * _g2_
			_a_ + (_z_ / sqrt(_v_ / 2))
		but _cKind_ = "cauchy"
			_a_ + tan(3.14159265358979 * (_PbU() - 0.5))
		ok
	next
	return _a_

func _PbSkew(_a_)
	_o_ = StzTukeySummaryQ(_a_)
	_h_ = _o_.Fourths()
	return ((_h_[1] + _h_[2]) / 2 - _o_.Median()) / (_h_[2] - _h_[1])

func _PbTail(_a_)
	_o_ = StzTukeySummaryQ(_a_)
	_lv_ = _o_.LetterValues(3)
	return (_lv_[3][6] / _lv_[2][6]) / 1.7054

func _PbRange(_cKind_, n, _cStat_)
	_nMin_ = 0  _nMax_ = 0
	for _k_ = 1 to 20
		_a_ = _PbBatch(_cKind_, n)
		if _cStat_ = "skew"  _v_ = _PbSkew(_a_)  else  _v_ = _PbTail(_a_)  ok
		if _k_ = 1  _nMin_ = _v_  _nMax_ = _v_  ok
		if _v_ < _nMin_  _nMin_ = _v_  ok
		if _v_ > _nMax_  _nMax_ = _v_  ok
	next
	return "[" + _FfNum(_nMin_, 4) + " .. " + _FfNum(_nMax_, 4) + "]"

func _PbGroups(_bProp_, _nNoise_)
	_g_ = []
	for _i_ = 1 to 5
		_lvl_ = 10 * _i_
		_sp_ = 2
		if _bProp_  _sp_ = 0.2 * _lvl_  ok
		_a_ = []
		for _k_ = 1 to 30  _a_ + (_lvl_ + _sp_ * _PbGaussian() * (1 + _nNoise_ * (_PbU() - 0.5)))  next
		_g_ + _a_
	next
	return _g_


func _PbSkew3(_a_)
	_o_ = StzTukeySummaryQ(_a_)
	_lv_ = _o_.LetterValues(4)
	_m_ = _lv_[1][5]
	_f_ = _lv_[2][6]
	return ((_lv_[2][5] - _m_) + (_lv_[3][5] - _m_) + (_lv_[4][5] - _m_)) / 3 / _f_

func _PbTailD(_a_)
	_o_ = StzTukeySummaryQ(_a_)
	_lv_ = _o_.LetterValues(4)
	return (_lv_[4][6] / _lv_[2][6]) / 2.2745

func _PbStat(_cStat_, _a_)
	if _cStat_ = "skew3"  return fabs(_PbSkew3(_a_))  ok
	return _PbTailD(_a_)

func _PbSeparate(_cStat_, _nn_, _acNull_, _acPos_)
	_nNullMax_ = 0
	_nNullN_ = 0
	for _c_ = 1 to len(_acNull_)
		for _k_ = 1 to 20
			_v_ = _PbStat(_cStat_, _PbBatch(_acNull_[_c_], _nn_))
			_nNullN_++
			if _v_ > _nNullMax_  _nNullMax_ = _v_  ok
		next
	next
	_c_ = "  " + _cStat_ + ": null max " + _FfNum(_nNullMax_, 4) + " over " + _nNullN_ + " batches;"
	for _p_ = 1 to len(_acPos_)
		_nAbove_ = 0
		_nMin_ = 0
		for _k_ = 1 to 20
			_v_ = _PbStat(_cStat_, _PbBatch(_acPos_[_p_], _nn_))
			if _k_ = 1  _nMin_ = _v_  ok
			if _v_ < _nMin_  _nMin_ = _v_  ok
			if _v_ > _nNullMax_  _nAbove_++  ok
		next
		_c_ += " " + _acPos_[_p_] + " clears it " + _nAbove_ + "/20 (min " + _FfNum(_nMin_, 4) + ");"
	next
	? _c_
