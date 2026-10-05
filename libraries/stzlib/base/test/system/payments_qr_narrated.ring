load "../../stzBase.ring"
load "../_narrated.ring"

# PY7 of the payments plane: THE PI-SPI QR PAYLOAD, built and read.
#
# A QR code at a till is a picture of a string, and the string is the BCEAO's: an EMV payload whose
# one account is the receiver's PI-SPI alias, closed by a CRC-16. This guard is about THE STRING. The
# picture (the matrix a camera reads) is a different layer and is not here.
#
# WHAT A COUNTER CAN SEE AND WHAT IT CANNOT. Four expected payloads below were produced by an
# INDEPENDENT builder in Python (payments_qr_vectors.py, which re-checks them against this file with
# --check), so Ring is held against a second implementation and not against itself. That proves the
# two AGREE. It does not prove a BCEAO phone accepts the string. Only a person scanning it with a
# PI-SPI application can say so, and the last scene says that nobody has: UNPERCEIVED.
#
# Ring's `=` on two strings ignores case, and a CRC is upper-case hexadecimal while an alias is lower:
# every equality that matters here goes through Same(), which is strcmp.
#
# The four vectors, kept as comment lines so the Python check can read them and so there is ONE copy
# of each: the scenes below read them back from this very file.
# VECTOR static-no-amount 00020136560012int.bceao.pi01363497a720-ab11-4973-9619-534e04f263a15204000053039525802CI5901X6001X62210510CAISSE_A01110300063042345
# VECTOR static-fixed 00020136560012int.bceao.pi01363497a720-ab11-4973-9619-534e04f263a1520400005303952540415005802CI5901X6001X62290518Produit-ABC-123654110300063049C73
# VECTOR dynamic 00020136560012int.bceao.pi01363497a720-ab11-4973-9619-534e04f263a15204000053039525405825005802CI5901X6001X62330522Tx-20251112-055052-001110340063041994
# VECTOR dynamic-niger-purpose-custom 00020136560012int.bceao.pi01363497a720-ab11-4973-9619-534e04f263a15204000053039525405185005802NE5901X6001X62540514VENTE-2026-00111034001210Panier-0010701xAA01aZZ01b63041BEA

$cAlias = "3497a720-ab11-4973-9619-534e04f263a1"

Scenario("the checksum: CRC-16/CCITT-FALSE, the one the BCEAO names")
	Then("the published check value of the algorithm, over '123456789', is 29B1",
		Same(StzPispiQrCrc16("123456789"), "29B1"), 1)
	Then("over nothing it is the initial value, FFFF", Same(StzPispiQrCrc16(""), "FFFF"), 1)
	Then("it is always four characters, zero-padded on the left", ring_len(StzPispiQrCrc16("a")), 4)
	Then("one changed character changes it", Same(StzPispiQrCrc16("PI-SPI"), StzPispiQrCrc16("PI-SPJ")), 0)
EndScenario()

Scenario("four codes, each equal to what an independent builder wrote")
	oA = StzPispiQrQ()
	oA.WithAlias($cAlias)
	oA.InCountry("CI")
	oA.AsStatic()
	oA.WithReference("CAISSE_A01")
	Then("a static code with no amount: the payer types it", Same(oA.Payload(), VectorNamed("static-no-amount")), 1)

	oB = StzPispiQrQ()
	oB.WithAlias($cAlias)
	oB.InCountry("ci")
	oB.AsStatic()
	oB.WithReference("Produit-ABC-123654")
	oB.WithAmount(StzAmountQ("1500", "XOF"))
	Then("a static code with a fixed amount (the country given in lower case)",
		Same(oB.Payload(), VectorNamed("static-fixed")), 1)

	oC = StzPispiQrQ()
	oC.WithAlias($cAlias)
	oC.InCountry("CI")
	oC.AsDynamic()
	oC.WithReference("Tx-20251112-055052-001")
	oC.WithAmount(StzAmountQ("82500", "XOF"))
	Then("a dynamic code, made for one sale", Same(oC.Payload(), VectorNamed("dynamic")), 1)

	oD = StzPispiQrQ()
	oD.WithAlias($cAlias)
	oD.InCountry("NE")
	oD.AsDynamic()
	oD.WithReference("VENTE-2026-001")
	oD.WithAmount(StzAmountQ("18500", "XOF"))
	oD.WithPurpose("Panier-001")
	oD.WithCustom("ZZ", "b")
	oD.WithCustom("AA", "a")
	oD.WithCustom("07", "x")
	Then("a Niger code with a purpose and the receiver's own tags",
		Same(oD.Payload(), VectorNamed("dynamic-niger-purpose-custom")), 1)
	Then("...sorted by name, digits before capitals, as in the BCEAO's builder",
		StzFindFirst("0701xAA01aZZ01b", oD.Payload()) > 0, TRUE)
EndScenario()

