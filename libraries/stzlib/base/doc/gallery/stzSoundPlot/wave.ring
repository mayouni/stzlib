# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzSoundPlot/wave.ring
# Two tones a few hertz apart (440 Hz and 444 Hz) added together: the waveform swells and fades four times a second.
load "../../stzBase.ring"

oSnd = StzSoundOfSilenceQ(1, 1, 48000)
nN = oSnd.Frames()
for i = 1 to nN
	nT = (i - 1) / 48000
	oSnd.SetSampleAt(i, 1, 0.4 * sin(2 * 3.14159265358979 * 440 * nT) + 0.4 * sin(2 * 3.14159265358979 * 444 * nT))
next

oPlot = new stzSoundPlot(800, 340)
oPlot.SetTitle("Beats", "440 Hz plus 444 Hz")
oPlot.SetNote("The envelope pulses four times in the second: the difference of the two frequencies.")
oPlot.DrawWave(oSnd)
oPlot.MarkTimeAt(0.5, 1, "half way")
oPlot.SaveAsPNG("../../doc/gallery/stzSoundPlot/wave.png")
? "done"
