#---------------------------------------------------------------------------#
#  STZSOUNDPATTERN -- rhythm is a string, and a pattern is a function of    #
#  time (MU3)                                                                #
#---------------------------------------------------------------------------#
#
#     oP = StzSoundPatternQ("bd ~ sn [hh hh]")        # Tidal's mini-notation
#     ? oP.CycleEvents(0)                        # what cycle 0 holds
#     oP.Fast(2).Every(3, :Rev).Off(0.25, 12)    # the algebra, chained
#     oP.ToScoreQ(4)                              # four cycles, as a stzSoundScore
#
# NAMED FOR ITS DOMAIN, 2026-09-26. It was stzPattern; on the author's word
# the name went to the domain-free class this one now extends
# (base/common/stzPattern.ring: the grammar, the query, the algebra). What is
# left here is what a word MEANS in sound -- a note or a stroke -- what Off's
# argument means (semitones), and the readers only sound needs.
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
# carries left to right, as in StzSoundScoreOfQ) or a stroke: dum tak ka, kick
# snare hihat, and Tidal's own bd sn hh for the kit.
#
# WHAT IS NOT HERE: euclidean rhythms "bd(3,8)", fractional factors, sample
# banks "bd:3", and jux (a stereo copy -- the timeline mixes every note to all
# channels and has no pan per note). Each is a later phase's, or needs an
# engine change that is not this phase's.

func StzSoundPatternQ(pcText)
	return new stzSoundPattern(pcText)

class stzSoundPattern from stzPattern

	@cOct = "4"             # the octave a note name without one takes

	# The distinct notes and strokes over the first `pnCycles` cycles -- what
	# a player renders BEFORE it starts: DistinctValues, in sound's word.
	def DistinctNotes(pnCycles)
		return This.DistinctValues(pnCycles)

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

	# `pnCycles` cycles as a stzSoundScore, a cycle being four beats. The pivot:
	# a pattern is a function, a score is data, and this is where one
	# becomes the other.
	def ToScoreQ(pnCycles)
		_oS_ = StzSoundScoreQ()
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

	#-- the domain's hooks (see stzPattern) ---------------------------------

	def _Value(pcWord)
		_c_ = lower(pcWord)
		_aS_ = [ [ "bd", "kick" ], [ "sn", "snare" ], [ "hh", "hihat" ], [ "kick", "kick" ],
		         [ "snare", "snare" ], [ "hihat", "hihat" ], [ "hat", "hihat" ],
		         [ "dum", "dum" ], [ "tak", "tak" ], [ "ka", "ka" ],
		         [ "cr", "crash" ], [ "crash", "crash" ], [ "rd", "ride" ], [ "ride", "ride" ],
		         [ "ht", "hightom" ], [ "hightom", "hightom" ], [ "mt", "midtom" ], [ "midtom", "midtom" ],
		         [ "ft", "floortom" ], [ "floortom", "floortom" ], [ "oh", "openhat" ], [ "openhat", "openhat" ] ]
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

	# the octave carries, left to right, as StzSoundScoreOfQ's does
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

	# a note moved by semitones; a stroke unchanged; no argument moves nothing
	def _Shift(paV, pnSemis)
		if NOT isNumber(pnSemis)  return paV ok
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

	# the octave carries left to right, so each parse starts again at 4
	def _ResetParse()
		@cOct = "4"
