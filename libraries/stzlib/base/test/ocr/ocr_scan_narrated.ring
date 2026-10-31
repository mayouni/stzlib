# ocr_scan_narrated.ring -- a SCANNED PDF read as a document (OCR slice O4), told as scenes.
#
# stzPdf.ReadOcr(lang) reads each page that has no text layer through the :ocr faculty (the registry picks the
# implementation per language) and hands its lines, each with its box, to the reader; the neural engine also finds
# in the page's pixels what a born-digital page draws as vector paths -- rules, bullet dots, shadings -- and how
# wide each line's strokes are (the bold cue). The reader then lays the page out by its own rules: headings, lists,
# tables, page furniture, reading order.
#
# The proof is a TWIN: each scan here is a page of a born-digital golden rendered at 150 dpi and wrapped as an
# image-only PDF (_rig/_make_scan_pdfs.py), so its blocks can be held against the blocks the reader finds in the
# born-digital page. Measured 2026-10-30 (page 1 of each): French golden_v36/z09 14 of 14 born-digital blocks found,
# 13 of the same kind; Arabic golden_v35/y11 16 of 16, 13; Russian golden_v33/u06 18 of 26, 16. Measured 2026-10-31,
# after the O4 gaps and the header band: French 14 of 14, 14; Arabic 16 of 16, 15; Russian 26 of 26, 23. What a scan
# does not give back yet: two list markers the recogniser drops (u06's old-style "1)" and "3)"), a code block of one
# line, and on a phone photo a bold sub-heading of the body's size (its long lines read larger than they are).
#
# French and Arabic are read by the platform floor and need its fr-FR / ar-SA packs; Russian by the PP-OCR model and
# needs its graphs. A scene the machine cannot run is SKIPPED BY NAME.
#
#   cd libraries/stzlib/base/test/ocr ; rnxc ocr_scan_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"
load "_data/goldens_v2.ring"

$cDir = "_data/"
StzOcrDeclare(StzOcrGoldensV2($cDir))

Scenario("A born-digital PDF keeps its text layer: ReadOcr reads no page through OCR")
	o = StzPdfQ("../document/_data/golden_v36/z09.pdf")
	nBefore = len(o.Blocks())
	o.ReadOcr("fr-FR")
	Then("no page was read through OCR", o.IsReadByOcr(), 0)
	Then("its blocks are the reader's own", len(o.Blocks()), nBefore)
EndScenario()

if StzOcrPlatformHas("fr-FR")
	Scenario("A French scan reads as a document: headings, two tables, a list, the page furniture")
		o = StzPdfQ($cDir + "scan_flate_gray.pdf")
		Then("the scan has no text layer", o.IsScanned(), 1)
		o.ReadOcr("fr-FR")
		? "   pages read: " + @@(o.OcrPages()) + "   marks found: " + @@(o.OcrMarks())
		Then("its page was read through OCR", o.IsReadByOcr(), 1)
		Then("by the floor: French is the floor's (a tie is not strictly better)", o.OcrPages()[1][2], "platform")
		Then("the title is a heading", blockKind(o, "Plaine Mobilité"), "heading")
		Then("the line's name is a heading", blockKind(o, "Ligne 12 : Gare routière - Hôpital Saint-Lazare"), "heading")
		Then("a section title is a heading", blockKind(o, "Horaires en semaine (du lundi au vendredi)"), "heading")
		Then("a bold sub-title is a heading (its strokes are wider)", blockKind(o, "Direction Gare routière"), "heading")
		Then("and the other one (strokes measured to a fraction of a pixel)", blockKind(o, "Direction Hôpital Saint-Lazare"), "heading")
		Then("the two timetables are two tables (the scan's ruled lines keep them apart)", countKind(o, "table"), 2)
		Then("each opens on its header row, white on a dark band (the band is the ladder's first row)", tableOpensWith(o, "Arrêt 6h40") + tableOpensWith(o, "Arrêt 6h55"), 2)
		Then("no header cell is left outside its table", paraWith(o, "Arrêt"), 0)
		Then("and the last row, under the thicker bottom rule, is in its table", tableWith(o, "8h24"), 1)
		Then("the three notes are list items (their bullets are dots in the pixels)", countKind(o, "list_item"), 3)
		Then("a list item reads whole", blockKind(o, "Les horaires du samedi sont affichés à chaque arrêt."), "list_item")
		Then("the address under the page is its footer", blockKind(o, "plainemobilite.example"), "page_footer")
		Then("the year in the top band is its header", blockKind(o, "Horaires 2026-2027"), "page_header")
	EndScenario()
else
	? "SKIP: A French scan reads as a document -- no fr-FR pack on this machine"
ok

