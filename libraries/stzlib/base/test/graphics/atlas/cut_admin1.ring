load "../../stzBase.ring"
decimals(1)
cBig = read("atlas/_ne10_admin1.json")
? "the world's admin-1 file: " + (len(cBig) / 1048576) + " MB"
aWant = [ [ "NE", "niger" ], [ "TN", "tunisia" ], [ "FR", "france" ] ]
for i = 1 to len(aWant)
	nT = clock()
	c = StzEngineJsonFilterFeatures(cBig, "iso_a2", aWant[i][1])
	write("atlas/admin1_" + aWant[i][2] + ".geojson", c)
	o = StzGeoFeaturesFromJson(c)
	? aWant[i][2] + ": " + o.Count() + " units, " + len(c) + " bytes, cut in " +
	  ((clock()-nT)/clockspersecond()) + " s"
	nShow = o.Count()
	if nShow > 4  nShow = 4  ok
	for k = 1 to nShow
		? "    " + o.NameOf(k) + "   parts " + o.PartCount(k)
	next
next
