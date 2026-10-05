#!/usr/bin/env python3
"""mkgrid.py -- writes w1_stzGrid_01..02.txt from alias families (same text for every name of a family).
Each family: (names, brief, returns, params-override, see, warning, note)."""
import json, os, sys
D = os.environ["DOCWAVE_DIR"].rstrip("/") + "/"
NOTH = "nothing; the position changes"
F = []
def fam(names, brief, ret="", par="", see="", warn="", note=""):
    F.append((names.split(), brief, ret, par, see, warn, note))

# ---- information
fam("init", "Builds a grid of the given numbers of columns and rows, with the current position on column 1, row 1.",
    "nothing; the object is built", "panColRow=the size as [ columns, rows ], a pair of numbers",
    "Size, NumberOfColumns, NumberOfRows", "",
    "the grid holds no data of its own: it keeps a current position, a direction, obstacles and a path; anything but a pair of numbers raises an error")
fam("Size", "Returns how many cells the grid has, its columns times its rows.", "a number", "", "NumberOfColumns, NumberOfRows, Nodes")
fam("NumberOfColumns", "Returns how many columns the grid has.", "a number", "", "NumberOfRows, Size")
fam("NumberOfRows", "Returns how many rows the grid has.", "a number", "", "NumberOfColumns, Size")
fam("CurrentPosition Position CurrentNode CurrentCell", "Returns the current position as [ column, row ], counted from 1 at the top left.",
    "a pair of numbers [ column, row ]", "", "CurrentColumn, CurrentRow, SetCurrentNode", "", "the column comes first, then the row")
fam("CurrentColumn", "Returns the column of the current position, counted from 1.", "a number", "", "CurrentRow, CurrentPosition")
fam("CurrentRow", "Returns the row of the current position, counted from 1.", "a number", "", "CurrentColumn, CurrentPosition")
fam("IsValidPosition", "TRUE if the column and the row both fall inside the grid, counted from 1.", "TRUE or FALSE", "",
    "IsCurrentPositionValid, IsObstacle", "", "an obstacle is a valid position")
fam("IsCurrentPositionValid", "TRUE if the current position falls inside the grid, which it always does unless it was forced.", "TRUE or FALSE", "",
    "IsValidPosition")
# ---- configuration
fam("Direction", "Returns the direction the grid is facing, in lower case: forward, backward, left, right, up or down.", "a text, forward by default", "",
    "SetDirection, MoveN", "", "the Move...N methods turn the direction as they go")
fam("SetDirection", "Turns the grid to face forward, backward, left, right, up or down; any other word raises an error.", "nothing; the direction changes", "",
    "Direction, MoveToNextNode", "", "case is ignored; the position does not change")
fam("SetCurrentNode SetCurrentPosition SetCurrenCell SetCurrentCell", "Puts the current position on the given cell, whatever is there; raises an error outside the grid.",
    "nothing; the position changes", "", "MoveToNode, CurrentPosition",
    "The error raised for a cell outside the grid is R24, Using uninitialized variable @nrow, instead of the intended range message: the message reads an attribute that does not exist",
    "unlike MoveToNode it does not check for an obstacle and does not turn the direction")
# ---- movement to a node
fam("MoveToNode Moveto MoveToCell", "Moves the current position onto the given cell; raises an error outside the grid, and stays put on an obstacle.",
    NOTH, "", "SetCurrentNode, MoveBy", "", "an obstacle blocks the move without any error; the direction is kept")
fam("MoveToFirstNode MovetoFirstPosition MoveToFirstCell", "Moves the current position to column 1, row 1, the top left cell, unless it is an obstacle.", NOTH, "",
    "MoveToLastNode, MoveToNode")
fam("MoveToLastNode MovetoLastPosition MoveToLast MoveLast MovetoLastCell", "Moves the current position to the last column of the last row, the bottom right cell, unless it is an obstacle.",
    NOTH, "", "MoveToFirstNode, MoveToNode")
