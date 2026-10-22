load "../../stzBase.ring"
# RX1 A/B probe: the education reader's page for one chapter in two scripts,
# written byte for byte so a run before and a run after the escape work compare.
oP = StzProgramQ("../../education/program")
oC = oP.CourseQ("elementary-introduction")
aCh = oC.RunChapterInQ("find-then-apply", [ "en", "ar" ])
oRd = new stzEduReader(oC)
oRd.AddChapter(aCh[1])
oRd.AddChapter(aCh[2])
cHtml = oRd.Html()
ring_write("_ab_edu_out.html", cHtml)
? "bytes: " + len(cHtml)
