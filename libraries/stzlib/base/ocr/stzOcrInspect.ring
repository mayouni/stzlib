#--------------------------------------------------------------#
#  stzOcrInspect.ring -- SEE what OCR read, and where           #
#--------------------------------------------------------------#
#
# An inspection page for a document read through OCR: each page's image beside what was read from it -- the reader's
# blocks, or the OCR's own lines -- linked both ways. Moving over the image draws the box of the block or line read
# there and marks it in the list; moving over a block or line draws its box on the image; a click keeps one marked.
# A reading is judged by a person against the page (the author found an alef read as another by looking), and a list
# of text with no place on the page cannot be judged that way: this page gives every line its place.
#
# One HTML file with its page images in a folder beside it (<name>_files): the images are the ones the OCR read --
# a scan's own JPEG, or the level, sharpened copy written for the OCR (BMP) -- so a box lands on the pixels it came
# from. Notes can mark blocks ("=" right, "x" wrong, "-" missing, "+" extra, or anything) with a sentence each, and a
# note with no block is listed at the end of its page: a test harness says there what it expected and did not find.
#
#   see    stzPdf.OcrInspection(cHtml), stzPdf.OcrInspectionXT(cHtml, aNotes), StzOcrInspectionHtml

# The HTML of an inspection page.
#
#   pcTitle    the page's title
#   paPages    one record per page read: [ :page, :image (its path, as the HTML will reference it), :summary,
#              :blocks = [ [ :kind, :text, :box = [ x0, y0, x1, y1 ] in the image's pixels or [], :mark, :note ], ... ],
#              :lines = [ [ :text, :box ], ... ] ]
#   returns    the HTML text
func StzOcrInspectionHtml(pcTitle, paPages)
	_c_ = "{pages:["
	_nP_ = len(paPages)
	for _i_ = 1 to _nP_
		_p_ = paPages[_i_]
		if _i_ > 1 _c_ += "," ok
		_c_ += "{n:" + _p_[:page] + ",img:" + _StzOcrJs(_p_[:image]) + ",summary:" + _StzOcrJs(_p_[:summary]) + ",blocks:["
		_nB_ = len(_p_[:blocks])
		for _k_ = 1 to _nB_
			_b_ = _p_[:blocks][_k_]
			if _k_ > 1 _c_ += "," ok
			_c_ += "{kind:" + _StzOcrJs(_b_[:kind]) + ",text:" + _StzOcrJs(_b_[:text]) + ",box:" + _StzOcrJsBox(_b_[:box]) +
			       ",mark:" + _StzOcrJs(_b_[:mark]) + ",note:" + _StzOcrJs(_b_[:note]) + "}"
		next
		_c_ += "],lines:["
		_nL_ = len(_p_[:lines])
		for _k_ = 1 to _nL_
			_l_ = _p_[:lines][_k_]
			if _k_ > 1 _c_ += "," ok
			_c_ += "{text:" + _StzOcrJs(_l_[:text]) + ",box:" + _StzOcrJsBox(_l_[:box]) + "}"
		next
		_c_ += "]}"
	next
	_c_ += "]}"
	_cT_ = StzReplace(StzReplace(StzReplace("" + pcTitle, "&", "&amp;"), "<", "&lt;"), ">", "&gt;")
	return StzReplace(StzReplace(_StzOcrInspectTemplate(), "@TITLE@", _cT_), "@DATA@", _c_)