fam("MoveToNextNode MoveToNextPosition MoveToNext MoveNext MoveToNextCell", "Moves the current position one step in the direction the grid faces.", NOTH, "",
    "MoveToPreviousNode, SetDirection, MoveN", "",
    "forward and backward wrap from one row to the next; the other directions stop at the edge; an obstacle blocks the step")
fam("MoveToPreviousNode MoveToPreviousPosition MoveToPrevious MovePrevious MoveToPreviousCell", "Moves the current position one step against the direction the grid faces.", NOTH, "",
    "MoveToNextNode, SetDirection", "", "it leaves the direction turned round: facing forward becomes backward, right becomes left")
fam("MoveToNthNode MoveToNthPosition MoveToNthCell", "Raises error R14 today instead of moving the current position n steps in the direction the grid faces.",
    "nothing today; the call raises", "", "MoveToNextNthNode, MoveN",
    "Raises R14 today for every direction: each branch calls a method that exists nowhere, such as MoveToNthNodeBackward, and the right branch has a doubled Move in its name",
    "MoveN and MoveToNextNthNode do the same job")
fam("MoveToNextNthNode MoveToNthNextNode MoveToNthNext MoveToNextNth MoveToNextNthPosition MoveToNthNextPosition MoveToNextNthCell MoveToNthNextCell",
    "Moves the current position n steps in the direction the grid faces, in one jump.", NOTH, "", "NextNthNode, MoveN, MoveToPreviousNthNode", "",
    "a jump that would leave the grid, or land on an obstacle, changes nothing; the direction is kept")
fam("MoveToPreviousNthNode MoveToNthPreviousNode MoveToNthPrevious MoveToPreviousNth MoveToPreviousNthPosition MoveToNthPreviousPosition MoveToPreviousNthCell MoveToNthPreviousCell",
    "Raises error R19 today instead of moving the current position n steps against the direction the grid faces.", "nothing today; the call raises", "",
    "MoveToNextNthNode, PreviousNthNode",
    "Raises R19 today on every call: it hands MoveToNode the whole [ column, row ] list that PreviousNthNode returns, where MoveToNode wants the column and the row as two arguments",
    "MoveToNode with the two numbers of PreviousNthNode does the job")
fam("MoveBy MoveByNColsNRows MoveFor MoveForNColsNRows", "Moves the current position by a number of columns and rows, which may be negative.", NOTH, "",
    "MoveToNode, MoveN", "", "a target outside the grid raises an error; a target on an obstacle changes nothing; the direction is kept")
fam("MoveN MoveNNodes MoveNCells", "Moves the current position n steps in the direction the grid faces, whatever it is.", NOTH, "",
    "Move, MoveForwardN, MoveRightN", "", "it turns to the direction method of the current direction, so the direction may be set by it")
fam("Move", "Moves the current position one step in the direction the grid faces.", NOTH, "", "MoveN, MoveToNextNode")
fam("MoveForwardN MoveForwardNNodes MoveNForward MoveNNodesForward MoveForwardNCells MoveNCellsForward",
    "Turns the grid forward and moves n columns right, or to column 1 of the row n lower when the row has no room.", NOTH, "",
    "MoveForward, MoveBackwardN, MoveRightN", "",
    "forward reads the grid row by row, but the wrap goes n rows down, not n cells on, so from column 3 of 4, row 1, two steps land on column 1, row 3; with no such row, or an obstacle, nothing moves")
fam("MoveForward", "Turns the grid forward and moves one cell on, to column 1 of the next row at the end of a row.", NOTH, "", "MoveForwardN, MoveBackward",
    note="at the last cell, or before an obstacle, it stays put")
fam("MoveBackwardN MoveBackwardNNodes MoveNBackward MoveNNodesBackward MoveBackwardNCells MoveNCellsBackward",
    "Turns the grid backward and moves n columns left, or to the last column of the row n higher when the row has no room.", NOTH, "",
    "MoveBackward, MoveForwardN, MoveLeftN", "",
    "with no such row, or an obstacle, nothing moves: from column 2 of row 2 two steps back stay where they are")
