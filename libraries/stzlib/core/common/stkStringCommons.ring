#----------------------------------#
#  COMMON FOR ALL STRING CLASSES   #
#----------------------------------#

func IsLetter(c)
	if len(c) != 1
		return FALSE
	ok
	_n_ = ascii(c)
	if (_n_ >= 65 and _n_ <= 90) or (_n_ >= 97 and _n_ <= 122)
		return TRUE
	ok
	return FALSE

	func @IsLetter(c)
		return IsLetter(c)

func IsDigit(c)
	if len(c) != 1
		return FALSE
	ok
	_n_ = ascii(c)
	return (_n_ >= 48 and _n_ <= 57)

	func @IsDigit(c)
		return IsDigit(c)

# Polymorphic (widened 2026-07-10, see doc/design/NNL_REVIEW.md): a single
# char keeps the historical ASCII-char check; a longer string answers for
# the WHOLE string -- this is what the NNL descriptor dispatch relies on
# (@isLowercase("ring") must be TRUE; it silently answered 0 for years
# because the char-only form said "not one char -> FALSE").

func IsUpperCase(c)
	if NOT isString(c) or len(c) = 0
		return FALSE
	ok
	if len(c) = 1
		_n_ = ascii(c)
		return (_n_ >= 65 and _n_ <= 90)
	ok
	return c = upper(c) and upper(c) != lower(c)

	func @IsUpperCase(c)
		return IsUpperCase(c)

func IsLowerCase(c)
	if NOT isString(c) or len(c) = 0
		return FALSE
	ok
	if len(c) = 1
		_n_ = ascii(c)
		return (_n_ >= 97 and _n_ <= 122)
	ok
	return c = lower(c) and lower(c) != upper(c)

	func @IsLowerCase(c)
		return IsLowerCase(c)

func StringIsEmpty(str)
	return (len(str) = 0)

func StringRepeat(str, _n_)
	_cResult_ = ""
	for i = 1 to _n_
		_cResult_ += str
	next
	return _cResult_

	func @StringRepeat(str, _n_)
		return StringRepeat(str, _n_)

func StringReverse(str)
	_cResult_ = ""
	for i = len(str) to 1 step -1
		_cResult_ += str[i]
	next
	return _cResult_

	func @StringReverse(str)
		return StringReverse(str)
