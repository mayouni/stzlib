#---------------------------------------------------------------------------#
#  STZINSTRUMENT -- one note of any of twenty instruments, as a stzSound.    #
#  MU1 of SOFTANZA_MUSIC_PLAN.md.                                            #
#---------------------------------------------------------------------------#
#
#     oOud = StzInstrumentQ(:Oud)
#     oNote = oOud.ToSoundOfNote("D4", 1.0)          # a stzSound, in tune to the cent
#     oOud.ToSoundOf(293.66, 1.0)                    # the same note, in Hz
#     oOud.ToSoundOfNote("E4-50", 1.0)               # a quarter tone below E4
#
#     StzInstrumentQ(:Kalangu).ToSoundOfGlide(150, 220, 0.8)     # a drum whose pitch moves
#     StzInstrumentQ(:Darbouka).ToSoundOfStroke(:Tak, 180, 0.5)  # centre or rim
#
#     StzInstruments()                               # the twenty, by name
#
# ── WHAT A NOTE IS HERE ────────────────────────────────────────────────────
#
# A note is DATA: a stzSound, rendered offline by the engine's seam
# (soundinstr.zig) -- the same arithmetic the browser tier compiles -- so every
# verb the sound plane owns applies to it: loudness, onsets, filters, the graph,
# a WAV. Nothing here plays anything. Scheduling notes against a clock is MU2.
#
# ── THE INSTRUMENTS TUNE THEMSELVES ────────────────────────────────────────
#
# A waveguide's pitch is not its delay length, so every string, bow and wind
# instrument plays a probe, MEASURES the pitch it made, and corrects -- up to
# eight passes, stepping by what it measured, and using only a correction it
# actually heard. RawCents() says how far the untuned model was off (the kakaki's
# lip model: 2.5 semitones flat); TuningCents() says what the tuner applied.
# FM and membrane instruments are in tune by construction and report 0 for both.
#
# ── THE NAMES ARE PROVISIONAL, AND THE FALLBACKS ARE DECIDED IN ADVANCE ────
#
# MU1's kill criterion: an instrument that does not sound like its name to the
# author ships under a name that does not lie. HonestName() is that name,
# written into the engine's table BEFORE anyone listened -- :Oud falls back to
# :DarkPluck, :Piano to :HammeredString -- so the fallback is a decision already
# made, not a negotiation after a disappointing listen.

func StzInstrumentQ(pName)
	return new stzInstrument(pName)

# The twenty, in the plan's order.
func StzInstruments()
	_a_ = []
	if NOT StzSoundEngineLoaded()  return _a_ ok
	for _i_ = 1 to StzEngineSoundInstrumentCount()
		_a_ + StzEngineSoundInstrumentName(_i_)
	next
	return _a_

# A note name to Hz: twelve-tone equal temperament from A4 = 440, with an
# optional cents offset -- "A4", "C#3", "Bb2", "D4+50" (a quarter tone up),
# "E4-50" (a quarter tone down). Returns 0 for anything it cannot read, never
# a guess: a misspelt note that silently became some other pitch would be worse
# than a refusal.
func StzNoteToHz(pcNote)
	_c_ = trim("" + pcNote)
	if len(_c_) < 2  return 0 ok
	_n_ = 0
	switch upper(_c_[1])
	on "C"  _n_ = -9
	on "D"  _n_ = -7
	on "E"  _n_ = -5
	on "F"  _n_ = -4
	on "G"  _n_ = -2
	on "A"  _n_ = 0
	on "B"  _n_ = 2
	other
		return 0
	off
	_i_ = 2
	if _c_[_i_] = "#"
		_n_++
		_i_++
	but _c_[_i_] = "b"
		_n_--
		_i_++
	ok
	_oct_ = ""
	while _i_ <= len(_c_) and isdigit(_c_[_i_])
		_oct_ += _c_[_i_]
		_i_++
	end
	if _oct_ = ""  return 0 ok
	_cents_ = 0
	if _i_ <= len(_c_)
		_sign_ = _c_[_i_]
		if _sign_ != "+" and _sign_ != "-"  return 0 ok
		_digits_ = ""
		_i_++
		while _i_ <= len(_c_) and isdigit(_c_[_i_])
			_digits_ += _c_[_i_]
			_i_++
		end
		if _digits_ = "" or _i_ <= len(_c_)  return 0 ok
		_cents_ = 0 + _digits_
		if _sign_ = "-"  _cents_ = -_cents_ ok
	ok
	_semis_ = _n_ + 12 * ((0 + _oct_) - 4) + _cents_ / 100
	return 440 * pow(2, _semis_ / 12)

