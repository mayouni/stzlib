# EXPECTED OUTPUT, made real.
#
# -- WHY THIS FILE EXISTS --
#
# The examples under test/plot/ have always carried their expected picture right
# in the source, as a quoted block under a #--> marker:
#
#     oPlot.Show()
#     #-->
#     '
#     ▲
#     │    ██
#     '
#
# Ring evaluates that block as an expression and throws the value away. It reads
# like an assertion and is not one. So for a long time an example "passed" as
# long as it did not raise -- and a plot that runs is not a plot that is right.
# That is not a hypothetical: stzHBarPlot once inherited the VERTICAL renderer
# and drew horizontal data as vertical bars for a whole commit, while all 73
# examples went on passing.
#
# Shows() turns the block into a comparison. The picture stays exactly where it
# was and still reads as documentation -- it is now also the thing that fails.
#
# -- HOW IT COMPARES --
#
# A plot IS its characters, so the comparison is exact: same characters, same
# rows, trailing spaces and all. Two allowances, both about the SOURCE FILE
# rather than the plot:
#
#   * the block opens and closes with a newline of its own, which belongs to the
#     quoting and not to the picture;
#   * the file may be stored with CRLF line endings, while a renderer emits LF.
#
# Nothing else is normalised. In particular trailing spaces are NOT trimmed: a
# padded row and a trimmed row are different strings, and several of the
# renderers deliberately differ on exactly that point.

func Shows(oPlot, cExpected)
	return ShowsThis(oPlot.ToString(), cExpected)

# For the handful of examples that print a VALUE rather than a picture. Same
# reasoning, same fate on mismatch -- the #--> comment beside a `?` was no more
# of an assertion than the quoted blocks were.
func Same(xActual, xExpected)
	if xActual = xExpected
		return TRUE
	ok
	? ""
	? "VALUE DOES NOT MATCH"
	? "  expected " + @@(xExpected)
	? "  actual   " + @@(xActual)
	? ""
	raise("The value does not match what the example says it prints.")

func ShowsThis(cActual, cExpected)
	_aAct_ = ExpectLines(cActual)
	_aExp_ = ExpectLines(cExpected)

	_nA_ = len(_aAct_)
	_nE_ = len(_aExp_)
	_bSame_ = (_nA_ = _nE_)
	if _bSame_
		for _i_ = 1 to _nA_
			if _aAct_[_i_] != _aExp_[_i_]
				_bSame_ = FALSE
				exit
			ok
		next
	ok

	if _bSame_
		return TRUE
	ok

	# THE REPORT NAMES THE FIRST ROW THAT DIFFERS, and shows both pictures whole.
	# A one-character difference in a box-drawing plot is invisible read straight,
	# so the row number is the part that makes it findable.
	? ""
	? "PICTURE DOES NOT MATCH"
	? "  expected " + _nE_ + " rows, got " + _nA_

	_nMin_ = _nE_
	if _nA_ < _nMin_
		_nMin_ = _nA_
	ok
	for _i_ = 1 to _nMin_
		if _aAct_[_i_] != _aExp_[_i_]
			? "  first difference at row " + _i_ + ":"
			? "    expected |" + _aExp_[_i_] + "|"
			? "    actual   |" + _aAct_[_i_] + "|"
			exit
		ok
	next

	? ""
	? "--- expected"
	for _i_ = 1 to _nE_
		? _aExp_[_i_]
	next
	? "--- actual"
	for _i_ = 1 to _nA_
		? _aAct_[_i_]
	next
	? ""

	raise("The picture does not match what the example says it shows.")

# Split into rows, dropping the CR of a CRLF file and the one blank row the
# quoting adds at each end.
func ExpectLines(cText)
	_cT_ = StzReplace(cText, char(13), "")
	_aL_ = StzSplit(_cT_, char(10))
	_nL_ = len(_aL_)

	_nFrom_ = 1
	_nTo_ = _nL_
	if _nL_ > 0 and _aL_[1] = ""
		_nFrom_ = 2
	ok
	if _nTo_ >= _nFrom_ and _aL_[_nTo_] = ""
		_nTo_--
	ok

	_aOut_ = []
	for _i_ = _nFrom_ to _nTo_
		_aOut_ + _aL_[_i_]
	next
	return _aOut_

# -- WHERE THE PICTURES IN THE EXAMPLES CAME FROM --
#
# The blocks were captured under Ring 1.22/1.23 and then never maintained: 49 of
# 62 no longer matched what the renderers draw, every one of them explained by a
# deliberate change nobody propagated back (the axis arrows became ▲ and ►, the
# multi-series marks changed, and a border junction that used to render as a
# stray │ became a proper ┤). They were regenerated from the live renderers in
# one pass rather than retyped -- 62 hand-copied runs of box characters is 62
# chances to miscount one, which had already produced three false failures
# during the engine port. Shows() pins them from here on, so the next deliberate
# change breaks the examples loudly instead of quietly ageing them.
