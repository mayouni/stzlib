# w4 defects (files wave): stzSplitter, stzAppServer, stzText, stzFolder

Format: method: symptom: cause. Each verified with a second call on different data.

## stzSplitter
- SplitAt([ :ToNParts, n ]) / [ :ToPartsOfNItems, n ] / unknown named pair: R14 istopartsofnitemsnamedparam: a method called on Q(p) that is defined nowhere (checked on 10 positions with n=3, and with :Foo)
- SplitBefore / SplitAfter with an unknown named pair: answer an empty string instead of raising: the if-chain has no else (:Foo, 3)
- SplitAtPosition(n) out of 1..N (0, 11 on 10; 20 on 5) or N = 1: one flat pair [ 1, N ] instead of a list of sections: the else branch returns [ 1, N ] without the outer list
- SplitAtPositions([ 1, 10 ]) on 10: R2: GetPairsFromPositions compares the last position with a literal 10 and indexes _aPairs_[0]; [ 1 ] on 10 also R2 in the helper
- SplitAtPositions with adjacent positions ([3,4], [5,6], [2,3,4], [9,10], [1,2]): reversed empty section such as [ 4, 3 ]: no filter on empty sections
- SplitAtPositions([ ]): raises "must be a list of numbers": IsListOfNumbers is false for an empty list although the code below handles length 0
- SplitAtSection(n1, n2): only n1 is range-checked (the test reads _n1_ twice): (3,99) on 12 gives [ [ 1, 2 ] ], (2,50) on 10 gives [ [ 1, 1 ] ]; a reversed section (5,3) answers [ [ 1, 4 ], [ 4, 10 ] ]
- SplitAtSections: unsorted input gives wrong sections ([ [8,9],[3,5] ] -> [ [1,7],[10,2],[6,10] ]; [ [6,7],[2,3] ] -> [ [1,5],[8,1],[4,10] ]): the sorted copy is built but the first and last cuts are read from the unsorted argument; touching or overlapping sections give reversed sections
- SplitAround(pair of numbers, e.g. [3,5] or [2,4]): R19: calls SplitAroundSection(p) with one argument where two are needed
- SplitAroundPosition(N): R21 operator with incorrect type (10 on 10, 6 on 6, 12 on 12): `return 1 : _nLen_-1` on the n = N branch is fine but the n = 1 / n = N branches return plain number ranges; n = N raises; n = 1 answers the plain numbers 2..N instead of [ [ 2, N ] ]; a position outside the range answers the plain numbers 1..N
- SplitAroundSection(n1, n2): R14 antisectionzz: calls AntiSectionZZ, defined nowhere (3,5 on 10; 2,4; 5,6 on 12)
- SplitAroundSections with overlapping sections ([[2,6],[4,8]] -> [[1,1],[9,12]] on 12 is right for overlap; kept as a note only)
- SplitToPartsOfNItems(0): R2 (n = 0 loops with step 0 / empty last section)
- GetPairsFromPositions([1]) on 10: R2, literal 10 in the helper
- SplitXT and the IB forms of SplitAtPosition / SplitAtPositions are not roots (aliases or nested)

## stzAppServer
- Use(cPath, fMiddleware): registers but never runs: the router stores [ path, f ] in @aMiddleware and nothing reads it (checked: /a with a header-setting middleware, then "/" and "*": no header on /b)
- Static(cPath, cDirectory): serves nothing: @aStaticRoutes is stored and never read; GET /files/hello.txt and GET /hello.txt (with "/" mapped) both answer 404 although the file exists
- Stop(): Port() keeps the last port and Uptime() keeps growing after the stop (the bound port and the start time are not cleared); ReactorQ is "" after
- Expose(oDb, cTable) on a table with no id column: the by-id routes answer 500 "no such column: id" (the key defaults to "id"); ExposeWithKey is the cure (checked with a sensor table and GET /api/sensor/p1)
- RawWrite(): answers 0 both on a live connection (the peer received "ok") and on a non-existent connection id, so it is not a delivery flag
- RawPort(nSid) on a stopped server: raises R13 (the reactor is an empty string); on an unknown id of a running server it answers -2
- MountAuth, MountAuthAt, MountOidcProvider(At), RequireSignedRequests, SetSecureCookies, SetAgentSlice return nothing (their Q forms, not roots, return the server)
- AdoptAgentHost(oHost): replaces the hosted host, so the agents added before are gone (NumberOfAgents 0 after adopting an empty host)
- StartTls / StartHttps success path not run: no certificate available (only the -13 error path with missing files, and bad CA); Run() not run (blocking loop)
- SplitAt([ :PositionsIB, ... ]): R14 splitatpositionsib; SplitBefore([ :PositionIB, n ]): R14 splitbeforepositionib; SplitAfter([ :PositionIB, n ]): R14 splitafterpositionib; SplitAtPositionIB (also reached from SplitAt([:AtIB..]) paths) is defined nowhere
- SplitAfter([ :PositionsIB, [3,6] ]) gives overlapping sections [ [1,4],[3,7],[6,10] ] (the IB widening re-adds the cut on both sides): by design of the IB form, noted only

