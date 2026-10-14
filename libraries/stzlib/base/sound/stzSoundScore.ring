#---------------------------------------------------------------------------#
#  STZSCORE -- music as DATA, before it is anything else (MU2)              #
#---------------------------------------------------------------------------#
#
#     oS = StzSoundScoreOfQ("c e g c5")                 # four quarter notes
#     oS.Then( StzSoundScoreOfQ("g f e d") )           # one after the other
#     oS.Together( StzSoundScoreOfQ("c3 ~ g2 ~").On(:Harp) )   # at the same time
#     oS.Transpose(2).Tempo(96).Swing(0.62)
#     oS.ToSoundQ().SaveAs("tune.wav")            # the performance, offline
#     StzSoundSchedulerQ(oS).Play()                    # the performance, live
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

func StzSoundScoreQ()
	return new stzSoundScore("")

# Space-separated note names, each a quarter note (one beat). The octave is
# optional and CARRIES, as Alda's does: "c e g c5" is C4 E4 G4 C5, and after
# the C5 an octave-less "e" would be E5. ~ is a rest of one beat.
func StzSoundScoreOfQ(pcNotes)
	return new stzSoundScore(pcNotes)

# Holds music as data: a flat list of timed notes, rests and drum strokes, measured in beats rather than seconds.
#
# Everything from one note to a whole piece is the same type, so Then, Together, Repeat, On and
# Transpose work on all of it. An event is [ startBeat, beats, hz, instrument, velocity, stroke,
# glideEndHz ]. The performance settings Tempo, Quantize and Swing turn beats into frames only when
# a sound is made, in FrameOf, so one score can be rendered at two speeds or swung and straight
# without being rewritten. A refused call leaves the score unchanged, counts in Refusals and
# explains itself in LastError. ToSound renders to memory with no audio device; Play goes live
# through the scheduler. The result has not been heard by a person (UNPERCEIVED): it is checked by
# frame count, sample rate and peak level.
#
#   receiver   o1 = new stzSoundScore("c e g c5")
#   example    ? o1.Beats()
#              #--> 4
#              ? o1.Seconds()
#              #--> 2
#              ? o1.Contour()
#              #--> U U U
#              ? o1.ToSound().SampleRate()
#              #--> 48000
#   see        stzSoundScoreRenderer, stzSoundScheduler, stzSound
class stzSoundScore

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

	# Builds a score, empty or filled from space-separated note names of one beat each.
	#
	#   pcNotes    space-separated note names, ~ for a rest, or an empty text for an empty score
	#   returns    nothing; the object is built
	#   note       the octave carries from one name to the next
	#   warning    a name that is not a note is skipped and counted in Refusals
	#   see        AddNotes, StzSoundScoreOfQ
	def init(pcNotes)
		if NOT isString(pcNotes) or ring_trim(pcNotes) = ""  return ok
		This.AddNotes(pcNotes)

	# Appends one pitched note after everything already in the score.
	#
	#   pNote      a note name such as A4, C#3, Bb2 or D4+50, or a frequency in hertz
	#   pnBeats    the length of the note in beats
	#   returns    the score itself, so calls chain
	#   note       the note takes the instrument named by On and the velocity set by SetVelocity
	#   warning    a name or length that is refused leaves the score unchanged, counts in Refusals
	#              and sets LastError
	#   see        NoteAt, AddNotes, Rest
	#@ aka  -- building ------------------------------------------------------------
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
		@aEvents + [ @nBeats, pnBeats, _hz_, @cOn, @nVelocity, "", 0 ]
		@nBeats += pnBeats
		return This

	def NoteQ(pNote, pnBeats)
		return This.Note(pNote, pnBeats)

	# Adds a note whose pitch slides from one pitch to another over its whole length, at an explicit beat.
	#
	#   pnBeat     the beat where the glide starts, 0 or later
	#   pFrom      the starting pitch, a note name or a frequency
	#   pTo        the ending pitch, a note name or a frequency
	#   pnBeats    the length of the glide in beats
	#   returns    the score itself, so calls chain
	#   note       the score length grows to cover the glide
	#   warning    refused, with LastError set, for a bad pitch, beat or length; a pluck or an FM
	#              instrument (guitar, harp) refuses to render a glide, so that note is missing from
	#              ToSound
	#   see        NoteAt, Note
	#@ aka  MU4: a note whose pitch MOVES from one pitch to another over its whole length -- a meend, a Zarma slide, a kalangu's squeezed tone. Names or Hz.
	def GlideAt(pnBeat, pFrom, pTo, pnBeats)
		_a_ = pFrom
		if isString(pFrom)  _a_ = StzNoteToHz(pFrom) ok
		_b_ = pTo
		if isString(pTo)  _b_ = StzNoteToHz(pTo) ok
		if NOT isNumber(_a_) or _a_ <= 0 or NOT isNumber(_b_) or _b_ <= 0
			This._Refuse("GlideAt: both ends are note names or frequencies")
			return This
		ok
		if NOT isNumber(pnBeat) or pnBeat < 0
			This._Refuse("GlideAt: a beat is 0 or later")
			return This
		ok
		if NOT This._GoodBeats(pnBeats, "GlideAt")  return This ok
		@aEvents + [ pnBeat, pnBeats, _a_, @cOn, @nVelocity, "", _b_ ]
		if pnBeat + pnBeats > @nBeats  @nBeats = pnBeat + pnBeats ok
		return This

	# Adds a pitched note at an explicit beat without moving where the next appended note goes.
	#
	#   pnBeat     the beat where the note starts, 0 or later
	#   pNote      a note name or a frequency in hertz
	#   pnBeats    the length of the note in beats
	#   returns    the score itself, so calls chain
	#   note       the score length grows to cover the note
	#   warning    refused, with LastError set, for a bad pitch, beat or length
	#   see        Note, StrokeAt
	#@ aka  MU3: a note at an explicit beat, for a score built from a pattern. It does not move where the next Note() goes; the length grows to cover it.
	def NoteAt(pnBeat, pNote, pnBeats)
		_hz_ = pNote
		if isString(pNote)  _hz_ = StzNoteToHz(pNote) ok
		if NOT isNumber(_hz_) or _hz_ <= 0
			This._Refuse("NoteAt: '" + pNote + "' is not a note name or a frequency")
			return This
		ok
		if NOT isNumber(pnBeat) or pnBeat < 0
			This._Refuse("NoteAt: a beat is 0 or later")
			return This
		ok
		if NOT This._GoodBeats(pnBeats, "NoteAt")  return This ok
		@aEvents + [ pnBeat, pnBeats, _hz_, @cOn, @nVelocity, "", 0 ]
		if pnBeat + pnBeats > @nBeats  @nBeats = pnBeat + pnBeats ok
		return This

	# Adds a drum stroke at an explicit beat without moving where the next appended note goes.
	#
	#   pnBeat     the beat where the stroke starts, 0 or later
	#   pStroke    the stroke name: dum, tak, ka, kick, snare, hihat, hat, crash, ride, hightom,
	#              midtom, floortom or openhat
	#   pnBeats    the length of the stroke in beats
	#   returns    the score itself, so calls chain
	#   note       the stroke's pitch is 0, so the drum instrument decides it
	#   warning    an unknown stroke name is refused, with LastError set
	#   see        Stroke, NoteAt
	def StrokeAt(pnBeat, pStroke, pnBeats)
		_s_ = lower("" + pStroke)
		if ring_find([ "dum", "tak", "ka", "kick", "snare", "hihat", "hat", "crash", "ride", "hightom", "midtom", "floortom", "openhat" ], _s_) = 0
			This._Refuse("StrokeAt: '" + pStroke + "' is not a stroke")
			return This
		ok
		if NOT isNumber(pnBeat) or pnBeat < 0
			This._Refuse("StrokeAt: a beat is 0 or later")
			return This
		ok
		if NOT This._GoodBeats(pnBeats, "StrokeAt")  return This ok
		@aEvents + [ pnBeat, pnBeats, 0, @cOn, @nVelocity, _s_, 0 ]
		if pnBeat + pnBeats > @nBeats  @nBeats = pnBeat + pnBeats ok
		return This

	# Sets the length of the score in beats outright, whatever its last note does.
	#
	#   pnBeats    the new length in beats, 0 or more
	#   returns    the score itself, so calls chain
	#   note       it can shorten the score below its last note
	#   warning    a negative or non-numeric value is ignored without a refusal
	#   see        Beats, Rest
	#@ aka  The length in beats, set outright -- a pattern's cycles end where they end, whatever their last note does.
	def SetLength(pnBeats)
		if isNumber(pnBeats) and pnBeats >= 0  @nBeats = pnBeats ok
		return This

	# Adds silence of the given length after everything already in the score.
	#
	#   pnBeats    the length of the silence in beats
	#   returns    the score itself, so calls chain
	#   warning    a length that is not positive is refused, with LastError set
	#   see        Note, SetLength
	def Rest(pnBeats)
		if NOT This._GoodBeats(pnBeats, "Rest")  return This ok
		@nBeats += pnBeats
		return This

	def RestQ(pnBeats)
		return This.Rest(pnBeats)

	# Appends one drum stroke after everything already in the score.
	#
	#   pStroke    the stroke name: dum, tak, ka, kick, snare, hihat, hat, crash, ride, hightom,
	#              midtom, floortom or openhat
	#   pnBeats    the length of the stroke in beats
	#   returns    the score itself, so calls chain
	#   note       which drum strikes it is decided by the instrument named in On
	#   warning    an unknown stroke name is refused, with LastError set
	#   see        StrokeAt, On
	#@ aka  A struck sound on a membrane -- :dum, :tak, :ka, or :kick, :snare, :hihat on the kit. Which drum strikes it is the instrument's business (On).
	def Stroke(pStroke, pnBeats)
		_s_ = lower("" + pStroke)
		if ring_find([ "dum", "tak", "ka", "kick", "snare", "hihat", "hat", "crash", "ride", "hightom", "midtom", "floortom", "openhat" ], _s_) = 0
			This._Refuse("Stroke: '" + pStroke + "' is not a stroke (dum, tak, ka -- or kick, snare, hihat)")
			return This
		ok
		if NOT This._GoodBeats(pnBeats, "Stroke")  return This ok
		@aEvents + [ @nBeats, pnBeats, 0, @cOn, @nVelocity, _s_, 0 ]
		@nBeats += pnBeats
		return This

	def StrokeQ(pStroke, pnBeats)
		return This.Stroke(pStroke, pnBeats)

	# Appends space-separated note names of one beat each, where the octave carries and ~ is a rest.
	#
	#   pcNotes    the note names, such as c e g c5, with ~ for a one-beat rest
	#   returns    the score itself, so calls chain
	#   note       in c e g c5 the first three are octave 4 and a following e would be e5
	#   warning    a word that is not a note is skipped, counted in Refusals and named in LastError
	#   see        Note, init
	#@ aka  Space-separated names, one beat each; the octave carries; ~ rests.
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

	# Appends another score so that it starts where this one ends.
	#
	#   poScore    the stzSoundScore to play after this one
	#   returns    the score itself, so calls chain
	#   note       the other score is copied, so changing it later does not change this one
	#   warning    anything but a stzSoundScore is refused, with LastError set
	#   see        Together, Repeat
	#@ aka  -- the algebra ---------------------------------------------------------
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

	# Overlays another score so that it starts where this one starts.
	#
	#   poScore    the stzSoundScore to play at the same time
	#   returns    the score itself, so calls chain
	#   note       the length becomes the longer of the two
	#   warning    anything but a stzSoundScore is refused, with LastError set
	#   see        Then
	#@ aka  PARALLEL: the other score starts where this one starts. The length is the longer of the two.
	def Together(poScore)
		if NOT This._IsScore(poScore, "Together")  return This ok
		for _e_ in poScore.Events()
			@aEvents + _e_
		next
		if poScore.Beats() > @nBeats  @nBeats = poScore.Beats() ok
		return This

	def TogetherQ(poScore)
		return This.Together(poScore)

	# Plays the score so many times in sequence, by copying its events.
	#
	#   pnTimes    how many times in all, a whole number of 1 or more
	#   returns    the score itself, so calls chain
	#   note       the length is multiplied by pnTimes
	#   warning    zero, a fraction or a non-number is refused, with LastError set
	#   see        Then
	#@ aka  The same score, n times in sequence.
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

	# Sets the instrument of every event that is still unnamed, and of notes added afterwards.
	#
	#   pInstrument   the instrument name, such as harp, guitar, bell, flute or drumkit
	#   returns       the score itself, so calls chain
	#   note          an inner naming wins over an outer one, since only unnamed events are named; a
	#                 score joined by Then or Together keeps its own naming
	#   warning       an unknown instrument is refused and LastError lists the instruments this
	#                 engine has
	#   see           Stroke, StzSoundInstruments
	#@ aka  THE INSTRUMENT, as a modifier: it names every event that has none yet, so an inner On() survives an outer one -- the innermost wins, as it does in Euterpea. Refused when this engine has no such instrument.
	def On(pInstrument)
		_c_ = lower("" + pInstrument)
		if StzEngineSoundInstrumentIndex(_c_) = 0
			This._Refuse("On: no instrument named '" + pInstrument + "' -- this engine has: " +
			             This._Joined(StzSoundInstruments()))
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

	# Shifts the pitch of every pitched note by a number of semitones.
	#
	#   pnSemitones   the shift in semitones, fractions allowed, 0.5 being a quarter tone
	#   returns       the score itself, so calls chain
	#   note          drum strokes keep their pitch, and the end of a glide moves too
	#   warning       a non-number is refused, with LastError set
	#   see           Note
	#@ aka  Semitones, fractional allowed (0.5 is a quarter tone). Strokes keep their pitch: a transposed drum pattern is the same drum pattern.
	def Transpose(pnSemitones)
		if NOT isNumber(pnSemitones)
			This._Refuse("Transpose: a number of semitones")
			return This
		ok
		_f_ = pow(2, pnSemitones / 12)
		_n_ = len(@aEvents)
		for _i_ = 1 to _n_
			if @aEvents[_i_][3] > 0  @aEvents[_i_][3] *= _f_ ok
			if len(@aEvents[_i_]) >= 7
				if @aEvents[_i_][7] > 0  @aEvents[_i_][7] *= _f_ ok    # a glide's end moves too
			ok
		next
		return This

	def TransposeQ(pnSemitones)
		return This.Transpose(pnSemitones)

	# Sets the velocity of the notes added from now on.
	#
	#   pnVelocity   the velocity above 0 and at most 1
	#   returns      the score itself, so calls chain
	#   note         notes already in the score keep their velocity
	#   warning      a value outside the range is refused, with LastError set
	#   see          Note, Stroke
	#@ aka  The velocity of notes ADDED FROM NOW ON, 0 < v <= 1.
	def SetVelocity(pnVelocity)
		if NOT isNumber(pnVelocity) or pnVelocity <= 0 or pnVelocity > 1
			This._Refuse("SetVelocity: a velocity is above 0 and at most 1")
			return This
		ok
		@nVelocity = pnVelocity
		return This

	def SetVelocityQ(pnVelocity)
		return This.SetVelocity(pnVelocity)

	# Sets the speed of the performance in beats per minute.
	#
	#   pnBpm      the speed in beats per minute, from 20 to 400
	#   returns    the score itself, so calls chain
	#   note       events stay in beats, so the same score can be rendered at two speeds
	#   warning    a value outside the range is refused, with LastError set
	#   see        TempoInBpm, Seconds
	#@ aka  -- the performance settings -------------------------------------------
	def Tempo(pnBpm)
		if NOT isNumber(pnBpm) or pnBpm < 20 or pnBpm > 400
			This._Refuse("Tempo: beats per minute, 20 to 400")
			return This
		ok
		@nTempo = pnBpm
		return This

	def TempoQ(pnBpm)
		return This.Tempo(pnBpm)

	# Snaps every start to the nearest multiple of a grid of beats when frames are computed.
	#
	#   pnGrid     the grid in beats, 0.25 being a sixteenth, or 0 for no grid
	#   returns    the score itself, so calls chain
	#   note       durations are left alone
	#   warning    a negative or non-numeric value is refused, with LastError set
	#   see        Swing, FrameOf
	#@ aka  Snap every start to the nearest multiple of `pnGrid` beats (0.25 = a sixteenth). 0 turns it off. Durations are left alone.
	def Quantize(pnGrid)
		if NOT isNumber(pnGrid) or pnGrid < 0
			This._Refuse("Quantize: a grid in beats, or 0 for none")
			return This
		ok
		@nQuantize = pnGrid
		return This

	def QuantizeQ(pnGrid)
		return This.Quantize(pnGrid)

	# Makes the first of each pair of eighth notes last a given share of the pair.
	#
	#   pnRatio    the share strictly between 0 and 1, 0.5 being straight and 2/3 a triplet swing
	#   returns    the score itself, so calls chain
	#   note       every position is warped, not only those on the grid
	#   warning    a value outside the range is refused, with LastError set
	#   see        SwingOn, SwingRatio
	#@ aka  SWING: the first of each PAIR of subdivisions lasts `pnRatio` of the pair. 0.5 is straight, 2/3 is a triplet swing, 0.75 a dotted one. Every position is warped, not only those on the grid -- the first half of each pair is stretched and the second compressed, piecewise-linearly -- so a note between two grid points moves with its neighbours instead of jumping past one.
	def Swing(pnRatio)
		return This.SwingOn(pnRatio, 0.5)

	# Makes the first of each pair of subdivisions last a given share of the pair, on a chosen subdivision.
	#
	#   pnRatio    the share strictly between 0 and 1, 0.5 being straight
	#   pnGrid     the length of one subdivision in beats, 0.5 for eighth notes
	#   returns    the score itself, so calls chain
	#   note       Swing is this call with a grid of 0.5
	#   warning    a bad ratio or a grid that is not positive is refused, with LastError set
	#   see        Swing, FrameOf
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

	# Returns the events in order of start beat, as a copy.
	#
	#   returns    a list of events, each [ startBeat, beats, hz, instrument, velocity, stroke,
	#              glideEndHz ]
	#   note       the instrument is an empty text until On or the performance default names one
	#   warning    changing the returned list changes nothing in the score; events that start
	#              together keep the order they were written in
	#   see        NumberOfEvents, PitchedEvents
	#@ aka  -- reading it ----------------------------------------------------------
	def Events()
		return This._Sorted(@aEvents)

	# Returns how many events the score holds.
	#
	#   returns    a number
	#   see        Events, Beats
	def NumberOfEvents()
		return len(@aEvents)

	# Returns the events that have a pitch, in order of start beat, leaving the drum strokes out.
	#
	#   returns    a list of events as Events gives them
	#   see        Events, Contour
	#@ aka  -- MU7: ANALYSE -- a score becomes data -------------------------------------
	def PitchedEvents()
		_a_ = []
		for _e_ in This.Events()
			if _e_[3] > 0  _a_ + _e_ ok
		next
		return _a_

	# Returns the distance from the lowest to the highest pitch in cents, 100 being a semitone.
	#
	#   returns    a number of cents; 0 when no note has a pitch
	#   see        PitchedEvents, Contour
	#@ aka  lowest to highest pitch, in cents
	def RangeInCents()
		_a_ = This.PitchedEvents()
		if len(_a_) = 0  return 0 ok
		_lo_ = _a_[1][3]
		_hi_ = _a_[1][3]
		for _e_ in _a_
			if _e_[3] < _lo_  _lo_ = _e_[3] ok
			if _e_[3] > _hi_  _hi_ = _e_[3] ok
		next
		return 1200 * log(_hi_ / _lo_) / log(2)

	# Returns how many pitched notes there are per beat of the score.
	#
	#   returns    a number; 0 for a score of no length
	#   see        PitchedEvents, Beats
	#@ aka  pitched notes per beat
	def Density()
		if @nBeats <= 0  return 0 ok
		return len(This.PitchedEvents()) / @nBeats

	# Returns a text of U, D or S for each step from one pitched note to the next, S meaning within 5 cents.
	#
	#   returns    a text of letters separated by spaces; an empty text for fewer than two pitched
	#              notes
	#   see        PitchedEvents, RangeInCents
	#@ aka  "U", "D" or "S" from each pitched note to the next -- S within 5 cents
	def Contour()
		_a_ = This.PitchedEvents()
		_s_ = ""
		for _k_ = 2 to len(_a_)
			_c_ = 1200 * log(_a_[_k_][3] / _a_[_k_ - 1][3]) / log(2)
			if _s_ != ""  _s_ += " " ok
			if _c_ > 5
				_s_ += "U"
			but _c_ < -5
				_s_ += "D"
			else
				_s_ += "S"
			ok
		next
		return _s_

	# Ranks the declared modes of every sound universe by how well their degrees fit the pitched notes, best first.
	#
	#   pnTop      how many rows to keep
	#   returns    a list of [ universe, mode, tonicHz, meanCentsOff ] rows, at most pnTop of them;
	#              [ ] when no note has a pitch
	#   note       it ranks the declarations, it does not say what the music is
	#   warning    a tie is reported as a tie, so several modes may show 0 cents off; each pitch is
	#              tried as the tonic
	#   see        StzSoundUniverses, Contour
	#@ aka  WHICH DECLARED MODE FITS: every mode of every universe, every note tried as its tonic, scored by how far (in cents) each note sits from the nearest degree of the mode, going up or coming down -- the mean. [ universe, mode, tonicHz, meanCentsOff ], best first. It ranks the DECLARATIONS; a tie is reported as a tie.
	def BestModes(pnTop)
		_aP_ = This.PitchedEvents()
		_aOut_ = []
		if len(_aP_) = 0  return _aOut_ ok
		_aT_ = []
		for _e_ in _aP_
			_seen_ = FALSE
			for _t_ in _aT_
				if fabs(1200 * log(_e_[3] / _t_) / log(2)) < 1  _seen_ = TRUE ok
			next
			if NOT _seen_  _aT_ + _e_[3] ok
		next
		for _u_ in StzSoundUniverses()
			_oU_ = StzSoundUniverseQ(_u_)
			for _m_ in _oU_._Get(_oU_.Declaration(), :modes, [])
				_aD_ = _oU_._Get(_m_, :degrees, [])
				if len(_aD_) = 0  loop ok
				# BOTH directions: a mode's descending form is the mode too. The
				# first cut read :degrees only, and a Rast melody that came down
				# through Rast's own flat seventh (as MU4 declares it must)
				# scored 3.4 cents off Rast -- its own notes counted as foreign.
				_aDesc_ = _oU_._Get(_m_, :descending, [])
				_aAll_ = []
				for _d_ in _aD_  _aAll_ + _d_ next
				for _d_ in _aDesc_
					if ring_find(_aAll_, _d_) = 0  _aAll_ + _d_ ok
				next
				_aD_ = _aAll_
				_oct_ = _oU_._Get(_m_, :octave, 1200)
				_best_ = 99999
				_bestT_ = 0
				for _t_ in _aT_
					_sum_ = 0
					for _e_ in _aP_
						_c_ = 1200 * log(_e_[3] / _t_) / log(2)
						_x_ = _c_ - _oct_ * floor(_c_ / _oct_)
						_md_ = 99999
						for _d_ in _aD_
							_df_ = fabs(_x_ - _d_)
							if _oct_ - _df_ < _df_  _df_ = _oct_ - _df_ ok
							if _df_ < _md_  _md_ = _df_ ok
						next
						_sum_ += _md_
					next
					if _sum_ / len(_aP_) < _best_
						_best_ = _sum_ / len(_aP_)
						_bestT_ = _t_
					ok
				next
				_aOut_ + [ _u_, _oU_._Get(_m_, :name, ""), _bestT_, _best_ ]
			next
		next
		# best first (insertion sort on the mean)
		for _i_ = 2 to len(_aOut_)
			_x_ = _aOut_[_i_]
			_j_ = _i_ - 1
			while _j_ >= 1
				if _aOut_[_j_][4] <= _x_[4]  exit ok
				_aOut_[_j_ + 1] = _aOut_[_j_]
				_j_--
			end
			_aOut_[_j_ + 1] = _x_
		next
		_r_ = []
		for _i_ = 1 to len(_aOut_)
			if _i_ > pnTop  exit ok
			_r_ + _aOut_[_i_]
		next
		return _r_

	# Returns the length of the score in beats, which is where an appended score would start.
	#
	#   returns    a number
	#   see        Seconds, SetLength
	def Beats()
		return @nBeats

	# Returns the speed set for the performance, in beats per minute.
	#
	#   returns    a number, 120 until set
	#   see        Tempo, Seconds
	def TempoInBpm()
		return @nTempo

	# Returns the swing share set for the performance.
	#
	#   returns    a number, 0.5 when straight
	#   see        Swing, SwingOn
	def SwingRatio()
		return @nSwing

	# Returns the length of the score in seconds at the current speed, without any note tail.
	#
	#   returns    a number of seconds
	#   warning    a rendered sound is longer than this by the tail of its last note
	#   see        Beats, SecondsOf
	def Seconds()
		return @nBeats * 60 / @nTempo

	# Returns the 0-based frame at which a beat falls, after the grid and the swing and at the current speed.
	#
	#   pnBeat     the beat to place
	#   pnRate     the sample rate in hertz
	#   returns    a number of frames
	#   warning    the offline render and the live scheduler both place notes with it, so they
	#              cannot disagree
	#   see        SecondsOf, Quantize
	#@ aka  WHERE A BEAT LANDS, in 0-based frames at `pnRate`: quantised, then swung, then timed. The one place beats become frames -- the offline render and the live scheduler both call it, so they cannot disagree about when a note is.
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

	# Returns how long a number of beats lasts at the current speed.
	#
	#   pnBeats    the number of beats
	#   returns    a number of seconds
	#   see        Seconds, FrameOf
	def SecondsOf(pnBeats)
		return pnBeats * 60 / @nTempo

	# Renders the whole performance offline into one stereo sound at 48000 Hz, held in memory.
	#
	#   returns    a stzSound; one frame long for an empty score
	#   note       the sound has not been heard by a person; it is checked by its frame count, rate
	#              and peak
	#   warning    no audio device is opened; a note an instrument refuses is missing from the sound
	#              and named in LastError
	#   see        StzSoundScoreRenderer, LastError
	#@ aka  -- performing it -------------------------------------------------------
	def ToSound()
		_oR_ = new stzSoundScoreRenderer(This)
		_o_ = _oR_.Offline()
		@cLastError = _oR_.LastError()
		_oR_.Release()
		return _o_

	def ToSoundQ()
		return This.ToSound()

	# Plays the score live through the scheduler and waits for the end.
	#
	#   returns    the score itself
	#   note       LastError holds what the scheduler reported
	#   warning    not run in this reference: it opens an audio device through stzSoundScheduler
	#   see        ToSound, StzSoundSchedulerQ
	def Play()
		_oP_ = StzSoundSchedulerQ(This)
		_oP_.Play()
		_oP_.RunToEnd()
		@cLastError = _oP_.LastError()
		_oP_.Release()
		return This

	# Returns the reason the last refused call gave, or an empty text.
	#
	#   returns    a text
	#   see        Refusals
	def LastError()
		return @cLastError

	# Returns how many calls the score has refused so far.
	#
	#   returns    a number
	#   warning    a refused call leaves the score unchanged
	#   see        LastError
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
		if isObject(po) and classname(po) = "stzsoundscore"  return TRUE ok
		This._Refuse(pcWho + ": needs a stzSoundScore")
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


