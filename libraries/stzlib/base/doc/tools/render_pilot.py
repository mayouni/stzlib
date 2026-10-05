#!/usr/bin/env python3
"""Render ONE class page and ONE method page from reference.json, for a person to read.

DOCREFORM pilot tool (not a library dependency). The pages show what the record says and
LABEL what was derived rather than written; nothing is added here. Self-contained HTML,
light and dark.

    python render_pilot.py reference.json stzString Find outdir

writes  outdir/stzString.html  and  outdir/stzString.Find.html
"""
import html, json, sys, pathlib, re

CSS = """
:root{--bg:#fbfaf7;--fg:#1b1b1b;--muted:#5b5b5b;--line:#dedad0;--card:#ffffff;--code:#f3f0e8;--acc:#7a2f1d;--ok:#2d6a3e;--drv:#8a5a00;--out:#0b5cad}
@media (prefers-color-scheme:dark){:root:not([data-theme=light]){--bg:#161513;--fg:#ece8df;--muted:#b5afa2;--line:#3a372f;--card:#1e1c19;--code:#25221e;--acc:#e0a58f;--ok:#7fcf93;--drv:#e3b252;--out:#7db8f0}}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--fg);font:18px/1.6 Georgia,'Iowan Old Style',serif}
main{max-width:56rem;margin:0 auto;padding:1.5rem 16px 4rem}
nav.crumb{font:16px/1.4 system-ui,sans-serif;color:var(--muted);margin-bottom:1rem}
nav.crumb a{color:var(--acc)}
h1{font-size:2rem;margin:.2rem 0 .4rem;line-height:1.2}
h2{font-size:1.35rem;margin:2.2rem 0 .6rem;border-bottom:1px solid var(--line);padding-bottom:.25rem}
h3{font-size:1.1rem;margin:1.4rem 0 .4rem;font-family:system-ui,sans-serif;text-transform:capitalize}
.brief{font-size:1.2rem;margin:.2rem 0 1rem}
.meta{font:16px/1.5 system-ui,sans-serif;color:var(--muted)}
code,pre{font:15.5px/1.55 Consolas,'Cascadia Mono',monospace}
pre{background:var(--code);border:1px solid var(--line);border-radius:6px;padding:.8rem 1rem;overflow:auto;margin:.5rem 0 1rem}
code{background:var(--code);padding:0 .25em;border-radius:3px}
pre .out{color:var(--out);font-weight:600}
table{border-collapse:collapse;width:100%;margin:.4rem 0 1.2rem;font:16px/1.45 system-ui,sans-serif}
th,td{text-align:left;vertical-align:top;border-bottom:1px solid var(--line);padding:.45rem .6rem}
th{font-weight:700}
td.n{white-space:nowrap;font-family:Consolas,monospace;font-weight:600}
.tag{font:13px/1 system-ui,sans-serif;border:1px solid var(--line);border-radius:999px;padding:.12rem .5rem;margin-left:.4rem;white-space:nowrap}
.tag.w{color:var(--ok);border-color:var(--ok)}.tag.d{color:var(--drv);border-color:var(--drv)}
.none{color:var(--muted);font-style:italic}
.warn{border-left:4px solid var(--drv);background:var(--card);padding:.5rem .9rem;margin:.6rem 0}
.strip{display:flex;flex-wrap:wrap;gap:.6rem 1.6rem;font:16px/1.4 system-ui,sans-serif;margin:.8rem 0 1.4rem}
.strip b{font-size:1.25rem;display:block}
details{margin:.4rem 0 1rem}summary{cursor:pointer;font:16px/1.4 system-ui,sans-serif;color:var(--acc)}
@media(max-width:600px){body{font-size:17px}th,td{padding:.4rem .3rem}}
"""


def e(s):
    return html.escape(str(s), quote=False)


def tag(origin):
    if origin == "written":
        return '<span class="tag w">written</span>'
    if origin == "derived":
        return '<span class="tag d">derived</span>'
    return ""


def code_block(text):
    out = []
    for ln in text.split("\n"):
        out.append('<span class="out">%s</span>' % e(ln) if ln.lstrip().startswith("#-->") else e(ln))
    return "<pre>%s</pre>" % "\n".join(out)


def page(title, body):
    return ('<!doctype html><html lang="en"><head><meta charset="utf-8">'
            '<meta name="viewport" content="width=device-width,initial-scale=1">'
            '<title>%s</title><style>%s</style></head><body><main>%s</main></body></html>' % (e(title), CSS, body))


def method_href(cls, name):
    return "%s.%s.html" % (cls, name)


