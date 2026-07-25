load "../../stzBase.ring"
load "../_narrated.ring"

# stzDataPort -- phase 2 of the service-virtualization plane: the DATABASE
# exemplar, chosen deliberately because it proves the pattern with code that
# already works.
#
# A data port is "any object with Exec(sql) / Rows(sql) / Value(sql)" -- the
# surface stzDatabase already had. So the port is not new machinery; it is a name
# for a shape the library owned all along.
#
# WHAT MAKES THIS THE INTERESTING EXEMPLAR: every other double in this plane is a
# FAKE. A mail sandbox does not send; an OIDC sandbox is not Google. But a database
# "sandbox" is SQLITE -- a real database that happens to live in a file you own.
# The plan calls that LOCAL-REAL, and it is why nobody needs a hosted-DB
# subscription to write a data-backed application today.
#
# And that forced a genuine refinement of phase 1. The registry's fake/real split
# was too coarse: a fake must never ship, but a local-real source shipping is not a
# violation at all -- plenty of good systems run sqlite in production forever. So
# there are now THREE postures, and one new invariant for the one case that IS
# dangerous: an in-memory database, which is real right up to the moment the
# process restarts.

$DB = CurrentDir() + "/_dataport_test.db"

Scenario("the port is three methods, and sqlite already speaks them")
	if isString($DB) and fexists($DB)  remove($DB)  ok
	oSrc = StzSqliteDataSourceQ($DB)

	oSrc.Exec("CREATE TABLE dish (id INTEGER PRIMARY KEY, name TEXT, price INTEGER)")
	oSrc.Exec("INSERT INTO dish (name, price) VALUES ('Tajine', 120)")
	oSrc.Exec("INSERT INTO dish (name, price) VALUES ('Couscous', 90)")

	Then("Rows returns rows", len(oSrc.Rows("SELECT * FROM dish")), 2)
	Then("Value returns one value", ring_number(oSrc.Value("SELECT SUM(price) FROM dish")), 210)
	Then("the table is there", oSrc.TableExists("dish"), TRUE)
	Then("...and enumerable", @@(oSrc.Tables()), @@([ "dish" ]))
	Then("...and countable", oSrc.RowCount("dish"), 2)
	Then("a table that does not exist counts zero rather than raising", oSrc.RowCount("nope"), 0)
EndScenario()

Scenario("local-real is NOT a fake -- and that distinction is load-bearing")
	oSrc = StzSqliteDataSourceQ($DB)
	Then("it declares itself local-real", oSrc.IsLocalReal(), TRUE)
	Then("...and file-backed, so it survives a restart", oSrc.IsEphemeral(), FALSE)

	Given("an in-memory source")
	oMem = StzMemoryDataSourceQ()
	oMem.Exec("CREATE TABLE t (x INTEGER)")
	Then("it is a GENUINE database -- the table really exists", oMem.TableExists("t"), TRUE)
	oMem.Exec("INSERT INTO t VALUES (7)")
	Then("...that really stores things", ring_number(oMem.Value("SELECT x FROM t")), 7)
	Then("...but it vanishes on restart, and says so", oMem.IsEphemeral(), TRUE)
	# indistinguishable from the safe thing until the process dies, and one
	# character away from it -- which is why it needs a check, not a convention.
EndScenario()

Scenario("the registry learned a THIRD posture from this exemplar")
	oReg = new stzServiceRegistry("restolean")
	oReg.BindLocal(:database, StzSqliteDataSourceQ($DB))
	oReg.BindSandbox(:mail, new stzMailSandbox())

	Then("the database is local", oReg.PostureOf(:database), :local)
	Then("the mail double is a sandbox", oReg.PostureOf(:mail), :sandbox)
	Then("...and the posture is auto-detected from the OBJECT",
	     oReg.BindQ(:db2, StzSqliteDataSourceQ($DB)).PostureOf(:db2), :local)
	Then("each list is available", @@(oReg.LocalServices()), @@([ "database", "db2" ]))
	Then("...separately", @@(oReg.SandboxedServices()), @@([ "mail" ]))

	When("the application uses the service")
	oDb = oReg.Service(:database)
	Then("it queries through the port, never naming an implementation",
	     ring_number(oDb.Value("SELECT COUNT(*) FROM dish")), 2)
EndScenario()