# a text as a JavaScript string literal in single quotes, safe inside a script element
func _StzOcrJs(pcText)
	_c_ = "" + pcText
	_c_ = StzReplace(_c_, "\", "\\")
	_c_ = StzReplace(_c_, "'", "\'")
	_c_ = StzReplace(_c_, char(13), "")
	_c_ = StzReplace(_c_, char(10), "\n")
	_c_ = StzReplace(_c_, char(9), "\t")
	_c_ = StzReplace(_c_, "<", "\x3c")
	return "'" + _c_ + "'"

# a box as a JavaScript array of four numbers, null when there is none
func _StzOcrJsBox(paBox)
	if NOT isList(paBox) or len(paBox) != 4 return "null" ok
	return "[" + paBox[1] + "," + paBox[2] + "," + paBox[3] + "," + paBox[4] + "]"

# the page's HTML, with @TITLE@ and @DATA@ to fill (one statement a line: Ring++ refuses one expression of a hundred
# concatenations)
func _StzOcrInspectTemplate()
	_n_ = char(10)
	_c_ = ""
	_c_ += "<!doctype html>" + _n_
	_c_ += "<html lang='en'>" + _n_
	_c_ += "<head>" + _n_
	_c_ += "<meta charset='utf-8'>" + _n_
	_c_ += "<meta name='viewport' content='width=device-width, initial-scale=1'>" + _n_
	_c_ += "<title>@TITLE@</title>" + _n_
	_c_ += "<style>" + _n_
	_c_ += ":root { --bg:#fbfaf7; --fg:#1d1d1b; --soft:#4a4844; --line:#d9d5cc; --card:#ffffff; --hi:#c2410c; --hifill:rgba(194,65,12,0.14); --box:rgba(37,99,235,0.55); --on:#fff1e6; --ok:#1f6f3f; --bad:#a3271f; --miss:#8a5a00; }" + _n_
	_c_ += "@media (prefers-color-scheme: dark) { :root { --bg:#1b1b1a; --fg:#ecebe6; --soft:#c9c6bd; --line:#3a3936; --card:#242422; --hi:#fb923c; --hifill:rgba(251,146,60,0.18); --box:rgba(96,165,250,0.6); --on:#3a2a1c; --ok:#7fd39b; --bad:#ff8d84; --miss:#f0c36a; } }" + _n_
	_c_ += "* { box-sizing:border-box; }" + _n_
	_c_ += "body { margin:0; padding:16px; background:var(--bg); color:var(--fg); font:17px/1.5 system-ui, -apple-system, 'Segoe UI', sans-serif; }" + _n_
	_c_ += "h1 { font-size:24px; margin:0 0 4px; }" + _n_
	_c_ += "h2 { font-size:20px; margin:28px 0 8px; }" + _n_
	_c_ += "p { max-width:75ch; margin:4px 0 12px; }" + _n_
	_c_ += ".pair { display:grid; grid-template-columns:minmax(0,1fr) minmax(0,1fr); gap:16px; align-items:start; }" + _n_
	_c_ += "@media (max-width:900px) { .pair { grid-template-columns:1fr; } }" + _n_
	_c_ += ".fig { position:relative; border:1px solid var(--line); background:#fff; cursor:crosshair; }" + _n_
	_c_ += "@media (min-width:901px) { .fig { position:sticky; top:8px; } }" + _n_
	_c_ += ".fig img { display:block; width:100%; height:auto; }" + _n_
	_c_ += ".fig svg { position:absolute; inset:0; width:100%; height:100%; pointer-events:none; }" + _n_
	_c_ += ".fig rect.all { fill:none; stroke:var(--box); stroke-width:1; vector-effect:non-scaling-stroke; }" + _n_
	_c_ += ".fig rect.hi { fill:var(--hifill); stroke:var(--hi); stroke-width:2.5; vector-effect:non-scaling-stroke; }" + _n_
	_c_ += ".bar { display:flex; flex-wrap:wrap; gap:8px; align-items:center; margin:0 0 8px; }" + _n_
	_c_ += ".bar button { font:inherit; padding:4px 12px; border:1px solid var(--line); background:var(--card); color:var(--fg); border-radius:6px; cursor:pointer; }" + _n_
	_c_ += ".bar button[aria-pressed='true'] { border-color:var(--hi); box-shadow:inset 0 0 0 1px var(--hi); }" + _n_
	_c_ += ".bar label { display:flex; gap:6px; align-items:center; }" + _n_
	_c_ += ".list { background:var(--card); border:1px solid var(--line); border-radius:6px; }" + _n_
	_c_ += ".item { display:grid; grid-template-columns:auto auto minmax(0,1fr); gap:10px; padding:6px 10px; border-bottom:1px solid var(--line); cursor:default; }" + _n_
	_c_ += ".item:last-child { border-bottom:0; }" + _n_
	_c_ += ".item.on { background:var(--on); }" + _n_
	_c_ += ".item.on .t { text-decoration:underline; text-decoration-color:var(--hi); text-decoration-thickness:2px; text-underline-offset:4px; }" + _n_
	_c_ += ".item.pinned { outline:2px solid var(--hi); outline-offset:-2px; }" + _n_
	_c_ += ".kind { font-family:ui-monospace, Consolas, monospace; white-space:nowrap; }" + _n_
	_c_ += ".mark { font-weight:700; min-width:1ch; }" + _n_
	_c_ += ".mark.ok { color:var(--ok); } .mark.bad { color:var(--bad); } .mark.miss { color:var(--miss); } .mark.extra { color:var(--bad); }" + _n_
	_c_ += ".note { color:var(--soft); display:block; }" + _n_
	_c_ += ".t { unicode-bidi:plaintext; white-space:pre-wrap; overflow-wrap:anywhere; }" + _n_
	_c_ += ".nobox { opacity:1; border-left:4px solid var(--miss); }" + _n_
	_c_ += "</style>" + _n_
	_c_ += "</head>" + _n_
	_c_ += "<body>" + _n_
	_c_ += "<h1>@TITLE@</h1>" + _n_
	_c_ += "<p>Each page: the image the OCR read, and what was read from it. Move over the image to find the line or block" + _n_
	_c_ += "read there; move over a line or block to see where it was read. Click one to keep it marked.</p>" + _n_
	_c_ += "<div id='pages'></div>" + _n_
	_c_ += "<script>" + _n_
	_c_ += "const D = @DATA@;" + _n_
	_c_ += "const SVGNS = 'http://www.w3.org/2000/svg';" + _n_
	_c_ += "function el(tag, cls, text) { const e = document.createElement(tag); if (cls) e.className = cls; if (text !== undefined) e.textContent = text; return e; }" + _n_
	_c_ += "function markClass(m) { return m === '=' ? 'ok' : m === 'x' ? 'bad' : m === '-' ? 'miss' : m === '+' ? 'extra' : ''; }" + _n_
	_c_ += "D.pages.forEach(function (pg) {" + _n_
	_c_ += "  const sec = el('section'); sec.appendChild(el('h2', '', 'Page ' + pg.n + (pg.summary ? ' — ' + pg.summary : '')));" + _n_
	_c_ += "  const pair = el('div', 'pair');" + _n_
	_c_ += "  const fig = el('div', 'fig'); const img = el('img'); img.src = pg.img; img.alt = 'page ' + pg.n;" + _n_
	_c_ += "  const svg = document.createElementNS(SVGNS, 'svg'); svg.setAttribute('preserveAspectRatio', 'none');" + _n_
	_c_ += "  fig.appendChild(img); fig.appendChild(svg);" + _n_
	_c_ += "  const side = el('div'); const bar = el('div', 'bar'); const list = el('div', 'list');" + _n_
	_c_ += "  const layers = { blocks: pg.blocks, lines: pg.lines };" + _n_
	_c_ += "  let layer = pg.blocks.length ? 'blocks' : 'lines'; let pinned = -1; let showAll = false;" + _n_
	_c_ += "  const bBlocks = el('button', '', 'Blocks (' + pg.blocks.length + ')'); const bLines = el('button', '', 'OCR lines (' + pg.lines.length + ')');" + _n_
	_c_ += "  const all = el('label'); const cb = el('input'); cb.type = 'checkbox'; all.appendChild(cb); all.appendChild(document.createTextNode('show every box'));" + _n_
	_c_ += "  bar.appendChild(bBlocks); bar.appendChild(bLines); bar.appendChild(all);" + _n_
	_c_ += "  side.appendChild(bar); side.appendChild(list);" + _n_
	_c_ += "  pair.appendChild(fig); pair.appendChild(side); sec.appendChild(pair);" + _n_
	_c_ += "  document.getElementById('pages').appendChild(sec);" + _n_
	_c_ += "  function rectOf(it) { return it.box; }" + _n_
	_c_ += "  function draw(i) {" + _n_
	_c_ += "    while (svg.firstChild) svg.removeChild(svg.firstChild);" + _n_
	_c_ += "    const items = layers[layer];" + _n_
	_c_ += "    if (showAll) items.forEach(function (it) { if (!it.box) return; const r = document.createElementNS(SVGNS, 'rect'); r.setAttribute('class', 'all');" + _n_
	_c_ += "      r.setAttribute('x', it.box[0]); r.setAttribute('y', it.box[1]); r.setAttribute('width', it.box[2] - it.box[0]); r.setAttribute('height', it.box[3] - it.box[1]); svg.appendChild(r); });" + _n_
	_c_ += "    const j = i >= 0 ? i : pinned;" + _n_
	_c_ += "    if (j >= 0 && items[j] && items[j].box) { const b = items[j].box; const r = document.createElementNS(SVGNS, 'rect'); r.setAttribute('class', 'hi');" + _n_
	_c_ += "      r.setAttribute('x', b[0]); r.setAttribute('y', b[1]); r.setAttribute('width', b[2] - b[0]); r.setAttribute('height', b[3] - b[1]); svg.appendChild(r); }" + _n_
	_c_ += "    Array.prototype.forEach.call(list.children, function (row, k) { row.classList.toggle('on', k === j); row.classList.toggle('pinned', k === pinned); });" + _n_
	_c_ += "  }" + _n_
	_c_ += "  function fill() {" + _n_
	_c_ += "    list.textContent = ''; pinned = -1;" + _n_
	_c_ += "    bBlocks.setAttribute('aria-pressed', layer === 'blocks'); bLines.setAttribute('aria-pressed', layer === 'lines');" + _n_
	_c_ += "    layers[layer].forEach(function (it, k) {" + _n_
	_c_ += "      const row = el('div', 'item' + (it.box ? '' : ' nobox'));" + _n_
	_c_ += "      row.appendChild(el('span', 'mark ' + markClass(it.mark || ''), it.mark || ''));" + _n_
	_c_ += "      row.appendChild(el('span', 'kind', it.kind || ''));" + _n_
	_c_ += "      const t = el('span', 't', it.text); t.dir = 'auto';" + _n_
	_c_ += "      if (it.note) { const n = el('span', 'note', it.note); n.dir = 'auto'; t.appendChild(n); }" + _n_
	_c_ += "      row.appendChild(t);" + _n_
	_c_ += "      row.addEventListener('mouseenter', function () { draw(k); });" + _n_
	_c_ += "      row.addEventListener('mouseleave', function () { draw(-1); });" + _n_
	_c_ += "      row.addEventListener('click', function () { pinned = pinned === k ? -1 : k; draw(-1); });" + _n_
	_c_ += "      list.appendChild(row);" + _n_
	_c_ += "    });" + _n_
	_c_ += "    draw(-1);" + _n_
	_c_ += "  }" + _n_
	_c_ += "  function at(ev) {" + _n_
	_c_ += "    const r = img.getBoundingClientRect(); const x = (ev.clientX - r.left) * img.naturalWidth / r.width; const y = (ev.clientY - r.top) * img.naturalHeight / r.height;" + _n_
	_c_ += "    let best = -1; let area = Infinity;" + _n_
	_c_ += "    layers[layer].forEach(function (it, k) { const b = it.box; if (!b) return;" + _n_
	_c_ += "      if (x >= b[0] && x <= b[2] && y >= b[1] && y <= b[3]) { const a = (b[2] - b[0]) * (b[3] - b[1]); if (a < area) { area = a; best = k; } } });" + _n_
	_c_ += "    return best;" + _n_
	_c_ += "  }" + _n_
	_c_ += "  fig.addEventListener('mousemove', function (ev) { const k = at(ev); draw(k); if (k >= 0) { const row = list.children[k]; const rr = row.getBoundingClientRect();" + _n_
	_c_ += "    if (rr.top < 0 || rr.bottom > window.innerHeight) row.scrollIntoView({ block: 'nearest' }); } });" + _n_
	_c_ += "  fig.addEventListener('mouseleave', function () { draw(-1); });" + _n_
	_c_ += "  fig.addEventListener('click', function (ev) { const k = at(ev); pinned = pinned === k ? -1 : k; draw(-1); });" + _n_
	_c_ += "  img.addEventListener('load', function () { svg.setAttribute('viewBox', '0 0 ' + img.naturalWidth + ' ' + img.naturalHeight); });" + _n_
	_c_ += "  bBlocks.addEventListener('click', function () { layer = 'blocks'; fill(); });" + _n_
	_c_ += "  bLines.addEventListener('click', function () { layer = 'lines'; fill(); });" + _n_
	_c_ += "  cb.addEventListener('change', function () { showAll = cb.checked; draw(-1); });" + _n_
	_c_ += "  fill();" + _n_
	_c_ += "});" + _n_
	_c_ += "</script>" + _n_
	_c_ += "</body>" + _n_
	_c_ += "</html>" + _n_
	return _c_