fam("MoveBackward", "Turns the grid backward and moves one cell back, to the last column of the row above at the start of a row.", NOTH, "",
    "MoveBackwardN, MoveForward", note="at the first cell, or before an obstacle, it stays put")
for d, dd, opp, verb in (("Right", "right", "Left", "columns right"), ("Left", "left", "Right", "columns left"),
                          ("Up", "up", "Down", "rows up"), ("Down", "down", "Up", "rows down")):
    fam("Move%sN Move%sNNodes Move%sNCells" % (d, d, d), "Turns the grid %s and moves n %s, unless that leaves the grid or lands on an obstacle." % (dd, verb),
        NOTH, "", "Move%s, Move%sN, MoveN" % (d, opp), "", "nothing moves when the target is outside the grid or an obstacle; the cells in between are not checked" if d == "Right" else "")
    fam("Move%s" % d, "Turns the grid %s and moves one cell %s." % (dd, dd), NOTH, "", "Move%sN, Move%s" % (d, opp), "", "at the edge, or before an obstacle, it stays put")
    fam("MoveN%s MoveNNodes%s MoveNCells%s" % (d, d, d), "Raises error R24 today instead of moving n cells %s." % dd, "nothing today; the call raises", "",
        "Move%sN" % d,
        "Raises R24, Using uninitialized variable n, on every call: the method takes no argument but passes n on; Move%sN takes the number of steps" % d)
# ---- traversal and neighbours
fam("Nodes", "Returns every cell of the grid as [ column, row ], column by column, from the top of column 1.", "a list of [ column, row ] pairs", "",
    "Size, Neighbors", "", "Positions and Cells give the same list")
fam("Neighbors", "Returns the up to eight cells around the current position, obstacles included, ordered by column then row.", "a list of [ column, row ] pairs", "",
    "WalkableNeighbors, ShowNeighbors", "", "a corner has three, an edge five; WalkableNeighbors drops the obstacles and the diagonals")
fam("ShowNeighbors ShowAdjacents ShowAdjacentNodes ShowAdjacentCells", "Prints the grid with the cells around the current position marked by the neighbour character.",
    "nothing; the grid is printed", "", "Neighbors, SetNeighborChar, Show")
fam("ShowAdjacent", "Raises error R14 today instead of printing the grid with the neighbours marked.", "nothing today; the call raises", "", "ShowNeighbors",
    "Raises R14 today: it calls PaintNeighbors, a method that exists nowhere", "ShowNeighbors does the job")
fam("NodeUp", "Returns the cell just above the current position; raises an error at the top row.", "a pair [ column, row ]", "", "NodeDown, NthNodeUp")
fam("NodeUpLeft", "Returns the cell above and to the left of the current position; raises an error when there is none.", "a pair [ column, row ]", "", "NodeUp, NodeLeft",
    note="the error message says above, even when the left edge is the cause")
fam("NodeUpRight", "Returns the cell above and to the right of the current position; raises an error when there is none.", "a pair [ column, row ]", "", "NodeUp, NodeRight")
fam("NodeDown", "Returns the cell just below the current position; raises an error at the bottom row.", "a pair [ column, row ]", "", "NodeUp, NthNodeDown")
fam("NodeDownLeft", "Returns the cell below and to the left of the current position; raises an error when there is none.", "a pair [ column, row ]", "", "NodeDown, NodeLeft")
fam("NodeDownRight", "Returns the cell below and to the right of the current position; raises an error when there is none.", "a pair [ column, row ]", "", "NodeDown, NodeRight")
fam("NodeLeft", "Returns the cell just left of the current position; raises an error at the first column.", "a pair [ column, row ]", "", "NodeRight, NthNodeLeft")
fam("NodeRight", "Returns the cell just right of the current position; raises an error at the last column.", "a pair [ column, row ]", "", "NodeLeft, NthNodeRight")
fam("DistanceTo", "Returns the Manhattan distance, columns plus rows, from the current position to the given cell.", "a number", "", "EuclideanDistanceTo, HeuristicCost",
    note="obstacles are ignored")
