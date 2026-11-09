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
	# The condition names the engine's @item and @i; here they are _item_ and
	# _i_, the loop's own locals -- an @name in a plain function is refused
	# under Ring++'s Rule A. Rewritten before the eval, as FirstNPrimesW does.
	# admitted again HERE, in the body that runs it: the caller's check is
	# not seen by Haro's checker, and must not need to be trusted
	if NOT StzIsQueryCondition(pcCond)  stzraise("This condition names something the W engine does not judge.")  ok
	pcCond = StzReplaceCS(StzReplaceCS(pcCond, "@item", "_item_", 0), "@i", "_i_", 0)
	for _i_ = 1 to _n_
		_item_ = paItems[_i_]
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
	# The condition names the engine's @item and @i; here they are _item_ and
	# _i_, the loop's own locals -- an @name in a plain function is refused
	# under Ring++'s Rule A. Rewritten before the eval, as FirstNPrimesW does.
	if NOT StzIsQueryCondition(pcExpr)  stzraise("This expression names something the W engine does not judge.")  ok
	pcExpr = StzReplaceCS(StzReplaceCS(pcExpr, "@item", "_item_", 0), "@i", "_i_", 0)
	for _i_ = 1 to _n_
		_item_ = paItems[_i_]
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
# quotes except TRUE, FALSE, NULL and :symbols, so it cannot name a function. Used
# before ToList() evaluates the literal.
func StzIsPlainListLiteral(pcText)
	if NOT isString(pcText)  return 0  ok
	_n_ = len(pcText)
	_cQ_ = ""
	_cWord_ = ""
	_bSym_ = 0
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
		if (_k_ >= 65 and _k_ <= 90) or (_k_ >= 97 and _k_ <= 122) or _k_ = 95 or _k_ >= 128 or
		   (_cWord_ != "" and _k_ >= 48 and _k_ <= 57)
			# a : starts a symbol only where a token can start -- after [ , = ( a space
			# or a tab, or at the start. In [1:limit] the : is Ring's range and limit
			# is a variable: not a symbol, so the text is refused
			if _cWord_ = "" and _i_ > 1 and pcText[_i_ - 1] = ":"
				if _i_ = 2
					_bSym_ = 1
				else
					_cBefore_ = pcText[_i_ - 2]
					if _cBefore_ = "[" or _cBefore_ = "," or _cBefore_ = "=" or _cBefore_ = "(" or
					   _cBefore_ = " " or _cBefore_ = char(9)
						_bSym_ = 1
					ok
				ok
			ok
			_cWord_ += _ch_
		else
			if _cWord_ != ""
				# a :symbol is a text; any other word must be true, false or null
				_cW_ = lower(_cWord_)
				if NOT _bSym_ and _cW_ != "true" and _cW_ != "false" and _cW_ != "null"  return 0  ok
				_cWord_ = ""
				_bSym_ = 0
			ok
			if _ch_ = "(" or _ch_ = "{" or _ch_ = "@" or _ch_ = "$"  return 0  ok
			# a : that does not start a symbol is Ring's range operator: [1:3000000000]
			# builds that many items, so a range is never literal data here
			if _ch_ = ":"
				if _i_ >= _n_  return 0  ok
				_kN_ = ascii(pcText[_i_ + 1])
				if NOT ( (_kN_ >= 65 and _kN_ <= 90) or (_kN_ >= 97 and _kN_ <= 122) or _kN_ = 95 )  return 0  ok
				if _i_ > 1
					_cB_ = pcText[_i_ - 1]
					if NOT ( _cB_ = "[" or _cB_ = "," or _cB_ = "=" or _cB_ = "(" or _cB_ = " " or _cB_ = char(9) )  return 0  ok
				ok
			ok
		ok
	next
	return 1

