
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#  LOADING NECESSARY RING LIBS AND ENGINE BRIDGES      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

load "stdlibcore.ring"

# Load Core Engine bridge (string + char)
# The Engine replaces Qt -- no qtcore.ring, no Ring extensions.

$cEngineDir = _stzDiscoverEngineDir()

load "../../engine/stk_string.ring"

# --- Helper function (Ring compiles funcs first, so it's callable above) ---

func _stzDiscoverEngineDir()
	# Strategy: search upward from currentdir() for engine/zig-out/bin/
	# This works regardless of where Ring is installed.
	_cDir_ = currentdir()
	# Normalize backslashes to forward slashes
	_nLen_ = len(_cDir_)
	_cNorm_ = ""
	for _i_ = 1 to _nLen_
		if _cDir_[_i_] = "\"
			_cNorm_ += "/"
		else
			_cNorm_ += _cDir_[_i_]
		ok
	next
	_cDir_ = _cNorm_

	# Try up to 10 parent levels
	for _depth_ = 1 to 10
		_cCandidate_ = _cDir_ + "/engine"
		_cProbe_ = _cCandidate_ + "/zig-out/bin"
		if fexists(_cProbe_ + "/stz_string.dll") or fexists(_cProbe_ + "/stz_sequence.dll")
			return _cCandidate_
		ok
		# Also try libraries/stzlib/engine (for when cwd is the repo root)
		_cCandidate2_ = _cDir_ + "/libraries/stzlib/engine"
		_cProbe2_ = _cCandidate2_ + "/zig-out/bin"
		if fexists(_cProbe2_ + "/stz_string.dll") or fexists(_cProbe2_ + "/stz_sequence.dll")
			return _cCandidate2_
		ok
		# Go up one level
		_nLast_ = 0
		for _j_ = len(_cDir_) to 1 step -1
			if _cDir_[_j_] = "/"
				_nLast_ = _j_
				exit
			ok
		next
		if _nLast_ < 2
			exit
		ok
		_cDir_ = left(_cDir_, _nLast_ - 1)
	next
	# Fallback: old exefolder() approach
	return exefolder() + "/../libraries/stzlib/engine"
