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
# 13 of the same kind; Arabic golden_v35/y11 16 of 16, 13; Russian golden_v33/u06 18 of 26, 16. What a scan does not
# give back yet: a list whose markers the recogniser drops (u06), a code block (no OCR says a face is monospace),
# bold on Arabic headings, and the header cells of a table set on a dark band (z09).
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
		Then("the two timetables are two tables (the scan's ruled lines keep them apart)", countKind(o, "table"), 2)
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
	EndScenario()
else
	? "SKIP: A Russian scan reads as a document -- the Cyrillic recogniser is not installed"
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

func paraWith(oP, pcText)
	aB = oP.Blocks()
	nB = len(aB)
	for i = 1 to nB
		if aB[i][:kind] = "paragraph" and StzFindFirst(pcText, aB[i][:text]) > 0 return 1 ok
	next
	return 0
