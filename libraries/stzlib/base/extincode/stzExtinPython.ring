# Functions for porting Python code to Ring

func range0(p)
	# Python...	: range(3) 		--> [0, 1, 2]
	# Python..	: range(-3, 4, 2)	--> [-3, -1, 1, 3 ]
	_aResult_ = []
	if isNumber(p)
		# range(n) : 0 <= x < n	--> n not included!
		if p > 0	
			_aResult_ = 0 : (p - 1)
		ok
	but isList(p)
		if @IsListOfNumbers(p)
			# range(n1, n2): n1 <= x < n2
			#--> n1 included, but n2 not included!
			if len(p) = 2
				if p[1] < p[2]
					_aResult_ = p[1] : (p[2]-1)
				ok
			# range(n1, n2, step): n1 <= x < n2 (increasing by step)
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

	func range0Q(p)
		return new stzList(@range(p))

	func range(p)
		return range0(p)
		func @range(p)
			return range0(p)
		return rangeQ(p)
			return range0Q(p)

func range1(p)
	_aResult_ = []
	if isNumber(p)
		# Example: range1(3) #--> [ 1, 2, 3 ]
		_aResult_ = 1 : p
	but isList(p)
		if @IsListOfNumbers(p)
			if len(p) = 3
				_aResult_ = []
				for i = p[1] to p[2] step p[3]
					_aResult_ + i
				next
			but len(p) = 2
				_aResult_ = p[1] : p[2]
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
			_n1_ = 1
			if _acNumbers_[1] != ""
				_n1_ = 0 + _acNumbers_[1]
			ok
			_n2_ = 0 + _acNumbers_[2]
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
	def range1Q(p)
		return new stzList(range1(p))

func print(str)
	? str

	func echo(str)
		print(str)

	func WriteLine(str)
		print(str)

	func println(str)
		print(str)

	func printf(str)
		print(str)

func f(str)
	return Interpoltate(str)

func exec(_cCode_)
	eval(_cCode_)

func _if(pExpressionOrBoolean)
	if len(_aTempVars) = 0
	    StzRaise("No temp vars defined! Call vr() first.")
	ok
	_bVarReset = 0
	_bTemp_ = 1
	if isString(pExpressionOrBoolean)
		_cCode_ = '_bTemp_ = (' + pExpressionOrBoolean + ')'
		eval(_cCode_)
	but ( isNumber(pExpressionOrBoolean) and (pExpressionOrBoolean = 0 or pExpressionOrBoolean = 1) )
		_bTemp_ = pExpressionOrBoolean
	ok
	if _bTemp_ = 0
		_bVarReset = 1
	ok
	func if_(pExpressionOrBoolean)
		return _if(pExpressionOrBoolean)

func _else(_value_)
    _aValues_ = []
    if NOT isList(_value_)
        _aTemp_ = []
        _aTemp_ + _value_
        _value_ = _aTemp_
    ok
    _aValues_ = _value_
    if _bVarReset = 1 and len(_aTempVars) > 0
        _nTempVars_ = len(_aTempVars)
        _nValues_ = len(_aValues_)
        _nLen_ = @Min([ _nTempVars_, _nValues_ ])
        _oHash_ = new stzHashList(_aVars)
        for i = 1 to _nLen_
            _cVarName_ = _aTempVars[i][1]
            _aTempVars[i][2] = _aValues_[i]
            _n_ = _oHash_.FindKey(_cVarName_)
            if _n_ > 0
                _aVars[_n_][2] = _aValues_[i]
            else
                _aVars + [ _cVarName_, _aValues_[i] ]
            ok
            if ObjectIsStzObject(_aValues_[i])
                _aValues_[i].SetObjectVarNameTo(_cVarName_)
            ok
        next
        if _nLen_ > 0
            _var = [ _aTempVars[_nLen_][1], _aValues_[_nLen_] ]
        ok
        if oldval() = ""
            _oldVar = _var
        ok
    ok
    func else_(_value_)
        return _else(_value_)
