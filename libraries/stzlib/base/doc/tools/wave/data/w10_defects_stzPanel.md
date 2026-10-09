# Wave 10 defects: stzPanel, stzNaturalEngine, stzFalseObject, stzRegexMaker, stzNumbrex, stzUrl

Found by calling every root method with invented data; each failure was repeated with a second dataset before it was called broken. Nothing was fixed (comments only). Each is recorded as a warning in the doc block of the method.

## stzPanel (gui/stzPanel.ring)

No method raises wrongly. Behaviours worth knowing, recorded in the blocks:

| method | symptom | cause | evidence |
|---|---|---|---|
| LoadMarkup | does not raise for malformed markup; HasDocument becomes TRUE | the engine call answers 0 for text that is not well formed RML, so the `RmlUi said:` branch never runs; the parse error is only in LastEngineMessage (first input), and empty for the second | `<rml><body><br></body></rml>` and the text `this is not markup` were both accepted; LastEngineMessage for the first read "Closing tag 'body' mismatched..." |
| ClickAt, PointerMovedTo, PointerPressed, PointerReleased, PointerLeft | produce no event before the first Layout | the pointer verbs act on the laid-out tree, and LoadMarkup does not lay out | ClickAt(10, 60) before Layout: EventCount 0; after Layout the same call queued 5 events |
| FocusUp, FocusDown, FocusLeft, FocusRight | answered FALSE and left focus where it was | not found; RmlUi's spatial heuristic found no neighbour in a column of three `tab-index: auto` boxes (FocusNext and FocusPrevious moved it) | two runs, with and without Layout, four directions each |
| Counters, Events, EventCount | shared by every panel | the engine keeps one counter block and one event queue | a new stzPanel(10, 10) read the counters of the last render; the click on panel a showed 5 events on panel b |

Not run: ToPNG (needs a graphics device).

## stzNaturalEngine (natural/stzNatural.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| FindContextPlaceholders | answers [ ] for a {hole} that is not at the start of the text | tests `@StzMid(_cCode_, _i_, _i_) = "{"`, but the global @StzMid is count-based (start, count), so it compares i characters with a brace | `{a}` answers [ "{a}" ]; `x{a}`, `{a} x`, ` {a}` and `Hello {name} from {c}` all answer [ ] |
| InterpolateContext | a hole with no value is replaced by the quoted text not_found instead of staying | `_cValue_` is the written form (`@@`) of the lookup result, compared with the symbol :NOT_FOUND, so a miss is never recognised | `{zip}` and `{b}` both became `"not_found"` |
| InterpolateContext | text values arrive quoted, so a narration that already quotes the hole (`'{name}'`) fails to evaluate | values are inserted in `@@` form | `Create a string with '{name}'` raised R42 in eval; `{name}` unquoted worked |
| init, Execute, GenerateCodeFromSemantics (Code) | a narration that creates no object raises `Unsupported object type!` | by design (test 06 of test/natural); not a defect, recorded so the reader is not surprised | Naturally("flibber flobber"), and Code() on an empty engine |
| GetContextValue, FindInList | the not-found marker is the text not_found | `:NOT_FOUND` is the string not_found, so a context value equal to that text cannot be told from a miss | noted from the source and from the answers |

## stzFalseObject (object/stzFalseObject.ring)

None. All 55 roots behave as the source says. Note: WasNever answers 0 (not 1) on a false object, which is by design (the whole chain is already false).

