
## Wave 9 -- stzObject (agent: base/object/stzObject.ring, 251 hand-written roots)

Every root was called with real data on a stzString, a stzList, a stzNumber or a bare stzObject (invented values only). Nothing was fixed (comments only). Each defect below was seen on at least two receivers or two different calls; each is a warning in the method's block.

Raise today (cause in the source):
1. **Values, AttributesAndValues -- R24 `aresult`.** `Values` builds `_aResult_` but evals `aResult + This.<attr>` and returns `_aResult_`. Seen on stzString, stzList, bare stzObject. AttributesAndValues calls Values.
2. **SizeInBytesXT32, SizeInBytesXT64 -- R3.** They call `@SizeInBytesXT32(This)` / `@SizeInBytesXT64(This)`, which are not defined anywhere (the profiler defines `@SizeInBytesXT` and `@MemorySizeInBytes32XT`).
3. **ToPointer -- "Bad parameter type!" (stzString), R21 (stzList, bare).** `object2pointer(This.Object())`; the built-in `object2pointer(o1)` called directly on the same object answers a pointer.
4. **IsListOrString -- R4 stack overflow.** The body is `return This.IsListOrString()`. IsStringOrList works.
5. **WhichAreBoth -- R24 `_alist_`.** The body tests `_aList_`, never set (`_aContent_` is meant).
6. **AddTimeValue, AddExecutionTimeValue, AddExecutionTime -- R24 `_atime`.** Raise even with `SetKeepingTimeTo(1)`; `_aTime` is never declared.
7. **OccursForTheNthTime, OccursForTheFirstTime, OccursForTheLastTime -- R14.** They call `NthOccurrenceCS` on a text and `NthOccurrence` on a list; neither exists on the receiver (seen on both).
8. **The Of... family.** OfM, OfXTM, OfBM, OfMB, OfXTCSBM, OfXTCSMB raise R14 (forward to OfCSM/OfCSBM/OfCSMB, which do not exist); OfXTCSB raises R24 (`c` for `_n_`); OfXTBM raises R24 (`cignored` not declared); OfXTMB and OfXTBQ raise R19 (two arguments passed to a three-argument method).
9. **ToStzListOfObjects -- R14 `islistofobjects`.** Seen on a list of numbers and on a list of stzString objects.
10. **Numberified on a stzNumber -- R14 `isnumberinstring`.** Seen with 42 and 7.5 (stzNumber.Content answers a text, so the text branch runs).
11. **SwapWith on a bare stzObject -- R14 `updatewith`.** Works on stzString and stzList (they define UpdateWith).
12. **IfQ with a false condition -- "Bad parameter type!"** The source comment says it answers an R13 error message; it raises instead of answering a false object.
13. **AnObjectQ and IsA on a bare stzObject -- R24 `@noname`.**

Answer FALSE (or a wrong value) for every input tried:
14. **IsFalseObject, IsTrueObject.** Both compare the class name with the misspelling `:stzFlaseObject`; `AFalseObject().IsFalseObject()` and `ATrueObject().IsTrueObject()` are FALSE. (`IsNullObject` is correct.)
15. **HasSameStzTypeAs.** Always FALSE (stzString/stzString, stzList/stzList, bare/bare): it tests `Q(p).IsStzType()`, which is TRUE only when the other object's content is a text naming a class. HasSameTypeAs only tests `isObject(p)`.
16. **IsText.** FALSE for a stzString holding "banana" and for a bare stzObject.
17. **ALengthN on a stzList.** Uses NumberOfChars first: 0 for [ 1, 2, 3 ] and for [ "ab", "cd" ], 4 for [ "a", "b", "c", "d" ].
18. **AreBothA, AreTwo.** Test the pair as a whole, not its two items: [ "a", "b" ] is FALSE for :String and TRUE for :List.

Traps (documented as warnings or notes, not defects):
- `Of(5)` on a stzString ends the Ring process with no message (stzString.IsEqualToCS with a number); not stzObject's code.
- `Occurs(:After, "banana")` needs the named pair `:After = value` (positional raises R24 `_ctemp_`).
- `ToNumber("1_250")` is refused although the code strips underscores after the check.
- The history list (`AddHistoricValue`, `HistoricValues`) is one list for the whole process: `o1.AddHistoricValue(1)` is read back by `o2.HistoricValues()`.
- `SetVarName("oFruit")` registers the object, but `v("oFruit")` raises; `v("ofruit")` (lower case) answers.
- `BetweenN` explanation text: "expected between between 1 and 2, found 3".
- `ClassName()` answers "stzobject" for every class.
