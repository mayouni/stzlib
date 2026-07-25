load "../../stzBase.ring"
load "../_narrated.ring"

# stzXml -- XML as an object you hold.
#
# The library had no XML at all. It got one the long way round: the XML-signature
# work needed a parser it could trust, and that parser turns out to be exactly the
# one an application wants -- so it was promoted to engine/src/xml.zig and is now
# SHARED. stzXml and the SAML code sit on the same implementation.
#
# That sharing is a security property, not tidiness. An identity provider that
# signs with a different canonicalizer than its verifier is the classic
# cross-vendor failure; the only way to be certain they agree is for there to be
# one of them. And the strictness comes along for free: this parser REFUSES any
# document carrying a DOCTYPE or ENTITY declaration, which closes XXE by
# construction rather than by remembering to configure it.
#
# Shape follows stzHtml -- the library's other navigable tree -- so a document, a
# node, and a builder. NOT a String/File split: no format in the library splits
# that way, because a file is a SOURCE, not a different kind of thing.
#
# The path language is deliberately small and is NOT XPath: "a/b/c" walks by local
# name, "//c" finds anywhere, "a/b[2]" indexes siblings.

$X = '<library xmlns="urn:lib" name="City Library">' +
     '<book isbn="1"><title>Dune</title><year>1965</year></book>' +
     '<book isbn="2"><title>Ubik</title><year>1969</year></book>' +
     '</library>'

Scenario("reading a document without holding an object (the stzJsonFuncs shape)")
	Then("it is valid", StzXmlIsValid($X), TRUE)
	Then("the root is named", StzXmlRoot($X), "library")
	Then("a walked path reads text", StzXmlGet($X, "library/book/title"), "Dune")
	Then("an INDEXED step picks a sibling", StzXmlGet($X, "library/book[2]/title"), "Ubik")
	Then("// finds an element anywhere", StzXmlGet($X, "//year"), "1965")
	Then("attributes read", StzXmlAttr($X, "library/book[2]", "isbn"), "2")
	Then("...including on the root", StzXmlAttr($X, "library", "name"), "City Library")
	Then("the namespace is available when it matters", StzXmlNamespace($X, "library/book"), "urn:lib")
	Then("siblings count", StzXmlCount($X, "library/book"), 2)
	Then("...and so does // ", StzXmlCount($X, "//title"), 2)
	Then("child names come back as a list", @@(StzXmlChildren($X, "library/book")), @@([ "title", "year" ]))
	Then("a number reads as a number", StzXmlGetInt($X, "//year") + 1, 1966)
EndScenario()

Scenario("a missing path is REPORTED, never guessed")
	Then("a path that does not exist yields nothing", StzXmlGet($X, "library/nope/title"), "")
	Then("...and does not pretend to exist", StzXmlHas($X, "library/nope"), FALSE)
	Then("...nor to have a count", StzXmlCount($X, "library/nope"), 0)
	Then("an absent attribute yields nothing", StzXmlAttr($X, "library/book", "nosuch"), "")
	Then("a malformed document is invalid", StzXmlIsValid("<broken>"), FALSE)
	Then("junk is invalid", StzXmlIsValid("not xml at all"), FALSE)
EndScenario()

Scenario("XXE is closed BY CONSTRUCTION -- the same refusal the signature path makes")
	# This is the one behaviour worth stating loudly. A DOCTYPE is how an XML
	# reader becomes a file-disclosure primitive; here it is not sanitised, not
	# configured off, but refused outright.
	Then("a DOCTYPE is refused",
	     StzXmlIsValid("<!DOCTYPE d [<!ENTITY e SYSTEM 'file:///etc/passwd'>]><d/>"), FALSE)
	Then("...so is a bare ENTITY declaration",
	     StzXmlIsValid("<!ENTITY xxe SYSTEM 'file:///etc/passwd'><d/>"), FALSE)
	Then("an ordinary document is unaffected", StzXmlIsValid($X), TRUE)
EndScenario()

