#---------------------------------------------------------------------------#
#  STZSOUNDGRAPH -- describe a sound once; render it to a file OR hear it.   #
#---------------------------------------------------------------------------#
#
#     oG = new stzSoundGraph()                  # stereo, 48 kHz
#     oG.AddOscillator(:Triangle, 440, 0.6)
#     oG.NameIt(:tone)
#     oG.AddEnvelopeOn(:tone, 0.01, 0.3, 0.0, 0.4, 0.35)
#     oG.AddEchoOn(:tone, 0.25, 0.4, 0.4)
#     oG.ToFile("bell.wav", 3)
#
#     # the same, fluent -- every Q returns the GRAPH, never a node object
#     oG.AddOscillatorQ(:Sine, 880, 0.5).NameItQ(:bell).
#        AddEnvelopeOnQ(:bell, 0.001, 1.4, 0, 0.4, 1.6).
#        AddEchoOnQ(:bell, 0.38, 0.5, 0.4).
#        PlayForQ(5)
#
# THE LAW THIS CLASS FOLLOWS (house naming):
#   - a method is an explicit VERB acting on the graph: AddOscillator,
#     NameIt, SetOutputTo -- never a bare noun, and never a preposition;
#   - the plain form ACTS and returns nothing;
#   - the ...Q twin does the same act and returns THE GRAPH;
#   - To...() returns DATA or writes a file, and keeps its name.
#
# WHY THERE ARE NO stzOscillator / stzEnvelope / stzFilter CLASSES:
# the plan's first sketch had
#
#     oG.Add(StzOscillatorQ(:Sine).Hz(440)).Named(:tone)
#
# and SN4's challenge pass rejected it. Every line there builds an
# INTERMEDIATE object, configures it, and hands it over -- exactly what the
# Q law exists to prevent, and the same error the graphics sketch made before
# GR4 corrected it to AddCircleQ(). A node is not a thing you should be left
# holding; it is something the graph DOES.
#
# NAMES, NOT NUMBERS. The engine addresses nodes by index. Indices are a
# terrible thing to write by hand -- insert one node and every later number
# shifts. So the face keeps a name -> index map: NameIt(:tone) labels the last
# node added, and any On(...) verb takes that label. Numbers still work if you
# want them.
#
# THE LAST NODE ADDED is the one NameIt labels -- the same "last shape added"
# convention stzCanvas uses for Fill(). Every Add* also returns nothing (or
# the graph, for Q), so the label is how you refer back.
#
# ACYCLIC BY CONSTRUCTION, and the face cannot hide it: a node may only take
# inputs that already exist. Ask for an unknown name and you get a counted
# refusal, not a silent no-op.

func StzSoundGraphQ()
	return new stzSoundGraph()

func StzSoundGraphOfQ(pnChannels, pnRate)
	_o_ = new stzSoundGraph()
	_o_.Reshape(pnChannels, pnRate)
	return _o_

