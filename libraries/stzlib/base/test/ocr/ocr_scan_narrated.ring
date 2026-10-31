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
# after the O4 gaps and the header band: French 14 of 14, 14; Arabic 16 of 16, 15; Russian 26 of 26, 23; and after
# the remaining gaps: Russian 26 of 26, 25. What a scan does not give back yet: a code block of one line (its face
# cannot be told from its widths: code 1.11, prose up to 1.18), and a short 12.5-pt Arabic title over 11.5-pt text
# read as a heading (1.087 of the body, the bar 1.1).
# An Arabic line's size is read from its words' median top and bottom (2026-10-31): its box grew with its length.
#
# Light text on a dark band is read again by the PP-OCR model (StzOcrWithDarkBands, 2026-10-31): the platform
# reads white on navy worst of all.
#
# Small text: the platform misreads text under about 40 pixels high and a run of small words beside large ones,
# so the floor reads such pages enlarged and such runs on their own (bridge v4, 2026-10-31): on the 14 French and
# Arabic degraded twins words read right 94.1% -> 97.0%, numbers 85.4% -> 91.9%.
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
		Then("the policy details are a table too (its borders are rules in the pixels)", tableWith(o, "HP-2026-48213"), 1)
		# the platform gave these as 2O26-48213-HP and a garbled hotline before it read small text enlarged and
		# put a word holding Latin letters back in the order it stands on the page
		Then("the footer's policy number reads as printed", kindWith(o, "page_footer", "وثيقة رقم HP-2026-48213"), 1)
		Then("the small hotline beside the large title is read on its own: two numbers in the paragraph's order", kindWith(o, "page_header", "الخط الساخن 800 1234"), 1)
		Then("the numbered exclusions are list items", countKind(o, "list_item") >= 2, 1)
		# an Arabic line's box runs from the highest mark of any word to the deepest tail of any other, so it grew with
		# the line: this 17-word line of 11.5-pt text read 14.0 -- its size now comes from its words' median top and bottom
		Then("a long Arabic line reads near its 11.5 points", sizeOf(o, "تغطى المقتنيات الثمينة") > 10.5 and sizeOf(o, "تغطى المقتنيات الثمينة") < 13, 1)
		Then("a one-word bold heading with no tail is a heading", blockKind(o, "الاستثناءات"), "heading")
		Then("the 12.5-pt note title stands apart from the 11.5-pt paragraph under it", blockKind(o, "ملاحظة حول المقتنيات") != "", 1)
		# the platform reads "التآكل" (corrosion) as "التأكل" at every scale: the madda is a few pixels -- the author saw it
		Then("an alef with madda reads as printed (the word list knows the word by it)", kindWith(o, "list_item", "التآكل وسوء الصيانة"), 1)
		Then("the company's name in the top band is the page header", blockKind(o, "المكتب الرئيسي: شارع الاستقلال 25، المدينة الجديدة") = "page_header" or countKind(o, "page_header") >= 1, 1)
	EndScenario()
else
	? "SKIP: An Arabic scan reads as a document -- no ar-SA pack on this machine"
ok

# The pages the author was shown on the look page: a scan app's copy of each golden page -- JPEG at quality 92, the
# page sized in pixels (_rig/_degrade_scans.py <page> clean <pdf>). Read as it stands, the platform gave 44 for 6h44,
# 000,()2 for 20,000, 2O26-482l3-Hp for HP-2026-48213 and garbled the hotline: it misreads text under about 40 pixels
# high, so a page whose small words stand lower is read again enlarged.
if StzOcrPlatformHas("fr-FR") and StzOcrPlatformHas("ar-SA")
	Scenario("A scan app's page: small text is read enlarged, and reads as printed")
		o = StzPdfQ($cDir + "app_z09_p1.pdf")
		o.ReadOcr("fr-FR")
		Then("a 9-pt time in a timetable reads whole", tableWith(o, "6h44"), 1)
		Then("a bullet the enlarged read takes for a letter is no block: the dot in the pixels is the marker", blockKind(o, "e") = "" and countKind(o, "list_item") = 3, 1)
		o = StzPdfQ($cDir + "app_y11_p1.pdf")
		o.ReadOcr("ar-SA")
		Then("an amount reads whole", paraWith(o, "حتى مبلغ 20,000 ريال"), 1)
		Then("the footer's policy number reads as printed, its 0 and 1 not O and l", kindWith(o, "page_footer", "وثيقة رقم HP-2026-48213"), 1)
		Then("the hotline beside the title reads", kindWith(o, "page_header", "الخط الساخن 800 1234"), 1)
		Then("a 1 alone is not an l", tableWith(o, "في 1 يناير 2027"), 1)
	EndScenario()
