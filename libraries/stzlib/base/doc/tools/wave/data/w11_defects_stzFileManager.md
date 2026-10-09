# Wave 11 defects -- stzFileManager and the other classes of this batch

Found by calling each method on invented data, in a scratch folder. Nothing was fixed. Each line: method, symptom, cause, evidence.

## file/stzFile.ring

1. **stzFileManager.CopyTo, CopyAs, MoveTo, MoveAs, RenameAs, CreateBackup, CreateBackupAs, SafeDelete, SafeRemove, ZipBackup, IsExecutable** -- raise `Error (R3) : Calling Function without definition: _filename / _filedirpath / _filecompletebasename / _fileextension`. Cause: the helpers `_FileName`, `_FileDirPath`, `_FileExtension`, `_FileCompleteBaseName` are written between `class stzFileXT` and `class stzFileInfo`, and Ring attaches a function placed between classes to the class before it, so they are methods of stzFileXT, not globals (the file itself warns about this at the FileManage functions). Evidence: every call raised R3; CopyToAs and MoveToAs, which do not use a helper, work. SafeDelete leaves the file in place.
2. **stzFileManager.SplitByLines, SplitBySize, SplitByPattern** -- raise `Error (R13) : Object is required`. Cause: the body treats the text returned by `StzFileRead(path)` as a reader object (`_oReader_.Lines()`); it also calls the missing helpers of item 1 and `StzFileCreate`. Evidence: three calls, same error.
3. **stzFileManager.Backup** -- returns 1 and writes no file. Cause: the target name is `file.backup.` + `StzTimeStamp()`, which is `09/10/2026 11:37:52`; the `/` makes folders that do not exist, the copy fails and the 1 is returned anyway. Evidence: two calls, no backup file in the folder.
4. **stzFileManager.LastModified** -- returns the empty text for every file (stub).
5. **stzFileInfo.IsExecutable** -- returns 0 for every file. Cause: `StzEnginePathExtension` returns the extension with its dot (`.exe`), the body compares with `exe`, `bat`, `cmd`, `com`. Evidence: prog.exe and run.BAT both 0.
6. **stzFileInfo.IsWritable** (and so **Info**) -- creates an empty file when the path does not exist. Cause: the test opens the path with `fopen(path, "a")`. Evidence: ghost1.txt, nope.txt, nope2.txt did not exist before the call and did after it.
7. **stzFileInfo.InfoXT** -- raises `Unsupported feature!` always, because it calls `LastRead`, which raises. **CreationTime** and **LastReadingTime** raise on purpose.
8. **stzFileInfo.CompleteSuffix / CompleteBaseName** -- CompleteSuffix equals Suffix (a.tar.gz gives `.gz`, not `.tar.gz`); CompleteBaseName returns the full name with the extension (a.tar.gz).
9. **stzFileAppender.Write, WrtiteQ, WriteLine ...** -- a number as argument (5, 1.5) ends the whole Ring process silently with exit code 1; a list and the empty text do not. Cause not located (the engine append call); evidence: two numbers, exit 1 and the line after the call never runs. The methods WrtiteQ, WrtiteLinesQ are misspelt, and WriteSeperator returns nothing.
10. **stzFileOverwriter.PreserveAndModify** -- raises `Error (R12) : Error in property name, property not found: coriginalcontent`. Cause: `This.cOriginalContent` should be `@cOriginalContent`. Evidence: two files.
11. **stzFileModifier.InsertLine** -- raises `Error (R24) : Using uninitialized variable: nnewline`. Cause: the body passes `nNewLine`, the parameter is `cNewLine`. Evidence: one call, deterministic by reading.
12. **stzFileModifier.Modify(old, :With = new)** -- raises `Incorrect param type! cNewText must be a string.`. Cause: the unwrapped value is stored in `_cNexText_` (typo) and the original list is validated. Evidence: one call.
13. **stzFileXT.init** -- the constructor returns the object of the chosen intent, but Ring ignores a constructor's return value, so `new stzFileXT(path, "info")` is an empty stzFileXT (`FileName` raises R14, `Content` answers NULL for "read"). The intent `erase` names `stzFileEraser`; the class is `stzFileEaraser`, so it raises R11 class not found. Evidence: info, read, erase.
14. **stzFileCreator.WriteTemplate(other)** -- returns nothing for an unknown template (the three known return 1) and writes a `# File:` header; not a defect, noted.

## list/stzListChecker.ring

15. **stzListChecker.ContainsItem** -- answers 0 for every item, present or not; so **ContainsAllOfThese** answers 1 only for an empty list and **ContainsOneOfThese** answers 0 always. Cause: `StzEngineListContainsCS(list, item, cs)` answers 0 for present items (checked directly on [1,2,3] and ["a","b"]); the engine function `stz_list_contains_cs` takes the needle as a value handle and the class passes the raw item. Evidence: numbers, texts and a list item; `stzList.Contains` answers 1 on the same data.
16. **stzListChecker.ContainsW** -- raises `Calling Function without definition: stzccodetoringcode`; no file defines `StzCCodeToRingCode` (stzListClassifier.ring notes the same missing function).

## file/stzHtml.ring

17. **stzHtmlBuilder.AppendToCurrent / Build / BuildToFile / Root** -- `Build` answers the empty text whatever was appended; BuildToFile writes an empty file. Cause: `@oCurrent = @oRoot` copies the root object (Ring assigns objects by value), so AppendToCurrent adds to the copy. Evidence: root children 0, current children 1; also after `SetCurrent(Root())`.
18. **stzHtmlBuildNode.AppendChild** stores a copy: a change to the child after it was appended does not appear in ToHtml (`span` appended, then SetText("late"), output `<span></span>`). SetText and SetAttr do not escape (`<` stays, a `"` in an attribute breaks the markup), unlike stzXmlBuilder.

## list/stzYielder.ring

19. **stzYielder.MapIndexed / MapIndexedQ** -- every item of the result is the text `<list>`; MapIndexedQ then replaces the held list by those texts. Evidence: :Square, :Abs, :Negate, :Increment on two lists.

## Not defects, noted

- stzXml.TextsAt indexes only the last step of the path, so `library/book/title` gives one title.
- stzXml.NumberAt / stzXmlNode.Number raise `Invalid numeric string` for non-numeric text.
- stzYielder: an unknown operation name returns the content unchanged without a message.