# Renders the events of a score once each into sound buffers that the offline render and the live scheduler share.
#
# Every event is rendered by its instrument, and the same note (same instrument, pitch, length,
# velocity and stroke) is rendered only once however often it recurs, because a wind instrument
# tunes itself by listening and that is slow. Plan lists a start frame and a buffer id per event;
# Offline mixes the plan into one stereo sound at 48000 Hz. An instrument that refuses a note, such
# as a glide on a pluck, is counted in Refusals and the note is missing from the plan. Nothing here
# opens an audio device. The sound has not been heard by a person (UNPERCEIVED): it is checked by
# frame count, sample rate and peak level.
#
#   receiver   o1 = new stzSoundScoreRenderer(StzSoundScoreOfQ("c e c e"))
#   example    ? len(o1.Plan())
#              #--> 4
#              ? o1.NotesRendered()
#              #--> 2
#              ? o1.Offline().Frames()
#              #--> 115200
#   see        stzSoundScore, stzSoundScheduler, stzSound
class stzSoundScoreRenderer

	@oScore = NULL
	@nRate = 48000
	@nChannels = 2
	@nGain = 0.6            # per note, so a chord of a few does not clip
	@aKeys = []             # [ key, bufferId ]
	@aInst = []             # [ name, stzSoundInstrument ]
	@aPlan = []             # [ frame0, bufferId ] per event, in start order
	@nEndFrame = 0
	@cLastError = ""
	@nRefusals = 0
	@nRendered = 0          # distinct notes the instruments rendered
	@nSeconds = 0           # wall time spent rendering them

	# Builds a renderer over a score, to turn its events into sound buffers.
	#
	#   poScore    the stzSoundScore whose events are rendered
	#   returns    nothing; the object is built
	#   see        stzSoundScore, Plan
	def init(poScore)
		@oScore = poScore

	# Sets the factor applied to every note when it is mixed into the offline render.
	#
	#   pnGain     the gain per note, 0.6 by default so that a few notes in a chord do not clip
	#   returns    nothing
	#   see        Gain, Offline
	def SetGain(pnGain)
		@nGain = pnGain

	# Returns the factor applied to each note in the offline render.
	#
	#   returns    a number, 0.6 until set
	#   see        SetGain
	def Gain()
		return @nGain

	# Returns the sample rate of the render, in hertz.
	#
	#   returns    a number, 48000
	#   see        Channels, Offline
	def Rate()
		return @nRate

	# Returns the number of channels of the render.
	#
	#   returns    a number, 2
	#   see        Rate, Offline
	def Channels()
		return @nChannels

	# Returns the reason the last note was refused, or an empty text.
	#
	#   returns    a text
	#   see        Refusals
	def LastError()
		return @cLastError

	# Returns how many notes an instrument has refused to render.
	#
	#   returns    a number
	#   see        LastError, NotesRendered
	def Refusals()
		return @nRefusals

	# Returns how many distinct notes the instruments have rendered.
	#
	#   returns    a number; a note that recurs with the same instrument, pitch, length and velocity
	#              counts once
	#   warning    the count is not reset by Release, so rendering again adds to it
	#   see        Plan, SecondsRendering
	def NotesRendered()
		return @nRendered

	# Returns the wall time spent rendering the notes, in seconds.
	#
	#   returns    a number
	#   warning    measured on the processor clock
	#   see        NotesRendered
	def SecondsRendering()
		return @nSeconds

	# Returns the frame where the last note ends, in the sound of the render.
	#
	#   returns    a number of frames; 0 until Plan or Offline has run
	#   warning    it is the length of the rendered sound
	#   see        Plan, Offline
	def EndFrame()
		return @nEndFrame

	# Returns one row per event giving the frame it starts at and the buffer holding its note, rendering the notes on first use.
	#
	#   returns    a list of [ frame, bufferId ] rows in start order; [ ] for an empty score
	#   warning    an event whose instrument refused it has no row; equal notes share one buffer id
	#   see        Offline, NotesRendered
	#@ aka  [ frame0, bufferId ] per event, in start order; rendered on first ask.
	def Plan()
		if len(@aPlan) = 0 and @oScore.NumberOfEvents() > 0
			This._Build()
		ok
		return @aPlan

	# Mixes every planned note into one new silent stereo sound at the render's rate and returns it.
	#
	#   returns    a stzSound as long as the last note, and one frame long when nothing was rendered
	#   note       the sound has not been heard by a person
	#   warning    no audio device is opened; a failed mix sets LastError
	#   see        Plan, SetGain, Release
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

	# Frees the note buffers the renderer holds and forgets the plan.
	#
	#   returns    nothing
	#   warning    the sounds already returned by Offline are separate and stay valid; asking for
	#              the plan again renders the notes again
	#   see        Plan, Offline
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

	# MU3: one note's buffer, rendered once -- the live loops ask for notes
	# one at a time. [ start, beats, hz, instrument, velocity, stroke ]
	def BufferFor(paEvent)
		return This._BufferFor(paEvent)

	def _BufferFor(paEvent)
		_inst_ = paEvent[4]
		if _inst_ = ""  _inst_ = "piano" ok
		_hold_ = @oScore.SecondsOf(paEvent[2])
		_end_ = 0
		if len(paEvent) >= 7  _end_ = paEvent[7] ok
		_key_ = _inst_ + "|" + paEvent[3] + "|" + _hold_ + "|" + paEvent[5] + "|" + paEvent[6] + "|" + _end_
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
		but _end_ > 0 and _end_ != paEvent[3]
			# MU4: a glide -- the pitch moves over the whole note, in log
			# frequency. Refused by a pluck or an FM voice (MU1), and then the
			# refusal is counted like any other, never turned into a step.
			_oS_ = _oI_.ToSoundOfGlide(paEvent[3], _end_, _hold_)
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
		_o_ = StzSoundInstrumentQ(pcName)
		@aInst + [ pcName, _o_ ]
		return _o_
