load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	GG3 -- PARENT AND CHILD

	Until now stzScene held a FLAT list of instances. Every object carried
	its own absolute transform, so an articulated thing -- a robot arm, a
	solar system, a moon around a planet around a sun -- was impossible
	without the caller recomputing every descendant by hand each frame.

	GG3 gives an instance a PARENT. Its transform becomes LOCAL, and the
	drawn position is parent_world * local. Move the sun and the whole
	system moves, because the system is a chain rather than a list.

	KILL CRITERION from the plan: "if hierarchical propagation cannot stay
	on-device -- if any frame needs a CPU round trip to resolve parents --
	it falls back to CPU composition and the claim shrinks."

	This file settles that by MEASURING it rather than assuming the GPU is
	needed, which is the G6 law applied to our own roadmap.

	Run:  ring gg3_hierarchy.ring
---------------------------------------------------------------------------*/

decimals(3)

if NOT StzGraphicsDevice()
	? "No GPU device -- nothing to measure."
	return
ok

oBall = new stzMesh([ :Sphere, 0.5 ])

#---------------------------------------------------------------------------
? "-- 1. A moon follows its planet follows its sun ---------------"
#
# The whole claim in three objects. The moon is never told where the sun
# is; it only knows where it sits relative to its planet.
#---------------------------------------------------------------------------

oS = new stzScene(900, 560)
oS.SetBackgroundQ("#080C18").SetCamera(0, 9, 14, 0, 0, 0)

# The plain Add form ACTS and returns nothing (the house law); LastIndex()
# is how you name what you just added.
oS.AddMesh(oBall, 0, 0, 0)     nSun   = oS.LastIndex()
oS.AddMesh(oBall, 4, 0, 0)     nEarth = oS.LastIndex()
oS.AddMesh(oBall, 1.4, 0, 0)   nMoon  = oS.LastIndex()

? "   flat scene depth : " + oS.HierarchyDepth() + "  (0 = a list, not a chain)"

oS.SetParent(nEarth, nSun)
oS.SetParent(nMoon, nEarth)

aM = oS.WorldPosition(nMoon)
? "   moon world x with the sun at origin : " + aM[1] +
  "   (4 + 1.4 = 5.4)"
? "   hierarchy depth now : " + oS.HierarchyDepth() + "  (2 links)"

# MOVE ONLY THE SUN. Nothing else is touched.
oS.MoveTo(nSun, 10, 0, 0)
aM2 = oS.WorldPosition(nMoon)
aE2 = oS.WorldPosition(nEarth)
? ""
? "   sun moved to x=10, and NOTHING else was touched:"
? "     earth world x : " + aE2[1] + "   (10 + 4)"
? "     moon  world x : " + aM2[1] + "   (10 + 4 + 1.4)"
bFollow = (fabs(aM2[1] - 15.4) < 0.001) and (fabs(aE2[1] - 14) < 0.001)
? "   the chain followed : " + bFollow

# the negative sibling: detach the moon and it stops following
oS.ClearParent(nMoon)
aM3 = oS.WorldPosition(nMoon)
? "   moon DETACHED, world x : " + aM3[1] + "   (back to its own 1.4)"
? "   detaching really detaches : " + (fabs(aM3[1] - 1.4) < 0.001)
oS.SetParent(nMoon, nEarth)

#---------------------------------------------------------------------------
? ""
? "-- 2. A cycle is REFUSED, not hung on -------------------------"
#
# A caller can always build a loop. The engine must answer, not freeze.
#---------------------------------------------------------------------------

oC = new stzScene(400, 300)
oC.SetCamera(0, 5, 10, 0, 0, 0)
oC.AddMesh(oBall, 0, 0, 0)   nA = oC.LastIndex()
oC.AddMesh(oBall, 2, 0, 0)   nB = oC.LastIndex()
oC.SetParent(nA, nB)
oC.SetParent(nB, nA)          # a loop
aW = oC.WorldPosition(nA)     # must RETURN
? "   parented in a loop, and it still answers : " + (len(aW) = 3)
? "   cycles refused (counted, not silent)     : " + oC.CyclesRefused()
? "   parenting a node to ITSELF is refused    : " + (oC.SetParent(nA, nA) = FALSE)

#---------------------------------------------------------------------------
? ""
? "-- 3. Does this need the GPU? MEASURE, do not assume ----------"
#
# The plan allowed a GPU propagation path. Before writing one, find out
# whether resolving parents is even visible in a frame.
#---------------------------------------------------------------------------

