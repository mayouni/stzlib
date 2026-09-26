# MU4 -- THE UNIVERSES, HEARD. Run it and listen.
#
#     cd libraries/stzlib/base/test/sound
#     ring sound_mu4_demo.ring
#
# One phrase -- "1 2 3 4 5 4 3 2", written in DEGREES -- played inside every
# declared universe, over that universe's own cycle, on its own instrument,
# with its own ornaments. Each is written to a WAV (mu4_NN_*.wav) and then
# played live. Before each, the console prints what to listen for and how
# sure the declaration is -- because for some of these, the person listening
# knows more than every source this library found.
#
# THE VERDICT THIS PHASE NEEDS is not "does it sound nice": it is, from someone
# who knows the tradition, "that is (or is not) Rast / Dhil / Yaman / slendro".
# Their name and word go into the MU4 STATUS. Until then: UNPERCEIVED.

load "../../stzBase.ring"

pr()
decimals(1)
cPhrase = "1 2 3 4 5 4 3 2"

aPieces = [
	[ "mu4_01_western_major", :western, :major, "", 2, "the default everyone else escapes" ],
	[ "mu4_02_maqam_rast", :maqam, :rast, "", 2, "the half-flat third (350 cents) -- not major, not minor" ],
	[ "mu4_03_maqam_hijaz", :maqam, :hijaz, "", 2, "the augmented second between degrees 2 and 3" ],
	[ "mu4_04_tunisian_dhil", :tunisian, :dhil, "btayhi", 2, "Snoussi's Dhil over btayhi -- on paper Rast's skeleton; does it sound like Dhil to you, or like Rast?" ],
	[ "mu4_05_tunisian_sika_hijaz", :tunisian, :sika_hijaz, "btayhi", 2, "Sika with the 'Tunisian hijaz' on top -- the documented Tunisian difference" ],
	[ "mu4_06_tunisian_rasd_aldhil", :tunisian, :rasdaldhil, "barwal", 4, "Rasd al-Dhil (Snoussi's f-half-sharp) over barwal, fast" ],
	[ "mu4_07_niger_zarma_tende", :niger, :zarma, "tende", 2, "every note SLID into, over the tende n-emnas -- the scale is a placeholder" ],
	[ "mu4_09_raga_yaman_teental", :raga, :yaman, "teental", 1, "Yaman, meends into Re Ga and Ma, over teental -- listen for khali's missing bass" ],
	[ "mu4_10_gamelan_slendro", :gamelan, :slendro, "lancaran", 1, "slendro averaged over 30 gamelans, stretched octave, lancaran" ],
	[ "mu4_11_gamelan_kanyutmesem", :gamelan, :kanyutmesem, "lancaran", 1, "the SAME phrase on one real gamelan -- 18 cents flatter on nem" ],
	[ "mu4_12_gamelan_paired", :gamelan, :slendro_paired, "lancaran", 1, "pairs 6 Hz apart, beating -- Balinese practice on a Javanese scale, stated" ],
	[ "mu4_13_westafrican_timeline", :westafrican, "", "standard", 3, "the bell alone: the phrase is REFUSED, this universe declares no scale" ],
	[ "mu4_14_flamenco_solea", :flamenco, :phrygian, "solea", 2, "solea's compas, accents 3 6 8 10 12, the third raised up and natural down" ] ]

? "=================================================================="
? " MU4 -- one phrase, " + char(34) + cPhrase + char(34) + ", in eight universes"
? "=================================================================="
bLive = StzAudioDevEngineLoaded() and StzEngineAudioDevIsAvailable() = 1
for p in aPieces
	o = StzSoundUniverseQ(p[2])
	if "" + p[3] != ""  o.Mode(p[3]) ok
	if p[4] != ""  o.Cycle(p[4]) ok
	oS = o.PerformQ(cPhrase, p[5])
	? ""
	? "-- " + p[1] + "   " + o.Title() + " / " + o.ModeName() + " / " + o.CycleName()
	? "   listen for: " + p[6]
	if o.LastError() != ""  ? "   (" + o.LastError() + ")" ok
	? "   confidence: " + o._Get(o.Declaration(), :confidence, "")
	oSnd = oS.ToSound()
	oSnd.SaveAs(p[1] + ".wav")
	? "   written: " + oSnd.Duration() + " s"
	if bLive  oS.Play() ok
next

? ""
? "-- mu4_08_niger_kalangu: 'sannu da zuwa' (welcome), L H L H L, on the kalangu"
oNig = StzSoundUniverseQ(:niger)
oKal = oNig.SentenceQ("sannu da zuwa")
oKal.ToSound().SaveAs("mu4_08_niger_kalangu.wav")
? "   " + oNig._Get(oNig.Declaration(), :tonewhy, "")
if bLive  oKal.Play() ok

? ""
? "Tell me, for any tradition you know: is it that mode -- or which part is"
? "wrong? For Tunisia: does 04 sound like Dhil, or like Rast? That is the"
? "one question the sources could not answer, and the MU4 STATUS records"
? "whoever answers it, by name."
