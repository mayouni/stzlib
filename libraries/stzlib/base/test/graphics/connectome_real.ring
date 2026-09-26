load "../../stzBase.ring"
decimals(3)

# REAL DATA. Eight neuron reconstructions in the standard SWC format, downloaded
# from NeuroMorpho.org (Wearne/Hof monkey neocortex "cnic" pyramidal cells, a
# Markram rat-cortex cell, and the NeuroM reference neuron). Each SWC node is
#   id  type  x y z  radius  parent
# and every node but the root draws one segment to its parent -- the morphology
# IS a point graph, so polylines are the honest primitive. We fan the eight
# cells around a shared origin, one colour each, boutons at the dendritic tips,
# and render supersampled on white.

PI = 3.14159265

aFiles = [ "nm_cnic_006.swc", "nm_cnic_003.swc", "nm_cnic_005.swc", "nm_cnic_001.swc",
           "nm_C010398B-P2.swc", "nm_cnic_002.swc", "nm_cnic_004.swc", "n_neurom.swc" ]
aColH  = [ "#1E56E8", "#E8940F", "#8E3FD0", "#12AEDC",
           "#2E7BFF", "#E0A81E", "#B04BE0", "#17B7DE" ]
aBriteH= [ "#3E86FF", "#FFC021", "#C24BFF", "#1AD8F2",
           "#5A96FF", "#FFCE3A", "#D06BFF", "#2CE0F5" ]
aAng   = [ 0, -22, 22, -44, 44, -64, 64, 80 ]   # degrees the cell is fanned by

# the SWC data is NOT vendored -- like the geo atlas, you bring your own.
# connectome_DATA.md carries the one-line fetch for every file below.
for i = 1 to len(aFiles)
	if NOT fexists(aFiles[i])
		? "SKIPPED, by name: " + aFiles[i] + " not present -- see connectome_DATA.md for the fetch."
		return
	ok
next

# --- read every cell (each carries its own robust radius) ------------------
aCells = []
nFiles = len(aFiles)
for i = 1 to nFiles  aCells + ReadSwc(aFiles[i])  next   # [ edges, leaves, robustR ]
nseed = 20260926

nW = 1500  nH = 1080
Cx = 750   Cy = 560
oC = new stzCanvas(nW, nH)
oC.SetBackground("#FFFFFF")

# --- draw each cell, rotated into its place --------------------------------
aScreenLeaves = []
for i = 1 to nFiles
	th = aAng[i] * PI / 180
	ct = cos(th)  st = sin(th)
	dx = aAng[i] * 2.4                      # wider soma spread
	dy = fabs(aAng[i]) * 0.6                # outer cells sit lower -> a fan base
	scale = 300 / aCells[i][3]              # each cell to a common visual size
	col = aColH[i] + "96"
	edges = aCells[i][1]
	ne = len(edges)
	for e = 1 to ne
		ed = edges[e]
		X1 = Cx + dx + (ed[1] * ct - ed[2] * st) * scale
		Y1 = Cy + dy - (ed[1] * st + ed[2] * ct) * scale
		X2 = Cx + dx + (ed[3] * ct - ed[4] * st) * scale
		Y2 = Cy + dy - (ed[3] * st + ed[4] * ct) * scale
		oC.AddLineQ(X1, Y1, X2, Y2).Stroke(col, 0.8)
	next
	# project this cell's tips into screen space for boutons
	lv = aCells[i][2]
	nl = len(lv)
	for k = 1 to nl
		lx = Cx + dx + (lv[k][1] * ct - lv[k][2] * st) * scale
		ly = Cy + dy - (lv[k][1] * st + lv[k][2] * ct) * scale
		aScreenLeaves + [ lx, ly, i ]
	next
next
oC.Flush()

# --- boutons: dense at the crown, sparse elsewhere -------------------------
nBout = 0
nL = len(aScreenLeaves)
for k = 1 to nL
	t = aScreenLeaves[k]
	x = t[1]  y = t[2]  ci = t[3]
	place = 0  rad = 0
	if y < 500 and fabs(x - Cx) < 430
		nseed = (nseed * 1103515245 + 12345) % 2147483648
		rad = 3.5 + (nseed / 2147483648) * 5
		place = 1
	else
		nseed = (nseed * 1103515245 + 12345) % 2147483648
		if (nseed / 2147483648) < 0.16
			nseed = (nseed * 1103515245 + 12345) % 2147483648
			rad = 2.2 + (nseed / 2147483648) * 2
			place = 1
		ok
	ok
	if place
		oC.AddCircleQ(x, y, rad).FillQ(aBriteH[ci]).Stroke("#FFFFFF55", 0.6)
		oC.AddCircleQ(x - rad * 0.3, y - rad * 0.3, rad * 0.34).FillQ("#FFFFFFAA").Stroke("#00000000", 0)
		nBout++
	ok
next
oC.Flush()

oC.ToPNGHiRes("connectome_real.png")
? "-> connectome_real.png"
nTotE = 0
for i = 1 to nFiles  nTotE += len(aCells[i][1])  next
? "   " + nFiles + " real neurons, " + nTotE + " segments, " + nBout + " boutons"

# ============================================================================
# THE SWC READER -- parse one .swc file into [ edges, leaf tips, extent ],
# all soma-centred. ~15 lines of actual parsing.
func ReadSwc cPath
	aRaw = StzSplit(read(cPath), char(10))
	aN = []  nMax = 0  nR = len(aRaw)
	for i = 1 to nR
		cL = trim(aRaw[i])
		if cL = "" or left(cL, 1) = "#"  loop  ok
		cL = StzReplace(cL, char(9), " ")
		aF = StzSplit(cL, " ")  aG = []  nF = len(aF)
		for f = 1 to nF  if aF[f] != ""  aG + aF[f]  ok  next
		if len(aG) < 7  loop  ok
		nId = 0 + aG[1]
		aN + [ nId, 0 + aG[3], 0 + aG[4], 0 + aG[7] ]      # id, x, y, parent
		if nId > nMax  nMax = nId  ok
	next
	# index x, y and parenthood by node id
	aX = list(nMax)  aY = list(nMax)  aChild = list(nMax)  nN = len(aN)
	for i = 1 to nN  aX[ aN[i][1] ] = aN[i][2]  aY[ aN[i][1] ] = aN[i][3]  next
	sx = aN[1][2]  sy = aN[1][3]
	aEdges = []  aDist = []
	for i = 1 to nN
		par = aN[i][4]
		if par >= 1
			aEdges + [ aN[i][2] - sx, aN[i][3] - sy, aX[par] - sx, aY[par] - sy ]
			aChild[par] = 1
		ok
		aDist + sqrt(pow(aN[i][2] - sx, 2) + pow(aN[i][3] - sy, 2))
	next
	aLeaves = []
	for i = 1 to nN
		if aChild[ aN[i][1] ] = 0  aLeaves + [ aN[i][2] - sx, aN[i][3] - sy ]  ok
	next
	# robust radius: 80th percentile distance, so one long axon does not set the scale
	aDist = sort(aDist)
	robust = aDist[ floor(len(aDist) * 0.80) ]
	if robust <= 0  robust = aDist[len(aDist)]  ok
	return [ aEdges, aLeaves, robust ]
