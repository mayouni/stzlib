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
    QMkdir(cSbx)
    o = new stzFolder(cSbx)
    When("CreateFolders([Alpha, Beta, Gamma]) is called")
    a = o.CreateFolders([ "Alpha", "Beta", "Gamma" ])
    Then("it returns 3 folder handles", len(a), 3)
    Then("Alpha exists on disk", dirExists(cSbx + "/Alpha"), 1)
    Then("Gamma exists on disk", dirExists(cSbx + "/Gamma"), 1)
EndScenario()

Scenario("VizSearchFiles lists files matching a pattern")
    Given("a .dll file inside a sub-folder")
    write(cSbx + "/Alpha/readme.dll", "x")
    o = new stzFolder(cSbx)
    Then("the visual search output mentions the .dll match",
        StzFind(o.VizSearchFiles("*.dll"), ".dll") > 0, TRUE)
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
QMkdir(cTA + "/docs")  QMkdir(cTA + "/images/more")  QMkdir(cTA + "/images/notes")
QMkdir(cTA + "/music")  QMkdir(cTA + "/tempo")  QMkdir(cTA + "/videos")
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
    Then("the root folder name appears", StzFind(cS, "_tanar") > 0, TRUE)
    Then("the docs sub-folder appears", StzFind(cS, "docs") > 0, TRUE)
    Then("the images sub-folder appears", StzFind(cS, "images") > 0, TRUE)
EndScenario()

Scenario("Custom deep statistics (guards the StzLower 64-byte fix)")
    Given("a 74-char deep-count display pattern")
    t = new stzFolder(cTA)
    t.SetDisplayStat('@CountFiles:@DeepCountFiles files, @CountFolders:@DeepCountFolders folders')
    cX = t.ToStringXT()
    Then("the root deep stat reads 1:7 files, 5:7 folders (not truncated)",
        StzFind(cX, "1:7 files, 5:7 folders") > 0, TRUE)
EndScenario()

Scenario("VizDeepSearch marks every match")
    Given("the fixture searched for *.txt")
    t = new stzFolder(cTA)
    cV = t.VizDeepSearch("*.txt")
    Then("the root shows the target marker + total 5", StzFind(cV, "5 matches") > 0, TRUE)
    Then("howto.txt is found deep in images/notes", StzFind(cV, "howto.txt") > 0, TRUE)
EndScenario()

if dirExists(cTA) RemoveFolderRecursive(cTA) ok

Summary()

# Safety net: ensure the sandboxes are gone even if an assertion bailed early.
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
if dirExists(CurrentDir() + "/_tanar") RemoveFolderRecursive(CurrentDir() + "/_tanar") ok
