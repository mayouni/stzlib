# PROBE -- MEASURE before the threshold: a change point in a series as the
# largest step of the 3RS3R smooth, in units of the rough's fourth-spread.
# Null classes: a level with noise, a trend with noise. Positive classes: a
# step of 2, 3 and 5 noise-sigmas at the middle. Twenty seeded series each.
load "../../stzBase.ring"
nPcSeed = 4242
# THE COUNT AT THE CANDIDATE THRESHOLD, window 10 each side
for n in [ 40, 100 ]
	? "n = " + n + "  window 10; how many of 20 clear 1.8, and where the largest contrast sits"
	for cKind in [ "level", "trend", "step2", "step3", "step5" ]
		nMin = 0  nMax = 0  nHits = 0  nFire = 0
		for k = 1 to 20
			a = _PcSeries(cKind, n)
			r = _PcContrast(a, 10)
			if k = 1  nMin = r[1]  nMax = r[1]  ok
			if r[1] < nMin  nMin = r[1]  ok
			if r[1] > nMax  nMax = r[1]  ok
			if r[1] > 1.8  nFire++  ok
			if fabs(r[2] - (floor(n / 2) + 1)) <= 2  nHits++  ok
		next
		? "  " + cKind + "  [" + _FfNum(nMin, 3) + " .. " + _FfNum(nMax, 3) + "]  fires " + nFire + "/20  located within 2 " + nHits + "/20"
	next
next

func _PcU
	nPcSeed = (nPcSeed * 16807) % 2147483647
	return nPcSeed / 2147483647

func _PcGaussian
	_u1_ = _PcU()
	_u2_ = _PcU()
	return sqrt(-2 * log(_u1_)) * cos(2 * 3.14159265358979 * _u2_)

func _PcSeries cKind, n
	_a_ = []
	for _i_ = 1 to n
		_v_ = 10 + _PcGaussian()
		if cKind = "trend"  _v_ += 0.1 * _i_  ok
		if cKind = "step2" and _i_ > n / 2  _v_ += 2  ok
		if cKind = "step3" and _i_ > n / 2  _v_ += 3  ok
		if cKind = "step5" and _i_ > n / 2  _v_ += 5  ok
		_a_ + _v_
	next
	return _a_

# [ largest |step of the smooth| over the rough's fourth-spread, its index ]
func _PcStat a
	_o_ = StzTukeySmootherQ(a)
	_aS_ = _o_.Smooth3RS3R()
	_aR_ = _o_.Rough("3RS3R")
	_nF_ = StzTukeySummaryQ(_aR_).FourthSpread()
	if _nF_ <= 0  return [ 0, 0 ]  ok
	_nMax_ = 0  _nAt_ = 0
	for _i_ = 1 to len(_aS_) - 1
		_d_ = fabs(_aS_[_i_ + 1] - _aS_[_i_]) / _nF_
		if _d_ > _nMax_  _nMax_ = _d_  _nAt_ = _i_ + 1  ok
	next
	return [ _nMax_, _nAt_ ]

# [ the largest |median(after) - median(before)| over the rough's fourth-spread, its index ]
# with w values on each side of the candidate cut
func _PcContrast a, w
	# THE SCALE: the fourth-spread of the consecutive differences -- blind to a
	# level and to a trend, and resistant to the one big difference a step makes
	_aDx_ = []
	for _i_ = 1 to len(a) - 1  _aDx_ + (a[_i_ + 1] - a[_i_])  next
	_nF_ = StzTukeySummaryQ(_aDx_).FourthSpread()
	if _nF_ <= 0  return [ 0, 0 ]  ok
	_nMax_ = 0  _nAt_ = 0
	for _t_ = w to len(a) - w
		_aB_ = []  _aA_ = []
		for _i_ = _t_ - w + 1 to _t_  _aB_ + a[_i_]  next
		for _i_ = _t_ + 1 to _t_ + w  _aA_ + a[_i_]  next
		_d_ = fabs(StzEngineStatsMedian(StzEngineStatsCreate(_aA_)) - StzEngineStatsMedian(StzEngineStatsCreate(_aB_))) / _nF_
		if _d_ > _nMax_  _nMax_ = _d_  _nAt_ = _t_ + 1  ok
	next
	return [ _nMax_, _nAt_ ]
