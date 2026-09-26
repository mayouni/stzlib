#---------------------------------------------------------------------------#
#  STZPATTERN -- rhythm is a string, and a pattern is a function of time    #
#  (MU3)                                                                     #
#---------------------------------------------------------------------------#
#
#     oP = StzPatternQ("bd ~ sn [hh hh]")        # Tidal's mini-notation
#     ? oP.CycleEvents(0)                        # what cycle 0 holds
#     oP.Fast(2).Every(3, :Rev).Off(0.25, 12)    # the algebra, chained
#     oP.ToScoreQ(4)                              # four cycles, as a stzScore
#
# THE IDEA IS TIDALCYCLES' (plan 1.1): a pattern is not a list of notes, it is
# a FUNCTION from a cycle number to the events in that cycle. Every verb below
# builds a new function out of old ones, which is why they compose: Fast(2) of
# an alternation still alternates, Rev of a stack reverses both parts.
#
# ONE CYCLE AT A TIME, and on purpose. Every query asks for one whole cycle,
# and every event comes back as an onset in [0, 1) of that cycle plus a length.
# Asking whole cycles is what keeps the arithmetic exact across hours of play:
# cycle 10000's events are computed from 10000, not by adding 1 ten thousand
# times. The price is stated: a fast or slow factor must be a WHOLE number
# here, because a factor of 1.5 does not map whole cycles onto whole cycles.
#
# THE MINI-NOTATION, MU3's set -- exactly what plan 1.1 names, and no more:
#
#     a b c       a sequence: each step gets an equal share of the cycle
#     ~           a rest
#     [a b]       a group: the steps share ONE step's time
#     [a, b]      a stack: both at once (also at the top level: "a b, c d")
#     <a b c>     alternation: a on cycle 0, b on cycle 1, c on cycle 2, ...
#     a*2         the step twice as fast (a whole number)
#     a/2         the step half as fast: it sounds every other cycle
#     a?          the step sounds on about half the cycles -- DETERMINISTICALLY,
#                 from the cycle number and a seed, so a guard can hold it
#     a!3         the step three times, as three steps
#     a@3         the step weighs three steps (elongation)
#
# A WORD is a note name ("c", "e5", "bb3", "d4+50", "e-50" -- the octave
# carries left to right, as in StzScoreOfQ) or a stroke: dum tak ka, kick
# snare hihat, and Tidal's own bd sn hh for the kit.
#
# WHAT IS NOT HERE: euclidean rhythms "bd(3,8)", fractional factors, sample
# banks "bd:3", and jux (a stereo copy -- the timeline mixes every note to all
# channels and has no pan per note). Each is a later phase's, or needs an
# engine change that is not this phase's.

func StzPatternQ(pcText)
	return new stzPattern(pcText)

