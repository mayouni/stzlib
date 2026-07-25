# The Parser That Says No
### How Softanza got XML by refusing most of it — and why the refusals are the feature

Softanza had no XML at all. It now has one, and it arrived from a direction nobody
planned: the digital-signature work needed a parser it could *trust*, and a parser
you can trust turns out to be exactly the parser an application wants.

This narration walks that parser, the object you hold on top of it, and the small
number of firm decisions that make both worth using. Every code block is real, and
every output block is its actual output.

The short version, and the thing worth taking away: **most of what this parser
does is decline to do things.** That is not a shortcoming to apologise for. It is
the whole design.

---

## Start with the object

```ring
cXml = '<library xmlns="urn:lib" name="City Library">' +
       '<book isbn="1"><title>Dune</title><year>1965</year></book>' +
       '<book isbn="2"><title>Ubik</title><year>1969</year></book>' +
       '</library>'

? StzXmlRoot(cXml)
# --> library

? StzXmlGet(cXml, "library/book/title")
# --> Dune

? StzXmlGet(cXml, "library/book[2]/title")
# --> Ubik

? StzXmlGet(cXml, "//year")
# --> 1965
```

Three path forms, and that is deliberately all of them:

| Form | Meaning |
|---|---|
| `"a/b/c"` | walk down, step by step, by **local element name** |
| `"a/b[2]"` | the 2nd matching sibling (1-based) |
| `"//c"` | the first element with that local name, **anywhere** |

You may be reaching for XPath here, and its absence is a choice worth defending.
A *partial* XPath is worse than none: the moment a path language looks like XPath,
every reader assumes predicates, axes, functions, unions. They write
`//book[@isbn='2']`, it silently fails, and they debug their document instead of
their expectation. Three forms that obviously *are* three forms create no such
illusion.

## Why local names, not prefixes

Look again at what the document says versus what the path says:

```ring
? StzXmlNamespace(cXml, "library/book")
# --> urn:lib
```

The path never mentioned `urn:lib`, nor any prefix. That is on purpose, and it is
the single most practical decision in the module.

In real XML, a prefix is just a local nickname. These two documents are *the same
document* to any conforming reader:

```xml
<saml:Assertion xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">
<a:Assertion    xmlns:a="urn:oasis:names:tc:SAML:2.0:assertion">
```

Two vendors, two nicknames, identical meaning. A path written against the first
breaks against the second — and it breaks *silently*, returning empty rather than
complaining. Matching by local name sidesteps that whole category of bug. The
ambiguity it introduces (two different namespaces sharing a local name) is rarer,
louder, and answerable: ask for the namespace when it matters.

## Reading is reading, not decoding

Here is a small thing that causes real bugs elsewhere. XML text can contain
*entity references* — `&amp;` for `&`, `&lt;` for `<`. What should a read return?

```ring
cDoc = '<r a="x &amp; y"><t>Tom &amp; Jerry &lt;fun&gt;</t></r>'

? StzXmlGet(cDoc, "r/t")
# --> Tom & Jerry <fun>

? StzXmlAttr(cDoc, "r", "a")
# --> x & y
```

**Decoded.** The alternative — handing back the raw `Tom &amp; Jerry &lt;fun&gt;`
— makes every caller responsible for decoding, and callers forget. When they
forget, one of two things happens: the user sees `&amp;` on their screen, or the
value gets escaped a second time and `&amp;` becomes `&amp;amp;`. Both are
classics. Returning character data means the caller gets the *value*, which is
what they asked for.

(The canonicalizer keeps its own separate escaping path, because signatures care
about exact bytes rather than values. Same parser, two jobs, no confusion between
them.)

---

## The refusal

Now the part that matters most. Try to feed it a perfectly ordinary-looking XML
feature:

```ring
? StzXmlIsValid("<!DOCTYPE d [<!ENTITY e SYSTEM 'file:///etc/passwd'>]><d/>")
# --> 0

? StzXmlIsValid("<!ENTITY xxe SYSTEM 'file:///etc/passwd'><d/>")
# --> 0
```

Refused. Not sanitised, not "handled" — refused, before parsing begins.

