load "../../stzBase.ring"
load "../_narrated.ring"

# stzFolder defects guard -- the register rows of DEFECTS.md for stzFolder and the notes of
# doc/tools/wave/data/w4_defects_files.md, each reproduced on a fixture and proved fixed.
#
# SAFETY. Every call that changes the disk runs on a fixture this file builds itself, a fresh folder
# _fgcl_fx beside the script. Before each destructive call Guard() checks that the object stands in
# the fixture and that the path it is given stays there; a refused call stops the process. Nothing
# here ever touches a relative path, a drive root or a path derived from the repository, and the
# objects never GoUp out of the fixture except where a scenario proves the position can leave home,
# and then no destructive call follows before GoHome.
#
# The first scenarios read, the later ones write. Each scenario that writes rebuilds the fixture.

cFx = _CleanPath(currentDir()) + "/_fgcl_fx"
cProcess = _CleanPath(currentDir())

Scenario("A path is read from the current position, at any depth, and judged on disk")
	Build(cFx)
	o = new stzFolder(cFx)
	Given("a fixture holding a.txt, C.TXT, sub1/d.txt, sub1/deep1/f.txt and some empty folders")
	Then("a top file is a file", o.IsFile("a.txt"), 1)
	Then("a file two levels down is a file when written as a sub-path", o.IsFile("sub1/d.txt"), 1)
	Then("the listing form with a leading slash reaches the same file", o.IsFile("/sub1/d.txt"), 1)
	Then("the absolute path reaches it too", o.IsFile(cFx + "/sub1/d.txt"), 1)
	Then("a path in a folder that does not exist is not a file (it was TRUE on the last name)", o.IsFile("/zz/a.txt"), 0)
	Then("a folder that does not exist does not hold a.txt", o.IsFile("zz/a.txt"), 0)
	Then("the case of the name does not matter", o.IsFile("A.TXT"), 1)
	Then("a mixed-case name on disk is found", o.IsFile("c.txt"), 1)
	Then("a folder is not a file", o.IsFile("sub1"), 0)
	Then("a folder two levels down is a folder", o.IsFolder("sub1/deep1"), 1)
	Then("a folder behind a missing folder is not a folder (it was TRUE on the last name)", o.IsFolder("/zz/sub1"), 0)
	Then("the trailing slash of the listing form is ignored", o.IsFolder("/sub1/"), 1)
	Then("a file is not a folder", o.IsFolder("a.txt"), 0)
	Then("Exists finds a deep file", o.Exists("sub1/deep1/f.txt"), 1)
	Then("Exists does not find the last name of an absent path", o.Exists("/nowhere/a.txt"), 0)
	Then("IsFilePath agrees with IsFile", o.IsFilePath("sub1/d.txt"), 1)
	Then("IsFolderPath agrees with IsFolder", o.IsFolderPath("sub1/deep1"), 1)
	Then("PathType says folder", o.PathType("sub1"), "folder")
	Then("PathType says file for a deep file", o.PathType("sub1/d.txt"), "file")
	Then("PathType says none for an absent path", o.PathType("/zz/sub1"), "none")
	When("IsPath, which raised R19, is asked about a file, a folder and nothing")
	Then("a file is a path", o.IsPath("a.txt"), 1)
	Then("a folder is a path", o.IsPath("sub1"), 1)
	Then("an absent name is not a path", o.IsPath("zz"), 0)
EndScenario()

Scenario("The fence reads a relative path from the position and folds .. before it judges")
	o = new stzFolder(cFx)
	Then("a relative name is inside (it read the process folder and said FALSE)", o.IsInside("sub1"), 1)
	Then("the position itself is not inside", o.IsInside(cFx), 0)
	Then("a path that climbs out with .. is outside", o.IsInside("sub1/../../x"), 0)
	Then("a path that climbs and comes back is still inside", o.IsInside("sub1/../sub2"), 1)
	Then("IsOutside is the opposite", o.IsOutside("sub1/../../x"), 1)
	bRaised = 0
	try
		o.GoTo("sub1/../../x")
	catch
		bRaised = 1
	end
	Then("GoTo refuses a path that climbs out", bRaised, 1)
	Then("and the position did not move", o.Path(), cFx)
	bRaised = 0
	try
		o.GoTo("..")
	catch
		bRaised = 1
	end
	Then("GoTo refuses .. itself (it used to accept it as text)", bRaised, 1)