class stzPattern

	@aRoot = NULL          # the tree; NULL when the text did not parse
	@cText = ""
	@cLastError = ""
	@nRefusals = 0
	@nSeed = 7             # for ?, so two patterns with the same text agree

	# parser state
	@aChars = []
	@nPos = 1
	@cOct = "4"
	@nDegrades = 0

	def init(pcText)
		@cText = "" + pcText
		@aRoot = This._Parse(@cText)

	def IsValid()
		return NOT isNull(@aRoot)

	def Text()
		return @cText

	def LastError()
		return @cLastError

	def Refusals()
		return @nRefusals

	def Tree()
		return @aRoot

	#-- querying ------------------------------------------------------------

	# The events of cycle `pnCycle` (a whole number, 0 is the first), sorted
	# by onset: [ onset, length, kind, name ] with onset in [0, 1) and length
	# in cycles. `kind` is "note" or "stroke".
	def CycleEvents(pnCycle)
		if isNull(@aRoot)  return [] ok
		_a_ = This._Q(@aRoot, pnCycle)
		_out_ = []
		for _e_ in _a_
			_out_ + [ _e_[1], _e_[2], _e_[3][1], _e_[3][2] ]
		next
		return This._SortByOnset(_out_)

	# Every distinct [ kind, name, length ] over the pattern's first `pnCycles`
	# cycles -- what a player renders BEFORE it starts, so no note is rendered
	# while a cycle is being posted.
	def DistinctNotes(pnCycles)
		_a_ = []
		for _c_ = 0 to pnCycles - 1
			for _e_ in This.CycleEvents(_c_)
				_k_ = [ _e_[3], _e_[4], _e_[2] ]
				_found_ = FALSE
				for _x_ in _a_
					if _x_[1] = _k_[1] and _x_[2] = _k_[2] and _x_[3] = _k_[3]
						_found_ = TRUE
						exit
					ok
				next
				if NOT _found_  _a_ + _k_ ok
			next
		next
		return _a_

	# How many cycles before the pattern repeats -- alternations, slow
	# factors and Every all lengthen it. Capped at 64: a pattern that takes
	# longer than that to come round is rendered as it arrives.
	def Period()
		if isNull(@aRoot)  return 1 ok
		_p_ = This._Period(@aRoot)
		if _p_ > 64  _p_ = 64 ok
		return _p_

	# True when every word is a stroke: the pattern names its own drum.
	def IsAllStrokes()
		if isNull(@aRoot)  return FALSE ok
		_n_ = 0
		for _e_ in This.CycleEvents(0)
			if _e_[3] != "stroke"  return FALSE ok
			_n_++
		next
		return _n_ > 0

	def HasStroke(pcName)
		for _c_ = 0 to This.Period() - 1
			for _e_ in This.CycleEvents(_c_)
				if _e_[4] = pcName  return TRUE ok
			next
		next
		return FALSE

	# `pnCycles` cycles as a stzScore, a cycle being four beats. The pivot:
	# a pattern is a function, a score is data, and this is where one
	# becomes the other.
	def ToScoreQ(pnCycles)
		_oS_ = StzScoreQ()
		for _c_ = 0 to pnCycles - 1
			for _e_ in This.CycleEvents(_c_)
				_b_ = 4 * (_c_ + _e_[1])
				if _e_[3] = "stroke"
					_oS_.StrokeAt(_b_, _e_[4], 4 * _e_[2])
				else
					_oS_.NoteAt(_b_, _e_[4], 4 * _e_[2])
				ok
			next
		next
		_oS_.SetLength(4 * pnCycles)
		return _oS_

	#-- the algebra ---------------------------------------------------------
	# Each wraps the whole pattern and returns it, so they chain.

	def Fast(pnFactor)
		if NOT This._WholeFactor(pnFactor, "Fast")  return This ok
		if isNull(@aRoot)  return This ok
		_t_ = @aRoot
		@aRoot = [ :fast, _t_, pnFactor ]
		return This

	def Slow(pnFactor)
		if NOT This._WholeFactor(pnFactor, "Slow")  return This ok
		if isNull(@aRoot)  return This ok
		_t_ = @aRoot
		@aRoot = [ :slow, _t_, pnFactor ]
		return This

	# Each cycle backwards: an event at onset o of length d moves to 1-o-d.
	def Rev()
		if isNull(@aRoot)  return This ok
		_t_ = @aRoot
		@aRoot = [ :rev, _t_ ]
		return This

	# On cycles 0, n, 2n, ... apply a transformation: :Rev, or [ :Fast, k ],
	# or [ :Slow, k ]. The other cycles are left alone.
	def Every(pnN, pXform)
		if NOT isNumber(pnN) or pnN < 1 or pnN != floor(pnN)
			This._Refuse("Every: a whole number of cycles, 1 or more")
			return This
		ok
		_x_ = This._Xform(pXform)
		if isNull(_x_)  return This ok
		if isNull(@aRoot)  return This ok
		_t_ = @aRoot
		@aRoot = [ :every, _t_, pnN, _x_ ]
		return This

	# The pattern PLUS a copy of itself `pnCycles` later (0 < t < 1), the copy
	# transposed by `pnSemitones` (strokes keep their drum). What the shift
	# pushes past the end of a cycle sounds at the start of the next.
	def Off(pnCycles, pnSemitones)
		if NOT isNumber(pnCycles) or pnCycles <= 0 or pnCycles >= 1
			This._Refuse("Off: a shift strictly between 0 and 1 cycle")
			return This
		ok
		if NOT isNumber(pnSemitones)  pnSemitones = 0 ok
		if isNull(@aRoot)  return This ok
		_t_ = @aRoot
		@aRoot = [ :off, _t_, pnCycles, pnSemitones ]
		return This

	#-- private: the query --------------------------------------------------

	# One cycle of a node: [ [ onset, length, value ], ... ], onset in [0, 1).
	def _Q(paN, pnC)
		switch paN[1]
		on :atom
			return [ [ 0, 1, paN[2] ] ]
		on :rest
			return []
		on :seq
			_out_ = []
			_aSt_ = paN[2]
			_w_ = 0
			for _s_ in _aSt_  _w_ += _s_[2] next
			_at_ = 0
			for _s_ in _aSt_
				_share_ = _s_[2] / _w_
				for _e_ in This._Q(_s_[1], pnC)
					_out_ + [ _at_ + _e_[1] * _share_, _e_[2] * _share_, _e_[3] ]
				next
				_at_ += _share_
			next
			return _out_
		on :stack
			_out_ = []
			for _k_ in paN[2]
				for _e_ in This._Q(_k_, pnC)  _out_ + _e_ next
			next
			return _out_
		on :alt
			_n_ = len(paN[2])
			_i_ = (pnC % _n_) + 1
			return This._Q(paN[2][_i_], floor(pnC / _n_))
		on :fast
			_k_ = paN[3]
			_out_ = []
			for _j_ = 0 to _k_ - 1
				for _e_ in This._Q(paN[2], pnC * _k_ + _j_)
					_out_ + [ (_j_ + _e_[1]) / _k_, _e_[2] / _k_, _e_[3] ]
				next
			next
			return _out_
		on :slow
			_k_ = paN[3]
			_m_ = pnC % _k_
			_out_ = []
			for _e_ in This._Q(paN[2], floor(pnC / _k_))
				_o_ = _e_[1] * _k_ - _m_
				if _o_ >= 0 and _o_ < 1
					_out_ + [ _o_, _e_[2] * _k_, _e_[3] ]
				ok
			next
			return _out_
		on :degrade
			_out_ = []
			_i_ = 0
			for _e_ in This._Q(paN[2], pnC)
				_i_++
				if This._Keep(pnC, paN[3], _i_)  _out_ + _e_ ok
			next
			return _out_
		on :rev
			_out_ = []
			for _e_ in This._Q(paN[2], pnC)
				_out_ + [ 1 - _e_[1] - _e_[2], _e_[2], _e_[3] ]
			next
			return _out_
		on :every
			if pnC % paN[3] = 0
				return This._Q(This._Wrap(paN[4], paN[2]), pnC)
			ok
			return This._Q(paN[2], pnC)
		on :off
			_t_ = paN[3]
			_out_ = This._Q(paN[2], pnC)
			for _e_ in This._Q(paN[2], pnC)
				if _e_[1] + _t_ < 1
					_out_ + [ _e_[1] + _t_, _e_[2], This._Shift(_e_[3], paN[4]) ]
				ok
			next
			# the copy of the previous cycle that the shift pushed into this one
			if pnC > 0
				for _e_ in This._Q(paN[2], pnC - 1)
					if _e_[1] + _t_ >= 1
						_out_ + [ _e_[1] + _t_ - 1, _e_[2], This._Shift(_e_[3], paN[4]) ]
					ok
				next
			ok
			return _out_
		off
		return []

	# the transformation Every applies, as a node wrapped around `paChild`
	def _Wrap(paX, paChild)
		switch paX[1]
		on :rev   return [ :rev, paChild ]
		on :fast  return [ :fast, paChild, paX[2] ]
		on :slow  return [ :slow, paChild, paX[2] ]
		off
		return paChild

	def _Xform(pX)
		if isString(pX) and lower(pX) = "rev"  return [ :rev ] ok
		if isList(pX) and len(pX) = 2 and isString(pX[1])
			_c_ = lower(pX[1])
			if (_c_ = "fast" or _c_ = "slow") and isNumber(pX[2]) and pX[2] >= 1 and
			   pX[2] = floor(pX[2])
				return [ _c_, pX[2] ]
			ok
		ok
		This._Refuse("Every: the transformation is :Rev, [ :Fast, n ] or [ :Slow, n ]")
		return NULL

	# a note moved by semitones; a stroke unchanged
	def _Shift(paV, pnSemis)
		if paV[1] != "note" or pnSemis = 0  return paV ok
		_hz_ = StzNoteToHz(paV[2]) * pow(2, pnSemis / 12)
		return [ "note", This._HzName(_hz_) ]

	# a frequency as a name StzNoteToHz reads back exactly enough: the nearest
	# note plus its cents, e.g. "E5+0" -- so a shifted copy is still a WORD
	def _HzName(pnHz)
		_semis_ = 12 * log(pnHz / 440) / log(2)
		_n_ = floor(_semis_ + 0.5)
		_cents_ = floor((_semis_ - _n_) * 100 + 0.5)
		_aN_ = [ "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#" ]
		_i_ = ((_n_ % 12) + 12) % 12
		_oct_ = 4 + floor((_n_ + 9) / 12)
		_c_ = _aN_[_i_ + 1] + _oct_
		if _cents_ > 0  _c_ += "+" + _cents_ ok
		if _cents_ < 0  _c_ += "-" + fabs(_cents_) ok
		return _c_

	# deterministic "about half": a hash of the cycle, the node's seed and the
	# event's place -- the same pattern plays the same thing every time
	#
	# THE FIRST HASH KEPT 2 OF 12 in the smoke test -- a sum of the inputs
	# mod a prime, one multiply, then the LOW digits, which a multiplicative
	# generator leaves poorly mixed. Now: the inputs folded one at a time, each
	# followed by three rounds of the Park-Miller step, and the decision taken
	# from the HIGH end (the value as a fraction of the modulus). All in whole
	# numbers below 2^53, so a double holds every step exactly.
	def _Keep(pnC, pnSeed, pnI)
		_m_ = 2147483647
		_h_ = 1 + (@nSeed % 1000)
		for _v_ in [ pnC, pnSeed, pnI ]
			_h_ = (_h_ + (_v_ % 1000000) * 7919 + 1) % _m_
			for _r_ = 1 to 3  _h_ = (_h_ * 48271) % _m_ next
		next
		return _h_ / _m_ < 0.5

	def _Period(paN)
		switch paN[1]
		on :atom   return 1
		on :rest   return 1
		on :seq
			_p_ = 1
			for _s_ in paN[2]  _p_ = This._Lcm(_p_, This._Period(_s_[1])) next
			return _p_
		on :stack
			_p_ = 1
			for _k_ in paN[2]  _p_ = This._Lcm(_p_, This._Period(_k_)) next
			return _p_
		on :alt
			_p_ = 1
			for _k_ in paN[2]  _p_ = This._Lcm(_p_, This._Period(_k_)) next
			return len(paN[2]) * _p_
		on :fast
			_p_ = This._Period(paN[2])
			return _p_ / This._Gcd(_p_, paN[3])
		on :slow     return This._Period(paN[2]) * paN[3]
		on :degrade  return This._Period(paN[2])
		on :rev      return This._Period(paN[2])
		on :every    return This._Lcm(This._Period(paN[2]), paN[3])
		on :off      return This._Period(paN[2])
		off
		return 1

	def _Gcd(a, b)
		while b != 0
			_t_ = b
			b = a % b
			a = _t_
		end
		return a

	def _Lcm(a, b)
		if a > 4096 or b > 4096  return 4096 ok
		return a / This._Gcd(a, b) * b

	#-- private: the parser -------------------------------------------------
	#
	# Recursive descent over the characters. Every refusal names the place
	# (1-based) and what was expected there, and a pattern that does not parse
	# is NULL -- never half a pattern.

	def _Parse(pcText)
		@aChars = []
		for _k_ = 1 to len(pcText)  @aChars + pcText[_k_] next
		@nPos = 1
		@cOct = "4"
		@nDegrades = 0
		@cLastError = ""
		This._Ws()
		if @nPos > len(@aChars)
			This._Refuse("an empty pattern")
			return NULL
		ok
		_n_ = This._Stack("")
		if isNull(_n_)  return NULL ok
		This._Ws()
		if @nPos <= len(@aChars)
			This._Refuse("at " + @nPos + ": unexpected '" + @aChars[@nPos] + "'")
			return NULL
		ok
		return _n_

	# sequences separated by commas, up to `pcClose` (or the end, for "")
	def _Stack(pcClose)
		_aSeqs_ = []
		while TRUE
			_s_ = This._Seq(pcClose)
			if isNull(_s_)  return NULL ok
			_aSeqs_ + _s_
			This._Ws()
			if @nPos <= len(@aChars) and @aChars[@nPos] = ","
				@nPos++
				loop
			ok
			exit
		end
		if len(_aSeqs_) = 1  return _aSeqs_[1] ok
		return [ :stack, _aSeqs_ ]

	# steps up to a comma, `pcClose`, or the end
	def _Seq(pcClose)
		_aSt_ = []
		while TRUE
			This._Ws()
			if @nPos > len(@aChars)
				if pcClose != ""
					This._Refuse("at the end: '" + pcClose + "' is missing")
					return NULL
				ok
				exit
			ok
			_c_ = @aChars[@nPos]
			if _c_ = "," or _c_ = pcClose  exit ok
			if _c_ = "]" or _c_ = ">"
				This._Refuse("at " + @nPos + ": '" + _c_ + "' closes nothing")
				return NULL
			ok
			_r_ = This._Step()
			if isNull(_r_)  return NULL ok
			for _x_ in _r_  _aSt_ + _x_ next
		end
		if len(_aSt_) = 0
			This._Refuse("at " + @nPos + ": an empty sequence")
			return NULL
		ok
		if len(_aSt_) = 1 and _aSt_[1][2] = 1  return _aSt_[1][1] ok
		return [ :seq, _aSt_ ]

	# a term and its modifiers -> a list of [ node, weight ] (a list, because
	# ! turns one step into several)
	def _Step()
		_start_ = @nPos
		_n_ = This._Term()
		if isNull(_n_)  return NULL ok
		_w_ = 1
		_rep_ = 1
		while @nPos <= len(@aChars)
			_c_ = @aChars[@nPos]
			if _c_ = "*" or _c_ = "/"
				@nPos++
				_k_ = This._Number()
				if isString(_k_)  _k_ = 0 ok
				if _k_ < 1 or _k_ != floor(_k_)
					This._Refuse("at " + @nPos + ": '" + _c_ + "' takes a whole number, 1 or more " +
					             "(a fractional factor does not map cycles onto cycles)")
					return NULL
				ok
				# THROUGH A TEMPORARY: "x = [ :fast, x, k ]" in Ring built a list
				# that lost its last element -- the first run of the guard's
				# smoke test died on it
				_t_ = _n_
				if _c_ = "*"  _n_ = [ :fast, _t_, _k_ ] else _n_ = [ :slow, _t_, _k_ ] ok
			but _c_ = "?"
				@nPos++
				@nDegrades++
				_t_ = _n_
				_n_ = [ :degrade, _t_, @nDegrades ]
			but _c_ = "!"
				@nPos++
				_k_ = This._Number()
				if isString(_k_)
					_rep_ = 2
				else
					if _k_ < 1 or _k_ != floor(_k_)
						This._Refuse("at " + @nPos + ": '!' takes a whole number")
						return NULL
					ok
					_rep_ = _k_
				ok
			but _c_ = "@"
				@nPos++
				_k_ = This._Number()
				if isString(_k_)  _k_ = 0 ok
				if _k_ <= 0
					This._Refuse("at " + @nPos + ": '@' takes a positive weight")
					return NULL
				ok
				_w_ = _k_
			else
				exit
			ok
		end
		_out_ = []
		for _r_ = 1 to _rep_  _out_ + [ _n_, _w_ ] next
		return _out_

	def _Term()
		_c_ = @aChars[@nPos]
		if _c_ = "~"
			@nPos++
			return [ :rest ]
		ok
		if _c_ = "["
			_open_ = @nPos
			@nPos++
			_n_ = This._Stack("]")
			if isNull(_n_)  return NULL ok
			@nPos++          # the ]
			return _n_
		ok
		if _c_ = "<"
			@nPos++
			_aAlt_ = []
			while TRUE
				This._Ws()
				if @nPos > len(@aChars)
					This._Refuse("at the end: '>' is missing")
					return NULL
				ok
				if @aChars[@nPos] = ">"
					@nPos++
					exit
				ok
				if @aChars[@nPos] = ","
					This._Refuse("at " + @nPos + ": a ',' inside < > -- alternate whole steps, or stack in [ ]")
					return NULL
				ok
				_r_ = This._Step()
				if isNull(_r_)  return NULL ok
				for _x_ in _r_  _aAlt_ + _x_[1] next
			end
			if len(_aAlt_) = 0
				This._Refuse("at " + @nPos + ": '< >' with nothing to alternate")
				return NULL
			ok
			return [ :alt, _aAlt_ ]
		ok
		return This._Word()

	def _Word()
		_w_ = ""
		while @nPos <= len(@aChars)
			_c_ = @aChars[@nPos]
			if _c_ = " " or _c_ = char(9) or _c_ = nl or _c_ = char(13) or
			   ring_find([ "[", "]", "<", ">", ",", "*", "/", "?", "!", "@", "~" ], _c_) > 0
				exit
			ok
			_w_ += _c_
			@nPos++
		end
		if _w_ = ""
			This._Refuse("at " + @nPos + ": expected a note, a stroke, ~, [ or <")
			return NULL
		ok
		_v_ = This._Value(_w_)
		if isNull(_v_)  return NULL ok
		return [ :atom, _v_ ]

	def _Value(pcWord)
		_c_ = lower(pcWord)
		_aS_ = [ [ "bd", "kick" ], [ "sn", "snare" ], [ "hh", "hihat" ], [ "kick", "kick" ],
		         [ "snare", "snare" ], [ "hihat", "hihat" ], [ "hat", "hihat" ],
		         [ "dum", "dum" ], [ "tak", "tak" ], [ "ka", "ka" ] ]
		for _p_ in _aS_
			if _p_[1] = _c_  return [ "stroke", _p_[2] ] ok
		next
		_full_ = This._NoteName(_c_)
		if _full_ = ""
			This._Refuse("'" + pcWord + "' is neither a note name (c, e5, bb3, d4+50, e-50) " +
			             "nor a stroke (bd sn hh, kick snare hihat, dum tak ka)")
			return NULL
		ok
		return [ "note", _full_ ]

	# the octave carries, left to right, as StzScoreOfQ's does
	def _NoteName(pcTok)
		if ring_find([ "a","b","c","d","e","f","g" ], pcTok[1]) = 0  return "" ok
		_full_ = upper(pcTok[1])
		_k_ = 2
		if len(pcTok) >= 2
			if pcTok[2] = "#" or pcTok[2] = "b"
				_full_ += pcTok[2]
				_k_ = 3
			ok
		ok
		_rest_ = ""
		for _j_ = _k_ to len(pcTok)  _rest_ += pcTok[_j_] next
		_digit_ = FALSE
		if _rest_ != ""
			if isdigit(_rest_[1])  _digit_ = TRUE ok
		ok
		if NOT _digit_  _rest_ = @cOct + _rest_ ok
		_full_ += _rest_
		if StzNoteToHz(_full_) = 0  return "" ok
		_o_ = ""
		for _j_ = 2 to len(_full_)
			if isdigit(_full_[_j_])
				_o_ += _full_[_j_]
			but _o_ != ""
				exit
			ok
		next
		@cOct = _o_
		return _full_

	def _Number()
		_s_ = ""
		while @nPos <= len(@aChars)
			_c_ = @aChars[@nPos]
			if isdigit(_c_) or _c_ = "."
				_s_ += _c_
				@nPos++
			else
				exit
			ok
		end
		if _s_ = "" or _s_ = "."  return "" ok     # "" = no number here
		return 0 + _s_

	def _Ws()
		while @nPos <= len(@aChars)
			_c_ = @aChars[@nPos]
			if _c_ = " " or _c_ = char(9) or _c_ = nl or _c_ = char(13)
				@nPos++
			else
				exit
			ok
		end

	def _Refuse(pcWhy)
		@nRefusals++
		@cLastError = pcWhy

	def _WholeFactor(pn, pcWho)
		if NOT isNumber(pn) or pn < 1 or pn != floor(pn)
			This._Refuse(pcWho + ": a whole number, 1 or more (a fractional factor does not map cycles onto cycles)")
			return FALSE
		ok
		return TRUE

	def _SortByOnset(paE)
		_a_ = paE
		_n_ = len(_a_)
		for _i_ = 2 to _n_
			_e_ = _a_[_i_]
			_j_ = _i_ - 1
			while _j_ >= 1 and _a_[_j_][1] > _e_[1]
				_a_[_j_ + 1] = _a_[_j_]
				_j_--
			end
			_a_[_j_ + 1] = _e_
		next
		return _a_
