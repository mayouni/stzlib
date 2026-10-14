#---------------------------------------------------------------------------#
#  STZMUSIC -- the first line makes a sound (plan section 4, "dead simple")  #
#---------------------------------------------------------------------------#
#
#     StzMusicQ().Play("c e g c5")                  # four notes, a piano
#     StzMusicQ().Tempo(90).With(:Oud).Play("d e f g a")
#     StzMusicQ().With(:Kora).ToSound("a c5 e g").SaveAs("kora.wav")
#
# IT OWNS NO MECHANISM. Every verb here is one line over stzSoundScore (the data),
# stzSoundScoreRenderer (the instruments) and stzSoundScheduler (the timing). The plan
# (section 5) says so of this piece, and it is the reason the class is short:
# "fun" that owns machinery is machinery nobody can test on its own.
#
# THE PHASE GATE. Plan section 7: the one-line test in section 4 "runs at the
# close of every phase from MU1 on". It could not run at MU1's close -- there
# was no StzMusicQ -- and MU1's STATUS did not say so. MU2's guard runs it,
# and the STATUS records both.
#
# WHAT IT IS NOT, YET: the Loop / Every / In verbs of section 4 -- live loops
# are the pattern language (MU3) and a universe is declared data (MU4). The
# note string is a list of names, one beat each; its grammar grows in MU3.

func StzMusicQ()
	return new stzMusic

