load "../../stzBase.ring"
load "../_narrated.ring"

# ExposeReadOnly -- the MBaaS floor with no door that writes.
#
# Expose() publishes the full CRUD floor, DELETE included. A host that must
# never offer a delete (the Zing server projection, github issue #2) needs a
# floor that serves reads and refuses the rest. ExposeReadOnly() is that
# floor: GET answers exactly as under Expose, and POST / PUT / DELETE answer
# 405 without touching the table.
#
# Every refusal is paired with a sibling that proves the route is the cause:
# the same verb on a table exposed with Expose() still writes.
#
# Offline by construction: a second stzReactor plays the HTTP client.

$CRLF = char(13) + char(10)

oSrv = new stzAppServer()
oClient = new stzReactor()
oSrv.Start(0, "127.0.0.1")

$oDb = new stzDatabase(":memory:")
$oDb.Exec("CREATE TABLE ledger(id INTEGER PRIMARY KEY, entry TEXT)")
$oDb.Exec("INSERT INTO ledger (entry) VALUES ('opening')")
$oDb.Exec("CREATE TABLE note(id INTEGER PRIMARY KEY, entry TEXT)")
$oDb.Exec("INSERT INTO note (entry) VALUES ('first')")
$oDb.Exec("CREATE TABLE tag(uuid TEXT, label TEXT)")
$oDb.Exec("INSERT INTO tag (uuid, label) VALUES ('u-1', 'alpha')")

oSrv.ExposeReadOnly($oDb, "ledger")
oSrv.Expose($oDb, "note")
oSrv.ExposeReadOnlyWithKey($oDb, "tag", "uuid")

Scenario("a read-only table still reads exactly as under Expose")
	Given("a ledger table exposed with ExposeReadOnly")
	When("a client GETs the list, the count and one row")
	cList  = Hit("GET", "/api/ledger", "")
	cCount = Hit("GET", "/api/ledger/count", "")
	cOne   = Hit("GET", "/api/ledger/1", "")
	Then("the list answers 200 with the row", Has(cList, "200 OK") and Has(cList, '"rows":[["1","opening"]]'), TRUE)
	Then("the count answers 1", Has(cCount, '"count":1'), TRUE)
	Then("one row answers by id", Has(cOne, '"row":["1","opening"]'), TRUE)
	When("a client GETs an id that does not exist")
	cMissing = Hit("GET", "/api/ledger/999", "")
	Then("it is still an honest 404, not a 405", Has(cMissing, "404 Not Found"), TRUE)
EndScenario()

Scenario("a read-only table refuses every verb that writes")
	Given("the same ledger with one row")
	When("a client POSTs a new entry")
	cBody = Hit("POST", "/api/ledger", "entry=forged")
	Then("it is refused with 405", Has(cBody, "405 Method Not Allowed"), TRUE)
	Then("and says why", Has(cBody, "read-only resource"), TRUE)
	Then("no row was inserted", ring_number($oDb.Value("SELECT COUNT(*) FROM ledger")), 1)

	When("a client PUTs over row 1")
	cBody = Hit("PUT", "/api/ledger/1", "entry=rewritten")
	Then("it is refused with 405", Has(cBody, "405 Method Not Allowed"), TRUE)
	Then("the row is unchanged in sqlite", $oDb.Value("SELECT entry FROM ledger WHERE id=1"), "opening")

	When("a client DELETEs row 1")
	cBody = Hit("DELETE", "/api/ledger/1", "")
	Then("it is refused with 405", Has(cBody, "405 Method Not Allowed"), TRUE)
	Then("the row is still in sqlite", ring_number($oDb.Value("SELECT COUNT(*) FROM ledger")), 1)
	Then("and the delete route never ran", Has(cBody, '"deleted"'), FALSE)
EndScenario()

Scenario("the refusal is the route's, not the verb's: Expose still writes")
	Given("a note table exposed with plain Expose, beside the ledger")
	When("a client PUTs then DELETEs a note")
	cPut = Hit("PUT", "/api/note/1", "entry=edited")
	Then("the update is served", Has(cPut, '"updated":1'), TRUE)
	Then("the change is in sqlite", $oDb.Value("SELECT entry FROM note WHERE id=1"), "edited")
	cDel = Hit("DELETE", "/api/note/1", "")
	Then("the delete is served", Has(cDel, '"deleted":1'), TRUE)
	Then("the note is gone", ring_number($oDb.Value("SELECT COUNT(*) FROM note")), 0)
EndScenario()

Scenario("ExposeReadOnlyWithKey reads by its key and refuses writes")
	Given("a tag table keyed by uuid")
	When("a client GETs /api/tag/u-1")
	cOne = Hit("GET", "/api/tag/u-1", "")
	Then("the row is found by uuid", Has(cOne, '"row":["u-1","alpha"]'), TRUE)
	When("a client DELETEs /api/tag/u-1")
	cDel = Hit("DELETE", "/api/tag/u-1", "")
	Then("it is refused with 405", Has(cDel, "405 Method Not Allowed"), TRUE)
	Then("the row is still there", ring_number($oDb.Value("SELECT COUNT(*) FROM tag")), 1)
EndScenario()

Scenario("teardown")
	oSrv.Stop()
	$oDb.Close()
	oClient.Destroy()
	Then("teardown completes without crash", TRUE, TRUE)
EndScenario()

func Hit(cMethod, cPath, cForm)
	cReq = cMethod + " " + cPath + " HTTP/1.1" + $CRLF + "Host: local" + $CRLF
	if cForm != ""
		cReq += "Content-Length: " + len(cForm) + $CRLF
	ok
	cReq += "Connection: close" + $CRLF + $CRLF + cForm
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	return oClient.AwaitTcp(nJob, 5000)

func Has(cText, cNeedle)
	return StzFindFirst(cNeedle, cText) > 0
