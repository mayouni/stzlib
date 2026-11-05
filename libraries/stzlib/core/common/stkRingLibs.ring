
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#  LOADING NECESSARY RING LIBS AND ENGINE BRIDGES      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

load "stdlibcore.ring"

# Load Core Engine bridge (string + char)
# The Engine replaces Qt -- no qtcore.ring, no Ring extensions.

$cEngineDir = _stzDiscoverEngineDir()
# the library's own source folder (the one holding base/ and engine/), found
# apart from the engine: STZ_ENGINE_DIR may name a copy outside the tree
$cStzLibDir = _stzDiscoverLibDir()

load "../../engine/stk_string.ring"

# --- Helper function (Ring compiles funcs first, so it's callable above) ---

# THE DOMAIN DOOR (SOFTANZA_ONE_HOUR.md ruling 3, rung W7b). Every engine
# loader asks this before its LoadLib. A domain not loaded is surface a
# process does not carry, and the only kind W6 can shut: a loaded library
# cannot be unloaded from a running process.
#
#   the manifest   a program may name its domains BEFORE load "stzBase.ring":
#                  $aStzDomains = [ "crypto", "seclog" ]   (or STZ_DOMAINS=crypto,seclog)
#                  absent, every domain loads as before
#   the floor      the domains stzBase's own load needs always load: string, list,
#                  unicode, stats, meta and hashmap (found by RUNNING a do-nothing
#                  program under an empty manifest, 2026-11-05: the static reach said
#                  five, and missed hashmap, which a class attribute block reaches);
#                  the core's stk_* libraries are not asked
#   the deny list  <engineDir>/DENIED, one line per domain: name|advisoryId|why,
#                  written by stzExposureResponder.ShutDomain -- refused even when
#                  the manifest names it; the refusal is written to the security
#                  ledger as exposure.closed when the program opens one
#   returns        1 to load, 0 to skip; a skipped domain's handle is NULL and a
#                  call into it raises R3 at its line, naming the function
func StzDomainWanted(pcDomain)
	_c_ = lower("" + pcDomain)
	if NOT isglobal("$aStzDomainsDenied")
		$aStzDomainsDenied = _stzReadDomainDeny()
		$aStzDomainsSkipped = []
		$aStzDomainsRefused = []
	ok
	_n_ = len($aStzDomainsDenied)
	for _i_ = 1 to _n_
		if $aStzDomainsDenied[_i_][1] = _c_
			$aStzDomainsRefused + $aStzDomainsDenied[_i_]
			return 0
		ok
	next
	if find([ "string", "list", "unicode", "stats", "meta", "hashmap" ], _c_) > 0
		return 1
	ok
	_aM_ = []
	if isglobal("$aStzDomains")
		_aM_ = $aStzDomains
	else
		_cEnv_ = sysget("STZ_DOMAINS")
		if _cEnv_ = ""  return 1  ok
		_aM_ = _stzFields(_cEnv_, ",")
	ok
	_nM_ = len(_aM_)
	for _i_ = 1 to _nM_
		if lower(trim("" + _aM_[_i_])) = _c_  return 1  ok
	next
	$aStzDomainsSkipped + _c_
	return 0

# a text cut at one separator character (stdlib's split reads the NL global,
# which a caller can overwrite)
func _stzFields(pcText, pcSep)
	_a_ = []
	_cur_ = ""
	_n_ = len(pcText)
	for _i_ = 1 to _n_
		if pcText[_i_] = pcSep
			_a_ + _cur_
			_cur_ = ""
		else
			_cur_ += pcText[_i_]
		ok
	next
	_a_ + _cur_
	return _a_

# where the deny list lives: a program's $cStzDomainDenyFile, else the
# STZ_DOMAIN_DENY variable, else <engineDir>/DENIED (one engine folder serves
# many programs, so a deny there reaches them all)
func StzDomainDenyFile()
	if isglobal("$cStzDomainDenyFile") and $cStzDomainDenyFile != ""
		return $cStzDomainDenyFile
	ok
	_p_ = sysget("STZ_DOMAIN_DENY")
	if _p_ != ""  return _p_  ok
	return $cEngineDir + "/DENIED"

# the domains a manifest left out, and those the deny list refused: [ [ domain, advisoryId, why ], ... ]
func StzDomainsSkipped()
	if NOT isglobal("$aStzDomainsSkipped")  return []  ok
	return $aStzDomainsSkipped

func StzDomainsRefused()
	if NOT isglobal("$aStzDomainsRefused")  return []  ok
	return $aStzDomainsRefused

# The folder holding base/ and engine/ of the library being run, by searching
# upward from the working directory for a source file every checkout carries.
# Empty when none is found (a program run from outside any tree).
func _stzDiscoverLibDir()
	_cDir_ = ""
	_cCur_ = currentdir()
	_n_ = len(_cCur_)
	for _i_ = 1 to _n_
		if _cCur_[_i_] = char(92)
			_cDir_ += "/"
		else
			_cDir_ += _cCur_[_i_]
		ok
	next
	for _depth_ = 1 to 12
		if fexists(_cDir_ + "/engine/stk_string.ring") and fexists(_cDir_ + "/base/stzBase.ring")
			return _cDir_
		ok
		if fexists(_cDir_ + "/libraries/stzlib/base/stzBase.ring")
			return _cDir_ + "/libraries/stzlib"
		ok
		_nLast_ = 0
		for _j_ = len(_cDir_) to 1 step -1
			if _cDir_[_j_] = "/"
				_nLast_ = _j_
				exit
			ok
		next
		if _nLast_ < 2  exit  ok
		_cDir_ = left(_cDir_, _nLast_ - 1)
	next
	return ""

# the deny list, read once: [ [ domain, advisoryId, why ], ... ]
func _stzReadDomainDeny()
	_a_ = []
	_p_ = StzDomainDenyFile()
	if NOT fexists(_p_)  return _a_  ok
	_aL_ = str2list(read(_p_))
	_n_ = len(_aL_)
	for _i_ = 1 to _n_
		_l_ = trim(_aL_[_i_])
		if _l_ = "" or left(_l_, 1) = "#"  loop  ok
		_aF_ = _stzFields(_l_, "|")
		while len(_aF_) < 3  _aF_ + ""  end
		_a_ + [ lower(trim(_aF_[1])), trim(_aF_[2]), trim(_aF_[3]) ]
	next
	return _a_

func _stzDiscoverEngineDir()
	# STZ_ENGINE_DIR names the engine folder outright: the Ring++ copy of the
	# engine (bench/engine_copy.py builds it beside the official one) is the only
	# build rnxc loads, and it lives outside this tree -- RING-RETIRED-01, 2026-11-05.
	_cEnv_ = sysget("STZ_ENGINE_DIR")
	if _cEnv_ != "" and (fexists(_cEnv_ + "/zig-out/bin/stz_string.dll") or fexists(_cEnv_ + "/zig-out/lib/libstz_string.so"))
		return _cEnv_
	ok
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