Here is what that declaration does in a permissive parser. `<!ENTITY e SYSTEM
'file:///etc/passwd'>` defines `&e;` to mean *the contents of that file*. Write
`&e;` anywhere in the document and the parser dutifully reads the file and
substitutes it. Now imagine your application accepts an XML upload and echoes any
part of it back — a name, an error message, a log line. You have handed a stranger
a file reader for your server. That is **XXE**, and it has been in the OWASP top
ten for years.

A sibling trick, the "billion laughs", defines an entity in terms of itself ten
levels deep and expands one small document into gigabytes of memory.

Both live in the same feature. Softanza's answer is not a flag you must remember
to set, or a sanitiser you hope is complete. The feature is **absent**. A document
that uses it is not a document this parser reads.

That is the sentence worth carrying: **the refusal is the security property.** A
parser that can be configured safely will eventually be configured unsafely, by
someone tired, in a hurry, in a file nobody re-reads. A parser that cannot do the
dangerous thing has no such failure mode.

The honest bill for that, stated in the module header rather than discovered
later: no DTD or XSD validation, no XPath, no XSLT, UTF-8 only, and bounded
documents rather than streaming. If a task genuinely needs those, it wants a
different tool — not a laxer version of this one.

---

## One parser, and why that is not merely tidy

`stzXml` did not get its own parser. It shares the one the XML-signature code
uses, and the sharing is deliberate in a way worth explaining.

Digitally signing XML has a peculiar wrinkle. These two documents are logically
identical:

```xml
<r b="2" a="1">text</r>
<r a="1" b="2">text</r>
```

Same element, same attributes, same content — different **bytes**. Signatures are
over bytes. So XML signing defines a normal form, *canonicalization*, that both
signer and verifier compute before hashing. Get the rules even slightly different
on the two sides and every signature fails, or worse, some pass and some do not.

Which means: if an identity provider signs with one implementation and verifies
with another, they must agree exactly. The most reliable way to guarantee two
implementations agree is for there to be **one implementation**.

So `engine/src/xml.zig` holds the parser and the canonicalizer, and both `stzXml`
and the signature code sit on it. `stzXml` inherits the strictness for free — and
you can see the shared lineage directly, by opening a genuinely signed SAML
assertion as an ordinary document:

```ring
oSaml = new stzXml(cSignedAssertion)

? oSaml.Root()
# --> Assertion

? oSaml.TextAt("//Issuer")
# --> https://idp.acme.com

? oSaml.TextAt("//NameID")
# --> dana@acme.com

? oSaml.NumberOf("//SignatureValue")
# --> 1
```

No special API, no signature awareness. The security document is just a document.

And the canonicalizer is not trusted on its own word: it is checked
**byte-for-byte against libxml2** across ten vectors, kept as permanent tests.
That is worth doing because canonicalization is where this kind of code breaks
quietly. Two bugs it caught in ours: a namespace prefix declared on an ancestor
must be re-declared on the element that first *uses* it, and entity references
must be decoded then re-escaped — escaping the raw source turns `&amp;` into
`&amp;amp;` and every hash is wrong.

---

## The object shape, and one argument I lost gracefully

XML is a *tree*. The library already had one tree format — `stzHtml` — and it had
already discovered what a tree needs: a document, a node, and a builder. So XML
gets the same three, because being the same kind of thing should look the same.

```ring
oXml = new stzXml(cXml)

? oXml.NumberOf("library/book")
# --> 2

oNode = oXml.NodeQ("library/book[2]")
? oNode.Name() + " / " + oNode.Attribute("isbn") + " / " + oNode.TextAt("title")
# --> book / 2 / Ubik

for oBook in oXml.NodesQ("library/book")
    ? oBook.Path() + " -> " + oBook.TextAt("title") + " (" + oBook.TextAt("year") + ")"
next
# --> library/book[1] -> Dune (1965)
# --> library/book[2] -> Ubik (1969)
```

Notice `oNode.TextAt("title")` — a node reads *relative to itself*. That is the
whole point of holding one.

There was a proposal on the table for `stzXmlString` and `stzXmlFile` as separate
classes, and it is instructive to see why the library's own history answers it.
No format in Softanza splits that way: `stzJson`, `stzCSV` and `stzHtml` all take
text and let `read()` deal with sources. And the Softanza habit of *saying the
relationship in English first* settles it in one sentence: **"an XML document,
which may come from a string or a file."** A file is a *source*, not a *kind*.
`FromFile()` and `SaveTo()` are conveniences on the one class.

