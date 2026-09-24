# The court of this project. %PROJECT% is the learner's folder; it prints what it found.
cP = "%PROJECT%"
if fexists(cP + "/world.zknw") and fexists(cP + "/agent.pia") and fexists(cP + "/ask.ring")
	oWorld = new stzKnowledgeGraph("w")
	oWorld.ImportKnow(cP + "/world.zknw")
	? "world facts five or more: " + yn(len(oWorld.Facts()) >= 5)
	oD = StzAgentDeclarationFromFileQ(cP + "/agent.pia")
	? "agent admitted: " + yn(oD.IsValid())
	? "every act reversible: " + yn(oD.IsValid() and oD.ReversibilityClass() = "reversible")
	aRun = StzEduRunSoftanza('$cProjectFolder = "' + cP + '"' + char(10) + read(cP + "/ask.ring"))
	? "answer printed: " + yn(aRun[2] = 0 and len(trim(aRun[1])) > 0)
else
	? "files: missing"
ok
func yn(b)
	if b
		return "yes"
	ok
	return "no"