Scenario("what is built is read back: nothing is lost on the way")
	for i = 1 to 4
		aR = StzPispiQrParse(VectorAt(i))
		Then("vector " + i + " is valid", aR[:valid], 1)
		Then("...with no error", len(aR[:errors]), 0)
	next
	aD = StzPispiQrParse(VectorNamed("dynamic"))[:data]
	Then("the alias comes back", Same(aD[:alias], $cAlias), 1)
	Then("the country comes back", aD[:countryCode], "CI")
	Then("the type is read from the channel", aD[:qrType], "DYNAMIC")
	Then("the amount is whole francs, as digits", aD[:amount], "82500")
	Then("the label comes back", Same(aD[:referenceLabel], "Tx-20251112-055052-001"), 1)
	aS = StzPispiQrParse(VectorNamed("static-no-amount"))[:data]
	Then("a static code with no amount reads as one", aS[:qrType] + "|" + aS[:amount], "STATIC|")
	aN = StzPispiQrParse(VectorNamed("dynamic-niger-purpose-custom"))[:data]
	Then("the purpose comes back", aN[:purpose], "Panier-001")
EndScenario()

Scenario("the builder refuses what would print a bad code")
	Then("an alias that is not the shape of a UUID", BuildRaises("alias", "not-an-alias"), 1)
	Then("an alias of the right length with its hyphens in the wrong places",
		BuildRaises("alias", "3497a720ab114973-9619-534e04f263a1xx"), 1)
	Then("a country outside the union", BuildRaises("country", "FR"), 1)
	Then("a reference label over 25 characters", BuildRaises("label", "0123456789012345678901234x"), 1)
	Then("...25 exactly is fine", BuildRaises("label", "0123456789012345678901234"), 0)
	Then("no reference label at all", BuildRaises("label", ""), 1)
	Then("a label outside printable ASCII (a TLV length counts characters)",
		BuildRaises("label", "Caf" + char(195) + char(169)), 1)
	Then("an amount in another currency", BuildRaises("eur", ""), 1)
	Then("a zero amount", BuildRaises("zero", ""), 1)
	Then("a custom tag in lower case, whose order the BCEAO's builder leaves to a locale", BuildRaises("tag", "ab"), 1)
	Then("a custom tag of three characters", BuildRaises("tag", "ABC"), 1)
	Then("asking for a payload before saying static or dynamic", BuildRaises("channel", ""), 1)
	Then("and a plain valid code does not raise", BuildRaises("none", ""), 0)
EndScenario()

Scenario("the reader says what is wrong, and never raises")
	cGood = VectorNamed("dynamic")
	Then("a single changed digit in the amount: the CRC no longer matches",
		HasError(StzPispiQrParse(Replace1(cGood, "5405825005802", "5405825015802")), "CRC"), 1)
	Then("a payload cut short is not valid", StzPispiQrParse(Left20(cGood))[:valid], 0)
	Then("...and says it is malformed", HasError(StzPispiQrParse(Left20(cGood)), "malformed"), 1)
	Then("an empty string is not valid", StzPispiQrParse("")[:valid], 0)
	Then("the invalid example the SDK's own tests use: no account named",
		HasError(StzPispiQrParse("0002010102126304BEEF"), "tag 36"), 1)

	Then("another scheme in tag 36", PErr(Resealed(Replace1(cGood, "int.bceao.pi", "int.bceao.pj")), "scheme"), 1)
	Then("a currency that is not 952", PErr(Resealed(Replace1(cGood, "5303952", "5303978")), "952"), 1)
	Then("a country outside the union", PErr(Resealed(Replace1(cGood, "5802CI", "5802FR")), "country"), 1)
	Then("an amount with a decimal point", PErr(Resealed(Replace1(cGood, "540582500", "54058250.")), "amount"), 1)
	Then("a payload with no reference label",
		PErr(Resealed(Replace1(cGood, "62330522Tx-20251112-055052-001", "6207")), "62-05"), 1)
	Then("...and those were caught by their OWN reason, not the CRC, since the CRC was recomputed",
		PErr(Resealed(Replace1(cGood, "5303952", "5303978")), "CRC"), 0)
EndScenario()

Scenario("what the BCEAO's own material does that its builder does not")
	cGood = VectorNamed("dynamic")
	aP = StzPispiQrParse(Resealed(Replace1(cGood, "0002013656", "0002010102113656")))
	Then("a tag 01 (point of initiation, in the portal's own validator placeholder) is accepted", aP[:valid], 1)
	Then("...and noted, because the builder does not emit it", len(aP[:notes]), 1)
	aT = StzPispiQrParse(Resealed(Replace1(cGood, "1103400", "1103731")))
	Then("channel 731, a transfer QR the PAYER presents, is read and not refused", aT[:valid], 1)
	Then("...and noted as one a platform reads and does not make", StzFindFirst("731", aT[:notes][1]) > 0, TRUE)
	aF = StzPispiQrParse(Resealed(Replace1(cGood, "1103400", "1103500")))
	Then("channel 500, which the BCEAO's worked example carries and its portal never lists, is read", aF[:valid], 1)
	Then("...and noted as unlisted", StzFindFirst("not one the BCEAO", aF[:notes][1]) > 0, TRUE)
	Then("an unlisted channel reads as neither static nor dynamic", aF[:data][:qrType], "OTHER")