fam("EuclideanDistanceTo", "Returns the straight-line distance from the current position to the given cell.", "a number", "", "DistanceTo")
fam("NextNthNode", "Returns the cell n steps ahead in the direction the grid faces, without moving; the current cell when the move is blocked.", "a pair [ column, row ]", "",
    "PreviousNthNode, MoveToNextNthNode", "", "a jump out of the grid or onto an obstacle answers the current position, not an error; forward and backward wrap as MoveForwardN does")
fam("PreviousNthNode", "Returns the cell n steps behind the direction the grid faces, without moving, but wrongly for n above 1.", "a pair [ column, row ]", "",
    "NextNthNode, MoveToPreviousNode",
    "Wrong for n of 2 or more: it repeats MoveToPreviousNode, which turns the direction round after each step, so the steps cancel out; n of 2 answers the current cell and n of 3 the answer of n of 1",
    "n of 1 is right")
fam("NthNodeUp", "Returns the cell n rows above the current position; raises an error when it falls outside the grid.", "a pair [ column, row ]", "", "NodeUp, NthNodeDown")
fam("NthNodeDown", "Returns the cell n rows below the current position; raises an error when it falls outside the grid.", "a pair [ column, row ]", "", "NodeDown, NthNodeUp")
fam("NthNodeLeft", "Returns the cell n columns left of the current position; raises an error when it falls outside the grid.", "a pair [ column, row ]", "", "NodeLeft, NthNodeRight")
fam("NthNodeRight", "Returns the cell n columns right of the current position; raises an error when it falls outside the grid.", "a pair [ column, row ]", "", "NodeRight, NthNodeLeft")
# ---- obstacles
fam("AddObstacle", "Marks a cell as an obstacle that moves and paths avoid; raises an error outside the grid.", "nothing; the obstacle is recorded", "",
    "AddObstacles, RemoveObstacle, IsObstacle", "", "adding the same cell twice records it once; an obstacle may sit under the current position")
fam("AddObstacles", "Marks each cell of a list as an obstacle, skipping items that are not a pair.", "nothing; the obstacles are recorded", "", "AddObstacle, ClearObstacles",
    note="a pair outside the grid raises an error and the pairs before it are kept")
fam("RemoveObstacle", "Removes the obstacle on a cell; a cell without one changes nothing.", "nothing; the obstacle is removed", "", "AddObstacle, ClearObstacles")
fam("ClearObstacles RemoveObstacles", "Removes every obstacle.", "nothing; the obstacles are removed", "", "RemoveObstacle, AddObstacles")
fam("IsObstacle", "TRUE if the cell holds an obstacle.", "TRUE or FALSE", "", "AddObstacle, Obstacles")
fam("AreObstacles", "Raises error R20 today instead of telling whether every cell of a list is an obstacle.", "nothing today; the call raises", "", "IsObstacle",
    "Raises R20 today on every call: the parameter check is called with an argument it does not take; behind it, the loop would test the whole list instead of each pair",
    "IsObstacle tests one cell")
fam("SetObstacleChar SetObstacleNode", "Sets the character that draws the obstacles; anything but one character raises an error.", "nothing; the character changes", "",
    "ObstacleChar, ToString")
fam("ObstacleChar", "Returns the character that draws the obstacles.", "a text of one character, ■ by default", "", "SetObstacleChar")
fam("Obstacles", "Returns the obstacles as a list of [ column, row ] pairs, in the order they were added.", "a list of [ column, row ] pairs", "", "AddObstacle, IsObstacle")
# ---- path
fam("AddPath AddPathNodes AddPathCells", "Appends the cells of a list, in order, to the stored path.", "nothing; the path grows", "", "AddPathNode, ClearPath, ShowPath",
    note="the cells are not checked against the grid, so a cell outside it is kept and ignored when drawn; a value that is not a list raises an error")
