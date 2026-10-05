# Wave 4 defects (stzGrid, stzListOfPairs, stzAuth, stzJson) -- code, not comments; none fixed

Each was called on two different data sets (grids 5x4 and 4x3 with and without an obstacle, pair lists of text and of numbers) before it was written down.

## stzJson
- ToString, ToStringXT, Show, Print, Copy: raise "aList must be a well-formatted JSON list" for every non-empty ARRAY (arrays of numbers, of text, of objects): the serializer ListToJson accepts only hash lists and deep hash lists, never a plain list. An empty array is fine. An empty object writes as [ ].
- Value: JSON true/false come back as 1/0.

## stzListOfPairs
- UpdatePairWith (and UpdateNthPairWith, UpdatePairN, UpdatePair, UpdateNthPair): n above 2 raises "n must be a number equal to 1 or 2" although the list may hold more pairs; the check is against 1 and 2, not against the number of pairs.
- ReplacePair, PairReplaced (and ReplacePairQ): R20 on every call: IsPair(paNewPair) inside the class reaches the inherited stzList.IsPair method (no argument) instead of the global function.
- SortBy, SortByInAscending, SortByUp, SortedBy: leave the order unchanged for every key expression tried (@pair[2], len(@pair[1]), @pair, -@pair[2]); the forwarded stzList.SortBy does not evaluate an expression on a list item (it works on text items).
- SortByInDescending, SortByDown, SortedByInDescending, SortedByDown: swap the two items of every pair instead of sorting: after the (inert) ascending sort they call Reverse, which is SwapItems in this class.
- SortedInDescending (alias under SortedDown): answers the ASCENDING order because its body calls Sorted.
- ExpandedIfPairsOfNumbers: R14, calls ExpandedIfPairOfNumbers which exists only in list/archive.
- IsListOfSections: always TRUE (the loop sets _bIsMadeOfNumbers_, a variable nobody reads, instead of _bResult_); [ [ "a", "b" ] ] and mixed pairs pass.
- AreAnagrams (AreAnagramsCS): R14, reads FirstValue and SecondValue which the class does not define.
- ToStzSetOfSections: always raises "You must provide a list of sections", even for [ [ 1, 3 ], [ 5, 8 ] ] that ToStzListOfSections accepts.
- ContainsInAllPairs, ContainsThisInAllPairs (aliases of ContainsInAnyPair): answer TRUE when only one pair holds the item.
- Trap, not a defect: Reverse, Inverse, Swap, PairsSwapped... exchange the items inside each pair; they do not reverse the order of the pairs.
- ToStzHashList: raises for two pairs sharing a first item ("well formed hashlist"); wraps each value in a one-item list.

## stzAuth
- None found in the 135 roots. Exercised: every root of the password, session, TOTP, magic link, reset, email code, roles, actor, governance, lockout, OIDC (sandbox) and passkey (sandbox) groups. Not exercised: the SUCCESS path of LoginWithSaml and its three forms (needs a signed assertion; the refusals were run: no provider raises, a provider with no trusted IdP raises). SetStore with a database store was not run (no disk write); a second in-memory store was.
- Notes that are not defects: Authenticate does not count failures and passes a locked account; SetPasswordResetTTL returns the object while the other setters return nothing; LockAccount does not delete sessions, they work again after UnlockAccount; a short password burns the reset token.

## stzGrid
- ShortestPath: the end cell comes FIRST ([ 1, 1 ] to [ 3, 1 ] answers [ 3, 1 ], [ 1, 1 ], [ 2, 1 ]); cause ReconstructPath: Ring's insert(list, 1, item) inserts after item 1, not at the front. MazeWithPath stores that order too.
- ReconstructPath: same cause, same wrong order.
- MoveToNthNode (and Position, Cell forms): R14 in every direction: calls MoveToNthNodeBackward/Forward/Right/Up/Down, MoveMoveToNthNodeLeft, none defined.
- MoveToPreviousNthNode (7 forms): R19: MoveToNode(This.PreviousNthNode(n)) passes one list where two numbers are wanted.
- PreviousNthNode: wrong for n >= 2: repeats MoveToPreviousNode, which turns the direction round after each step, so the steps cancel (n=2 answers the current cell, n=3 the answer of n=1); tested facing forward and right.
- MoveNRight, MoveNNodesRight, MoveNCellsRight, and the same three for Left, Up, Down: R24 "uninitialized variable n": they take no argument but pass n on.
- Maze: R19, calls RandomMaze without its density.
- AreObstacles: R20: CheckParams(panColRow) is called with an argument; behind it the loop reads panColRow[1], panColRow[2] instead of each pair.
- ShowAdjacent: R14, calls PaintNeighbors which exists nowhere.
- ManhattanPath: an obstacle on the horizontal leg raises R14 (FindManhattanPathVerticalFirst missing); on the vertical leg R20 (ShortestPath called with four arguments).
- ManhattanPathVerticalFirst, ZigZagPath: an obstacle they cannot sidestep raises R20 (ShortestPath called with four arguments).
- SetCurrentNode (and forms): a cell outside the grid raises R24 "@nrow" instead of the intended range message (the message reads @nRow, which does not exist).
- ShowNode/ShowCell/ShowCells/ShowNeighbors print but return nothing, while ShowNodes/ShowPath return the picture (documented as behaviour, not as a defect).
- MoveForwardN/MoveBackwardN: the wrap to the next row moves n ROWS, not n cells on (from column 3 of 4 in row 1, two steps forward land on column 1 of row 3); documented as behaviour.
- ZigZagPath with start = end answers one pair, not a list of pairs.
