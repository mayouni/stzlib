#---------------------------------------------------------------------------#
#  STZMICROPHONE -- record from an input, and get an ordinary sound back.    #
#---------------------------------------------------------------------------#
#
#     oM = new stzMicrophone()
#     ? oM.IsAvailable()
#     ? oM.DeviceName()
#
#     oS = oM.RecordFor(3)              # 3 seconds -> a stzSound
#     oS.SaveAs("me.wav")
#     ? oS.Peak()
#
#     # or drive it yourself, to watch the level while it runs
#     oM.StartRecording(10)
#     while oM.IsRecording()
#         oM.Collect()                  # move what arrived into the recording
#         ? oM.SecondsRecorded()
#         sleep(0.2)
#     end
#     oS = oM.StopRecording()
#
# THE LAW THIS CLASS FOLLOWS: verbs (StartRecording, Collect, StopRecording),
# plain forms act, Q twins return the microphone, readers return data.
#
# WHY IT EXISTS AT ALL, AND WHY IT NEARLY DID NOT: SN4's challenge pass found
# that the plan named stzMicrophone while the plane had no capture stream --
# SN1 built enumeration only, SN3 built a playback sink. A face over nothing
# is worse than a missing face, so SN4 built the capture path rather than ship
# a stub: the ring already existed and is single-producer/single-consumer, and
# capture is simply that ring run the other way round -- the device callback
# is the PRODUCER, this face the consumer.
#
# COLLECT() IS NOT OPTIONAL. The device fills a ring holding about 250 ms. If
# nobody drains it, the newest frames are DROPPED and counted as overruns --
# never written over unread audio, because losing the newest is recoverable
# and losing the middle of a recording silently is not. RecordFor() collects
# for you; the manual form makes you do it, which is the honest trade for
# being able to watch the level as it goes.

func StzMicrophoneQ()
	return new stzMicrophone()

class stzMicrophone

	@nRec = 0            # the engine recorder
	@nDev = 0            # the capture device
	@nChannels = 1
	@nRate = 48000
	@bRecording = FALSE
	@cLastError = ""

	def init()
		if NOT StzSoundEngineLoaded()
			@cLastError = "stz_sound.dll is not loaded"
		ok

	#-- readers -------------------------------------------------------------

	# Is there anything to record WITH? A machine with no input, or no device
	# DLL at all, is a supported configuration -- CI is one.
	def IsAvailable()
		if NOT StzAudioDevEngineLoaded()  return FALSE ok
		if StzEngineAudioDevIsAvailable() = 0  return FALSE ok
		return StzEngineAudioDevCount(StzAudioDevKindCapture()) > 0

	def DeviceCount()
		if NOT StzAudioDevEngineLoaded()  return 0 ok
		_n_ = StzEngineAudioDevCount(StzAudioDevKindCapture())
		if _n_ < 0  return 0 ok
		return _n_

	# The default input's name. UTF-8 and not necessarily ASCII -- SN0 found
	# this machine reports a French one.
	def DeviceName()
		if NOT This.IsAvailable()  return "" ok
		_i_ = StzEngineAudioDevDefaultIndex(StzAudioDevKindCapture())
		if _i_ < 1  _i_ = 1 ok
		return StzEngineAudioDevName(StzAudioDevKindCapture(), _i_)

	def IsRecording()
		return @bRecording

	def SecondsRecorded()
		if @nRec = 0  return 0 ok
		_f_ = StzEngineSoundRecorderFrames(@nRec)
		if _f_ <= 0  return 0 ok
		return _f_ / @nRate

	def FramesRecorded()
		if @nRec = 0  return 0 ok
		return StzEngineSoundRecorderFrames(@nRec)

	# Frames the ring could not accept because nobody collected in time.
	# Zero is the answer you want, and it is COUNTED rather than guessed at.
	def Overruns()
		if @nDev = 0  return 0 ok
		return StzEngineAudioDevCaptureOverruns(@nDev)

	def LastError()
		return @cLastError

	def SetChannels(pnChannels)
		@nChannels = pnChannels

	def SetChannelsQ(pnChannels)
		This.SetChannels(pnChannels)
		return This

	def SetSampleRate(pnRate)
		@nRate = pnRate

	def SetSampleRateQ(pnRate)
		This.SetSampleRate(pnRate)
		return This

	#-- recording -----------------------------------------------------------

	# The whole thing in one call: record nSeconds and hand back a stzSound.
	def RecordFor(pnSeconds)
		if NOT This.StartRecording(pnSeconds)  return NULL ok
		_t_ = 0
		while _t_ < pnSeconds
			sleep(0.05)
			_t_ += 0.05
			This.Collect()             # keep the ring from overflowing
		end
		return This.StopRecording()

	# Open the input and start filling. nMaxSeconds sizes the recording buffer
	# up front -- growing it mid-capture is exactly the pause that costs frames.
	def StartRecording(pnMaxSeconds)
		if @bRecording
			@cLastError = "already recording"
			return FALSE
		ok
		if NOT This.IsAvailable()
			@cLastError = "no capture device on this machine"
			return FALSE
		ok
		@nRec = StzEngineSoundRecorderNew(@nChannels, @nRate, pnMaxSeconds)
		if @nRec = 0
			@cLastError = StzEngineSoundLastError()
			return FALSE
		ok
		@nDev = StzEngineAudioDevCaptureOpen(StzEngineSoundRecorderRingPtr(@nRec), 256)
		if @nDev = 0
			@cLastError = StzEngineAudioDevLastError()
			StzEngineSoundRecorderFree(@nRec)
			@nRec = 0
			return FALSE
		ok
		if StzEngineAudioDevCaptureStart(@nDev) != 0
			@cLastError = StzEngineAudioDevLastError()
			StzEngineAudioDevCaptureClose(@nDev)
			StzEngineSoundRecorderFree(@nRec)
			@nDev = 0
			@nRec = 0
			return FALSE
		ok
		@bRecording = TRUE
		return TRUE

	# Move whatever has arrived into the recording. Call it often.
	def Collect()
		if @nRec = 0  return 0 ok
		return StzEngineSoundRecorderDrain(@nRec)

	def CollectQ()
		This.Collect()
		return This

	# Stop, and hand back what was recorded as a stzSound. NULL if nothing
	# was captured -- an empty recording is a failure worth hearing about,
	# not a silent buffer of zeros.
	def StopRecording()
		if @nRec = 0
			@cLastError = "not recording"
			return NULL
		ok
		if @nDev != 0
			StzEngineAudioDevCaptureStop(@nDev)
			This.Collect()                        # whatever landed last
			StzEngineAudioDevCaptureClose(@nDev)  # consumer stops FIRST
			@nDev = 0
		ok
		@bRecording = FALSE
		_b_ = StzEngineSoundRecorderFinish(@nRec)  # then the ring is freed
		@nRec = 0
		if _b_ = 0
			@cLastError = StzEngineSoundLastError()
			return NULL
		ok
		return StzSoundFromBufferQ(_b_)

	# Give up on a recording without wanting the audio.
	def CancelRecording()
		if @nDev != 0
			StzEngineAudioDevCaptureStop(@nDev)
			StzEngineAudioDevCaptureClose(@nDev)
			@nDev = 0
		ok
		if @nRec != 0
			StzEngineSoundRecorderFree(@nRec)
			@nRec = 0
		ok
		@bRecording = FALSE
