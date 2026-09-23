# E3a -- the SPINE of the Elementary Introduction: skills, curriculum, levels.
#
# Before a single new chapter is written, the course's skeleton must hold:
#   1. the 25 skills exist, in 7 families, each with three levels in en/fr/ar/ha
#   2. the curriculum plans 15 chapters, trains every skill, and its
#      prerequisites form no cycle
#   3. what SHIPS (course.zknw) is inside the PLAN, and the planned chapters
#      not yet written are PRINTED BY NAME, never counted as shipped
#   4. every skill's evidence names something: an exercise folder that
#      exists (backed) or one that does not yet (named, listed)
#   5. the levels S0-S4 are ranked, each reaches further than the last, and
#      each is earned by a project the levels file declares
# Every positive has a negative sibling. No child process runs here: the
# spine is files and facts, so this gate is seconds.
#
# Run from this folder: ring spine_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"

t0 = clock()
cProg = "../../education/program"
aLangs = [ "en", "fr", "ar", "ha" ]
oP = StzProgramQ(cProg)
oC = oP.CourseQ("elementary-introduction")
EduSpineClean()

#---------------------------------------------------------------------------
Scenario("1. Twenty-five skills, seven families, four languages")
acSkills = oP.SkillIds()
Then("the program holds 25 skills", len(acSkills), 25)
aFam = []
acIncomplete = []
acBadFamily = []
for i = 1 to len(acSkills)
	oS = oP.SkillQ(acSkills[i])
	cF = oS.Family()
	if StzFindFirst(cF, [ "formulate", "express", "patterns", "see", "know", "govern", "craft" ]) = 0
		acBadFamily + acSkills[i]
	ok
	bSeen = 0
	for j = 1 to len(aFam)
		if aFam[j][1] = cF
			aFam[j][2]++
			bSeen = 1
		ok
	next
	if NOT bSeen
		aFam + [ cF, 1 ]
	ok
	acMiss = oS.MissingIn(aLangs)
	if len(acMiss) > 0
		acIncomplete + (acSkills[i] + ":" + @@(acMiss))
	ok
next
Then("every skill names one of the seven families", @@(acBadFamily), "[ ]")
cNarr = DemoFolderOfBase() + "/doc/narrations/"
acLostStudy = []
for i = 1 to len(acSkills)
	acSt = oP.SkillQ(acSkills[i]).Study()
	if len(acSt) = 0
		acLostStudy + (acSkills[i] + ": (none)")
	ok
	for j = 1 to len(acSt)
		if NOT fexists(cNarr + acSt[j] + ".md")
			acLostStudy + (acSkills[i] + ": " + acSt[j])
		ok
	next
next
Then("every skill's study reference is a narration that exists", @@(acLostStudy), "[ ]")
Then("all seven families are used", len(aFam), 7)
Then("every skill has a title, a question and three levels in all four languages", @@(acIncomplete), "[ ]")
oS = oP.SkillQ("ex-03")
Then("a skill reads back its question", oS.Question("en"), "Where is it, and what do I do there?")
Then("...in Arabic too", StzLen(oS.Question("ar")) > 0 and oS.Question("ar") != oS.Question("en"), 1)
Then("...and its three levels are three different sentences",
	oS.Level("fr", "foundation") != oS.Level("fr", "expert"), 1)

Given("a scratch skill with no Hausa text (negative sibling)")
StzEngineDirCreatePath("t_edu_skills")
write("t_edu_skills/zz-01.zknw", 'knowledge "skill-zz-01"' + char(10) + char(10) + "facts" + char(10) +
	"    zz-01 | is-a | skill" + char(10) + "    zz-01 | family | craft" + char(10))
for i = 1 to 3
	write("t_edu_skills/zz-01." + aLangs[i] + ".md", "# ZZ-01 · T" + char(10) + "question: q" + char(10) +
		"foundation: f" + char(10) + "practitioner: p" + char(10) + "expert: e" + char(10))