def class_page(c, linked):
    s = c["summary"]
    h = ['<nav class="crumb">Softanza reference &rsaquo; classes &rsaquo; %s</nav>' % e(c["name"]),
         "<h1>%s</h1>" % e(c["name"]), '<p class="brief">%s</p>' % e(c.get("brief", ""))]
    meta = "Inherits %s &middot; source <code>%s:%s</code>" % (
        ", ".join(e(a) for a in c.get("ancestors", [])) or "nothing", e(c["file"]), c["line"])
    h.append('<p class="meta">%s</p>' % meta)
    h.append('<div class="strip"><div><b>%d</b>methods</div><div><b>%d</b>with a written brief</div>'
             '<div><b>%d</b>with a run example</div><div><b>%d</b>other names folded in</div>'
             '<div><b>%d</b>extension forms folded in</div></div>' % (
                 s["roots"], s["brief_written"], s["with_example"], s["alias_names"], s["extension_forms"]))
    h.append("<h2>Detailed description</h2><p>%s</p>" % e(c.get("description", "")))
    if c.get("receiver"):
        h.append("<h3>A small object to try the methods on</h3>" + code_block(c["receiver"]))
    if c.get("example"):
        h.append("<h3>The shortest example</h3>" + code_block(c["receiver"] + "\n" + c["example"]))
    if c.get("see"):
        h.append('<p class="meta">See also: %s</p>' % ", ".join("<code>%s</code>" % e(x) for x in c["see"]))
    h.append("<h2>Methods, by what they do</h2>")
    by = {m["name"]: m for m in c["methods"]}
    for sec in c["sections"]:
        members = [by[n] for n in sec["members"] if n in by]
        if not members:
            continue
        title = sec["title"] or "unsorted"
        h.append("<h3>%s <span class='meta'>(%d)</span></h3><table><tr><th>Method</th><th>What it does</th></tr>" % (e(title), len(members)))
        for m in members:
            name = e(m["name"])
            if m["name"] in linked:
                name = '<a href="%s">%s</a>' % (method_href(c["name"], m["name"]), name)
            o = m.get("origin", {}).get("brief", "none")
            brief = e(m["brief"]) + tag(o) if m.get("brief") else '<span class="none">no description yet</span>'
            h.append('<tr><td class="n">%s</td><td>%s</td></tr>' % (name, brief))
        h.append("</table>")
    return page(c["name"] + " - Softanza reference", "".join(h))


def method_page(c, m):
    cn = c["name"]
    o = m.get("origin", {})
    h = ['<nav class="crumb"><a href="%s.html">%s</a> &rsaquo; %s</nav>' % (e(cn), e(cn), e(m["name"])),
         "<h1>%s</h1>" % e(m["name"])]
    if m.get("brief"):
        h.append('<p class="brief">%s%s</p>' % (e(m["brief"]), tag(o.get("brief"))))
    else:
        h.append('<p class="brief none">no description yet</p>')
    if m.get("status") and m["status"] != "stable":
        h.append('<p class="warn">Status: %s</p>' % e(m["status"]))
    for w in m.get("warnings", []):
        h.append('<p class="warn"><b>Warning.</b> %s</p>' % e(w))
    usage = m.get("usage", [])
    h.append("<h2>Usage</h2>" + code_block("\n".join(usage[:1] + m.get("forms", []))))
    pars = m.get("parameters", [])
    if pars:
        h.append("<h2>Parameters</h2><table><tr><th>Name</th><th>Type</th><th>Role</th></tr>")
        for p in pars:
            role = e(p["role"]) + tag(p.get("origin")) if p.get("role") else '<span class="none">not described</span>'
            h.append('<tr><td class="n">%s</td><td>%s</td><td>%s</td></tr>' % (e(p["name"]), e(p["type"]), role))
        h.append("</table>")
    if m.get("returns"):
        h.append("<h2>Returns</h2><p>%s%s</p>" % (e(m["returns"]), tag(o.get("returns"))))
    if m.get("detail"):
        h.append("<h2>Details</h2><p>%s</p>" % e(m["detail"]))
    if m.get("notes"):
        h.append("<h2>Notes</h2><ul>%s</ul>" % "".join("<li>%s</li>" % e(n) for n in m["notes"]))
    if m.get("example"):
        h.append("<h2>Example</h2><p class='meta'>Every example is run by the library's own harness; the blue lines are what it printed.</p>")
        h.append(code_block(c.get("receiver", "") + "\n" + m["example"] if not m["example"].lstrip().startswith("o1 =") else m["example"]))
    exts = m.get("extensions", [])
    if exts:
        h.append("<details><summary>%d other forms of this method</summary><table><tr><th>Form</th><th>What it adds</th></tr>" % len(exts))
        sig = {u.split("(")[0]: u for u in usage}
        for x in exts:
            h.append('<tr><td class="n">%s</td><td>%s</td></tr>' % (e(sig.get(x["name"], x["name"])), e(x["adds"])))
        h.append("</table></details>")
    if m.get("aliases"):
        h.append("<p><b>Other names:</b> %s</p>" % ", ".join("<code>%s</code>" % e(a) for a in m["aliases"]))
    if m.get("passive"):
        h.append("<p><b>Returns a copy instead:</b> <code>%s</code></p>" % e(m["passive"]))
    if m.get("see"):
        h.append("<p><b>See also:</b> %s</p>" % ", ".join("<code>%s</code>" % e(x) for x in m["see"]))
    h.append('<p class="meta">Source <code>%s:%s</code> &middot; section: %s &middot; checks %s &middot; '
             '<span class="tag w">written</span> = the author of the code wrote it, <span class="tag d">derived</span> = the extractor read it from the code or the glossary.</p>'
             % (e(c["file"]), m["line"], e(m.get("section", "")), "".join(str(x) for x in m.get("checks", []))))
    return page("%s.%s - Softanza reference" % (cn, m["name"]), "".join(h))


def main():
    if len(sys.argv) < 5:
        print(__doc__); sys.exit(2)
    ref = json.load(open(sys.argv[1], encoding="utf-8"))
    cname, mname, out = sys.argv[2], sys.argv[3], pathlib.Path(sys.argv[4])
    out.mkdir(parents=True, exist_ok=True)
    c = next(x for x in ref["classes"] if x["name"] == cname)
    m = next(x for x in c["methods"] if x["name"] == mname)
    (out / ("%s.html" % cname)).write_text(class_page(c, {mname}), encoding="utf-8")
    (out / ("%s.%s.html" % (cname, mname))).write_text(method_page(c, m), encoding="utf-8")
    print("wrote", out / ("%s.html" % cname), "and", out / ("%s.%s.html" % (cname, mname)))


if __name__ == "__main__":
    main()
