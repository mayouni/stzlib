# SN6, HEARD -- a transport you can interrupt, and a pool you can play.
#
#     cd libraries/stzlib/base/test/sound
#     ring sound_transport_demo.ring
#
# A guard proves the numbers. Only playing it proves the sound, so every phase
# of this plane ships one of these.
#
# THREE THINGS TO LISTEN FOR:
#
#   1  the pause is SILENT. Not a click, not a thud -- the master gain ramps
#      over 10 ms first, which is the difference plate 2 of the gallery draws
#      as a stripe across every frequency.
#   2  the resume CONTINUES. The chord is where you left it, not back at its
#      beginning, and the clock printed alongside says the same.
#   3  the pool OVERLAPS. The last passage fires notes faster than they decay,
#      and you can hear them stack -- one graph, built once, eight slots.

load "../../stzBase.ring"
decimals(2)

? ""
? "=== SN6: A TRANSPORT, AND A POOL ==="
? ""

if NOT StzSoundEngineLoaded() or NOT StzAudioDevEngineLoaded() or
   StzEngineAudioDevIsAvailable() != 1
	? "No output device on this machine -- there is nothing to hear."
	bye
ok

# ---------------------------------------------------------------------------
? "1. A CHORD YOU CAN INTERRUPT"
? "   Three notes, held. Watch the clock, and listen to the pause."

oG = new stzSoundGraph()
oG.Reshape(2, 48000)
aHz = [ 261.63, 329.63, 392.00 ]           # C major, held
aNames = [ :c, :e, :g ]
for i = 1 to 3
	oG.AddOscillator(:Triangle, aHz[i], 0.22)
	oG.NameIt(aNames[i])
	oG.AddEnvelopeOn(aNames[i], 0.08, 0.2, 0.85, 0.3, 60)
	aNames[i] = "" + aNames[i] + "v"
	oG.NameIt(aNames[i])
next
oG.AddMixOf(aNames)
oG.AddEchoOn(oG.OutputNode(), 0.30, 0.35, 0.30)

oT = new stzSoundTransport(oG)
oT.OnStarted(func { ? "   [started]" })
oT.OnFinished(func { ? "   [finished]" })

oT.Play()
if NOT oT.IsPlaying()
	? "   could not start: " + oT.LastError()
	bye
ok

for i = 1 to 6
	sleep(0.25)
	oT.Tick()
	? "   playing ... " + oT.PositionInSeconds() + "s"
next

? ""
? "   -- pausing (listen: no click) --"
oT.Pause()
sleep(1.2)
? "   paused at " + oT.PositionInSeconds() + "s. Silence. The clock is still."

? "   -- resuming (it continues; it does not restart) --"
oT.Resume()
for i = 1 to 6
	sleep(0.25)
	oT.Tick()
	? "   playing ... " + oT.PositionInSeconds() + "s"
next
oT.Stop()
? "   underruns: " + oT.Underruns()
oT.Release()
oG.Release()

# ---------------------------------------------------------------------------
? ""
? "2. A POOL, PLAYED"
? "   Eight slots on one graph, built once. The device opened before the"
? "   first note, not during it -- opening one costs half a second, and"
? "   half a second is forty frames of a game."

oPool = new stzVoicePool(48000)
oPool.AddToneVoice(:blip, :Square, 880, 0.09, 4)
oPool.AddToneVoice(:low, :Triangle, 220, 0.30, 2)
oPool.AddToneVoice(:tick, :Sine, 1760, 0.04, 2)
oPool.Start()
if NOT oPool.IsStarted()
	? "   could not start the pool: " + oPool.LastError()
	bye
ok

? ""
? "   a) one at a time, comfortably within the slots"
for i = 1 to 6
	oPool.Fire(:blip)
	sleep(0.22)
next
sleep(0.3)
? "      " + oPool.FiresOf(:blip) + " fires, " + oPool.StealsOf(:blip) + " steals"

? ""
? "   b) a little rhythm -- three voices at once"
aPattern = [ :blip, :tick, :blip, :low, :tick, :blip, :tick, :low ]
for r = 1 to 3
	for i = 1 to len(aPattern)
		oPool.Fire(aPattern[i])
		sleep(0.13)
	next
next
sleep(0.4)

? ""
? "   c) FASTER THAN THEY DECAY -- this is where slots run out"
for i = 1 to 14
	oPool.Fire(:low)                     # 0.30 s shots, only 2 slots
	sleep(0.07)
next
sleep(0.5)
? "      low: " + oPool.FiresOf(:low) + " fires, " + oPool.StealsOf(:low) +
  " steals -- each steal is a note cut short so a newer one could sound"

? ""
? "   position on the shared clock: " + oPool.PositionInSeconds() + "s"
? "   underruns: " + oPool.Underruns()
oPool.Release()

? ""
? "done."