EndScenario()

Scenario("The deep tests judge the disk and not the shape of the text")
	o = new stzFolder(cFx)
	Then("IsDeepFile is TRUE for a real file two levels down (it was FALSE)", o.IsDeepFile("/sub1/d.txt"), 1)
	Then("IsDeepFile is TRUE three levels down", o.IsDeepFile("/sub1/deep1/f.txt"), 1)
	Then("IsDeepFile is FALSE for a file one level down", o.IsDeepFile("/a.txt"), 0)
	Then("IsDeepFile is FALSE for a path that is not on disk (it was TRUE on the shape)", o.IsDeepFile("/zz/y.txt"), 0)
	Then("IsDeepFolder is TRUE for a real folder two levels down", o.IsDeepFolder("/sub1/deep1/"), 1)
	Then("IsDeepFolder is FALSE for a folder one level down", o.IsDeepFolder("/sub1/"), 0)
	Then("IsDeepFolder is FALSE for an absent folder (it was TRUE on the shape)", o.IsDeepFolder("/zz/yy/"), 0)
	Then("IsDeep is TRUE for a deep file", o.IsDeep("/sub1/d.txt"), 1)
	Then("IsDeepPath now returns the verdict, it returned nothing", o.IsDeepPath("/sub1/d.txt"), 1)
	Then("IsDeepPath answers FALSE too", o.IsDeepPath("/a.txt"), 0)
	Then("DeepExists finds the deep file", o.DeepExists("/sub1/deep1/f.txt"), 1)
	Then("DeepExists does not find an absent path", o.DeepExists("/nothing/zz.txt"), 0)
EndScenario()

Scenario("IsFolderEmpty reads the disk and creates nothing")
	o = new stzFolder(cFx)
	Then("an empty folder is empty", o.IsFolderEmpty("empty"), 1)
	Then("a folder that holds a folder is not empty", o.IsFolderEmpty("sub1"), 0)
	Then("a folder that is not there is not empty", o.IsFolderEmpty("brandnew"), 0)
	Then("and it was not created in the fixture (it was)", dirExists(cFx + "/brandnew"), 0)
	Then("nor in the process folder", dirExists(cProcess + "/brandnew"), 0)
	Then("a deep empty folder is read where it is", o.IsFolderEmpty("sub1/deep1/sub2"), 1)
EndScenario()

Scenario("ParentFolder and PathInfo answer the folder that holds the path")
	o = new stzFolder(cFx)
	Then("the parent of a top folder is the position (it answered the folder itself)", o.ParentFolder("sub1"), cFx)
	Then("the parent of a top file is the position", o.ParentFolder("a.txt"), cFx)
	Then("the parent of a deep file is its folder (it raised Incorrect path!)", o.ParentFolder("sub1/d.txt"), cFx + "/sub1")
	bRaised = 0
	try
		o.ParentFolder("zz/q.txt")
	catch
		bRaised = 1
	end
	Then("the parent of an absent path is an error", bRaised, 1)
	aInfo = o.PathInfo("sub1")
	Then("PathInfo gives the folder type (the facts come as key, value, key, value ...)", aInfo[8], "folder")
	Then("and a correct parent_folder (it was the folder itself)", aInfo[16], cFx)
	Then("GetDirectoryPath cuts a path to the folder that holds it", o.GetDirectoryPath("sub1/d.txt"), cFx + "/sub1")
	Then("GetFolderNameFromPath gives the last name (it cut at the first separator)", o.GetFolderNameFromPath("a/b/c"), "c")
	Then("and an empty text for the position itself", o.GetFolderNameFromPath(cFx), "")
EndScenario()

Scenario("ExistingPathsAmong and MissingPathsAmong filter by what is held here")
	o = new stzFolder(cFx)
	Then("the existing ones are returned as given (it raised R24)",
		@@(o.ExistingPathsAmong([ "a.txt", "zz", "sub1", "sub1/d.txt" ])), @@([ "a.txt", "sub1", "sub1/d.txt" ]))
	Then("the missing ones are returned as given (it raised R24)",
		@@(o.MissingPathsAmong([ "a.txt", "zz", "sub1", "yy/q" ])), @@([ "zz", "yy/q" ]))
	Then("nothing is missing from a list of present names", @@(o.MissingPathsAmong([ "a.txt" ])), "[ ]")
	Then("nothing exists among absent names", @@(o.ExistingPathsAmong([ "zz" ])), "[ ]")
