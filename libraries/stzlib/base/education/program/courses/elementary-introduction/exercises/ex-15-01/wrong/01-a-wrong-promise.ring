# The cell promises 3 for 1 + 1.
cBroken = "# Mini" + char(10) + "```ring" + char(10) + "? 1 + 1" + char(10) + "#--> 3" + char(10) + "```" + char(10)
write("t_ex15_a.en.md", cBroken)
oCh = StzChapterQ("t_ex15_a.en.md", "en")
oCh.Run("")
? oCh.AllPromisesKept()
remove("t_ex15_a.en.md")