# 1 when a condition (already lowered) names NOTHING that could act. Outside
# quotes, every word must be one of:
#   - and, or, not, true, false, null
#   - a variable (@item, @i) or a symbol (:CS) -- what follows @ or :
#   - Q or StzCharQ, opening Q( ... ) / StzCharQ( ... ) on a value
#   - This, only as This[ ... ] (reading an item, never a method of the list)
#   - a method name right after a dot that ASKS: Is..., Has..., Contains...,
#     StartsWith..., EndsWith..., NumberOf..., Count..., Size, Len...,
#     or one of the char's value queries: Script, CharCase, Orientation,
#     Category, Direction, Unicode, Name (they read, never act)
#   - one of the engine's pure functions: len, lower, upper, trim, ascii, abs,
#     round, floor, ceil, number, string, left, right, isstring, isnumber, islist
# A second statement needs a word outside this list, so it cannot be smuggled in.
func StzIsQueryCondition(pcCond)
	if NOT isString(pcCond)  return 0  ok
	_acPure_ = [ "len", "lower", "upper", "trim", "ascii", "abs", "round", "floor", "ceil",
		"number", "string", "left", "right", "isstring", "isnumber", "islist" ]
	_acAsk_ = [ "is", "has", "contains", "startswith", "endswith", "numberof", "count", "size", "len" ]
	_acValueQ_ = [ "script", "charcase", "orientation", "category", "direction", "unicode", "name" ]
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
			but (_cW_ = "q" or _cW_ = "stzcharq") and _cNext_ = "("
				_bOk_ = 1
			but _cW_ = "this" and _cNext_ = "["
				_bOk_ = 1
			but _cPrev_ = "."
				for _a_ = 1 to len(_acAsk_)
					if left(_cW_, len(_acAsk_[_a_])) = _acAsk_[_a_]  _bOk_ = 1  _bHasMethod_ = 1  exit  ok
				next
				if find(_acValueQ_, _cW_) > 0  _bOk_ = 1  _bHasMethod_ = 1  ok
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

# 1 when p is a function the program can call: a named function or an
# anonymous one (func x { ... }), both names isfunction() knows.
func StzIsFunctionValue(p)
	if NOT isString(p) or p = ""  return 0  ok
	return isfunction(p)

# Raises unless p is a function: an API that used to take CODE AS TEXT takes a
# function instead, because Haro runs no text as code (PRINCIPAL-HAROFIRST-01).
func StzRequireFunction(p, pcWhat)
	if NOT StzIsFunctionValue(p)
		stzraise(pcWhat + " takes a function, not code as text: pass func x { ... } " +
			"(Haro runs no text as code).")
	ok

# The value of an expression for every item: a FUNCTION of the item is called
# on each; an expression given as text is a W expression the engine computes
# (StzWValues), never run as code.
func _StzValuesOfItems(paItems, pExpr)
	if StzIsFunctionValue(pExpr)
		_aR_ = []
		_n_ = len(paItems)
		for _i_ = 1 to _n_
			_aR_ + call pExpr(paItems[_i_])
		next
		return _aR_
	ok
	return StzWValues(paItems, pExpr)

# Calls the method named pcMethod on poObject with the values of paArgs, and returns its answer.
#
#   poObject   the object
#   pcMethod   a method NAME, alone (Content, not Content()); anything else is refused
#   paArgs     the arguments as values, at most 4; none is put into code
#   returns    what the method returns
#   note       the one text run here is the checked name between fixed code -- the checked form
#              haro check admits; a later Haro dispatch table replaces even that
#   see        StzIsPlainIdentifier
func StzCallMethodOn(poObject, pcMethod, paArgs)
	if NOT isobject(poObject)
		StzRaise("Can't call the method! poObject must be an object.")
	ok
	if NOT islist(paArgs)
		paArgs = [ paArgs ]
	ok
	cName = "" + pcMethod
	if right(cName, 2) = "()"
		cName = left(cName, len(cName) - 2)
	ok
	if NOT StzIsPlainIdentifier(cName)
		StzRaise("Can't call the method! '" + cName + "' is not a plain name, and a name is all that is run here.")
	ok
	nArgs = len(paArgs)
	if nArgs > 4
		StzRaise("Can't call the method! At most 4 arguments are passed.")
	ok
	aArgCode = [ "", "paArgs[1]", "paArgs[1], paArgs[2]", "paArgs[1], paArgs[2], paArgs[3]",
		"paArgs[1], paArgs[2], paArgs[3], paArgs[4]" ]
	xResult = ""
	eval("xResult = poObject." + cName + "(" + aArgCode[nArgs + 1] + ")")
	return xResult

