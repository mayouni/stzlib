load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-KINDFACTORY-01 -- the secret store names no plane.
#
# Payments PY3 taught the sealed store to read its descriptors back by
# naming the payments class inside the store: a security file depending on
# a payments file, so a sealed file written with payments loaded could not
# be read without it. The store now finds a kind's family by NAME: a kind
# "<family>-<part>" is built by StzSecretFromKind_<family>(name, part) when
# that function is loaded, and is otherwise read as a plain secret that
# keeps its kind -- never refused.

$oHuman = HumanActor("oncall")
$cStore = "_tmp_kind_factory.sealed"

Scenario("a payments descriptor comes back as itself, expiry included")
	oKey = StzSecretQ("master-key").FromLiteralQ(StzNewSealKey())
	oS = new stzSecretStore("billing")
	oP = new stzPispiSecret("bia-mtls-cert", "mtls-cert")
	oP.FromLiteral("-----BEGIN CERTIFICATE-----")
	oP.SetExpiry(1800000000)
	oS.Register(oP)
	oS.SaveSealedTo($cStore, oKey, $oHuman)
	oBack = StzSecretStoreFromSealedFile($cStore, oKey, $oHuman).Secret("bia-mtls-cert")
	Then("the class is the payments one", classname(oBack), "stzpispisecret")
	Then("...with its part", oBack.Part(), "mtls-cert")
	Then("...and its expiry", oBack.ExpiresAt(), 1800000000)
	CleanUp()
EndScenario()

Scenario("any family can own its kinds, by defining one function")
	oKey = StzSecretQ("master-key").FromLiteralQ(StzNewSealKey())
	oS = new stzSecretStore("demo")
	oT = new stzToken("demo-a")
	oT.SetKind("demo-session")
	oT.FromLiteral("v")
	oS.Register(oT)
	oS.SaveSealedTo($cStore, oKey, $oHuman)
	oBack = StzSecretStoreFromSealedFile($cStore, oKey, $oHuman).Secret("demo-a")
	Then("the guard's own factory built it", classname(oBack), "demofamilysecret")
	Then("...given the part after the first dash", oBack.@cPart, "session")
	CleanUp()
EndScenario()

Scenario("a family with no factory loaded is read, not refused (negative sibling)")
	oKey = StzSecretQ("master-key").FromLiteralQ(StzNewSealKey())
	oS = new stzSecretStore("acme")
	oX = new stzSecret("acme-key")
	oX.SetKind("acme-signing")
	oX.FromLiteral("v")
	oS.Register(oX)
	oS.SaveSealedTo($cStore, oKey, $oHuman)
	oBack = StzSecretStoreFromSealedFile($cStore, oKey, $oHuman).Secret("acme-key")
	Then("it loads as a plain secret", classname(oBack), "stzsecret")
	Then("...that keeps its kind", oBack.Kind(), "acme-signing")
	CleanUp()
EndScenario()

Summary()

# -- helpers (after the main code) ------------------------------------

func StzSecretFromKind_demo pcName, pcPart
	return new demoFamilySecret(pcName, pcPart)

func CleanUp
	if fexists($cStore)  remove($cStore)  ok

class demoFamilySecret from stzToken
	@cPart = ""
	def init(pcName, pcPart)
		@cName = "" + pcName
		@cPart = "" + pcPart
		@cKind = "demo-" + pcPart
