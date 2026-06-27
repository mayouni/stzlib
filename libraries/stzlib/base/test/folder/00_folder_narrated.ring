load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzFolder -- exercises the filesystem
# methods (CreateFolders / VizSearchFiles / DeepRemoveAll) against a LOCAL
# SANDBOX under the test directory, so it is portable and non-destructive
# (unlike the classic folder samples, which hardcode C:\TestArea, C:\Windows
# and d:/ring124 and depend on machine-specific fixtures).
#
# These three methods were added this session; existence is checked with
# Ring's dirExists() builtin (stzFolder.Exists() mangles paths -- see the
# NormalizeFilePath lowercase/strip note).

cSbx = CurrentDir() + "/_fnar"
if dirExists(cSbx)
    RemoveFolderRecursive(cSbx)
ok

Scenario("CreateFolders creates several sub-folders at once")
    Given("a fresh sandbox folder")
    StzMakeDir(cSbx)
    o = new stzFolder(cSbx)
    When("CreateFolders([Alpha, Beta, Gamma]) is called")
    a = o.CreateFoldersQ([ "Alpha", "Beta", "Gamma" ])
    Then("it returns 3 folder handles", len(a), 3)
    Then("Alpha exists on disk", dirExists(cSbx + "/Alpha"), 1)
    Then("Gamma exists on disk", dirExists(cSbx + "/Gamma"), 1)
EndScenario()

Scenario("VizSearchFiles lists files matching a pattern")
    Given("a .dll file inside a sub-folder")
    write(cSbx + "/Alpha/readme.dll", "x")
    o = new stzFolder(cSbx)
    Then("the visual search output mentions the .dll match",
        StzFindFirst(o.VizSearchFiles("*.dll"), ".dll") > 0, TRUE)
EndScenario()

Scenario("DeepRemoveAll removes the folder and its whole subtree")
    Given("the populated sandbox")
    o = new stzFolder(cSbx)
    Then("removal reports success", o.DeepRemoveAll(), TRUE)
    Then("the folder no longer exists", dirExists(cSbx), 0)
EndScenario()

# --- Visual exploration (matches stzfolder-visual-exploration-and-search.md) ---
# Builds the documented "testarea" fixture and asserts the visual surface:
# Show/ShowXT icons + counts, deep stats, expansion, and viz search markers.
# Guards the engine StzLower 64-byte truncation fix (the deep-stat pattern is
# 74 chars) and the case-preserving navigation fixes.

cTA = CurrentDir() + "/_tanar"
if dirExists(cTA) RemoveFolderRecursive(cTA) ok
StzMakeDir(cTA + "/docs")  StzMakeDir(cTA + "/images/more")  StzMakeDir(cTA + "/images/notes")
StzMakeDir(cTA + "/music")  StzMakeDir(cTA + "/tempo")  StzMakeDir(cTA + "/videos")
write(cTA + "/test.txt", "program")
write(cTA + "/images/image1.png", "x")  write(cTA + "/images/image2.png", "x")
write(cTA + "/images/notes/howto.txt", "x")  write(cTA + "/images/notes/sources.txt", "x")
write(cTA + "/tempo/temp1.txt", "x")  write(cTA + "/tempo/temp2.txt", "x")

Scenario("Surface vs deep counts")
    Given("the documented testarea fixture")
    t = new stzFolder(cTA)
    Then("CountFiles is 1 (root)", t.CountFiles(), 1)
    Then("CountFolders is 5 (root)", t.CountFolders(), 5)
    Then("DeepCountFiles is 7", t.DeepCountFiles(), 7)
    Then("DeepCountFolders is 7", t.DeepCountFolders(), 7)
EndScenario()

Scenario("Show renders the tree (ToString returns it; Show prints it)")
    Given("the fixture")
    t = new stzFolder(cTA)
    cS = t.ToString()
    Then("the root folder name appears", StzFindFirst(cS, "_tanar") > 0, TRUE)
    Then("the docs sub-folder appears", StzFindFirst(cS, "docs") > 0, TRUE)
    Then("the images sub-folder appears", StzFindFirst(cS, "images") > 0, TRUE)
EndScenario()

Scenario("Custom deep statistics (guards the StzLower 64-byte fix)")
    Given("a 74-char deep-count display pattern")
    t = new stzFolder(cTA)
    t.SetDisplayStat('@CountFiles:@DeepCountFiles files, @CountFolders:@DeepCountFolders folders')
    cX = t.ToStringXT()
    Then("the root deep stat reads 1:7 files, 5:7 folders (not truncated)",
        StzFindFirst(cX, "1:7 files, 5:7 folders") > 0, TRUE)
