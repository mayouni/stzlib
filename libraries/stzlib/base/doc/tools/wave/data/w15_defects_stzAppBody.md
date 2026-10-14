# Wave 15, group 5 -- defects found while documenting (not fixed; comments only)

Each row: method, symptom, cause, evidence. Confirmed with a second call on different data.

## appserver

- **stzAppResponse.Json / ObjectToJson**, wrong JSON shape. A Ring hash list of pairs
  `[ [ "name", "Ana" ], [ "tags", [ "a", "b" ] ] ]` serializes as `[{"name":"Ana"},{"age":31},{"tags":{"a":"b"}}]`
  (an array of one-pair objects, and the inner list of two texts is read as an object). Cause: the serializer reads a
  list whose first item is a text as a flat `[ key, value, ... ]` object and every other list as an array; the pair list
  falls in the second case and each pair, starting with a text, in the first. Evidence: `ObjectToJson([ "a", "b" ])`
  returns `{"a":"b"}`; `Json([ :name = "Ana", :age = 31 ])` body is `[{"name":"Ana"},{"age":31}]`.
- **stzAppResponse.ObjectToJson**, raises. A list of an odd number of texts (`[ "a", "b", "c" ]`) raises R2 index out
  of range (reads the value of the missing third pair). Evidence: second call with `[ "a", "b", "c" ]`.
- **stzAppResponse.ObjectToJson**, no escaping. `ObjectToJson('a"b')` returns `"a"b"`, which is not valid JSON; a
  newline inside the text is written as a raw line feed. Evidence: two texts (quote and line feed).
- **stzAppResponse.ObjectToJson**, an object (any `stzXxx`) falls through to `""`; no error.
- Not a defect, a trap: `new stzAppRouter()` with parentheses raises R19 (too few parameters); `new stzAppRouter` works.

## data

- **stzDatabase.ExecWith / RowsWith / TypedRowsWith / ValueWith**, wrong number in the error. A call whose number of
  bound values does not match the statement raises `sql error: N parameter(s) given, the statement has -1`; the
  statement's real count is never reported. Evidence: `ExecWith("INSERT INTO t VALUES (?, ?, ?)", [ 1, 2 ])` (2 given, 3
  marks) and `RowsWith("SELECT ?", [ 1, 2, 3 ])` (3 given, 1 mark) both say `has -1`; `RowsWith("SELECT ?", [ ])` says
  `0 parameter(s) given, the statement has -1`. Cause: in the engine bridge (`StzEngineDbExecP` / `StzEngineDbQueryP`),
  not traced further; the Ring side only forwards the message. Harmless to the data, wrong to a reader.

- **stzUnicodeData.NumberOfUnicodeChars** (class method) answers 34939 and the global function `NumberOfUnicodeChars()`
  answers 149186 (a constant `$nNumberOfUnicodeChars`); two answers to one name. The method counts the engine table's
  entries (one per line of the data file, a range being two lines), the global is the count of assigned characters.
  Documented in the block; the aliases NumberOfChars, NumberOfUnicodes, HowMany... of the method share the first answer.
- **stzUnicodeData.CharHexCodeByName** with a name that does not exist returns the bare prefix `0x`, no error (the sibling
  CharUnicodeByName returns -1 and CharByName raises).

## extincode

- **IntObject.getMinValue / getMaxValue** return TEXT with digit separators (`-999_999_999_999_999`), so
  `int.getMaxValue() > 5` and `int.getMinValue() < 0` raise R41 Invalid numeric string, and `int.getMaxValue() + 1`
  joins text (`999_999_999_999_9991`). Cause: `RingMinIntegerXT` / `RingMaxIntegerXT` return the stored text constants.
  Two comparisons and one sum confirm it.
- **WITH.As**, a name registered twice. The replace branch assigns `_aVars[_n_]` four times with the same index, so the
  slot named `big` becomes `bigObject` and `bigData`/`bigTable` keep the first call's values; a further call with that
  name raises "Can't create the stzHashList object!". Evidence: three calls on a three-row intermediate table, the
  variable names listed after the second call (`say, bigObject, bigData, bigTable, bigObject`).
- **CREATE_TABLE** (function of the same file, noticed while feeding WITH): raises "operator: unsupported operator '='
  on stzList" on `Vr(pcName) '=' Vl(_oTable_)`, so the SQL emulation cannot create a table today. Evidence: two calls
  of `CREATE_TABLE("emp")` in fresh processes. Not a method of any class; reported for the owner of extincode.
- Not a defect, a trap: `new IntObject()` with parentheses raises R3 (Calling Function without definition: init); `new IntObject` works.

## file

- **stzFolderWatcher.Watch** accepts a folder that does not exist: IsRunning becomes 1 and LastError stays empty, and
  no event can ever come. Evidence: `Watch(<scratch>/fx_watch/nope_dir)`. Not a crash; a silent success.
- **stzZipFile.AddString**, raises R3 `Calling Function without definition: zip_newentry`. Cause: the RingZip function
  `zip_newentry` does not exist (calling it directly gives the same error); `zip_entry_open` exists. Two calls, with
  an existing archive and a new name.
- **stzZipFile.CreateFromDirectory**, raises R3 `Calling Function without definition: filesindir` for every existing
  folder (tried with two folders). Cause: `FilesInDir` is defined nowhere in the library.