EndScenario()

Scenario("A plain folder name is found and counted")
	o = new stzFolder(cFx)
	Then("CountFolder of a plain name is 1 (it was always 0)", o.CountFolder("sub1"), 1)
	Then("with slashes too", o.CountFolder("/sub1/"), 1)
	Then("ignoring case", o.CountFolder("SUB1"), 1)
	Then("an absent name is 0", o.CountFolder("zz"), 0)
	Then("a pattern still counts", o.CountFolder("sub*"), 2)
	Then("FindFolders finds a plain name (it answered [ ])", @@(o.FindFolders("sub1")), @@([ "/sub1/" ]))
	Then("and a pattern", @@(o.FindFolders("sub*")), @@([ "/sub1/", "/sub2/" ]))
	Then("FindTheseFolders finds plain names", @@(o.FindTheseFolders([ "sub2", "empty" ])), @@([ "/sub2/", "/empty/" ]))
EndScenario()

Scenario("FilesIn and FoldersIn list a child folder")
	o = new stzFolder(cFx)
	Then("FilesIn of a child with files (it raised)", @@(o.FilesIn("sub1")), @@([ "/d.txt" ]))
	Then("FoldersIn of a child with a folder (it raised)", @@(o.FoldersIn("sub1")), @@([ "/deep1/" ]))
	Then("FilesIn of an empty child is empty", @@(o.FilesIn("empty")), "[ ]")
	Then("FilesIn by absolute path", @@(o.FilesIn(cFx + "/sub1/deep1")), @@([ "/f.txt" ]))
	Then("FilesIn of the position itself answers like Files", @@(o.FilesIn(cFx)), @@(o.Files()))
	Then("FoldersIn of a deep child", @@(o.FoldersIn("sub1/deep1")), @@([ "/sub2/" ]))
	bRaised = 0
	try
		o.FilesIn("zz")
	catch
		bRaised = 1
	end
	Then("FilesIn of a folder that is not held here is an error", bRaised, 1)
EndScenario()

Scenario("Find and DeepFind give one flat list")
	o = new stzFolder(cFx)
	Then("a name that is a file", @@(o.Find("a.txt")), @@([ "/a.txt" ]))
	Then("a pattern that matches folders (it nested them in one item)", @@(o.Find("sub*")), @@([ "/sub1/", "/sub2/" ]))
	Then("a name that matches nothing", @@(o.Find("qqq")), "[ ]")
	Then("DeepFind reaches a deep file", @@(o.DeepFind("f.txt")), @@([ "/sub1/deep1/f.txt" ]))
	Then("DeepFind joins files and folders of one name",
		@@(o.DeepFind("sub2")), @@([ "/sub2/", "/sub1/deep1/sub2/" ]))
	Then("DeepFindTheseFiles lists a file once though two patterns find it",
		@@(o.DeepFindTheseFiles([ "f.txt", "f*" ])), @@([ "/sub1/deep1/f.txt" ]))
	Then("DeepFindTheseFolders lists a folder once though two patterns find it",
		@@(o.DeepFindTheseFolders([ "deep1", "DEEP1" ])), @@([ "/sub1/deep1/" ]))
EndScenario()

Scenario("The deep counts count a name below a folder")
	o = new stzFolder(cFx)
	Then("DeepCountFileIn counts f.txt below the fixture (it raised R14)", o.DeepCountFileIn("f.txt", cFx), 1)
	Then("and ignores case", o.DeepCountFileIn("F.TXT", cFx), 1)
	Then("below a sub-folder only that sub-folder is read", o.DeepCountFileIn("a.txt", cFx + "/sub1"), 0)
	Then("DeepCountTheseFiles adds the names up (it raised R24)", o.DeepCountTheseFiles([ "f.txt", "d.txt", "zz" ]), 2)
	Then("DeepCountTheseFilesIn adds them up below a folder (it raised R14)",
		o.DeepCountTheseFilesIn([ "f.txt", "d.txt", "zz" ], cFx + "/sub1"), 2)
	Then("DeepCountFolderIn counts two folders called sub2 (it raised R14)", o.DeepCountFolderIn("sub2", cFx), 2)
	Then("DeepCountTheseFoldersIn adds the names up (it raised R14)", o.DeepCountTheseFoldersIn([ "sub2", "deep1" ], cFx), 3)