class stzSoundGraph

	@nG = 0
	@aNames = []          # [ [name, nodeIndex], ... ]
	@nLast = 0            # the last node added -- what NameIt labels
	@nOut = 0
	@cLastError = ""
	@nChannels = 2
	@nRate = 48000
	@nBlock = 512
	@nUnderruns = 0      # frames the last PlayFor could not supply

	def init()
		if NOT StzSoundEngineLoaded()
			@cLastError = "stz_sound.dll is not loaded"
			return
		ok
		@nG = StzEngineSoundGraphNew(@nChannels, @nRate, @nBlock)

	# Start over with a different shape. Only legal before anything is added.
	def Reshape(pnChannels, pnRate)
		if @nG != 0
			StzEngineSoundGraphFree(@nG)
		ok
		@nChannels = pnChannels
		@nRate = pnRate
		@aNames = []
		@nLast = 0
		@nOut = 0
		@nG = StzEngineSoundGraphNew(pnChannels, pnRate, @nBlock)

	def ReshapeQ(pnChannels, pnRate)
		This.Reshape(pnChannels, pnRate)
		return This

	def Release()
		if @nG != 0
			StzEngineSoundGraphFree(@nG)
			@nG = 0
		ok

	def LastError()
		if @cLastError != ""  return @cLastError ok
		return StzEngineSoundGraphLastError()

	def NodeCount()
		if @nG = 0  return 0 ok
		return StzEngineSoundGraphNodeCount(@nG)

	def GraphId()
		return @nG

	#-- naming --------------------------------------------------------------

	# Label the LAST node added, so later verbs can refer to it by name.
	def NameIt(pcName)
		if @nLast = 0
			@cLastError = "NameIt: nothing has been added yet to name"
			return
		ok
		@aNames + [ lower("" + pcName), @nLast ]

	def NameItQ(pcName)
		This.NameIt(pcName)
		return This

	# Resolve a name OR a raw node number to a node index. Unknown names are
	# an error the caller hears about, never a silent 0.
	def NodeNamed(pName)
		if isNumber(pName)
			return pName
		ok
		_c_ = lower("" + pName)
		_n_ = len(@aNames)
		for _i_ = 1 to _n_
			if @aNames[_i_][1] = _c_
				return @aNames[_i_][2]
			ok
		next
		@cLastError = "no node is named '" + pName + "'"
		return 0

	def HasNode(pName)
		return This.NodeNamed(pName) != 0

	#-- the sources ---------------------------------------------------------

	# WAVEFORM BY NAME, not by number: :Sine :Triangle :Square :Saw.
	def AddOscillator(pWave, pnHz, pnAmplitude)
		if @nG = 0  return ok
		@nLast = StzEngineSoundGraphAddOsc(@nG, This._WaveCode(pWave), pnHz, pnAmplitude)
		@nOut = @nLast

	def AddOscillatorQ(pWave, pnHz, pnAmplitude)
		This.AddOscillator(pWave, pnHz, pnAmplitude)
		return This

	# Play an existing sound (a stzSound, or an engine buffer id) as a source.
	def AddSound(poSound)
		if @nG = 0  return ok
		_id_ = poSound
		if isObject(poSound)
			_id_ = poSound.BufferId()
		ok
		@nLast = StzEngineSoundGraphAddSource(@nG, _id_, 0)
		if @nLast = 0
			@cLastError = StzEngineSoundGraphLastError()
		ok
		@nOut = @nLast

	def AddSoundQ(poSound)
		This.AddSound(poSound)
		return This

	def AddLoopingSound(poSound)
		if @nG = 0  return ok
		_id_ = poSound
		if isObject(poSound)
			_id_ = poSound.BufferId()
		ok
		@nLast = StzEngineSoundGraphAddSource(@nG, _id_, 1)
		@nOut = @nLast

	def AddLoopingSoundQ(poSound)
		This.AddLoopingSound(poSound)
		return This

	#-- the shapers: each takes WHAT it acts on, by name --------------------

	def AddGainOn(pName, pnGain)
		This._Chain(This.NodeNamed(pName), :gain, [pnGain])

	def AddGainOnQ(pName, pnGain)
		This.AddGainOn(pName, pnGain)
		return This

	def AddFilterOn(pName, pKind, pnCutoff, pnQ)
		This._Chain(This.NodeNamed(pName), :filter, [This._FilterCode(pKind), pnCutoff, pnQ])

	def AddFilterOnQ(pName, pKind, pnCutoff, pnQ)
		This.AddFilterOn(pName, pKind, pnCutoff, pnQ)
		return This

	def AddEnvelopeOn(pName, pnAttack, pnDecay, pnSustain, pnRelease, pnHold)
		This._Chain(This.NodeNamed(pName), :env, [pnAttack, pnDecay, pnSustain, pnRelease, pnHold, 0])

	def AddEnvelopeOnQ(pName, pnAttack, pnDecay, pnSustain, pnRelease, pnHold)
		This.AddEnvelopeOn(pName, pnAttack, pnDecay, pnSustain, pnRelease, pnHold)
		return This

	# The same envelope, starting nStart seconds in. THIS is what makes a
	# score possible: a voice that knows WHEN it sounds is a note.
	def AddEnvelopeOnAt(pName, pnAttack, pnDecay, pnSustain, pnRelease, pnHold, pnStart)
		This._Chain(This.NodeNamed(pName), :env, [pnAttack, pnDecay, pnSustain, pnRelease, pnHold, pnStart])

	def AddEnvelopeOnAtQ(pName, pnAttack, pnDecay, pnSustain, pnRelease, pnHold, pnStart)
		This.AddEnvelopeOnAt(pName, pnAttack, pnDecay, pnSustain, pnRelease, pnHold, pnStart)
		return This

	# ECHO, not "reverb". SN4's challenge pass refused to call a delay a
	# reverb: one repeat fading out is not a diffuse room, and a name that
	# promises a hall and delivers a slapback survives into documentation.
	def AddEchoOn(pName, pnSeconds, pnFeedback, pnWet)
		This._Chain(This.NodeNamed(pName), :delay, [pnSeconds, pnFeedback, pnWet])

	def AddEchoOnQ(pName, pnSeconds, pnFeedback, pnWet)
		This.AddEchoOn(pName, pnSeconds, pnFeedback, pnWet)
		return This

	def AddPanOn(pName, pnPan)
		This._Chain(This.NodeNamed(pName), :pan, [pnPan])

	def AddPanOnQ(pName, pnPan)
		This.AddPanOn(pName, pnPan)
		return This

	#-- mixing --------------------------------------------------------------

	# Mix several named nodes into one. The engine requires every input to
	# EXIST before the mix does -- that is what makes a cycle impossible --
	# so this verb takes them all at once rather than letting you add to a
	# mix later and discover the refusal.
	def AddMixOf(paNames)
		if @nG = 0  return ok
		_m_ = StzEngineSoundGraphAddMix(@nG)
		_n_ = len(paNames)
		for _i_ = 1 to _n_
			_node_ = This.NodeNamed(paNames[_i_])
			if _node_ = 0
				@cLastError = "AddMixOf: no node named '" + paNames[_i_] + "'"
				loop
			ok
			if StzEngineSoundGraphMixAdd(@nG, _m_, _node_) != 0
				@cLastError = StzEngineSoundGraphLastError()
			ok
		next
		@nLast = _m_
		@nOut = _m_

	def AddMixOfQ(paNames)
		This.AddMixOf(paNames)
		return This

	#-- output --------------------------------------------------------------

	# Which node the graph hands to the world. Defaults to the last thing
	# added, which is right far more often than not.
	def SetOutputTo(pName)
		if @nG = 0  return ok
		_n_ = This.NodeNamed(pName)
		if _n_ = 0  return ok
		@nOut = _n_

	def SetOutputToQ(pName)
		This.SetOutputTo(pName)
		return This

	def Prepare()
		if @nG = 0  return FALSE ok
		StzEngineSoundGraphSetOutput(@nG, @nOut)
		if StzEngineSoundGraphIsPrepared(@nG) = 1
			return TRUE
		ok
		if StzEngineSoundGraphPrepare(@nG) != 0
			@cLastError = StzEngineSoundGraphLastError()
			return FALSE
		ok
		return TRUE

	# Render nSeconds and hand back a stzSound. DATA, so To... is right.
	def ToSound(pnSeconds)
		if NOT This.Prepare()  return NULL ok
		_b_ = StzEngineSoundGraphToBuffer(@nG, floor(pnSeconds * @nRate))
		if _b_ = 0
			@cLastError = StzEngineSoundGraphLastError()
			return NULL
		ok
		return StzSoundFromBufferQ(_b_)

	def ToFile(pcPath, pnSeconds)
		if NOT This.Prepare()  return ok
		if StzEngineSoundGraphToFile(@nG, floor(pnSeconds * @nRate), pcPath, 16) != 0
			@cLastError = StzEngineSoundGraphLastError()
		ok

	def ToFileQ(pcPath, pnSeconds)
		This.ToFile(pcPath, pnSeconds)
		return This

	# Rewind every stateful node so the next render starts from the top.
	def Rewind()
		if @nG = 0  return ok
		StzEngineSoundGraphRewind(@nG)

	def RewindQ()
		This.Rewind()
		return This

	#-- hearing it ----------------------------------------------------------

	def PlayFor(pnSeconds)
		if NOT This.Prepare()  return ok
		if NOT StzAudioDevEngineLoaded() or StzEngineAudioDevIsAvailable() = 0
			@cLastError = "no audio device on this machine"
			return
		ok
		_s_ = StzEngineSoundStreamStart(@nG, 16384)
		if _s_ = 0
			@cLastError = StzEngineSoundGraphLastError()
			return
		ok
		sleep(0.12)                     # let the producer get ahead of the device
		_d_ = StzEngineAudioDevPlaybackOpen(StzEngineSoundStreamRingPtr(_s_), 256)
		if _d_ = 0
			@cLastError = StzEngineAudioDevLastError()
			StzEngineSoundStreamStop(_s_)
			return
		ok
		StzEngineAudioDevPlaybackStart(_d_)
		sleep(pnSeconds)
		StzEngineAudioDevPlaybackStop(_d_)
		@nUnderruns = StzEngineSoundStreamUnderruns(_s_)
		StzEngineAudioDevPlaybackClose(_d_)   # consumer first, ALWAYS
		StzEngineSoundStreamStop(_s_)         # then the producer frees the ring

	def PlayForQ(pnSeconds)
		This.PlayFor(pnSeconds)
		return This

	# How many frames the last PlayFor could not supply. Zero is the answer
	# you want, and the plane counts it rather than letting you guess.
	def Underruns()
		return @nUnderruns

	#-- private -------------------------------------------------------------

	# Add a shaper downstream of pnInput and remember it as the last node.
	def _Chain(pnInput, pKind, paArgs)
		if @nG = 0  return ok
		if pnInput = 0
			@cLastError = "that node does not exist"
			return
		ok
		_new_ = 0
		switch pKind
		on :gain
			_new_ = StzEngineSoundGraphAddGain(@nG, pnInput, paArgs[1])
		on :filter
			_new_ = StzEngineSoundGraphAddFilter(@nG, pnInput, paArgs[1], paArgs[2], paArgs[3])
		on :env
			_new_ = StzEngineSoundGraphAddEnvelopeAt(@nG, pnInput,
				paArgs[1], paArgs[2], paArgs[3], paArgs[4], paArgs[5], paArgs[6])
		on :delay
			_new_ = StzEngineSoundGraphAddDelay(@nG, pnInput, paArgs[1], paArgs[2], paArgs[3])
		on :pan
			_new_ = StzEngineSoundGraphAddPan(@nG, pnInput, paArgs[1])
		off
		if _new_ = 0
			@cLastError = StzEngineSoundGraphLastError()
			return
		ok
		@nLast = _new_
		@nOut = _new_

	def _WaveCode(pWave)
		if isNumber(pWave)  return pWave ok
		switch lower("" + pWave)
		on "sine"      return StzSoundWaveSine()
		on "square"    return StzSoundWaveSquare()
		on "saw"       return StzSoundWaveSaw()
		on "sawtooth"  return StzSoundWaveSaw()
		on "triangle"  return StzSoundWaveTriangle()
		off
		@cLastError = "unknown waveform '" + pWave + "' -- use :Sine :Square :Saw :Triangle"
		return StzSoundWaveSine()

	def _FilterCode(pKind)
		if isNumber(pKind)  return pKind ok
		switch lower("" + pKind)
		on "lowpass"   return StzSoundFilterLowPass()
		on "low"       return StzSoundFilterLowPass()
		on "highpass"  return StzSoundFilterHighPass()
		on "high"      return StzSoundFilterHighPass()
		on "bandpass"  return StzSoundFilterBandPass()
		on "band"      return StzSoundFilterBandPass()
		off
		@cLastError = "unknown filter '" + pKind + "' -- use :LowPass :HighPass :BandPass"
		return StzSoundFilterLowPass()