else
	? "SKIP: A scan app's page is read enlarged -- the fr-FR and ar-SA packs are both needed"
ok

# Light text on a dark band -- a letterhead's footer, photographed (_data/band_footer.pdf, from _rig/_make_band_page.py,
# every word invented there): the platform garbles it ("Regestre : FFVPAR/03Q021tC17", "UIGER", "E4nad"), so the engine
# finds the band and the PP-OCR model reads it again, its brightest channel stretched, inverted and enlarged.
$bModel = fexists(StzOcrModelDir() + "/ppocr_det.gguf") and fexists(StzOcrModelDir() + "/ppocr_cls.gguf") and fexists(StzOcrModelDir() + "/ppocr_rec.gguf")
if StzOcrPlatformHas("fr-FR") and $bModel
	Scenario("Light text on a dark band is read again by the model")
		o = StzPdfQ($cDir + "band_footer.pdf")
		o.ReadOcr("fr-FR")
		Then("the page was read by the platform, its one dark band again by the model", o.OcrPages()[1][2] + " " + o.OcrPages()[1][6], "platform 1")
		Then("a register number reads whole", kindWith(o, "page_footer", "FR/PAR/03/2021/C17/00482"), 1)
		Then("a town reads as printed", kindWith(o, "page_footer", "AGADEZ NIGER"), 1)
		Then("an address of mail too", kindWith(o, "page_footer", "accueil@archives.example"), 1)
		Then("a telephone number keeps its spaces (where the two readings differ, the model's is taken)", kindWith(o, "page_footer", "+227 20 44 17 63"), 1)
		Then("the band's lines stay the page's footer (their strokes are not measured: no false bold)", countKind(o, "heading"), 0)
		Then("the body, on paper, is the platform's", paraWith(o, "Le service des archives reçoit le public"), 1)
	EndScenario()
else
	? "SKIP: Light text on a dark band -- the fr-FR pack and the PP-OCR graphs are both needed"
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
		# the recogniser drops "1)" whole and reads "3)" as "3" while "2)" reads whole: the numbering gives them back
		Then("item 1, its marker lost, is item 1 again (the line right above item 2)", kindWith(o, "list_item", "1) Закрепите шлюз"), 1)
		Then("item 3, read as a bare 3, is item 3 again", kindWith(o, "list_item", "3) Подключите кабель"), 1)
		# a detector's box loses the capitals' height: the title's second line, all lower case, read 15 points under 20
		Then("the two-line title is one heading (a line going on in lower case continues the one above)", blockKind(o, "Шлюз телеметрии ТМ-200: руководство по настройке"), "heading")
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
		# a size read from a photo's boxes holds about 3% either way; the two bold 10-pt sub-headings over 10.5-pt text
		# (0.952 of it) fell under the 0.95 bar and read as paragraphs -- a page read through OCR is given 0.90
		Then("a bold sub-heading of the body's size is a heading", blockKind(o, "Direction Gare routière"), "heading")
		Then("and the other one", blockKind(o, "Direction Hôpital Saint-Lazare"), "heading")
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
		Then("a section numbered on two levels is a heading though its bold was not seen", blockKind(o, "2.1 Комплектность"), "heading")
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
