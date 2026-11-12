# Functions for porting C code to Ring

$_b = 0 	# Used for ternary operators in C
_bv = ""	# Idem

func b(e)
	$_b = e

func bv(val1, val2)
	_nLen_ = len($vVars)
	if $_b = 1
		$vVars[_nLen_][2] = val1
	else
		$vVars[_nLen_][2] = val2
	ok	

func bt(val)
	_nLen_ = len($vVars)
	if $_b = 1
		$vVars[_nLen_][2] = val
	ok

func bf(val)
	_nLen_ = len($vVars)
	if $_b = 0
		$vVars[_nLen_][2] = val
	ok