## stzRegexMaker (regex/stzRegexMaker.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| NumberOfSequences, HowManySequences, CountSequences, NumberOfSeqs, HowManySeqs, CountSeqs, NumberOfCommands, HowManyCommands, CountCommands | R24 `acsequences` | the body reads `len(acSequences)`; the variable is `@aSequences` | with and without ranges added |
| HowManyFragments, CountFragments, NumberOfFrags, HowManyFrags, CountFrags | R14 `numberoffragments` | they forward to `NumberOfFragments`; the method is spelled `NumberOfFragements` | each of the five called; the same five are in deadforward_baseline.txt |
| CommandXT, CommandAndFragment, CommandAndFrag, CommandAndItsFragment, CommandAndItsFrag | R24 `n` | the aliases call `This.SequenceXT(n)` but declare no parameter | each called; SequenceXT(1) works |
| CanContainAChar, CanContaingChar, CanContainADigit, CanContaingdigit | R14 `isbetweenorfromnamedparam` | they call a stzList method that does not exist (the named-param test) | Between, Among and From forms; a text argument raises Incorrect param type! |
| CanContainACharBetween, CanContainADigitBetween (text form) | R14 `char` | the text form `A-Z` / `0-9` calls a bare Char() that does not exist; the list form works | "A-Z" and "0-9" |
| CanContainADigitAmong (list form) | R3 `islistofdigits` | the function is not defined; the text form works | `[ "1", "3" ]` |
| ComposePatterns (modes or, sequence) | R20 | calls `join(list, sep)` with two arguments; and mode works | or with 2 and 3 patterns, sequence with 2 |
| MatchSameContentAs | R24 `pctaggroupname` | after finding the group it appends `pcTagGroupName`, which is not its parameter (the parameter is pcGroupName) | two different group names |
| AddBackReference (number) | appends two backslashes: `\\1` | the source writes `"\\"` where Ring has no escape, so both characters stay | length 3 for group 1 |
| AddRange, CanContain* | an unknown repeat kind or repeat name silently drops the quantifier; `repeatedAtMost` ignores the count | quantifier chosen by an if-chain with no else; AtMost writes `?` | `:zzz` gave `[ab]`; AtMost 3 gave `[ab]?` |
| Quantifiers, QuantifiersCommands | answer an empty text | the bodies are `#TODO` | called |
| Sequence, RepeatSequence | raise R2 when only literals were added; fragments and sequences are numbered apart | AddLiteral and the fragment adders add a fragment and no sequence | AddLiteral then Sequence(1) |
| pvtGetRepeat | private (R26 from outside) | by design | read through CanContainACharBetween |

## stzNumbrex (regex/stzNumbrex.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Match, init | a pattern with no readable token matches every number | the parser drops what it cannot read, and MatchTokens over an empty list answers 1 | `{@zzz}` and `{zzz}`: Match(5) and Match(-7) answer 1 |
| ParseConstraints, CheckDigits (`@Digit(n)`) | can never match | the exact constraint compares the digit COUNT to n, while the token's default count is exactly one digit | `{@Digit(7)}`: 7, 77 and 1234567 all answer 0 |
| CheckFactors (`@Factor(prime)`) | can never match | GetFactors includes 1, and the prime constraint demands every factor prime | 1, 2, 3, 6, 7, 8, 15 all answer 0 |
| CheckPart | an unknown part name answers 1 for every number | the final `return 1` | `zzz` on 5 |
| IsNumeric | 3.5 and -3.5 answer 0 | accepts only digits and the dash | called |

No Numbrex public name forwards to a missing method (all alias calls were made and answered).

## stzUrl (network/stzUrl.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| (class) | not loaded by stzlib.ring or stzBase.ring | no `load "network/stzUrl.ring"` in either, so `new stzUrl` raises R11 in a normal session | the probe needed an explicit load |
| FileName | raises "Indexes out of range" when the path ends with a slash | `Section(n + 1, n)` with n the last position | `/a/b/` and `/` |
| FromLocalFile | R19 whatever the path | calls `ReplaceSubstring("\", "/")` with two arguments; the method takes (from, to, replacement) | a drive path and `/tmp/y.txt` |
| ResolvedWith | a relative reference leaves the base unchanged or is misread | the engine parses `d.html` with an empty path and `sub/d.html` with host `sub` and path `/d.html` | `d.html` gave http://plain.org/a/b/; `sub/d.html` gave http://plain.org/d.html |
| SetAuthority | an authority without user information or port keeps the old ones | each part is replaced only when given | `plain.net` after `kim:k1@new.net:9000` gave `kim:k1@plain.net:9000` |
| Authority vs Content | Authority prints a port of 80 or 443, Content leaves it out | ReconstructUrl drops 80 and 443 whatever the scheme | SetPort(80) on https |
| IsValid | FALSE for a relative reference whose path and query are read | the engine requires a scheme and host | `/just/a/path?q=1` |

No stzUrl public name forwards to a missing method (Url, ToString, Protocol, Domain, Server and Location were called and answered).
