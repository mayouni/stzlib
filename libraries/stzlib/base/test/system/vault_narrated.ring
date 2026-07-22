# The pluggable VAULT SEAM -- a :vault-sourced secret is fetched through a
# resolver you supply, so Softanza binds to no one backend.
#
# The contract: any object with Resolve(locator) is a valid resolver. Softanza
# ships stzVaultResolver (in-memory, for dev/test); production replaces it with a
# client for HashiCorp Vault / AWS Secrets Manager / a KMS. The secret, the store,
# and the actor gate do not change -- only the resolver.
#
# Ring traps avoided: no oR/nL locals; main before the first func; no inline
# new X().M(); custom class has an empty init(); try/catch/done for raises.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

oHuman = HumanActor("ops")
oLLM   = LLMActor("planner")

# a resolver seeded for dev -- a real one fetches from the external manager.
oVault = new stzVaultResolver("dev")
oVault.Register("secret/prod/db#password", "hunter2-from-vault")

oKey = new stzSecret("db")
oKey.FromVaultQ("secret/prod/db#password")

? "-- Scene 1: a vault-sourced secret is fetched THROUGH a resolver --"
chk("the secret knows it is vault-sourced", oKey.IsVaultSourced())
chk("...its descriptor shows the vault LOCATOR, never a value", StzFindFirst("vault:secret/prod/db", oKey.Descriptor()) > 0)
chk("RevealVia(resolver, effectful) fetches the value from the vault", oKey.RevealVia(oVault, oHuman) = "hunter2-from-vault")

? ""
? "-- Scene 2: the reveal is GOVERNED -- the gate applies BEFORE the fetch --"
bRefused = FALSE
try
	oKey.RevealVia(oVault, oLLM)
catch
	bRefused = TRUE
done
chk("an LLM is refused -- it never reaches the vault", bRefused)

? ""
? "-- Scene 3: a vault secret cannot be revealed without a resolver --"
bNeedsResolver = FALSE
try
	oKey.Reveal(oHuman)                 # no resolver -> must raise, directing to RevealVia
catch
	bNeedsResolver = TRUE
done
chk("Reveal(actor) on a vault secret raises (directs to RevealVia)", bNeedsResolver)
bNoRes = FALSE
try
	oKey.RevealVia(NULL, oHuman)        # RevealVia with no resolver
catch
	bNoRes = TRUE
done
chk("...RevealVia without a resolver raises too", bNoRes)
chk("...and it is not 'resolvable' the plain way (needs a resolver)", NOT oKey.IsResolvableBy(oHuman))

? ""
? "-- Scene 4: the resolver is a DUCK-TYPED contract -- any Resolve(locator) --"
oMine = new myVaultClient()               # a custom object, not a stzVaultResolver
chk("a custom resolver object satisfies the contract", oKey.RevealVia(oMine, oHuman) = "from-my-vault")

? ""
? "-- Scene 5: a vault secret lives in the store -- revealed via resolver, AUDITED --"
oStore = new stzSecretStore("proj")
oStore.Register(oKey)
chk("the store holds the vault secret (redacted)", StzFindFirst("<secret 'db'", oStore.DescriptorOf("db")) > 0)
nBefore = oStore.NumberOfAccesses()
chk("store.RevealVia(name, resolver, effectful) fetches through the vault", oStore.RevealVia("db", oVault, oHuman) = "hunter2-from-vault")
chk("...and the store AUDITED it (one governed door)", oStore.NumberOfAccesses() = nBefore + 1)
bStoreNoRes = FALSE
try
	oStore.Reveal("db", oHuman)         # plain store Reveal -> no resolver for a vault secret
catch
	bStoreNoRes = TRUE
done
chk("...plain store.Reveal on a vault secret raises (needs a resolver)", bStoreNoRes)
bStoreLlm = FALSE
try
	oStore.RevealVia("db", oVault, oLLM)
catch
	bStoreLlm = TRUE
done
chk("...an LLM via the store is refused AND logged refused", bStoreLlm and oStore.RefusedAccesses() >= 1)

? ""
? "-- Scene 6: RevealVia is a safe SUPERSET -- non-vault secrets ignore it --"
oLit = new stzSecret("inline")
oLit.FromLiteralQ("plain-value")
chk("RevealVia on a literal secret ignores the resolver", oLit.RevealVia(oVault, oHuman) = "plain-value")
chk("...its Reveal(actor) still works directly", oLit.Reveal(oHuman) = "plain-value")

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

# a custom vault client -- ANY object exposing Resolve(locator) is a valid
# resolver (the empty init() avoids the param-less-class R19 trap).
class myVaultClient
	def init()
	def Resolve(pcLocator)
		return "from-my-vault"
	def Has(pcLocator)
		return TRUE
