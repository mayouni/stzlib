# Wave 11 defects: stzAuthMemoryStore, stzAuthDbStore, stzResponsePlan family, stzVirtualSystem family, stzVirtualEnvironment family, stzVirtualFileSystem family, stzDelivery family

Found by calling every root method with invented data (in-memory objects, `:memory:` sqlite, a rehearsal double, a scratch folder). Each was confirmed with a second dataset except where marked. Nothing was fixed. Each is recorded as a warning or a note in the doc block of the method.

## stzAuthMemoryStore (security/stzAuthStore.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| PutSession | a second PutSession with a token already stored adds a second row instead of replacing the first; Session keeps answering the first, CountSessions grows; stzAuthDbStore (INSERT OR REPLACE) replaces | `@aSessions + [...]` with no search for the token | same record twice gives count 2 (db store: 1); tokens "zz" for bob then carol: Session("zz")[:user] is bob and count is 2 |

## stzVirtualSystem (system/stzVirtualSystem.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| RollbackTo (after UndoLast) | raises R2 `Array Access (Index out of range)` instead of restoring | the snapshot keeps the history length at its creation; UndoLast cuts the history but does not trim snapshots, and RollbackTo reads `@aHistory[_j_]` up to the old length | snapshot at 3 ops, UndoLast(2), RollbackTo; snapshot at 2 ops, UndoLast(1), RollbackTo: both raise |
| UndoLast | a negative count raises R2 `Index out of range` (misuse, one dataset only) | `_nKeep_ = n - pnCount` exceeds the history length | UndoLast(-1) on 4 operations |
| CreateSnapshot / RollbackTo | a second snapshot of the same name does not replace the first; RollbackTo restores the first | RollbackTo takes the first match | snapshots "s" after 1 and 2 operations: RollbackTo("s") leaves 1 node and 1 operation |

## stzFileTree / stzVirtualFileSystem (system/stzVirtualFileSystem.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| CopyFile, MoveFile (stzFileTree.Apply) | copying or moving a path the twin does not hold creates an EMPTY file at the destination, where the real disk refuses | `PutFile(to, ContentOf(from))` and `ContentOf` answers an empty text for an absent path | CopyFile("/nope","/dst") gives Exists("/dst") 1 and size 0; MoveFile("/nope2","/dst2") the same; the plan's Validate flags both against the disk |
| DeleteFolder | the files below the folder stay in the twin (the bridge's real folder delete returns FALSE for a folder that still holds a file) | `Remove` drops one path only | CreateFolder /d, two files under it, DeleteFolder("/d") leaves both files in Paths() |
