#---------------------------------------------------------------------------#
#  STZSCORE -- music as DATA, before it is anything else (MU2)              #
#---------------------------------------------------------------------------#
#
#     oS = StzScoreOfQ("c e g c5")                 # four quarter notes
#     oS.Then( StzScoreOfQ("g f e d") )           # one after the other
#     oS.Together( StzScoreOfQ("c3 ~ g2 ~").On(:Harp) )   # at the same time
#     oS.Transpose(2).Tempo(96).Swing(0.62)
#     oS.ToSoundQ().SaveAs("tune.wav")            # the performance, offline
#     StzSchedulerQ(oS).Play()                    # the performance, live
#
# THE SHAPE IS EUTERPEA'S (plan 1.2): a note, a rest, a SEQUENCE of scores, a
# PARALLEL of scores, and modifiers over a whole score -- an instrument, a
# transposition. Everything from one note to a symphony is the same type, so
# every verb here works on all of it. It is stored FLAT, as events in beats,
# because a score is read far more often than it is built: the scheduler, the
# offline render and every future analysis want the events, not the tree.
#
# BEATS, NOT SECONDS. A score says WHEN in beats; the performance settings
# (Tempo, Quantize, Swing) turn beats into frames, once, in FrameOf(). Keeping
# them apart is what lets one score be played at two tempi or swung and
# straight without being rewritten -- Csound's orchestra/score split, applied
# to time.
#
# AN EVENT is [ startBeat, beats, hz, instrument, velocity, stroke ]. `hz` is
# 0 for a stroke whose drum decides its own pitch; `instrument` is "" until a
# modifier or the performance default (:Piano) names one; `stroke` is "" for
# a pitched note.
#
# WHAT IT IS NOT (MU2's count): no mini-notation beyond space-separated note
# names and ~ for a rest -- durations, [ ] groups and <a b> alternation are the
# pattern language, MU3's. No universe: a pitch is a note name or a frequency,
# and the tuning is 12-TET plus the cents StzNoteToHz already reads. MU4's.

func StzScoreQ()
	return new stzScore("")

# Space-separated note names, each a quarter note (one beat). The octave is
# optional and CARRIES, as Alda's does: "c e g c5" is C4 E4 G4 C5, and after
# the C5 an octave-less "e" would be E5. ~ is a rest of one beat.
func StzScoreOfQ(pcNotes)
	return new stzScore(pcNotes)

