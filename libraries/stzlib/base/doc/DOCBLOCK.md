# How to document a method (and a class) in Softanza

*One page. The reasons are in `design/DOCREFORM_PROPOSAL.md`; the extractor is `meta/stzDocRecord.ring` and `meta/stzDocExport.ring`; the result is `reference.json`.*

You write **only what a machine cannot know**. The extractor already derives the usage line, the parameter types (`pc` text, `pn` number, `pa` list, `pb` boolean, `po` object, `pac` list of text, `pan` list of numbers), the extension forms (`Q`, `CS`, `XT`, `Z`, `ZZ`, `W`, `U`...) that exist, the other names that forward to your method, the passive twin, and a first sentence for a predicate (`IsX`). It labels each of those `derived` in the record. A section title (`#===# Finding #===#`) is structure: it groups members and is **never** shown as a description.

## The block, above the `def`

```ring
	# Returns the positions of every occurrence of pcSubStr, as a list of numbers.
	#
	# Case-sensitive by default; FindCS takes the flag.
	#
	#   pcSubStr   the text to look for
	#   returns    a list of numbers; [ ] when pcSubStr is absent
	#   note       the positions are in characters, not bytes
	#   see        FindFirst, FindNth, Contains
	#   example    ? @@( Q("banana").Find("an") )
	#              #--> [ 2, 4 ]
	def Find(pcSubStr)
```

- **Brief** (the first line): one sentence, 20 to 140 characters, starts in uppercase with a **third-person verb** (`Returns`, `Removes`, `Sets`) or `TRUE if`, ends with a period, and says something the name does not. `Returns the number of chars.` for `NumberOfChars` says nothing: the gate refuses it.
- A bare `#` ends the brief. The next lines, until the fields, are an optional **detail** paragraph.
- **Fields**: `#`, then two or more spaces, then the key, then two or more spaces, then the text. The key is a **parameter name of that def**, or one of `returns note warning see example since status detour forms`. A line indented to the value column or deeper continues the field above. (One space after the key, and it is prose.)
- **example**: the lines you would type, with the output **inline** as `#-->` after each meaningful `?` line. There is no separate output field. The examples are run by the library's own harness.
- `status`: `stable` (default), `experimental`, `deprecated`, `internal`. A `pvt...` name is `internal` without saying so.
- `detour`: the natural name a host-language collision forced away (`IsAChar` for `IsChar`).
- `forms`: the accepted named-parameter calls (`HasMoreChars(:Than = 3)`).
- No blank line between the block and the `def`.
- An old one-line comment is still a valid brief. `#@ aka ...` lines are unchanged: they feed retrieval only.

A parameter named like one in `params.txt` (`pCaseSensitive`, `pcSubStr`, `pCol`...) is described **once**, there, and every method that does not describe it itself inherits it, marked `derived`. Describe a parameter in the block only when its meaning here differs.

## Above the `class`

```ring
# Holds a text and answers questions about it.
#
# Reach for it when a method of stzString is more than you need. It is made of
# Unicode characters, never of bytes.
#
#   receiver   o1 = new stzDocFx("banana")
#   example    ? @@( o1.Find("an") )
#              #--> [ 2, 4 ]
#   see        stzString
class stzDocFx from stzDocFxBase
```

`receiver` is one or two lines that build a small representative object named `o1`, so every method's example can start from it. A class that is only another name of its parent (`class stzItems from stzList`, empty) is recorded as `alias_of`.

## The gate (waves, then CI)

A method **passes** when: (1) the brief has the form above, (2) it is not the name restated nor the signature repeated, (3) every parameter has a role (written, or `params.txt`), (4) the return is stated (written, or derived for a predicate or a body that returns nothing). It is **reference** when it also has an example (5) that runs (6). New or changed public methods owe checks 1 and 2.

`StzDocFindings(cBase)` reports a public name that forwards to a method that does not exist, a `pvt` name shown as public, and a misspelled word in a name (words reviewed as correct go in `typo-reviewed.txt`).

Export: `cd base/doc; ring export_reference.ring <commit> <date>` (one process, under a minute; run it alone).