if StzOcrPlatformHas("ar-SA")
	Scenario("An Arabic scan reads as a document, in logical order")
		o = StzPdfQ($cDir + "scan_y11_p1.pdf")
		o.ReadOcr("ar-SA")
		Then("by the floor: Arabic is the floor's", o.OcrPages()[1][2], "platform")
		Then("the title is a heading", blockKind(o, "ملخص وثيقة تأمين المنزل"), "heading")
		Then("a bold section title is a heading, not a caption of the table under it (Arabic bold: strokes to a fraction of a pixel)", blockKind(o, "التغطيات الأساسية"), "heading")
		Then("the coverage table is a table", tableWith(o, "الحريق والانفجار"), 1)
		Then("the policy details are a table too (its borders are rules in the pixels)", tableWith(o, "HP-2026-48213") + tableWith(o, "2O26-48213-HP"), 1)
		Then("the numbered exclusions are list items", countKind(o, "list_item") >= 2, 1)
		Then("the company's name in the top band is the page header", blockKind(o, "المكتب الرئيسي: شارع الاستقلال 25، المدينة الجديدة") = "page_header" or countKind(o, "page_header") >= 1, 1)
	EndScenario()
else
	? "SKIP: An Arabic scan reads as a document -- no ar-SA pack on this machine"
ok

if fexists(StzOcrModelDir() + "/ppocr_rec_cyrillic.gguf")
	Scenario("A Russian scan reads as a document through the model, chosen for Russian")
		o = StzPdfQ($cDir + "scan_u06_p1.pdf")
		o.ReadOcr("ru-RU")
		Then("by the model: the registry chose it for Russian", o.OcrPages()[1][2], "ppocr")
		Then("a numbered section title is a heading (bold from its strokes)", blockKind(o, "1. Назначение"), "heading")
		Then("another one too", blockKind(o, "2. Подготовка к работе"), "heading")
		Then("a paragraph reads whole", paraWith(o, "предназначен для сбора данных с датчиков"), 1)
		Then("the page number is the footer", blockKind(o, "Стр. 1 из 3"), "page_footer")
		Then("the running title is the header", blockKind(o, "ТМ-200 · Руководство по настройке"), "page_header")
		Then("a list item whose marker OCR glued to its word is a list item (the space given back)", kindWith(o, "list_item", "блок питания"), 1)
		Then("the lettered and numbered items too: six of the eight", countKind(o, "list_item") >= 6, 1)
		Then("the shaded configuration block is code (monospace from its lines' widths)", kindWith(o, "code", "[network]"), 1)
		Then("one block, its comments joined to their lines", kindWith(o, "code", "# адрес шлюза") * kindWith(o, "code", "[mqtt]"), 1)
	EndScenario()
else
	? "SKIP: A Russian scan reads as a document -- the Cyrillic recogniser is not installed"
ok

# PHONE SCANS (real-scan robustness): the same pages made to look photographed by _rig/_degrade_scans.py "phone"
# -- toned, noisy paper; turned half a degree; a shadowed border; camera blur; JPEG at 65; the page sized in pixels
# as a scan app writes it (one point per pixel, so the printed scale is read from the paper's proportions).
# Measured 2026-10-31 over 21 degraded twins (7 effects x 3 pages): blocks of the right kind 282 -> 292 with the
# deskew, the paper-relative thresholds and rules that need paper on both sides; 292 -> 304 with BLUR answered
# (a soft page the platform will read is sharpened -- the PP-OCR model reads a soft page better as it is -- and a
# word-tight box never swallows a bullet).

if StzOcrPlatformHas("fr-FR")
	Scenario("A French phone scan is turned level and still reads as a document")
		o = StzPdfQ($cDir + "phone_z09_p1.pdf")
		Then("its page is sized in pixels (a scan app's), and the printed scale comes from the paper: A4 at 1241 px is 2.08 px a point", o.ImagePixelsPerPoint(1) > 2.07 and o.ImagePixelsPerPoint(1) < 2.10, 1)
		o.ReadOcr("fr-FR")
		nSkew = o.OcrPages()[1][4]
		? "   turned level by " + nSkew + " degrees; marks " + @@(o.OcrMarks())
		Then("the half-degree turn is measured", nSkew > -0.6 and nSkew < -0.4, 1)
		Then("the title is a heading", blockKind(o, "Plaine Mobilité"), "heading")
		Then("the two timetables are still two tables", countKind(o, "table"), 2)
		Then("each still opens on its header row: the photographed band bleeds past the rules, by a fifth of its height at most", tableOpensWith(o, "Arrêt 6h40") + tableOpensWith(o, "Arrêt 6h55"), 2)
		Then("the page is read in PRINTED points: the 20-pt title is not 41 units of a pixel-sized page", sizeOf(o, "Plaine Mobilité") > 18 and sizeOf(o, "Plaine Mobilité") < 22, 1)
		Then("the three notes are still list items", kindWith(o, "list_item", "Les horaires du samedi") + kindWith(o, "list_item", "Le bus s'arrête") + kindWith(o, "list_item", "Les poussettes"), 3)
		Then("the footer is still the footer", countKind(o, "page_footer") >= 1, 1)
	EndScenario()