fam("AddPathNode AddPathCell", "Appends one cell to the stored path; raises an error outside the grid.", "nothing; the path grows", "", "AddPath, ClearPath")
fam("ClearPath RemovePath", "Empties the stored path.", "nothing; the path is emptied", "", "AddPath, Path")
fam("Path", "Returns the stored path as a list of [ column, row ] pairs, in order.", "a list of [ column, row ] pairs", "", "AddPath, PathLength, ShortestPath")
fam("PathLength PathLen", "Returns how many cells the stored path holds.", "a number", "", "Path, PathComplexity")
fam("SetPathChar", "Sets the character that draws the path; anything but one character raises an error.", "nothing; the character changes", "", "PathChar, ShowPath")
fam("PathChar", "Returns the character that draws the path.", "a text of one character, ○ by default", "", "SetPathChar")
fam("SetCurrentChar", "Sets the character that draws the current position; anything but one character raises an error.", "nothing; the character changes", "", "CurrentChar, ToString")
fam("CurrentChar", "Returns the character that draws the current position.", "a text of one character, x by default", "", "SetCurrentChar")
fam("SetEmptyChar", "Sets the character that draws an empty cell; anything but one character raises an error.", "nothing; the character changes", "", "EmptyChar, ToString")
fam("EmptyChar", "Returns the character that draws an empty cell.", "a text of one character, a dot by default", "", "SetEmptyChar")
fam("SetNeighborChar SetNeighbourChar", "Sets the character that marks the neighbours; anything but one character raises an error.", "nothing; the character changes", "", "NeighborChar, ShowNeighbors")
fam("NeighborChar NeighbourChar", "Returns the character that marks the neighbours.", "a text of one character, N by default", "", "SetNeighborChar")
# ---- path finding
fam("ShortestPath", "Returns a shortest route from start to end around the obstacles, but with the end cell first instead of last.", "a list of [ column, row ] pairs; [ ] when no route exists", "",
    "ManhattanPath, Path, Regions",
    "The end cell comes first today, then the start and the cells in order, so [ 1, 1 ] to [ 3, 1 ] answers [ 3, 1 ], [ 1, 1 ], [ 2, 1 ]: ReconstructPath inserts each cell after the first item instead of at the front",
    "moves are up, down, left and right; the route is stored as the path; a start or end outside the grid, or on an obstacle, raises an error")
fam("ManhattanPath", "Returns and stores a route that walks along the row of the start, then along the column of the end.", "a list of [ column, row ] pairs", "",
    "ManhattanPathVerticalFirst, ShortestPath",
    "Raises R14 today, or R20, when an obstacle is on the way: the horizontal leg calls FindManhattanPathVerticalFirst, which exists nowhere, and the vertical leg calls ShortestPath with four arguments instead of two",
    "an end or start outside the grid raises an error; the current position is not moved")
fam("ManhattanPathVerticalFirst", "Returns and stores a route that walks along the column of the start, then along the row of the end.", "a list of [ column, row ] pairs", "",
    "ManhattanPath, ShortestPath",
    "Raises R20 today when an obstacle is on the way: it calls ShortestPath with four arguments instead of two",
    "the positions are not checked against the grid; the current position is not moved")
fam("SpiralPath", "Returns and stores a spiral that winds out from the start for up to eight steps per ring, turning right, down, left, up.", "a list of [ column, row ] pairs", "",
    "ZigZagPath, ManhattanPath", "",
    "it moves the current position to the start; it stops at the edge or when every direction is blocked; a start outside the grid raises an error")
fam("ZigZagPath", "Returns and stores a snaking route from start to end, swinging sideways after every width cells.", "a list of [ column, row ] pairs", "",
    "SpiralPath, ManhattanPath",
    "Raises R20 today when it cannot sidestep an obstacle: the fallback calls ShortestPath with four arguments instead of two",
    "it moves the current position to the start; when start and end are the same cell it answers that one pair, not a list of pairs; a position outside the grid raises an error")