- **stzZipFile.Size**, wrong. Returns 0 for an archive of 478 bytes (and for a second non-empty archive), 98 for an
  archive with no entry. Cause: `StzLen(read(path))` counts characters, and compressed bytes are not valid UTF-8.
- **stzZipFile.ExtractTo / ExtractHere / ExtractToNewFolder**, process killer. Extracting an archive whose entry names
  are absolute paths (made by `CreateFrom` with absolute paths, which stores them as given) into a folder that exists
  ends the Ring process with exit code 127, no message, no output flushed. Evidence: two different archives (t1, t3),
  a marker file written before the call exists and the one after does not. The same call into a folder that does not
  exist extracts nothing and raises nothing. Relative entry names extract correctly (also creating the folder).
- **stzZipFile.AddFile / AddFiles** on an archive that does not exist: return the archive path, create nothing, raise
  nothing (mode 'a' on a missing file). Evidence: AddFile on a fresh name, then Exists = 0.

## natural

- **stzTruthChain.IsA / IsNotA / Containing (a second starter)**. A second starter does not extend the chain, it
  restarts it: `TruthOf("ring").IsA(:Uppercase).IsA(:Lowercase).Holds()` is 1 (only the last starter decides) while
  `Why()` narrates both: `yes: "ring" is uppercase is lowercase`. `Containing("z").Containing("r")` on "ring" is 1 too.
  Cause: `_Add` tags every starter "seed", and `Holds` assigns the accumulator at each seed. Two calls.
- **stzTruthChain header comment** (file head) promises `TruthOf("Ring").IsA(:Lowercase).OrIsA(:Uppercase).Holds()`
  `#--> 1`; it answers 0 (Ring is neither all lower nor all upper case). Comment wrong, not the code.

## optim

- **stzOptimSentence** (read by init), a bare relation after a where clause. `maximize x` / `where x is between 0 and 9`
  / `x + 1 <= 5` is read as another variable declaration, so `ToModel()` raises `AddVar: 'x' is declared twice`, with
  no finding from `Findings()`; the file header promises "a bare `x + y <= 50` is always allowed". The same relation
  placed before `maximize`, or written as `keeping x + 1 <= 5`, works. Cause: after a `where` clause the parser stays in
  the where mode and reads every unlabelled clause as a variable range. Two calls.
- **stzOptimSentence** (read by init), `minimize x + y where x is binary` on ONE line: the splitter only cuts at
  ` and where `/` and keeping `, so the where clause stays in the objective and Findings says "no variables". Written
  on its own line or after `and`, it works.
- **stzOptimFile** and **stzOptimSentence**: a reader built with an empty text is valid (`IsValid()` = 1) in the file
  class when no `SetText` ran, because parsing has not run; `ToModel` then raises a different message
  (declare the variables before the objective). Minor.

## table

- **stzListOfTables.init**, the same-row-count rule is not enforced. `IsListOfTables` takes `len(paList[i][2])`, the
  length of the second COLUMN PAIR of each hash list (always 2), as if it were the row count, so a table of 2 rows and a
  table of 3 rows are accepted together (`IsListOfTables([ a1, a3 ])` = 1 with 2 and 3 rows). Two calls.
- **stzListOfTables.init** with an empty list raises R2 `Array Access (Index out of range)` (`paList[1]` is read before
  anything is checked), not the intended `Can't create the stzListOfTables object!` message.

## stats

- **stzCoeffExtractor.evaluateExpression** (and so **numericalDerivative**, and **extract** for every expression with
  `/`, `pow(`, `sqrt(`, `max(`, `min(` or `abs(`): raises R42 `Error in eval() function` (syntax error C27). Cause:
  it replaces the variables by calling `ManyReplaced(pacSubStrings, pcNewSubStr)` with a LIST of new texts, but that
  method takes ONE new text and returns an empty text for a list, so the formula that is evaluated is `_nResult_ = `.
  Evidence: `evaluateExpression("x + y", [...])`, `extract("x/8 + y/4", "x")`, `extract("pow(x, 2)", "x")`,
  `extract("sqrt(x)", "x")`, `extract("max([0, x-1000])", "x")` all raise; `StzStringQ("x + y").ManyReplaced([...], [...])`
  answers an empty text on its own.
- **stzCoeffExtractor.validateExpression** answers 0 for every expression (`"x + 1"`, `"x + y"`): it calls
  `createTestValues(cExpression)` and that method takes no argument (R20 inside its try).
- **stzCoeffExtractor.extract / extractLinearCoefficient**, substring matching of names: `extract("5*xx + 2*x", "x")` is 5,
  `extract("3*price", "p")` is 3, `extract("7*xx", "x")` is 7; a variable repeated (`2*x + 3*x`) answers its first term
  (2, not 5). Cause: the term search uses `ring_substr1` on the name and returns at the first term that contains it.
- **stzCoeffExtractor.init** changes Ring's global display precision to 4 decimals and leaves it there (`1/3` prints
  0.3333 afterwards) unless a brace closes or `BraceEnd()` is called; the class attribute that records the outside
  precision is read at `new`, so building two extractors in a row records 4 for the second.