EndScenario()

Scenario("The deep contains tests ignore case and OneOf means one of")
	o = new stzFolder(cFx)
	Then("a file looked up in capitals", o.DeepContainsFile("D.TXT"), 1)
	Then("a folder looked up in capitals", o.DeepContainsFolder("SUB1"), 1)
	Then("a file or folder in capitals", o.DeepContains("F.TXT"), 1)
	Then("In forms ignore case too", o.DeepContainsFileIn("F.TXT", cFx + "/sub1"), 1)
	Then("OneOfTheseFiles is TRUE when one is there (it asked for all)", o.DeepContainsOneOfTheseFiles([ "f.txt", "zz.txt" ]), 1)
	Then("OneOfTheseFiles is FALSE when none is", o.DeepContainsOneOfTheseFiles([ "zz.txt", "yy.txt" ]), 0)
	Then("OneOfTheseFolders is TRUE when one is there", o.DeepContainsOneOfTheseFolders([ "sub2", "zz" ]), 1)
	Then("OneOfTheseFolders is FALSE when none is", o.DeepContainsOneOfTheseFolders([ "zz", "yy" ]), 0)
	Then("TheseFiles still asks for all", o.DeepContainsTheseFiles([ "f.txt", "zz.txt" ]), 0)
EndScenario()

Scenario("The home distance is counted, and GoUp above home is seen")
	o = new stzFolder(cFx)
	Then("at home the relative path is a dot", o.RelativePathFromHome(), ".")
	Then("and the distance is 0", o.DistanceFromHome(), 0)
	o.GoTo("sub1")
	o.GoTo("deep1")
	Then("two levels down the relative path is sub1/deep1 (it raised R14)", o.RelativePathFromHome(), "sub1/deep1")
	Then("the distance is 2 (it raised R14)", o.DistanceFromHome(), 2)
	aNav = o.NavigationInfo()
	Then("NavigationInfo no longer raises and carries five facts", len(aNav), 5)
	Then("its relativefromhome fact", aNav[3][2], "sub1/deep1")
	Then("IsAtHome is FALSE there", o.IsAtHome(), 0)
	o.GoHome()
	Then("IsAtHome is TRUE after GoHome", o.IsAtHome(), 1)
	o.GoUp()
	Then("one GoUp above home reads as .. (no destructive call follows)", o.RelativePathFromHome(), "..")
	Then("at a distance of 1", o.DistanceFromHome(), 1)
	o.GoHome()
EndScenario()

Scenario("A path with a control character is not secure, a null byte included")
	o = new stzFolder(cFx)
	Then("an ordinary name is secure", o.IsSecurePath("ok.txt"), 1)
	Then("a null byte is not (it answered TRUE)", o.IsSecurePath("a" + char(0) + "b"), 0)
	Then("a bell is not", o.IsSecurePath("a" + char(7)), 0)
EndScenario()

