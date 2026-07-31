load "../../stzBase.ring"

$nAlerts = 0

? "== block 1 =="
StzOpenSecurityLedger(512)
oSent = StzSecuritySentinel(StzDefaultDetectionSet())
oSent.OnDetection(func aFinding {
	$nAlerts++
	? "  >> ALERT [" + aFinding[:severity] + "] " + aFinding[:where]
	? "     " + aFinding[:message]
})
oSent.OnClear(func cWhere { ? "  >> cleared: " + cWhere })

oAuth = new stzAuth()
oAuth.Register("victim", "correct-horse")

? "quiet system      : " + oSent.Check() + " alert(s)"

for i = 1 to 5
	oAuth.Login("victim", "guess-" + i)
next
? "after five guesses:"
oSent.Check()

? "still under attack:"
oAuth.Login("victim", "guess-6")
? "  " + oSent.Check() + " new alert(s) -- the story did not restart"

? "== block 2 =="
aCase = oSent.LastCase()
? "the case, photographed when it fired:"
? "  story        : " + aCase[:where]
? "  severity     : " + aCase[:severity]
? "  ledger held  : " + aCase[:ledgerCount] + " event(s)"
? "  head digest  : " + left(aCase[:headDigest], 24) + "..."
? "  nearest events:"
for i = 1 to len(aCase[:recent])
	? "    " + aCase[:recent][i][:kind] + " by " + aCase[:recent][i][:actor]
next

? "== block 3 =="
oSent.Show()
StzCloseSecurityLedger()
