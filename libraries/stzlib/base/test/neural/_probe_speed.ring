# _probe_speed.ring -- A4: what does the decoder cost on THIS CPU?   ring _probe_speed.ring <model-needle> [prompt-sentences] [gen-tokens]
#
# Measures, with the generator's own tokenizer, (1) PREFILL of a prompt of about 500 tokens and (2) the decode of
# <gen-tokens> new tokens, each as tokens per second and as a MINIMUM over three repetitions (the project's rule:
# minima over repetitions; a single wall time on this machine is not a measurement). Run `python bench/heartbeat.py`
# before AND after and record the CPU's state beside the numbers: while the firmware holds the CPU under its nominal
# speed (exit 1) these are THROTTLED numbers and are reported as such. Nothing else heavy may be running.

load "../../stzBase.ring"
load "_modelpick.ring"

cNeedle = sysargv[3]
nSent = 33
nGen = 100
if len(sysargv) >= 4 nSent = 0 + sysargv[4] ok
if len(sysargv) >= 5 nGen = 0 + sysargv[5] ok

if _mpLoad(cNeedle) = 0 ? "NOLOAD " + cNeedle bye ok
cPrompt = _mpSecretPrompt(nSent)
nTok = StzTokenCount(cPrompt)
? "model " + cNeedle + "  prompt tokens " + nTok + "  decode tokens " + nGen

nBestPre = 1000000000
nBestDec = 1000000000
for rep = 1 to 3
	# PREFILL: one token generated, so the time is the prompt's
	t0 = clock()
	StzGenerate(cPrompt, 1)
	nPre = (clock() - t0) / clockspersecond()
	if nPre < nBestPre nBestPre = nPre ok
	# DECODE: a short prompt, many tokens (a counting task the model keeps going on), prefill cost subtracted
	cShort = StzChatPrompt("", "Count from 1 to 200, separated by commas, with nothing else.")
	t0 = clock()
	StzGenerate(cShort, 1)
	nShortPre = (clock() - t0) / clockspersecond()
	t0 = clock()
	cOut = StzGenerate(cShort, nGen)
	nAll = (clock() - t0) / clockspersecond()
	nDec = nAll - nShortPre
	if nDec < nBestDec nBestDec = nDec ok
next
? "prefill: best " + nBestPre + " s for " + nTok + " tokens = " + (nTok / nBestPre) + " tokens/s"
? "decode:  best " + nBestDec + " s for about " + nGen + " tokens = " + (nGen / nBestDec) + " tokens/s"