Scenario("In the default mode the file methods work and the position follows the file")
	Build(cFx)
	o = new stzFolder(cFx)
	Given("a fixture and an object in batch mode OFF, the default")
	Then("batch mode is off", o.IsBatchMode(), 0)
	Guard(o, cFx + "/n1.txt")
	Then("FileCreate answers 1 (it did the work and then raised R14)", o.FileCreate("n1.txt"), 1)
	Then("the file is on disk", fexists(cFx + "/n1.txt"), 1)
	Then("FileRead reads an empty file (it raised R14 and lost the text)", o.FileRead("n1.txt"), "")
	Then("FileOverwrite answers 1 (it raised R14, then R13)", o.FileOverwrite("n1.txt", "hello"), 1)
	Then("and the text is there", o.FileRead("n1.txt"), "hello")
	Then("FileModify answers 1 (it raised R14 before changing anything)", o.FileModify("n1.txt", "hello", "world"), 1)
	Then("and changed the text", o.FileRead("n1.txt"), "world")
	Then("FileSize is the byte count (it raised R14)", o.FileSize("n1.txt"), 5)
	aInfo = o.FileInfo("n1.txt")
	Then("FileInfo carries the size (it raised R14)", aInfo[2][2], 5)
	Then("FileCopy answers 1 (it raised R14 after copying)", o.FileCopy("n1.txt", "n2.txt"), 1)
	Then("the copy is there", fexists(cFx + "/n2.txt"), 1)
	Guard(o, cFx + "/sub1/n2.txt")
	Then("FileMove into a sub-folder answers 1 (it raised R14 after moving)", o.FileMove("n2.txt", "sub1/n2.txt"), 1)
	Then("the file arrived", fexists(cFx + "/sub1/n2.txt"), 1)
	Then("and left", fexists(cFx + "/n2.txt"), 0)
	Then("the position followed the file into sub1", StzRight(o.Path(), 5), "sub1/")
	o.GoHome()
	Then("a file two levels down is read (it raised: not held directly)", o.FileRead("sub1/d.txt"), "alpha d" + nl + "zzz")
	o.GoHome()
	Then("the listing form reaches a deep file", o.FileRead("/sub1/deep1/f.txt"), "alpha f")
	o.GoHome()
	bRaised = 0
	try
		o.FileRead("sub1")
	catch
		bRaised = 1
	end
	Then("FileRead of a folder name is an error (it answered an empty text)", bRaised, 1)
	Guard(o, cFx + "/n1.txt")
	Then("FileRemove answers 1 (it raised R14 after deleting)", o.FileRemove("n1.txt"), 1)
	Then("the file is gone", fexists(cFx + "/n1.txt"), 0)
EndScenario()

Scenario("FileOverwrite, FileErase, FileBackup and the safe forms work")
	Build(cFx)
	o = new stzFolder(cFx)
	Guard(o, cFx + "/b.txt")
	Then("FileBackup answers 1 (it raised R20)", o.FileBackup("b.txt"), 1)
	Then("the backup holds the content", read(cFx + "/b.txt.bak"), "bbb")
	Then("the original is untouched", read(cFx + "/b.txt"), "bbb")
	Then("FileSafeOverwrite answers 1 (it raised R11)", o.FileSafeOverwrite("b.txt", "new"), 1)
	Then("the file holds the new text", read(cFx + "/b.txt"), "new")
	Then("the backup holds the old text", read(cFx + "/b.txt.bak"), "bbb")
	Then("FileSafeErase answers 1 (it raised R11)", o.FileSafeErase("b.txt"), 1)
	Then("the file stays and is empty", read(cFx + "/b.txt"), "")
	Then("the backup holds what the file held", read(cFx + "/b.txt.bak"), "new")
	Then("FileOverwrite refills it", o.FileOverwrite("b.txt", "again"), 1)
	Then("FileErase answers 1 (it raised R11)", o.FileErase("b.txt"), 1)
	Then("the file stays and is empty again", fexists(cFx + "/b.txt") and read(cFx + "/b.txt") = "", 1)
	Then("FileEraseQ returns the eraser object", type(o.FileEraseQ("b.txt")), "OBJECT")
	bRaised = 0
	try
		o.FileErase("zz.txt")
	catch
		bRaised = 1
	end
	Then("FileErase of an absent file is an error", bRaised, 1)
EndScenario()

Scenario("FileCreate no longer pretends when the folder is missing, and FilesCreate names what it made")
	Build(cFx)
	o = new stzFolder(cFx)
	bRaised = 0
	try
		o.FileCreate("nodir/x.txt")
	catch
		bRaised = 1
	end
	Then("FileCreate in a missing folder is an error (it answered 1 and created nothing)", bRaised, 1)
	Then("and no folder was made", dirExists(cFx + "/nodir"), 0)
	aRes = o.FilesCreate([ "p.txt", "q.txt" ])
	Then("FilesCreate reports both as created (it reported every file as failed)", @@(aRes[1][2]), @@([ "p.txt", "q.txt" ]))
	Then("and none as failed", @@(aRes[2][2]), "[ ]")
	Then("the files are on disk", fexists(cFx + "/p.txt") and fexists(cFx + "/q.txt"), 1)
	aRes = o.FilesCreate([ "p.txt", "r.txt" ])
	Then("a name already taken is reported as failed", len(aRes[2][2]), 1)
	Then("and the other is created", @@(aRes[1][2]), @@([ "r.txt" ]))
