# A FLOOR PLAN, NARRATED -- DN22 of the graph plane (SOFTANZA_GRAPH_PLANE_PLAN.md).
#
# A floor plan is rooms TO SCALE: every room a rectangle in metres, every
# door an opening on one of its walls, every window the same, and the
# picture arithmetic over those -- one scale for the whole flat, an area
# written in each room, a scale bar beneath. Four rules say what a
# building may not do -- two rooms overlapping, a room with no door, a
# room nobody can walk to from outside, a window that opens onto another
# room instead of the outside.
#
# This guide RUNS: every number below is read back from the substance the
# builder wrote, and every rule is asked through the catalogue's gate.
#
#   Run:  ring floorplan_narrated.ring

load "../../stzBase.ring"
load "gg_math_scenes.ring"

nPass = 0
nFail = 0
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")

? "-- Scene 1: a flat of six rooms, in metres --"
oP = StzFloorPlanDiagram(FONT, StzMathFlatRooms(), StzMathFlatDoors(), StzMathFlatWindows())
oP.Layout()
oS = oP.Substance()
aRooms = oS.ObjectsOfType("Room")
aDoors = oS.ObjectsOfType("Door")
aWin = oS.ObjectsOfType("Window")
? "   " + len(aRooms) + " rooms, " + len(aDoors) + " doors, " + len(aWin) + " windows"
chk("six rooms, six doors, six windows", len(aRooms) = 6 and len(aDoors) = 6 and len(aWin) = 6)
? "   the living room is " + oS.DataOf("r2", "mw") + " m by " + oS.DataOf("r2", "mh") + " m, so its area is " +
  StzFloorPlanAreaText(oS.DataOf("r2", "area"))
chk("a room's area is its metres multiplied, written as the plan writes it",
    oS.DataOf("r2", "area") = 20 and StzFloorPlanAreaText(20) = "20 m2")
nScaleA = oS.DataOf("r2", "w") / oS.DataOf("r2", "mw")
nScaleB = oS.DataOf("r5", "h") / oS.DataOf("r5", "mh")
? "   a metre is " + StzFactNumText(nScaleA) + " px across the living room and " +
  StzFactNumText(nScaleB) + " px down the bedroom"
chk("one scale for the whole flat, both ways", fabs(nScaleA - nScaleB) < 0.01)

? ""
? "-- Scene 2: four rules about a building, and a sound flat passes them --"
aF = StzCheckPictures([ [ "flat", oP ] ]).Findings()
? "   rooms_do_not_overlap, every_room_has_a_door, every_room_is_reachable, windows_face_outside"
chk("the flat has nothing wrong with it", len(aF) = 0)

? ""
? "-- Scene 3: the same flat with one of each mistake --"
? "   a pantry drawn over the living room; a bathroom with no door; a bedroom"
? "   and a study whose only door is between the two; a window from the living"
? "   room into the bedroom."
oW = StzFloorPlanDiagram(FONT, StzMathFlatWrongRooms(), StzMathFlatWrongDoors(), StzMathFlatWrongWindows())
aW = StzCheckPictures([ [ "wrong", oW ] ]).Findings()
say(aW)
chk("an overlap is reported on both rooms", hits(aW, "rooms_do_not_overlap") = 2 and has(aW, "Pantry"))
chk("the room with no door is named", hits(aW, "every_room_has_a_door") = 1 and has(aW, "Bath"))
chk("the two rooms nobody can reach are both named", hits(aW, "every_room_is_reachable") = 2)
chk("the window onto a room is caught", hits(aW, "windows_face_outside") = 1)
chk("and those six are everything the rules find", len(aW) = 6)

? ""
? "-- Scene 4: the pictures --"
if StzGraphicsDevice()
	oP.ToPNG("guide_floorplan.png")
	oW.ToPNG("guide_floorplan_witness.png")
	? "   wrote guide_floorplan.png and guide_floorplan_witness.png"
else
	? "   (no device -- the numbers above needed none; the pictures do)"
ok

? ""
? "== " + nPass + " passed, " + nFail + " failed =="

#---------------------------------------------------------------------------

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func hits aF, cRule
	_n_ = 0
	for _i_ = 1 to len(aF)
		if StzLower("" + aF[_i_][:rule]) = StzLower(cRule)  _n_++  ok
	next
	return _n_

func has aF, cText
	for _i_ = 1 to len(aF)
		if StzFindFirst(cText, "" + aF[_i_][:message]) > 0  return 1  ok
	next
	return 0

func say aF
	for _i_ = 1 to len(aF)
		? "     " + aF[_i_][:rule] + " -- " + aF[_i_][:message]
	next
