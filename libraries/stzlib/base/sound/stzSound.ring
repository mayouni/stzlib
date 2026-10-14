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

# Holds a buffer of audio samples that you can load, inspect, change, analyse and save as a WAV file.
#
# The buffer lives in the sound engine and carries its own sample rate and channel count, so a saved
# file and a reloaded file keep the rate they were made at. The plain form of a verb acts and
# returns nothing; the Q twin does the same and returns the sound, so a chain never leaves it.
# Readers such as Duration, Peak and Rms return data, and the To... analysis methods return
# stzSoundGrid objects of numbers, never pictures. Play and PlayFor open an audio device and block
# until the sound ends; they are the only methods here that do. The sound has not been heard by a
# person (UNPERCEIVED): the examples are checked by frame count, sample rate, peak level and
# duration, not by listening.
#
#   receiver   o1 = StzSoundOfSilenceQ(0.5, 2, 48000)
#   example    ? o1.Frames()
#              #--> 24000
#              ? o1.SampleRate()
#              #--> 48000
#              ? o1.Duration()
#              #--> 0.50
#              o1.SetSampleAt(10, 1, 0.5)
#              ? o1.Peak()
#              #--> 0.50
#   see        stzSoundScore, stzSoundGraph, stzSoundGrid
class stzSound

	@nBuf = 0            # the engine's sample-buffer id; 0 = nothing held
	@cLastError = ""

	# Loads a sound from an audio file, or builds an empty sound that holds nothing when the path is empty.
	#
	#   pcPath     the file to decode, or an empty text for an empty sound
	#   returns    nothing; the object is built
	#   note       the sample rate and channel count are those of the file
	#   warning    a missing or undecodable file leaves the sound empty and sets LastError instead
	#              of raising; a library without the sound engine does the same
	#   see        MakeSilence, StzSoundQ
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

	# Replaces whatever the sound holds with a buffer of silence of the given length, channels and rate.
	#
	#   pnSeconds    the length in seconds, rounded down to whole frames
	#   pnChannels   the number of channels, 1 for mono and 2 for stereo
	#   pnRate       the sample rate in hertz
	#   returns      nothing; use MakeSilenceQ to chain
	#   note         the rate is kept in the buffer and travels into SaveAs files
	#   warning      the old buffer is freed first
	#   see          StzSoundOfSilenceQ, Release
	#@ aka  -- lifecycle ----------------------------------------------------------
	def MakeSilence(pnSeconds, pnChannels, pnRate)
		This.Release()
		@nBuf = StzEngineSoundNewSilent(floor(pnSeconds * pnRate), pnChannels, pnRate)
		if @nBuf = 0
			@cLastError = StzEngineSoundLastError()
		ok

	def MakeSilenceQ(pnSeconds, pnChannels, pnRate)
		This.MakeSilence(pnSeconds, pnChannels, pnRate)
		return This

	# Makes the sound hold a sample buffer that the engine already owns, freeing the buffer held before.
	#
	#   pnBufferId   the engine's id of the buffer to adopt
	#   returns      nothing
	#   warning      the sound then owns the id, so freeing it twice is the caller's fault
	#   see          BufferId, StzSoundFromBufferQ
	def AdoptBuffer(pnBufferId)
		This.Release()
		@nBuf = pnBufferId

	# Returns the engine's id of the held sample buffer, to hand to a graph or a mixer.
	#
	#   returns    a number; 0 when the sound holds nothing
	#   see        AdoptBuffer, Release
	#@ aka  Hand the engine id out -- for a graph that wants this sound as a source. An ENGINE handle, not a pointer, so it obeys the house law.
	def BufferId()
		return @nBuf

	# Frees the held sample buffer and leaves the sound empty.
	#
	#   returns    nothing
	#   warning    calling it again on the empty sound does nothing
	#   see        IsEmpty, MakeSilence
	def Release()
		if @nBuf != 0
			StzEngineSoundFree(@nBuf)
			@nBuf = 0
		ok

	# TRUE if the sound holds no buffer or a buffer of no frames.
	#
	#   returns    TRUE or FALSE
	#   see        Frames, Release
	def IsEmpty()
		return @nBuf = 0 or StzEngineSoundFrames(@nBuf) <= 0

	# Returns the text of the last failure the sound recorded, or an empty text.
	#
	#   returns    a text
	#   warning    an error stays until the next failure replaces it; a success does not clear it
	#   see        init, SaveAs
	def LastError()
		return @cLastError

	# Returns how many frames, one sample per channel each, the sound holds.
	#
	#   returns    a number; 0 for an empty sound
	#   see        Duration, SampleRate
	#@ aka  -- readers: they return DATA and keep their names ---------------------
	def Frames()
		if @nBuf = 0  return 0 ok
		return StzEngineSoundFrames(@nBuf)

	# Returns the number of channels the sound holds.
	#
	#   returns    a number; 0 for an empty sound
	#   see        ChangeChannelsTo, ToMono
	def Channels()
		if @nBuf = 0  return 0 ok
		return StzEngineSoundChannels(@nBuf)

	# Returns the sample rate of the held buffer, in hertz.
	#
	#   returns    a number; 0 for an empty sound
	#   warning    the rate is read from the buffer, not guessed from a file name
	#   see        ResampleTo, Duration
	def SampleRate()
		if @nBuf = 0  return 0 ok
		return StzEngineSoundRate(@nBuf)

	# Returns the length of the sound in seconds, from its frames and its rate.
	#
	#   returns    a number of seconds; 0 for an empty sound
	#   see        Frames, SampleRate
	def Duration()
		if @nBuf = 0  return 0 ok
		return StzEngineSoundDuration(@nBuf)

	# Returns the largest absolute sample value across all channels, 1 being full scale.
	#
	#   returns    a number from 0 to 1 or more; 0 for an empty sound
	#   see        Rms, Loudness
	def Peak()
		if @nBuf = 0  return 0 ok
		return StzEngineSoundPeak(@nBuf)

	# Returns the root-mean-square level of the samples, a measure of average strength.
	#
	#   returns    a number; 0 for an empty sound
	#   see        Peak, Loudness
	def Rms()
		if @nBuf = 0  return 0 ok
		return StzEngineSoundRms(@nBuf)

	# Returns one sample value, by 1-based frame and channel.
	#
	#   pnFrame     the frame to read, counted from 1
	#   pnChannel   the channel to read, counted from 1
	#   returns     a number between -1 and 1; 0 for an empty sound
	#   see         SetSampleAt, ToList
	#@ aka  ONE sample. 1-based frame and channel, like every Ring face.
	def SampleAt(pnFrame, pnChannel)
		if @nBuf = 0  return 0 ok
		return StzEngineSoundGet(@nBuf, pnFrame, pnChannel)

	# Writes one sample value at a 1-based frame and channel.
	#
	#   pnFrame     the frame to write, counted from 1
	#   pnChannel   the channel to write, counted from 1
	#   pnValue     the sample value, between -1 and 1
	#   returns     nothing; use SetSampleAtQ to chain
	#   warning     an empty sound ignores the call
	#   see         SampleAt
	def SetSampleAt(pnFrame, pnChannel, pnValue)
		if @nBuf = 0  return ok
		StzEngineSoundSet(@nBuf, pnFrame, pnChannel, pnValue)

	def SetSampleAtQ(pnFrame, pnChannel, pnValue)
		This.SetSampleAt(pnFrame, pnChannel, pnValue)
		return This

	# Returns the samples of one channel as a list of numbers, one per frame.
	#
	#   pnChannel   the channel to read, counted from 1
	#   returns     a list of numbers; [ ] for an empty sound
	#   warning     one engine call per sample: fine for a few thousand frames, slow for a whole
	#               song
	#   see         SampleAt, ToSpectrum
	#@ aka  The samples of one channel, as a Ring list. DATA, so To... is right. Be aware this crosses the FFI once per sample -- fine for a look at a few thousand frames, wrong for a whole song.
	def ToList(pnChannel)
		_a_ = []
		if @nBuf = 0  return _a_ ok
		_n_ = StzEngineSoundFrames(@nBuf)
		for _i_ = 1 to _n_
			_a_ + StzEngineSoundGet(@nBuf, _i_, pnChannel)
		next
		return _a_

	# Converts the sound in place to a new sample rate with the high-quality sinc method.
	#
	#   pnRate     the new sample rate in hertz
	#   returns    nothing; use ResampleToQ to chain
	#   note       a failure sets LastError and keeps the old buffer
	#   warning    the frame count changes in proportion to the rate, and the old buffer is freed
	#   see        ResampleToFast, SampleRate
	#@ aka  -- verbs that change the sound ----------------------------------------
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

	# Converts the sound in place to a new sample rate with the cheaper linear method.
	#
	#   pnRate     the new sample rate in hertz
	#   returns    nothing; use ResampleToFastQ to chain
	#   note       the frame count changes in proportion to the rate
	#   warning    less accurate than ResampleTo
	#   see        ResampleTo, SampleRate
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

	# Converts the sound in place to the given number of channels.
	#
	#   pnChannels   the number of channels wanted
	#   returns      nothing; use ChangeChannelsToQ to chain
	#   note         the engine also accepts counts above 2 and builds them without complaint
	#   warning      the old buffer is freed
	#   see          ToMono, ToStereo
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

	# Converts the sound in place to one channel.
	#
	#   returns    nothing; use ToMonoQ to chain
	#   see        ToStereo, ChangeChannelsTo
	def ToMono()
		This.ChangeChannelsTo(1)

	def ToMonoQ()
		This.ToMono()
		return This

	# Converts the sound in place to two channels.
	#
	#   returns    nothing; use ToStereoQ to chain
	#   see        ToMono, ChangeChannelsTo
	def ToStereo()
		This.ChangeChannelsTo(2)

	def ToStereoQ()
		This.ToStereo()
		return This

	# Returns the whole sound encoded as a 16-bit WAV file, held in memory.
	#
	#   returns    a text of bytes starting with RIFF; an empty text for an empty sound
	#   warning    no file is written
	#   see        SaveAs, init
	#@ aka  -- output --------------------------------------------------------------
	def ToWavBytes()
		if @nBuf = 0  return "" ok
		return StzEngineSoundToWavBytes(@nBuf)

	# Adds another sound into this one, starting at a time offset and scaled by a gain.
	#
	#   poSound     the sound to add
	#   pnSeconds   the time in this sound where the other starts, in seconds
	#   pnGain      the factor the added samples are multiplied by
	#   returns     the sound itself, so calls chain
	#   warning     refused, with LastError set, when the two sample rates differ, since the note
	#               would change pitch; an empty receiver or a non-object argument is ignored
	#   see         StzSoundOfSilenceQ
	#@ aka  16-bit by default: it is what everything reads, and SN1 measured the round-trip error at 4.18e-5, one quantum. Ask for 32 when you are handing the file back to another stage rather than to a listener. ADD another sound into this one from pnSeconds in, scaled by pnGain -- notes laid on a timeline. Refused when the sample rates differ: a note mixed at the wrong rate would be a different pitch, silen
	def MixIn(poSound, pnSeconds, pnGain)
		if @nBuf = 0 or NOT isObject(poSound)  return This ok
		_at_ = floor(pnSeconds * StzEngineSoundRate(@nBuf)) + 1
		if StzEngineSoundMixInto(@nBuf, poSound.BufferId(), _at_, pnGain) < 0
			@cLastError = StzEngineSoundLastError()
		ok
		return This

	# Writes the sound to a WAV file with 16-bit samples.
	#
	#   pcPath     the file to write, overwritten
	#   returns    nothing; use SaveAsQ to chain
	#   note       a failure sets LastError
	#   warning    the rate and channel count are stored in the file
	#   see        SaveAsFloat, ToWavBytes
	def SaveAs(pcPath)
		if @nBuf = 0  return ok
		if StzEngineSoundSaveWav(@nBuf, pcPath, 16) != 0
			@cLastError = StzEngineSoundLastError()
		ok

	def SaveAsQ(pcPath)
		This.SaveAs(pcPath)
		return This

	# Writes the sound to a WAV file with 32-bit float samples, for handing to another stage.
	#
	#   pcPath     the file to write, overwritten
	#   returns    nothing; use SaveAsFloatQ to chain
	#   warning    the file is twice the size of the 16-bit one
	#   see        SaveAs
	def SaveAsFloat(pcPath)
		if @nBuf = 0  return ok
		if StzEngineSoundSaveWav(@nBuf, pcPath, 32) != 0
			@cLastError = StzEngineSoundLastError()
		ok

	def SaveAsFloatQ(pcPath)
		This.SaveAsFloat(pcPath)
		return This

	# Plays the sound on the default audio device and waits until it has ended, plus a quarter second.
	#
	#   returns    nothing
	#   note       it builds a one-node graph, so for background play use a stzSoundGraph
	#   warning    not run in this reference: it opens an audio device; with no device tier or no
	#              device it sets LastError and returns silently
	#   see        PlayFor, SaveAs
	#@ aka  -- hearing it ----------------------------------------------------------
	def Play()
		This.PlayFor(This.Duration() + 0.25)

	def PlayForQ(pnSeconds)
		This.PlayFor(pnSeconds)
		return This

	# Plays the sound on the default audio device for a stated time, then closes the device.
	#
	#   pnSeconds   how long to keep the device open, in seconds
	#   returns     nothing; use PlayForQ to chain
	#   note        a time shorter than the sound cuts it off
	#   warning     not run in this reference: it opens an audio device; with no device it sets
	#               LastError and returns silently
	#   see         Play
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

	# Returns the magnitude spectrum of the first 4096 frames of channel 1 as a grid of numbers.
	#
	#   returns    a stzSoundGrid of 1 row and 2049 columns; an empty text for an empty sound
	#   see        ToSpectrumOf, DominantFrequency
	#@ aka  -- analysis (SN5): the output is DATA, never a picture -----------------
	def ToSpectrum()
		return This.ToSpectrumOf(1, 1, 4096)

	# Returns the magnitude spectrum of one window of one channel as a grid of numbers.
	#
	#   pnChannel      the channel to analyse, counted from 1
	#   pnStartFrame   the first frame of the window, counted from 1
	#   pnFftSize      the window length in frames
	#   returns        a stzSoundGrid of 1 row and pnFftSize / 2 + 1 columns; an empty text when the
	#                  window cannot be taken
	#   warning        a failure sets LastError
	#   see            ToSpectrum, ToSpectrogramOf
	def ToSpectrumOf(pnChannel, pnStartFrame, pnFftSize)
		if @nBuf = 0  return "" ok
		_g_ = StzEngineSoundSpectrum(@nBuf, pnChannel, pnStartFrame, pnFftSize)
		if _g_ = 0
			@cLastError = StzEngineSoundAnalysisLastError()
			return ""
		ok
		return new stzSoundGrid(_g_)

	# Returns frequency against time for channel 1, one grid row per 2048-frame window moving 512 frames.
	#
	#   returns    a stzSoundGrid with one row per window and 1025 columns; an empty text for an
	#              empty sound
	#   warning    uses 4 threads
	#   see        ToSpectrogramOf, ToSpectrum
	#@ aka  Frequency against time: one row per window. MULTICORE by default -- every row is an independent FFT over a different slice of the same immutable buffer, which is the one analysis here that parallelises without an argument.
	def ToSpectrogram()
		return This.ToSpectrogramOf(1, 2048, 512, 4)

	# Returns frequency against time for one channel, one grid row per window, with the window, hop and thread count chosen.
	#
	#   pnChannel   the channel to analyse, counted from 1
	#   pnFftSize   the window length in frames
	#   pnHop       the frames between two window starts
	#   pnThreads   how many threads share the windows
	#   returns     a stzSoundGrid with one row per window and pnFftSize / 2 + 1 columns; an empty
	#               text on failure
	#   warning     a failure sets LastError
	#   see         ToSpectrogram
	def ToSpectrogramOf(pnChannel, pnFftSize, pnHop, pnThreads)
		if @nBuf = 0  return "" ok
		_g_ = StzEngineSoundSpectrogram(@nBuf, pnChannel, pnFftSize, pnHop, pnThreads)
		if _g_ = 0
			@cLastError = StzEngineSoundAnalysisLastError()
			return ""
		ok
		return new stzSoundGrid(_g_)

	# Returns the strongest frequency present in channel 1, in hertz, from an 8192-frame window.
	#
	#   returns    a number of hertz; -1 for an empty sound
	#   warning    the answer is the centre of a bin about 6 Hz wide, so a 440 Hz sine reads 439.45
	#              or 440.43
	#   see        ToSpectrum
	#@ aka  The strongest frequency present, in hertz.
	def DominantFrequency()
		if @nBuf = 0  return -1 ok
		return StzEngineSoundDominantFrequency(@nBuf, 1, 8192)

	# Returns the times at which notes start in channel 1, in seconds, with the default sensitivity of 0.35.
	#
	#   returns    a stzSoundGrid of 1 row, one column per onset; an empty text for an empty sound
	#   see        ToOnsetsOf, Tempo
	#@ aka  Where notes START, in seconds -- a one-row grid of times.
	def ToOnsets()
		return This.ToOnsetsOf(1, 0.35)

	# Returns the times at which notes start in one channel, in seconds, with a chosen sensitivity.
	#
	#   pnChannel       the channel to analyse, counted from 1
	#   pnSensitivity   how easily a rise in energy counts as an onset, a larger number accepting
	#                   fewer rises, so fewer onsets
	#   returns         a stzSoundGrid of 1 row, one column per onset; an empty text on failure
	#   warning         a failure sets LastError
	#   see             ToOnsets
	def ToOnsetsOf(pnChannel, pnSensitivity)
		if @nBuf = 0  return "" ok
		_g_ = StzEngineSoundOnsets(@nBuf, pnChannel, 2048, 512, pnSensitivity)
		if _g_ = 0
			@cLastError = StzEngineSoundAnalysisLastError()
			return ""
		ok
		return new stzSoundGrid(_g_)

	# Returns the speed of the beat in channel 1, in beats per minute.
	#
	#   returns    a number; -1 when there are too few onsets to say, or the sound is empty
	#   warning    a pulse of 16 clicks at 0.5 s reads 119.68, not exactly 120
	#   see        ToOnsets
	#@ aka  Beats per minute, or -1 when there are too few onsets to say -- which is a better answer than a confident number derived from two events.
	def Tempo()
		if @nBuf = 0  return -1 ok
		return StzEngineSoundTempo(@nBuf, 1)

	# Returns the integrated loudness in LUFS, resampling a copy to 48 kHz first when the sound has another rate.
	#
	#   returns    a number of LUFS; -1000 for silence, for an empty sound and for a sound shorter
	#              than one 400 ms block
	#   warning    the caller's sound is not changed
	#   see        MomentaryLoudness, LoudnessOfSupport
	#@ aka  Integrated loudness in LUFS (ITU-R BS.1770-4), or -1000 for silence.
	def Loudness()
		if @nBuf = 0  return -1000 ok
		if StzEngineSoundRate(@nBuf) = 48000
			return StzEngineSoundLoudness(@nBuf)
		ok
		_tmp_ = StzEngineSoundResample(@nBuf, 48000, StzSoundQualitySinc())
		if _tmp_ = 0
			@cLastError = StzEngineSoundLastError()
			return -1000
		ok
		_l_ = StzEngineSoundLoudness(_tmp_)
		StzEngineSoundFree(_tmp_)
		return _l_

	# Returns the loudest 400 ms window of the sound in LUFS, the measure that works for a short cue.
	#
	#   returns    a number of LUFS; -1000 for an empty sound, for silence and for a sound shorter
	#              than 400 ms
	#   warning    resamples a copy to 48 kHz when needed; a 200 ms sound reads -1000, which
	#              LoudnessOfSupport measures instead
	#   see        Loudness, ShortTermLoudness
	#@ aka  SS2 -- THE LOUDNESS AN EARCON CAN BE MEASURED WITH.
	def MomentaryLoudness()
		return This._LoudnessVia(:momentary)

	# Returns the loudest 3 s window of the sound in LUFS.
	#
	#   returns    a number of LUFS; -1000 for an empty sound, silence or a sound shorter than 3 s
	#   warning    resamples a copy to 48 kHz when needed
	#   see        MomentaryLoudness, Loudness
	def ShortTermLoudness()
		return This._LoudnessVia(:shortterm)

	# Returns the K-weighted level over the sound's whole length, which is not a standard LUFS figure.
	#
	#   returns    a number of decibels; -1000 for an empty sound or silence
	#   warning    resamples a copy to 48 kHz when needed
	#   see        LoudnessMetric, MomentaryLoudness
	#@ aka  The same K-weighting and the same formula over the sound's OWN length. NOT a standard LUFS figure, and LoudnessMetric() says so -- because the alternative is answering the standard's question wrongly instead of answering a different question honestly. A 60 ms earcon at peak 0.5 reads -9.26 here against -9.27 for the same tone at 400 ms: the two agree to a hundredth of a decibel where the standard 
	def LoudnessOfSupport()
		return This._LoudnessVia(:support)

	# Returns the engine's name for what LoudnessOfSupport measures, so the number never travels without its meaning.
	#
	#   returns    a text
	#   see        LoudnessOfSupport
	#@ aka  What the number means, so it never travels without its method.
	def LoudnessMetric()
		return StzEngineSoundLoudnessMetricName()

	# Every one of the three resamples a COPY to 48 kHz when it must, exactly as
	# Loudness does: the K-weighting coefficients are specified at 48 kHz, and
	# the engine refuses another rate rather than returning a plausible number.
	def _LoudnessVia(pWhich)
		if @nBuf = 0  return -1000 ok
		_id_ = @nBuf
		_tmp_ = 0
		if StzEngineSoundRate(@nBuf) != 48000
			_tmp_ = StzEngineSoundResample(@nBuf, 48000, StzSoundQualitySinc())
			if _tmp_ = 0
				@cLastError = StzEngineSoundLastError()
				return -1000
			ok
			_id_ = _tmp_
		ok
		_v_ = -1000
		switch pWhich
		on :momentary   _v_ = StzEngineSoundLoudnessMomentary(_id_)
		on :shortterm   _v_ = StzEngineSoundLoudnessShortTerm(_id_)
		on :support     _v_ = StzEngineSoundLoudnessOfSupport(_id_)
		off
		if _tmp_ != 0  StzEngineSoundFree(_tmp_) ok
		return _v_
