load "../../stzBase.ring"

# PY5 stage (b): THE CONFORMANCE RUN, against the BCEAO's sandbox, under DIKO's sandbox account.
#
# This is the one stage the plane cannot perform by itself, and it says so. It needs credentials that
# only the author holds (the author is the mandataire of DIKO's sandbox account), and it needs a
# PERSON to look: a payment that landed in the BCEAO's sandbox is a fact about the world, and a
# counter cannot see it. Until a named person has watched it land in the sandbox dashboard, every
# line this prints is UNPERCEIVED, and the plane reports it so.
#
#     set PISPI_BASE_URL=https://<the sandbox's base URL from the portal, version included>
#     set PISPI_CLIENT_ID=...          set PISPI_CLIENT_SECRET=...      set PISPI_API_KEY=...
#     (optional)  PISPI_TOKEN_URL  PISPI_SCOPE_PREFIX (default piz/)  PISPI_CA
#                 PISPI_PAYER_ALIAS  PISPI_PAYEE_ALIAS  PISPI_PAY=1
#     cd libraries/stzlib/base/test/system && ring payments_conformance_run.ring
#
# What it does, in order, and stops at the first thing that is not true: ask for a token, list the
# accounts, list the participants, resolve the payee's alias if one is given, and ONLY IF PISPI_PAY=1
# send one payment of 100 francs of virtual money from the payer to the payee. The sandbox mTLS is
# off, so no certificate is presented. It never prints a secret, and it never creates an account:
# opening the sandbox account is the author's act, on the portal, and nothing here submits a form.
#
# Without the variables it prints what is missing and exits 0: a run that could not happen is
# UNPERCEIVED, never a failure and never a pass.

aNeed = [ "PISPI_BASE_URL", "PISPI_CLIENT_ID", "PISPI_CLIENT_SECRET", "PISPI_API_KEY" ]
aMissing = []
for i = 1 to len(aNeed)
	if EnvVar(aNeed[i]) = ""
		aMissing + aNeed[i]
	ok
next
if len(aMissing) > 0
	? "UNPERCEIVED: the BCEAO sandbox has not been reached from this machine."
	cList = ""
	for i = 1 to len(aMissing)
		if i > 1  cList += ", "  ok
		cList += aMissing[i]
	next
	? "  missing: " + cList
	? "  the author brings DIKO's sandbox credentials (the author is the mandataire of that account),"
	? "  sets the variables named at the top of this file, and runs it again. Until a named person has"
	? "  watched a payment land in the sandbox dashboard, nothing about the live adapter is perceived."
	bye
ok

cPrefix = EnvVar("PISPI_SCOPE_PREFIX")
if cPrefix = ""
	cPrefix = "piz/"
ok
oStore = StzSecretStoreQ("diko-sandbox")
oClient = StzPispiSecretQ("sandbox", "client")
oClient.FromLiteral(EnvVar("PISPI_CLIENT_ID") + ":" + EnvVar("PISPI_CLIENT_SECRET"))
oStore.Register(oClient)
oKey = StzPispiSecretQ("sandbox", "api-key")
oKey.FromLiteral(EnvVar("PISPI_API_KEY"))
oStore.Register(oKey)

oAd = StzPispiHttpAdapterQ()
oAd.WithParticipant("sandbox")
oAd.WithBaseUrl(EnvVar("PISPI_BASE_URL"))
oAd.WithScopePrefix(cPrefix)
oAd.WithSecretsFrom(oStore, HumanActor("author"))
oAd.AsConformance()
if EnvVar("PISPI_TOKEN_URL") != ""
	oAd.WithTokenUrl(EnvVar("PISPI_TOKEN_URL"))
ok
if EnvVar("PISPI_CA") != ""
	oAd.WithCaFile(EnvVar("PISPI_CA"))
ok
oPay = StzPaymentsPortQ(oAd)
oPay.AllowUngovernedPayouts()      # virtual money, a conformance run, no plan to commit

? "conformance run against " + EnvVar("PISPI_BASE_URL")
try
	aAcc = oPay.Accounts()
	? "  accounts: " + len(aAcc)
	aPart = oPay.Participants()
	? "  participants: " + len(aPart)
	if EnvVar("PISPI_PAYEE_ALIAS") != ""
		aWho = oPay.ResolveAlias(EnvVar("PISPI_PAYEE_ALIAS"))
		aCl = _StzPiGet(aWho, "client", [])
		? "  payee resolves to: " + _StzPiGet(aCl, "nom", "?") + " (" + _StzPiGet(aCl, "categorie", "?") + ")"
	ok
	if EnvVar("PISPI_PAY") = "1" and EnvVar("PISPI_PAYER_ALIAS") != "" and EnvVar("PISPI_PAYEE_ALIAS") != ""
		cTx = "CONF-" + StzEngineTimeNowMs()
		oO = StzPaymentOrderQ()
		oO.WithTxId(cTx)
		oO.FromAlias(EnvVar("PISPI_PAYER_ALIAS"))
		oO.ToAlias(EnvVar("PISPI_PAYEE_ALIAS"))
		oO.WithAmount(StzAmountQ("100", "XOF"))
		oO.WithoutConfirmation()
		aP = oPay.Pay(oO)
		? "  payment sent: txId " + cTx + ", statut " + _StzPiGet(aP, "statut", "?") + ", end2endId " + _StzPiGet(aP, "end2endId", "?")
		? "  PERCEPTION OWED: a named person must open the sandbox dashboard and see payment " + cTx + " land,"
		? "  and record who, what they saw and when. Until then this run is UNPERCEIVED."
	else
		? "  no payment was sent (PISPI_PAY=1 with both aliases sends one of 100 francs of virtual money)."
		? "  Reads succeeded; they prove the token, the API key and the scopes, not a payment."
	ok
catch
	? "  STOPPED at the first thing that was not true: " + cCatchError
done
? "STATUS: UNPERCEIVED until a named person has seen a payment land in the sandbox dashboard."
