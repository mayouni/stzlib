# Asks whether the document ran without ever running it.
cDoc = "# Mini" + char(10) + "```ring" + char(10) + "? 1 + 1" + char(10) + "#--> 2" + char(10) + "```" + char(10)
write("t_ex15_b.en.md", cDoc)
oCh = StzChapterQ("t_ex15_b.en.md", "en")
? oCh.HasRun()
remove("t_ex15_b.en.md")