EndScenario()

Scenario("VizDeepSearch marks every match")
    Given("the fixture searched for *.txt")
    t = new stzFolder(cTA)
    cV = t.VizDeepSearch("*.txt")
    Then("the root shows the target marker + total 5", StzFindFirst(cV, "5 matches") > 0, TRUE)
    Then("howto.txt is found deep in images/notes", StzFindFirst(cV, "howto.txt") > 0, TRUE)
EndScenario()

Scenario("Finders match by name list, surface glob, and deep recursion")
    Given("the fixture")
    t = new stzFolder(cTA)
    Then("FindFiles([test.txt]) matches the root file",
        StzFindFirst(@@(t.FindFiles([ "test.txt" ])), "test.txt") > 0, TRUE)
    Then("surface FindFiles(*.txt) finds only the root file", len(t.FindFiles("*.txt")), 1)
    Then("DeepFindFiles(*.txt) finds all 5 deep", len(t.DeepFindFiles("*.txt")), 5)
    Then("DeepFindFiles(howto.txt) finds the nested file", len(t.DeepFindFiles("howto.txt")), 1)
EndScenario()

Scenario("DeepFindFolders matches folders anywhere in the subtree")
    Given("the fixture with a deeper src/views folder")
    t = new stzFolder(cTA)
    StzMakeDir(cTA + "/src/views")
    t.Refresh()
    Then("DeepFindFolders(*view*) finds the nested views folder",
        StzFindFirst(@@(t.DeepFindFolders("*view*")), "views") > 0, TRUE)
    Then("DeepFindFolders(notes) finds the nested notes folder",
        StzFindFirst(@@(t.DeepFindFolders("notes")), "notes") > 0, TRUE)
EndScenario()

Scenario("File ops: create, size, copy, delete, exists")
    Given("a fresh file sandbox")
    cFx = CurrentDir() + "/_tfops"
    if dirExists(cFx) RemoveFolderRecursive(cFx) ok
    StzMakeDir(cFx)
    write(cFx + "/seed.txt", "hello world")  # 11 bytes
    f = new stzFolder(cFx)
    f.SetBatchMode(TRUE)
    When("a file is created")
    f.CreateFile("new.txt")
    f.Refresh()
    Then("the created file exists", f.FileExists("new.txt"), 1)
    Then("FileSize reports the byte length", f.FileSize("seed.txt"), 11)
    When("the seed file is copied")
    f.CopyFile("seed.txt", "copy.txt")
    f.Refresh()
    Then("the copy exists", f.FileExists("copy.txt"), 1)
    When("the created file is deleted")
    f.DeleteFile("new.txt")
    f.Refresh()
    Then("the deleted file is gone", f.FileExists("new.txt"), 0)
    f = 0
    if dirExists(cFx) RemoveFolderRecursive(cFx) ok
EndScenario()

Scenario("Folder file-op intents follow the Q convention (object forms)")
    Given("a fresh file sandbox")
    cFq = CurrentDir() + "/_tfq"
    if dirExists(cFq) RemoveFolderRecursive(cFq) ok
    StzMakeDir(cFq)
    write(cFq + "/seed.txt", "one" + nl + "two")
    g = new stzFolder(cFq)
    g.SetBatchMode(TRUE)
    Then("FileReadQ returns a reader object", g.FileReadQ("seed.txt").NumberOfLines(), 2)
    When("FileAppend (object-only) appends to a new log")
    oAp = g.FileAppend("app.log")
    oAp.WriteLine("entry")
    Then("the appended entry is present", oAp.ContainsText("entry"), 1)
    oAp.Close()
    When("FileUpdate (object) edits a file")
    oUp = g.FileUpdate("seed.txt")
    oUp.ReplaceLineContaining("one", "ONE")
    Then("the edit took effect", StzFindFirst(oUp.Content(), "ONE") > 0, TRUE)
    oUp.Close()
    g = 0  oAp = 0  oUp = 0
    if dirExists(cFq) RemoveFolderRecursive(cFq) ok
EndScenario()

if dirExists(cTA) RemoveFolderRecursive(cTA) ok

Summary()

# Safety net: ensure the sandboxes are gone even if an assertion bailed early.
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
if dirExists(CurrentDir() + "/_tanar") RemoveFolderRecursive(CurrentDir() + "/_tanar") ok
