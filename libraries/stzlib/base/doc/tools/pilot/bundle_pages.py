import re, sys, importlib.util

SP = "C:/Users/ASUSV3~1/AppData/Local/Temp/claude/D--GitHub-stzlib/9a0dccae-8274-4800-8870-3865850d08f5/scratchpad/"
spec = importlib.util.spec_from_file_location("rp", "D:/GitHub/_wtd/libraries/stzlib/base/doc/tools/render_pilot.py")
rp = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rp)


def main_of(path):
    t = open(path, encoding="utf-8").read()
    m = re.search(r"<main>(.*)</main>", t, re.S)
    return m.group(1)


cls = main_of(SP + "pages/stzString.html")
met = main_of(SP + "pages/stzString.Find.html")
cls = cls.replace('href="stzString.Find.html"', 'href="#method"')
met = met.replace('href="stzString.html"', 'href="#class"')

css = rp.CSS
css = css.replace("@media (prefers-color-scheme:dark){:root:not([data-theme=light]){--bg:#161513;--fg:#ece8df;--muted:#b5afa2;--line:#3a372f;--card:#1e1c19;--code:#25221e;--acc:#e0a58f;--ok:#7fcf93;--drv:#e3b252;--out:#7db8f0}}",
                  "@media (prefers-color-scheme:dark){:root:not([data-theme=\"light\"]){--bg:#161513;--fg:#ece8df;--muted:#b5afa2;--line:#3a372f;--card:#1e1c19;--code:#25221e;--acc:#e0a58f;--ok:#7fcf93;--drv:#e3b252;--out:#7db8f0;color-scheme:dark}}\n"
                  ":root[data-theme=\"dark\"]{--bg:#161513;--fg:#ece8df;--muted:#b5afa2;--line:#3a372f;--card:#1e1c19;--code:#25221e;--acc:#e0a58f;--ok:#7fcf93;--drv:#e3b252;--out:#7db8f0;color-scheme:dark}")
assert 'data-theme="dark"' in css

tabs_css = """
.tabs{display:flex;gap:.5rem;flex-wrap:wrap;padding:.8rem 16px;border-bottom:1px solid var(--line);background:var(--bg);position:sticky;top:env(safe-area-inset-top,0px);z-index:2;font:16px/1.3 system-ui,sans-serif}
.tabs a{color:var(--fg);text-decoration:none;padding:.4rem .8rem;border:1px solid var(--line);border-radius:6px}
.tabs a[aria-current=true]{background:var(--acc);color:var(--bg);border-color:var(--acc);font-weight:600}
.tabs a:focus-visible{outline:2px solid var(--acc);outline-offset:2px}
.tabs .note{margin-left:auto;color:var(--muted);align-self:center}
.tablewrap{overflow-x:auto}
"""

html_out = """<title>Softanza Pilot Pages</title>
<style>
%s
%s
body{padding-inline:0}
</style>
<nav class="tabs" aria-label="Pilot pages">
<a href="#class" id="t-class">Class page: stzString</a>
<a href="#method" id="t-method">Method page: stzString.Find</a>
<span class="note">Pilot of STZLIB-DOCREFORM-01, read from reference.json</span>
</nav>
<main id="p-class">%s</main>
<main id="p-method" hidden>%s</main>
<script>
(function(){
  function show(){
    var h=(location.hash||"#class").replace("#","");
    if(h!=="method")h="class";
    document.getElementById("p-class").hidden=(h!=="class");
    document.getElementById("p-method").hidden=(h!=="method");
    ["class","method"].forEach(function(k){
      document.getElementById("t-"+k).setAttribute("aria-current",String(k===h));
    });
    window.scrollTo(0,0);
  }
  window.addEventListener("hashchange",show);
  show();
})();
</script>
""" % (css, tabs_css, cls, met)
# wide tables scroll inside their own container
html_out = html_out.replace("<table>", '<div class="tablewrap"><table>').replace("</table>", "</table></div>")
open(SP + "pilot_bundle.html", "w", encoding="utf-8").write(html_out)
print(len(html_out))
