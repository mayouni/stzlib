#---------------------------------------------------------------------------#
#  STZMUSIC -- the first line makes a sound (plan section 4, "dead simple")  #
#---------------------------------------------------------------------------#
#
#     StzMusicQ().Play("c e g c5")                  # four notes, a piano
#     StzMusicQ().Tempo(90).With(:Oud).Play("d e f g a")
#     StzMusicQ().With(:Kora).ToSound("a c5 e g").SaveAs("kora.wav")
#
# IT OWNS NO MECHANISM. Every verb here is one line over stzScore (the data),
# stzScoreRenderer (the instruments) and stzScheduler (the timing). The plan
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

class stzMusic

	@nTempo = 120
	@cInstrument = "piano"
	@nSwing = 0.5
	@cLastError = ""
	@nRefusals = 0
	@oLast = NULL           # the score the last Play or ToSound made
	@oLive = NULL           # MU3: the live session, made on first use

	def Tempo(pnBpm)
		if NOT isNumber(pnBpm) or pnBpm < 20 or pnBpm > 400
			@nRefusals++
			@cLastError = "Tempo: beats per minute, 20 to 400"
			return This
		ok
		@nTempo = pnBpm
		return This

	def With(pInstrument)
		_c_ = lower("" + pInstrument)
		if StzEngineSoundInstrumentIndex(_c_) = 0
			@nRefusals++
			@cLastError = "With: no instrument named '" + pInstrument + "'"
			return This
		ok
		@cInstrument = _c_
		return This

	def Swing(pnRatio)
		@nSwing = pnRatio
		return This

	# Plays, and returns when the last note has sounded.
	def Play(pcNotes)
		_oS_ = This.ScoreOf(pcNotes)
		if _oS_.NumberOfEvents() = 0  return This ok
		_oS_.Play()
		if _oS_.LastError() != ""  @cLastError = _oS_.LastError() ok
		return This

	def ToSound(pcNotes)
		return This.ScoreOf(pcNotes).ToSound()

	# The score a note string makes here -- so what Play would do can be
	# looked at, changed, and played later.
	def ScoreOf(pcNotes)
		_oS_ = StzScoreOfQ(pcNotes)
		_oS_.On(@cInstrument)
		_oS_.Tempo(@nTempo)
		if @nSwing != 0.5  _oS_.Swing(@nSwing) ok
		if _oS_.Refusals() > 0
			@nRefusals += _oS_.Refusals()
			@cLastError = _oS_.LastError()
		ok
		@oLast = _oS_
		return _oS_

	def LastScore()
		return @oLast

	#-- MU3: live loops ------------------------------------------------------
	#
	#     oM = StzMusicQ().Tempo(96)
	#     oM.LiveLoop(:iqa, "dum ~ tak ~ dum dum tak ~")   # the rhythm names itself
	#     oM.LiveLoopOn(:drone, "d2", :Oud)
	#     oM.WaitCycles(4)
	#     oM.Every(4, :iqa, :Rev)                          # lands on a boundary
	#     oM.WaitCycles(4)
	#     oM.StopLive()
	#
	# All of it is stzLive's; this is the one-line front over it.

	def LiveLoop(pName, pcPattern)
		This._EnsureLive()
		return @oLive.LiveLoop(pName, pcPattern)

	def LiveLoopOn(pName, pcPattern, pInstrument)
		This._EnsureLive()
		return @oLive.LiveLoopOn(pName, pcPattern, pInstrument)

	def Every(pnN, pName, pXform)
		This._EnsureLive()
		return @oLive.Every(pnN, pName, pXform)

	def Silence(pName)
		This._EnsureLive()
		return @oLive.Silence(pName)

	def Hush()
		This._EnsureLive()
		return @oLive.Hush()

	def WaitCycles(pnCycles)
		This._EnsureLive()
		@oLive.WaitCycles(pnCycles)
		return This

	def StopLive()
		if isObject(@oLive)
			@oLive.Release()
			@oLive = NULL
		ok
		return This

	# The live session, for reading its logs. Every verb above calls the
	# ATTRIBUTE directly rather than This.Live().Verb(): Ring copies an object
	# on assignment, and acting on a returned copy would change nothing.
	def Live()
		This._EnsureLive()
		return @oLive

	def _EnsureLive()
		if NOT isObject(@oLive)
			@oLive = StzLiveQ(@nTempo)
			@oLive.SetDefaultInstrument(@cInstrument)
		ok

	def LastError()
		return @cLastError

	def Refusals()
		return @nRefusals