Scenario("in production a FAKE blocks, but a local-real source may ship")
	oReg = new stzServiceRegistry("restolean")
	oReg.BindLocal(:database, StzSqliteDataSourceQ($DB))
	oReg.BindSandbox(:mail, new stzMailSandbox())
	oReg.SetPhase(:production)

	Then("it is not sound", oReg.IsSound(), FALSE)
	Then("...and the ONLY complaint is the fake", len(oReg.Findings()), 1)
	Then("...named", oReg.Findings()[1][:invariant], "sandbox-in-production")
	Then("...pointing at mail, NOT at the database", oReg.Findings()[1][:where], "restolean/mail")

	When("the dependency on mail is retired entirely")
	oReg.Undeclare(:mail)
	Then("a self-hosted sqlite in production is perfectly sound", oReg.IsSound(), TRUE)
	# self-hosting is a choice, not a mistake.
EndScenario()

Scenario("Unbind and Undeclare mean different things")
	oReg = new stzServiceRegistry("restolean")
	oReg.BindSandbox(:mail, new stzMailSandbox())
	Then("bound and sound", oReg.IsSound(), TRUE)

	When("the implementation is removed")
	oReg.Unbind(:mail)
	Then("the DEPENDENCY remains, so it is now an error", oReg.IsSound(), FALSE)
	Then("...named", oReg.Findings()[1][:invariant], "unbound-service")
	# correct: your solution still needs mail, it just has nothing to serve it.

	When("the dependency itself is retired")
	oReg.Undeclare(:mail)
	Then("nothing is outstanding", len(oReg.Findings()), 0)
	Then("...and it is no longer declared", oReg.IsDeclared(:mail), FALSE)
EndScenario()

Scenario("an EPHEMERAL database in production is the one real trap")
	oReg = new stzServiceRegistry("ephemeral-app")
	oReg.BindLocal(:database, StzMemoryDataSourceQ())

	Then("in development it is fine -- this is what tests want", oReg.IsSound(), TRUE)

	When("the phase becomes production")
	oReg.SetPhase(:production)
	Then("it is NOT sound", oReg.IsSound(), FALSE)
	Then("...named for what is wrong", oReg.Findings()[1][:invariant], "ephemeral-in-production")
	Then("...and explained", StzFindFirst("vanishes on restart", oReg.Findings()[1][:message]) > 0, TRUE)
	Then("a FILE-backed source in the same phase is sound",
	     (new stzServiceRegistry("ok")).SetPhaseQ(:production).BindLocalQ(:database,
	        StzSqliteDataSourceQ($DB)).IsSound(), TRUE)
EndScenario()

Scenario("swapping to a hosted adapter changes no application code")
	oReg = new stzServiceRegistry("restolean")
	oReg.BindLocal(:database, StzMemoryDataSourceQ())
	oReg.SetPhase(:production)
	Then("the ephemeral local source is refused", oReg.IsSound(), FALSE)

	When("a hosted client is bound instead, naming its credential in the store")
	# a stand-in for a Postgres/MySQL client: any object with Exec/Rows/Value, and
	# no opinion about being a fake -- so the registry treats it as live.
	oReg.BindLive(:database, new stzString("postgres-adapter"), "pg-dsn")
	Then("the posture is live", oReg.PostureOf(:database), :live)
	Then("...the registry holds the secret NAME, never the key", oReg.SecretNameOf(:database), "pg-dsn")
	Then("...and the ephemeral finding is gone", len(oReg.Findings()), 0)

	When("checked against a store that lacks that credential")
	oStore = new stzSecretStore("acme")
	Then("it is refused", oReg.IsSoundVia(oStore), FALSE)
	Then("...for the right reason",
	     StzFindFirst("live-without-secret", @@(oReg.FindingsVia(oStore))) > 0, TRUE)

	When("the credential is registered")
	oStore.Register( (new stzApiKey("pg-dsn")).FromLiteralQ("postgres://live") )
	Then("the surface is sound", oReg.IsSoundVia(oStore), TRUE)
	Then("...and an effectful actor may take it live", oReg.MayGoLive(HumanActor("dana"), oStore), TRUE)
	Then("...while an LLM actor may not", oReg.MayGoLive(LLMActor("assistant"), oStore), FALSE)
	if isString($DB) and fexists($DB)  remove($DB)  ok
EndScenario()

Summary()
