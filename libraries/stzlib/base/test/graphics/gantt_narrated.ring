# A GANTT CHART, NARRATED -- DN14 of the graph plane (SOFTANZA_GRAPH_PLANE_PLAN.md).
#
# A schedule is a list of tasks with a start and a finish, and a list of
# dependencies between them. The chart is ARITHMETIC over that list: every
# bar's position is a datum on the day scale, every lane is assigned by
# the builder so that no two bars on one lane touch, and three rules say
# what a schedule may not do -- a dependency running backwards in time, a
# task finishing before it starts, two tasks double-booked on a lane.
#
# This guide is the reader's walk through it, and it RUNS: every number
# printed below is the picture's own, read back from the substance the
# builder wrote, and every rule is asked through the same gate the
# catalogue is held to.
#
#   Run:  ring gantt_narrated.ring

load "../../stzBase.ring"
load "gg_math_scenes.ring"

nPass = 0
nFail = 0
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")

? "-- Scene 1: a schedule is a list of tasks, and the chart is arithmetic --"
? "   the project: " + len(StzMathProjectTasks()) + " rows, " + len(StzMathProjectDeps()) + " dependencies"
oG = StzGanttDiagram(FONT, StzMathProjectTasks(), StzMathProjectDeps())
oG.Layout()
# the substance is what the builder wrote: every task, its days, its lane
oS = oG.Substance()
aTasks = oS.ObjectsOfType("Task")
aMiles = oS.ObjectsOfType("Milestone")
? "   drawn as " + len(aTasks) + " bars, " + len(aMiles) + " of them milestones"
chk("eight rows, two of them milestones -- a task with no duration is a diamond, and still a task",
    len(aTasks) = 8 and len(aMiles) = 2)
? "   'Build' starts on day " + oS.DataOf("t5", "start") + ", finishes on day " +
  oS.DataOf("t5", "finish") + ", and sits on lane " + oS.DataOf("t5", "lane")
chk("a bar's days are the schedule's days -- the position IS the datum",
    oS.DataOf("t5", "start") = 20 and oS.DataOf("t5", "finish") = 30)
nDayBuild = (oS.DataOf("t5", "x1") - oS.DataOf("t5", "x0")) / 10
nDayDesign = (oS.DataOf("t2", "x1") - oS.DataOf("t2", "x0")) / 8
? "   one day is " + StzFactNumText(nDayBuild) + " px on Build's bar and " +
  StzFactNumText(nDayDesign) + " px on Design's"
chk("every bar is drawn on ONE day scale", fabs(nDayBuild - nDayDesign) < 0.01)
? "   'Test' (days 30-36) and 'Docs' (days 26-38) overlap in time, so the builder put them on lanes " +
  oS.DataOf("t6", "lane") + " and " + oS.DataOf("t7", "lane")
chk("two tasks that overlap in time are never given one lane",
    oS.DataOf("t6", "lane") != oS.DataOf("t7", "lane"))

? ""
? "-- Scene 2: three rules about time, and a sound schedule passes all three --"
aF = StzCheckPictures([ [ "project", oG ] ]).Findings()
? "   dependency_forward_in_time, task_ends_after_it_starts, lane_not_double_booked"
chk("the project has nothing wrong with it", len(aF) = 0)

? ""
? "-- Scene 3: the same project typed wrong, and every mistake named --"
? "   Test made to depend on Docs, which ends after Test starts; Docs put on Build's"
? "   lane; and a task that finishes before it starts."
oW = StzGanttDiagram(FONT, StzMathProjectWrongTasks(), StzMathProjectWrongDeps())
aW = StzCheckPictures([ [ "wrong", oW ] ]).Findings()
say(aW)
chk("a dependency running backwards is caught on both its tasks, with the days",
    hits(aW, "dependency_forward_in_time") = 2 and
    has(aW, "'Test' starts on day 26, 12 days before 'Docs' ends on day 38"))
chk("a task that finishes before it starts is caught, by name and by how much",
    hits(aW, "task_ends_after_it_starts") = 1 and
    has(aW, "'Backwards' finishes on day 20, 2 days before it starts"))
chk("a double-booked lane is reported on both tasks, with the overlap in days",
    hits(aW, "lane_not_double_booked") = 2 and
    has(aW, "'Build' and 'Docs' share lane 5 and overlap by 2 days"))
chk("and those five are everything the rules find", len(aW) = 5)

? ""
? "-- Scene 4: the pictures --"
if StzGraphicsDevice()
	oG.ToPNG("guide_gantt.png")
	oW.ToPNG("guide_gantt_witness.png")
	? "   wrote guide_gantt.png and guide_gantt_witness.png"
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