# ---- drawing
fam("ShowPath", "Prints the grid with a path drawn in, and returns the picture as text.", "a text: the picture of the grid", "", "ShowNodes, ToString, SetPathChar",
    note="an empty text for the path draws the stored path, and an empty text for the character keeps the path character; the stored path and character are restored after")
fam("ShowNode ShowCell", "Prints the grid with one cell marked by the given character.", "nothing; the grid is printed", "", "ShowNodes, ShowPath",
    note="the picture is not returned, unlike ShowNodes")
fam("ShowNodes", "Prints the grid with the given cells marked by a character, and returns the picture as text.", "a text: the picture of the grid", "",
    "ShowNode, ShowPath", note="cells outside the grid are ignored; the stored path is untouched")
fam("ShowCells", "Prints the grid with the given cells marked by a character.", "nothing; the grid is printed", "", "ShowNodes", note="the picture is not returned, unlike ShowNodes")
fam("ShowRegions", "Prints the grid with each region cut by the obstacles drawn with its own number, 1, 2, 3 and so on.", "nothing; the grid is printed", "",
    "Regions, AreConnected")
fam("ShowCustomGrid", "Prints a picture given as rows of one-character items, inside the frame of the grid.", "nothing; the picture is printed", "", "ShowNodes, ToString",
    note="the rows and columns must be as many as the grid has")
# ---- helpers
fam("HeuristicCost", "Returns the Manhattan distance between two cells, the estimate path finding uses.", "a number", "", "DistanceTo, ShortestPath")
fam("WalkableNeighbors", "Returns the up to four cells next to a cell, to its left, below, right and above in that order, without the obstacles.", "a list of [ column, row ] pairs", "",
    "Neighbors, ShortestPath", note="cells outside the grid and obstacles are left out")
fam("IsInList", "TRUE if the cell is one of the [ column, row ] pairs of a list.", "TRUE or FALSE", "", "WalkableNeighbors, Fill")
fam("LowestFScore", "Returns the position, in the list of open cells, of the cell with the lowest score.", "a number: a position in the open list", "", "GetScoreAt, ShortestPath",
    note="the first one wins a tie")
fam("GetScoreAt", "Returns the score stored for a cell in a score list; 999999 when the cell has none.", "a number", "", "SetScoreAt, LowestFScore")
fam("SetScoreAt", "Stores the score of a cell in a score list, in place, adding the cell when absent, and returns the list.", "the score list, which was changed in place", "",
    "GetScoreAt", note="the list passed in is the one changed, so the result may be ignored; the cell is added when it has no score")
fam("SetCameFrom", "Records in a predecessor map which cell a cell was reached from, in place, and returns the map.", "the predecessor map, which was changed in place", "",
    "GetCameFrom, ReconstructPath", note="the map passed in is the one changed, so the result may be ignored; an existing entry is replaced")
fam("GetCameFrom", "Returns the cell a cell was reached from, in a predecessor map; an empty text when it has none.", "a pair [ column, row ], or an empty text", "",
    "SetCameFrom, ReconstructPath")
fam("ReconstructPath", "Returns the route that ends on a cell by following a predecessor map back, but with that last cell first instead of last.", "a list of [ column, row ] pairs", "",
    "SetCameFrom, ShortestPath",
    "The end cell comes first today: each earlier cell is inserted after the first item instead of at the front, which is also why ShortestPath answers its end first",
    "an empty map answers the end cell alone")
fam("PathComplexity", "Returns how many turns the stored path takes, counted as changes of direction after the first step.", "a number; 0 for a path of two cells or fewer", "",
    "PathEfficiency, PathLength")
fam("PathEfficiency", "Returns, as a percentage capped at 100, the straight Manhattan distance of the stored path over the steps it takes.", "a number from 0 to 100; 100 for a path of fewer than two cells", "",
    "PathComplexity, PathLength", note="a snaking path scores low: 4 straight cells over 12 steps give 33.33")
fam("Fill", "Returns every cell reachable from a cell by up, down, left and right steps that avoid the obstacles, in the order of the search.", "a list of [ column, row ] pairs", "",
    "Regions, AreConnected", note="the start cell is always in the answer, even when it is an obstacle, and the search then spreads from it; FloodFill gives the same list")