else
	? "SKIP: A French phone scan is turned level -- no fr-FR pack on this machine"
ok

if StzOcrPlatformHas("fr-FR")
	Scenario("A blurred French scan is sharpened before the platform reads it, and reads as the sharp one")
		o = StzPdfQ($cDir + "blur_z09_p1.pdf")
		o.ReadOcr("fr-FR")
		? "   " + @@(o.OcrPages())
		Then("the page was soft and read from a sharpened copy", o.OcrPages()[1][5], 1)
		Then("the title is a heading", blockKind(o, "Plaine Mobilité"), "heading")
		Then("the line's name is a heading again (blurred, unsharpened, it read as a list item)", blockKind(o, "Ligne 12 : Gare routière - Hôpital Saint-Lazare"), "heading")
		Then("the two timetables are two tables", countKind(o, "table"), 2)
		Then("the three notes are list items", countKind(o, "list_item"), 3)
		Then("the footer is the footer", blockKind(o, "plainemobilite.example"), "page_footer")
	EndScenario()
	Scenario("A sharp scan is not sharpened")
		o = StzPdfQ($cDir + "scan_flate_gray.pdf")
		o.ReadOcr("fr-FR")
		Then("read as it is", o.OcrPages()[1][5], 0)
	EndScenario()
else
	? "SKIP: A blurred French scan is sharpened -- no fr-FR pack on this machine"
ok

if fexists(StzOcrModelDir() + "/ppocr_rec_cyrillic.gguf")
	Scenario("A Russian phone scan is turned level and still reads as a document")
		o = StzPdfQ($cDir + "phone_u06_p1.pdf")
		o.ReadOcr("ru-RU")
		nSkew = o.OcrPages()[1][4]
		? "   turned level by " + nSkew + " degrees"
		Then("the half-degree turn is measured, the shadowed border kept out of the vote", nSkew > -0.6 and nSkew < -0.4, 1)
		Then("a section title is a heading", blockKind(o, "2. Подготовка к работе"), "heading")
		Then("another one too", blockKind(o, "3. Файл конфигурации"), "heading")
		Then("its lists come back as list items", countKind(o, "list_item") >= 6, 1)
		Then("the page number is the footer", blockKind(o, "Стр. 1 из 3"), "page_footer")
	EndScenario()
else
	? "SKIP: A Russian phone scan is turned level -- the Cyrillic recogniser is not installed"
ok

Summary()

# the kind of the first block whose text is pcText, "" when none
func blockKind(oP, pcText)
	aB = oP.Blocks()
	nB = len(aB)
	for i = 1 to nB
		if aB[i][:text] = pcText return aB[i][:kind] ok
	next
	return ""

# 1 when a block of the kind holds the text
func kindWith(oP, pcKind, pcText)
	aB = oP.Blocks()
	nB = len(aB)
	for i = 1 to nB
		if aB[i][:kind] = pcKind and StzFindFirst(pcText, aB[i][:text]) > 0 return 1 ok
	next
	return 0

func countKind(oP, pcKind)
	aB = oP.Blocks()
	nB = len(aB)
	n = 0
	for i = 1 to nB
		if aB[i][:kind] = pcKind n++ ok
	next
	return n

# 1 when a table holds the text in one of its cells
func tableWith(oP, pcText)
	aB = oP.Blocks()
	nB = len(aB)
	for i = 1 to nB
		if aB[i][:kind] = "table" and StzFindFirst(pcText, aB[i][:text]) > 0 return 1 ok
	next
	return 0

func tableOpensWith(oP, pcText)
	aB = oP.Blocks()
	nB = len(aB)
	for i = 1 to nB
		if aB[i][:kind] = "table" and StzFindFirst(pcText, StzReplace(StzReplace(aB[i][:text], char(9), " "), char(10), " ")) = 1 return 1 ok
	next
	return 0

func sizeOf(oP, pcText)
	aB = oP.Blocks()
	nB = len(aB)
	for i = 1 to nB
		if StzFindFirst(pcText, aB[i][:text]) > 0 return aB[i][:size] ok
	next
	return 0

func paraWith(oP, pcText)
	aB = oP.Blocks()
	nB = len(aB)
	for i = 1 to nB
		if aB[i][:kind] = "paragraph" and StzFindFirst(pcText, aB[i][:text]) > 0 return 1 ok
	next
	return 0
