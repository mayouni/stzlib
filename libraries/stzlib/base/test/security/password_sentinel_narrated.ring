load "../../stzBase.ring"
load "../_narrated.ring"

# The OpenSSH 10.6p2 bypass (2026-11-05), read against our own verifier.
#
# On musl with PAM off, crypt(3) answered "*" for a password over 256
# characters, and an account whose stored hash was "*" compared equal: any
# long password logged in. The root cause was outside OpenSSH; its fix refuses
# a stored hash shorter than a minimum. The shape is general: an ERROR VALUE
# from a hash meeting a stored SENTINEL. Our compare answers ConstEqual("", "")
# = 1, so the PBKDF2 path refuses a short hash on either side before comparing.

Scenario("1. the trap the refusal exists for")
	Then("the constant-time compare calls two empty texts equal", StzEngineCryptoConstEqual("", ""), 1)
	Then("PBKDF2 answers 64 hex for an overlong password -- today", len(StzEngineCryptoPbkdf2(copy("a", 1024), "salt", 1000, 32)), 64)
EndScenario()

Scenario("2. no sentinel or short stored hash verifies, for any length of password")
	aPw = [ "", "a", copy("a", 256), copy("a", 257), copy("a", 1024), copy("a", 100000) ]
	aSt = [ "*", "!", "salt:", ":", "*:*", "salt:" + copy("0", 63), "$argon2id$", "$argon2id$v=19$m=65536,t=3,p=4$", "" ]
	nAccepted = 0
	for i = 1 to len(aPw)
		for j = 1 to len(aSt)
			r = 0
			try
				r = StzVerifyPassword(aPw[i], aSt[j])
			catch
				r = 0
			done
			if r = 1  nAccepted++  ok
		next
	next
	? "  NUMBER " + (len(aPw) * len(aSt)) + " password and stored-record pairs tried"
	Then("NUMBER -- accepted", nAccepted, 0)
EndScenario()

Scenario("3. real records still verify (negative siblings)")
	cA = StzHashPassword("right horse battery")
	Then("Argon2id: the right password", StzVerifyPassword("right horse battery", cA), 1)
	Then("Argon2id: a wrong one", StzVerifyPassword("wrong", cA), 0)
	Then("Argon2id: an overlong one", StzVerifyPassword(copy("a", 1024), cA), 0)
	cP = StzHashSecretXT("legacy secret", 1000)
	Then("legacy PBKDF2: the right secret", StzVerifySecretXT("legacy secret", cP, 1000), 1)
	Then("legacy PBKDF2: a wrong one", StzVerifySecretXT("other", cP, 1000), 0)
	Then("legacy PBKDF2 with its hash cut to 63 hex is refused, not compared", StzVerifySecretXT("legacy secret", left(cP, len(cP) - 1), 1000), 0)
EndScenario()

Summary()
shutdown($_zst_fail)
