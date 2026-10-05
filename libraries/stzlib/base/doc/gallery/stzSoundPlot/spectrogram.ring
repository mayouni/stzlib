# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzSoundPlot/spectrogram.ring
# A one second sweep from 200 Hz to 4000 Hz drawn as a spectrogram: time across, frequency up, loudness as brightness.
load "../../stzBase.ring"

oSnd = StzSoundOfSilenceQ(1, 1, 48000)
nPh = 0
nN = oSnd.Frames()
for i = 1 to nN
	nHz = 200 + (4000 - 200) * (i - 1) / nN
	nPh += 2 * 3.14159265358979 * nHz / 48000
	oSnd.SetSampleAt(i, 1, 0.7 * sin(nPh))
next
oGrid = oSnd.ToSpectrogram()

oPlot = new stzSoundPlot(800, 420)
oPlot.SetTitle("A rising sweep", "200 Hz to 4000 Hz in one second")
oPlot.SetNote("The bright line climbs from the bottom to the top: the pitch rises steadily.")
oPlot.DrawSpectrogram(oGrid, 6000)
oPlot.SaveAsPNG("../../doc/gallery/stzSoundPlot/spectrogram.png")
? "done"