EndScenario()

Scenario("DeleteFolder works in the default mode and stays where it is")
	Build(cFx)
	o = new stzFolder(cFx)
	Guard(o, cFx + "/empty")
	Then("DeleteFolder answers 1 (it deleted and then raised R14)", o.DeleteFolder("empty"), 1)
	Then("the folder is gone", dirExists(cFx + "/empty"), 0)
	Then("the position did not move", o.Path(), cFx)
	Guard(o, cFx + "/sub1/deep1/sub2")
	Then("a deep folder is deleted by its sub-path", o.DeleteFolder("sub1/deep1/sub2"), 1)
	Then("the deep folder is gone", dirExists(cFx + "/sub1/deep1/sub2"), 0)
	Then("its parent stays", dirExists(cFx + "/sub1/deep1"), 1)
	bRaised = 0
	try
		o.DeleteFolder("zz")
	catch
		bRaised = 1
	end
	Then("a folder that is not there is an error", bRaised, 1)
	bRaised = 0
	try
		o.DeleteFolder(cFx)
	catch
		bRaised = 1
	end
	Then("the position itself cannot be deleted", bRaised, 1)
	Then("and the fixture is still there", dirExists(cFx), 1)
EndScenario()

Scenario("DeepDeleteFile and DeepDeleteFolder delete below, nothing above")
	Build(cFx)
	o = new stzFolder(cFx)
	Guard(o, cFx + "/sub1/deep1/f.txt")
	Then("DeepDeleteFile deletes a deep file (it always raised)", o.DeepDeleteFile("F.TXT"), 1)
	Then("the deep file is gone", fexists(cFx + "/sub1/deep1/f.txt"), 0)
	Then("the other files are left", fexists(cFx + "/sub1/d.txt") and fexists(cFx + "/a.txt"), 1)
	Then("a second call finds nothing and says FALSE", o.DeepDeleteFile("f.txt"), 0)
	Then("a leading slash is accepted", o.DeepDeleteFile("/s3.txt"), 1)
	Then("and deleted that file", fexists(cFx + "/sub2/s3.txt"), 0)
	Guard(o, cFx + "/sub2")
	Then("DeepDeleteFolder deletes both folders called sub2, the deep one first (it deleted nothing)", o.DeepDeleteFolder("SUB2"), 1)
	Then("the top sub2 is gone", dirExists(cFx + "/sub2"), 0)
	Then("the deep sub2 is gone", dirExists(cFx + "/sub1/deep1/sub2"), 0)
	Then("their parents stay", dirExists(cFx + "/sub1/deep1"), 1)
	Then("a name that is nowhere answers 1 and deletes nothing", o.DeepDeleteFolder("qqq"), 1)
	Guard(o, cFx + "/sub1/deep1")
	Then("FolderDeepDelete deletes a folder, not a file (it called the file version)", o.FolderDeepDelete("deep1"), 1)
	Then("deep1 is gone", dirExists(cFx + "/sub1/deep1"), 0)
	Then("sub1 stays", dirExists(cFx + "/sub1"), 1)
EndScenario()

Scenario("The deep modifiers change the files they name")
	Build(cFx)
	o = new stzFolder(cFx)
	Guard(o, cFx + "/sub1/d.txt")
	Then("DeepModifyInFile counts the file it changed (it changed nothing)", o.DeepModifyInFile("d.txt", "alpha", "OMEGA"), 1)
	Then("and the text changed", read(cFx + "/sub1/d.txt"), "OMEGA d" + nl + "zzz")
	Then("DeepModifyInFiles counts the files of the listed names", o.DeepModifyInFiles([ "s3.txt", "zz.txt" ], "beta", "BETA"), 1)
	Then("and the text changed", read(cFx + "/sub2/s3.txt"), "BETA")
	Guard(o, cFx + "/sub2/s2.txt")
	Then("DeepModifyInFolder rewrites the files of every folder of that name", o.DeepModifyInFolder("sub2", "zzz", "ZZZ"), 2)
	Then("the file that holds the text changed", read(cFx + "/sub2/s2.txt"), "ZZZ")
	Then("DeepModifyInFolders sums the folders", o.DeepModifyInFolders([ "sub2" ], "ZZZ", "zzz"), 2)
	Then("and the text is back", read(cFx + "/sub2/s2.txt"), "zzz")
	Then("DeepModifyInRoot rewrites every file of the tree (it changed nothing)", o.DeepModifyInRoot("bbb", "BBB"), 7)
	Then("a file at the top changed", read(cFx + "/b.txt"), "BBB")
	Then("and a deep one is untouched when it does not hold the text", read(cFx + "/sub1/deep1/f.txt"), "alpha f")