class stzScore

	@aEvents = []          # [ startBeat, beats, hz, instrument, velocity, stroke ]
	@nBeats = 0            # the length, in beats -- where the next Then() starts
	@nTempo = 120
	@nQuantize = 0         # 0 = no grid
	@nSwing = 0.5          # 0.5 = straight
	@nSwingGrid = 0.5      # the swung subdivision, in beats: 0.5 = eighth notes
	@nVelocity = 0.8
	@cOn = ""              # the instrument On() named, for notes added after it
	@cLastError = ""
	@nRefusals = 0

	def init(pcNotes)
		if NOT isString(pcNotes) or ring_trim(pcNotes) = ""  return ok
		This.AddNotes(pcNotes)

	#-- building ------------------------------------------------------------

	# One pitched note, after everything already in the score. `pNote` is a
	# note name ("A4", "C#3", "Bb2", "D4+50") or a frequency in Hz.
	def Note(pNote, pnBeats)
		_hz_ = pNote
		if isString(pNote)
			_hz_ = StzNoteToHz(pNote)
		ok
		if NOT isNumber(_hz_) or _hz_ <= 0
			This._Refuse("Note: '" + pNote + "' is not a note name (A4, C#3, Bb2, D4+50) or a frequency")
			return This
		ok
		if NOT This._GoodBeats(pnBeats, "Note")  return This ok
		@aEvents + [ @nBeats, pnBeats, _hz_, @cOn, @nVelocity, "" ]
		@nBeats += pnBeats
		return This

	def NoteQ(pNote, pnBeats)
		return This.Note(pNote, pnBeats)

	def Rest(pnBeats)
		if NOT This._GoodBeats(pnBeats, "Rest")  return This ok
		@nBeats += pnBeats
		return This

	def RestQ(pnBeats)
		return This.Rest(pnBeats)

	# A struck sound on a membrane -- :dum, :tak, :ka, or :kick, :snare, :hihat
	# on the kit. Which drum strikes it is the instrument's business (On).
	def Stroke(pStroke, pnBeats)
		_s_ = lower("" + pStroke)
		if ring_find([ "dum", "tak", "ka", "kick", "snare", "hihat", "hat" ], _s_) = 0
			This._Refuse("Stroke: '" + pStroke + "' is not a stroke (dum, tak, ka -- or kick, snare, hihat)")
			return This
		ok
		if NOT This._GoodBeats(pnBeats, "Stroke")  return This ok
		@aEvents + [ @nBeats, pnBeats, 0, @cOn, @nVelocity, _s_ ]
		@nBeats += pnBeats
		return This

	def StrokeQ(pStroke, pnBeats)
		return This.Stroke(pStroke, pnBeats)

	# Space-separated names, one beat each; the octave carries; ~ rests.
	def AddNotes(pcNotes)
		_aTok_ = This._Words("" + pcNotes)
		_oct_ = "4"
		for _t_ in _aTok_
			if _t_ = "~"
				This.Rest(1)
				loop
			ok
			_full_ = This._WithOctave(_t_, _oct_)
			if _full_ = ""
				This._Refuse("'" + _t_ + "' is not a note name -- a letter a..g, an optional # or b, an optional octave, optional +/-cents")
				loop
			ok
			_oct_ = This._OctaveOf(_full_)
			This.Note(_full_, 1)
		next
		return This

	def AddNotesQ(pcNotes)
		return This.AddNotes(pcNotes)

	#-- the algebra ---------------------------------------------------------

	# SEQUENCE: the other score starts where this one ends.
	def Then(poScore)
		if NOT This._IsScore(poScore, "Then")  return This ok
		for _e_ in poScore.Events()
			_c_ = _e_
			_c_[1] += @nBeats
			@aEvents + _c_
		next
		@nBeats += poScore.Beats()
		return This

	def ThenQ(poScore)
		return This.Then(poScore)

	# PARALLEL: the other score starts where this one starts. The length is
	# the longer of the two.
	def Together(poScore)
		if NOT This._IsScore(poScore, "Together")  return This ok
		for _e_ in poScore.Events()
			@aEvents + _e_
		next
		if poScore.Beats() > @nBeats  @nBeats = poScore.Beats() ok
		return This

	def TogetherQ(poScore)
		return This.Together(poScore)

	# The same score, n times in sequence.
	def Repeat(pnTimes)
		if NOT isNumber(pnTimes) or pnTimes < 1 or pnTimes != floor(pnTimes)
			This._Refuse("Repeat: a whole number of times, 1 or more")
			return This
		ok
		_one_ = @aEvents
		_len_ = @nBeats
		for _k_ = 2 to pnTimes
			for _e_ in _one_
				_c_ = _e_
				_c_[1] += _len_ * (_k_ - 1)
				@aEvents + _c_
			next
		next
		@nBeats = _len_ * pnTimes
		return This

	def RepeatQ(pnTimes)
		return This.Repeat(pnTimes)

	# THE INSTRUMENT, as a modifier: it names every event that has none yet,
	# so an inner On() survives an outer one -- the innermost wins, as it does
	# in Euterpea. Refused when this engine has no such instrument.
	#
	# AND it names the notes this score gains AFTERWARDS by Note and Stroke.
	# The first cut was the pure modifier only, and the very first smoke test
	# fell into it: StzScoreQ().On(:Drumkit) then twenty strokes named NOTHING
	# (the score was empty when On ran), so every stroke went to the default
	# piano and was refused. A rule that the first user breaks in the first
	# line is the rule's fault. Scores joined by Then or Together keep their
	# own naming -- an unnamed part stays unnamed until an outer On names it.
	def On(pInstrument)
		_c_ = lower("" + pInstrument)
		if StzEngineSoundInstrumentIndex(_c_) = 0
			This._Refuse("On: no instrument named '" + pInstrument + "' -- this engine has: " +
			             This._Joined(StzInstruments()))
			return This
		ok
		_n_ = len(@aEvents)
		for _i_ = 1 to _n_
			if @aEvents[_i_][4] = ""  @aEvents[_i_][4] = _c_ ok
		next
		@cOn = _c_
		return This

	def OnQ(pInstrument)
		return This.On(pInstrument)

	# Semitones, fractional allowed (0.5 is a quarter tone). Strokes keep
	# their pitch: a transposed drum pattern is the same drum pattern.
	def Transpose(pnSemitones)
		if NOT isNumber(pnSemitones)
			This._Refuse("Transpose: a number of semitones")
			return This
		ok
		_f_ = pow(2, pnSemitones / 12)
		_n_ = len(@aEvents)
		for _i_ = 1 to _n_
			if @aEvents[_i_][3] > 0  @aEvents[_i_][3] *= _f_ ok
		next
		return This

	def TransposeQ(pnSemitones)
		return This.Transpose(pnSemitones)

	# The velocity of notes ADDED FROM NOW ON, 0 < v <= 1.
	def SetVelocity(pnVelocity)
		if NOT isNumber(pnVelocity) or pnVelocity <= 0 or pnVelocity > 1
			This._Refuse("SetVelocity: a velocity is above 0 and at most 1")
			return This
		ok
		@nVelocity = pnVelocity
		return This

	def SetVelocityQ(pnVelocity)
		return This.SetVelocity(pnVelocity)

	#-- the performance settings -------------------------------------------

	def Tempo(pnBpm)
		if NOT isNumber(pnBpm) or pnBpm < 20 or pnBpm > 400
			This._Refuse("Tempo: beats per minute, 20 to 400")
			return This
		ok
		@nTempo = pnBpm
		return This

	def TempoQ(pnBpm)
		return This.Tempo(pnBpm)

	# Snap every start to the nearest multiple of `pnGrid` beats (0.25 = a
	# sixteenth). 0 turns it off. Durations are left alone.
	def Quantize(pnGrid)
		if NOT isNumber(pnGrid) or pnGrid < 0
			This._Refuse("Quantize: a grid in beats, or 0 for none")
			return This
		ok
		@nQuantize = pnGrid
		return This

	def QuantizeQ(pnGrid)
		return This.Quantize(pnGrid)

	# SWING: the first of each PAIR of subdivisions lasts `pnRatio` of the
	# pair. 0.5 is straight, 2/3 is a triplet swing, 0.75 a dotted one. Every
	# position is warped, not only those on the grid -- the first half of each
	# pair is stretched and the second compressed, piecewise-linearly -- so a
	# note between two grid points moves with its neighbours instead of
	# jumping past one.
	def Swing(pnRatio)
		return This.SwingOn(pnRatio, 0.5)

	def SwingOn(pnRatio, pnGrid)
		if NOT isNumber(pnRatio) or pnRatio <= 0 or pnRatio >= 1
			This._Refuse("Swing: a ratio strictly between 0 and 1 -- 0.5 is straight")
			return This
		ok
		if NOT isNumber(pnGrid) or pnGrid <= 0
			This._Refuse("Swing: the swung subdivision is a positive number of beats")
			return This
		ok
		@nSwing = pnRatio
		@nSwingGrid = pnGrid
		return This

	def SwingQ(pnRatio)
		return This.Swing(pnRatio)

	#-- reading it ----------------------------------------------------------

	# The events in start order. A copy: changing it changes nothing here.
	def Events()
		return This._Sorted(@aEvents)

	def NumberOfEvents()
		return len(@aEvents)

	def Beats()
		return @nBeats

	def TempoInBpm()
		return @nTempo

	def SwingRatio()
		return @nSwing

	def Seconds()
		return @nBeats * 60 / @nTempo

	# WHERE A BEAT LANDS, in 0-based frames at `pnRate`: quantised, then
	# swung, then timed. The one place beats become frames -- the offline
	# render and the live scheduler both call it, so they cannot disagree
	# about when a note is.
	def FrameOf(pnBeat, pnRate)
		_b_ = pnBeat
		if @nQuantize > 0
			_b_ = floor(_b_ / @nQuantize + 0.5) * @nQuantize
		ok
		if @nSwing != 0.5
			_pair_ = 2 * @nSwingGrid
			_k_ = floor(_b_ / _pair_)
			_t_ = _b_ - _k_ * _pair_
			_split_ = _pair_ * @nSwing
			if _t_ < @nSwingGrid
				_t_ = _t_ * _split_ / @nSwingGrid
			else
				_t_ = _split_ + (_t_ - @nSwingGrid) * (_pair_ - _split_) / @nSwingGrid
			ok
			_b_ = _k_ * _pair_ + _t_
		ok
		return floor(_b_ * 60 / @nTempo * pnRate + 0.5)

	def SecondsOf(pnBeats)
		return pnBeats * 60 / @nTempo

	#-- performing it -------------------------------------------------------

	# The whole performance, rendered offline into one sound. Every note is
	# the instrument's (MU1), placed at FrameOf() by mixInto.
	def ToSound()
		_oR_ = new stzScoreRenderer(This)
		_o_ = _oR_.Offline()
		@cLastError = _oR_.LastError()
		_oR_.Release()
		return _o_

	def ToSoundQ()
		return This.ToSound()

	def Play()
		_oP_ = StzSchedulerQ(This)
		_oP_.Play()
		_oP_.RunToEnd()
		@cLastError = _oP_.LastError()
		_oP_.Release()
		return This

	def LastError()
		return @cLastError

	def Refusals()
		return @nRefusals

	#-- private -------------------------------------------------------------

	def _Refuse(pcWhy)
		@nRefusals++
		@cLastError = pcWhy

	def _GoodBeats(pnBeats, pcWho)
		if NOT isNumber(pnBeats) or pnBeats <= 0
			This._Refuse(pcWho + ": a length is a positive number of beats")
			return FALSE
		ok
		return TRUE

	def _IsScore(po, pcWho)
		if isObject(po) and classname(po) = "stzscore"  return TRUE ok
		This._Refuse(pcWho + ": needs a stzScore")
		return FALSE

	# words split on spaces and tabs -- by hand, because split() is in Ring's
	# stdlib and this plane must not depend on it being loaded
	def _Words(pcText)
		_a_ = []
		_w_ = ""
		for _k_ = 1 to len(pcText)
			_ch_ = pcText[_k_]
			if _ch_ = " " or _ch_ = char(9) or _ch_ = nl
				if _w_ != ""  _a_ + _w_  _w_ = "" ok
			else
				_w_ += _ch_
			ok
		next
		if _w_ != ""  _a_ + _w_ ok
		return _a_

	# "e" + "4" -> "e4"; "e5" stays; "c#" -> "c#4"; "d+50" -> "d4+50".
	# "" when the token is not a note.
	def _WithOctave(pcTok, pcOct)
		_c_ = lower(pcTok)
		if ring_find([ "a","b","c","d","e","f","g" ], _c_[1]) = 0  return "" ok
		# the letter, upper-cased; then an accidental if there is one; then
		# the rest -- walked by hand so no slice is ever taken past the end
		_full_ = upper(_c_[1])
		_k_ = 2
		if len(_c_) >= 2
			if _c_[2] = "#" or _c_[2] = "b"
				_full_ += _c_[2]
				_k_ = 3
			ok
		ok
		_rest_ = ""
		for _j_ = _k_ to len(_c_)
			_rest_ += _c_[_j_]
		next
		_digit_ = FALSE
		if _rest_ != ""
			if isdigit(_rest_[1])  _digit_ = TRUE ok
		ok
		if NOT _digit_  _rest_ = pcOct + _rest_ ok
		_full_ += _rest_
		if StzNoteToHz(_full_) = 0  return "" ok
		return _full_

	def _OctaveOf(pcFull)
		_o_ = ""
		for _k_ = 2 to len(pcFull)
			if isdigit(pcFull[_k_])
				_o_ += pcFull[_k_]
			but _o_ != ""
				exit
			ok
		next
		return _o_

	# a stable insertion sort on the start beat: parallel parts that begin
	# together keep the order they were written in
	def _Sorted(paEvents)
		_a_ = paEvents
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

	def _Joined(paList)
		_s_ = ""
		for _i_ = 1 to len(paList)
			if _i_ > 1  _s_ += ", " ok
			_s_ += "" + paList[_i_]
		next
		return _s_


