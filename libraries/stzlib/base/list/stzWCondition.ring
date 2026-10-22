/*
	stzWCondition -- a condition given as TEXT is judged, never run
	(threat-model R17).

	A W method takes its condition as a string: StringsW("len(@string) = 2").
	Several of them used to build "_b_ = " + condition and hand it to eval,
	so the condition was RING CODE: Ring needs no separator between
	statements, and "1 StzFileWrite(...)" wrote the file. That is the class
	PHP2Shell belongs to (text decoded into behaviour), measured on Ring 1.27
	and Ring++ on 2026-10-22.

	The engine already owns a W evaluator that FindW uses: a closed grammar
	of @item, @i, comparisons, len(), isString(), Q(@item).IsX() and the
	navigation keywords -- and NO calls into code. Everything here routes
	there:

		StzWPositions(aItems, cCondition)   the positions where it holds
		StzWValues(aItems, cExpression)     its value for every item

	Each W method's own keywords (@string, @char, @position) are lowered to
	the engine's (@item, @i) first, so the methods keep their meaning. A
	condition that needs real Ring logic -- calling your own functions --
	takes the WF form, which receives a function, not text.
*/

# The engine's keywords for a W method's own: @string and @char are the
# item, @position is its index; { } around a condition are dropped.
func StzWLower(pcExpr)
	_c_ = ring_trim("" + pcExpr)
	if len(_c_) >= 2 and left(_c_, 1) = "{" and right(_c_, 1) = "}"
		_c_ = ring_trim(substr(_c_, 2, len(_c_) - 2))
	ok
	_c_ = StzReplaceCS(_c_, "@string", "@item", 0)
	_c_ = StzReplaceCS(_c_, "@char", "@item", 0)
	_c_ = StzReplaceCS(_c_, "@position", "@i", 0)
	_c_ = StzReplaceCS(_c_, "@item", "@item", 0)
	return _c_

# The positions of aItems where the condition holds, judged by the engine.
func StzWPositions(paItems, pcCondition)
	if NOT isList(paItems) or len(paItems) = 0  return []  ok
	if NOT isString(pcCondition) or ring_trim(pcCondition) = ""  return []  ok
	_c_ = StzWLower(pcCondition)
	if StzIsQueryCondition(_c_)
		return _StzWCheckedPositions(paItems, _c_)
	ok
	_oW_ = new stzList(paItems)
	return _oW_.FindAllItemsW(_c_)

# The CHECKED form, for a condition the engine's grammar does not cover but
# that names nothing it could run: query methods on Q(@item) with literal
# arguments. Evaluated item by item -- safe only because StzIsQueryCondition
# admitted it, and never called on text it did not admit.
func _StzWCheckedPositions(paItems, pcCond)
	_aR_ = []
	_n_ = len(paItems)
	for _i_ = 1 to _n_
		@item = paItems[_i_]
		@i = _i_
		_bW_ = 0
		try
			eval("_bW_ = " + pcCond)
		catch
			_bW_ = 0
		done
		if _bW_  _aR_ + _i_  ok
	next
	return _aR_

func _StzWCheckedValues(paItems, pcExpr)
	_aR_ = []
	_n_ = len(paItems)
	for _i_ = 1 to _n_
		@item = paItems[_i_]
		@i = _i_
		_vW_ = ""
		eval("_vW_ = ( " + pcExpr + " )")
		_aR_ + _vW_
	next
	return _aR_

# The expression's value for every item, computed by the engine. Raises
# when the engine cannot compute it, rather than running it as code.
func StzWValues(paItems, pcExpr)
	if NOT isList(paItems) or len(paItems) = 0  return []  ok
	if NOT isString(pcExpr) or ring_trim(pcExpr) = ""
		stzraise("StzWValues: an expression is required.")
	ok
	_c_ = StzWLower(pcExpr)
	if StzIsQueryCondition(_c_)
		return _StzWCheckedValues(paItems, _c_)
	ok
	_oW_ = new stzList(paItems)
	_a_ = _oW_.Map(_c_)
	if NOT isList(_a_) or len(_a_) != len(paItems)
		stzraise("This expression needs Ring logic the W engine does not evaluate: '" + pcExpr +
			"'. A text condition is judged, never run; pass a function instead (the WF form).")
	ok
	return _a_

# 1 when pcName is a plain identifier: letters, digits and _ only, not
# starting with a digit -- what may be pasted into a method name.
func StzIsPlainIdentifier(pcName)
	if NOT isString(pcName) or pcName = ""  return 0  ok
	_n_ = len(pcName)
	for _i_ = 1 to _n_
		_k_ = ascii(pcName[_i_])
		_bOk_ = (_k_ >= 65 and _k_ <= 90) or (_k_ >= 97 and _k_ <= 122) or _k_ = 95 or
			(_i_ > 1 and _k_ >= 48 and _k_ <= 57)
		if NOT _bOk_  return 0  ok
	next
	return 1