## stzText (models not loaded: neural and generative paths read from the body, recorded as what they answer without one)
- SummarizedAbstractively(): R19 without a generative model (3 texts): the extractive fallback calls Summary() without its n argument (SummarizedIn(n) works)
- NamedEntities (and PersonNames, Organizations, Locations, EntitiesOfType, Profile, ShowEntities): the rule-based recognizer joins a capitalized word after a full stop to the previous entity: "Paris. Angela Merkel" typed ENTITY, "Apple. Paris" typed ORGANIZATION, "Berlin. Angela Merkel" typed ENTITY (3 texts)
- EntityTypeOf / EntitiesTypedAs / ClassifiedAs without a neural model: every candidate scores 0 on a short name so the first candidate wins (Microsoft -> city when city is listed first; all five entities came out as city); a limitation, not an error
- EntitiesOfType is case-sensitive ("person" finds nothing where "PERSON" finds Barack Obama)
- Nouns also returns proper nouns (prefix NN); the rule tagger mislabels "brown" in "quick brown fox" as NN
- InContextWithWindow(word, "x"): R41 invalid numeric string for a non-number window
- the old briefs of SentimentExplained and ReadabilityExplained said "human-readable sentence": both return lists of pairs (corrected in the blocks)
- the old comment of Lemmatized said better -> good: it returns well in "over better fences" (adverb reading)
- LemmatizedInLanguage / StemmedInLanguage with an unknown or unsupported language (klingon; german for lemmas) answer with the English result, silently
- not exercised: Embedding, SemanticSimilarityWith, AnswerAbout, SummarizedAbstractively and NeuralEntities with a model; the embedding branches of SummarySentences and MostSimilarSentenceTo (read from the body)

