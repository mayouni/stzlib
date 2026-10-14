# Wave 14 (agent w14s) defects: stzSoundScore, stzSoundScoreRenderer, stzSound, stzSoundLive, stzSoundUniverse, stzSoundGraph, stzSoundTransport, stzVoice, stzListener, stzMusic, stzSoundScheduler, stzSoundStaff

Found by calling every root method that can be called without an audio device, with invented data (short note strings, a generated sine and click track, the machine's own voices, the shipped universes). Each defect was confirmed with a second dataset. Nothing was fixed. Each is recorded as a warning in the doc block of the method. No audio device or microphone was opened; the sound has not been heard by a person (UNPERCEIVED), and the numbers below are frame counts, rates and peaks.

## stzSoundLive (sound/stzSoundLive.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| WaitCycles (capture mode, after CaptureInsteadOfDevice) | never returns when the wait runs past the capture length; no error, the thread spins | `_Drain` clamps to the room left in the capture buffer, so `@nHeard` stops at the buffer length and `While HeardFrames() < target` can never end; unpaced mode has no sleep in that branch | a 7 s capture with 1, 2, 1 and 1 cycles asked in turn at 120 bpm (8 s in all): the last wait hung; 3 s capture, `WaitCycles(2)` (4 s) at 120 bpm: no return after 25 s. Both stopped by killing the process |
| Landings, ConsoleLog, Ledger (version numbers) | the version of a loop can go back: `cycle 1 \| tune v3` then `cycle 2 \| tune v2` | `_Land` before the start resets the version list and numbers from the last version plus one; while running it numbers from `len(list) + 1` | `tune` defined three times before Start, then redefined once while running: landings `[ tune 1 ], [ tune 2 ], [ tune 3 ], [ tune 2, landing 2, heard 1 ]`; a second case with `Hush()` before Start gave `tune v3` then `tune v2` too |

## stzSoundGraph (sound/stzSoundGraph.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| AddOscillator, AddLoopingSound, AddSound (after Prepare, ToSound, ToFile or PlayFor) | nothing is added, but OutputNode() becomes 0 and the engine's refusal is not checked | the face stores the engine's 0 in `@nLast` and `@nOut` without testing it (AddGainOn and the other shapers do test it) | graph prepared, then `AddOscillator(:Sine, 880, 0.5)`: NodeCount stays 1, OutputNode 0, LastError "cannot add nodes after Prepare"; the render that follows still plays the first oscillator (peak 0.50, 438.74 Hz) |
| AddOscillator, AddFilterOn | an unknown waveform or filter name sets LastError but a node is still added (a sine, a low-pass) | the name lookup falls back instead of refusing | `AddOscillator(:wiggle, ...)` and `AddFilterOn(:tone, :wobble, ...)` each added a node |
| LastError | once set it is never cleared, even by a later success | `LastError()` returns the face's text whenever it is not empty and nothing resets it | after `NameIt` on an empty graph, every later call, however well it went, still answers "NameIt: nothing has been added yet to name" |

## stzVoice (sound/stzVoice.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| LastError after ToSoundOf | a stale message survives a render that worked | a render that succeeds does not clear `@cLastError` | `ToSoundOfSsml` with an unclosed tag was refused; the next `ToSoundOf("")` returned a sound but LastError still gave the SSML message (UseVoice and UseLanguage do clear it) |
| UseVoice (error text) | the error names a voice one less than the position given | the engine counts from 0, the face from 1, and the engine's text is passed through | `UseVoice(99)` answered "cannot select voice 98" |

## stzMusic (sound/stzMusic.ring)

No defect found. Note: Tempo, With and Swing do not reach PhraseToSound or PlayPhrase, which use the chosen universe's own speed and instrument (read from the code and seen in the durations; this is stated in the doc blocks, not claimed as a bug).

## Not exercised, and why

stzSound.Play and PlayFor, stzSoundScore.Play, stzSoundScheduler.Play and the device path of Tick, stzSoundTransport.Play, PlayFor, Resume, RunFor and the playing paths of Pause, Stop, Tick and RunToEnd, stzSoundGraph.PlayFor, stzSoundLive.Start/WaitCycles/DriveWith without capture mode, stzVoice.Say and ToTransportOf, stzMusic.Play and PlayPhrase, stzListener.HearMicrophoneFor: each opens an audio device or the microphone and was read from the code only (reported `not run`).
