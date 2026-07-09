# Functions for porting C code to Ring

_b = 0 	# Used for ternary operators in C
_bv = ""	# Idem

func b(e)
	_b = e

func bv(val1, val2)
	_nLen_ = len(_aVars)
	if _b = 1
		_aVars[_nLen_][2] = val1
	else
		_aVars[_nLen_][2] = val2
	ok	

func bt(val)
	_nLen_ = len(_aVars)
	if _b = 1
		_aVars[_nLen_][2] = val
	ok

func bf(val)
	_nLen_ = len(_aVars)
	if _b = 0
		_aVars[_nLen_][2] = val
	ok
