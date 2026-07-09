# Functions for porting PHP code to Ring

func echo(str)
	? str

func range0(p)
	# PHP...	: range(1, 3) 		--> [1, 2, 3]
	_aResult_ = []
	if isNumber(p)
		if p > 0	
			_aResult_ = 0 : (p - 1)
		ok
	but isList(p)
		if Q(p).IsListOfNumbers()
			if len(p) = 2
				if p[1] < p[2]
					_aResult_ = p[1] : (p[2]-1)
				ok
			but len(p) = 3
				_aResult_ = []
				if p[1] < p[2] and p[3] > 0
					for i = p[1] to p[2]-1 step p[3]
						_aResult_ + i
					next
				but p[1] > p[2] and p[3] < 0
					for i = p[1] to p[2]+1 step p[3]
						_aResult_ + i
					next
				ok
			ok
		ok
	but isString(p)
		_oStr_ = new stzString(p)
		if _oStr_.NumberOfOccurrenceQ(":").IsEither(1, 2) and
		   _oStr_.Copy().RemoveManyQ([":", "-"]).IsNumberInString()
			_acNumbers_ = _oStr_.SplitAt(":")
			_nLen_ = len(_acNumbers_)
			if _acNumbers_[2] = ""
				StzRaise("Incorrect syntax! The second parameter must not be empty.")
			ok
			_n1_ = 0
			if _acNumbers_[1] != ""
				_n1_ = 0 + _acNumbers_[1] + 1
			ok
			_n2_ = 0 + _acNumbers_[2] - 1
			_nStep_ = 1
			if _nLen_ = 3
				_nStep_ = 0 + _acNumbers_[3]
			ok
			_aResult_ = []
			if _nStep_ < 0
				_nTemp_ = _n1_
				_n1_ = _n2_
				_n2_ = _nTemp_
			ok
			for i = _n1_ to _n2_ step _nStep_
				_aResult_ + i
			next
		ok
	else
		StzRaise("Unsupported syntax!")
	ok
	return _aResult_
