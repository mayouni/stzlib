# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzSoundPlot/spectra.ring
# Two tones, a loud 220 Hz and a quiet 880 Hz, as two spectra on one log-frequency axis, with a marker.
load "../../stzBase.ring"

oLoud = MakeTone(220, 0.4, 0.5)
oQuiet = MakeTone(880, 0.4, 0.1)
oSpecLoud = oLoud.ToSpectrumOf(1, 1000, 8192)
oSpecQuiet = oQuiet.ToSpectrumOf(1, 1000, 8192)

oPlot = new stzSoundPlot(800, 380)
oPlot.SetTitle("Two tones", "one loud, one a fifth the size")
oPlot.SetNote("Both are measured against the loudest peak, so the quiet tone sits about 14 dB lower.")
oPlot.DrawSpectra([ [ "220 Hz", oSpecLoud ], [ "880 Hz", oSpecQuiet ] ], 100, 8000)
oPlot.MarkFrequencyAt(440, 100, 8000, "440 Hz")
oPlot.SaveAsPNG("../../doc/gallery/stzSoundPlot/spectra.png")
? "done"

func MakeTone nHz, nSecs, nAmp
	oS = StzSoundOfSilenceQ(nSecs, 1, 48000)
	nN = oS.Frames()
	for i = 1 to nN
		oS.SetSampleAt(i, 1, nAmp * sin(2 * 3.14159265358979 * nHz * (i - 1) / 48000))
	next
	return oS