# Reads a call written as text -- Name, Name() or Name(arg, arg ...) -- into its name and the
# VALUES of its arguments, running nothing.
#
#   pcText     the call text; each argument is a literal: a number, a quoted text, a :symbol, or
#              a list of literal data
#   returns    [ cName, aArgs ]
#   note       anything else -- a variable, an expression, a second call -- is refused by name
#   see        StzLiteralValue, StzCallMethodOn
func StzParseCallText(pcText)
	if NOT isstring(pcText)
		StzRaise("Can't read the call! It must be a text.")
	ok
	cText = trim(pcText)
	nOpen = substr(cText, "(")
	if nOpen = 0
		if NOT StzIsPlainIdentifier(cText)
			StzRaise("Can't read the call '" + pcText + "'! A name alone, or Name(literal values), is read.")
		ok
		return [ cText, [] ]
	ok
	cName = trim(left(cText, nOpen - 1))
	if NOT StzIsPlainIdentifier(cName) or right(cText, 1) != ")"
		StzRaise("Can't read the call '" + pcText + "'! A name alone, or Name(literal values), is read.")
	ok
	cInside = substr(cText, nOpen + 1, len(cText) - nOpen - 1)
	aArgs = []
	cArg = ""
	cQuote = ""
	nDepth = 0
	nLen = len(cInside)
	for i = 1 to nLen
		c = cInside[i]
		if cQuote != ""
			if c = cQuote
				cQuote = ""
			ok
			cArg += c
			loop
		ok
		if c = '"' or c = "'" or c = "`"
			cQuote = c
		but c = "["
			nDepth++
		but c = "]"
			nDepth--
		but c = "," and nDepth = 0
			aArgs + StzLiteralValue(cArg)
			cArg = ""
			loop
		ok
		cArg += c
	next
	if cQuote != "" or nDepth != 0
		StzRaise("Can't read the call '" + pcText + "'! A quote or a bracket is not closed.")
	ok
	if trim(cArg) != "" or len(aArgs) > 0
		aArgs + StzLiteralValue(cArg)
	ok
	return [ cName, aArgs ]

# The value a literal written as text stands for: a number, a quoted text, a :symbol, or a list
# of literal data. Anything else is refused by name.
func StzLiteralValue(pcText)
	cText = trim("" + pcText)
	nLen = len(cText)
	if nLen = 0
		StzRaise("Can't read the value! It is empty.")
	ok
	c1 = cText[1]
	if nLen >= 2 and (c1 = '"' or c1 = "'" or c1 = "`") and cText[nLen] = c1
		cIn = substr(cText, 2, nLen - 2)
		if substr(cIn, c1) = 0
			return cIn
		ok
	ok
	if c1 = ":" and StzIsPlainIdentifier(substr(cText, 2))
		return substr(cText, 2)
	ok
	if c1 = "["
		if NOT StzIsPlainListLiteral(cText)
			StzRaise("Can't read the value '" + cText + "'! A list is read only when it holds literal data.")
		ok
		aValue = []
		eval("aValue = " + cText)
		return aValue
	ok
	bDigit = 0
	bNumber = 1
	nExp = 0
	for i = 1 to nLen
		c = cText[i]
		if c >= "0" and c <= "9"
			bDigit = 1
		but (c = "e" or c = "E") and bDigit and nExp = 0 and i < nLen
			nExp = i
		but c = "-" or c = "+"
			if NOT ( i = 1 or i = nExp + 1 )
				bNumber = 0
				exit
			ok
		but NOT (c = "." and nExp = 0)
			bNumber = 0
			exit
		ok
	next
	if bNumber and bDigit
		return number(cText)
	ok
	cLow = lower(cText)
	if cLow = "true"
		return 1
	ok
	if cLow = "false"
		return 0
	ok
	StzRaise("Can't read the value '" + cText + "'! A number, a quoted text, a :symbol or a list of literal data is read.")

# 1 when the W condition holds for the one value pValue (named @item), 0 when it does not.
#
#   pValue     the value the condition is about
#   pcCond     a W condition as text
#   returns    1 or 0
#   warning    a condition the W engine cannot judge RAISES, naming the WF form -- it is never
#              read as false, and never run as code
#   see        StzWValues, StzWPositions
func StzWHolds(pValue, pcCond)
	aV = StzWValues([ pValue ], pcCond)
	xV = aV[1]
	if isNumber(xV)
		return xV != 0
	ok
	if isString(xV)
		return xV != ""
	ok
	return 1

