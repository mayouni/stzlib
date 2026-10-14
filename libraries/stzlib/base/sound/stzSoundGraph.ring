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

# Describes a sound once as nodes joined by name, then renders it to memory or a file, or plays it.
#
# A node is something the graph does, not an object you hold: Add... calls add a node and make it
# the output, NameIt labels the last one, and the ...On calls take a label and build after that
# node. A node may only take inputs that already exist, so a graph cannot loop. Once Prepare,
# ToSound, ToFile or PlayFor has frozen the graph, no node can be added: the Add... calls then do
# nothing and LastError says so. The plain form acts and returns nothing; the Q twin returns the
# graph. ToSound and ToFile render with no audio device; PlayFor is the only method that opens one.
# The sound has not been heard by a person (UNPERCEIVED): it is checked by frame count, sample rate
# and peak level, not by listening.
#
#   receiver   o1 = StzSoundGraphOfQ(1, 22050)
#   example    o1.AddOscillator(:Sine, 440, 0.5)
#              ? o1.NodeCount()
#              #--> 1
#              ? o1.ToSound(0.5).Frames()
#              #--> 11025
#              ? o1.ToSound(0.5).SampleRate()
#              #--> 22050
#   see        stzSound, stzSoundTransport, stzSoundScheduler
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

	# Builds an empty sound graph, stereo at 48000 Hz, to which nodes are added by name.
	#
	#   returns    nothing; the object is built
	#   warning    a library without the sound engine leaves it empty and sets LastError
	#   see        StzSoundGraphQ, Reshape
	def init()
		if NOT StzSoundEngineLoaded()
			@cLastError = "stz_sound.dll is not loaded"
			return
		ok
		@nG = StzEngineSoundGraphNew(@nChannels, @nRate, @nBlock)

	# Frees the graph and starts a new empty one with a different channel count and sample rate.
	#
	#   pnChannels   the number of channels, 1 for mono and 2 for stereo
	#   pnRate       the sample rate in hertz
	#   returns      nothing; use ReshapeQ to chain
	#   warning      only legal before anything is added, since every node and name is forgotten
	#   see          StzSoundGraphOfQ, Release
	#@ aka  Start over with a different shape. Only legal before anything is added.
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

	# Frees the engine graph and leaves the object empty.
	#
	#   returns    nothing
	#   warning    afterwards GraphId and NodeCount answer 0
	#   see        Reshape
	def Release()
		if @nG != 0
			StzEngineSoundGraphFree(@nG)
			@nG = 0
		ok

	# Returns the reason the last call failed, or the engine's last graph error when the face has recorded none.
	#
	#   returns    a text
	#   warning    once the face has recorded an error it keeps returning that one, and a later
	#              success does not clear it
	#   see        Prepare
	def LastError()
		if @cLastError != ""  return @cLastError ok
		return StzEngineSoundGraphLastError()

	# Returns how many nodes the graph holds.
	#
	#   returns    a number
	#   warning    0 for a released graph
	#   see        AddOscillator, GraphId
	def NodeCount()
		if @nG = 0  return 0 ok
		return StzEngineSoundGraphNodeCount(@nG)

	# Returns the engine's id of the graph, to hand to a transport or a stream.
	#
	#   returns    a number; 0 for a released graph
	#   see        Release
	def GraphId()
		return @nG

	# Returns the sample rate of the graph, in hertz.
	#
	#   returns    a number, 48000 until Reshape changes it
	#   see        Channels, Reshape
	def SampleRate()
		return @nRate

	# Returns the number of channels of the graph.
	#
	#   returns    a number, 2 until Reshape changes it
	#   see        SampleRate, Reshape
	def Channels()
		return @nChannels

	# Returns the index of the node the graph hands to the world.
	#
	#   returns    a number; 0 when nothing has been added
	#   warning    a node added after the graph was prepared can reset this to 0, see the defects
	#              file
	#   see        SetOutputTo, AddMasterGain
	#@ aka  Which node the graph currently hands to the world, as an index. A caller rarely needs this; a TRANSPORT does, because it has to reach behind the names and put something after whatever the output turned out to be.
	def OutputNode()
		return @nOut

	# Adds a gain node after the current output and makes it the output, so a pause can fade everything with one ramp.
	#
	#   returns    the index of the new node; 0 when the graph has no output yet or is already
	#              prepared
	#   note       a refusal sets LastError
	#   warning    the node is named master; a transport adds it by itself when built, before the
	#              graph is prepared
	#   see        OutputNode, stzSoundTransport
	#@ aka  A gain node placed AFTER the current output, and made the new output.
	def AddMasterGain()
		if @nG = 0  return 0 ok
		if @nOut = 0
			@cLastError = "AddMasterGain: the graph has no output yet"
			return 0
		ok
		_n_ = StzEngineSoundGraphAddGain(@nG, @nOut, 1.0)
		if _n_ = 0
			@cLastError = StzEngineSoundGraphLastError()
			return 0
		ok
		@nLast = _n_
		@nOut = _n_
		@aNames + [ "master", _n_ ]
		return _n_

	# Labels the last node added so that later calls can refer to it by name.
	#
	#   pcName     the label, kept in lower case
	#   returns    nothing; use NameItQ to chain
	#   warning    with nothing added it sets LastError and labels nothing
	#   see        NodeNamed, HasNode
	#@ aka  -- naming --------------------------------------------------------------
	def NameIt(pcName)
		if @nLast = 0
			@cLastError = "NameIt: nothing has been added yet to name"
			return
		ok
		@aNames + [ lower("" + pcName), @nLast ]

	def NameItQ(pcName)
		This.NameIt(pcName)
		return This

	# Resolves a label or a raw node number to a node index.
	#
	#   pName      the label given to NameIt, matched without regard to case, or a node number
	#   returns    a number; 0 and a LastError for an unknown label; a number is returned as it is,
	#              existing or not
	#   see        NameIt, HasNode
	#@ aka  Resolve a name OR a raw node number to a node index. Unknown names are an error the caller hears about, never a silent 0.
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

	# TRUE if a label resolves to a node.
	#
	#   pName      the label to look for, or a node number
	#   returns    TRUE or FALSE
	#   warning    a number is always TRUE, whether or not that node exists; an unknown label also
	#              sets LastError
	#   see        NodeNamed
	def HasNode(pName)
		return This.NodeNamed(pName) != 0

	# Adds a tone generator as a source and makes it the last node and the output.
	#
	#   pWave         the waveform: Sine, Triangle, Square or Saw
	#   pnHz          the frequency in hertz
	#   pnAmplitude   the peak level, 1 being full scale
	#   returns       nothing; use AddOscillatorQ to chain
	#   note          after the graph is prepared nothing is added, LastError says so, and the
	#                 output index becomes 0
	#   warning       an unknown waveform name sets LastError but still adds a sine
	#   see           NameIt, AddEnvelopeOn
	#@ aka  -- the sources ---------------------------------------------------------
	def AddOscillator(pWave, pnHz, pnAmplitude)
		if @nG = 0  return ok
		@nLast = StzEngineSoundGraphAddOsc(@nG, This._WaveCode(pWave), pnHz, pnAmplitude)
		@nOut = @nLast

	def AddOscillatorQ(pWave, pnHz, pnAmplitude)
		This.AddOscillator(pWave, pnHz, pnAmplitude)
		return This

	# Adds an existing sound as a source that plays once, and makes it the last node and the output.
	#
	#   poSound    a stzSound, or an engine buffer id
	#   returns    nothing; use AddSoundQ to chain
	#   warning    a refusal sets LastError
	#   see        AddLoopingSound, NameIt
	#@ aka  Play an existing sound (a stzSound, or an engine buffer id) as a source.
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

	# Adds an existing sound as a source that repeats for as long as the graph is rendered.
	#
	#   poSound    a stzSound, or an engine buffer id
	#   returns    nothing; use AddLoopingSoundQ to chain
	#   warning    the loop makes a 0.1 s sound fill any length asked of ToSound
	#   see        AddSound
	def AddLoopingSound(poSound)
		if @nG = 0  return ok
		_id_ = poSound
		if isObject(poSound)
			_id_ = poSound.BufferId()
		ok
		@nLast = StzEngineSoundGraphAddSource(@nG, _id_, 1)
		@nOut = @nLast

	# Adds a node whose output is the notes placed on it, each at the frame asked, and makes it the output.
	#
	#   returns    the index of the timeline node; 0 with LastError set when refused
	#   warning    the node has no input; the scheduler and live loops place notes on it through
	#              engine calls
	#   see        stzSoundScheduler, stzSoundLive
	#@ aka  MU2: a node whose output is the notes placed on it, each at the frame asked -- inside a block, not at its top. It has no input. Returns the node (1-based), which StzEngineSoundGraphTimelinePlace takes.
	def AddTimeline()
		if @nG = 0  return 0 ok
		@nLast = StzEngineSoundGraphAddTimeline(@nG)
		if @nLast = 0
			@cLastError = StzEngineSoundGraphLastError()
			return 0
		ok
		@nOut = @nLast
		return @nLast

	def AddLoopingSoundQ(poSound)
		This.AddLoopingSound(poSound)
		return This

	# Adds a gain stage after a node and makes it the output.
	#
	#   pName      the label or number of the node to act on
	#   pnGain     the multiplier, 1 leaving the level unchanged
	#   returns    nothing; use AddGainOnQ to chain
	#   note       it acts on the node the label names, not on the last one added: two calls on the
	#              same label branch from it, so label each new node with NameIt to chain them
	#   warning    an unknown node sets LastError and adds nothing
	#   see        AddPanOn, AddEnvelopeOn
	#@ aka  -- the shapers: each takes WHAT it acts on, by name --------------------
	def AddGainOn(pName, pnGain)
		This._Chain(This.NodeNamed(pName), :gain, [pnGain])

	def AddGainOnQ(pName, pnGain)
		This.AddGainOn(pName, pnGain)
		return This

	# Adds a filter after a node and makes it the output.
	#
	#   pName      the label or number of the node to act on
	#   pKind      the filter type: LowPass, HighPass or BandPass
	#   pnCutoff   the cut-off or centre frequency in hertz
	#   pnQ        the resonance, above 0, 0.7 being a gentle slope
	#   returns    nothing; use AddFilterOnQ to chain
	#   note       a low-pass at 300 Hz brought a 2000 Hz sine down to a peak of 0.01
	#   warning    an unknown filter name sets LastError but still adds a low-pass; a cut-off of 0
	#              or at and above half the rate is refused by the engine and adds nothing
	#   see        AddGainOn, AddEchoOn
	def AddFilterOn(pName, pKind, pnCutoff, pnQ)
		This._Chain(This.NodeNamed(pName), :filter, [This._FilterCode(pKind), pnCutoff, pnQ])

	def AddFilterOnQ(pName, pKind, pnCutoff, pnQ)
		This.AddFilterOn(pName, pKind, pnCutoff, pnQ)
		return This

	# Adds a loudness envelope after a node and makes it the output.
	#
	#   pName       the label or number of the node to act on
	#   pnAttack    the rise time in seconds
	#   pnDecay     the fall time in seconds from the peak to the sustain level
	#   pnSustain   the held level from 0 to 1
	#   pnRelease   the final fall time in seconds
	#   pnHold      the time in seconds, counted from the start, at which the release begins
	#   returns     nothing; use AddEnvelopeOnQ to chain
	#   note        measured: with attack 0.1, decay 0.2, sustain 0.5, release 0.2 and hold 0.5 the
	#               level is 0.5 from 0.3 s to 0.5 s and silent after 0.7 s
	#   warning     an unknown node sets LastError and adds nothing; a sustain above 1 or a negative
	#               time is refused by the engine and adds nothing
	#   see         AddEnvelopeOnAt, AddEchoOn
	def AddEnvelopeOn(pName, pnAttack, pnDecay, pnSustain, pnRelease, pnHold)
		This._Chain(This.NodeNamed(pName), :env, [pnAttack, pnDecay, pnSustain, pnRelease, pnHold, 0])

	def AddEnvelopeOnQ(pName, pnAttack, pnDecay, pnSustain, pnRelease, pnHold)
		This.AddEnvelopeOn(pName, pnAttack, pnDecay, pnSustain, pnRelease, pnHold)
		return This

	# Adds a loudness envelope that starts a number of seconds into the sound, so a voice knows when it sounds.
	#
	#   pName       the label or number of the node to act on
	#   pnAttack    the rise time in seconds
	#   pnDecay     the fall time in seconds from the peak to the sustain level
	#   pnSustain   the held level from 0 to 1
	#   pnRelease   the final fall time in seconds
	#   pnHold      the time in seconds, counted from the start, at which the release begins
	#   pnStart     the time in seconds at which the envelope begins
	#   returns     nothing; use AddEnvelopeOnAtQ to chain
	#   warning     an unknown node sets LastError and adds nothing
	#   see         AddEnvelopeOn
	#@ aka  The same envelope, starting nStart seconds in. THIS is what makes a score possible: a voice that knows WHEN it sounds is a note.
	def AddEnvelopeOnAt(pName, pnAttack, pnDecay, pnSustain, pnRelease, pnHold, pnStart)
		This._Chain(This.NodeNamed(pName), :env, [pnAttack, pnDecay, pnSustain, pnRelease, pnHold, pnStart])

	def AddEnvelopeOnAtQ(pName, pnAttack, pnDecay, pnSustain, pnRelease, pnHold, pnStart)
		This.AddEnvelopeOnAt(pName, pnAttack, pnDecay, pnSustain, pnRelease, pnHold, pnStart)
		return This

	# Adds a single feedback delay after a node and makes it the output.
	#
	#   pName        the label or number of the node to act on
	#   pnSeconds    the delay time in seconds
	#   pnFeedback   the share of each echo fed back into the line, from 0 to below 1
	#   pnWet        the share of the echoes in the output, 0 for none and 1 for echoes only, the
	#                dry sound being scaled by 1 minus pnWet
	#   returns      nothing; use AddEchoOnQ to chain
	#   warning      a feedback of 1 or more, a delay over 60 s or a delay of 0 is refused by the
	#                engine and adds nothing; named an echo and not a reverb because one fading
	#                repeat is not a room
	#   see          AddFilterOn, AddGainOn
	#@ aka  ECHO, not "reverb". SN4's challenge pass refused to call a delay a reverb: one repeat fading out is not a diffuse room, and a name that promises a hall and delivers a slapback survives into documentation.
	def AddEchoOn(pName, pnSeconds, pnFeedback, pnWet)
		This._Chain(This.NodeNamed(pName), :delay, [pnSeconds, pnFeedback, pnWet])

	def AddEchoOnQ(pName, pnSeconds, pnFeedback, pnWet)
		This.AddEchoOn(pName, pnSeconds, pnFeedback, pnWet)
		return This

	# Adds a stereo pan after a node and makes it the output.
	#
	#   pName      the label or number of the node to act on
	#   pnPan      the position from 0 for left to 1 for right, 0.5 being the centre
	#   returns    nothing; use AddPanOnQ to chain
	#   note       the pan is not -1 to 1: -0.5 plays left only and 2 plays right only
	#   warning    an unknown node sets LastError and adds nothing
	#   see        AddGainOn
	def AddPanOn(pName, pnPan)
		This._Chain(This.NodeNamed(pName), :pan, [pnPan])

	def AddPanOnQ(pName, pnPan)
		This.AddPanOn(pName, pnPan)
		return This

	# Adds a mixer that sums several named nodes and makes it the output.
	#
	#   paNames    the labels or numbers of the nodes to mix
	#   returns    nothing; use AddMixOfQ to chain
	#   warning    a name that is not a node is skipped and named in LastError, and the mixer is
	#              still added with the others
	#   see        SetOutputTo, NameIt
	#@ aka  -- mixing --------------------------------------------------------------
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

	# Chooses which node the graph hands to the world, instead of the last one added.
	#
	#   pName      the label or number of the node to use as output
	#   returns    nothing; use SetOutputToQ to chain
	#   warning    an unknown label changes nothing and sets LastError
	#   see        OutputNode
	#@ aka  -- output --------------------------------------------------------------
	def SetOutputTo(pName)
		if @nG = 0  return ok
		_n_ = This.NodeNamed(pName)
		if _n_ = 0  return ok
		@nOut = _n_

	def SetOutputToQ(pName)
		This.SetOutputTo(pName)
		return This

	# Freezes the graph with the chosen output so it can be rendered.
	#
	#   returns    1 if the graph is ready, 0 if not; an empty graph answers 0 and LastError says it
	#              has no nodes
	#   warning    once prepared no node can be added, whatever the call; ToSound, ToFile and
	#              PlayFor call it themselves
	#   see        ToSound, ToFile
	def Prepare()
		if @nG = 0  return 0 ok
		StzEngineSoundGraphSetOutput(@nG, @nOut)
		if StzEngineSoundGraphIsPrepared(@nG) = 1
			return 1
		ok
		if StzEngineSoundGraphPrepare(@nG) != 0
			@cLastError = StzEngineSoundGraphLastError()
			return 0
		ok
		return 1

	# Renders a number of seconds of the graph into memory as a sound.
	#
	#   pnSeconds   how many seconds to render
	#   returns     a stzSound at the graph's rate and channel count; an empty text with LastError
	#               set when the graph cannot be prepared
	#   warning     no audio device is opened; rendering again carries on from where the last render
	#               stopped, so a spent envelope stays silent, unless Rewind is called first; the
	#               sound has not been heard by a person
	#   see         ToFile, Rewind
	#@ aka  Render nSeconds and hand back a stzSound. DATA, so To... is right.
	def ToSound(pnSeconds)
		if NOT This.Prepare()  return "" ok
		_b_ = StzEngineSoundGraphToBuffer(@nG, floor(pnSeconds * @nRate))
		if _b_ = 0
			@cLastError = StzEngineSoundGraphLastError()
			return ""
		ok
		return StzSoundFromBufferQ(_b_)

	# Renders a number of seconds of the graph into a 16-bit WAV file.
	#
	#   pcPath      the file to write, overwritten
	#   pnSeconds   how many seconds to render
	#   returns     nothing; use ToFileQ to chain
	#   warning     the rate and channel count are stored in the file; a failure sets LastError
	#   see         ToSound
	def ToFile(pcPath, pnSeconds)
		if NOT This.Prepare()  return ok
		if StzEngineSoundGraphToFile(@nG, floor(pnSeconds * @nRate), pcPath, 16) != 0
			@cLastError = StzEngineSoundGraphLastError()
		ok

	def ToFileQ(pcPath, pnSeconds)
		This.ToFile(pcPath, pnSeconds)
		return This

	# Takes every stateful node back to its start so the next render begins from the top.
	#
	#   returns    nothing; use RewindQ to chain
	#   warning    a prepared graph stays prepared
	#   see        ToSound
	#@ aka  Rewind every stateful node so the next render starts from the top.
	def Rewind()
		if @nG = 0  return ok
		StzEngineSoundGraphRewind(@nG)

	def RewindQ()
		This.Rewind()
		return This

	# Plays the graph on the audio device for a number of seconds, then closes the device.
	#
	#   pnSeconds   how long to play
	#   returns     nothing; use PlayForQ to chain
	#   note        it blocks the calling thread for the whole time
	#   warning     not run in this reference: it opens an audio device; with no device it sets
	#               LastError and returns
	#   see         ToFile, Underruns
	#@ aka  -- hearing it ----------------------------------------------------------
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

	# Returns how many frames the last PlayFor could not supply.
	#
	#   returns    a number; 0 is the answer to want, and 0 before any PlayFor
	#   see        PlayFor
	#@ aka  How many frames the last PlayFor could not supply. Zero is the answer you want, and the plane counts it rather than letting you guess.
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