next
oZ = StzSkillQ("t_edu_skills", "zz-01")
Then("the missing language is named, and it is not filled from English", @@(oZ.MissingIn(aLangs)), '[ "ha" ]')
bRed = 0
try
	oZ.Question("ha")
catch
	bRed = 1
done
Then("asking for the missing text is RED", bRed, 1)
EndScenario()

#---------------------------------------------------------------------------
Scenario("2. The curriculum plans fifteen chapters, trains every skill, and has no cycle")
acPlan = oC.PlannedChapterIds()
Then("fifteen chapters are planned, in order", len(acPlan), 15)
Then("the first planned chapter is the one that ships", acPlan[1], "find-then-apply")
acUntrained = []
for i = 1 to len(acSkills)
	if len(oC.TrainedBy(acSkills[i])) = 0
		acUntrained + acSkills[i]
	ok
next
Then("every one of the 25 skills is trained by a planned chapter", @@(acUntrained), "[ ]")
acIdle = []
acDangling = []
for i = 1 to len(acPlan)
	if len(oC.Trains(acPlan[i])) = 0
		acIdle + acPlan[i]
	ok
	acR = oC.Requires(acPlan[i])
	for j = 1 to len(acR)
		if StzFindFirst(acR[j], acPlan) = 0
			acDangling + (acPlan[i] + " -> " + acR[j])
		ok
	next
next
Then("every planned chapter trains at least one skill", @@(acIdle), "[ ]")
Then("every prerequisite is itself a planned chapter", @@(acDangling), "[ ]")
Then("the first chapter requires nothing", len(oC.Requires(acPlan[1])), 0)
Then("the prerequisites form no cycle", oC.HasCycle(), 0)
Then("chapter 14 reaches back to chapter 1 through its prerequisites",
	StzFindFirst("find-then-apply", oC.Prerequisites("an-agent-that-cannot-hurt")) > 0, 1)

Given("a scratch course whose curriculum has a cycle (negative sibling)")
StzEngineDirCreatePath("t_edu_prog/courses/loopy")
write("t_edu_prog/program.zknw", 'knowledge "p"' + char(10) + char(10) + "facts" + char(10) + "    p | is-a | program" + char(10))
write("t_edu_prog/courses/loopy/course.zknw", 'knowledge "loopy"' + char(10) + char(10) + "facts" + char(10) + "    loopy | is-a | course" + char(10))
write("t_edu_prog/courses/loopy/curriculum.zknw", 'knowledge "c"' + char(10) + char(10) + "facts" + char(10) +
	"    loopy | plans-chapter-01 | a" + char(10) + "    loopy | plans-chapter-02 | b" + char(10) +
	"    a | requires | b" + char(10) + "    b | requires | a" + char(10))
Then("the cycle is caught", StzProgramQ("t_edu_prog").CourseQ("loopy").HasCycle(), 1)
EndScenario()

#---------------------------------------------------------------------------
Scenario("3. What ships is inside the plan; what is not yet written is named")
acHave = oC.ChapterIds()
acOutside = []
for i = 1 to len(acHave)
	if StzFindFirst(acHave[i], acPlan) = 0
		acOutside + acHave[i]
	ok
next
Then("every shipped chapter is a planned chapter", @@(acOutside), "[ ]")
acUnwritten = oC.UnwrittenChapterIds()
? "  [owned, not run] planned chapters not yet written (" + len(acUnwritten) + " of " + len(acPlan) + "):"
for i = 1 to len(acUnwritten)
	? "      " + acUnwritten[i]
next
Then("shipped + unwritten = planned, and the two are never summed as shipped",
	len(acHave) + len(acUnwritten), len(acPlan))
Then("one chapter ships today", len(acHave), 1)
EndScenario()

