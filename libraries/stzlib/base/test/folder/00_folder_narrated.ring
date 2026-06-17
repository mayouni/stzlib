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

Summary()

# Safety net: ensure the sandbox is gone even if an assertion bailed early.
if dirExists(cSbx)
    RemoveFolderRecursive(cSbx)
ok