# Calls pcName as a method of poObject when it has one, else as a global function, with the values
# of paArgs -- the order an unqualified call inside a class resolves in.
#
#   poObject   the object
#   pcName     a plain name; anything else is refused
#   paArgs     the arguments as values, at most 4
#   returns    what the method or the function returns
#   warning    a name that is neither a method of poObject nor a function raises
#   see        StzCallMethodOn
func StzCallMethodOrFunction(poObject, pcName, paArgs)
	cName = "" + pcName
	if NOT StzIsPlainIdentifier(cName)
		StzRaise("Can't call '" + cName + "'! It is not a plain name.")
	ok
	if ismethod(poObject, lower(cName))
		return StzCallMethodOn(poObject, cName, paArgs)
	ok
	if NOT isfunction(cName)
		StzRaise("Can't call '" + cName + "'! It is neither a method of the object nor a function.")
	ok
	f = cName
	switch len(paArgs)
	on 0
		return call f()
	on 1
		return call f(paArgs[1])
	on 2
		return call f(paArgs[1], paArgs[2])
	on 3
		return call f(paArgs[1], paArgs[2], paArgs[3])
	on 4
		return call f(paArgs[1], paArgs[2], paArgs[3], paArgs[4])
	off
	StzRaise("Can't call '" + cName + "'! At most 4 arguments are passed.")

# The value of an expression of literals, the pure functions and the operators of
# StzMethodExprValue, with no object and no names: "(2 + 3) * 4" gives 20. Nothing is run.
func StzExprValue(pcExpr)
	return StzMethodExprValue(new stzNoMethods, pcExpr, [])

# 1 when such an expression holds.
func StzExprHolds(pcExpr)
	return StzMethodExprHolds(new stzNoMethods, pcExpr, [])

# The value of an expression about an object's own methods, read by a closed grammar and never run.
#
#   poObject   the object whose methods the expression names
#   pcExpr     the expression: numbers, quoted texts, true and false, $names from paNamed, calls of
#              the object's methods (Count(), @.Value(), IsEven), the functions abs, sqrt, min, max,
#              len, round, floor, ceil, lower and upper, + - * / %, = != <> < > <= >=, and, or, not,
#              and parentheses; braces around the whole are dropped
#   paNamed    the values a name may read, as [ [ "$name", value ], ... ] or [ [ "age", 30 ], ... ]
#              -- a bare name found here is that value, before it is a method; [] for none
#   returns    the value
#   note       a method is called by its checked name with the VALUES of its arguments; nothing in
#              the text reaches eval, so a text cannot act -- a name outside this grammar is refused
#   see        StzMethodExprHolds, StzCallMethodOn
func StzMethodExprValue(poObject, pcExpr, paNamed)
	oExpr = new stzMethodExpr(poObject, pcExpr, paNamed)
	return oExpr.Value()

# 1 when the expression about the object's methods holds, 0 when it does not; it raises when the
# text is not in the grammar of StzMethodExprValue.
func StzMethodExprHolds(poObject, pcExpr, paNamed)
	xValue = StzMethodExprValue(poObject, pcExpr, paNamed)
	if isNumber(xValue)
		return xValue != 0
	ok
	if isString(xValue)
		return xValue != ""
	ok
	return 1