# THE NOTES OF A PERFORMANCE: every event rendered by its instrument once, and
# the same note -- same instrument, pitch, length, velocity, stroke -- rendered
# ONCE however often it recurs. A wind instrument tunes itself by listening
# (MU1) and that is slow; a repeated note must not pay it twice. Shared by the
# offline render and the scheduler, so both play the same buffers.
class stzScoreRenderer

	@oScore = NULL
	@nRate = 48000
	@nChannels = 2
	@nGain = 0.6            # per note, so a chord of a few does not clip
	@aKeys = []             # [ key, bufferId ]
	@aInst = []             # [ name, stzInstrument ]
	@aPlan = []             # [ frame0, bufferId ] per event, in start order
	@nEndFrame = 0
	@cLastError = ""
	@nRefusals = 0
	@nRendered = 0          # distinct notes the instruments rendered
	@nSeconds = 0           # wall time spent rendering them

	def init(poScore)
		@oScore = poScore

	def SetGain(pnGain)
		@nGain = pnGain

	def Gain()
		return @nGain

	def Rate()
		return @nRate

	def Channels()
		return @nChannels

	def LastError()
		return @cLastError

	def Refusals()
		return @nRefusals

	def NotesRendered()
		return @nRendered

	def SecondsRendering()
		return @nSeconds

	def EndFrame()
		return @nEndFrame

	# [ frame0, bufferId ] per event, in start order; rendered on first ask.
	def Plan()
		if len(@aPlan) = 0 and @oScore.NumberOfEvents() > 0
			This._Build()
		ok
		return @aPlan

	def Offline()
		_aP_ = This.Plan()
		_n_ = @nEndFrame
		if _n_ < 1  _n_ = 1 ok
		_o_ = new stzSound("")
		_o_.MakeSilence(_n_ / @nRate, @nChannels, @nRate)
		for _p_ in _aP_
			if StzEngineSoundMixInto(_o_.BufferId(), _p_[2], _p_[1] + 1, @nGain) < 0
				@cLastError = StzEngineSoundLastError()
				@nRefusals++
			ok
		next
		return _o_

	def Release()
		for _k_ in @aKeys
			StzEngineSoundFree(_k_[2])
		next
		@aKeys = []
		@aPlan = []

	def _Build()
		_t0_ = clock()
		_aEv_ = @oScore.Events()
		for _e_ in _aEv_
			_b_ = This._BufferFor(_e_)
			if _b_ = 0  loop ok
			_f_ = @oScore.FrameOf(_e_[1], @nRate)
			@aPlan + [ _f_, _b_ ]
			_end_ = _f_ + StzEngineSoundFrames(_b_)
			if _end_ > @nEndFrame  @nEndFrame = _end_ ok
		next
		@nSeconds = (clock() - _t0_) / clockspersecond()

	def _BufferFor(paEvent)
		_inst_ = paEvent[4]
		if _inst_ = ""  _inst_ = "piano" ok
		_hold_ = @oScore.SecondsOf(paEvent[2])
		_key_ = _inst_ + "|" + paEvent[3] + "|" + _hold_ + "|" + paEvent[5] + "|" + paEvent[6]
		for _k_ in @aKeys
			if _k_[1] = _key_  return _k_[2] ok
		next
		_oI_ = This._Instrument(_inst_)
		if NOT _oI_.IsUsable()
			@cLastError = _oI_.LastError()
			@nRefusals++
			return 0
		ok
		_oI_.SetVelocity(paEvent[5])
		if paEvent[6] != ""
			_hz_ = paEvent[3]
			if _hz_ <= 0
				_r_ = _oI_.Range()
				_hz_ = sqrt(_r_[1] * _r_[2])
			ok
			_oS_ = _oI_.ToSoundOfStroke(paEvent[6], _hz_, _hold_)
		else
			_oS_ = _oI_.ToSoundOf(paEvent[3], _hold_)
		ok
		if NOT isObject(_oS_)
			@cLastError = _oI_.LastError()
			@nRefusals++
			return 0
		ok
		_b_ = _oS_.BufferId()
		@aKeys + [ _key_, _b_ ]
		@nRendered++
		return _b_

	def _Instrument(pcName)
		for _p_ in @aInst
			if _p_[1] = pcName  return _p_[2] ok
		next
		_o_ = StzInstrumentQ(pcName)
		@aInst + [ pcName, _o_ ]
		return _o_
