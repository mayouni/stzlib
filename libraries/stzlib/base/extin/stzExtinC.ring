# Functions for porting C code to Ring

_b = 0 	# Used for ternary operators in C
_bv = ""	# Idem

func b(e)
	_b = e

func bv(val1, val2)
	nLen = len(_aVars)
	if _b = _TRUE_
		_aVars[nLen][2] = val1
	else
		_aVars[nLen][2] = val2
	ok	

func bt(val)
	nLen = len(_aVars)
	if _b = _TRUE_
		_aVars[nLen][2] = val
	ok

func bf(val)
	nLen = len(_aVars)
	if _b = _FALSE_
		_aVars[nLen][2] = val
	ok