EndScenario()

Scenario("The searches name the right file and see the whole folder")
	Build(cFx)
	o = new stzFolder(cFx)
	Then("SearchInFolder names d.txt (it named a subfolder)", @@(o.SearchInFolder("sub1", "alpha")), @@([ [ "d.txt", [ 1 ] ] ]))
	Then("a folder none of whose files hold the text answers [ ]", @@(o.SearchInFolder("sub2", "alpha")), "[ ]")
	Then("a text the first file holds is found (it was skipped)", @@(o.SearchInFolder("sub2", "zzz")), @@([ [ "s2.txt", [ 1 ] ] ]))
	Then("SearchInFolders collects the files of every child folder",
		@@(o.SearchInFolders("beta")), @@([ [ "s3.txt", [ 1 ] ] ]))
	Then("SearchInTheseFolders collects the listed ones",
		@@(o.SearchInTheseFolders([ "sub1", "sub2" ], "zzz")), @@([ [ "d.txt", [ 2 ] ], [ "s2.txt", [ 1 ] ] ]))
	Then("DeepSearchInFolder reads the files of the folders of that name (it answered [ ])",
		@@(o.DeepSearchInFolder("sub1", "alpha")), @@([ [ cFx + "/sub1/d.txt", [ 1 ] ] ]))
	Then("DeepSearchInFolder finds a text in a deeper folder",
		@@(o.DeepSearchInFolder("deep1", "alpha")), @@([ [ cFx + "/sub1/deep1/f.txt", [ 1 ] ] ]))
	Then("DeepSearchInFolders sums the folders (it answered [ ])",
		len(o.DeepSearchInFolders([ "sub1", "deep1" ], "alpha")), 2)
EndScenario()

Scenario("The tree drawing opens folders where they are and creates nothing")
	Build(cFx)
	o = new stzFolder(cFx)
	Given("an object in the plain Expand mode and no sub1, deep1 or sub2 in the process folder")
	Then("the process folder holds no sub1", dirExists(cProcess + "/sub1"), 0)
	o.Expand()
	cTree = o.ToString()
	Then("every level opens: the file of a deep folder is drawn (only the first level opened)", StzFindFirst("f.txt", cTree) > 0, 1)
	Then("the file of a first level folder is drawn", StzFindFirst("d.txt", cTree) > 0, 1)
	Then("nothing was created in the process folder", dirExists(cProcess + "/sub1") + dirExists(cProcess + "/deep1") + dirExists(cProcess + "/sub2"), 0)
	o2 = new stzFolder(cFx)
	o2.DeepExpandAll()
	cTree = o2.ToString()
	Then("DeepExpandAll draws the same deep file", StzFindFirst("f.txt", cTree) > 0, 1)
	Then("and creates nothing", dirExists(cProcess + "/sub1") + dirExists(cProcess + "/deep1") + dirExists(cProcess + "/sub2"), 0)
	o3 = new stzFolder(cFx)
	o3.ExpandThis("sub1")
	cTree = o3.ToString()
	Then("ExpandThis opens the folder it names (it raised R24): d.txt is drawn", StzFindFirst("d.txt", cTree) > 0, 1)
	Then("and the folder below it stays closed: f.txt is not drawn", StzFindFirst("f.txt", cTree), 0)
	o4 = new stzFolder(cFx)
	cViz = o4.VizDeepFindFiles("f*")
	Then("VizDeepFindFiles draws the tree (it raised R24)", StzFindFirst("file matches", cViz) > 0, 1)
	Then("it marks the matching file", StzFindFirst("f.txt", cViz) > 0, 1)
	Then("it counts one match", StzFindFirst("1 file matches", cViz) > 0, 1)
	Then("GetFoldersContainingFileMatches names the folders on the way (it raised R24)",
		@@(o4.GetFoldersContainingFileMatches(cFx, "f*")), @@([ "sub1", "deep1" ]))
	Then("CollectFoldersWithFileMatches now returns the folders (it returned nothing)",
		len(o4.CollectFoldersWithFileMatches(cFx, "f*", [])), 1)
	aCollected = o4.CollectFoldersWithFileMatches(cFx, "*.txt", [ "x" ])
	Then("and adds to the list it was given, which stays first", aCollected[1], "x")
	Then("with the folders that hold a .txt file after it", len(aCollected), 5)
