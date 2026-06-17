load "../../stzBase.ring"
load "../_narrated.ring"

# Gold-standard narrated suite for stzFile -- exercises the seven intent
# classes against a LOCAL sandbox (portable, non-destructive). Guards the
# fixes made this pass:
#   - stzFileInfo.SizeInBytes (was inheriting the object's repr size = 553)
#   - engine file mtime (stz_file_mtime) backing LastModified (was "Unsupported")
#   - FileAppend append-or-create (was raising on a missing file) + Write()
#     (StzFileAppendQ called a non-existent Append())

cSbx = CurrentDir() + "/_fnar"
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
StzMakeDir(cSbx)

Scenario("FileInfo reports file metadata (SizeInBytes + real mtime)")
    Given("a 14-byte sandbox file")
    write(cSbx + "/notes.txt", "hello softanza")
    oInfo = FileInfoQ(cSbx + "/notes.txt")
    Then("the file exists", oInfo.Exists(), 1)
    Then("it is writable", oInfo.IsWritable(), 1)
    Then("SizeInBytes is the byte length (not the object repr)", oInfo.SizeInBytes(), 14)
    Then("it is not executable", oInfo.IsExecutable(), 0)
    Then("LastModificationTime is a real positive epoch", oInfo.LastModificationTime() > 0, TRUE)
    Then("LastModified renders a non-empty date-time", len(oInfo.LastModified()) > 0, TRUE)
EndScenario()

Scenario("FileRead queries content without writing")
    Given("a 4-line sandbox file")
    write(cSbx + "/data.txt", "a" + nl + "b" + nl + "c" + nl + "d")
    oReader = FileReadQ(cSbx + "/data.txt")
    Then("it counts 4 lines", oReader.NumberOfLines(), 4)
    Then("the byte size is 7 (4 chars + 3 newlines)", oReader.Size(), 7)
    Then("the first line is a", oReader.FirstLine(), "a")
    Then("the last line is d", oReader.LastLine(), "d")
    Then("it finds existing text", oReader.ContainsText("c"), 1)
    oReader.Close()
EndScenario()

Scenario("FileCreate writes a new file with read-as-you-go")
    Given("a fresh creator")
    oCreator = FileCreateQ(cSbx + "/new.txt")
    oCreator.WriteLine("alpha")
    oCreator.WriteLine("beta")
    Then("the created content is readable mid-write", oCreator.ContainsText("alpha"), 1)
    Then("both lines are present", StzFind(oCreator.Content(), "beta") > 0, TRUE)
    oCreator.Close()
EndScenario()

Scenario("FileAppend creates-then-appends a missing log (append-or-create)")
    Given("a log file that does NOT exist yet")
    oLog = FileAppend(cSbx + "/app.log")
    Then("a brand-new append target reports empty", oLog.IsEmpty(), 1)
    When("lines are appended")
    oLog.WriteLine("first")
    oLog.WriteLine("second")
    Then("the appended content is present", StzFind(oLog.Content(), "first") > 0, TRUE)
    Then("it is no longer empty", oLog.IsEmpty(), 0)
    oLog.Close()
EndScenario()

Scenario("FileOverwrite reads the original before replacing")
    Given("an existing 1-line file")
    write(cSbx + "/ow.txt", "old line one")
    oWriter = FileOverwriteQ(cSbx + "/ow.txt")
    Then("the original had 1 line", len(oWriter.OriginalLines()), 1)
    When("new content is written")
    oWriter.WriteLine("Status: Completed")
    Then("the new content replaced the old", StzFind(oWriter.Content(), "Completed") > 0, TRUE)
    Then("the old content is gone", StzFind(oWriter.Content(), "old line one"), 0)
    oWriter.Close()
EndScenario()

Scenario("FileUpdate makes targeted edits")
    Given("a 4-line settings file")
    write(cSbx + "/cfg.txt", "Host=localhost" + nl + "Port=5432" + nl + "Debug=true" + nl + "Obsolete=x")
    oUpdater = FileUpdateQ(cSbx + "/cfg.txt")
    When("a line is replaced, one inserted, one removed")
    oUpdater.ReplaceLineContaining("Host=", "Host=newserver")
    oUpdater.InsertLineAtEnd("New=Default")
    oUpdater.RemoveLinesContaining("Obsolete")
    Then("the replacement took effect", StzFind(oUpdater.Content(), "Host=newserver") > 0, TRUE)
    Then("the inserted line is present", StzFind(oUpdater.Content(), "New=Default") > 0, TRUE)
    Then("the removed line is gone", StzFind(oUpdater.Content(), "Obsolete"), 0)
    oUpdater.Close()
EndScenario()

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

Summary()

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