class stzMethodExpr
	@oObject
	@aNamed
	@aTokens = []
	@nPos = 1
	@cText = ""

	def init(poObject, pcExpr, paNamed)
		if NOT isString(pcExpr)
			StzRaise("Can't read the expression! It must be a text.")
		ok
		@oObject = poObject
		@aNamed = paNamed
		@cText = trim(pcExpr)
		if len(@cText) >= 2 and left(@cText, 1) = "{" and right(@cText, 1) = "}"
			@cText = trim(substr(@cText, 2, len(@cText) - 2))
		ok
		This._Tokenize()

	def Value()
		@nPos = 1
		if len(@aTokens) = 0
			This._Refuse("it is empty")
		ok
		xValue = This._Or()
		if @nPos <= len(@aTokens)
			This._Refuse("'" + @aTokens[@nPos][2] + "' is not expected there")
		ok
		return xValue

	def _Refuse(pcWhy)
		StzRaise("Can't read the expression '" + @cText + "': " + pcWhy + ".")

	# tokens are [ kind, text ]: num, str, name, global, op
	def _Tokenize()
		@aTokens = []
		cS = @cText
		nLen = len(cS)
		i = 1
		while i <= nLen
			c = cS[i]
			if c = " " or c = char(9) or c = char(10) or c = char(13)
				i++
				loop
			ok
			if c = '"' or c = "'" or c = "`"
				j = i + 1
				while j <= nLen and cS[j] != c
					j++
				end
				if j > nLen
					This._Refuse("a quote is not closed")
				ok
				@aTokens + [ "str", substr(cS, i + 1, j - i - 1) ]
				i = j + 1
				loop
			ok
			if (c >= "0" and c <= "9") or (c = "." and i < nLen and cS[i + 1] >= "0" and cS[i + 1] <= "9")
				j = i
				while j <= nLen and ((cS[j] >= "0" and cS[j] <= "9") or cS[j] = ".")
					j++
				end
				@aTokens + [ "num", substr(cS, i, j - i) ]
				i = j
				loop
			ok
			if c = "$" or c = "_" or (c >= "a" and c <= "z") or (c >= "A" and c <= "Z")
				j = i + 1
				while j <= nLen and (cS[j] = "_" or (cS[j] >= "a" and cS[j] <= "z") or
				      (cS[j] >= "A" and cS[j] <= "Z") or (cS[j] >= "0" and cS[j] <= "9"))
					j++
				end
				cWord = substr(cS, i, j - i)
				if c = "$"
					@aTokens + [ "global", lower(cWord) ]
				else
					@aTokens + [ "name", cWord ]
				ok
				i = j
				loop
			ok
			if i < nLen
				c2 = substr(cS, i, 2)
				if c2 = "!=" or c2 = "<>" or c2 = "<=" or c2 = ">=" or c2 = "=="
					@aTokens + [ "op", c2 ]
					i += 2
					loop
				ok
			ok
			if c = "(" or c = ")" or c = "," or c = "+" or c = "-" or c = "*" or c = "/" or
			   c = "%" or c = "=" or c = "<" or c = ">" or c = "!" or c = "@" or c = "."
				@aTokens + [ "op", c ]
				i++
				loop
			ok
			This._Refuse("the character '" + c + "' is not in the grammar")
		end

	def _Peek()
		if @nPos <= len(@aTokens)
			return @aTokens[@nPos]
		ok
		return [ "end", "" ]

	def _IsOp(pcOp)
		aT = This._Peek()
		return aT[1] = "op" and aT[2] = pcOp

	def _IsWord(pcWord)
		aT = This._Peek()
		return aT[1] = "name" and lower(aT[2]) = pcWord

	def _Expect(pcOp)
		if NOT This._IsOp(pcOp)
			This._Refuse("'" + pcOp + "' was expected")
		ok
		@nPos++

	def _Truth(pValue)
		if isNumber(pValue)
			return pValue != 0
		ok
		if isString(pValue)
			return pValue != ""
		ok
		return 1

	def _Or()
		xLeft = This._And()
		while This._IsWord("or")
			@nPos++
			xRight = This._And()
			xLeft = ( This._Truth(xLeft) or This._Truth(xRight) )
		end
		return xLeft

	def _And()
		xLeft = This._Not()
		while This._IsWord("and")
			@nPos++
			xRight = This._Not()
			xLeft = ( This._Truth(xLeft) and This._Truth(xRight) )
		end
		return xLeft

	def _Not()
		if This._IsWord("not") or This._IsOp("!")
			@nPos++
			return NOT This._Truth(This._Not())
		ok
		return This._Compare()

	def _Compare()
		xLeft = This._Add()
		aT = This._Peek()
		if aT[1] = "op" and ( aT[2] = "=" or aT[2] = "==" or aT[2] = "!=" or aT[2] = "<>" or
		   aT[2] = "<" or aT[2] = ">" or aT[2] = "<=" or aT[2] = ">=" )
			@nPos++
			xRight = This._Add()
			switch aT[2]
			on "="  return xLeft = xRight
			on "==" return xLeft = xRight
			on "!=" return xLeft != xRight
			on "<>" return xLeft != xRight
			on "<"  return xLeft < xRight
			on ">"  return xLeft > xRight
			on "<=" return xLeft <= xRight
			on ">=" return xLeft >= xRight
			off
		ok
		return xLeft

	def _Add()
		xLeft = This._Mul()
		while This._IsOp("+") or This._IsOp("-")
			cOp = This._Peek()[2]
			@nPos++
			xRight = This._Mul()
			if cOp = "+"
				if isString(xLeft) or isString(xRight)
					xLeft = "" + xLeft + xRight
				else
					xLeft = xLeft + xRight
				ok
			else
				xLeft = This._Num(xLeft) - This._Num(xRight)
			ok
		end
		return xLeft

	def _Mul()
		xLeft = This._Unary()
		while This._IsOp("*") or This._IsOp("/") or This._IsOp("%")
			cOp = This._Peek()[2]
			@nPos++
			xRight = This._Num(This._Unary())
			xLeft = This._Num(xLeft)
			if cOp = "*"
				xLeft = xLeft * xRight
			but cOp = "/"
				if xRight = 0
					This._Refuse("it divides by zero")
				ok
				xLeft = xLeft / xRight
			else
				xLeft = xLeft % xRight
			ok
		end
		return xLeft

	def _Num(pValue)
		if NOT isNumber(pValue)
			This._Refuse("a number was expected and " + type(pValue) + " was found")
		ok
		return pValue

	def _Unary()
		if This._IsOp("-")
			@nPos++
			return 0 - This._Num(This._Unary())
		ok
		if This._IsOp("+")
			@nPos++
			return This._Num(This._Unary())
		ok
		return This._Primary()

	def _Args()
		aArgs = []
		This._Expect("(")
		if This._IsOp(")")
			@nPos++
			return aArgs
		ok
		while 1
			aArgs + This._Or()
			if This._IsOp(",")
				@nPos++
				loop
			ok
			This._Expect(")")
			exit
		end
		return aArgs

	def _Primary()
		aT = This._Peek()
		if aT[1] = "num"
			@nPos++
			return 0 + aT[2]
		ok
		if aT[1] = "str"
			@nPos++
			return aT[2]
		ok
		if aT[1] = "global"
			@nPos++
			nNamed = len(@aNamed)
			for i = 1 to nNamed
				if lower(@aNamed[i][1]) = aT[2]
					return @aNamed[i][2]
				ok
			next
			This._Refuse("'" + aT[2] + "' is not one of the values it may read")
		ok
		if This._IsOp("(")
			@nPos++
			xValue = This._Or()
			This._Expect(")")
			return xValue
		ok
		# @.Method(...) -- the object, named
		if This._IsOp("@")
			@nPos++
			This._Expect(".")
			aT = This._Peek()
			if aT[1] != "name"
				This._Refuse("a method name was expected after @.")
			ok
			@nPos++
			aArgs = []
			if This._IsOp("(")
				aArgs = This._Args()
			ok
			return StzCallMethodOn(@oObject, aT[2], aArgs)
		ok
		if aT[1] = "name"
			@nPos++
			cLow = lower(aT[2])
			if cLow = "true"
				return 1
			ok
			if cLow = "false"
				return 0
			ok
			aArgs = []
			bCalled = This._IsOp("(")
			if NOT bCalled
				nNamed = len(@aNamed)
				for i = 1 to nNamed
					if lower(@aNamed[i][1]) = cLow
						return @aNamed[i][2]
					ok
				next
			ok
			if classname(@oObject) = "stznomethods" and NOT ( bCalled and ring_find([ "abs", "sqrt",
			   "round", "floor", "ceil", "len", "lower", "upper", "max", "min" ], cLow) > 0 )
				This._Refuse("'" + aT[2] + "' names something a text cannot reach: a variable or a " +
					"function of the program is read by the program itself, as in iif(x > 3, ...)")
			ok
			if bCalled
				aArgs = This._Args()
			ok
			if bCalled and len(aArgs) > 0
				nArgs = len(aArgs)
				switch cLow
				on "abs"
					return fabs(This._Num(aArgs[1]))
				on "sqrt"
					return sqrt(This._Num(aArgs[1]))
				on "round"
					return floor(This._Num(aArgs[1]) + 0.5)
				on "floor"
					return floor(This._Num(aArgs[1]))
				on "ceil"
					return ceil(This._Num(aArgs[1]))
				on "len"
					if isList(aArgs[1])
						return len(aArgs[1])
					ok
					return StzLen("" + aArgs[1])
				on "lower"
					return StzLower("" + aArgs[1])
				on "upper"
					return StzUpper("" + aArgs[1])
				on "max"
					xBest = This._Num(aArgs[1])
					for i = 2 to nArgs
						if This._Num(aArgs[i]) > xBest
							xBest = aArgs[i]
						ok
					next
					return xBest
				on "min"
					xBest = This._Num(aArgs[1])
					for i = 2 to nArgs
						if This._Num(aArgs[i]) < xBest
							xBest = aArgs[i]
						ok
					next
					return xBest
				off
			ok
			return StzCallMethodOn(@oObject, aT[2], aArgs)
		ok
		if aT[1] = "end"
			This._Refuse("it ends too early")
		ok
		This._Refuse("'" + aT[2] + "' is not expected there")

# An object with no method: what StzExprValue reads an expression against, so a name in it reaches
# nothing.
class stzNoMethods