fam("AreConnected", "TRUE if two cells can reach each other by up, down, left and right steps that avoid the obstacles.", "TRUE or FALSE", "", "Fill, Regions",
    note="an obstacle, or a cell outside the grid, answers FALSE; a value that is not a pair of numbers raises an error")
fam("Regions", "Returns the groups of cells that the obstacles cut the grid into, each group as a list of [ column, row ] pairs.", "a list of regions, each a list of pairs", "",
    "Fill, ShowRegions, AreConnected", note="regions are found by scanning row by row from the top left; the obstacles belong to none")
fam("RandomMaze", "Replaces the obstacles by random ones, each cell having the given percentage of chance, never on the current position.", "nothing; the obstacles change", "",
    "MazeWithPath, ClearObstacles", note="a density below 0 counts as 0 and one above 90 as 90, so the grid is never full; the result differs from call to call")
fam("Maze", "Raises error R19 today instead of building a random maze.", "nothing today; the call raises", "", "RandomMaze",
    "Raises R19 today on every call: it calls RandomMaze without the density RandomMaze requires", "RandomMaze does the job")
fam("MazeWithPath", "Clears the obstacles, moves to the start, stores a route to the end, and scatters obstacles at random on the other cells.", "nothing; the obstacles and the path change", "",
    "RandomMaze, ShortestPath", "The stored route lists the end cell first, as ShortestPath does today",
    "each cell off the route has a 30 percent chance of an obstacle, so the route stays free; the current position ends on the start; the result differs from call to call")
# ---- visual
fam("Show", "Prints the grid as text: the column numbers, a frame, one line per row, with obstacles, path and the current cell drawn.", "nothing; the grid is printed", "",
    "ToString, Legend, ShowPath")
fam("ToString", "Returns the grid as text: the column numbers, a frame, one line per row, with obstacles, path and the current cell drawn.", "a text of several lines", "",
    "Show, Legend", note="a > marks the current row and a v the current column; the frame uses box-drawing characters; the current cell is drawn over the path, the path over the obstacles")
fam("Legend", "Returns one line naming the grid size and the characters used for the current cell, the obstacles and the path.", "a text on one line, as Grid: 5x4 followed by the characters, separated by vertical bars", "",
    "ToString, SetCurrentChar")
fam("ReplaceAll", "Records the value, given as :With = value, that every cell of Content will hold; any other argument raises an error.", "nothing; the fill value is recorded", "",
    "Content", note="ReplaceAllQ chains")
fam("Content", "Returns the grid as a list of rows filled with the value given to ReplaceAll; an empty list before that.", "a list of rows, each a list of values", "", "ReplaceAll, Size",
    note="rows come first: a grid of 3 columns and 2 rows gives 2 lists of 3 values")

names_all = []
lines = []
for names, brief, ret, par, see, warn, note in F:
    for nm in names:
        names_all.append(nm)
        lines.append(" | ".join([nm, brief, ret, par, see, warn, note]).rstrip(" |") if False else " | ".join([nm, brief, ret, par, see, warn, note]))
# duplicates?
import collections
dup = [k for k, v in collections.Counter(names_all).items() if v > 1]
if dup: print("DUPLICATE", dup)
half = len(lines) // 2
open(D + "w1_stzGrid_01.txt", "w", encoding="utf-8").write("\n".join(lines[:half]) + "\n")
open(D + "w1_stzGrid_02.txt", "w", encoding="utf-8").write("\n".join(lines[half:]) + "\n")
ref = json.load(open(os.environ["DOCWAVE_REF"], encoding="utf-8"))
roots = [m["name"] for c in ref["classes"] if c["name"] == "stzGrid" for m in c["methods"]]
miss = [r for r in roots if r not in names_all]
extra = [n for n in names_all if n not in roots]
print(len(lines), "lines; missing", miss, "; not a root", extra)
