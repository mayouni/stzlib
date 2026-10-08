# Wave 9 defects -- stzMathDiagram, stzListOfBytes, stzSystemProfile, stzSystemCall, stzOperatingSystem

Found by calling every root with real data (Ring 1.27, Windows, 2026-10-09). None was fixed; each is a warning in the doc block of the method.
Every item was confirmed with a second, different call unless marked otherwise.

## stzListOfBytes (number/stzListOfBytes.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| BytesOfThisChar | answers an empty text instead of the bytes of a character | the nested `def BytesOfThisChar(pcChar)` under BytesOfChar has no body | on `abc` with `b`, and on `héllo` with `é`: ""; BytesOfChar answers [ "b" ] |
| Stripped | answers an empty text instead of the trimmed bytes | the nested `def Stripped()` under Trimmed has no body | on `  ab c  ` and on `x `: ""; Trimmed answers "ab c" and "x" |
| FillWithAsciiCharUpToNChars | raises R21 Using operator with values of incorrect type | `nChars * This.NumberOfBytesPerChar()` multiplies a number by a list of [ char, count ] pairs | `abc` with (z, 2) and `abcd` with (y, 3) |
| ToUTF8 | raises R14 Calling Method without definition: toutf8 | forwards to `stzString.ToUTF8()`, which does not exist | on `abc` and on `aé€` |
| Bits, ToStzListOfBits | answer an empty text | bodies are `// TODO` comments | on `abc` and on `x ` |
| ToPercentEncoding | the three arguments (pcExcludedFromEncoding, pcIncludedInEncoding, pcPercentAsciiChar) change nothing | the body calls the engine with no argument and never reads them | `a-b_c.d~e` with - excluded, `a-b` with a included and # as escape, `x/y z` with / excluded (still %2F) |
| FromPercentEncoding | the argument pcPercentAsciiChar is never read | same | code read, plus one decode with % only |
| Updated | returns its argument and leaves the object as it was; it does not return an updated copy | body is `return pcStr` | `abc` with QQ and `x ` with ZZZ: object unchanged |
| FromHex | text that is not pairs of hex digits (0x prefix, odd count, space, letter beyond f) silently empties the list | engine returns nothing, the method stores "" | 0xff, 414, zz, `41 42` |

## stzSystemCall (system/stzSystemCall.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| ParseOutputAsNumber (and SetReturnType("number")) | raises R41 Invalid numeric string for any output that holds a character that is not a digit | the character tests `_c_ >= "0"` raise when the character is a letter, a space after the digits, a sign or a point; only an all-digit output is read | `echo 42` gives 42; `echo 42 apples`, `echo 3.5`, `echo -8`, `echo none`, `echo total 17 items` all raise |
| OutputAsLines | raises when the return type is list or number | Run already converted @cOutput to a list or a number, and the method splits it as text | list: Bad parameter type; number: Incorrect param type! cStrOrList must be a string or list |
| SetTimeout, WithTimeout, Timeout | the timeout is stored and never applied | @nTimeout is read only by Timeout(); nothing passes it to the engine | `ping -n 3 127.0.0.1` with SetTimeout(1) ran 2,083 ms and ended with exit code 0; grep finds the field on three lines only |
| DontCaptureOutput | the output is still kept when the console is hidden (the default) | Run stores `_aRun_[1]` in @cOutput whatever @bCaptureOutput says; the flag only gates the conversion | `echo nocap`, `echo nocap2`: Output holds the text |
| RunSilently, RunSilent, RunEngineSilent | the command's own output appears in the console that started the program | the engine runs the command with the parent's standard output | echo printed its text four times |
| Run on a command that needs the shell | the command is wrapped twice: Args shows cmd.exe /c cmd.exe /c echo x & echo y | init wraps it, Run calls UseShellIfNeeded again on the wrapped string | `echo x & echo y`: the answer is still right, so cosmetic |

## stzSystemProfile (system/stzSystemProfile.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| SetCapabilityList, FromString (capabilities line) | an unknown capability raises, and the profile is left holding the capabilities listed before it, so the previous list is lost | `@oCaps = new stzSystemCapabilities(paCaps)` raises inside init after the object was created and some were granted; the half-filled object is what @oCaps then holds | [ network, foo, clock ] left [ network ]; [ gpio, teleport ] left [ gpio ]; FromString of `capabilities: clock, bar` left [ clock ] |

## stzMathDiagram (graph/stzMathDiagram.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Fact | paArgs given as a bare text (Fact("count", "shapes")) raises R21 | `if NOT isList(_a_) _a_ = [ _a_ ] ok` is the single-clause `if` that does not fire in Ring 1.25/1.27 (CLAUDE.md note 6) | Fact("value", "A.icon.cx") and Fact("count", "shapes") both raise; the list forms work |
| Emphasis (focus, dim) and ClearMarks | ClearMarks does not undo a focus or a dim: they rewrite the shape's own stroke and mint nothing | ClearMarks only deletes the shapes listed in @acMarks | after Emphasis(A.icon, :focus) and ClearMarks: stroke #4D4DC9, width 3 (was #656565, 1); tried once |
| CanvasWidth, CanvasHeight | fail doc-gate check 3 (parameter without a role) although they take no argument | the one-line definition `def CanvasWidth()   return @oStyle.CanvasWidth()` is read by the extractor as a parameter named `)   return @oStyle.CanvasWidth(`, which no block can describe | reference.json record: parameters = [ { name: ")   return @oStyle.CanvasWidth(" } ]; fix is to put the body on its own line (a code change) or to make the extractor read the parameter list up to the first closing parenthesis |

## stzOperatingSystem (system/stzOperatingSystem.ring)

Not a defect, a question that could not be settled on Windows: Name() tests Ring's `isunix()` before `islinux()`. If Ring's `isunix()` is also true on Linux, Name answers unix and IsLinux is FALSE there. Not run (Windows only); the doc blocks of Name and IsUnix say so.

## Extractor note

The applier turns the `#-- title ---` divider comments of stzMathDiagram and stzSystemProfile into stray `#@ aka  -- title ---` lines above the method that follows (46 in stzMathDiagram, 15 in stzSystemProfile). Left as the README allows.