EndScenario()

Scenario("the code of the twin's own business account")
	oHub = StzPiSpiSandboxQ()
	oQ = StzPispiQrQ()
	oQ.WithAlias(oHub.BusinessAlias())
	oQ.InCountry("NE")
	oQ.AsDynamic()
	oQ.WithReference("BOUTIQUE-2026-001")
	oQ.WithAmount(StzAmountQ("18500", "XOF"))
	aR = StzPispiQrParse(oQ.Payload())
	Then("the twin's alias is a UUID the builder accepts, and the code is valid", aR[:valid], 1)
	aRd = aR[:data]
	Then("it is the twin's alias that the code names", Same(aRd[:alias], oHub.BusinessAlias()), 1)
EndScenario()

Scenario("what nobody has perceived")
	Then("the oracle script a person runs against the BCEAO's own SDK exists beside this guard",
		StzFileExists("payments_qr_oracle.mjs"), 1)
	? "  UNPERCEIVED: no PI-SPI application has scanned a code made here, and the BCEAO's SDK has not been"
	? "  compared with these four strings. A named person runs payments_qr_oracle.mjs (it needs the SDK:"
	? "  npm install @pi-spi/qrcode) and scans a rendered code with a PI-SPI app, and records who and what"
	? "  they saw. Until then every PASS above means Ring and Python agree, and nothing more."
EndScenario()

Summary()

# --- helpers -------------------------------------------------------------

# a case-sensitive equality: Ring's = on strings ignores case
func Same(a, b)
	if strcmp(a, b) = 0
		return 1
	ok
	return 0

# the vectors are read from this very file's comment lines, so there is ONE copy of each
func VectorAt(n)
	aLines = split(read("payments_qr_narrated.ring"), char(10))
	k = 0
	for i = 1 to len(aLines)
		cL = aLines[i]
		if left(cL, 9) = "# VECTOR "
			k++
			if k = n
				aPart = split(cL, " ")
				return trim(aPart[len(aPart)])
			ok
		ok
	next
	return ""

func VectorNamed(cName)
	aLines = split(read("payments_qr_narrated.ring"), char(10))
	for i = 1 to len(aLines)
		cL = aLines[i]
		if left(cL, 9) = "# VECTOR "
			aPart = split(cL, " ")
			if aPart[3] = cName
				return trim(aPart[len(aPart)])
			ok
		ok
	next
	return ""

# builds a code with ONE thing wrong, or nothing wrong for "none"; answers 1 when the builder raised
func BuildRaises(cWhat, cValue)
	oQ = StzPispiQrQ()
	oQ.WithAlias($cAlias)
	oQ.InCountry("CI")
	oQ.AsDynamic()
	oQ.WithReference("VENTE-1")
	if cWhat = "alias"
		oQ.WithAlias(cValue)
	but cWhat = "country"
		oQ.InCountry(cValue)
	but cWhat = "label"
		oQ.WithReference(cValue)
	but cWhat = "eur"
		try
			oQ.WithAmount(StzAmountQ("10", "EUR"))
		catch
			return 1
		done
	but cWhat = "zero"
		try
			oQ.WithAmount(StzAmountQ("0", "XOF"))
		catch
			return 1
		done
	but cWhat = "tag"
		oQ.WithCustom(cValue, "x")
	but cWhat = "channel"
		oQ = StzPispiQrQ()
		oQ.WithAlias($cAlias)
		oQ.InCountry("CI")
		oQ.WithReference("VENTE-1")
	ok
	try
		oQ.Payload()
	catch
		return 1
	done
	return 0

func HasError(aResult, cPart)
	aE = aResult[:errors]
	for i = 1 to len(aE)
		if StzFindFirst(cPart, aE[i]) > 0
			return 1
		ok
	next
	return 0

# replaces the first occurrence, and refuses if there is none: a test whose edit missed would pass for the wrong reason
func Replace1(cStr, cOld, cNew)
	nAt = StzFindFirst(cOld, cStr)
	if nAt = 0
		raise("Replace1: " + cOld + " is not in the payload")
	ok
	return left(cStr, nAt - 1) + cNew + right(cStr, len(cStr) - nAt - len(cOld) + 1)

func Left20(cStr)
	return left(cStr, 20)

# a payload whose body was edited, with its CRC recomputed, so the only fault is the edit
func Resealed(cEdited)
	cBody = left(cEdited, len(cEdited) - 4)
	return cBody + StzPispiQrCrc16(cBody)

# reads a payload and says whether one of its errors mentions cPart
func PErr(cPayload, cPart)
	return HasError(StzPispiQrParse(cPayload), cPart)
