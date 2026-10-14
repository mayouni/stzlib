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

# Records from an input device and hands back the recording as an ordinary stzSound.
#
# RecordFor records for a number of seconds in one call; StartRecording, Collect and StopRecording
# let you drive it and watch the level as it goes. Collect is not optional: the device fills a ring
# of about 250 ms and, if nobody drains it, the newest frames are dropped and counted as overruns,
# never written over unread audio. A machine with no input or no device library is a supported
# configuration and IsAvailable answers 0. For this reference the microphone was never opened and no
# device was queried, so the example uses only what touches none: the settings, the counters at rest
# and the refusals. Nothing was recorded or heard (UNPERCEIVED).
#
#   receiver   o1 = new stzMicrophone()
#   example    ? o1.IsRecording()
#              #--> 0
#              ? o1.SecondsRecorded()
#              #--> 0
#              ? o1.FramesRecorded()
#              #--> 0
#              ? o1.Overruns()
#              #--> 0
#              ? o1.Collect()
#              #--> 0
#              o1.SetChannels(2)
#              o1.SetSampleRate(44100)
#              oNone = o1.StopRecording()
#              ? o1.LastError()
#              #--> not recording
#   see        stzSound, stzSoundLive, stzListener
class stzMicrophone

	@nRec = 0            # the engine recorder
	@nDev = 0            # the capture device
	@nChannels = 1
	@nRate = 48000
	@bRecording = 0
	@cLastError = ""

	# Builds a recorder with one channel at 48000 hertz, noting whether the sound engine is loaded.
	#
	#   returns    nothing; the object is built and no device is opened
	#   note       StzMicrophoneQ builds the same object; without the sound engine LastError says
	#              stz_sound.dll is not loaded
	#   see        StartRecording, RecordFor
	def init()
		if NOT StzSoundEngineLoaded()
			@cLastError = "stz_sound.dll is not loaded"
		ok

	# TRUE if there is an input to record with.
	#
	#   returns    TRUE or FALSE, as 1 or 0; 0 on a machine with no input or no device library, a
	#              supported configuration
	#   note       CI machines answer 0
	#   warning    not run: it asks the operating system for its capture devices
	#   see        DeviceCount, DeviceName
	#@ aka  -- readers -------------------------------------------------------------
	def IsAvailable()
		if NOT StzAudioDevEngineLoaded()  return 0 ok
		if StzEngineAudioDevIsAvailable() = 0  return 0 ok
		return StzEngineAudioDevCount(StzAudioDevKindCapture()) > 0

	# Returns how many capture devices the machine has.
	#
	#   returns    a number; 0 when there is no device library
	#   warning    not run: it asks the operating system for its capture devices
	#   see        IsAvailable, DeviceName
	def DeviceCount()
		if NOT StzAudioDevEngineLoaded()  return 0 ok
		_n_ = StzEngineAudioDevCount(StzAudioDevKindCapture())
		if _n_ < 0  return 0 ok
		return _n_

	# Returns the name of the default input.
	#
	#   returns    the name as text, which may be UTF-8 and not ASCII; an empty text when there is
	#              none
	#   note       one machine of the plane reported a French name
	#   warning    not run: it asks the operating system for its capture devices
	#   see        DeviceCount, IsAvailable
	#@ aka  The default input's name. UTF-8 and not necessarily ASCII -- SN0 found this machine reports a French one.
	def DeviceName()
		if NOT This.IsAvailable()  return "" ok
		_i_ = StzEngineAudioDevDefaultIndex(StzAudioDevKindCapture())
		if _i_ < 1  _i_ = 1 ok
		return StzEngineAudioDevName(StzAudioDevKindCapture(), _i_)

	# TRUE if a recording is running.
	#
	#   returns    1 or 0
	#   note       0 for a recorder that never started
	#   see        StartRecording, StopRecording
	def IsRecording()
		return @bRecording

	# Returns how many seconds have been collected so far.
	#
	#   returns    a number of seconds; 0 when no recording exists
	#   note       frames divided by the sample rate; it grows only when Collect moves frames in
	#   see        FramesRecorded, Collect
	def SecondsRecorded()
		if @nRec = 0  return 0 ok
		_f_ = StzEngineSoundRecorderFrames(@nRec)
		if _f_ <= 0  return 0 ok
		return _f_ / @nRate

	# Returns how many frames have been collected so far.
	#
	#   returns    a number; 0 when no recording exists
	#   see        SecondsRecorded, Collect
	def FramesRecorded()
		if @nRec = 0  return 0 ok
		return StzEngineSoundRecorderFrames(@nRec)

	# Returns how many frames the device had to drop because nobody collected in time.
	#
	#   returns    a number; 0 is the answer you want, and 0 when no device is open
	#   note       the ring holds about 250 ms; when full, the newest frames are dropped and
	#              counted, never written over unread audio
	#   see        Collect
	#@ aka  Frames the ring could not accept because nobody collected in time. Zero is the answer you want, and it is COUNTED rather than guessed at.
	def Overruns()
		if @nDev = 0  return 0 ok
		return StzEngineAudioDevCaptureOverruns(@nDev)

	# Returns the reason of the last failure.
	#
	#   returns    the reason as text; an empty text when nothing went wrong
	#   note       after StopRecording with nothing running it reads not recording
	#   see        StartRecording, StopRecording
	def LastError()
		return @cLastError

	# Sets how many channels the next recording has.
	#
	#   pnChannels   the number of channels, 1 by default
	#   returns      nothing; the number is stored. SetChannelsQ returns the microphone for chaining
	#   note         it is not checked; set it before StartRecording
	#   see          SetSampleRate, StartRecording
	def SetChannels(pnChannels)
		@nChannels = pnChannels

	def SetChannelsQ(pnChannels)
		This.SetChannels(pnChannels)
		return This

	# Sets the sample rate the next recording is made at.
	#
	#   pnRate     the rate in hertz, 48000 by default
	#   returns    nothing; the number is stored. SetSampleRateQ returns the microphone for chaining
	#   note       it is not checked; set it before StartRecording, and SecondsRecorded divides by
	#              it
	#   see        SetChannels, StartRecording
	def SetSampleRate(pnRate)
		@nRate = pnRate

	def SetSampleRateQ(pnRate)
		This.SetSampleRate(pnRate)
		return This

	# Records for a number of seconds, collecting as it goes, and returns the sound.
	#
	#   pnSeconds   how long to record, in seconds
	#   returns     a stzSound of what was recorded; an empty text when no recording could start or
	#               nothing was captured
	#   note        it waits in steps of 50 ms and collects at each, so the ring does not overflow
	#   warning     not run: it opens the input device and records
	#   see         StartRecording, StopRecording
	#@ aka  -- recording -----------------------------------------------------------
	def RecordFor(pnSeconds)
		if NOT This.StartRecording(pnSeconds)  return "" ok
		_t_ = 0
		while _t_ < pnSeconds
			sleep(0.05)
			_t_ += 0.05
			This.Collect()             # keep the ring from overflowing
		end
		return This.StopRecording()

	# Opens the input and starts filling a recording of a fixed maximum length.
	#
	#   pnMaxSeconds   the longest the recording can be, in seconds, which sizes its buffer up front
	#   returns        1 when recording began; 0 with the reason in LastError when it is already
	#                  recording, there is no capture device or the device refused
	#   note           the buffer is sized at the start because growing it during capture is the
	#                  pause that costs frames
	#   warning        not run: it opens the input device
	#   see            Collect, StopRecording
	#@ aka  Open the input and start filling. nMaxSeconds sizes the recording buffer up front -- growing it mid-capture is exactly the pause that costs frames.
	def StartRecording(pnMaxSeconds)
		if @bRecording
			@cLastError = "already recording"
			return 0
		ok
		if NOT This.IsAvailable()
			@cLastError = "no capture device on this machine"
			return 0
		ok
		@nRec = StzEngineSoundRecorderNew(@nChannels, @nRate, pnMaxSeconds)
		if @nRec = 0
			@cLastError = StzEngineSoundLastError()
			return 0
		ok
		@nDev = StzEngineAudioDevCaptureOpen(StzEngineSoundRecorderRingPtr(@nRec), 256)
		if @nDev = 0
			@cLastError = StzEngineAudioDevLastError()
			StzEngineSoundRecorderFree(@nRec)
			@nRec = 0
			return 0
		ok
		if StzEngineAudioDevCaptureStart(@nDev) != 0
			@cLastError = StzEngineAudioDevLastError()
			StzEngineAudioDevCaptureClose(@nDev)
			StzEngineSoundRecorderFree(@nRec)
			@nDev = 0
			@nRec = 0
			return 0
		ok
		@bRecording = 1
		return 1

	# Moves what the device has delivered into the recording; to be called often while recording.
	#
	#   returns    the number of frames moved; 0 when no recording exists. CollectQ returns the
	#              microphone for chaining
	#   note       it is not optional: an undrained ring drops the newest frames and counts them as
	#              overruns
	#   see        StartRecording, Overruns
	#@ aka  Move whatever has arrived into the recording. Call it often.
	def Collect()
		if @nRec = 0  return 0 ok
		return StzEngineSoundRecorderDrain(@nRec)

	def CollectQ()
		This.Collect()
		return This

	# Stops the input, collects the last frames and returns the recording as a sound.
	#
	#   returns    a stzSound; an empty text, with the error not recording, when nothing is running
	#              or nothing was captured
	#   note       the consumer stops before the ring is freed; an empty recording is reported as a
	#              failure and not as a buffer of zeros
	#   see        StartRecording, CancelRecording
	#@ aka  Stop, and hand back what was recorded as a stzSound. NULL if nothing was captured -- an empty recording is a failure worth hearing about, not a silent buffer of zeros.
	def StopRecording()
		if @nRec = 0
			@cLastError = "not recording"
			return ""
		ok
		if @nDev != 0
			StzEngineAudioDevCaptureStop(@nDev)
			This.Collect()                        # whatever landed last
			StzEngineAudioDevCaptureClose(@nDev)  # consumer stops FIRST
			@nDev = 0
		ok
		@bRecording = 0
		_b_ = StzEngineSoundRecorderFinish(@nRec)  # then the ring is freed
		@nRec = 0
		if _b_ = 0
			@cLastError = StzEngineSoundLastError()
			return ""
		ok
		return StzSoundFromBufferQ(_b_)

	# Gives up on a recording and discards what was captured.
	#
	#   returns    nothing; the device is closed and the recording freed
	#   note       calling it with nothing running does nothing
	#   see        StopRecording
	#@ aka  Give up on a recording without wanting the audio.
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
		@bRecording = 0