#---------------------------------------------------------------------------
Scenario("4. Evidence: every level of every skill names its proof, backed or not yet")
acNoEvidence = []
acBacked = []
acNotYet = []
acBadProject = []
acProjects = oP.ProjectIds()
for i = 1 to len(acSkills)
	oS = oP.SkillQ(acSkills[i])
	cEv = oS.Evidence("foundation")
	if cEv = ""
		acNoEvidence + acSkills[i]
	else
		acParts = StzSplit(cEv, "/")
		if len(acParts) = 2 and oP.FolderFor("courses/" + acParts[1] + "/exercises/" + acParts[2]) != ""
			acBacked + (acSkills[i] + " <- " + cEv)
		else
			acNotYet + (acSkills[i] + " <- " + cEv)
		ok
	ok
	for k in [ "practitioner", "expert" ]
		cP = oS.Evidence(k)
		if cP = "" or StzFindFirst(cP, acProjects) = 0
			acBadProject + (acSkills[i] + ":" + k)
		ok
	next
next
Then("every skill names foundation evidence", @@(acNoEvidence), "[ ]")
? "  [backed] foundation evidence whose exercise EXISTS (" + len(acBacked) + "):"
for i = 1 to len(acBacked)
	? "      " + acBacked[i]
next
? "  [named, not yet] foundation evidence whose exercise is not written (" + len(acNotYet) + "):"
for i = 1 to len(acNotYet)
	? "      " + acNotYet[i]
next
Then("the three skills the E1/E2 exercises train are backed today", len(acBacked), 3)
Then("backed + not yet = 25, and neither is claimed as the other", len(acBacked) + len(acNotYet), 25)
Then("every practitioner and expert evidence names a project the levels file declares", @@(acBadProject), "[ ]")
EndScenario()

#---------------------------------------------------------------------------
Scenario("5. Five levels, ranked, each reaching further, each earned by a project")
acLevels = oP.LevelIds()
Then("five levels, S0 to S4", @@(acLevels), @@([ "s0", "s1", "s2", "s3", "s4" ]))
nPrev = 0
bMonotone = 1
acNoProject = []
for i = 1 to len(acLevels)
	nThrough = 0 + oP.LevelFact(acLevels[i], "needs-chapters-through")
	if nThrough <= nPrev or nThrough > len(acPlan)
		bMonotone = 0
	ok
	nPrev = nThrough
	cPr = oP.LevelFact(acLevels[i], "earned-by")
	if cPr = "" or StzFindFirst(cPr, acProjects) = 0
		acNoProject + acLevels[i]
	ok
next
Then("each level needs strictly more chapters than the last, within the plan", bMonotone, 1)
Then("the top level needs the whole course", 0 + oP.LevelFact("s4", "needs-chapters-through"), len(acPlan))
Then("every level is earned by a declared project, never by a test score", @@(acNoProject), "[ ]")
acNoBrief = []
acEarnable = []
for i = 1 to len(acProjects)
	for j = 1 to len(aLangs)
		if NOT fexists(cProg + "/projects/" + acProjects[i] + "/brief." + aLangs[j] + ".md")
			acNoBrief + (acProjects[i] + ":" + aLangs[j])
		ok
	next
	if fexists(cProg + "/projects/" + acProjects[i] + "/guard.ring")
		acEarnable + acProjects[i]
	ok
next
Then("every project has a brief in all four languages", @@(acNoBrief), "[ ]")
? "  [owned, not run] projects with no guard yet, so no level can be earned (" +
	(len(acProjects) - len(acEarnable)) + " of " + len(acProjects) + ")"
Then("no level can be earned today, and nothing pretends otherwise", @@(acEarnable), "[ ]")
EndScenario()

EduSpineClean()
? ""
? "  [time] whole guard: " + ((clock() - t0) / clockspersecond()) + " s"
Summary()

#===========================================================================
func EduSpineClean()
	StzEduRemoveTree("t_edu_skills")
	StzEduRemoveTree("t_edu_prog")

# .../libraries/stzlib/base, from the file the library discovered itself by
func DemoFolderOfBase()
	_es_c_ = StzEduBaseFile()
	_es_n_ = 0
	for _es_i_ = 1 to len(_es_c_)
		if _es_c_[_es_i_] = "/"
			_es_n_ = _es_i_
		ok
	next
	return StzLeft(_es_c_, _es_n_ - 1)