_aNCount17_ = [ 200, 1000, 4000 ]
_nNCount17_ = len(_aNCount17_)
for _iNCount17_ = 1 to _nNCount17_
	nCount = _aNCount17_[_iNCount17_]
	oD = new stzScene(400, 300)
	oD.SetCamera(0, 40, 90, 0, 0, 0)
	nPrev = 0
	for i = 1 to nCount
		oD.AddMesh(oBall, 0.6, 0, 0)
		nId = oD.LastIndex()
		if nPrev > 0
			oD.SetParent(nId, nPrev)       # ONE chain, depth = nCount
		ok
		nPrev = nId
	next
	nT0 = clock()
	for r = 1 to 20
		oD.WorldPosition(nCount)           # forces a full resolve
	next
	nT1 = clock()
	? "   " + nCount + " deep, parents added FIRST : depth " +
	  oD.HierarchyDepth() + ", " +
	  ((nT1-nT0)/clockspersecond()*1000/20) + " ms"

	# the resolver's WORST case: children added before their parents, so
	# every pass can resolve only one link. Measuring only the friendly
	# order would flatter the number by the resolver's luck.
	oRev = new stzScene(400, 300)
	oRev.SetCamera(0, 40, 90, 0, 0, 0)
	for i = 1 to nCount
		oRev.AddMesh(oBall, 0.6, 0, 0)
	next
	for i = 1 to nCount - 1
		oRev.SetParent(i, i + 1)             # child index < parent index
	next
	nT2 = clock()
	for r = 1 to 5
		oRev.WorldPosition(1)
	next
	nT3 = clock()
	? "   " + nCount + " deep, parents added LAST  : depth " +
	  oRev.HierarchyDepth() + ", " +
	  ((nT3-nT2)/clockspersecond()*1000/5) + " ms"
next

? ""
? "   A worst-case chain is the deepest hierarchy that exists: every"
? "   instance parented to the last, so the propagation cannot skip a"
? "   single pass. A real articulated model is depth 3-6, not 4000."

#---------------------------------------------------------------------------
? ""
? "-- 4. Draw it ------------------------------------------------"
#---------------------------------------------------------------------------

oP = new stzScene(1000, 620)
oP.SetBackgroundQ("#070B16").SetCamera(0, 8, 20, 0, 0, 0)
oP.SetLight(-0.4, -1, -0.4, "#FFF6E0", "#232A44")

# SIZE BY MESH, NOT BY PARENT SCALE. Scaling the sun 2.2x also scales every
# child's ORBIT -- correct scene-graph behaviour (scale composes down the
# chain) and it threw the planets clean out of frame the first time. Three
# meshes of different radii keeps every scale at 1 and the surprise out of
# the picture.
oSunMesh    = new stzMesh([ :Sphere, 1.6 ])
oPlanetMesh = new stzMesh([ :Sphere, 0.6 ])
oMoonMesh   = new stzMesh([ :Sphere, 0.28 ])

oP.AddMeshQ(oSunMesh, 0, 0, 0).Color("#FFC53D")
nSun2 = oP.LastIndex()

aPlanets = [ [ 4.5, "#4FA3E0" ], [ 7.5, "#E06C4F" ], [ 10.5, "#7FD8A0" ] ]
nIdx = 1
_aP18_ = aPlanets
_nP18_ = len(_aP18_)
for _iP18_ = 1 to _nP18_
	p = _aP18_[_iP18_]
	oP.AddMeshQ(oPlanetMesh, p[1], 0, 0).Color(p[2])
	nId = oP.LastIndex()
	oP.SetParent(nId, nSun2)
	# a moon on the middle planet: the chain becomes two links deep
	if nIdx = 2
		oP.AddMeshQ(oMoonMesh, 1.5, 0, 0).Color("#D8D8E8")
		nMoonId = oP.LastIndex()
		oP.SetParent(nMoonId, nId)
	ok
	nIdx++
next

? "   instances : " + oP.InstanceCount() + "   depth : " + oP.HierarchyDepth() + " links"
? "   moon world x : " + oP.WorldPosition(nMoonId)[1] + "   (7.5 + 1.5 = 9)"

# and now MOVE THE SUN -- one call, and the whole system travels
oP.MoveTo(nSun2, -3, 0, 0)
? "   sun to x=-3, moon world x : " + oP.WorldPosition(nMoonId)[1] + "   (-3 + 7.5 + 1.5 = 6)"
oP.MoveTo(nSun2, 0, 0, 0)

cB = oP.ToPNG("gg3_system.png")
? "   gg3_system.png : " + len(cB) + " bytes"

? ""
? "=============================================================="
? " children follow parents : " + bFollow
? " cycles refused, never hung : " + (oC.CyclesRefused() > 0)
? "=============================================================="
