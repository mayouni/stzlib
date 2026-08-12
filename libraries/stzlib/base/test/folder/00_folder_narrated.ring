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
        StzFindFirst(".dll", o.VizSearchFiles("*.dll")) > 0, TRUE)
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
    Then("the root folder name appears", StzFindFirst("_tanar", cS) > 0, TRUE)
    Then("the docs sub-folder appears", StzFindFirst("docs", cS) > 0, TRUE)
    Then("the images sub-folder appears", StzFindFirst("images", cS) > 0, TRUE)
EndScenario()

Scenario("Custom deep statistics (guards the StzLower 64-byte fix)")
    Given("a 74-char deep-count display pattern")
    t = new stzFolder(cTA)
    t.SetDisplayStat('@CountFiles:@DeepCountFiles files, @CountFolders:@DeepCountFolders folders')
    cX = t.ToStringXT()
    Then("the root deep stat reads 1:7 files, 5:7 folders (not truncated)",
        StzFindFirst("1:7 files, 5:7 folders", cX) > 0, TRUE)
EndScenario()

# Regression: IsStatPattern() called StzFindFirst(pattern, keyword) -- needle
# and haystack swapped. It asked whether the whole display pattern occurs
# inside a short keyword, which is 0 for anything real, so SetDisplayStat()
# refused every pattern with "Incorrect start pattern!" and killed the
# scenario above outright.
#
# It survived because the DEFAULT pattern is "@count", which IS a keyword --
# a string is found in itself whichever way round you ask. Only a pattern
# LONGER than a keyword exposed it, which is every pattern worth setting.

Scenario("A display pattern is recognised by the keyword INSIDE it")
    Given("a fresh folder view")
    p = new stzFolder(cTA)
    Then("a keyword on its own is a stat pattern", p.IsStatPattern("@count"), TRUE)
    Then("a keyword embedded in prose is too", p.IsStatPattern("holding @deepcountfiles files in total"), TRUE)
    Then("...and case does not matter", p.IsStatPattern("Holding @DeepCountFiles Files"), TRUE)
    # The negative sibling: without a keyword it must still be REFUSED, or
    # this would pass against an IsStatPattern that simply answered TRUE.
    Then("prose with NO keyword is refused", p.IsStatPattern("just some words"), FALSE)
    Then("an @-token that is not a keyword is refused", p.IsStatPattern("@total @size"), FALSE)
    # "@counted" DOES contain "@count", so it is accepted -- the pattern
    # language is substring substitution, and that is the contract, not a bug.
    Then("...but a keyword with a suffix still matches", p.IsStatPattern("@counted"), TRUE)
    Then("the empty pattern is refused", p.IsStatPattern(""), FALSE)
EndScenario()

# FindTheseFiles/FindTheseFolders gather several searches into one deduplicated
# answer. Both were broken, and the two defects were stacked:
#
#   _nLenR_ = len(acFileResult)     <- a name that exists NOWHERE
#   if find(_acFound_, ...)         <- 2 args to this class's own Find(cPattern)
#
# The typo raised R24 on the first result, so FindTheseFiles never worked. It
# also HID the line beneath it: with the loop bound coming from a variable that
# does not exist, the body was unreachable. FindTheseFolders had the bound
# right, so its find() was live -- an R20 waiting for the first folder to match.
#
# `find` is Ring's (list, item); StzFindFirst is NEEDLE-FIRST. The order changes
# with the call, which is the kind of detail a silent fix gets wrong.

Scenario("Several searches gathered into one answer, without duplicates")
    Given("the folder holding this suite")
    f = new stzFolder(CurrentDir())
    nAll = len(f.FindFiles("*.ring"))
    Then("there are .ring files to find", nAll > 0, TRUE)

    When("FindTheseFiles is asked for that same pattern")
    Then("it returns them all", len(f.FindTheseFiles([ "*.ring" ])), nAll)

    # The point of the find() call is DEDUPLICATION. Asking twice must not
    # double the answer -- and this is the assertion that would have caught
    # the shadowed find() had the loop above it ever run.
    When("the SAME pattern is asked for twice")
    Then("the answer is not doubled", len(f.FindTheseFiles([ "*.ring", "*.ring" ])), nAll)

    Given("the parent directory, which holds many topic folders")
    g = new stzFolder(CurrentDir() + "/..")
    nF = len(g.FindTheseFolders([ "f*" ]))
    Then("FindTheseFolders finds some", nF > 0, TRUE)
    Then("...and does not double them either", len(g.FindTheseFolders([ "f*", "f*" ])), nF)

    # The negative sibling: a pattern matching nothing must answer empty, not
    # raise and not fall back to everything.
    Then("a pattern matching nothing is empty", len(f.FindTheseFiles([ "*.nosuchext" ])), 0)
EndScenario()

Scenario("VizDeepSearch marks every match")
    Given("the fixture searched for *.txt")
    t = new stzFolder(cTA)
    cV = t.VizDeepSearch("*.txt")
    Then("the root shows the target marker + total 5", StzFindFirst("5 matches", cV) > 0, TRUE)
    Then("howto.txt is found deep in images/notes", StzFindFirst("howto.txt", cV) > 0, TRUE)
EndScenario()

Scenario("Finders match by name list, surface glob, and deep recursion")
    Given("the fixture")
    t = new stzFolder(cTA)
    Then("FindFiles([test.txt]) matches the root file",
        StzFindFirst("test.txt", @@(t.FindFiles([ "test.txt" ]))) > 0, TRUE)
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
        StzFindFirst("views", @@(t.DeepFindFolders("*view*"))) > 0, TRUE)
    Then("DeepFindFolders(notes) finds the nested notes folder",
        StzFindFirst("notes", @@(t.DeepFindFolders("notes"))) > 0, TRUE)
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
    Then("the edit took effect", StzFindFirst("ONE", oUp.Content()) > 0, TRUE)
    oUp.Close()
    g = 0  oAp = 0  oUp = 0
    if dirExists(cFq) RemoveFolderRecursive(cFq) ok
EndScenario()

if dirExists(cTA) RemoveFolderRecursive(cTA) ok

Summary()

# Safety net: ensure the sandboxes are gone even if an assertion bailed early.
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
if dirExists(CurrentDir() + "/_tanar") RemoveFolderRecursive(CurrentDir() + "/_tanar") ok