## stzFolder
- DEFAULT MODE (batch off): FileRead, FileCreate, FileRemove, FileCopy, FileMove, DeleteFolder, FileSize, FileInfo, FileModify, FileOverwrite, FileAppend, FileCreateQ end in R14 (getdirectorypath is defined nowhere): create/remove/copy/move/DeleteFolder/FileRead do the work then raise (FileRead loses its text); the others raise before acting (FileModify left the text unchanged, FileOverwrite left c.md unchanged). SetBatchMode(1) makes them work
- IsPath: R19: calls IsFilePath() and IsFolderPath() with no argument (checked with a.txt and sub1)
- IsDeepPath: returns nothing: `IsDeep(_cPath_)` without return
- IsDeepFile: FALSE for a deep file that exists ('/sub1/d.txt', '/sub1/deep1/f.txt'); TRUE only for shapes like '/zz/a.txt': NormalizePath turns a name that is not a top-level file into a folder path (ends with /)
- IsDeepFolder / DeepExists / IsDeep: shape-only: '/zz/yy/' and '/nothing/zz.txt' TRUE although absent; '/a.txt' FALSE; without the leading slash 'sub1/d.txt' FALSE
- IsFile / IsFolder / Exists / IsFilePath / IsFolderPath / PathType: compare only the LAST NAME with the direct children: '/zz/a.txt' TRUE, '/zz/sub1' TRUE, 'sub1/d.txt' FALSE
- IsInside / IsOutside: a relative path is resolved against the process folder, not the position: IsInside('sub1') FALSE; the position itself is not inside (strict)
- IsFolderEmpty(path) / ShouldExpandFolder / ToString with Expand modes: `new stzFolder(path)` creates a missing folder: IsFolderEmpty('brandnew') created it in the process folder; ToString with Expand created empty deep1/sub1/sub2 folders in the process folder (found as stray empty folders in test/reflect and removed by hand); Expand opens only the first level because inner names are tested relative to the process folder
- ParentFolder('sub1') answers 'sub1' (the folder itself without its slash); ParentFolder('sub1/d.txt') raises "Incorrect path!"; PathInfo.parent_folder is wrong for a folder
- ExistingPathsAmong / MissingPathsAmong: R24 _cpath_: append a variable never set (two lists each)
- CountFolder: always 0 (FindFolders('sub1'), '/sub1/', '/sub1' all []); FindFolders and FindTheseFolders match only * patterns
- FilesIn / FoldersIn: raise 'cPath must be non-empty a string' for any non-empty child folder (sub1 abs), 'Incorrect path!' for the folder itself or a deeper one; [] for an empty child and for a relative name
- DeepCountFileIn / DeepCountFolderIn: R14 findfilein / findfolderin; DeepCountTheseFiles: R24 _cpath_; DeepCountTheseFilesIn: R14 searchthesefilesin; DeepCountTheseFoldersIn: R14 searchthesefoldersin
- DeepContains* (all): the query is compared as given with the lowercase listing: 'B.TXT', 'D.TXT', 'SUB1' FALSE where the lowercase TRUE
- DeepContainsOneOfTheseFiles / DeepContainsOneOfTheseFolders: call the ALL version: ['f.txt','zz.txt'] FALSE, ['sub2','zz'] FALSE (both orders checked); the ...In versions are right
- RelativePathFromHome / DistanceFromHome / NavigationInfo: R14 getrelativepath away from home (checked at sub1 and sub1/deep1); fine at home
- GoTo: does not check that the folder exists ('nothing' accepted); accepts '..' as text; GoUp can leave the home folder (checked up to the parent of the fixtures) so the delete methods could then act on the parent
- CollapseFolders / CollapseTheseFolders / CollapseThese: no visible effect (turn Expand off; the list is read only under Expand, which clears it)
- ExpandThis: R24 cfolders (passes an undefined variable)
- GetFoldersContainingFileMatches and VizDeepFindFiles: R24 _aallpaths_ (uninitialized variable)
- CollectFoldersWithFileMatches: returns nothing; the list it fills is a copy
- GetFolderNameFromPath: cuts at the FIRST separator ('a/b/c' -> 'b/c'; an absolute path loses only its drive)
- GetPhysicalOrder: R24 _aEntry_; FormatStatsForFolder: R14 countfilesin (both private)
- Find / DeepFind: files + folders joined with list-append: [ "/a.txt", [ ] ], [ [ "/sub1/", "/sub2/" ] ]
- SearchInFolder / SearchInFolders / SearchInTheseFolders: the line loop reuses the file loop counter: sub1 'alpha' -> [ ["deep1",[2]] ] and sub2 'alpha' -> [ ["s3.txt",[1]] ] (s3.txt does not hold it); 'zzz' -> [] although s2.txt holds it
- DeepSearchInFolder / DeepSearchInFolders: always [] (tests fexists on the folder path)
- DeepModifyInFile / DeepModifyInFiles / DeepModifyInFolder / DeepModifyInFolders / DeepModifyInRoot: always 0 and nothing changed (f.txt and d.txt checked)
- DeepDeleteFile: always raises "Can't navigate outside the folder!" (IsInside of a bare name against the process folder); DeepDeleteFolder: answers 1 and deletes nothing (relative paths fail the dirExists test); FolderDeepDelete and FolderDeepRemove call the file version
- FilesCreate: every file reported failed with R24 cfilename, created always [ ]; the files ARE created
- FileCreate: answers 1 and creates nothing when the parent folder is missing ('nodir/n3.txt', 'x/y/z.txt'); FileCopy / FileMove to a missing folder answer 0 and do nothing
- FileOverwrite: writes then raises R13 "Object is required" (batch mode); FileSafeOverwrite: R11 class not found, nothing written; FileErase: R11 class stzfileeraser not found; FileSafeErase: R11; files kept; FileBackup: R20 extra parameters, no backup
- FileInfoXT (not a root): raises "Unsupported feature! Use OS-level tools for file timestamps."
- IsSecurePath: returns 1 when a NUL byte is found (inverted first test, read from the body; one call consistent)
- Matches: '?' is not a wildcard; case-sensitive; a star in the middle is unsupported (body)
- FileRead of a deeper file ('sub1/d.txt', absolute too) raises "cFile does not exist in the folder."; FileRead of a folder name answers ""
- Safety: every delete method ran on a fixture inside the scratch folder (out/fx/<case>), guarded by a path check before and after each call