# 1 when a "list in a string" holds only literal data: no letters outside
# quotes except TRUE, FALSE and NULL, so it cannot name a function. Used
# before ToList() evaluates the literal.
func StzIsPlainListLiteral(pcText)
	if NOT isString(pcText)  return 0  ok
	_n_ = len(pcText)
	_cQ_ = ""
	_cWord_ = ""
	for _i_ = 1 to _n_ + 1
		if _i_ <= _n_  _ch_ = pcText[_i_]  else  _ch_ = " "  ok
		if _cQ_ != ""
			if _ch_ = _cQ_  _cQ_ = ""  ok
			loop
		ok
		if _ch_ = '"' or _ch_ = "'" or _ch_ = "`"
			_cQ_ = _ch_
			loop
		ok
		_k_ = ascii(_ch_)
		if (_k_ >= 65 and _k_ <= 90) or (_k_ >= 97 and _k_ <= 122) or _k_ = 95 or _k_ >= 128
			_cWord_ += _ch_
		else
			if _cWord_ != ""
				_cW_ = lower(_cWord_)
				if _cW_ != "true" and _cW_ != "false" and _cW_ != "null"  return 0  ok
				_cWord_ = ""
			ok
			if _ch_ = "(" or _ch_ = "{" or _ch_ = "@" or _ch_ = "$"  return 0  ok
		ok
	next
	return 1

# 1 when a condition (already lowered) names NOTHING that could act. Outside
# quotes, every word must be one of:
#   - and, or, not, true, false, null
#   - a variable (@item, @i) or a symbol (:CS) -- what follows @ or :
#   - Q, opening Q( ... ) on a value
#   - This, only as This[ ... ] (reading an item, never a method of the list)
#   - a method name right after a dot that ASKS: Is..., Has..., Contains...,
#     StartsWith..., EndsWith..., NumberOf..., Count..., Size, Len...
#   - one of the engine's pure functions: len, lower, upper, trim, ascii, abs,
#     round, floor, ceil, number, string, left, right, isstring, isnumber, islist
# A second statement needs a word outside this list, so it cannot be smuggled in.
func StzIsQueryCondition(pcCond)
	if NOT isString(pcCond)  return 0  ok
	_acPure_ = [ "len", "lower", "upper", "trim", "ascii", "abs", "round", "floor", "ceil",
		"number", "string", "left", "right", "isstring", "isnumber", "islist" ]
	_acAsk_ = [ "is", "has", "contains", "startswith", "endswith", "numberof", "count", "size", "len" ]
	_n_ = len(pcCond)
	_cQ_ = ""
	_bHasMethod_ = 0
	_i_ = 1
	while _i_ <= _n_
		_ch_ = pcCond[_i_]
		if _cQ_ != ""
			if _ch_ = _cQ_  _cQ_ = ""  ok
			_i_++  loop
		ok
		if _ch_ = '"' or _ch_ = "'" or _ch_ = "`"
			_cQ_ = _ch_  _i_++  loop
		ok
		if _ch_ = "{" or _ch_ = "}" or _ch_ = "$" or _ch_ = ";"  return 0  ok
		_k_ = ascii(_ch_)
		if (_k_ >= 65 and _k_ <= 90) or (_k_ >= 97 and _k_ <= 122) or _k_ = 95
			_j_ = _i_
			while _j_ <= _n_
				_kj_ = ascii(pcCond[_j_])
				if NOT ( (_kj_ >= 65 and _kj_ <= 90) or (_kj_ >= 97 and _kj_ <= 122) or _kj_ = 95 or (_kj_ >= 48 and _kj_ <= 57) )  exit  ok
				_j_++
			end
			_cW_ = lower(substr(pcCond, _i_, _j_ - _i_))
			_cPrev_ = ""
			if _i_ > 1  _cPrev_ = pcCond[_i_ - 1]  ok
			_cNext_ = ""
			_m_ = _j_
			while _m_ <= _n_ and pcCond[_m_] = " "  _m_++  end
			if _m_ <= _n_  _cNext_ = pcCond[_m_]  ok
			_bOk_ = 0
			if _cPrev_ = "@" or _cPrev_ = ":"
				_bOk_ = 1
			but _cW_ = "and" or _cW_ = "or" or _cW_ = "not" or _cW_ = "true" or _cW_ = "false" or _cW_ = "null"
				_bOk_ = 1
			but _cW_ = "q" and _cNext_ = "("
				_bOk_ = 1
			but _cW_ = "this" and _cNext_ = "["
				_bOk_ = 1
			but _cPrev_ = "."
				for _a_ = 1 to len(_acAsk_)
					if left(_cW_, len(_acAsk_[_a_])) = _acAsk_[_a_]  _bOk_ = 1  _bHasMethod_ = 1  exit  ok
				next
			but find(_acPure_, _cW_) > 0 and _cNext_ = "("
				_bOk_ = 1
			ok
			if NOT _bOk_  return 0  ok
			_i_ = _j_
			loop
		ok
		_i_++
	end
	# Only worth the checked path when there is a method call the engine
	# cannot take; everything else goes to the engine itself.
	return _bHasMethod_
