# made f1.ring ; run: cd libraries/stzlib/base/test/reflect && ring <this file>  (picture: font_sample.png)
load "../../../stzlib.ring"
# chdir("<an output folder>") here, after the load, so the picture lands there (the engine DLL path breaks if Ring starts elsewhere: run from base/test/reflect)
oF = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oK = new stzFont("C:/Windows/Fonts/malgun.ttf")
oFb = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oFb.AddFallback(oK)

aLines = [
  [ oF, "Hamburgefonstiv 123 AVA", 30 ],
  [ oF, "مرحبا بالعالم", 30 ],
  [ oF, "שלום עולם", 30 ],
  [ oF, "안녕하세요 (Segoe alone)", 30 ],
  [ oFb, "안녕하세요 (with malgun fallback)", 30 ]
]
o = new stzCanvas(640, 300)
o.SetBackgroundQ("#FFFFFF")
y = 50
for i = 1 to len(aLines)
	f = aLines[i][1]  t = aLines[i][2]  s = aLines[i][3]
	w = f.WidthOf(t, s)
	? "" + i + " width=" + w + " cover=" + @@(f.CoverageOf(t, s)) + " draws=" + f.DrawsEveryGlyphOf(t, s) + " rtl=" + f.IsRtlParagraph(t, s)
	o.AddRectQ(20, y - 28, w, 40).FillQ("#DDEEFF")
	o.AddTextQ(t, 20, y).SetFontQ(f, s).Color("#111111")
	y += 55
next
# caret after the 5th byte of the Latin line
aR = oF.CaretRectAt("Hamburgefonstiv 123 AVA", 30, 5, 0)
? "caret " + @@(aR)
o.AddRectQ(20 + aR[1], 50 - 28 + 0, 2, 40).FillQ("#FF0000")
o.ToPNG("font_sample.png")
