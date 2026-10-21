# Probe: ring _probe_rss.ring <model-needle> <filler-sentences> [max-new]
# Loads the model, asks the secret-word probe, prints tokens, answer and the pool the graph asked for.
# Wrap it in a process-memory meter (peak working set) to read what a prompt costs a model.
load "../../stzBase.ring"
load "_modelpick.ring"
cNeedle = sysargv[3]
nFill = 0 + sysargv[4]
nMax = 4
if len(sysargv) >= 5 nMax = 0 + sysargv[5] ok
if _mpLoad(cNeedle) = 0 ? "NOLOAD" bye ok
aR = _mpAsk(nFill, nMax)
? "tokens=" + aR[1] + " answer=[" + aR[2] + "]"