### A node is a path, and that is why nothing dangles

Look at what came back above: `library/book[1]`. A node is not a pointer into
engine memory — it is **the document plus the path that reaches it**.

That one decision removes an entire class of problem. There is no handle to
invalidate, no lifetime to manage, no way to hold a node past the document it came
from. Reading a child is just a longer path, so `NodeQ()` chains as far as you
like. And a node can always hand you the document back:

```ring
? oXml.NodesQ("library/book")[1].DocumentQ().Root()
# --> library
```

---

## Building: the escaping is not optional

The other half of XML is producing it, and the usual approach — pasting strings
together — is how injection bugs are born. One unescaped `<` and the *shape* of
your document changes, which means an attacker who controls a value controls your
structure.

```ring
oB = new stzXmlBuilder("catalog")
oB.SetAttributeQ("version", "1.0")
oB.OpenXTQ("book", [ [ "isbn", "9" ] ])
oB.AddElementQ("title", "Tom & Jerry <fun>")
oB.AddElementQ("year", "2026")
oB.CloseQ()

? oB.Content()
# --> <catalog version="1.0"><book isbn="9"><title>Tom &amp; Jerry &lt;fun&gt;</title><year>2026</year></book></catalog>
```

The dangerous characters are gone, and — importantly — the *value* is not:

```ring
? oB.XmlQ().TextAt("catalog/book/title")
# --> Tom & Jerry <fun>
```

Escaped on the way out, decoded on the way in. The round trip is invisible, which
is exactly how safety should feel.

The builder also refuses to produce nonsense. Leave an element open and it will
not hand you a broken document:

```ring
oBad = new stzXmlBuilder("r")
oBad.OpenQ("a")
? oBad.NumberOfOpenElements()
# --> 1

oBad.Content()
# --> raises: stzXmlBuilder: 1 element(s) still open -- Close them first.
```

## Reading a document as a human

```ring
? oXml.Pretty()
```

```
<library xmlns="urn:lib" name="City Library">
  <book isbn="1">
    <title>Dune</title>
    <year>1965</year>
  </book>
  <book isbn="2">
    <title>Ubik</title>
    <year>1969</year>
  </book>
</library>
```

One caveat, stated where you will see it: pretty-printing **normalises** — it
re-emits from the parse tree, with canonical attribute order and escaping. That is
what makes it safe rather than a fragile text transform. It also means it is for
*reading*, not for re-signing something you already signed.

---

## Two bugs, and who caught them

Worth recording, because both are the kind that ship quietly.

**The first**: reads originally returned raw source instead of decoded text. Found
by writing the round-trip test above and seeing `Tom &amp; Jerry` come back out of
a value that went in as `Tom & Jerry`.

**The second is the more interesting one.** `Exists()` on a node that is not there
answered *true*:

```ring
? oXml.NodeQ("library/book[9]").Exists()
# --> 1     ... in a document with exactly two books
```

The cause: counting matched the last step's *name* and ignored the index, so
`book[9]` counted all the `book` children and found two. The Ring guard caught it.
The fix was one early return — and then a *second* test, written in the engine,
caught that the fix was in the wrong place: the `//` branch ran first and also
ignored the index, so `//title[9]` still counted every title. The index check
belongs before both.

That second catch is the argument for testing at more than one level. The Ring
suite was green after the first fix. The engine test was not.

---

## What the module is, in one paragraph

An XML reader that refuses DOCTYPE and ENTITY outright, so the most common way an
XML parser becomes a file-disclosure primitive simply is not available. A path
language with three forms and no pretence of being XPath. Local-name matching, so
a vendor's choice of prefix cannot break your code. Values decoded on read and
escaped on write, so the round trip is invisible. A document, a node that is
really a path, and a builder that cannot emit malformed output. And one shared
implementation underneath, byte-verified against libxml2, because the code that
signs XML and the code that reads it must agree — and the surest way to make two
things agree is to have one thing.

*Verified: 55 assertions in `test/file/xml_narrated.ring`, and 10 engine tests via
`zig build test-xml` — including the libxml2 canonicalization vectors and a
scenario that reads a genuinely OpenSSL-signed SAML assertion as an ordinary
document.*
