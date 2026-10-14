#---------------------------------------------------------------------------#
#  STZINSTRUMENT -- one note of any of twenty instruments, as a stzSound.    #
#  MU1 of SOFTANZA_MUSIC_PLAN.md.                                            #
#---------------------------------------------------------------------------#
#
#     oOud = StzSoundInstrumentQ(:Oud)
#     oNote = oOud.ToSoundOfNote("D4", 1.0)          # a stzSound, in tune to the cent
#     oOud.ToSoundOf(293.66, 1.0)                    # the same note, in Hz
#     oOud.ToSoundOfNote("E4-50", 1.0)               # a quarter tone below E4
#
#     StzSoundInstrumentQ(:Kalangu).ToSoundOfGlide(150, 220, 0.8)     # a drum whose pitch moves
#     StzSoundInstrumentQ(:Darbouka).ToSoundOfStroke(:Tak, 180, 0.5)  # centre or rim
#
#     StzSoundInstruments()                               # the twenty, by name
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

func StzSoundInstrumentQ(pName)
	return new stzSoundInstrument(pName)

# The twenty, in the plan's order.
func StzSoundInstruments()
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

# Renders one note of any of twenty instruments as a stzSound, in tune to the cent, from a note name, a frequency, a glide or a stroke.
#
# A note is data: a stzSound rendered offline by the engine, so every verb of the sound plane
# applies to it, loudness, onsets, filters, a WAV. Nothing here plays. Strings, bows and winds tune
# themselves: each plays a probe, measures the pitch it made and corrects, and RawCents and
# TuningCents report what that took. FM and membrane instruments are in tune by construction. Each
# instrument has an honest fallback name decided before anyone listened. Strokes belong to
# membranes, hand drums and the drum kit, and a plucked or FM voice cannot glide. An unknown
# instrument does not raise: it is not usable and LastError lists the twenty. Rendered notes are
# checked by frame count, sample rate, peak and measured pitch and have not been heard by a person
# (UNPERCEIVED).
#
#   receiver   o1 = StzSoundInstrumentQ(:Oud) oNote = o1.ToSoundOfNote("D4", 1.0)
#   example    ? o1.IsUsable()
#              #--> 1
#              ? o1.HonestName()
#              #--> darkpluck
#              ? o1.Engine()
#              #--> pluck
#              ? @@( o1.Range() )
#              #--> [ 70, 700 ]
#              ? oNote.SampleRate()
#              #--> 48000
#              ? oNote.Frames()
#              #--> 60000
#              ? abs(StzEngineSoundPitchOf(oNote.BufferId(), 12001, 4096, 50, 2000) - 293.66) < 1
#              #--> 1
#              oBad = o1.ToSoundOfStroke("tak", 180, 0.5)
#              ? o1.LastError()
#              #--> ToSoundOfStroke: oud is not struck -- it has no strokes
#              ? StzSoundInstrumentQ("kazoo").IsUsable()
#              #--> 0
#   see        stzSound, stzSoundScore, stzSoundLadder
class stzSoundInstrument

	@nId = 0
	@cName = ""
	@nVelocity = 0.8
	@nRate = 48000
	@cLastError = ""
	@nRefusals = 0
	@nRawCents = 0
	@nTuningCents = 0

	# Looks one of the twenty instruments up by name and makes it ready to render notes.
	#
	#   pName      the instrument name in any letter case, such as :Oud, one of piano, guitar, harp,
	#              bell, epiano, brass, flute, oud, koto, kora, metallophone, drumkit, mezwed,
	#              zokra, darbouka, bendir, kakaki, sarewa, imzad or kalangu
	#   returns    nothing; the instrument is usable only if the name was found and the sound engine
	#              is loaded
	#   note       StzSoundInstrumentQ builds the same object
	#   warning    an unknown name does not raise: the instrument is not usable, a refusal is
	#              counted and LastError lists the twenty names
	#   see        IsUsable, ToSoundOfNote
	def init(pName)
		if NOT StzSoundEngineLoaded()
			@cLastError = "stz_sound.dll is not loaded"
			return
		ok
		_i_ = StzEngineSoundInstrumentIndex(lower("" + pName))
		if _i_ = 0
			@nRefusals++
			@cLastError = "no instrument named '" + pName + "' -- this engine has: " +
			              This._Joined(StzSoundInstruments())
			return
		ok
		@nId = _i_
		@cName = StzEngineSoundInstrumentName(_i_)

	# TRUE if the instrument was found and can render.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        init, LastError
	#@ aka  -- what it is --------------------------------------------------------
	def IsUsable()
		return @nId > 0

	# Returns the instrument name as the engine spells it.
	#
	#   returns    the name as text in lower case, such as oud; an empty text when it is not usable
	#   see        HonestName
	def Name()
		return @cName

	# Returns the name the instrument ships under if the ear says the real one is a lie.
	#
	#   returns    the fallback name as text, such as darkpluck for the oud, talkingdrum for the
	#              kalangu or fmbell for the bell; an empty text when not usable
	#   note       decided in the engine table before anyone listened
	#   see        Name
	#@ aka  The name it ships under if the author's ear says the real one lies.
	def HonestName()
		if @nId = 0  return "" ok
		return StzEngineSoundInstrumentHonestName(@nId)

	# Returns how the instrument makes its sound.
	#
	#   returns    pluck, bow, wind, fm or membrane, as text; an empty text when not usable
	#   note       the oud is a pluck and the kalangu and the drum kit are membranes
	#   see        PitchClass
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

	# Returns how well the instrument has a pitch.
	#
	#   returns    harmonic, inharmonic or none, as text; an empty text when not usable
	#   note       harmonic is held to 2 cents, inharmonic is a bar, a bell or a drum whose partials
	#              are not multiples, and none is a hi-hat or a snare; the oud is harmonic, the
	#              kalangu and the bell inharmonic, the drum kit none
	#   see        Engine, Range
	#@ aka  harmonic: held to 2 cents. inharmonic: a bar, a bell or a drum, whose partials are not multiples -- its lowest mode is checked, its perceived pitch is the listener's. none: a hi-hat or a snare.
	def PitchClass()
		if @nId = 0  return "" ok
		switch StzEngineSoundInstrumentPitchClass(@nId)
		on 0  return "harmonic"
		on 1  return "inharmonic"
		on 2  return "none"
		off
		return ""

	# Returns the lowest and highest frequency the instrument plays, in hertz.
	#
	#   returns    a list of two numbers; [ ] when not usable
	#   note       the oud plays 70 to 700 hertz and the kalangu 70 to 400
	#   see        PitchClass
	def Range()
		if @nId = 0  return [] ok
		return [ StzEngineSoundInstrumentLow(@nId), StzEngineSoundInstrumentHigh(@nId) ]

	# Returns the strength the notes are struck with.
	#
	#   returns    a number above 0 and at most 1, 0.8 by default
	#   see        SetVelocity
	def Velocity()
		return @nVelocity

	# Sets the strength the notes are struck with.
	#
	#   pnVelocity   the strength, above 0 and at most 1
	#   returns      nothing; the velocity is stored. SetVelocityQ returns the instrument for
	#                chaining
	#   note         the next notes use it
	#   warning      a value of 0 or less, above 1, or not a number counts a refusal, sets LastError
	#                to SetVelocity: a velocity is above 0 and at most 1 and leaves the old value
	#   see          Velocity
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

	# Renders one note at a frequency as a mono sound at 48000 hertz.
	#
	#   pnHz        the frequency in hertz
	#   pnSeconds   how long the note is written for, in seconds
	#   returns     a stzSound; an empty text when the instrument is not usable or the engine
	#               refused
	#   note        the note may ring past its written length: an oud of 0.5 s gave 36000 frames,
	#               0.75 s; the engine tunes each plucked, bowed and wind model by measuring a probe
	#   warning     an unusable instrument gives an empty text and LastError says so
	#   see         ToSoundOfNote, ToSoundOfGlide
	#@ aka  -- a note, as data ----------------------------------------------------
	def ToSoundOf(pnHz, pnSeconds)
		return This._Note(pnHz, pnHz, pnSeconds, 0)

	# Renders one note, given by name, as a mono sound at 48000 hertz.
	#
	#   pcNote      a note name such as A4, C#3, Bb2, D4+50 for a quarter tone above or E4-50 for
	#               one below
	#   pnSeconds   how long the note is written for, in seconds
	#   returns     a stzSound; an empty text when the name is not a note or the instrument cannot
	#               render
	#   note        an oud D4 of 1 s gave 60000 frames, 1.25 s, a peak of 0.56 and a pitch read back
	#               as 293.67 hertz, against 293.66; E4-50 read back as 320.26, against 320.24
	#   warning     a name that is not a note, such as H9, gives an empty text and the error
	#               ToSoundOfNote: ... is not a note name
	#   see         ToSoundOf, StzNoteToHz
	def ToSoundOfNote(pcNote, pnSeconds)
		_hz_ = StzNoteToHz(pcNote)
		if _hz_ = 0
			@nRefusals++
			@cLastError = "ToSoundOfNote: '" + pcNote + "' is not a note name " +
			              "(A4, C#3, Bb2, D4+50)"
			return ""
		ok
		return This._Note(_hz_, _hz_, pnSeconds, 0)

	# Renders one note whose pitch moves from one frequency to another while it sounds.
	#
	#   pnFromHz    the frequency it starts on
	#   pnToHz      the frequency it ends on
	#   pnSeconds   how long the glide lasts, in seconds
	#   returns     a stzSound; an empty text when the instrument cannot glide, with the reason in
	#               LastError
	#   note        a kalangu glide of 0.8 s gave exactly 38400 frames
	#   warning     a pluck and an FM voice hold one pitch and refuse: an oud gave an empty text and
	#               the error this instrument cannot glide
	#   see         ToSoundOf
	#@ aka  A pitch that MOVES while it sounds -- a talking drum squeezed, a bow sliding. Strings plucked and FM voices hold one pitch and refuse this.
	def ToSoundOfGlide(pnFromHz, pnToHz, pnSeconds)
		return This._Note(pnFromHz, pnToHz, pnSeconds, 0)

	# Renders one stroke of a drum, where it is struck, as a sound.
	#
	#   pStroke     dum, tak or ka on a hand drum, or kick, snare, hihat, openhat, crash, ride,
	#               hightom, midtom or floortom on the kit, as a symbol or text
	#   pnHz        the pitch of the drum in hertz
	#   pnSeconds   how long it is written for, in seconds
	#   returns     a stzSound; an empty text when the instrument is not struck, the stroke is
	#               unknown or this drum has not got it
	#   note        cymbals ring past the length written: a crash is at least 2 seconds, a ride at
	#               least 1.2 and an open hi-hat at least 0.6, which the drum kit gave exactly as
	#               96000, 57600 and 28800 frames
	#   warning     an instrument that is not a membrane, such as the oud, gives the error ... is
	#               not struck; an unknown stroke such as boom gives the error ... is not a stroke;
	#               a stroke the instrument does not have, such as crash on a darbouka, gives the
	#               error that stroke is not one this instrument has
	#   see         ToSoundOfGlide, Engine
	#@ aka  Where a drum is struck. Hand drums: :Dum (centre), :Tak (rim), :Ka (the weaker rim). The kit: :Kick, :Snare, :HiHat -- and (MU13) its cymbals, :Crash and :Ride, which ring PAST the length written for them, as cymbals do: a crash at least two seconds, a ride at least one and a fifth -- and (MU14) the toms, :HighTom :MidTom :FloorTom, and :OpenHat, which washes at least six tenths of a second.
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
		on "crash"  _v_ = 3
		on "ride"   _v_ = 4
		on "hightom"   _v_ = 5     # MU14: the toms, high, mid and floor
		on "midtom"    _v_ = 6
		on "floortom"  _v_ = 7
		on "openhat"   _v_ = 8     # and the hi-hat left open
		off
		if _v_ < 0
			@nRefusals++
			@cLastError = "ToSoundOfStroke: '" + pStroke + "' is not a stroke " +
			              "(dum, tak, ka -- or kick, snare, hihat, openhat, crash, ride, hightom, midtom, floortom on the kit)"
			return ""
		ok
		_s_ = pnSeconds
		if _v_ = 3 and _s_ < 2.0  _s_ = 2.0 ok
		if _v_ = 4 and _s_ < 1.2  _s_ = 1.2 ok
		if _v_ = 8 and _s_ < 0.6  _s_ = 0.6 ok      # an open hi-hat washes until it is closed
		return This._Note(pnHz, pnHz, _s_, _v_)

	# Returns how far off pitch the untuned model of the last note was, in cents.
	#
	#   returns    a number; 0 for an FM or membrane instrument, which is in tune by construction
	#   note       measured by the engine from a probe
	#   see        TuningCents
	#@ aka  -- what the last note needed ------------------------------------------
	def RawCents()
		return @nRawCents

	# Returns the correction the tuner applied to the last note, in cents.
	#
	#   returns    a number; 0 when none was needed
	#   note       the oud D4 needed none
	#   see        RawCents
	def TuningCents()
		return @nTuningCents

	# Returns the reason of the last refusal.
	#
	#   returns    the reason as text; an empty text when the last call went well
	#   see        Refusals
	def LastError()
		return @cLastError

	# Returns how many calls were refused.
	#
	#   returns    a number
	#   note       it counts an unknown instrument, a bad velocity, a bad note and a refused stroke
	#              or glide
	#   see        LastError
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
