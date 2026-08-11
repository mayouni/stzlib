#---------------------------------------------------------------------------#
#  STZSOUND -- a sound you can hold: load it, look at it, change it, hear it. #
#---------------------------------------------------------------------------#
#
#     oS = new stzSound("bell.wav")
#     ? oS.Duration()            ? oS.SampleRate()     ? oS.Channels()
#     oS.Play()                                        # blocks until it ends
#     oS.SaveAs("copy.wav")
#
#     # fluent -- every Q returns the SOUND, never a sub-object
#     oS.ResampleToQ(44100).ToMonoQ().SaveAs("small.wav")
#
#     # make one from nothing
#     oT = StzSoundOfSilenceQ(2, 2, 48000)             # 2 s, stereo, 48 kHz
#
# THE LAW THIS CLASS FOLLOWS (house naming, restated because every method
# here obeys it):
#   - a method is an explicit VERB acting on the sound: Play, SaveAs,
#     ResampleTo, ToMono -- never a bare noun;
#   - the plain form ACTS and returns nothing;
#   - the ...Q twin does the same act and returns THE SOUND, so a chain
#     never leaves the main object;
#   - readers (Duration, Peak, Rms) return DATA and keep their names;
#   - To...() returns DATA too -- ToList() hands you the samples.
#
# WHY ResampleTo AND ToMono MUTATE rather than return a new sound: the engine
# makes a new buffer either way, but a face that returned a second stzSound
# would leave the caller holding two and freeing neither. The face swaps its
# own buffer and frees the old one, so a chain cannot leak.
#
# PLAY() BLOCKS, and says so in its name's absence of "Start". A sample buffer
# is not a stream; to hear it the face builds a one-node graph and runs it to
# the end. If you want it in the background, that is a stzSoundGraph.
#
# INDICES ARE 1-BASED here, as in every Ring face; the engine is 0-based and
# the bridge translates.

func StzSoundQ(pcPath)
	return new stzSound(pcPath)

# Sound from a file -- the common case, named so the call site reads.
func StzSoundFromFileQ(pcPath)
	return new stzSound(pcPath)

# A silent sound to fill in yourself, or to render into.
func StzSoundOfSilenceQ(pnSeconds, pnChannels, pnRate)
	_o_ = new stzSound("")
	_o_.MakeSilence(pnSeconds, pnChannels, pnRate)
	return _o_

# Wrap a buffer the engine already owns (a graph render, a recording).
func StzSoundFromBufferQ(pnBufferId)
	_o_ = new stzSound("")
	_o_.AdoptBuffer(pnBufferId)
	return _o_

