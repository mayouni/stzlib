# THE ROSTER -- rows 1 and 2 of softanza/roster/MIGRATION.md, narrated
#
# silence-board.pia and ledger-roll.pia are declared in softanza/roster/ and
# refuse to load until every `ring:` clause they name resolves to a real Ring
# function (prompt 39's own gate, at LOAD). This suite backs the six
# functions in stzAgentRoster.ring and runs the two declared agents against a
# throwaway fixture tree -- never the live softanza estate, so a run of this
# suite can never move a real journal file or touch the real SESSION-LOG.md.
#
# Every fixture is BUILT BY THIS SCRIPT, not checked in static: the roll's
# "before the current month" test would rot the day it was written if the
# fixture's dates were literals. STZ_SOFTANZA_ROOT is the env-var door
# StzRosterEstateRoot() opens for exactly this -- point it at a fixture and
# the estate-wide walk-up is never consulted.
#
# Scenes 1-2: silence-board (a heartbeat sampled, a dead run named, a board
# that announces its own death). Scenes 3-5: ledger-roll (a month relocated,
# the pointer it leaves, the zero it reports, the move it refuses to half-do).
#
# THE HELPERS LIVE AFTER pf(). Ring runs a file's top-level code only up to
# the first `func`; a helper defined at the top would silently end every
# scene below it.

load "../../stzBase.ring"

nPass = 0
nFail = 0