class stzInstrument

	@nId = 0
	@cName = ""
	@nVelocity = 0.8
	@nRate = 48000
	@cLastError = ""
	@nRefusals = 0
	@nRawCents = 0
	@nTuningCents = 0

	def init(pName)
		if NOT StzSoundEngineLoaded()
			@cLastError = "stz_sound.dll is not loaded"
			return
		ok
		_i_ = StzEngineSoundInstrumentIndex(lower("" + pName))
		if _i_ = 0
			@nRefusals++
			@cLastError = "no instrument named '" + pName + "' -- this engine has: " +
			              This._Joined(StzInstruments())
			return
		ok
		@nId = _i_
		@cName = StzEngineSoundInstrumentName(_i_)

	#-- what it is --------------------------------------------------------

	def IsUsable()
		return @nId > 0

	def Name()
		return @cName

	# The name it ships under if the author's ear says the real one lies.
	def HonestName()
		if @nId = 0  return "" ok
		return StzEngineSoundInstrumentHonestName(@nId)

	def Engine()
		if @nId = 0  return "" ok
		switch StzEngineSoundInstrumentEngine(@nId)
		on 0  return "pluck"
		on 1  return "bow"
		on 2  return "wind"
		on 3  return "fm"
		on 4  return "membrane"
		off
		return ""

	# harmonic: held to 2 cents. inharmonic: a bar, a bell or a drum, whose
	# partials are not multiples -- its lowest mode is checked, its perceived
	# pitch is the listener's. none: a hi-hat or a snare.
	def PitchClass()
		if @nId = 0  return "" ok
		switch StzEngineSoundInstrumentPitchClass(@nId)
		on 0  return "harmonic"
		on 1  return "inharmonic"
		on 2  return "none"
		off
		return ""

	def Range()
		if @nId = 0  return [] ok
		return [ StzEngineSoundInstrumentLow(@nId), StzEngineSoundInstrumentHigh(@nId) ]

	def Velocity()
		return @nVelocity

	def SetVelocity(pnVelocity)
		if NOT isNumber(pnVelocity) or pnVelocity <= 0 or pnVelocity > 1
			@nRefusals++
			@cLastError = "SetVelocity: a velocity is above 0 and at most 1"
			return
		ok
		@nVelocity = pnVelocity

	def SetVelocityQ(pnVelocity)
		This.SetVelocity(pnVelocity)
		return This

	#-- a note, as data ----------------------------------------------------

	def ToSoundOf(pnHz, pnSeconds)
		return This._Note(pnHz, pnHz, pnSeconds, 0)

	def ToSoundOfNote(pcNote, pnSeconds)
		_hz_ = StzNoteToHz(pcNote)
		if _hz_ = 0
			@nRefusals++
			@cLastError = "ToSoundOfNote: '" + pcNote + "' is not a note name " +
			              "(A4, C#3, Bb2, D4+50)"
			return ""
		ok
		return This._Note(_hz_, _hz_, pnSeconds, 0)

	# A pitch that MOVES while it sounds -- a talking drum squeezed, a bow
	# sliding. Strings plucked and FM voices hold one pitch and refuse this.
	def ToSoundOfGlide(pnFromHz, pnToHz, pnSeconds)
		return This._Note(pnFromHz, pnToHz, pnSeconds, 0)

	# Where a drum is struck. Hand drums: :Dum (centre), :Tak (rim), :Ka (the
	# weaker rim). The kit: :Kick, :Snare, :HiHat.
	def ToSoundOfStroke(pStroke, pnHz, pnSeconds)
		if This.Engine() != "membrane"
			@nRefusals++
			@cLastError = "ToSoundOfStroke: " + @cName + " is not struck -- it has no strokes"
			return ""
		ok
		_v_ = -1
		switch lower("" + pStroke)
		on "dum"    _v_ = 0
		on "tak"    _v_ = 1
		on "ka"     _v_ = 2
		on "kick"   _v_ = 0
		on "snare"  _v_ = 1
		on "hihat"  _v_ = 2
		on "hat"    _v_ = 2
		off
		if _v_ < 0
			@nRefusals++
			@cLastError = "ToSoundOfStroke: '" + pStroke + "' is not a stroke " +
			              "(dum, tak, ka -- or kick, snare, hihat on the kit)"
			return ""
		ok
		return This._Note(pnHz, pnHz, pnSeconds, _v_)

	#-- what the last note needed ------------------------------------------

	def RawCents()
		return @nRawCents

	def TuningCents()
		return @nTuningCents

	def LastError()
		return @cLastError

	def Refusals()
		return @nRefusals

	#-- private ------------------------------------------------------------

	def _Note(pnHz, pnHzEnd, pnSeconds, pnVariant)
		if @nId = 0
			@nRefusals++
			@cLastError = "this instrument is not usable: " + @cLastError
			return ""
		ok
		_b_ = StzEngineSoundNoteOf(@nId, pnHz, pnHzEnd, pnSeconds, @nVelocity,
		                           pnVariant, @nRate)
		if _b_ = 0
			@nRefusals++
			@cLastError = StzEngineSoundLastError()
			return ""
		ok
		@nRawCents = StzEngineSoundNoteRawCents()
		@nTuningCents = StzEngineSoundNoteTuningCents()
		@cLastError = ""
		return StzSoundFromBufferQ(_b_)

	def _Joined(paList)
		_s_ = ""
		for _i_ = 1 to len(paList)
			if _i_ > 1  _s_ += ", " ok
			_s_ += "" + paList[_i_]
		next
		return _s_