Scenario("the document object, and nodes that are just paths")
	oXml = new stzXml($X)
	Then("it knows its root", oXml.Root(), "library")
	Then("it counts", oXml.NumberOf("library/book"), 2)
	Then("it reads a path", oXml.TextAt("library/book[2]/year"), "1969")
	Then("it reads a number", oXml.NumberAt("library/book[2]/year"), 1969)
	Then("repeated leaves collect", @@(oXml.TextsAt("//title")), @@([ "Dune", "Ubik" ]))

	When("a node is taken")
	oNode = oXml.NodeQ("library/book[2]")
	Then("it exists", oNode.Exists(), TRUE)
	Then("...knows its name", oNode.Name(), "book")
	Then("...its attribute", oNode.Attribute("isbn"), "2")
	Then("...and reads RELATIVE to itself", oNode.TextAt("title"), "Ubik")

	When("every matching node is taken")
	aNodes = oXml.NodesQ("library/book")
	Then("there are two", len(aNodes), 2)
	Then("...the first is Dune", aNodes[1].TextAt("title"), "Dune")
	Then("...the second Ubik", aNodes[2].TextAt("title"), "Ubik")
	# a node holds the document plus a PATH, so nothing can dangle: there is no
	# pointer into engine memory to invalidate.
	Then("a node can hand back its document", aNodes[1].DocumentQ().Root(), "library")

	Then("a node that is not there says so", oXml.NodeQ("library/book[9]").Exists(), FALSE)
EndScenario()

Scenario("building a document escapes every value")
	# Pasting XML together by hand is how injection happens: one unescaped value
	# and the SHAPE of the document changes.
	oB = new stzXmlBuilder("catalog")
	oB.SetAttributeQ("version", "1.0")
	oB.OpenXTQ("book", [ [ "isbn", "9" ] ])
	oB.AddElementQ("title", "Tom & Jerry <fun>")
	oB.AddElementQ("year", "2026")
	oB.CloseQ()
	cOut = oB.Content()

	Then("the ampersand was escaped", StzFindFirst("&amp;", cOut) > 0, TRUE)
	Then("...and the angle brackets", StzFindFirst("&lt;fun&gt;", cOut) > 0, TRUE)
	Then("...so the structure is intact", StzXmlIsValid(cOut), TRUE)

	When("the built document is read back")
	oRead = oB.XmlQ()
	Then("the value round-trips DECODED, not as markup", oRead.TextAt("catalog/book/title"), "Tom & Jerry <fun>")
	Then("...the attribute survives", oRead.AttributeAt("catalog/book", "isbn"), "9")
	Then("...and the root attribute", oRead.AttributeAt("catalog", "version"), "1.0")

	When("an element is left open")
	oBad = new stzXmlBuilder("r")
	oBad.OpenQ("a")
	Then("it says so rather than emitting broken XML", oBad.NumberOfOpenElements(), 1)
	bRaised = FALSE
	try
		oBad.Content()
	catch
		bRaised = TRUE
	done
	Then("...and refuses to hand it over", bRaised, TRUE)

	When("Close is called with nothing open")
	bRaised2 = FALSE
	try
		(new stzXmlBuilder("r")).Close()
	catch
		bRaised2 = TRUE
	done
	Then("it refuses", bRaised2, TRUE)

	Given("a root name that is empty")
	bRaised3 = FALSE
	try
		new stzXmlBuilder("")
	catch
		bRaised3 = TRUE
	done
	Then("it refuses to build a nameless document", bRaised3, TRUE)
EndScenario()

Scenario("pretty printing, for reading")
	oXml = new stzXml($X)
	cPretty = oXml.Pretty()
	Then("the tree is indented", StzFindFirst(nl + "  <book", cPretty) > 0, TRUE)
	Then("...nested deeper still", StzFindFirst(nl + "    <title>Dune</title>", cPretty) > 0, TRUE)
	Then("and it is still a valid document", StzXmlIsValid(cPretty), TRUE)
	Then("...that reads the same", StzXmlGet(cPretty, "library/book[2]/title"), "Ubik")
	# NOTE: pretty printing NORMALISES (canonical attribute order and escaping),
	# which is what makes it safe -- and why it is for reading, not re-signing.
EndScenario()

Scenario("the parser really is the one the signature code uses")
	# a genuine signed SAML assertion, read as an ordinary document
	cSigned = read(CurrentDir() + "/../system/fixtures/saml/SIGNED.txt")
	Then("stzXml parses it", StzXmlIsValid(cSigned), TRUE)
	Then("...names its root", StzXmlRoot(cSigned), "Assertion")
	Then("...reads its issuer", StzXmlGet(cSigned, "//Issuer"), "https://idp.acme.com")
	Then("...its subject", StzXmlGet(cSigned, "//NameID"), "dana@acme.com")
	Then("...and its SAML namespace", StzXmlNamespace(cSigned, "Assertion"), "urn:oasis:names:tc:SAML:2.0:assertion")
	Then("...while seeing the signature as ordinary elements", StzXmlCount(cSigned, "//SignatureValue"), 1)
EndScenario()

Summary()