cFixture = StzReplace(WorkingDirectory(), "\", "/") + "/_roster-fixture"
cEstate = cFixture + "/estate"
cCentral = cEstate + "/central"
cRepoAlive = cEstate + "/repo-alive"
cRepoDead = cEstate + "/repo-dead"
cRepoQuiet = cEstate + "/repo-quiet"

if StzDirExists(cFixture)
	StzDirDeleteAll(cFixture)
ok
StzDirCreatePath(cCentral + "/dashboard/archive")
StzDirCreatePath(cCentral + "/journal")
StzDirCreatePath(cRepoAlive + "/.central/runs")
StzDirCreatePath(cRepoDead + "/.central/runs")
StzDirCreatePath(cRepoQuiet)

StzFileWrite(cCentral + "/dashboard/machine.jsonl",
	'{"t":"2026-08-20T10:00","cpu":9,"memfree":5.0,"freeC":100.0}' + char(10))

StzFileWrite(cRepoAlive + "/.central/runs/2026-08-20-0900-wake.log",
	"=== harness wake 2026-08-20 09:00 ===" + char(10) +
	"did the ordinary thing" + char(10) +
	"=== finished 2026-08-20 09:01 ===" + char(10))

StzFileWrite(cRepoDead + "/.central/runs/2026-08-20-0900-wake.log",
	"=== harness wake 2026-08-20 09:00 ===" + char(10) +
	"started the ordinary thing, then the process never came back" + char(10))

pr()

#=====================================================================#
? "-- Scene 1: silence-board -- a heartbeat sampled, a corpse named --"
#=====================================================================#

SetEnvVar("STZ_SOFTANZA_ROOT", cCentral)

oDecl = StzAgentDeclarationFromFileQ("../../../../../../softanza/roster/silence-board.pia")
chk("the live declaration is accepted -- every ring: clause it names now exists",
	oDecl.IsValid() = 1)

oBoard = oDecl.ToAgent()
chk("one cycle samples AND judges -- sample then corpses, both verified",
	oBoard.Cycle() = 2)
chk("...the sampler's own heartbeat is a fact",
	oBoard.MemoryQ().Fact("board", "holds", "heartbeat") = 1)
chk("...the 10-minute refresh row was sensed",
	len(oBoard.MemoryQ().Recall("the-10-minute-refresh", "last-seen")) = 1)
chk("...the repo that finished cleanly is NOT named a corpse",
	oBoard.MemoryQ().Fact("repo-alive", "ruled", "corpse") = 0)
chk("...the repo whose newest run has no finished footer IS",
	oBoard.MemoryQ().Fact("repo-dead", "ruled", "corpse") = 1)
chk("...a repo with no .central/runs/ at all gets no verdict either way",
	len(oBoard.MemoryQ().Recall("repo-quiet", "newest-wake-log")) = 0)
chk("...and the judge marks the ruling done",
	oBoard.MemoryQ().Fact("board", "ruled", "corpses") = 1)
chk("...ANNOUNCE did not fire -- the board is not dead this cycle",
	oBoard.MemoryQ().Fact("board", "announced", "death") = 0)

? ""
#=====================================================================#
? "-- Scene 2: silence-board -- no evidence surface, so it says so --"
#=====================================================================#
# no-fact where sample writes fact: a root that resolves to somewhere with
# no dashboard/ at all is the board's own blindness, and FAIL-LOUD means it
# reports STALE rather than replaying whatever it last knew.

StzDirCreatePath(cFixture + "/nothing-here")
SetEnvVar("STZ_SOFTANZA_ROOT", cFixture + "/nothing-here")

oBoard2 = StzAgentDeclarationFromFileQ(
	"../../../../../../softanza/roster/silence-board.pia").ToAgent()
chk("a cycle over an unreachable estate does not fake a heartbeat",
	oBoard2.Cycle() = 1)
chk("...SAMPLE left the heartbeat fact unwritten",
	oBoard2.MemoryQ().Fact("board", "holds", "heartbeat") = 0)
chk("...CORPSES never ran -- its precondition is the heartbeat that is missing",
	oBoard2.MemoryQ().Fact("board", "ruled", "corpses") = 0)
chk("...and ANNOUNCE fired instead, verified",
	oBoard2.MemoryQ().Fact("board", "announced", "death") = 1)
chk("...the tick itself reports VERIFIED, because announcing is the correct outcome",
	len(StzFind("VERIFIED", oBoard2.Trace()[len(oBoard2.Trace())][:why])) > 0)

SetEnvVar("STZ_SOFTANZA_ROOT", cCentral)

? ""
#=====================================================================#
? "-- Scene 3: ledger-roll -- a month before this one moves, and the --"
? "             pointer is written where the next reader will see it --"
#=====================================================================#

cOld = "2000-01"
cCur = _StzRosterCurrentMonth()
StzFileWrite(cCentral + "/journal/" + cOld + "-scar.md", "an old journal entry" + char(10))
StzFileWrite(cCentral + "/journal/" + cCur + "-fresh.md", "this month's entry" + char(10))
StzFileWrite(cCentral + "/dashboard/SESSION-LOG.md",
	"# SESSION-LOG" + char(10) +
	char(10) +
	cOld + "-15 09:00 | someone | something that happened long ago" + char(10) +
	cCur + "-01 09:00 | someone | something happening this month" + char(10))

oRollDecl = StzAgentDeclarationFromFileQ("../../../../../../softanza/roster/ledger-roll.pia")
chk("the live ledger-roll declaration is accepted",
	oRollDecl.IsValid() = 1)

oRoll = oRollDecl.ToAgent()
chk("one cycle relocates AND writes the pointer, both verified",
	oRoll.Cycle() = 2)
chk("...the old journal file is gone from the live folder",
	StzFileExists(cCentral + "/journal/" + cOld + "-scar.md") = 0)
chk("...and it exists, whole, in the archive -- relocation, not retention",
	StzFileExists(cCentral + "/journal/archive/" + cOld + "-scar.md") = 1)
chk("...this month's journal file was left alone",
	StzFileExists(cCentral + "/journal/" + cCur + "-fresh.md") = 1)

cSlAfter = StzFileRead(cCentral + "/dashboard/SESSION-LOG.md")
chk("...the old SESSION-LOG line moved to its month's archive file",
	len(StzFind("something that happened long ago",
		StzFileRead(cCentral + "/dashboard/archive/SESSION-LOG-" + cOld + ".md"))) > 0)
chk("...and is gone from the live file",
	len(StzFind("something that happened long ago", cSlAfter)) = 0)
chk("...this month's line stayed in the live file",
	len(StzFind("something happening this month", cSlAfter)) > 0)
chk("...the pointer line is in the live file, naming the archive path",
	len(StzFind("Rolled ", cSlAfter)) > 0 and
	len(StzFind("dashboard/archive/SESSION-LOG-<month>.md", cSlAfter)) > 0)
chk("...and both memory facts the file declares are held",
	oRoll.MemoryQ().Fact("archive", "holds", "month") = 1 and
	oRoll.MemoryQ().Fact("ledger", "holds", "pointer") = 1)
chk("...SAYZERO did not fire -- something moved this cycle",
	oRoll.MemoryQ().Fact("roll", "moved", "nothing") = 0)

? ""
#=====================================================================#
? "-- Scene 4: ledger-roll -- nothing to move, and the zero is a fact --"
#=====================================================================#
# a pass that prints nothing when it moves nothing is indistinguishable from
# a pass that is not running -- so the quiet outcome is a RECORD here.

oRoll2 = StzAgentDeclarationFromFileQ(
	"../../../../../../softanza/roster/ledger-roll.pia").ToAgent()
chk("a second cycle, with only this month's files left, still verifies",
	oRoll2.Cycle() = 1)
chk("...RELOCATE found nothing before the current month",
	oRoll2.MemoryQ().Fact("archive", "holds", "month") = 0)
chk("...POINTER never ran -- its precondition did not hold",
	oRoll2.MemoryQ().Fact("ledger", "holds", "pointer") = 0)
chk("...SAYZERO fired and recorded the zero as a fact",
	oRoll2.MemoryQ().Fact("roll", "moved", "nothing") = 1)

? ""
#=====================================================================#
? "-- Scene 5: ledger-roll -- a move it cannot verify is abandoned, --"
? "             the source left exactly where it was --"
#=====================================================================#
# FAIL-CLOSED: relocate writes the destination and RE-READS it before
# touching the source. Here the destination path is blocked by a directory
# of the same name, so the write can never be verified -- the probe for
# whether fail-closed is real rather than assumed.

cBlocked = cOld + "-blocked.md"
StzFileWrite(cCentral + "/journal/" + cBlocked, "must not be lost" + char(10))
StzDirCreatePath(cCentral + "/journal/archive/" + cBlocked)

oRoll3 = StzAgentDeclarationFromFileQ(
	"../../../../../../softanza/roster/ledger-roll.pia").ToAgent()
oRoll3.Cycle()
chk("a destination the write cannot occupy leaves the source FILE untouched",
	StzFileExists(cCentral + "/journal/" + cBlocked) = 1)
chk("...its content is exactly what it was",
	StzFileRead(cCentral + "/journal/" + cBlocked) = "must not be lost" + char(10))

StzDirDeleteAll(cCentral + "/journal/archive/" + cBlocked)
StzFileDelete(cCentral + "/journal/" + cBlocked)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

StzDirDeleteAll(cFixture)

pf()

func chk(cWhat, bCond)
	if bCond = 1
		nPass++
		? "  [OK] " + cWhat
	else
		nFail++
		? "  [FAIL] " + cWhat
	ok