EndScenario()

Scenario("The private helpers that raised now work (reached through a subclass)")
	Build(cFx)
	op = new stzFolderProbe(cFx)
	Then("GetPhysicalOrder lists files and folders as records (it raised R24)",
		@@(op.ProbePhysicalOrder(cFx + "/sub1")),
		@@([ [ [ "name", "d.txt" ], [ "type", "file" ] ], [ [ "name", "deep1" ], [ "type", "folder" ] ] ]))
	Then("FormatStatsForFolder counts a child folder (it raised R14)",
		op.ProbeFormatStatsForFolder("sub1", "@countfiles files, @countfolders folders"), "1 files, 1 folders")
	op.Expand()
	Then("ShouldExpandFolder reads a deep folder where it is: full, so open", op.ProbeShouldExpand("sub1", cFx), 1)
	Then("an empty one stays closed", op.ProbeShouldExpand("empty", cFx), 0)
	Then("a folder that is not there is closed and not created", op.ProbeShouldExpand("ghost", cFx) + dirExists(cFx + "/ghost"), 0)
EndScenario()

Scenario("Cleaning up: the fixture is removed")
	Guard(new stzFolder(cFx), cFx + "/x")
	RemoveFolderRecursive(cFx)
	Then("the fixture is gone", dirExists(cFx), 0)
	Then("and nothing was left in the process folder",
		dirExists(cProcess + "/sub1") + dirExists(cProcess + "/deep1") + dirExists(cProcess + "/brandnew"), 0)
EndScenario()

Summary()

# --- helpers ----------------------------------------------------------------

func Guard(o, cPath)
	# Refuses, and stops the process, when the object or the path is not inside the fixture.
	cRoot = StzLower(_CleanPath(currentDir() + "/_fgcl_fx"))
	cPos = StzLower(_CleanPath(o.Path()))
	cTarget = StzLower(_CleanPath(cPath))
	bOk = (cPos = cRoot or StzLeft(cPos, StzLen(cRoot) + 1) = cRoot + "/")
	bOk = bOk and StzLeft(cTarget, StzLen(cRoot) + 1) = cRoot + "/"
	bOk = bOk and StzFindFirst("..", cTarget) = 0
	if NOT bOk
		? "GUARD REFUSED: " + cPath + " from " + o.Path()
		shutdown(9)
	ok

func Build(cFx)
	if dirExists(cFx)
		Guard(new stzFolder(cFx), cFx + "/x")
		RemoveFolderRecursive(cFx)
	ok
	StzMakeDir(cFx + "/sub1/deep1/sub2")
	StzMakeDir(cFx + "/sub2")
	StzMakeDir(cFx + "/empty")
	write(cFx + "/a.txt", "alpha one" + nl + "beta" + nl + "alpha three")
	write(cFx + "/b.txt", "bbb")
	write(cFx + "/C.TXT", "ccc")
	write(cFx + "/sub1/d.txt", "alpha d" + nl + "zzz")
	write(cFx + "/sub1/deep1/f.txt", "alpha f")
	write(cFx + "/sub2/s2.txt", "zzz")
	write(cFx + "/sub2/s3.txt", "beta")

class stzFolderProbe from stzFolder

	def ProbePhysicalOrder(c)
		return This.GetPhysicalOrder(c)

	def ProbeFormatStatsForFolder(cName, cPattern)
		return This.FormatStatsForFolder(cName, cPattern)

	def ProbeShouldExpand(cName, cParent)
		return This.ShouldExpandFolder(cName, cParent)
