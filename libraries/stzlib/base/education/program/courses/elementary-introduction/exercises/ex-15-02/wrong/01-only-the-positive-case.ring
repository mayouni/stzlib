# A guard that can only pass proves nothing.
cDoc = "# Mini" + char(10) + "```ring" + char(10) + "? 1 + 1" + char(10) + "#--> 2" + char(10) + "```" + char(10)
write("t_ex15_e.en.md", cDoc)
oCh = StzChapterQ("t_ex15_e.en.md", "en")
oCh.Run("")
? oCh.AllPromisesKept()
remove("t_ex15_e.en.md")
