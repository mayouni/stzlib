load "../../stzBase.ring"
decimals(2)

# CAN SOFTANZA DRAW A CONNECTOME? -- a procedural neural arbor, bilaterally
# symmetric, thousands of thin curved filaments in four tract colours with
# synaptic boutons clustered at the crown, composited with alpha on white and
# rendered SUPERSAMPLED so the hairlines stay crisp.
#
# No bezier primitive is needed: a neuron skeleton IS a sequence of points, so
# each branch is integrated as a gently-curving polyline -- the same machinery
# the geo plane's streamlines use. Symmetry is exact: the right hemisphere is
# generated, then its coordinates are mirrored to make the left.

PI = 3.14159265
nSeed = 20260926
cx = 750

# tract colours (base) and the brighter bouton fills, indexed 1..4
aCol   = [ "#1E56E8", "#E8940F", "#8E3FD0", "#12AEDC" ]   # blue orange purple cyan
aColZ  = [ 4, 3, 2, 1 ]                                    # blue drawn last (front)
aBrite = [ "#3E86FF", "#FFC021", "#C24BFF", "#1AD8F2" ]

aStrokes = []    # each: [ flatPoints, hex6, alphaHex, width, z ]
aTips    = []    # each: [ x, y, colIdx ]

# roots of the right hemisphere: x, y, angleDeg (90=up), length, width, depth, colIdx
aRoots = [
	[ cx+4,  940,  96, 205, 3.0, 6, 1 ],
	[ cx+18, 900,  74, 205, 2.7, 6, 2 ],
	[ cx+34, 850,  58, 215, 2.5, 6, 3 ],
	[ cx+52, 800,  44, 225, 2.3, 6, 4 ],
	[ cx+16, 820,  86, 195, 2.4, 6, 1 ],
	[ cx+40, 760,  50, 205, 2.2, 6, 2 ],
	[ cx+66, 730,  34, 195, 2.0, 6, 4 ],
	[ cx+12, 700,  94, 205, 2.2, 6, 3 ],
	[ cx+26, 620,  90, 205, 2.0, 6, 1 ],
	[ cx+8,  990, -84, 155, 2.6, 6, 1 ],
	[ cx+30, 1000,-66, 145, 2.2, 5, 4 ]
]

# --- grow the arbor by an explicit work stack (all state at top scope) ------
aQueue = []
nR = len(aRoots)
for i = 1 to nR  aQueue + aRoots[i]  next

while len(aQueue) > 0
	nQ = len(aQueue)
	job = aQueue[nQ]  del(aQueue, nQ)          # pop from the back
	x = job[1]  y = job[2]  ang = job[3] * PI / 180
	blen = job[4]  wid = job[5]  depth = job[6]  ci = job[7]

	nSteps = floor(blen / 15)
	if nSteps < 4  nSteps = 4  ok
	sl = blen / nSteps
	nSeed = (nSeed * 1103515245 + 12345) % 2147483648
	curl = (nSeed / 2147483648 - 0.5) * 0.9    # a constant per-branch arc

	pts = [ x, y ]
	for s = 1 to nSteps
		nSeed = (nSeed * 1103515245 + 12345) % 2147483648
		noise = (nSeed / 2147483648 - 0.5) * 0.10
		ang += curl / nSteps + noise
		x += cos(ang) * sl
		y -= sin(ang) * sl                     # screen y grows down; up = minus
		pts + x  pts + y
	next

	aStrokes + [ pts, aCol[ci], "AA", wid, aColZ[ci] ]

	if depth > 0 and wid > 0.55 and len(aStrokes) < 5200
		nSeed = (nSeed * 1103515245 + 12345) % 2147483648
		nKids = 2 + ((nSeed / 2147483648) < 0.30)
		for k = 1 to nKids
			nSeed = (nSeed * 1103515245 + 12345) % 2147483648
			off = (nSeed / 2147483648 - 0.5) * 0.95
			childAng = (ang + off - 0.05) * 180 / PI    # slight outward bias
			nSeed = (nSeed * 1103515245 + 12345) % 2147483648
			lf = 0.62 + (nSeed / 2147483648) * 0.22
			aQueue + [ x, y, childAng, blen * lf, wid * 0.72, depth - 1, ci ]
		next
	else
		aTips + [ x, y, ci ]
	ok
end

# --- mirror the right hemisphere to the left, exactly --------------------
nS = len(aStrokes)
for i = 1 to nS
	s = aStrokes[i]
	p = s[1]  mp = []
	nP = len(p)
	for j = 1 to nP step 2
		mp + (2 * cx - p[j])
		mp + p[j + 1]
	next
	aStrokes + [ mp, s[2], s[3], s[4], s[5] ]
next
nT = len(aTips)
for i = 1 to nT
	t = aTips[i]
	aTips + [ 2 * cx - t[1], t[2], t[3] ]
next

# --- render: strokes back-to-front by colour, boutons on top -------------
nW = 1500  nH = 1100
oC = new stzCanvas(nW, nH)
oC.SetBackground("#FFFFFF")

for z = 1 to 4
	nAll = len(aStrokes)
	for i = 1 to nAll
		s = aStrokes[i]
		if s[5] = z
			oC.AddPolylineQ(s[1]).Stroke(s[2] + s[3], s[4])
		ok
	next
next
oC.Flush()

nBout = 0
nAllT = len(aTips)
for i = 1 to nAllT
	t = aTips[i]
	x = t[1]  y = t[2]  ci = t[3]
	place = 0  rad = 0
	if y < 350 and fabs(x - cx) < 210
		nSeed = (nSeed * 1103515245 + 12345) % 2147483648
		rad = 4 + (nSeed / 2147483648) * 5.5
		place = 1
	else
		nSeed = (nSeed * 1103515245 + 12345) % 2147483648
		if (nSeed / 2147483648) < 0.18
			nSeed = (nSeed * 1103515245 + 12345) % 2147483648
			rad = 2.4 + (nSeed / 2147483648) * 2.2
			place = 1
		ok
	ok
	if place
		oC.AddCircleQ(x, y, rad).FillQ(aBrite[ci]).Stroke("#FFFFFF55", 0.6)
		oC.AddCircleQ(x - rad * 0.3, y - rad * 0.3, rad * 0.34).FillQ("#FFFFFFAA").Stroke("#00000000", 0)
		nBout++
	ok
next
oC.Flush()

oC.ToPNGHiRes("connectome.png")
? "-> connectome.png"
? "   strokes " + len(aStrokes) + ", tips " + len(aTips) + ", boutons " + nBout
