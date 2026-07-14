# R4 step 3 -- stzModelEval: THE EVALUATION SEED
# Scoring predictions against truth -- the metrics every learner in
# learning/ reports through (the richer statistical layer rides
# stats/stzDataSet: correlation/regression already engine-backed).

func StzAccuracy(pacPredicted, pacTruth)
	_n_ = len(pacPredicted)
	if len(pacTruth) < _n_
		_n_ = len(pacTruth)
	ok
	if _n_ = 0
		return 0
	ok
	_nOk_ = 0
	for _i_ = 1 to _n_
		if pacPredicted[_i_] = pacTruth[_i_]
			_nOk_++
		ok
	next
	return _nOk_ / _n_

# [ [ "truth->predicted", count ] ... ] -- every confusion named
func StzConfusionMatrix(pacPredicted, pacTruth)
	_aC_ = []
	_n_ = len(pacPredicted)
	if len(pacTruth) < _n_
		_n_ = len(pacTruth)
	ok
	for _i_ = 1 to _n_
		_cKey_ = "" + pacTruth[_i_] + "->" + pacPredicted[_i_]
		if HasKey(_aC_, _cKey_)
			_aC_[_cKey_] = _aC_[_cKey_] + 1
		else
			_aC_[_cKey_] = 1
		ok
	next
	return _aC_