# Makes sound in one line from a string of note names, a phrase of degrees in a tradition, lyrics or live loops.
#
# It owns no mechanism: each verb is a line over stzSoundScore, stzSoundScoreRenderer,
# stzSoundScheduler, stzSoundUniverse and stzSoundLive. Tempo, With and Swing apply to the note-
# string verbs (Play, ToSound, ScoreOf); the phrase verbs take their speed and instrument from the
# chosen universe. Play, PlayPhrase and the live loops on a sound card open an audio device and were
# not run in this reference; ToSound, ScoreOf, PhraseToSound and Sing render to memory.
# Live().CaptureInsteadOfDevice(seconds, FALSE) keeps the live verbs off the sound card. The sound
# has not been heard by a person (UNPERCEIVED): it is checked by frame count, sample rate and peak
# level, not by listening.
#
#   receiver   o1 = StzMusicQ()
#   example    o1.Tempo(90).With(:Oud)
#              ? o1.ScoreOf("d e f g a").Beats()
#              #--> 5
#              ? o1.ToSound("d e f g a").SampleRate()
#              #--> 48000
#              ? o1.With(:kazoo).Refusals()
#              #--> 1
#   see        stzSoundScore, stzSoundUniverse, stzSoundLive
class stzMusic

	@nTempo = 120
	@cInstrument = "piano"
	@nSwing = 0.5
	@cLastError = ""
	@nRefusals = 0
	@oLast = NULL           # the score the last Play or ToSound made
	@oLive = NULL           # MU3: the live session, made on first use
	@oUniverse = NULL       # MU4: the universe In() chose

	# Sets the speed used by the next note strings, in beats per minute.
	#
	#   pnBpm      the speed in beats per minute, from 20 to 400
	#   returns    the music object itself, so calls chain
	#   note       it does not reach the phrase verbs, whose speed comes from the universe, and a
	#              live session made later takes it
	#   warning    a value outside the range is refused, with LastError set and the refusal counted
	#   see        With, Swing
	def Tempo(pnBpm)
		if NOT isNumber(pnBpm) or pnBpm < 20 or pnBpm > 400
			@nRefusals++
			@cLastError = "Tempo: beats per minute, 20 to 400"
			return This
		ok
		@nTempo = pnBpm
		return This

	# Chooses the instrument used by the next note strings.
	#
	#   pInstrument   the instrument name, such as Piano, Oud or Kora
	#   returns       the music object itself, so calls chain
	#   warning       an unknown instrument is refused, with LastError set and the refusal counted
	#   see           Tempo, ScoreOf
	def With(pInstrument)
		_c_ = lower("" + pInstrument)
		if StzEngineSoundInstrumentIndex(_c_) = 0
			@nRefusals++
			@cLastError = "With: no instrument named '" + pInstrument + "'"
			return This
		ok
		@cInstrument = _c_
		return This

	# Sets the swing share used by the next note strings.
	#
	#   pnRatio    the share of each pair of eighths taken by the first, 0.5 being straight
	#   returns    the music object itself, so calls chain
	#   warning    it is stored without a check, and a bad value is refused later when a score is
	#              made
	#   see        Tempo
	def Swing(pnRatio)
		@nSwing = pnRatio
		return This

	# Plays a string of note names live on the audio device, one beat each, and returns when the last note has sounded.
	#
	#   pcNotes    space-separated note names, with ~ for a rest, such as c e g c5
	#   returns    the music object itself, so calls chain
	#   note       LastError copies what the score reported
	#   warning    not run in this reference: it opens an audio device through the score; an empty
	#              score plays nothing
	#   see        ToSound, ScoreOf, PlayPhrase
	#@ aka  Plays, and returns when the last note has sounded.
	def Play(pcNotes)
		_oS_ = This.ScoreOf(pcNotes)
		if _oS_.NumberOfEvents() = 0  return This ok
		_oS_.Play()
		if _oS_.LastError() != ""  @cLastError = _oS_.LastError() ok
		return This

	# Renders a string of note names to a sound in memory, with the chosen instrument, speed and swing.
	#
	#   pcNotes    space-separated note names, with ~ for a rest, such as d e f g a
	#   returns    a stzSound at 48000 Hz, two channels
	#   note       the sound has not been heard by a person; it is checked by frame count, rate and
	#              peak
	#   warning    no audio device is opened; a word that is not a note is skipped, counted and
	#              named in LastError
	#   see        ScoreOf, Play
	def ToSound(pcNotes)
		return This.ScoreOf(pcNotes).ToSound()

	# Returns the score that a string of note names makes here, so it can be looked at, changed and played later.
	#
	#   pcNotes    space-separated note names, with ~ for a rest
	#   returns    a stzSoundScore with the chosen instrument, speed and swing set
	#   note       the same score is kept for LastScore
	#   warning    refusals of the score are added to this object's count
	#   see        LastScore, ToSound
	#@ aka  The score a note string makes here -- so what Play would do can be looked at, changed, and played later.
	def ScoreOf(pcNotes)
		_oS_ = StzSoundScoreOfQ(pcNotes)
		_oS_.On(@cInstrument)
		_oS_.Tempo(@nTempo)
		if @nSwing != 0.5  _oS_.Swing(@nSwing) ok
		if _oS_.Refusals() > 0
			@nRefusals += _oS_.Refusals()
			@cLastError = _oS_.LastError()
		ok
		@oLast = _oS_
		return _oS_

	# Returns the score that the last Play, ToSound or ScoreOf made.
	#
	#   returns    a stzSoundScore; an empty text before any
	#   see        ScoreOf
	def LastScore()
		return @oLast

	# Chooses a musical universe, mode and tonic for the phrase verbs.
	#
	#   pUniverse   the universe name, such as Maqam, Raga or Western
	#   pMode       the mode name, or an empty text for the universe's own
	#   pTonic      the tonic as a note name, where a bare letter takes octave 4, or an empty text
	#               for the mode's own
	#   returns     the music object itself, so calls chain
	#   note        phrases are written in degrees, so one phrase means something in every universe
	#   warning     an unknown universe or mode is refused, with LastError set, and the universe
	#               chosen before stays
	#   see         PlayPhrase, PhraseToSound, Universe
	#@ aka  -- MU4: a universe ------------------------------------------------------
	def In(pUniverse, pMode, pTonic)
		_o_ = StzSoundUniverseQ(pUniverse)
		if NOT _o_.IsUsable()
			@nRefusals++
			@cLastError = _o_.LastError()
			return This
		ok
		if "" + pMode != ""  _o_.Mode(pMode) ok
		_t_ = "" + pTonic
		if _t_ != ""
			if len(_t_) <= 2 and NOT isdigit(right(_t_, 1))  _t_ += "4" ok
			_o_.Tonic(_t_)
		ok
		if _o_.Refusals() > 0
			@nRefusals += _o_.Refusals()
			@cLastError = _o_.LastError()
			return This
		ok
		@oUniverse = _o_
		return This

	# Returns the universe chosen by In.
	#
	#   returns    a stzSoundUniverse; an empty text before In
	#   see        In
	def Universe()
		return @oUniverse

	# Renders a phrase of degrees in the chosen universe to a sound in memory, as many cycles as asked.
	#
	#   pcDegrees   the phrase in degrees, such as 1 2 3 4 5 4 3 2
	#   pnCycles    how many times the phrase is played through its rhythmic cycle
	#   returns     a stzSound at 48000 Hz; an empty text with LastError set when no universe was
	#               chosen
	#   note        the sound has not been heard by a person, and none of the shipped universes has
	#               been confirmed by a listener from its tradition
	#   warning     no audio device is opened; the speed and the instrument are the universe's own,
	#               not Tempo and With
	#   see         In, PlayPhrase
	def PhraseToSound(pcDegrees, pnCycles)
		if NOT isObject(@oUniverse)
			@nRefusals++
			@cLastError = "PhraseToSound: choose a universe first -- In(:Maqam, :Rast, :C)"
			return NULL
		ok
		_oS_ = @oUniverse.PerformQ(pcDegrees, pnCycles)
		if @oUniverse.LastError() != ""  @cLastError = @oUniverse.LastError() ok
		return _oS_.ToSound()

	# Plays a phrase of degrees live in the chosen universe for two cycles and returns when they have sounded.
	#
	#   pcDegrees   the phrase in degrees, such as 1 2 3 4 5 4 3 2
	#   returns     the music object itself, so calls chain
	#   warning     not run in this reference: it opens an audio device; with no universe chosen it
	#               is refused, with LastError set
	#   see         PhraseToSound, In
	#@ aka  Plays two cycles and returns when they have sounded.
	def PlayPhrase(pcDegrees)
		if NOT isObject(@oUniverse)
			@nRefusals++
			@cLastError = "PlayPhrase: choose a universe first -- In(:Maqam, :Rast, :C)"
			return This
		ok
		@oUniverse.PerformQ(pcDegrees, 2).Play()
		return This

	# Sings lyrics on notes with the retuned speech voice and returns the result as a sound.
	#
	#   pcLyrics   the syllables, space-separated, such as la la la
	#   pcNotes    the note names to sing them on, such as c4 e4 g4
	#   returns    a stzSound, mono at 48000 Hz; an empty text when the voice is not allowed to sing
	#              or cannot
	#   note       the sound has not been heard by a person
	#   warning    a refusal is counted and named in LastError; it renders to memory and plays
	#              nothing
	#   see        ToSound
	#@ aka  -- MU5: singing ---------------------------------------------------------
	def Sing(pcLyrics, pcNotes)
		# Whichever voice the author has called SINGING (StzSoundSingingVerdict):
		# today that is SAPI's own voice retuned by PSOLA, opened 2026-09-27. The
		# voice is made on the FIRST Sing, and may be made before or after the
		# audio device is opened: until 2026-09-30 it had to come first, or SAPI
		# found no voices (STZLIB-VOICE-COMODE-01, fixed in the engine's voice.zig).
		_oR_ = StzSoundRetunedVoiceQ()
		_o_ = _oR_.Sing(pcLyrics, pcNotes)
		if NOT isObject(_o_)
			@nRefusals++
			@cLastError = _oR_.LastError()
		ok
		return _o_

	# Defines or redefines a live loop from a pattern, creating the live session on first use.
	#
	#   pName       the loop's name
	#   pcPattern   a pattern of note names and strokes, such as dum ~ tak ~
	#   returns     the cycle the loop lands on, counted from 0; -1 when refused
	#   note        the session takes the speed and the instrument set when it is made
	#   warning     it forwards to stzSoundLive and the session plays on a sound card when waited
	#               on, unless capture was set on Live()
	#   see         LiveLoopOn, WaitCycles
	#@ aka  -- MU3: live loops ------------------------------------------------------
	def LiveLoop(pName, pcPattern)
		This._EnsureLive()
		return @oLive.LiveLoop(pName, pcPattern)

	# Defines or redefines a live loop on a chosen instrument, creating the live session on first use.
	#
	#   pName         the loop's name
	#   pcPattern     a pattern of note names and strokes
	#   pInstrument   the instrument name
	#   returns       the cycle the loop lands on, counted from 0; -1 when refused
	#   warning       forwards to stzSoundLive
	#   see           LiveLoop
	def LiveLoopOn(pName, pcPattern, pInstrument)
		This._EnsureLive()
		return @oLive.LiveLoopOn(pName, pcPattern, pInstrument)

	# Redefines a live loop as itself transformed every so many cycles.
	#
	#   pnN        the period of the transform in cycles
	#   pName      the name of an existing loop
	#   pXform     the transform to apply, such as Rev
	#   returns    the cycle the loop lands on; -1 when refused
	#   warning    forwards to stzSoundLive; an unknown loop is refused
	#   see        LiveLoop
	def Every(pnN, pName, pXform)
		This._EnsureLive()
		return @oLive.Every(pnN, pName, pXform)

	# Stops one live loop at the first cycle boundary it can land on.
	#
	#   pName      the name of the loop to stop
	#   returns    the cycle on which the loop falls silent; -1 for an unknown loop
	#   warning    forwards to stzSoundLive
	#   see        Hush
	def Silence(pName)
		This._EnsureLive()
		return @oLive.Silence(pName)

	# Stops every live loop at the first cycle boundary each can land on.
	#
	#   returns    the cycle of the last loop's landing; -1 when there are no loops
	#   warning    forwards to stzSoundLive
	#   see        Silence
	def Hush()
		This._EnsureLive()
		return @oLive.Hush()

	# Lets the live session run for a number of cycles, starting it first when needed.
	#
	#   pnCycles   how many cycles to wait
	#   returns    the music object itself, so calls chain
	#   note       a capture shorter than the wait never returns, see the defects file
	#   warning    it plays on a sound card, which was not run in this reference except with capture
	#              set on Live(), where it returned after 2 cycles
	#   see        StopLive, Live
	def WaitCycles(pnCycles)
		This._EnsureLive()
		@oLive.WaitCycles(pnCycles)
		return This

	# Stops and frees the live session, so the next live call makes a new one.
	#
	#   returns    the music object itself, so calls chain
	#   warning    does nothing when there is no session
	#   see        WaitCycles, Live
	def StopLive()
		if isObject(@oLive)
			@oLive.Release()
			@oLive = NULL
		ok
		return This

	# Returns the live session, creating it on first use, so its logs can be read and capture chosen.
	#
	#   returns    a stzSoundLive
	#   warning    changing the returned session changes the one held here, so
	#              Live().CaptureInsteadOfDevice(6, FALSE) keeps the music object off the sound card
	#   see        StzSoundLiveQ
	#@ aka  The live session, for reading its logs. Every verb above calls the ATTRIBUTE directly rather than This.Live().Verb(): Ring copies an object on assignment, and acting on a returned copy would change nothing.
	def Live()
		This._EnsureLive()
		return @oLive

	def _EnsureLive()
		if NOT isObject(@oLive)
			@oLive = StzSoundLiveQ(@nTempo)
			@oLive.SetDefaultInstrument(@cInstrument)
		ok

	# Returns the reason the last call was refused, or an empty text.
	#
	#   returns    a text
	#   see        Refusals
	def LastError()
		return @cLastError

	# Returns how many calls this object has refused, including those of the scores it made.
	#
	#   returns    a number
	#   see        LastError
	def Refusals()
		return @nRefusals