class stzSound

	@nBuf = 0            # the engine's sample-buffer id; 0 = nothing held
	@cLastError = ""

	def init(pcPath)
		if NOT StzSoundEngineLoaded()
			@cLastError = "stz_sound.dll is not loaded"
			return
		ok
		if isString(pcPath) and pcPath != ""
			@nBuf = StzEngineSoundLoadFile(pcPath)
			if @nBuf = 0
				@cLastError = StzEngineSoundLastError()
			ok
		ok

	#-- lifecycle ----------------------------------------------------------

	def MakeSilence(pnSeconds, pnChannels, pnRate)
		This.Release()
		@nBuf = StzEngineSoundNewSilent(floor(pnSeconds * pnRate), pnChannels, pnRate)
		if @nBuf = 0
			@cLastError = StzEngineSoundLastError()
		ok

	def MakeSilenceQ(pnSeconds, pnChannels, pnRate)
		This.MakeSilence(pnSeconds, pnChannels, pnRate)
		return This

	def AdoptBuffer(pnBufferId)
		This.Release()
		@nBuf = pnBufferId

	# Hand the engine id out -- for a graph that wants this sound as a source.
	# An ENGINE handle, not a pointer, so it obeys the house law.
	def BufferId()
		return @nBuf

	def Release()
		if @nBuf != 0
			StzEngineSoundFree(@nBuf)
			@nBuf = 0
		ok

	def IsEmpty()
		return @nBuf = 0 or StzEngineSoundFrames(@nBuf) <= 0

	def LastError()
		return @cLastError

	#-- readers: they return DATA and keep their names ---------------------

	def Frames()
		if @nBuf = 0  return 0 ok
		return StzEngineSoundFrames(@nBuf)

	def Channels()
		if @nBuf = 0  return 0 ok
		return StzEngineSoundChannels(@nBuf)

	def SampleRate()
		if @nBuf = 0  return 0 ok
		return StzEngineSoundRate(@nBuf)

	def Duration()
		if @nBuf = 0  return 0 ok
		return StzEngineSoundDuration(@nBuf)

	def Peak()
		if @nBuf = 0  return 0 ok
		return StzEngineSoundPeak(@nBuf)

	def Rms()
		if @nBuf = 0  return 0 ok
		return StzEngineSoundRms(@nBuf)

	# ONE sample. 1-based frame and channel, like every Ring face.
	def SampleAt(pnFrame, pnChannel)
		if @nBuf = 0  return 0 ok
		return StzEngineSoundGet(@nBuf, pnFrame, pnChannel)

	def SetSampleAt(pnFrame, pnChannel, pnValue)
		if @nBuf = 0  return ok
		StzEngineSoundSet(@nBuf, pnFrame, pnChannel, pnValue)

	def SetSampleAtQ(pnFrame, pnChannel, pnValue)
		This.SetSampleAt(pnFrame, pnChannel, pnValue)
		return This

	# The samples of one channel, as a Ring list. DATA, so To... is right.
	# Be aware this crosses the FFI once per sample -- fine for a look at a
	# few thousand frames, wrong for a whole song.
	def ToList(pnChannel)
		_a_ = []
		if @nBuf = 0  return _a_ ok
		_n_ = StzEngineSoundFrames(@nBuf)
		for _i_ = 1 to _n_
			_a_ + StzEngineSoundGet(@nBuf, _i_, pnChannel)
		next
		return _a_

	#-- verbs that change the sound ----------------------------------------

	# Resample to a new rate. QUALITY is sinc unless you ask otherwise --
	# SN1 measured sinc at 97x the accuracy of linear for 26x the cost, and
	# still 150x faster than real time, so it is the right default.
	def ResampleTo(pnRate)
		if @nBuf = 0  return ok
		_new_ = StzEngineSoundResample(@nBuf, pnRate, StzSoundQualitySinc())
		if _new_ = 0
			@cLastError = StzEngineSoundLastError()
			return
		ok
		StzEngineSoundFree(@nBuf)
		@nBuf = _new_

	def ResampleToQ(pnRate)
		This.ResampleTo(pnRate)
		return This

	def ResampleToFast(pnRate)
		if @nBuf = 0  return ok
		_new_ = StzEngineSoundResample(@nBuf, pnRate, StzSoundQualityLinear())
		if _new_ = 0
			@cLastError = StzEngineSoundLastError()
			return
		ok
		StzEngineSoundFree(@nBuf)
		@nBuf = _new_

	def ResampleToFastQ(pnRate)
		This.ResampleToFast(pnRate)
		return This

	def ChangeChannelsTo(pnChannels)
		if @nBuf = 0  return ok
		_new_ = StzEngineSoundToChannels(@nBuf, pnChannels)
		if _new_ = 0
			@cLastError = StzEngineSoundLastError()
			return
		ok
		StzEngineSoundFree(@nBuf)
		@nBuf = _new_

	def ChangeChannelsToQ(pnChannels)
		This.ChangeChannelsTo(pnChannels)
		return This

	def ToMono()
		This.ChangeChannelsTo(1)

	def ToMonoQ()
		This.ToMono()
		return This

	def ToStereo()
		This.ChangeChannelsTo(2)

	def ToStereoQ()
		This.ToStereo()
		return This

	#-- output --------------------------------------------------------------

	# 16-bit by default: it is what everything reads, and SN1 measured the
	# round-trip error at 4.18e-5, one quantum. Ask for 32 when you are
	# handing the file back to another stage rather than to a listener.
	def SaveAs(pcPath)
		if @nBuf = 0  return ok
		if StzEngineSoundSaveWav(@nBuf, pcPath, 16) != 0
			@cLastError = StzEngineSoundLastError()
		ok

	def SaveAsQ(pcPath)
		This.SaveAs(pcPath)
		return This

	def SaveAsFloat(pcPath)
		if @nBuf = 0  return ok
		if StzEngineSoundSaveWav(@nBuf, pcPath, 32) != 0
			@cLastError = StzEngineSoundLastError()
		ok

	def SaveAsFloatQ(pcPath)
		This.SaveAsFloat(pcPath)
		return This

	#-- hearing it ----------------------------------------------------------

	# PLAY IT, and wait for it to finish. There is no sample-player in the
	# engine -- the device sink plays a STREAM -- so the face builds the
	# smallest graph that can carry this sound and runs it. That is what a
	# declarative face is for: the caller says "play", not "make a graph,
	# start a producer thread, open a device, wait, then take it all down".
	def Play()
		This.PlayFor(This.Duration() + 0.25)

	def PlayForQ(pnSeconds)
		This.PlayFor(pnSeconds)
		return This

	def PlayFor(pnSeconds)
		if @nBuf = 0  return ok
		if NOT StzAudioDevEngineLoaded()
			@cLastError = "no audio device tier on this machine"
			return
		ok
		if StzEngineAudioDevIsAvailable() = 0
			@cLastError = "no audio device on this machine"
			return
		ok
		_nCh_ = StzEngineSoundChannels(@nBuf)
		_g_ = StzEngineSoundGraphNew(_nCh_, StzEngineSoundRate(@nBuf), 512)
		_n_ = StzEngineSoundGraphAddSource(_g_, @nBuf, 0)
		StzEngineSoundGraphSetOutput(_g_, _n_)
		if StzEngineSoundGraphPrepare(_g_) != 0
			@cLastError = StzEngineSoundGraphLastError()
			StzEngineSoundGraphFree(_g_)
			return
		ok
		_s_ = StzEngineSoundStreamStart(_g_, 16384)
		sleep(0.12)
		_d_ = StzEngineAudioDevPlaybackOpen(StzEngineSoundStreamRingPtr(_s_), 256)
		if _d_ = 0
			@cLastError = StzEngineAudioDevLastError()
			StzEngineSoundStreamStop(_s_)
			StzEngineSoundGraphFree(_g_)
			return
		ok
		StzEngineAudioDevPlaybackStart(_d_)
		sleep(pnSeconds)
		StzEngineAudioDevPlaybackStop(_d_)
		StzEngineAudioDevPlaybackClose(_d_)     # consumer first, ALWAYS
		StzEngineSoundStreamStop(_s_)           # then the producer frees the ring
		StzEngineSoundGraphFree(_g_)
