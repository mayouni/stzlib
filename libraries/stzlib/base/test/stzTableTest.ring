load "../stzbase.ring"
load "../../max/list/stzPivotTable.ring" # some samples use stzPivotTable from the MAX layer
load "../../max/list/stzlist2D.ring" #TODO // Should be relocated in BASE layer

/*=== TESTING ERASE AND FILL SECTIONS IN STZSTRINg

pr()

o1 = new stzString("[**Word1***Word2**Word3***]")

aSections = [ [2,3], [9, 11], [17, 18], [24, 26] ]
? @@(o1.Sections(aSections))
#--> [ "**", "***", "**", "***" ]

o1.FillSections(aSections, :With = "^")

? o1.Content()
#--> '[^^Word1^^^Word2^^Word3^^^]'

o1.EraseSections(aSections)
? o1.Content()
#--> '[  Word1   Word2  Word3   ]'

pf()
# Executed in 0.08 second(s) in Ring 1.22

/*==== TESTING HTML TABLES IN STZSTRING
*/
pr()

cHtml = '

<!DOCTYPE html><html lang="en"> <head><meta name="viewport" content="width=device-width, initial-scale=1"><meta charset="utf-8"><meta name="description" content="JPM Dividend History for JPMorgan Chase &#38; Co. (NYSE) with yield, ex-date, payout history and stock distribution data relevant for income investors."><meta name="keywords" content="dividend date history yield calendar JPM JPMorgan Chase &#38; Co."><link rel="sitemap" href="/sitemap-index.xml"><meta property="og:title" content="Dividend History"><meta property="og:url" content="https://dividendhistory.org"><meta property="og:description" content="Dividend History | Yields, dates, complete payout history and stock information"><meta property="og:type" content="website"><meta property="og:image" content="https://dividendhistory.org/thumbnail.png"><link rel="canonical" href="https://dividendhistory.org/payout/JPM/"><link rel="shortcut icon" href="/favicon.ico"><title>Dividend History | JPM JPMorgan Chase &amp; Co. payout date</title><script type="module" src="/_astro/Layout.astro_astro_type_script_index_0_lang.CLMvWv1n.js"></script><script type="text/partytown" async src="https://www.googletagmanager.com/gtag/js?id=G-YGXZGLQLES"></script><script type="text/partytown">
			window.dataLayer = window.dataLayer || [];
			window.gtag = function(){dataLayer.push(arguments);}
			window.gtag("js", new Date());
			window.gtag("config", "G-YGXZGLQLES");
		</script><script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-7749727118045578" crossorigin="anonymous"></script><script>
			(() => {
			  	"use strict"
				const getStoredTheme = () => localStorage.getItem("theme")
				const setStoredTheme = theme => localStorage.setItem("theme", theme)
				const getPreferredTheme = () => {
					const storedTheme = getStoredTheme()
					if (storedTheme) {
						return storedTheme
					}
					return "light";
				}
				const setTheme = theme => {
					document.documentElement.setAttribute("data-bs-theme", theme);
					const searchSelect = document.querySelector(".multiselect");
					if (searchSelect) {
						searchSelect.classList.remove("multiselect-dark");
						searchSelect.classList.remove("multiselect-light");
						searchSelect.classList.add(`multiselect-${theme}`);
					}
				}
			
				setTheme(getPreferredTheme())
			
				const showActiveTheme = (theme, focus = false) => {
					const themeSwitcher = document.querySelector("#bd-theme")
					if (!themeSwitcher) {
						return
					}
					const btnToActive = document.querySelector(`[data-bs-theme-value="${theme}"]`)
					document.querySelectorAll("[data-bs-theme-value]").forEach(element => {
						element.classList.remove("active")
						element.setAttribute("aria-pressed", "false")
					})
					btnToActive.classList.add("active")
					btnToActive.setAttribute("aria-pressed", "true")
					if (focus) {
						themeSwitcher.focus()
					}
				}
			
				window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", () => {
					const storedTheme = getStoredTheme()
					if (storedTheme !== "light" && storedTheme !== "dark") {
						setTheme(getPreferredTheme())
					}
				})
			
				window.addEventListener("DOMContentLoaded", () => {
					showActiveTheme(getPreferredTheme())
					document.querySelectorAll("[data-bs-theme-value]")
						.forEach(toggle => {
						toggle.addEventListener("click", () => {
							const theme = toggle.getAttribute("data-bs-theme-value")
							setStoredTheme(theme)
							setTheme(theme)
							showActiveTheme(theme, true)
						})
					})
				})
			
			})()
		</script><link rel="stylesheet" href="/_astro/Layout.BJ8zYxaR.css">
<style>a{text-decoration:none}a:hover{text-decoration:underline}.form-select{padding:0}body{--bs-body-font-size: 14px}.stock-search-container{position:relative;--bs-dropdown-link-active-bg: var(--bs-gray-200)}[data-bs-theme=dark] .stock-search-container{--bs-dropdown-link-active-bg: #697fa1}.stock-search-container .dropdown-menu{max-height:30rem;overflow-y:auto;margin-top:0;border-top:none;border-top-left-radius:0;border-top-right-radius:0;width:100%!important;min-width:300px;padding-top:0}.stock-search-container #stock-search-results .dropdown-item{padding:.5rem 1rem!important;display:block!important;text-align:left;line-height:1.4;width:100%!important;box-sizing:border-box;white-space:normal;cursor:pointer}.stock-search-container #stock-search-results .dropdown-item:hover{background-color:var(--bs-dropdown-link-active-bg);color:var(--bs-dropdown-link-active-color)}.stock-search-container #stock-search-results .dropdown-item .fi{display:inline-block;margin-right:.5rem;vertical-align:baseline}.stock-search-container #stock-search-results .dropdown-item .symbol,.stock-search-container #stock-search-results .dropdown-item strong.symbol{font-weight:700!important;margin-right:.5rem;color:inherit;font-family:Consolas,Monaco,Menlo,DejaVu Sans Mono,Courier New,monospace}.stock-search-container #stock-search-results .dropdown-item .name{display:inline}.stock-search-container .cursor-pointer{cursor:pointer}.stock-search-container #stock-search-input{border-top-right-radius:0;border-bottom-right-radius:0}.stock-search-container #stock-search-input:focus{border-color:#1062b930;box-shadow:0 0 0 .25rem #1062b930}.stock-search-container #search-icon{border-top-left-radius:0;border-bottom-left-radius:0}.stock-search-container #search-icon-clear{display:none}.stock-search-container .no-results{padding:1rem;text-align:center;color:var(--bs-gray-600)}.search-shortcut-badge{position:absolute;right:3.5rem;top:50%;transform:translateY(-50%);pointer-events:none;z-index:10;align-items:center}.search-shortcut-badge kbd{background-color:var(--bs-gray-100);border:1px solid var(--bs-gray-300);border-radius:.25rem;padding:.125rem .375rem;font-size:.75rem;font-weight:500;color:var(--bs-gray-700);box-shadow:0 1px 2px #0000000d}[data-bs-theme=dark] .search-shortcut-badge kbd{background-color:var(--bs-gray-800);border-color:var(--bs-gray-600);color:var(--bs-gray-300)}.stock-search-container #stock-search-input:focus~.search-shortcut-badge,.stock-search-container #stock-search-input:not(:placeholder-shown)~.search-shortcut-badge{opacity:0;transition:opacity .2s ease}
.top-search-table[data-astro-cid-d77igchn]{font-size:12px}
.related-stocks-table[data-astro-cid-hgbsvna7]{font-size:12px}
</style><script>!(function(w,p,f,c){if(!window.crossOriginIsolated && !navigator.serviceWorker) return;c=w[p]=Object.assign(w[p]||{},{"lib":"/~partytown/","debug":false});c[f]=(c[f]||[]).concat(["dataLayer.push","gtag","GoogleAnalyticsObject","ga"])})(window,"partytown","forward");/* Partytown 0.11.0 - MIT QwikDev */
const t={preserveBehavior:!1},e=e=>{if("string"==typeof e)return[e,t];const[n,r=t]=e;return[n,{...t,...r}]},n=Object.freeze((t=>{const e=new Set;let n=[];do{Object.getOwnPropertyNames(n).forEach((t=>{"function"==typeof n[t]&&e.add(t)}))}while((n=Object.getPrototypeOf(n))!==Object.prototype);return Array.from(e)})());!function(t,r,o,i,a,s,c,l,d,p,u=t,f){function h(){f||(f=1,"/"==(c=(s.lib||"/~partytown/")+(s.debug?"debug/":""))[0]&&(d=r.querySelectorAll("script[type="text/partytown"]"),i!=t?i.dispatchEvent(new CustomEvent("pt1",{detail:t})):(l=setTimeout(v,(null==s?void 0:s.fallbackTimeout)||1e4),r.addEventListener("pt0",w),a?y(1):o.serviceWorker?o.serviceWorker.register(c+(s.swPath||"partytown-sw.js"),{scope:c}).then((function(t){t.active?y():t.installing&&t.installing.addEventListener("statechange",(function(t){"activated"==t.target.state&&y()}))}),console.error):v())))}function y(e){p=r.createElement(e?"script":"iframe"),t._pttab=Date.now(),e||(p.style.display="block",p.style.width="0",p.style.height="0",p.style.border="0",p.style.visibility="hidden",p.setAttribute("aria-hidden",!0)),p.src=c+"partytown-"+(e?"atomics.js?v=0.11.0":"sandbox-sw.html?"+t._pttab),r.querySelector(s.sandboxParent||"body").appendChild(p)}function v(n,o){for(w(),i==t&&(s.forward||[]).map((function(n){const[r]=e(n);delete t[r.split(".")[0]]})),n=0;n<d.length;n++)(o=r.createElement("script")).innerHTML=d[n].innerHTML,o.nonce=s.nonce,r.head.appendChild(o);p&&p.parentNode.removeChild(p)}function w(){clearTimeout(l)}s=t.partytown||{},i==t&&(s.forward||[]).map((function(r){const[o,{preserveBehavior:i}]=e(r);u=t,o.split(".").map((function(e,r,o){var a;u=u[o[r]]=r+1<o.length?u[o[r]]||(a=o[r+1],n.includes(a)?[]:{}):(()=>{let e=null;if(i){const{methodOrProperty:n,thisObject:r}=((t,e)=>{let n=t;for(let t=0;t<e.length-1;t+=1)n=n[e[t]];return{thisObject:n,methodOrProperty:e.length>0?n[e[e.length-1]]:void 0}})(t,o);"function"==typeof n&&(e=(...t)=>n.apply(r,...t))}return function(){let n;return e&&(n=e(arguments)),(t._ptf=t._ptf||[]).push(o,arguments),n}})()}))})),"complete"==r.readyState?h():(t.addEventListener("DOMContentLoaded",h),t.addEventListener("load",h))}(window,document,navigator,top,window.crossOriginIsolated);;(e=>{e.addEventListener("astro:before-swap",e=>{let r=document.body.querySelector("iframe[src*="/~partytown/"]");if(r)e.newDocument.body.append(r)})})(document);</script></head> <body class="container-fluid"> <nav class="navbar navbar-expand-lg bg-body-tertiary"> <div class="container-fluid"> <a class="navbar-brand" href="/">Dividend History</a> <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation"> <span class="navbar-toggler-icon"></span> </button> <div class="collapse navbar-collapse" id="navbarSupportedContent"> <ul class="navbar-nav me-auto mb-2 mb-lg-0"> <li class="nav-item"> <a class="nav-link" aria-current="page" href="/calendar/"><i class="bi bi-calendar2-week me-1"></i>Dividend Calendar</a> </li> <li class="nav-item"> <a class="nav-link" aria-current="page" href="/report/"><i class="bi bi-card-list me-1"></i>Dividend Reports</a> </li> <li class="nav-item"> <a class="nav-link" aria-current="page" href="/announcements/"><i class="bi bi-megaphone me-1"></i>Dividend Announcements</a> </li> <li class="nav-item dropdown"> <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false"> <i class="bi bi-globe-americas me-1"></i>Browse Dividend Stocks
</a> <ul class="dropdown-menu"> <li><a class="dropdown-item" href="/popular-dividend-stocks/" title="">Top 10 Most Popular Dividend Stocks</a></li> <li><a class="dropdown-item" href="/high-yield-dividend-stocks/" title="">High Dividend Stocks</a></li> <li><a class="dropdown-item" href="/quality-dividend-stocks/" title="">Best Quality Dividend Stocks</a></li> <li><a class="dropdown-item" href="/monthly-payout/" title="">Monthly Payout</a></li> <li><a class="dropdown-item" href="/weekly-payout/" title="">Weekly Payout</a></li> <li><a class="dropdown-item" href="/snp500/" title="">S&amp;P 500</a></li> <li><a class="dropdown-item" href="/nyse/" title="">NYSE</a></li> <li><a class="dropdown-item" href="/nasdaq/" title="">Nasdaq</a></li> <li><a class="dropdown-item" href="/tsx/" title="">Canadian TSX</a></li> <li><a class="dropdown-item" href="/lse/" title="">United Kingdom LSE</a></li> <li><a class="dropdown-item" href="/asx/" title="">Australian ASX</a></li> </ul> </li> <li class="nav-item"> <a class="nav-link" aria-current="page" href="/contact/">Contact</a> </li> </ul> <ul class="navbar-nav flex-row flex-wrap ms-md-auto"> <li class="nav-item dropdown"> <button class="btn btn-link nav-link py-2 px-0 px-lg-2 dropdown-toggle d-flex align-items-center show" id="bd-theme" type="button" aria-expanded="true" data-bs-toggle="dropdown" data-bs-display="static" aria-label="Toggle theme (light)"> <i class="bi bi-gear-fill"></i> <span class="d-lg-none ms-2" id="bd-theme-text">Change theme</span> </button> <ul class="dropdown-menu dropdown-menu-end" style="right: 0;left: auto;"> <li> <button type="button" class="dropdown-item d-flex align-items-center active" data-bs-theme-value="light" aria-pressed="true"> <i class="bi bi-sun-fill me-2"></i>
Light
<i id="light-check" class="bi bi-check2 ms-auto d-none"></i> </button> </li> <li> <button type="button" class="dropdown-item d-flex align-items-center" data-bs-theme-value="dark" aria-pressed="false"> <i class="bi bi-moon-stars-fill me-2"></i>
Dark
<i id="dark-check" class="bi bi-check2 ms-auto d-none"></i> </button> </li> </ul> </li> <li class="nav-item col-6 col-lg-auto">
&nbsp;
</li> </ul> </div> </div> </nav>  <div class="row pt-3"> <div class="col-md-2"></div> <div class="col-md-5"> <h4>JPMorgan Chase &amp; Co. (JPM)</h4>  </div> <div class="col-md-5"> <div class="stock-search-container"> <div class="input-group"> <span id="search-select-assist" class="visually-hidden">Stock search input</span> <!-- Main search dropdown --> <div class="dropdown flex-grow-1" id="stock-search-dropdown"> <input type="text" class="form-control" id="stock-search-input" placeholder="Search by Symbol or Company" autocomplete="off" aria-label="Search by Symbol or Company" aria-labelledby="search-select-assist" aria-expanded="false" aria-controls="stock-search-results" role="combobox"> <div> <ul class="dropdown-menu w-100" id="stock-search-results" role="listbox" aria-labelledby="stock-search-input"> <!-- Results will be populated here --> </ul> </div> </div> <span class="input-group-text cursor-pointer" id="search-icon"> <i class="bi bi-search" id="search-icon-default"></i> <i class="bi bi-x" id="search-icon-clear"></i> </span> <!-- Keyboard shortcut badge --> <span class="search-shortcut-badge d-none d-lg-flex" id="search-shortcut-badge"> <kbd><span id="shortcut-key">⌘</span>K</kbd> </span> </div> </div>  <script type="module" src="/_astro/StockSearch.astro_astro_type_script_index_0_lang.COxFcx87.js"></script> </div> </div> <div class="row"> <div class="col-md-2 hidden-xs hidden-sm"> <div class="leftad"> <!-- <script is:inline async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-7749727118045578"
        crossorigin="anonymous"></script> --> <ins class="adsbygoogle" style="display:block" data-ad-client="ca-pub-7749727118045578" data-ad-slot="3833971346" data-ad-format="auto" data-full-width-responsive="true"></ins> <script>
            (adsbygoogle = window.adsbygoogle || []).push({});
        </script> </div> </div> <div class="col-md-8 col-xs-12 col-sm-12"> <p>News/Announcements: <table id="news-table" class="table table-condensed"><tbody><tr><td>2025-03-20</td><td><span class="fi fi-us"></span></td><td><a href="/payout/JPM/">JPM</a></td><td>JPMorgan Chase &amp; Co. raises dividend 12% to $1.40 quarterly</td></tr><tr><td>2024-09-18</td><td><span class="fi fi-us"></span></td><td><a href="/payout/JPM/">JPM</a></td><td>JPMorgan Chase &amp; Co. raises dividend 8.7% to $1.25 quarterly</td></tr><tr><td>2024-03-21</td><td><span class="fi fi-us"></span></td><td><a href="/payout/JPM/">JPM</a></td><td>JPMorgan Chase &amp; Co. raises dividend 9.5% to $1.15 quarterly</td></tr><tr><td>2021-09-22</td><td><span class="fi fi-us"></span></td><td><a href="/payout/JPM/">JPM</a></td><td>JPMorgan Chase raises dividend 11% to $1.00 quarterly</td></tr><tr><td>2019-07-03</td><td><span class="fi fi-us"></span></td><td><a href="/payout/JPM/">JPM</a></td><td>JPMorgan Chase raises dividend 12.5% to $0.90 quarterly</td></tr></tbody></table></p> <p>Updated: 2025-07-18</p> <p>Last Close Price: $291.27</p> <p>Next Earnings: 2025-10-14</p> <p>Yield: 1.93%</p> <p>Payout Ratio: 27.48 %</p> <p>PE Ratio: 14.22</p> <p>Market Cap: 809.47B</p> <p>Frequency: Quarterly</p> <p>Dividend History (adjusted for splits)</p> <dividend-table><table id="dividend-table"><thead><tr><th>Ex-Dividend Date</th><th>Payout Date</th><th>Cash Amount</th><th>% Change</th></tr></thead><tbody><tr class="unconfirmed-div"><td>2026-01-06</td><td>2026-01-30</td><td>$1.40</td><td>unconfirmed/estimated</td></tr><tr class="unconfirmed-div"><td>2025-10-03</td><td>2025-10-31</td><td>$1.40</td><td>unconfirmed/estimated</td></tr><tr class><td>2025-07-03</td><td>2025-07-31</td><td>$1.40</td><td></td></tr><tr class><td>2025-04-04</td><td>2025-04-30</td><td>$1.40</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>12%</span></td></tr><tr class><td>2025-01-06</td><td>2025-01-31</td><td>$1.25</td><td></td></tr><tr class><td>2024-10-04</td><td>2024-10-31</td><td>$1.25</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>8.7%</span></td></tr><tr class><td>2024-07-05</td><td>2024-07-31</td><td>$1.15</td><td></td></tr><tr class><td>2024-04-04</td><td>2024-04-30</td><td>$1.15</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>9.52%</span></td></tr><tr class><td>2024-01-04</td><td>2024-01-31</td><td>$1.05</td><td></td></tr><tr class><td>2023-10-05</td><td>2023-10-31</td><td>$1.05</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>5%</span></td></tr><tr class><td>2023-07-05</td><td>2023-07-31</td><td>$1.00</td><td></td></tr><tr class><td>2023-04-05</td><td>2023-04-30</td><td>$1.00</td><td></td></tr><tr class><td>2023-01-05</td><td>2023-01-31</td><td>$1.00</td><td></td></tr><tr class><td>2022-10-05</td><td>2022-10-31</td><td>$1.00</td><td></td></tr><tr class><td>2022-07-05</td><td>2022-07-31</td><td>$1.00</td><td></td></tr><tr class><td>2022-04-05</td><td>2022-04-30</td><td>$1.00</td><td></td></tr><tr class><td>2022-01-05</td><td>2022-01-31</td><td>$1.00</td><td></td></tr><tr class><td>2021-10-05</td><td>2021-10-31</td><td>$1.00</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>11.11%</span></td></tr><tr class><td>2021-07-02</td><td>2021-07-31</td><td>$0.90</td><td></td></tr><tr class><td>2021-04-05</td><td>2021-04-30</td><td>$0.90</td><td></td></tr><tr class><td>2021-01-05</td><td>2021-01-31</td><td>$0.90</td><td></td></tr><tr class><td>2020-10-05</td><td>2020-10-31</td><td>$0.90</td><td></td></tr><tr class><td>2020-07-02</td><td>2020-07-31</td><td>$0.90</td><td></td></tr><tr class><td>2020-04-03</td><td>2020-04-30</td><td>$0.90</td><td></td></tr><tr class><td>2020-01-03</td><td>2020-01-31</td><td>$0.90</td><td></td></tr><tr class><td>2019-10-03</td><td>2019-10-31</td><td>$0.90</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>12.5%</span></td></tr><tr class><td>2019-07-03</td><td>2019-07-31</td><td>$0.80</td><td></td></tr><tr class><td>2019-04-04</td><td>2019-04-30</td><td>$0.80</td><td></td></tr><tr class><td>2019-01-03</td><td>2019-01-31</td><td>$0.80</td><td></td></tr><tr class><td>2018-10-04</td><td>2018-10-31</td><td>$0.80</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>42.86%</span></td></tr><tr class><td>2018-07-05</td><td>2018-07-31</td><td>$0.56</td><td></td></tr><tr class><td>2018-04-05</td><td>2018-04-30</td><td>$0.56</td><td></td></tr><tr class><td>2018-01-04</td><td>2018-01-31</td><td>$0.56</td><td></td></tr><tr class><td>2017-10-05</td><td>2017-10-31</td><td>$0.56</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>12%</span></td></tr><tr class><td>2017-07-03</td><td>2017-07-31</td><td>$0.50</td><td></td></tr><tr class><td>2017-04-04</td><td>2017-04-30</td><td>$0.50</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>4.17%</span></td></tr><tr class><td>2017-01-04</td><td>2017-01-31</td><td>$0.48</td><td></td></tr><tr class><td>2016-10-04</td><td>2016-10-31</td><td>$0.48</td><td></td></tr><tr class><td>2016-07-01</td><td>2016-07-31</td><td>$0.48</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>9.09%</span></td></tr><tr class><td>2016-04-04</td><td>2016-04-30</td><td>$0.44</td><td></td></tr><tr class><td>2016-01-04</td><td>2016-01-31</td><td>$0.44</td><td></td></tr><tr class><td>2015-10-02</td><td>2015-10-31</td><td>$0.44</td><td></td></tr><tr class><td>2015-07-01</td><td>2015-07-31</td><td>$0.44</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>10%</span></td></tr><tr class><td>2015-04-01</td><td>2015-04-30</td><td>$0.40</td><td></td></tr><tr class><td>2015-01-02</td><td>2015-01-31</td><td>$0.40</td><td></td></tr><tr class><td>2014-10-02</td><td>2014-10-31</td><td>$0.40</td><td></td></tr><tr class><td>2014-07-01</td><td>2014-07-31</td><td>$0.40</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>5.26%</span></td></tr><tr class><td>2014-04-02</td><td>2014-04-30</td><td>$0.38</td><td></td></tr><tr class><td>2014-01-02</td><td>2014-01-31</td><td>$0.38</td><td></td></tr><tr class><td>2013-10-02</td><td>2013-10-31</td><td>$0.38</td><td></td></tr><tr class><td>2013-07-02</td><td>2013-07-31</td><td>$0.38</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>26.67%</span></td></tr><tr class><td>2013-04-03</td><td>2013-04-30</td><td>$0.30</td><td></td></tr><tr class><td>2013-01-02</td><td>2013-01-31</td><td>$0.30</td><td></td></tr><tr class><td>2012-10-03</td><td>2012-10-31</td><td>$0.30</td><td></td></tr><tr class><td>2012-07-03</td><td>2012-07-31</td><td>$0.30</td><td></td></tr><tr class><td>2012-04-03</td><td>2012-04-30</td><td>$0.30</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>20%</span></td></tr><tr class><td>2012-01-04</td><td>2012-01-31</td><td>$0.25</td><td></td></tr><tr class><td>2011-10-04</td><td>2011-10-31</td><td>$0.25</td><td></td></tr><tr class><td>2011-07-01</td><td>2011-07-31</td><td>$0.25</td><td></td></tr><tr class><td>2011-04-04</td><td>2011-04-30</td><td>$0.25</td><td></td></tr><tr class><td>2011-01-04</td><td>2011-01-31</td><td>$0.05</td><td></td></tr><tr class><td>2010-10-04</td><td>2010-10-31</td><td>$0.05</td><td></td></tr><tr class><td>2010-07-01</td><td>2010-07-31</td><td>$0.05</td><td></td></tr><tr class><td>2010-04-01</td><td>2010-04-30</td><td>$0.05</td><td></td></tr><tr class><td>2010-01-04</td><td>2010-01-31</td><td>$0.05</td><td></td></tr><tr class><td>2009-10-02</td><td>2009-10-31</td><td>$0.05</td><td></td></tr><tr class><td>2009-07-01</td><td>2009-07-31</td><td>$0.05</td><td></td></tr><tr class><td>2009-04-02</td><td>2009-04-30</td><td>$0.05</td><td><span class="percent-change percent-decrease"><i class="bi bi-arrow-down-circle-fill me-1" role="img" aria-label="Dividend Decrease"></i>-86.84%</span></td></tr><tr class><td>2009-01-02</td><td>2009-01-31</td><td>$0.38</td><td></td></tr><tr class><td>2008-10-02</td><td>2008-10-31</td><td>$0.38</td><td></td></tr><tr class><td>2008-07-01</td><td>2008-07-31</td><td>$0.38</td><td></td></tr><tr class><td>2008-04-02</td><td>2008-04-30</td><td>$0.38</td><td></td></tr><tr class><td>2008-01-02</td><td>2008-01-31</td><td>$0.38</td><td></td></tr><tr class><td>2007-10-03</td><td>2007-10-31</td><td>$0.38</td><td></td></tr><tr class><td>2007-07-03</td><td>2007-07-31</td><td>$0.38</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>11.76%</span></td></tr><tr class><td>2007-04-03</td><td>2007-04-30</td><td>$0.34</td><td></td></tr><tr class><td>2007-01-03</td><td>2007-01-31</td><td>$0.34</td><td></td></tr><tr class><td>2006-10-04</td><td>2006-10-31</td><td>$0.34</td><td></td></tr><tr class><td>2006-07-03</td><td>2006-07-31</td><td>$0.34</td><td></td></tr><tr class><td>2006-04-04</td><td>2006-04-30</td><td>$0.34</td><td></td></tr><tr class><td>2006-01-04</td><td>2006-01-31</td><td>$0.34</td><td></td></tr><tr class><td>2005-10-04</td><td>2005-10-31</td><td>$0.34</td><td></td></tr><tr class><td>2005-07-01</td><td>2005-07-31</td><td>$0.34</td><td></td></tr><tr class><td>2005-04-04</td><td>2005-04-30</td><td>$0.34</td><td></td></tr><tr class><td>2005-01-04</td><td>2005-01-31</td><td>$0.34</td><td></td></tr><tr class><td>2004-10-04</td><td>2004-10-31</td><td>$0.34</td><td></td></tr><tr class><td>2004-07-01</td><td>2004-07-31</td><td>$0.34</td><td></td></tr><tr class><td>2004-04-02</td><td>2004-04-30</td><td>$0.34</td><td></td></tr><tr class><td>2004-01-02</td><td>2004-01-30</td><td>$0.34</td><td></td></tr><tr class><td>2003-10-02</td><td>2003-10-31</td><td>$0.34</td><td></td></tr><tr class><td>2003-07-01</td><td>2003-07-31</td><td>$0.34</td><td></td></tr><tr class><td>2003-04-02</td><td>2003-04-30</td><td>$0.34</td><td></td></tr><tr class><td>2003-01-02</td><td>2003-01-31</td><td>$0.34</td><td></td></tr><tr class><td>2002-10-02</td><td>2002-10-31</td><td>$0.34</td><td></td></tr><tr class><td>2002-07-02</td><td>2002-07-31</td><td>$0.34</td><td></td></tr><tr class><td>2002-04-03</td><td>2002-04-26</td><td>$0.34</td><td></td></tr><tr class><td>2002-01-02</td><td>2002-01-31</td><td>$0.34</td><td></td></tr><tr class><td>2001-10-03</td><td>2001-10-31</td><td>$0.34</td><td></td></tr><tr class><td>2001-07-03</td><td>2001-07-31</td><td>$0.34</td><td></td></tr><tr class><td>2001-04-04</td><td>2001-05-31</td><td>$0.34</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>6.25%</span></td></tr><tr class><td>2001-01-03</td><td>2001-01-31</td><td>$0.32</td><td></td></tr><tr class><td>2000-10-04</td><td>2000-10-31</td><td>$0.32</td><td><span class="percent-change percent-decrease"><i class="bi bi-arrow-down-circle-fill me-1" role="img" aria-label="Dividend Decrease"></i>-68%</span></td></tr><tr class><td>2000-09-21</td><td>2000-10-13</td><td>$1.00</td><td></td></tr><tr class><td>2000-07-03</td><td>2000-07-31</td><td>$0.32</td><td></td></tr><tr class><td>2000-04-04</td><td>2000-05-31</td><td>$0.32</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>17.07%</span></td></tr><tr class><td>2000-01-04</td><td>2000-01-31</td><td>$0.27333</td><td></td></tr><tr class><td>1999-10-04</td><td>1999-10-29</td><td>$0.27333</td><td></td></tr><tr class><td>1999-07-01</td><td>1999-07-30</td><td>$0.27333</td><td></td></tr><tr class><td>1999-04-01</td><td>1999-04-27</td><td>$0.27333</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>13.89%</span></td></tr><tr class><td>1999-01-04</td><td>1999-01-29</td><td>$0.24</td><td></td></tr><tr class><td>1998-10-02</td><td>1998-10-30</td><td>$0.24</td><td></td></tr><tr class><td>1998-07-01</td><td>1998-07-31</td><td>$0.24</td><td></td></tr><tr class><td>1998-04-02</td><td>1998-04-27</td><td>$0.24</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>16.13%</span></td></tr><tr class><td>1998-01-02</td><td>1998-01-30</td><td>$0.20667</td><td></td></tr><tr class><td>1997-10-02</td><td>1997-10-31</td><td>$0.20667</td><td></td></tr><tr class><td>1997-07-01</td><td>1997-07-31</td><td>$0.20667</td><td></td></tr><tr class><td>1997-04-02</td><td>1997-04-28</td><td>$0.20667</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>10.71%</span></td></tr><tr class><td>1997-01-02</td><td>1997-01-31</td><td>$0.18667</td><td></td></tr><tr class><td>1996-10-02</td><td>1996-10-31</td><td>$0.18667</td><td></td></tr><tr class><td>1996-07-02</td><td>1996-07-31</td><td>$0.18667</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>12%</span></td></tr><tr class><td>1996-01-03</td><td>1996-01-31</td><td>$0.16667</td><td></td></tr><tr class><td>1995-10-04</td><td>1995-10-31</td><td>$0.16667</td><td></td></tr><tr class><td>1995-07-03</td><td>1995-07-31</td><td>$0.16667</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>13.64%</span></td></tr><tr class><td>1995-03-31</td><td>1995-04-27</td><td>$0.14667</td><td></td></tr><tr class><td>1994-12-30</td><td>1995-01-31</td><td>$0.14667</td><td></td></tr><tr class><td>1994-09-30</td><td>1994-10-31</td><td>$0.14667</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>15.79%</span></td></tr><tr class><td>1994-06-29</td><td>1994-07-29</td><td>$0.12667</td><td></td></tr><tr class><td>1994-03-30</td><td>1994-04-27</td><td>$0.12667</td><td></td></tr><tr class><td>1993-12-31</td><td>1994-01-31</td><td>$0.12667</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>15.15%</span></td></tr><tr class><td>1993-09-30</td><td>1993-10-29</td><td>$0.11</td><td></td></tr><tr class><td>1993-06-29</td><td>1993-07-30</td><td>$0.11</td><td></td></tr><tr class><td>1993-03-31</td><td>1993-04-27</td><td>$0.11</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>10%</span></td></tr><tr class><td>1992-12-30</td><td>1993-01-29</td><td>$0.10</td><td></td></tr><tr class><td>1992-09-30</td><td>1992-10-30</td><td>$0.10</td><td></td></tr><tr class><td>1992-06-29</td><td>1992-07-31</td><td>$0.10</td><td></td></tr><tr class><td>1992-03-31</td><td>1992-04-27</td><td>$0.10</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>20%</span></td></tr><tr class><td>1991-12-09</td><td>1992-01-31</td><td>$0.08333</td><td></td></tr><tr class><td>1991-09-09</td><td>1991-10-31</td><td>$0.08333</td><td></td></tr><tr class><td>1991-06-10</td><td>1991-07-31</td><td>$0.08333</td><td></td></tr><tr class><td>1991-03-11</td><td>1991-04-26</td><td>$0.08333</td><td></td></tr><tr class><td>1990-12-10</td><td>1991-01-31</td><td>$0.08333</td><td><span class="percent-change percent-decrease"><i class="bi bi-arrow-down-circle-fill me-1" role="img" aria-label="Dividend Decrease"></i>-63.24%</span></td></tr><tr class><td>1990-09-10</td><td>1990-10-31</td><td>$0.22667</td><td></td></tr><tr class><td>1990-06-11</td><td>1990-07-31</td><td>$0.22667</td><td></td></tr><tr class><td>1990-03-09</td><td>1990-04-27</td><td>$0.22667</td><td></td></tr><tr class><td>1989-12-11</td><td>1990-01-31</td><td>$0.22667</td><td></td></tr><tr class><td>1989-09-11</td><td>1989-10-31</td><td>$0.22667</td><td></td></tr><tr class><td>1989-06-09</td><td>1989-07-31</td><td>$0.22667</td><td></td></tr><tr class><td>1989-03-09</td><td>1989-04-27</td><td>$0.22667</td><td></td></tr><tr class><td>1988-12-09</td><td>1989-01-31</td><td>$0.22667</td><td></td></tr><tr class><td>1988-09-09</td><td>1988-10-31</td><td>$0.22667</td><td></td></tr><tr class><td>1988-06-09</td><td>1988-07-29</td><td>$0.22667</td><td></td></tr><tr class><td>1988-03-09</td><td>1988-04-27</td><td>$0.22667</td><td></td></tr><tr class><td>1987-12-09</td><td>1988-01-29</td><td>$0.22667</td><td></td></tr><tr class><td>1987-09-09</td><td>1987-10-30</td><td>$0.22667</td><td></td></tr><tr class><td>1987-06-09</td><td>1987-07-31</td><td>$0.22667</td><td></td></tr><tr class><td>1987-03-09</td><td>1987-04-27</td><td>$0.22667</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>4.62%</span></td></tr><tr class><td>1986-12-09</td><td>1987-01-30</td><td>$0.21667</td><td></td></tr><tr class><td>1986-09-09</td><td>1986-10-31</td><td>$0.21667</td><td></td></tr><tr class><td>1986-06-09</td><td>1986-07-31</td><td>$0.21667</td><td></td></tr><tr class><td>1986-03-10</td><td>1986-04-28</td><td>$0.21667</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>4.84%</span></td></tr><tr class><td>1985-12-09</td><td>1986-01-31</td><td>$0.20667</td><td></td></tr><tr class><td>1985-09-09</td><td>1985-10-31</td><td>$0.20667</td><td></td></tr><tr class><td>1985-06-10</td><td>1985-07-31</td><td>$0.20667</td><td></td></tr><tr class><td>1985-03-11</td><td>1985-04-26</td><td>$0.20667</td><td><span class="percent-change percent-increase"><i class="bi bi-arrow-up-circle-fill me-1" role="img" aria-label="Dividend Increase"></i>5.08%</span></td></tr><tr class><td>1984-12-10</td><td>1985-01-31</td><td>$0.19667</td><td></td></tr><tr class><td>1984-09-10</td><td>1984-10-31</td><td>$0.19667</td><td></td></tr><tr class><td>1984-06-11</td><td>1984-07-31</td><td>$0.19667</td><td></td></tr><tr class><td>1984-03-09</td><td>1984-04-27</td><td>$0.19667</td><td></td></tr></tbody></table></dividend-table><script type="module" src="/_astro/DividendTable.astro_astro_type_script_index_0_lang.DjvwEouV.js"></script> </div> <div class="col-md-2"> <p> <!-- <script is:inline async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-7749727118045578"
    crossorigin="anonymous"></script> --> <ins class="adsbygoogle" style="display:block" data-ad-client="ca-pub-7749727118045578" data-ad-slot="5310704540" data-ad-format="auto" data-full-width-responsive="true"></ins> <script>
        (adsbygoogle = window.adsbygoogle || []).push({});
    </script> <br> </p> <div class="hidden-xs hidden-sm" data-astro-cid-hgbsvna7><table class="table related-stocks-table" data-astro-cid-hgbsvna7><tr data-astro-cid-hgbsvna7><th data-astro-cid-hgbsvna7>Related Stocks</th></tr><tr data-astro-cid-hgbsvna7><td data-astro-cid-hgbsvna7><a href="/payout/BAC/" data-astro-cid-hgbsvna7>BAC&nbsp;Bank of America</a></td></tr><tr data-astro-cid-hgbsvna7><td data-astro-cid-hgbsvna7><a href="/payout/WFC/" data-astro-cid-hgbsvna7>WFC&nbsp;Wells Fargo</a></td></tr><tr data-astro-cid-hgbsvna7><td data-astro-cid-hgbsvna7><a href="/payout/HSBC/" data-astro-cid-hgbsvna7>HSBC&nbsp;HSBC Holdings plc.</a></td></tr><tr data-astro-cid-hgbsvna7><td data-astro-cid-hgbsvna7><a href="/payout/HDB/" data-astro-cid-hgbsvna7>HDB&nbsp;HDFC Bank Limited</a></td></tr><tr data-astro-cid-hgbsvna7><td data-astro-cid-hgbsvna7><a href="/payout/RY/" data-astro-cid-hgbsvna7>RY&nbsp;Royal Bank Of Canada [NYSE]</a></td></tr><tr data-astro-cid-hgbsvna7><td data-astro-cid-hgbsvna7><a href="/payout/C/" data-astro-cid-hgbsvna7>C&nbsp;Citigroup</a></td></tr><tr data-astro-cid-hgbsvna7><td data-astro-cid-hgbsvna7><a href="/payout/TD/" data-astro-cid-hgbsvna7>TD&nbsp;Toronto Dominion Bank [NYSE]</a></td></tr></table></div> <div class="hidden-xs hidden-sm" data-astro-cid-d77igchn> <table class="table top-search-table" data-astro-cid-d77igchn> <tr data-astro-cid-d77igchn> <th data-astro-cid-d77igchn>Top Searches (current)</th> </tr> <tr data-astro-cid-d77igchn> <td data-astro-cid-d77igchn><a href="/payout/tsx/CASH/" data-astro-cid-d77igchn>CASH Horizons High Interest Savings ETF</a></td> </tr> <tr data-astro-cid-d77igchn> <td data-astro-cid-d77igchn><a href="/payout/tsx/ENB/" data-astro-cid-d77igchn>ENB Enbridge</a></td> </tr> <tr data-astro-cid-d77igchn> <td data-astro-cid-d77igchn><a href="/payout/tsx/XEQT/" data-astro-cid-d77igchn>XEQT iShares Core Equity ETF Portfolio</a></td> </tr> <tr data-astro-cid-d77igchn> <td data-astro-cid-d77igchn><a href="/payout/tsx/VFV/" data-astro-cid-d77igchn>VFV Vanguard S&P 500 Index ETF</a></td> </tr> <tr data-astro-cid-d77igchn> <td data-astro-cid-d77igchn><a href="/payout/SCHD/" data-astro-cid-d77igchn>SCHD Schwab US Dividend Equity ETF</a></td> </tr> <tr data-astro-cid-d77igchn> <td data-astro-cid-d77igchn><a href="/payout/JEPI/" data-astro-cid-d77igchn>JEPI JPMorgan Equity Premium Income ETF</a></td> </tr> <tr data-astro-cid-d77igchn> <td data-astro-cid-d77igchn><a href="/payout/tsx/HMAX" data-astro-cid-d77igchn>HMAX Hamilton Canadian Financials Yield Maximizer ETF</a></td> </tr> </table> </div>  </div> </div>  <hr class="space"> <p>2012-2025 DividendHistory.org, All Rights Reserved | <a href="/privacy/">Privacy</a></p> </body></html>
'

o1 = new stzString(cHtml)
? o1.ContainsHtmlTable()
#--> TRUE

? o1.NumberOfHtmlTables()
#--> 3

o1.HtmlToDataTablesQRT(:stzListOfTables).Show()

pf()

/*---

pr()

str = '
    <table class="data" id="products">
        <thead>
            <tr>
                <th scope="col">Product</th>
                <th scope="col">Price</th>
                <th scope="col">Stock</th>
            </tr>
        </thead>
        <tbody>
            <tr class="row">
                <td>Apple</td>
                <td>$1.50</td>
                <td>100</td>
            </tr>
            <tr class="row">
                <td>Orange</td>
                <td>$1.20</td>
                <td>150</td>
            </tr>
            <tr class="row">
                <td>Banana</td>
                <td>$0.80</td>
                <td>200</td>
            </tr>
            <tr class="row">
                <td>Grape</td>
                <td>$2.00</td>
                <td>80</td>
            </tr>
            <tr class="row">
                <td>Mango</td>
                <td>$3.00</td>
                <td>50</td>
            </tr>
        </tbody>
    </table>
'

o1 = new stzString(str)

? o1.IsHtmlTable()
#--> TRUE

o1.HtmlToDataTableQRT(:stzTable).Show()
#-->
# ╭─────────┬───────┬───────╮
# │ Product │ Price │ Stock │
# ├─────────┼───────┼───────┤
# │ Apple   │ $1.50 │   100 │
# │ Orange  │ $1.20 │   150 │
# │ Banana  │ $0.80 │   200 │
# ╰─────────┴───────┴───────╯

pf()
# Executed in 0.10 second(s) in Ring 1.22

/*---

pr()

cHtml = '
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Product Overview</title>
</head>
<body>

    <h1>Product Overview</h1>

<h2>Current Inventory</h2>
<p>Below is the list of products currently available in our store. It includes prices and the quantity in stock:</p>

<table class="data" id="products-inventory">
    <thead>
        <tr>
            <th scope="col">Product</th>
            <th scope="col">Price</th>
            <th scope="col">Stock</th>
        </tr>
    </thead>
    <tbody>
        <tr class="row"><td>Apple</td><td>$1.50</td><td>100</td></tr>
        <tr class="row"><td>Orange</td><td>$1.20</td><td>150</td></tr>
        <tr class="row"><td>Banana</td><td>$0.80</td><td>200</td></tr>
        <tr class="row"><td>Grape</td><td>$2.00</td><td>80</td></tr>
        <tr class="row"><td>Mango</td><td>$3.00</td><td>50</td></tr>
    </tbody>
</table>

<p>As you can see, bananas are our top-stocked item, but mangoes are running low. Restocking will be necessary soon, especially for high-demand fruits.</p>

<h2>Incoming Shipments</h2>
<p>This next table shows the expected quantities from our upcoming delivery. These items will be added to inventory once received:</p>

<table class="data" id="products-incoming">
    <thead>
        <tr>
            <th scope="col">Product</th>
            <th scope="col">Incoming Quantity</th>
            <th scope="col">Expected Arrival</th>
        </tr>
    </thead>
    <tbody>
        <tr class="row"><td>Pineapple</td><td>60</td><td>2025-05-20</td></tr>
        <tr class="row"><td>Kiwi</td><td>120</td><td>2025-05-21</td></tr>
        <tr class="row"><td>Strawberry</td><td>90</td><td>2025-05-22</td></tr>
    </tbody>
</table>

<p>These fresh items will broaden our offering for the week ahead. Special promotions are planned once the shipment is confirmed.</p>

<h2>Top-Selling Products (Last 7 Days)</h2>
<p>Here is an overview of our best-sellers over the past week. These trends help guide procurement decisions:</p>

<table class="data" id="products-top-sellers">
    <thead>
        <tr>
            <th scope="col">Product</th>
            <th scope="col">Units Sold</th>
            <th scope="col">Revenue</th>
        </tr>
    </thead>
    <tbody>
        <tr class="row"><td>Banana</td><td>180</td><td>$144.00</td></tr>
        <tr class="row"><td>Apple</td><td>160</td><td>$240.00</td></tr>
        <tr class="row"><td>Orange</td><td>140</td><td>$168.00</td></tr>
    </tbody>
</table>

<p>Bananas continue to dominate sales, followed closely by apples. Increasing their stock could yield higher revenue next week.</p>

</body>
</html>
'

o1 = new stzString(cHtml)
? o1.ContainsHtmlTable()
#--> TRUE

? o1.NumberOfHtmlTables()
#--> 3

o1.HtmlToDataTablesQRT(:stzListOfTables).Show()
#-->
# ╭─────────┬───────┬───────╮
# │ Product │ Price │ Stock │
# ├─────────┼───────┼───────┤
# │ Apple   │ $1.50 │   100 │
# │ Orange  │ $1.20 │   150 │
# │ Banana  │ $0.80 │   200 │
# ╰─────────┴───────┴───────╯
# ╭────────────┬───────────────────┬──────────────────╮
# │  Product   │ Incoming Quantity │ Expected Arrival │
# ├────────────┼───────────────────┼──────────────────┤
# │ Pineapple  │                60 │ 2025-05-20       │
# │ Kiwi       │               120 │ 2025-05-21       │
# │ Strawberry │                90 │ 2025-05-22       │
# ╰────────────┴───────────────────┴──────────────────╯
# ╭─────────┬────────────┬─────────╮
# │ Product │ Units Sold │ Revenue │
# ├─────────┼────────────┼─────────┤
# │ Banana  │        180 │ $144.00 │
# │ Apple   │        160 │ $240.00 │
# │ Orange  │        140 │ $168.00 │
# ╰─────────┴────────────┴─────────╯

pf()
# Executed in 0.42 second(s) in Ring 1.22

/*--- stzString first and last non-space chars

pr()

o1 = new stzString("   RING  ")

? o1.FirstNonSpaceChar()		#--> R
? o1.FindFirstNonSpaceChar()	#--> 4

? o1.LastNonSpaceChar()		#--> G
? o1.FindLastNonSpaceChar()	#--> 7

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*=== JSON

pr()

aData = [
	[
		"product",
		[ "Apple", "Orange", "Banana" ]
	],
	[
		"price",
		[ "$1.50", "$1.20", "$0.80" ]
	],
	[
		"stock",
		[ "100", "150", "200" ]
	]
]

o1 = new stzTable(aData)
? o1.ToJsonXT()
'
{
	"product": [
		"Apple",
		"Orange",
		"Banana"
	],
	"price": [
		"$1.50",
		"$1.20",
		"$0.80"
	],
	"stock": [
		"100",
		"150",
		"200"
	]
}
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*---

pr()

cJson = '{
	"product": [
		"Apple",
		"Orange",
		"Banana"
	],
	"price": [
		"$1.50",
		"$1.20",
		"$0.80"
	],
	"stock": [
		"100",
		"150",
		"200"
	]
}'


? IsJson(cJson)
#--> TRUE


o1 = new stzTable([])
o1.FromJson(cJson)
o1.Show()
'
╭─────────┬───────┬───────╮
│ Product │ Price │ Stock │
├─────────┼───────┼───────┤
│ Apple   │ $1.50 │   100 │
│ Orange  │ $1.20 │   150 │
│ Banana  │ $0.80 │   200 │
╰─────────┴───────┴───────╯
'

pf()
# Executed in 0.06 second(s) in Ring 1.22

/*---

pr()

cHtmlStr = '
    <table class="data" id="products">
        <thead>
            <tr>
                <th scope="col">Product</th>
                <th scope="col">Price</th>
                <th scope="col">Stock</th>
            </tr>
        </thead>
        <tbody>
            <tr class="row">
                <td>Apple</td>
                <td>$1.50</td>
                <td>100</td>
            </tr>
            <tr class="row">
                <td>Orange</td>
                <td>$1.20</td>
                <td>150</td>
            </tr>
            <tr class="row">
                <td>Banana</td>
                <td>$0.80</td>
                <td>200</td>
            </tr>
            <tr class="row">
                <td>Grape</td>
                <td>$2.00</td>
                <td>80</td>
            </tr>
            <tr class="row">
                <td>Mango</td>
                <td>$3.00</td>
                <td>50</td>
            </tr>
        </tbody>
    </table>
'

? Q(cHtmlStr).IsHtmlTable()
#--> TRUE

o1 = new stzTable([])

o1.FromHtml(cHtmlStr)
o1.Show()
#-->
'
╭─────────┬───────┬───────╮
│ Product │ Price │ Stock │
├─────────┼───────┼───────┤
│ Apple   │ $1.50 │   100 │
│ Orange  │ $1.20 │   150 │
│ Banana  │ $0.80 │   200 │
╰─────────┴───────┴───────╯
'

? o1.ToJsonXT()
'
{
	"product": [
		"Apple",
		"Orange",
		"Banana"
	],
	"price": [
		"$1.50",
		"$1.20",
		"$0.80"
	],
	"stock": [
		"100",
		"150",
		"200"
	]
}
'

? @@NL( o1.Content() )

pf()
# Executed in 0.10 second(s) in Ring 1.22


/*---

pr()

aData = [
	[
		"product",
		[ "Apple", "Orange", "Banana" ]
	],
	[
		"price",
		[ "$1.50", "$1.20", "$0.80" ]
	],
	[
		"stock",
		[ "100", "150", "200" ]
	]
]

o1 = new stzTable(aData)
? o1.ToHtmlXT() # Without XT you get a compact versio of the html string
#-->
'
<table class="data" id="products">
<thead>

<tr>
            <th scope="col">product</th>
            <th scope="col">price</th>
            <th scope="col">stock</th>
</tr>

</thead>

<tbody>

<tr class="row">
        <td>Apple</td>
        <td>$1.50</td>
        <td>100</td>

</tr>

<tr class="row">
        <td>Orange</td>
        <td>$1.20</td>
        <td>150</td>

</tr>

<tr class="row">
        <td>Banana</td>
        <td>$0.80</td>
        <td>200</td>

</tr>

</tbody>
</table>
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*==== TESTING CSV TABLES IN STZSTRING

pr()

cCSV = 'NATION;LANGUAGE;CAPITAL;CONTINENT
Tunisia;Arabic;Tunis;Africa
France;French;Paris;Europe
Egypt;English;Cairo;Africa
Belgium;French;Brussel;Europe
Yemen;Arabic;Sanaa;Asia'

o1 = new stzString(cCSV)

? o1.IsCSVTable()
#--> TRUE

o1.CSVToDataTableQRT(:stzTable).Show()
#-->
# ╭─────────┬──────────┬─────────┬───────────╮
# │ Nation  │ Language │ Capital │ Continent │
# ├─────────┼──────────┼─────────┼───────────┤
# │ Tunisia │ Arabic   │ Tunis   │ Africa    │
# │ France  │ French   │ Paris   │ Europe    │
# │ Egypt   │ English  │ Cairo   │ Africa    │
# │ Belgium │ French   │ Brussel │ Europe    │
# │ Yemen   │ Arabic   │ Sanaa   │ Asia      │
# ╰─────────┴──────────┴─────────┴───────────╯

pf()
# Executed in 0.32 second(s) in Ring 1.22

/*==== #tODO
pr()

? StzDateQ("27/08/2015").Month()


pf()

/*------- #ring

pr()

? @@( ring_trim("    ") )
#--> ""
	
pf()
# Executed in 0.02 second(s)

/*=============== #narration 5 ways to create a stzTable

pr()

# A table can be created in 6 different ways:

# WAY 1 : Creating an empty table with just a column and a row with just an empty cell
o1 = new stzTable([])

? @@( o1.Content() ) + NL
#--> [ [ "COL1", [ "" ] ] ]

o1.Show()
#--> COL1
#    ----
#     ""  

pf()
# Executed in 0.07 second(s)

/*--------------

pr()

# WAY 2 : Creating an empty table with 3 columns and 3 rows

o1 = new stzTable([3, 2])
o1.Show()
#-->
#   COL1   COL2   COL3
#     ""     ''     "'    
#     ""     ''     "'  

pf()
# Executed in 0.08 second(s)

/*---------------

pr()

# WAY 3: Creating a table by provding a list of lists, formatted as you
# would find it in the real world (the first line is for column names!)

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

o1.Show()
#-->
#   ID   EMPLOYEE   SALARY
#   --- ---------- -------
#   10        Ali    35000
#   20      Dania    28900
#   30        Han    25982
#   40        Ali    12870

pf()
# Executed in 0.08 second(s) in Ring 1.20
# Executed in 0.61 second(s) in Ring 1.17

/*---------------

pr()

# WAY 4: Creating a table by provding just the rows, without
# column names (they are added automatically by softanza):

o1 = new stzTable([
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

o1.Show()
#-->
#   COL1    COL2    COL3
#   ----- ------- ------
#     10     Ali   35000
#     20   Dania   28900
#     30     Han   25982
#     40     Ali   12870

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.61 second(s) in Ring 1.17

/*-----------------

pr()

# WAY 5: Creating a table by providing a hashtable where
# the column names are keys and rows are values
# (internally, stzTable content is hosted in this hashlist)

o1 = new stzTable([
 	:NAME   = [ "Ali", 	  "Dania", 	"Han" 	 ],
 	:JOB    = [ "Programmer", "Manager", 	"Doctor" ],
	:SALARY = [ 35000, 	  50000, 	62500    ]
])

o1.Show()
#-->  NAME          JOB   SALARY
#    ------ ------------ -------
#      Ali   Programmer    35000
#    Dania      Manager    50000
#      Han       Doctor    62500

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.47 second(s) in Ring 1.17

/*---------

# WAY 6: Creating a table from an external text file (EXPERIMENTAL)

#NOTE
# This example uses two files that exist in the default
# director: "myTable.csv" and "myHybridTable.txt"
# check them before you test the code.

pr()

# You can crate a table from an external data file.
# The file can be in CSV format or any other text file.
# Tha data inside the file must be separated by lines,
# and the lines must be separated by semicolons.

o1 = new stzTable(:FromFile = "mytable.csv")
? o1.ShowXT([ :RowNumber = TRUE ])
#-->
# ╭───┬─────────────────┬──────────┬─────────┬───────────╮
# │ # │     Nation      │ Language │ Capital │ Continent │
# ├───┼─────────────────┼──────────┼─────────┼───────────┤
# │ 1 │ Tunisia         │ Arabic   │ Tunis   │ Africa    │
# │ 2 │ France          │ French   │ Paris   │ Europe    │
# │ 3 │ Egypt           │ English  │ Cairo   │ Africa    │
# │ 4 │ Belgium         │ French   │ Brussel │ Europe    │
# │ 5 │ Yemen           │ Arabic   │ Sanaa   │ Asia      │
# ╰───┴─────────────────┴──────────┴─────────┴───────────╯

o2 = new stzTable(:FromFile = "myHybridTable.txt")
o2.ShowXT([ :RowNumber = TRUE ])
#-->
# ╭───┬─────────────────┬─────┬────────────────────────────────╮
# │ # │      Name       │ Age │            Hobbies             │
# ├───┼─────────────────┼─────┼────────────────────────────────┤
# │ 1 │ Hela            │  24 │ [ "Sport", "Music" ]           │
# │ 2 │ John             │  32 │ [ "Games", "Travel", "Sport" ] │
# │ 3 │ Ali             │  22 │ [ "Painting", "Dansing" ]      │
# │ 4 │ Foued           │  43 │ [ "Music", "Travel" ]          │
# ╰───┴─────────────────┴─────┴────────────────────────────────╯

#~> #NOTE that numbers and lists are evaluated and retutned as native types
#~> #NOTE lists in the text file must take the form ['str1','str2','str3']

pf()
# Executed in 0.64 second(s)

/*----------

pr()

#NOTE
# This example uses two files that exist in the default
# director: "mytable_emptyline.txt" and "mytable_line1_number"
# check them before you test the code.

# If the file begins with an empty line, then Softanza adds
# the names of columns automaticallys as :COL1, :COL2, etc

o1 = new stzTable(:FromFile = "mytable_emptyline.txt")

? o1.Show()

#-->    COL1      COL2      COL3     COL4
#    -------- --------- --------- -------
#    Tunisia    Arabic     Tunis   Africa
#     France    French     Paris   Europe
#      Egypt   English     Cairo   Africa
#    Belgium    French   Brussel   Europe
#      Yemen    Arabic     Sanaa     Asia

# Also, the first line is not empty but contains cells
# that are not strings (numbers or lists), then Softanza
# does the same (adds columns names)

o1 = new stzTable(:FromFile = "mytable_line1_number.txt")

? o1.Show()

#-->    COL1       COL2      COL3      COL4
#    -------- ---------- --------- --------
#     NATION   LANGUAGE       125   COUNTRY
#    Tunisia     Arabic     Tunis    Africa
#     France     French     Paris    Europe
#      Egypt    English     Cairo    Africa
#    Belgium     French   Brussel    Europe
#      Yemen     Arabic     Sanaa      Asia

pf()
# Executed in 0.46 second(s)

/*=================

pr()

StzTableQ([
	[ :M, :FUNCTION 	, :OBJECT ],

	[ ' ', 'Q'		, 'stzList' ],
	[ ' ', 'AreBothQ' 	, 'stzListOfStrings' ],
	[ '•', 'HavingQ'	, 'stzListOfStrings' ],
	[ ' ', 'AllTheirQ'	, 'stzListOfStrings' ]

# When we specify just the intersection char, Softanza
# add the values by default for the separator ("|")
# and the underline char ("-")

]).ShowXT([ :IntersectionChar = "+" ])

#-->
#  M |  FUNCTION |           OBJECT
#  --+-----------+-----------------
#    |         Q |          stzList
#    |  AreBothQ | stzListOfStrings
#  • |   HavingQ | stzListOfStrings
#    | AllTheirQ | stzListOfStrings

pf()
# Executed in 0.10 second(s)

/*--------------------

pr()

o1 = new stzTable([
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])
		
? o1.ColNames()
#--> [ "col1", "col2", "col3" ]

? o1.Row(2)
#--> [ 20, "Hatem", 46 ]

pf()
# Executed in 0.02 second(s)

/*--------------------

pr()

o1 = new stzTable([
	:COL1 = [ "I", 1 ],
	:COL2 = [ AHeart(), 2 ],
	:COL3 = [ "Ring", 3 ],
	:COL4 = [ "Language", 4 ]
])

? o1.ShowXT([
	:Separator 	  = "   ",
	:Alignment 	  = :Right,
		
	:UnderLineHeader  = TRUE,
	:UnderLineChar 	  = "-",
	:IntersectionChar = " ",
		
	:ShowRowNumbers   = FALSE
])

#--> COL1   COL2   COL3       COL4
#    ----- ------ ------ ---------
#       I      ♥   Ring   Language
#       1      2      3          4

pf()
# Executed in 0.10 second(s)

/*-------------------- #narration

pr()

o1 = new stzTable([
	:COL1 = [ "I", 1 ],
	:COL2 = [ AHeart(), 2 ],
	:COL3 = [ "Ring", 3 ],
	:COL4 = [ "Language", 4 ]
])

# By default, the colnames are underline using "-",
# with a separator, cells are adjusted to the right,
# and the row numbers are not showen

? o1.Show()

#--> COL1   COL2   COL3       COL4
#    ----- ------ ------ ---------
#       I      ♥   Ring   Language
#       1      2      3          4

# If you need a more sophisticated presentation,
# than you can use the extended form the the
# function, without speciying any options.

# In this case, Softanza uses in the backgound,
# the default values the options like this:
# - the colanmes are underlined using "-"
# - the cells are adjusted to the right
# - the colnames and the cells are separated by "|"
# - and the rows numbers are showen

? o1.ShowXT([])

#--> # | COL1 | COL2 | COL3 |     COL4
#    --+------+------+------+---------
#    1 |    I |    ♥ | Ring | Language
#    2 |    1 |    2 |    3 |        4

# If you deactivate the underlining of the header,
# and you do not specify any other option, all
# those options are deactivated

? o1.ShowXT([ :UnderlineHeader = FALSE ])
#--> COL1   COL2   COL3       COL4
#       I      ♥   Ring   Language
#       1      2      3          4

# And when you activate the underlining of
# the header, and don't set any other option,
# only the header is underlined using the
# default char "-"

? o1.ShowXT([ :UnderLineHeader = TRUE ])
#--> COL1   COL2   COL3       COL4
#    -----------------------------
#       I      ♥   Ring   Language
#       1      2      3          4

# But when you specify an intersection char,
# without specifying any other option, all
# the default options are used

o1.ShowXT([ :IntersectionChar = "+" ])
#--> COL1 | COL2 | COL3 |     COL4
#    -----+------+------+---------
#       I |    ♥ | Ring | Language
#       1 |    2 |    3 |        4

pf()
# Executed in 0.24 second(s)

/*--------------------

pr()

o1 = new stzTable([
	[ "I", 		1, 	11, 	111 ],
	[ AHeart(), 	2, 	22, 	222 ],
	[ "Ring", 	3, 	33, 	333 ],
	[ "Language", 	4, 	44, 	444 ]
])

o1.ShowXT([ :UnderLineHeader = TRUE, :InterSectionChar = "+" ])

#-->     COL1 | COL2 | COL3 | COL4
#    ---------+------+------+-----
#           I |    1 |   11 |  111
#           ♥ |    2 |   22 |  222
#        Ring |    3 |   33 |  333
#    Language |    4 |   44 |  444

pf()
# Executed in 0.12 second(s)

/*--------------------

pr()

o1 = new stzTable([
	:col1 = [ "I", 1 ],
	:col2 = [ AHeart(), 2 ],
	:Col3 = [ "Ring", 3 ],
	:Col4 = [ "Language", 4 ]
])

? o1.Show()
#-->
#	COL1   COL2   COL3       COL4
#	----- ------ ------ ---------
#	  I      ♥   Ring   Language
#	  1      2      3          4

pf()
# Executed in 0.12 second(s)

/*--------------------

pr()

o1 = new stzTable([ [ 10, "ten" ], [ 20, "twenty" ] ])
o1.Show()
#-->
#	COL1     COL2
#	----- -------
#	  10      ten
#	  20   twenty

pf()
# Executed in 0.07 second(s)

/*--------------------

pr()

o1 = new stzTable([
	[ "I", 1 ],
	[ AHeart(), 2 ],
	[ "Ring", 3 ],
	[ "Language", 4 ]
])

o1.ShowXT([ :UnderlineHeader = FALSE ])
#-->
# I   ♥   RING   LANGUAGE
# 1   2      3          4

pf()
# Executed in 0.08 second(s)

/*--------------------

pr()

o1 = new stzTable([
	[ "I", 1 ],
	[ AHeart(), 2 ],
	[ "Ring", 3 ],
	[ "Language", 4 ]
])

? o1.Rows()
#--> [ 1, 2, 3, 4 ]

pf()
# Executed in 0.02 second(s)

/*------

pr()

o1 = new stzList([ "A", "B", "C", "D", "E" ])
? @@( o1.FindMany([ "A", "B", "A", "B", "B" ]) )
#--> [ 1, 2 ]

o1.ReplaceManyByManyXT([ "A", "B", "A", "D", "E" ], :With = [ "1", "2"])
? @@( o1.Content() )
#--> [ "1", "2", "C", "1", "2" ]

pf()
# Executed in 0.02 second(s)

/*=============

pr()

o1 = new stzTable([
	[ :NAME, :AGE, :SCORE ],
	[ "sam", 24,   10     ],
	[ "dan", 36,   20     ],
	[ "tom", 43,   30     ]
])

o1.Show()
#-->
#	NAME   AGE   SCORE
#	----- ----- ------
#	 sam    24      10
#	 dan    36      20
#	 tom    43      30

? ""

? @@( o1.FindColsExcept([ :NAME, :SCORE ]) )
#--> [ 2 ]

? ""

o1.RemoveCol(2)
o1.Show()
#--> :NAME   :SCORE
#    ------ -------
#    sam       10
#    dan       20
#    tom       30

? ""

o1.RemoveCols([ 1, 2 ])
o1.Show() + NL

#--> COL1
#    ----
#      ""

pf()
# Executed in 0.13 second(s)

/*-------------

pr()

o1 = new stzTable([
	[ :NAME, :AGE, :SCORE ],
	[ "sam", 24,   10     ],
	[ "dan", 36,   20     ],
	[ "tom", 43,   30     ]
])

o1.RemoveCols([1, 2])
o1.Show()

#--> SCORE
#    -----
#       10
#       20
#       30

pf()
# Executed in 0.07 second(s)

/*-------------

pr()

o1 = new stzTable([
	[ :NAME, :AGE, :SCORE ],
	[ "sam", 24,   10     ],
	[ "dan", 36,   20     ],
	[ "tom", 43,   30     ]
])

o1.RemoveAll()
o1.Show()

#--> COL1
#    ----
#      ""

pf()
# Executed in 0.08 second(s)

/*=============

pr()

o1 = new stzTable([
	[ :COL1,    :COL2,    :COL3,	:COL4 ],
	#-------------------------------------#
	[ 10,	    "*",      100,	"*"   ],
	[ 20,	    "*",      200,	"*"   ],
	[ 30,	    "*",      300,	"*"   ]
])

? o1.FindColByName(:COL3) + NL
#--> 3

? o1.FindColsByName([ :COL2, :COL4 ])
#--> [ 2, 4 ]

? o1.FindColsByName([ :FirstCol, :LastCol ])
#--> [ 1, 4 ]

? o1.FindColsByName([ :FirstCol, :LastCol, :LastCol ])
#--> [ 1, 4 ]

#--

? o1.FindColByValue([ 100, 200, 300 ])
#--> [ 3 ]

? o1.FindColByValue([ "*", "*", "*" ])
#--> [ 2, 4 ]

? o1.FindColsByValue([
	[ 100, 200, 300 ],
	[ "*", "*", "*" ]
])
#--> [ 2, 3, 4 ]

? @@( o1.FindColsByValueExcept([
	[ "*", "*", "*" ],
	[ 10, 20, 30 ]
]) )
#--> [ 3 ]

pf()
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.17 second(s) in Ring 1.17

/*=============

pr()

o1 = new stzTable([
	[ :COL1,    :COL2,    :COL3 ],
	#----------------------------#
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ "*",	    "*",      "*"   ],
	[ 30,	    300,      3000  ],
	[ "*",	    "*",      "*"   ],
	[ "*",	    "*",      "*"   ]
])

? o1.FindRow([ 30, 300, 3000 ])
#--> [ 4 ]

? o1.FindRow([ "*", "*", "*" ])
#--> [ 3, 5, 6 ]

? o1.FindManyRows([
	[ 30, 300, 3000 ],
	[ "*", "*", "*" ]
])
#--> [ 3, 4, 5, 6 ]

? o1.FindRowsExcept([
	[ 30, 300, 3000 ],
	[ "*", "*", "*" ]
])
#--> [1, 2]

pf()
# Executed in 0.03 second(s)

/*-------------

pr()

o1 = new stzTable([
	[ :COL1,    :COL2,    :COL3 ],
	#----------------------------#
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ "*",	    "*",      "*"   ],
	[ 30,	    300,      3000  ]
])

o1.RemoveRow(3)

o1.Show()
#-->   COL1   COL2   COL3
#    ------ ------ ------
#       10     100   1000
#       20     200   2000
#       30     300   3000

pf()
# Executed in 0.09 second(s)

/*-------------

pr()

o1 = new stzTable([
	[ :COL1,    :COL2,    :COL3 ],
	#----------------------------#
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ "*",	    "*",      "*"   ],
	[ 30,	    300,      3000  ]
])

? o1.FindRow([ "*", "*", "*" ])
#--> [ 3 ]

o1.RemoveRow([ "*", "*", "*" ])

o1.Show()
#-->   COL1   COL2   COL3
#    ------ ------ ------
#       10     100   1000
#       20     200   2000
#       30     300   3000

pf()
# Executed in 0.12 second(s)

/*-------------

pr()

o1 = new stzTable([
	[ :COL1,    :COL2,    :COL3 ],
	#----------------------------#
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ "*",	    "*",      "*"   ],
	[ 30,	    300,      3000  ],
	[ "*",	    "*",      "*"   ],
	[ "*",	    "*",      "*"   ]
])

o1.RemoveRows([3, 5, 6])

o1.Show()

#-->   COL1    COL2   COL3
#    ------ ------- ------
#       10     100    1000
#       20     200    2000
#       30     300    3000

pf()
# Executed in 0.08 second(s)

/*-------------

pr()

o1 = new stzTable([
	[ :COL1,    :COL2,    :COL3 ],
	#----------------------------#
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ "*",	    "*",      "*"   ],
	[ 30,	    300,      3000  ],
	[ "*",	    "*",      "*"   ],
	[ "*",	    "*",      "*"   ]
])

? o1.FindRowsExceptAt([ 1, 2, 4 ])
#--> [ 3, 5, 6 ]

? o1.FindRowsExcept([
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ 30,	    300,      3000  ]
])
#--> [ 3, 5, 6 ]

#--

o1.RemoveAllRowsExcept([
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ 30,	    300,      3000  ]
]) # Or RemoveRowsOtherThan()

o1.Show()
#-->  COL1    COL2   COL3
#    ------ ------- ------
#       10     100    1000
#       20     200    2000
#       30     300    3000

pf()
# # Executed in 0.10 second(s)

/*============ A Softanza #narration showing one of the uses of the XT()

pr()

# You create a table with this structure:

o1 = new stzTable([
	[ :COL1,    :COL2,    :COL3 ],
	#----------------------------#
	[ 10,	    100,      1000  ],
	[ 20,	    200,      2000  ],
	[ "*",	    "*",      "*"   ],
	[ 30,	    300,      3000  ]
])

# And you want to show it on screen:

? o1.Show() + NL

#-->  COL1    COL2   COL3
#    ------ ------- ------
#       10     100    1000
#       20     200    2000
#        *       *       *
#       30     300    3000

# That's fine! But you may want a more elaborated formatting!
# Use the XT() extension:

? o1.ShowXT([]) + NL

#--> # | COL1 | COL2 | COL3
#    --+------+------+-----
#    1 |   10 |  100 | 1000
#    2 |   20 |  200 | 2000
#    3 |    * |    * |    *
#    4 |   30 |  300 | 3000

# You can even even set the options at your will...

? o1.ShowXT([
	:Separator 	  = " | ",
	:Alignment 	  = :Center,

	:UnderLineHeader  = TRUE,
	:UnderLineChar 	  = "-",
	:IntersectionChar = "+",

	:ShowRowNumbers   = TRUE
])

#--> # | COL1 | COL2 | COL3
#    --+------+------+-----
#    1 |  10  | 100  | 1000
#    2 |  20  | 200  | 2000
#    3 |  *   |  *   |  *  
#    4 |  30  | 300  | 3000

pf()
# Executed in 0.20 seconds(s) in Ring 1.20
# Executed in 1.09 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([3, 4])
? o1.Show()
#-->  COL1   COL2   COL3
#     ----- ------ -----
#       ""     ""    '"
#       ""     ""    '"
#       ""     ""    '"
#       ""     ""    '"

pf()
# Executed in 0.12 second(s)

/*==========

pr()

# Special syntax to enable the SQL syntax in Ring

o1 = new stzTable([])
? IsStzObject(o1)
#--> TRUE

o1.@([
	:COL2 = :INT,
	:COL3 = VARCHAR(30)
])

o1.Show()
#--> 	COL2   COL3
#	----- -----
#	  ""     ''   

pf()
# Executed in 0.08 second(s)

/*--------------

StartProfiler()

o1 = new stzList([ "ONE", "two", "THREE", 1, 2 ])
? o1.ContainsCS("TwO", :CS=FALSE)
#--> TRUE

StopProfiler()
#--> Executed in 0.02 second(s)

/*--------------

StartProfiler()

	o1 = new stzTable([
		[ :ID,	 :EMPLOYEE,    	:SALARY	],
		#-------------------------------#
		[ 10,	 "Ali",		35000	],
		[ 20,	 "Dania",	28900	],
		[ 30,	 "Han",		25982	],
		[ 40,	 "Ali",		12870	]
	])

	? o1.Show()
	#--> ID   EMPLOYEE   SALARY
	#    --- ---------- -------
	#    10        Ali    35000
	#    20      Dania    28900
	#    30        Han    25982
	#    40        Ali    12870

	? o1.NthColName(:LastCol) + NL
	#--> :SALARY

	? @@( o1.CellsInColsAsPositions([ :EMPLOYEE, :SALARY ]) ) + NL
	#--> [
	# 	[ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 2, 4 ],
	# 	[ 3, 1 ], [ 3, 2 ], [ 3, 3 ], [ 3, 4 ]
	# ]

	? o1.CellsToHashList()["[ 3, 4 ]"] + NL
	#--> 12870

	? @@( o1.SectionAsPositions([2,2], [3, 4]) )
	#--> [ [ 2, 2 ], [ 3, 2 ], [ 2, 3 ], [ 3, 3 ], [ 2, 4 ], [ 3, 4 ] ]

StopProfiler()
# Executed in 0.11 second(s) in Ring 1.20
# Executed in 1.56 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([
	[ "NAME", "AGE", "RANGE" ],
	[ "Sam",    42,      2   ],
	[ "Dan",    24,    "_"   ],
	[ "Alex",   34,      3   ]
])

? o1.Cell(3, 2) + NL
#--> "_"

o1.ReplaceCell(3, 2, 1)

o1.Show()
#--> NAME   AGE   RANGE
#    ----- ----- ------
#     Sam    42       2
#     Dan    24       1
#    Alex    34       3

pf()
# Executed in 0.09 second(s)

/*--------------

StartProfiler()

o1 = new stzTable([3, 3])

o1.Fill( :With = "." )
? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       .      .      .
#       .      .      .

o1.ReplaceRow(2, :With = [ "+", "+" ])
? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       +      +      .
#       .      .      .

o1.ReplaceRow(2, :With = [ "+", "+", "+" ])
? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       +      +      +
#       .      .      .

o1.ReplaceRow(2, :With = [ "+", "+", "+", "+", "+" ])
o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       +      +      +
#       .      .      .

StopProfiler()
# Executed in 0.22 second(s) in Ring 1.20
# Executed in 1.89 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([3, 3])

o1.Fill( :With = "." )

? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       .      .      .
#       .      .      .

o1.ReplaceAllRows(:With = [ "+", "+", "+" ])

o1.Show()
#--> COL1   COL2   COL3
#   ----- ------ -----
#      +      +      +
#      +      +      +
#      +      +      +

pf()
# Executed in 0.13 second(s) in Ring 1.20
# Executed in 0.98 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([2, 3])

o1.Fill( :With = "." )

? o1.Show()
#--> COL1   COL2
#    ----- -----
#      .      .
#      .      .
#      .      .

o1.ReplaceCol(:COL2, :With = [ "+", "+" ])
? o1.Show()
#--> COL1   COL2
#    ----- -----
#       .      +
#       .      +
#       .      .

o1.ReplaceCol(:COL2, :With = [ "+", "+", "+" ]) + NL
? o1.Show()
#--> COL1   COL2
#    ----- -----
#       .      +
#       .      +
#       .      +

o1.ReplaceCol(:COL2, :With = [ "+", "+", "+", "+", "+" ])
? o1.Show()
#--> COL1   COL2
#    ----- -----
#       .      +
#       .      +
#       .      +

pf()
# Executed in 0.18 second(s) in Ring 1.20
# Executed in 1.31 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([3, 3])

o1.Fill( :With = "." )

? o1.Show() + NL
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       .      .      .
#       .      .      .

o1.ReplaceAllCols(:With = [ "A", "B", "C" ])
o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       A      A      A
#       B      B      B
#       C      C      C

pf()
# Executed in 0.14 second(s) in Ring 1.20
# Executed in 1.02 second(s) in Ring 1.1è

/*----------------

pr()

o1 = new stzTable([3, 3])

o1.Fill( :With = "." )
? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       .      .      .
#       .      .      .

o1.Fill( :WithRow = [ "A", "B" ] )
o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       A      B      .
#       A      B      .
#       A      B      .

pf()
# Executed in 0.14 second(s) in Ring 1.20
# Executed in 1.09 second(s) in Ring 1.17

/*----------------

pr()

? Q([
	[ "COL1", [ "A", "B", "C" ] ],
	[ "COL2", [ "a", "b", "c" ] ],
	[ "COL3", [ "1", "2", "3" ] ]
]).IsHashList()
#--> TRUE

pf()
# Executed in 0.02 second(s)

/*----------------

pr()

o1 = new stzTable([
	[ "COL1", [ "A", "B", "C" ] ],
	[ "COL2", [ "a", "b", "c" ] ],
	[ "COL3", [ "1", "2", "3" ] ]
])

o1.Show()
#-->
#   COL1   COL2   COL3
#   ----- ------ -----
#      A      a      1
#      B      b      2
#      C      c      3

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.54 second(s) in Ring 1.17

/*----------------

pr()

? @@NL( StzTableQ([ 3, 3 ]).Filled(:With = "A") )
#--> [
#	[ "COL1", [ "A", "A", "A" ] ],
#	[ "COL2", [ "A", "A", "A" ] ],
#	[ "COL3", [ "A", "A", "A" ] ]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.09 second(s) in Ring 1.17

/*----------------

pr()

o1 = StzTableQ([ 3, 3 ]) { Fill(:With = "A") }
o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       A      A      A
#       A      A      A
#       A      A      A

pf()
# Executed in 0.10 second(s) in Ring 1.20
# Executed in 0.48 second(s) in Ring 1.17

/*----------------

pr()

o1 = new stzTable([3, 3])

o1.Fill( :With = "." )

? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       .      .      .
#       .      .      .
#       .      .      .

o1.Fill( :WithCol = [ "A", "B" ] )

? o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       A      A      A
#       B      B      B
#       .      .      .

o1.Fill( :WithCol = [ "A", "B", "C" ] )

o1.Show()
#--> COL1   COL2   COL3
#    ----- ------ -----
#       A      A      A
#       B      B      B
#       C      C      C

pf()
# Executed in 0.29 second(s) in Ring 1.20
# Executed in 1.58 second(s) in Ring 1.19

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.ReplaceRow(3, :With = [ 50, "NONE", 99 ])
? o1.Row(3)
#--> [ 50, "NONE", 99 ]

o1.ReplaceCol(:AGE, :With = [ "_", "_", "_" ])
? o1.Col(:AGE)
#--> [ "_", "_", "_" ]

pf()
# Executed in 0.04 second(s) in Ring 1.19
# Executed in 0.15 second(s) in Ring 1.17

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

? o1.ColName(3)
#--> :AGE

? o1.ColName(:NAME) + NL
#--> :NAME

o1.ReplaceColName(:NAME, :EMPLOYEE)

o1.Show()
#-->
#    ID    EMPLOYEE  AGE
#    --- ---------- ----
#    10     Karim     52
#    20     Hatem     46
#    30   Abraham     48

pf()
# Executed in 0.10 second(s) in Ring 1.20
# Executed in 0.48 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

? o1.ColNumber(:AGE) 
#--> 3

? o1.ColNumber(2)
#--> 2

? o1.ColNumber(:NONE)
#--> Error message:
# 	Incorrect param value! p must be a number or string.
# 	Allowed strings are :First, :FirstCol, :Last,
# 	:LastCol and any valid column name.

? o1.ColNumber(22)
#--> Error message:
# 	Incorrect value! n must be a number between 1 and 3.

pf()
# Executed in 0.02 second(s)

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.MoveRow( :From = 3, :To = 1 )

o1.Show()
#-->
#   ID      NAME   AGE
#   --- --------- ----
#   30   Abraham    48
#   20     Hatem    46
#   10     Karim    52

pf()
# Executed in 0.14 second(s)

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.SwapRows( :BetweenPositions = 2, :And = 3 )

? o1.Show()
#-->
#   ID      NAME   AGE
#   --- --------- ----
#   10     Karim    52
#   30   Abraham    48
#   20     Hatem    46

o1.SwapColumns( :BetweenPosition = 2, :And = 3 )

o1.Show()
#-->
#  ID   AGE      NAME
#  --- ----- --------
#  10    52     Karim
#  30    48   Abraham
#  20    46     Hatem

pf()
# Executed in 0.30 second(s)
# Executed in 1.05 second(s)

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.MoveCol( :ID, :ToPosition = 3 )
# or alternatively: o1.MoveCol( :FromPosition = 1, :To = 3 )

o1.Show()
#-->
#  AGE      NAME   ID
#  ---- --------- ---
#   52     Karim   10
#   46     Hatem   20
#   48   Abraham   30

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.48 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.AddCol( :AGE = [ 1, 2, 3 ] )
#--> Error message:
# 	Can't add the column! The name your provided already exists.

pf()

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.SwapColums( :AGE, :And = :NAME )

o1.Show()
#-->
#   ID   AGE      NAME
#   --- ----- --------
#   10    52     Karim
#   20    46     Hatem
#   30    48   Abraham

pf()
# Executed in 0.13 second(s) in Ring 1.20
# Executed in 0.71 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.ReplaceColName( :NAME, :FRIEND )
? o1.ColName(2)
#--> :FRIEND

pf()
# Executed in 0.02 second(s)

/*=============== #narration #flexibility

pr()

# Softanza is so flexible! Let's see it in action, for example,
# in using ReplaceCol(). Suppose you have a table like this:

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

# And you want to replace the column :AGE like this:

o1.ReplaceCol( :AGE, :By = [ 22, 20, 21 ] )

# The column is changed:

? o1.Col(:AGE)
#--> [ 22, 20, 21 ]

# Now, if you want to change just the name of the column, then
# pass the name instead of the list of values, like this:

o1.ReplaceCol( :AGE, :By = :LENGTH )

# then the name is changed:

? o1.ColName(3)
#--> :LENGTH

# Of course, you could use this specific function:

o1.ReplaceColName( :LENGTH, :By = :AGE )

# and the age turns back to its original name

? o1.ColName(3) + NL
#--> :AGE

? o1.Show()
#--> ID      NAME   AGE
#    --- --------- ----
#    10     Karim    22
#    20     Hatem    20
#    30   Abraham    21

# You can even use a number of column as a second parameter:

o1.ReplaceCol( :AGE, :ByColNumber = 1 )

o1.Show()
#--> ID      NAME   AGE
#    --- --------- ----
#    10     Karim    10
#    20     Hatem    20
#    30   Abraham    30

pf()
# Executed in 0.15 second(s)

/*==============

StartProfiler()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.SortDown()

? o1.Show()
#--> ID      NAME   AGE
#    --- --------- ----
#    30   Abraham    48
#    20     Hatem    46
#    10     Karim    52

o1.Sort()

? o1.Show()
#--> ID      NAME   AGE
#    --- --------- ----
#    10     Karim    52
#    20     Hatem    46
#    30   Abraham    48

o1.SortOn(:AGE)

? o1.Show()
#--> ID      NAME   AGE
#    --- --------- ----
#    20     Hatem    46
#    30   Abraham    48
#    10     Karim    52

o1.SortOnDown(:AGE)

o1.Show()
#--> ID      NAME   AGE
#    --- --------- ----
#    10     Karim    52
#    30   Abraham    48
#    20     Hatem    46

StopProfiler()
# Executed in 0.41 second(s)

/*--------

pr()

o1 = new stzListOfLists([
	[ 10, "Abdelkarim", 52 ],
	[ 20, "Hatem", 46 ],
	[ 30, "Abraham", 48 ]
])

o1.SortOnBy(2, "len(@item)")

? @@NL( o1.Content() )
#--> [
#	[ 20, "Hatem", 46 ],
#	[ 30, "Abraham", 48 ],
#	[ 10, "Abdelkarim", 52 ]
# ]

pf()
# Executed in 0.04 second(s)

/*---------

StartProfiler()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Abdelkarim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

o1.SortOnBy(:NAME, 'len(@cell)')

? o1.Show()
#--> ID         NAME   AGE
#    --- ------------ ----
#    20        Hatem    46
#    30      Abraham    48
#    10   Abdelkarim    52

o1.SortOnByDown(:NAME, 'len(@cell)')
? o1.Show()
#--> ID         NAME   AGE
#    --- ------------ ----
#    10   Abdelkarim    52
#    30      Abraham    48
#    20        Hatem    46

o1.SortOn(:AGE)
? o1.Show()
#--> ID         NAME   AGE
#    --- ------------ ----
#    20        Hatem    46
#    30      Abraham    48
#    10   Abdelkarim    52

o1.SortOnDown(:AGE)
o1.Show()
#--> ID         NAME   AGE
#    --- ------------ ----
#    10   Abdelkarim    52
#    30      Abraham    48
#    20        Hatem    46

StopProfiler()
# Executed in 0.40 second(s)

/*-------------

pr()

o1 = new stzTable([
	[  "COL1",   "COL2" ],
	#-------------------#
	[     "a",    "R1"  ],
	[ "abcde",    "R5"  ],
	[   "abc",    "R3"  ],
	[    "ab",    "R2"  ],
	[     "b",    "R1"  ],
	[   "abcd",   "R4"  ]
])

o1.SortOn(:COL2)

? o1.Show() + NL
#--> COL1   COL2
#   ------ -----
#       a     R1
#       b     R1
#      ab     R2
#     abc     R3
#    abcd     R4
#   abcde     R5

o1.SortOnDown(:COL2)

o1.Show()
#--> COL1   COL2
#   ------ -----
#   abcde     R5
#    abcd     R4
#     abc     R3
#      ab     R2
#       b     R1
#       a     R1

pf()
# Executed in 0.29 second(s)

/*===========

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],

	[ 10,	"Karim",	52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Abraham",	48	]
])

? @@( o1.ColAsPositions(:NAME) ) + NL
#--> [ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ] ]

? @@( o1.ColsAsPositions([ :NAME, :AGE ]) ) + NL
#--> [ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 3, 1 ], [ 3, 2 ], [ 3, 3 ] ]

? @@( o1.RowAsPositions(3) ) + NL
#--> [ [ 1, 3 ], [ 2, 3 ], [ 3, 3 ] ]

? @@( o1.RowsAsPositions([2, 3]) ) + NL
#--> [ [ 1, 2 ], [ 2, 2 ], [ 3, 2 ], [ 1, 3 ], [ 2, 3 ], [ 3, 3 ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.13 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([
	[  "COL1",   "COL2" ],
	#-------------------#
	[     "a",    "R1"  ],
	[ "abcde",    "R5"  ],
	[   "abc",    "R3"  ],
	[    "ab",    "R2"  ],
	[     "b",    "R1"  ],
	[   "abcd",   "R4"  ]
])

? @@( o1.CellsInCols([:COL1, :COL2]) ) + NL
#--> [
#	"a", "abcde", "abc", "ab", "b", "abcd",
#	"R1", "R5", "R3", "R2", "R1", "R4"
# ]

? @@( o1.CellsInRows([1, 3, 5]) )
#--> [ "a", "R1", "abc", "R3", "b", "R1" ]

pf()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.21 second(s) in Ring 1.17

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? o1.ContainsCol( :NAME = [ "Imed", "Hatem", "Karim" ] )
#--> TRUE

? o1.ContainsCols([
	:NAME = [ "Imed", "Hatem", "Karim" ],
	:AGE  = [ 52, 46, 48 ]
])
#--> TRUE

? o1.ContainsRow([ 20, "Hatem", 46 ])
#--> TRUE

? o1.ContainsRows([
	[ 20, "Hatem", 46 ],
	[ 30, "Karim", 48 ]
])
#--> TRUE

pf()
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.33 second(s) in Ring 1.17

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.SectionAsPositions([2, 2], [3, 3]) ) + NL # Or FindSections()
#--> [ [ 2, 2 ], [ 2, 3 ], [ 3, 1 ], [ 3, 2 ], [ 3, 3 ] ]

? @@(o1.Section([2, 2], [3, 3])) + NL
#--> [ "Hatem", "Karim", 52, 46, 48 ]

? @@NL(o1.SectionZ([2, 2], [3, 3])) + NL # or SectionAndPosiition()
#--> [
#	[ [ 2, 2 ], "Hatem" ],
#	[ [ 2, 3 ], "Karim" ],
#	[ [ 3, 1 ], 52 ],
#	[ [ 3, 2 ], 46 ],
#	[ [ 3, 3 ], 48 ]
# ]

? @@( o1.Section(:FirstCell, :LastCell) )
#--> [ 10, 20, 30, "Imed", "Hatem", "Karim", 52, 46, 48 ]

pf()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.15 second(s) in Ring 1.17

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.Cells() ) + NL
#--> [ 10, 20, 30, "Imed", "Hatem", "Karim", 52, 46, 48 ]

? @@NL( o1.CellsAndPositions() ) + NL # Same as CellsZ()
#--> [
#	[ 10, 		[ 1, 1 ] ],
#	[ "Imed", 	[ 2, 1 ] ],
#	[ 52, 		[ 3, 1 ] ],
#	[ 20, 		[ 1, 2 ] ],
#	[ "Hatem", 	[ 2, 2 ] ],
#	[ 46, 		[ 3, 2 ] ],
#	[ 30, 		[ 1, 3 ] ],
#	[ "Karim", 	[ 2, 3 ] ],
#	[ 48, 		[ 3, 3 ] ]
# ]

? @@NL( o1.PositionsAndCells() ) + NL
#--> [
#	[ [ 1, 1 ],	10	 ],
#	[ [ 2, 1 ],	"Imed"	 ],
#	[ [ 3, 1 ],	52	 ],
#	[ [ 1, 2 ],	20	 ],
#	[ [ 2, 2 ],	"Hatem"	 ],
#	[ [ 3, 2 ],	46	 ],
#	[ [ 1, 3 ],	30	 ],
#	[ [ 2, 3 ],	"Karim"	 ],
#	[ [ 3, 3 ],	48	 ]
# ]

? @@( o1.CellsToHashList() ) + NL # (used internally by Softanza)
#--> [
#	"[ 1, 1 ]" = 10,
#	"[ 2, 1 ]" = "Imed",
#	"[ 3, 1 ]" = 52,
#	"[ 1, 2 ]" = 20,
#	"[ 2, 2 ]" = "Hatem",
#	"[ 3, 2 ]" = 46,
#	"[ 1, 3 ]" = 30,
#	"[ 2, 3 ]" = "Karim",
#	"[ 3, 3 ]" = 48
# ]

? @@( o1.SectionToHashList([2, 2], [3, 3]) ) # (idem)
#--> [
#	[ "[ 2, 2 ]", "Hatem" ],
#	[ "[ 3, 2 ]", 46 ],
#	[ "[ 2, 3 ]", "Karim" ],
#	[ "[ 3, 3 ]", 48 ]
# ]

pf()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.36 second(s) in Ring 1.17

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? o1.NumberOfColumns()
#--> 3

? o1.HasCol(:NAME) + NL
#--> TRUE

? o1.ColNames()
#--> [ "id", "name", "age" ]

? o1.ColName(2)
#--> "name"

pf()
# Executed in 0.02 second(s)

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.Cell(2, 2) )
#--> "Hatem"

? o1.Cell(:EMPLOYEE, 2)
#--> Error message:
#   Syntax error in (employee)! This column name is inexistant.

? o1.Cell(5, 7 )
#--> Error message:
#    Incorrect value! n must correspond to a valid number of column. 

pf()
# Executed in 0.02 second(s)

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? o1.NumberOfRows()
#--> 3

? o1.NumberOfCols()
#--> 3

? o1.NumberOfCells()
#--> 12

pf()
# Executed in 0.02 second(s)

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.Header() ) + NL
#--> [ "id", "name", "age" ]

pf()
# Executed in 0.02 second(s)

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME 	],
	[ 10,	"Imed" 	],
	[ 20,	"Hatem" ],
	[ 30,	"Karim" ]
])

o1.AddCol(:AGE = [ 55, 35, 28 ])
? @@NL( o1.Content() )
#--> [
#	[ "id", 	[ 10, 20, 30 ] 			],
#	[ "name", 	[ "Imed", "Hatem", "Karim" ] 	],
#	[ "age", 	[ 55, 35, 28 ] 			]
# ]

pf()
# Executed in 0.02 second(s)

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME 	],
	#---------------#
	[ NULL,	NULL 	],
	[ NULL,	NULL 	],
	[ NULL,	NULL 	]
])

// A table is empty when all its cells are NULL

? o1.IsEmpty()
#--> TRUE

pf()
# Executed in 0.02 second(s)

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.NthCol(3) )
#--> [ 52, 46, 48 ]

pf()
# Executed in 0.02 second(s)

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.FirstColXT() ) + NL
#--> [ "id", 10, 20, 30 ]

? @@( o1.LastColXT() )
#-->[ "age", 52, 46, 48 ]

pf()
# Executed in 0.02 second(s)

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.Row(2) ) + NL
#--> [ 20, "Hatem", 46 ]

? @@NL( o1.Rows() )
#-->
# [
#	[ 10, "Imed",	52 ],
#	[ 20, "Hatem", 	46 ],
#	[ 30, "Karim",	48 ]
# ]

pf()
# Executed in 0.02 second(s)

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

o1.AddCol( :JOB = [ "Pilot", "Designer", "Author" ] )
? o1.Show()

#--> ID    NAME   AGE        JOB
#    --- ------- ----- ---------
#    10    Imed    52      Pilot
#    20   Hatem    46   Designer
#    30   Karim    48     Author

o1.RemoveCol(:JOB)
o1.Show()
#--> ID    NAME   AGE
#    --- ------- ----
#    10    Imed    52
#    20   Hatem    46
#    30   Karim    48

pf()
# Executed in 0.13 second(s)

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

o1.AddCol( :JOB = [ "Pilot", "Designer", "Author", "thing", "bye" ] )
? o1.Shwo() # NOTE this is misspelled!

#--> ID    NAME   AGE        JOB
#    --- ------- ----- ---------
#    10    Imed    52      Pilot
#    20   Hatem    46   Designer
#    30   Karim    48     Author

o1.AddCol( :NATION = [ "Tunisia", "Egypt" ] )
o1.Show()
#--> ID    NAME   AGE        JOB    NATION
#    --- ------- ----- ---------- --------
#    10    Imed    52      Pilot   Tunisia
#    20   Hatem    46   Designer     Egypt
#    30   Karim    48     Author        ""

pf()
# Executed in 0.18 second(s)

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

o1.RemoveCols([ :ID, :AGE ])

? @@( o1.Content() )
#--> [ [ "name", [ "Imed", "Hatem", "Karim" ] ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.16 second(s) in Ring 1.17

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.ColNames() ) + NL
#--> [ "id", "name", "age" ]

? @@NL( o1.Cols() ) # Or ColsData()
#--> [
#	[ 10, 20, 30 ],
#	[ "Imed", "Hatem", "Karim" ],
#	[ 52, 46, 48 ]
# ]
 
pf()
# Executed in 0.02 second(s)

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])


? @@( o1.Col(3) ) # Same as  o1.ColData(3), o1.Col(:AGE), and o1.ColData(:AGE)
#--> [ 52, 46, 48 ]

? o1.ColName(3)
#--> age

pf()
# Executed in 0.02 second(s)

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])


? @@NL( o1.TheseColumnsXT([ :ID, :NAME ]) ) // Same as o1.TheseColumnsXT([1, 2])
#--> [
#	[ "id", 	[ 10, 20, 30 ] 			],
#	[ "name", 	[ "Imed", "Hatem", "Karim" ] 	]
# ]

pf()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.14 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@NL( o1.ColZ(2) )
#--> [
#	[ "Imed", [ 2, 1 ] ],
#	[ "Hatem", [ 2, 2 ] ],
#	[ "Karim", [ 2, 3 ] ]
# ]

pf()
# Executed in 0.02 second(s)

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? o1.ColNames()
#--> [ "id", "name", "age" ]

? o1.IsColName(:name)
#--> TRUE

? o1.IsColNumber(3)
#--> TRUE

? o1.IsColNameOrNumber(:age)
#--> TRUE

? o1.AreColNamesOrNumbers([ :name, :age ])
#--> TRUE

? o1.AreColID([ :name, :age ])
#--> TRUE

pf()
# Executed in 0.03 second(s)

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@NL( o1.AllCols() ) + NL
#--> [
#	[ 10, 20, 30 ],
#	[ "Imed", "Hatem", "Karim" ],
#	[ 52, 46, 48 ]
# ]

? @@NL( o1.TheseCols([ 1, 3 ]) ) + NL
#--> [
#	[ 10, 20, 30 ],
#	[ 52, 46, 48 ]
# ]

? @@NL( o1.ColsXT() ) + NL
#--> [
#	[ "id",   [ 10, 20, 30 ] ],
#	[ "name", [ "Imed", "Hatem", "Karim" ] ],
#	[ "age",  [ 52, 46, 48 ] ]
# ]


? @@NL( o1.TheseColsXT([ 1, 3 ]) ) + NL
#--> [
#	[ "id", [ 10, 20, 30 ] ],
#	[ "age", [ 52, 46, 48 ] ]
# ]

? @@( o1.CellsInCols([ :name, :age ]) )
#--> [ "Imed", "Hatem", "Karim", 52, 46, 48 ]

pf()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.31 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])


? o1.ColNumbersToNames([3, 1])
#--> [ "age", "id" ]

? @@( o1.ColNamesToNumbers([ :AGE, :ID ]) )
#--> [ 3, 1 ]


pf()
# Executed in 0.03 second(s)

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])


? o1.TheseColNames([1, 2]) #--> [ "id", "employee" ]
#--> [ "id", "name" ]

pf()
# Executed in 0.02 second(s)

/*==============

pr()

? Q(["", "", ""]).AllItemsAreNull()
#--> TRUE

pf()
# Executed in 0.02 second(s)

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? o1.IsEmpty()
#--> FALSE

o1.Erase()

? o1.IsEmpty()
#--> TRUE

o1.Show()
#-->
#  ID    EMPLOYEE  SALARY
#  --- ---------- -------
#  NULL  NULL	     NULL
#  NULL  NULL	     NULL
#  NULL  NULL	     NULL

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.57 second(s) in Ring 1.17

/*-------------- #ring #bug?

pr()

aList = [ "Aaa", "Bbb", "Ccc" ]
? @@( aList["emm"] )
#--> ""

aList = [ :name = "Maiga", :job = "programmer" ]
? @@( aList[2]["emm"] )
#--> #--> ""

pf()
# Executed in 0.02 second(s)

/*-------------- #ring

pr()

str = "ring"
str[1] = "R"
? str
#--> Ring

str[3] = "nnn"
#--> Ring error message:
# Error (R7) : Can't assign to a string letter more than one character

pf()
# Executed in 0.02 second(s)

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? o1.Cell(:EMPLOYEE, 3)
#--> "Sonia"

o1.EraseCell(2, 3)

? @@( o1.Cell(2, 3) )
#-->NULL

pf()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.09 second(s) in Ring 1.17

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? o1.Cell(:EMPLOYEE, :LastRow)
#--> "Sonia"

? o1.Cell(:FirsCol, :LastRow)
#--> Error message:
#  Syntax error in (firscol)! Allowed values are
#  :First or :Last (or :FirstCol or :LastCol).

pf()
# Executed in 0.02 second(s)

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? o1.FirstColName()
#--> "id"

? o1.LastColName()
#--> "salary"

pf()
# Executed in 0.02 second(s)

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])


? o1.Col(:First)
#--> [ "001", "002", "003" ]

? o1.Col(:Last) # Works when CheckParams() = TRUE, otherwise use LastCol()
#--> [ 12499.20, 10890.10, 12740.30 ]

pf()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.06 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? o1.Row(:First)
#--> [ "001", "Salem", 12499.20 ]

? o1.Row(:Last) # Works when CheckParams() = TRUE, otherwise use LAstRow()
#--> [ "003", "Sonia", 12740.30 ]

pf()
# Executed in 0.02 second(s)

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "*****", 10000.10 ],
	[ "003", "Sonia", 12740.30 ],
	[ "002", "*****", 10000.10 ]
])

? @@( o1.FindCol(:SALARY) )
#--> 3

? @@( o1.FindRow([ "002", "*****", 10000.10 ]) )
#--> [ 2, 4 ]

pf()
# Executed in 0.03 second(s) in Ring 1.20
# Executed in 0.20 second(s) in Ring 1.17

/*-------------- #todo write a #narration

pr()

o1 = new stzTable([
	[ :ID,	   :EMPLOYEE, 	:SALARY   ],
	#---------------------------------#
	[ "001",   "Salima", 	12499.20  ],
	[ "002",   "Sonia", 	10000.10  ],
	[ "003",   "So",	12780.45  ],
	[ "004",   "GonSonSo", 	12740.30  ],
	[ "005",   "Mansour", 	10000.10  ],
	[ "006",   "so", 	14800.10  ]
])

? @@( o1.FindInCol(:EMPLOYEE, "---") ) + NL
#--> [ ]

? @@( o1.FindInCol(:EMPLOYEE, "So") ) + NL
#--> [ [ 2, 3 ] ]

? @@( o1.FindInColCS(:EMPLOYEE, "So", :CS = FALSE) ) + NL
#--> [ [ 2, 3 ], [ 2, 6 ] ]

? @@NL( o1.FindInCol(:EMPLOYEE, :SubValue = "So") ) + NL
#--> [
#	[ [ 2, 2 ], [ 1 ] 	],
#	[ [ 2, 3 ], [ 1 ] 	],
#	[ [ 2, 4 ], [ 4, 7 ] 	]
# ]

? @@NL( o1.FindInColCS(:EMPLOYEE, :SubValue = "So", :CS = FALSE) )
#--> [
# 	[ [ 2, 2 ], [ 1 ] 	],
#	[ [ 2, 3 ], [ 1 ] 	],
#	[ [ 2, 4 ], [ 4, 7 ] 	],
#	[ [ 2, 5 ], [ 4 ] 	],
#	[ [ 2, 6 ], [ 1 ] 	]
# ]

pf()
# Executed in 0.10 second(s) in Ring 1.20
# Executed in 0.55 second(s) in Ring 1.17

/*===================

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? @@( o1.ColSection(:EMPLOYEE, :FromCellAt = 2, :To = :LastRow) ) + NL
#--> [ "Henri", "Sonia" ]

? @@( o1.FindCellsInColSection(:EMPLOYEE, 2, :LastRow) ) + NL # Or ColSectionAsPositions()
#--> [ [ 2, 2 ], [ 2, 3 ] ]

? @@NL( o1.CellsInColSectionZ(:EMPLOYEE, 2, :LastRow) )
#--> [
#	[ "Henri", [ 2, 2 ] ],
#	[ "Sonia", [ 2, 3 ] ]
# ]

pf()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.12 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? @@( o1.RowSection(2, :FromCell = 2, :To = :LastCol) ) + NL
#--> [ "Henri", 10890.10 ]

? @@( o1.FindCellsInRowSection(2, 2, :LastCol) ) + NL # Or RowSectionAsPositions()
#--> [ [ 2, 2 ], [ 3, 2 ] ]

? @@NL( o1.CellsInRowSectionZ(2, 2, 3) )
#--> [
#	[ "Henri", [ 2, 2 ] ],
#	[ 10890.10, [ 3, 2 ] ]
# ]

pf()
# Executed in 0.03 second(s)

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? o1.CellAtPosition(2, 3) + NL
#--> "Sonia"

? o1.TheseCells([ [ 2, 1 ], [ 2, 3 ] ])
#--> [ "Salem", "Sonia" ]

pf()
# Executed in 0.02 second(s)

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? @@( o1.Col(:EMPLOYEE) )
#--> [ "Salem", "Henri", "Sonia" ]

? @@NL( o1.ColZ(:EMPLOYEE) ) // Same as o1.CellsAndPositionsInCol(:EMPLOYEE)
			     // and o1.CellsInColZ(:EMPLOYEE)
#--> [
#	[ "Salem", [ 2, 1 ] ],
#	[ "Henri", [ 2, 2 ] ],
#	[ "Sonia", [ 2, 3 ] ]
# ]

pf()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.15 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE, :SALARY ],
	#--------------------------#
	[ "001", "Salem", 12499.20 ],
	[ "002", "Henri", 10890.10 ],
	[ "003", "Sonia", 12740.30 ]
])

? @@( o1.CellsInCol(:EMPLOYEE) ) + NL // same as Col(:EMPLOYEE)
#--> [ "Salem", "Henri", "Sonia" ]

? @@( o1.CellsInColAsPositions(:EMPLOYEE) ) + NL // same as ColAsPositions(:EMPLOYEE)
#--> [ [2, 1], [2, 2], [2, 3] ]

? @@NL( o1.CellsInColZ(:EMPLOYEE) )
#--> [
#	[ "Salem", [ 2, 1 ] ],
#	[ "Henri", [ 2, 2 ] ],
#	[ "Sonia", [ 2, 3 ] ]
# ]

pf()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.18 second(s) in Ring 1.17

/*==============

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@NL( o1.RowZ(2) ) // Same as o1.CellsAndPositionsInRow(2)
#--> [
#	[ 20, 	   [ 1, 2 ] ],
#	[ "Hatem", [ 2, 2 ] ],
#	[ 46, 	   [ 3, 2 ] ]
#    ]

pf()
# Executed in 0.02 second(s)

/*--------------

pr()

o1 = new stzTable([
	[ :ID,	:NAME,		:AGE 	],
	#-------------------------------#
	[ 10,	"Imed",		52   	],
	[ 20,	"Hatem", 	46	],
	[ 30,	"Karim",	48	]
])

? @@( o1.CellsInRow(2) ) + NL // same as Row(2)
#--> [ 20, "Hatem", 46 ]

? @@( o1.CellsInRowAsPositions(2) ) + NL // same as RowAsPositions(2)
#--> [ [ 1, 2 ], [ 2, 2 ], [ 3, 2 ] ]

? @@NL( o1.CellsInRowZ(2) )
#--> [
#	[ 20, 		[ 1, 2 ] ],
#	[ "Hatem", 	[ 2, 2 ] ],
#	[ 46, 		[ 3, 2 ] ]
#    ]

pf()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.08 second(s) in Ring 1.17

/*==============

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@( o1.FindInCol( :FIRSTNAME, :Value = "Ali" ) ) + NL
#--> [ [ 1, 2 ], [ 1, 3 ] ]

? @@( o1.FindInCol( :FIRSTNAME, :SubValue = "a" ) ) + NL
#--> [ ]

? @@NL( o1.FindInColCS( :LASTNAME, :SubValue = "a", :CS = FALSE ) )
#--> [
#	[ [ 2, 1 ], [ 2 ]      ],
#	[ [ 2, 2 ], [ 1, 4, 6] ],
#	[ [ 2, 3 ], [ 1 ]      ]
# ]

pf()
# Executed in 0.07 second(s) in Ring 1.20
# Executed in 4.48 second(s) in Ring 1.17

/*==============

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],

	[ "Andy", 	"Maestro" ],
	[ "Alibaba", 	"Abraham" ],
	[ "Alibaba",	"AliAli"  ]
])

? o1.Cell(:FIRSTNAME, 2)
#--> Alibaba

? @@( o1.FindInCell(:FIRSTNAME, 2, "ba") )
#--> [ 4, 6 ]

? @@( o1.FindInCell(:LASTNAME, 3, "Ali") )
#--> [ 1, 4 ]

pf()
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.18 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],

	[ "Andy", 	"Maestro" ],
	[ "Alibaba", 	"Abraham" ],
	[ "Alibaba",	"AliAli"  ]
])

? @@( o1.ColCellsAsPositions(:FIRSTNAME) )
#--> [ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ] ]

? @@( o1.ColCellsAsPositions(:ANY) )
#--> Error message:
#    Incorrect param value! "any" is not a valid column identifier.

pf()
# Executed in 0.02 second(s)

/*--------------

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],

	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "AliAli",	"Ali"     ]
])

? @@( o1.FindInCells( [ [1, 1], [1, 2], [1, 3] ], :Value = "Ali" ) ) + NL
#--> [ [ 1, 2 ] ]

? @@NL( o1.FindInCells( [ [1, 1], [1, 2], [1, 3] ], :SubValue = "Ali" ) ) + NL
#NOTE: In place of :SubValue = ... you can say :CellPart or :SubPart = ...

#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1, 4 ] ]
# ]

? @@NL( o1.FindInCells( [ [1, 1], [1, 2], [1, 3] ], "Ali" ) )
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1, 4 ] ]
# ]

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.45 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],

	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "AliAli",	"Ali"     ],
	[ "Ali",	"Ben Ali" ]
])

? @@( o1.FindInCol( :FIRSTNAME, :Value = "Ali" ) ) + NL
#--> [ [ 1, 2 ], [ 1, 4 ] ]

? @@NL( o1.FindInCol( :FIRSTNAME, :SubValue = "Ali" ) ) + NL
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1, 4 ] ],
#	[ [ 1, 4 ], [ 1 ] ]
# ]

? @@NL( o1.FindInColCS( :LASTNAME, :SubValue = "A", :CS = FALSE ) )
#-->[
#	[ [ 2, 1 ], [ 2 ] ],
#	[ [ 2, 2 ], [ 1, 4, 6 ] ],
#	[ [ 2, 3 ], [ 1 ] ],
#	[ [ 2, 4 ], [ 5 ] ]
# ]

pf()
# Executed in 0.07 second(s) in Ring 1.20
# Executed in 0.12 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Alibaba",	"AliAli"  ]
])

? @@NL( o1.FindInRow(3, :CellPart = "Ali") )
#--> [
# 	[ [ 1, 3 ], [ 1 ] ],
# 	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

pf()
# Executed in 0.03 second(s)

/*--------------

pr()

o1 = new stzTable([
	[ :NAME,	:AGE ],
	[ "Ali",	24   ],
	[ "Lio",	25   ],
	[ "Dan",	42   ]
])

? o1.CellQ(:NAME, 2).Conttains("io") // #NOTE: A misspelled form of Contains()
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.08 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([
	[ :NAME,	:AGE ],
	[ "Ali",	24   ],
	[ "Lio",	25   ],
	[ "Dan",	42   ]
])


? o1.CellContainsSubValue(:NAME, 2, "io")
#--> TRUE

? o1.CellXT(:NAME, 2, :ContainsSubValue, "io")
#--> TRUE

pf()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.16 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],

	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "AliAli",	"Ali"     ],
	[ "Ali",	"Ben Ali" ]
])

? o1.NumberOfOccurrenceInCol(:FIRSTNAME, "Ali")
#--> 2

? o1.NumberOfOccurrenceInCol(:FIRSTNAME, :OfValue = "Ali")
#--> 2

? o1.NumberOfOccurrenceInCol(:FIRSTNAME, :OfSubValue = "Ali")
#--> 4

? o1.NumberOfOccurrenceXT(:InCol = :FIRSTNAME, :OfSubValue = "Ali")
#--> 4

? o1.NumberOfOccurrenceXT(:InRow = 3, :OfSubValue = "Ali")
#--> 3

? o1.NumberOfOccurrenceInRow(3, "Ali")
#--> 1

? o1.NumberOfOccurrenceInCell(2, 3, :OfSubValue = "Ali")
#--> 1

? o1.NumberOfOccurrenceXT(:InCell = [ 2, 3], :OfSubValue = "Ali")
#--> 1

pf()
# Executed in 0.16 second(s) in Ring 1.20
# Executed in 0.32 second(s) in Ring 1.17

/*=====================

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],

	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? o1.NumberOfOccurrenceInCols([ :FIRSTNAME, :LASTNAME ], "Ali") + NL
#--> 1

? @@( o1.FindInCols([ :FIRSTNAME, :LASTNAME ], "Ali") ) + NL
#--> [ [ 1, 2 ] ]

? o1.NumberOfOccurrenceInCols([ :FIRSTNAME, :LASTNAME ], :OfSubValue = "Ali") + NL
#--> 4

? @@NL( o1.FindInCols([ :FIRSTNAME, :LASTNAME ], :SubValue = "Ali") )
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

pf()
# Executed in 0.20 second(s) in Ring 1.20
# Executed in 0.35 second(s) in Ring 1.17

/*----------------------

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],

	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? @@( o1.FindInCols( [ :FIRSTNAME, :LASTNAME ], "Ali" ) ) + NL
#--> [ [ 1, 2 ] ]

# Same as:
? @@( o1.FindInCols( [ :FIRSTNAME, :LASTNAME ], :Value = "Ali" ) ) + NL # Added the :Value named param
#--> [ [ 1, 2 ] ]

? @@NL( o1.FindInCols( [ :FIRSTNAME, :LASTNAME ], :SubValue = "Ali" ) )
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

pf()
# Executed in 0.06 second(s) in Ring 1.20
# Executed in 0.28 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],

	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? @@( o1.FindInCols( [ :FIRSTNAME, :LASTNAME ], "Ali" ) ) + NL
#--> [ [ 1, 2 ] ]
# Executed in 0.11 second(s)

? @@( o1.FindInCols( [ 1, 2 ], "Ali" ) )
#--> [ [ 1, 2 ] ]

pf()
# Executed in 0.04 second(s)

/*--------------

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? o1.ColContains(2, "Ali")
#--> FALSE

? o1.ColContains(2, :SubValue = "Ali")
#--> TRUE

? o1.ColsContain([ :FIRSTNAME, :JOB ], "Ali")
#--> TRUE

? o1.ColsContain([ :LASTNAME, :JOB ], "Ali")
#--> FALSE

? o1.ColsContain([ :LASTNAME, :JOB ], :SubValue = "Ali")
#--> TRUE

? @@( o1.FindInCols([ :LASTNAME, :JOB ], :SubValue = "Ali") )
# [ [ [ 2, 3 ], [ 1, 4 ] ] ]

pf()
# Executed in 0.14 second(s) in Ring 1.20
# Executed in 0.40 second(s) in Ring 1.17

/*==============

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],

	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? @@( o1.RowAsPositions(2) ) + NL
#--> [ [ 1, 2 ], [ 2, 2 ], [ 3, 2 ] ]

? @@( o1.RowsAsPositions([ 1 , 3 ]) ) + NL
#--> [
#	[ 1, 1 ], [ 2, 1 ], [ 3, 1 ],
#	[ 1, 3 ], [ 2, 3 ], [ 3, 3 ]
# ]

? o1.NumberOfOccurrenceInRows([ 2, 3 ], "Ali") + NL
#--> 1

? @@( o1.FindInRows([ 2, 3 ], "Ali") ) + NL
#--> [ [ 1, 2 ] ]

? o1.NumberOfOccurrenceInRows([ 2, 3 ], :OfSubValue = "Ali") + NL
#--> 4

? @@( o1.FindInRows([ 2, 3 ], :SubValue = "Ali") ) + NL
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.26 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? o1.RowContains(3, "Ali")
#--> FALSE

? o1.RowContains(3, :SubValue = "Ali")
#--> TRUE

? o1.RowsContain([ 1, 3 ], "Ali")
#--> FALSE

? o1.RowsContain([ 1, 2 ], "Ali")
#--> TRUE

? o1.RowsContain([ 1, 3 ], :SubValue = "Ali") + NL
#--> TRUE

? @@NL( o1.FindInRows([ 1, 3 ], :SubValue = "Ali") )
#--> [
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

pf()
# Executed in 0.12 second(s)

/*===================

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? o1.FindCol(:JOB)
#--> 3

? @@( o1.FindCell("Abraham") )
#--> [ [ 2, 2 ] ]

? @@( o1.FindCell("Programmer") )
#--> [ [ 3, 1 ] ]

? @@( o1.FindCell("Ali") )
#--> [ [ 1, 2 ] ]

pf()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.20 second(s) in Ring 1.17

/*--------------

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	#-------------------------------------#
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.Find("Red") ) + NL
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

? @@( o1.FindInCol(:PALETTE1, "Blue") ) + NL
#--> [ [ 1, 2 ], [ 1, 3 ] ]

? @@( o1.FindInRow(2, "Red") ) 
#--> [ [ 2, 2 ], [ 2, 3 ] ]

pf()
# Executed in 0.06 second(s) in Ring 1.20
# Executed in 0.20 second(s) in Ring 1.17

/*===============

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	#-------------------------------------#
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.Section([1,2], [3,2]) ) + NL
#--> [ "Blue", "Blue", "White", "Red", "Green", "Gray", "Yellow", "Red" ]

? @@Nl( o1.SectionZ([1,2], [3,2]) ) + NL
#--> [
#	[ [ 1, 2 ], "Blue" ],
#	[ [ 1, 3 ], "Blue" ],
#	[ [ 1, 4 ], "White" ],
#	[ [ 2, 2 ], "Red" ],
#	[ [ 2, 3 ], "Green" ],
#	[ [ 2, 4 ], "Gray" ],
#	[ [ 3, 1 ], "Yellow" ],
#	[ [ 3, 2 ], "Red" ]
# ]

? @@( o1.SectionAsPositions([1,2], [3,2]) )
#--> [
#	[ 1, 2 ], [ 1, 3 ], [ 1, 4 ],
#	[ 2, 2 ], [ 2, 3 ], [ 2, 4 ],
#	[ 3, 1 ], [ 3, 2 ]
# ]

pf()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.12 second(s) in Ring 1.17

/*==========

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.FindInSection([1,2], [3,2], "Red") )
#--> [ [ 2, 2 ], [ 3, 2 ] ]

pf()
# Executed in 0.02 second(s)

/*----------

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@NL( o1.SectionZ(:From = :FirstCell, :To = [3,2]) )
#--> [
#	[ [ 1, 1 ], "Red" ],
#	[ [ 1, 2 ], "Blue" ],
#	[ [ 1, 3 ], "Blue" ],
#	[ [ 1, 4 ], "White" ],
#	[ [ 2, 1 ], "White" ],
#	[ [ 2, 2 ], "Red" ],
#	[ [ 2, 3 ], "Green" ],
#	[ [ 2, 4 ], "Gray" ],
#	[ [ 3, 1 ], "Yellow" ],
#	[ [ 3, 2 ], "Red" ]
# ]

pf()
# Executed in 0.02 second(s)

/*-----------

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.FindInSectionCS([1, 1], [3, 2], "red", TRUE) )
#--> [ ]

? @@( o1.FindInSectionCS([1, 1], [3, 2], "Red", TRUE) )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

? @@( o1.FindInSectionCS([1, 1], [3, 2], "red", :CS = FALSE) )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

pf()
# Executed in 0.03 second(s)

/*-----------

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? @@NL( o1.FindInSection( :From = [1, 2], :To = [2, 3], :CellPart = "Ali" ) )
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

pf()
# Executed in 0.03 second(s)

/*-----------

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	#-------------------------------------#
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.FindNthInSectionCS(2, :From = :FirstCell, :To = [3, 3], "red", :CS = FALSE) )
#--> [2, 2]

? @@( o1.FindFirstInSection(:From = :FirstCell, :To = [3, 3], "Red") )
#--> [1, 1]

? @@( o1.FindLastInSection(:From = :FirstCell, :To = [3, 3], "Red") )
#--> [3, 2]

pf()
# Executed in 0.03 second(s) in Ring 1.17
# Executed in 0.22 second(s) in Ring 1.20

/*-----------

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.Count("Red")
#--> 3

? o1.Count(:SubValue = "e")
#--> 11

? o1.CountInCol(:PALETTE1, "Blue")
#--> 2

? o1.CountInRow(2, "Red")
#--> 2

? o1.CountInCells( [ [1, 1], [2,1], [2, 2] ], "Red" )
#--> 2

? o1.CountInCells( [ [1, 1], [2,1], [2, 2] ], :SubValue = "e" )
#--> 3

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.24 second(s) in Ring 1.17

/*-----------

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.SectionContains( [1, 2], [3, 2], "Red" )
#--> TRUE

? o1.SectionContains( [1, 2], [3, 2], :SubValue = "ed" )
#--> TRUE

pf()
# Executed in 0.04 second(s)

/*==============

pr()

o1 = new stzListOfStrings([ "Red", "PALETTE" ])
? o1.AdjustedToRight()
#--> [
#	"    Red",
#	"PALETTE"
# ]

pf()
# Executed in 0.08 second(s)

/*----------------

pr()

o1 = new stzListOfStrings([ ":PALETTE1", "Red", "Blue", "Blue", "White" ])
? o1.AlignedToRight()
#--> [
# 	":PALETTE1",
# 	"      Red",
# 	"     Blue",
# 	"     Blue",
# 	"    White"
# ]

pf()
# Executed in 0.06 second(s)

/*===============

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.ShowXT([
	:Separator = " | ",
	:IntersectionChar = "+",
	:Alignment = :Left,
	:UnderLineHeader,
	:ShowRowNumbers
])
#-->
#  # | PALETTE1 | PALETTE2 | PALETTE3
# ---+----------+----------+----------
#  1 | Red      | White    | Yellow   
#  2 | Blue     | Red      | Red      
#  3 | Blue     | Green    | Magenta  
#  4 | White    | Gray     | Black    
#  5 | Red      | White    | Yellow   
#  6 | Blue     | Red      | Red      
#  7 | Blue     | Green    | Magenta  
#  8 | White    | Gray     | Black    
#  9 | Red      | White    | Yellow   
# 10 | Blue     | Red      | Red      
# 11 | Blue     | Green    | Magenta  
# 12 | White    | Gray     | Black    

pf()
# Executed in 0.16 second(s) in Ring 1.20
# Executed in 0.74 second(s) in Ring 1.17

/*==============

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.ShowXT([ :ShowRowNumbers, :IntersectionChar = "+" ])
#--> # | PALETTE1 | PALETTE2 | PALETTE3
#    -- ---------- ---------- ---------
#    1 |      Red |    White |   Yellow
#    2 |     Blue |      Red |      Red
#    3 |     Blue |    Green |  Magenta
#    4 |    White |     Gray |    Black

? @@NL( o1.SectionZ(:From = [1,2], :To = [3,2]) ) + NL
#--> [
#	[ [ 1, 2 ], "Blue" ],
#	[ [ 1, 3 ], "Blue" ],
#	[ [ 1, 4 ], "White" ],
#	[ [ 2, 2 ], "Red" ],
#	[ [ 2, 3 ], "Green" ],
#	[ [ 2, 4 ], "Gray" ],
#	[ [ 3, 1 ], "Yellow" ],
#	[ [ 3, 2 ], "Red" ]
# ]

? @@NL( o1.FindInSection(:From = [1,2], :To = [3,2], :SubValue = "e") ) + NL
#--> [
#	[ [ 1, 2 ], [ 4 ] ],
#	[ [ 1, 3 ], [ 4 ] ],
#	[ [ 1, 4 ], [ 5 ] ],
#	[ [ 2, 2 ], [ 2 ] ],
#	[ [ 2, 3 ], [ 3, 4 ] ],
#	[ [ 3, 1 ], [ 2 ] ],
#	[ [ 3, 2 ], [ 2 ] ]
# ]

? @@( o1.FindNthInSection(:First, :From = [1,2], :To = [3,2], :SubValue = "e") ) + NL
#--> [ [ 1, 2 ], 4 ]

? @@( o1.FindNthInSection(:Last, :From = [1,2], :To = [3,2], :SubValue = "e") ) + NL
#--> [ [ 3, 2 ], 2 ]

? @@( o1.FindLastInSection(:From = [1,2], :To = [3,2], :SubValue = "e") ) + NL
#--> [ [ 3, 2 ], 2 ]

pf()
# Executed in 0.20 second(s) in Ring 1.20
# Executed in 0.51 second(s) in Ring 1.17

/*=============

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.FindCell( "Red" ) )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

# Same as:
? @@( o1.FindAllOccurrences( :Of = "Red") )
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ] ]

? @@( o1.FindCells([ "Red", "White" ]) ) # Colors of the Tunisian flag :D
#--> [ [ 1, 1 ], [ 2, 2 ], [ 3, 2 ], [ 1, 4 ], [ 2, 1 ] ]

pf()
# Executed in 0.06 second(s)

/*-----------

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.NumberOfOccurrence( :Of = "Red" )
#--> 3

? @@( o1.FindNthCell(1, "Red") )
#--> [ 1, 1 ]

? @@( o1.FindNthCell(2, "Red") )
#--> [ 2, 2 ]

? @@( o1.FindLastCell( "Red" ) )
#--> [ 3, 2 ]

pf()
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.38 second(s) in Ring 1.17

/*-----------

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? o1.NumberOfOccurrence( :OfSubValue = "Ali" )
#--> 4

? @@NL( o1.FindAllOccurrences( :OfSubValue = "Ali" ) ) + NL
#--> [
#	[ [ 1, 2 ], [ 1 ] ],
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

? @@( o1.FindNthOccurrence( 2, :OfSubValue = "Ali" ) ) + NL
#--> [ [ 1, 3 ], 1 ]

? @@( o1.FindNth(2, :SubValue = "Ali") ) + NL
#--> [ [ 1, 3 ], 1 ]

? @@( o1.FindFirst(:SubValue = "Ali") ) + NL
#--> [ [ 1, 2 ], 1 ]

? @@( o1.FindLast(:SubValue = "Ali" ) )
#--> [ [ 2, 3 ], 4 ]

pf()
# Executed in 0.15 second(s) in Ring 1.20
# Executed in 0.69 second(s) in Ring 1.17

/*-----------

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? o1.NumberOfOccurrence( :OfSubValue = "Ali" )
#--> 4

? o1.NumberOfOccurrenceInCol( :LASTNAME, :OfSubValue = "Ali" )
#--> 2

? @@( o1.FindInCol( :LASTNAME, :SubValue = "Ali" ) )
#--> [ [ [ 2, 3 ], [ 1, 4 ] ] ]

? @@( o1.FindNthInCol( 2, :LASTNAME, :SubValue = "Ali" ) )
#--> [ [ 2, 3 ], 4 ]

pf()
# Executed in 0.12 second(s) in Ring 1.20
# Executed in 0.38 second(s) in Ring 1.17

/*-----------

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME,	:JOB	 	],
	#-----------------------------------------------#
	[ "Andy", 	"Maestro",	"Programmer" 	],
	[ "Ali", 	"Abraham",	"Designer"	],
	[ "Alibaba",	"AliAli",	"Tester"	]
])

? o1.NumberOfOccurrence( :OfSubValue = "Ali" )
#--> 4

? o1.NumberOfOccurrenceInRow( 3, :OfSubValue = "Ali" )
#--> 3

? @@NL( o1.FindInRow( 3, :SubValue = "Ali" ) ) + NL
#-->[
#	[ [ 1, 3 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 1, 4 ] ]
# ]

? @@( o1.FindNthInRow( 2, 3, :SubValue = "Ali" ) )
#--> [ [ 2, 3 ], 1 ]

pf()
# Executed in 0.09 second(s)

/*-----------

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? @@( o1.Col(2) )
#--> [ "White", "Red", "Green", "Gray" ]

? @@( o1.HasColName(:PALETTE2) )
#--> TRUE

? o1.HasColNames([ :PALETTE1, :PALETTE3 ]) #--> TRUE
#--> TRUE

? @@( o1.ColNames() )
#--> [ "palette1", "palette2", "palette3" ]

pf()
# Executed in 0.02 second(s)

/*==========

pr()

o1 = new stzTable([
	:ID 	  = [ 10,	20,		30	],
	:EMPLOYEE = [ "Ali",	"Sam",		"Ben"	],
	:SALARY	  = [ 14500,	17630,		20345	]
])

o1.AddRow([ 40, "Peter", 12500 ])
? o1.Row(4)
#--> [ 40, "Peter", 12500 ]

pf()
# Executed in 0.02 second(s)

/*==========

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

o1.AddCol( :PALETTE4 = [ "Magenta", "Blue", "White", "Red" ])

? @@( o1.ColNames() )
#--> [ "palette1", "palette2", "palette3", "palette4" ]

? o1.HasColName(:PALETTE4)
#--> TRUE

? @@( o1.Col(:PALETTE4) )
#--> [ "Magenta", "Blue", "White", "Red" ]

o1.RemoveCol(:PALETTE4)

? @@( o1.ColNames() )
#--> [ "palette1", "palette2", "palette3" ]

pf()
# Executed in 0.04 second(s)

/*----------

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],

	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.ColToColName(2)
#--> "palette2"

? o1.ColToColName(:PALETTE2) + NL
#--> "palette2"

? o1.TheseColsToColNames([3, :PALETTE1, 2])
#--> [ "palette3", "palette1", "palette2" ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.04 second(s) in Ring 1.20

/*----------

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.ColToColNumber(2)
#--> 2

? o1.ColToColNumber(:PALETTE2) + NL
#--> 2

? o1.TheseColsToColsNumbers([:PALETTE3, :PALETTE1, 2])
#--> [ 3, 1, 2 ]

pf()
# Executed in 0.03 second(s)

/*----------

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.Show()
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#        Red      White     Yellow
#       Blue        Red        Red
#       Blue      Green    Magenta
#      White       Gray      Black


o1.EraseCol(2)
? o1.Show()
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#         Red               Yellow
#        Blue                  Red
#        Blue              Magenta
#       White                Black

o1.EraseCols([3 , 1])
? o1.Show()
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#                            
#                               
#                               
#                               
#    

pf()
# Executed in 0.20 second(s)

/*----------

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.Show()
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#         Red      White     Yellow
#        Blue        Red        Red
#        Blue      Green    Magenta
#       White       Gray      Black

o1.EraseRow(2)
? o1.Show()
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#         Red      White     Yellow
#                               
#        Blue      Green    Magenta
#       White       Gray      Black

o1.EraseRows([3, 1])
? o1.Show()
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#                               
#                               
#                               
#       White       Gray      Black

pf()
# Executed in 0.18 second(s)

/*----------

pr()

o1 = new stzTable([
	:COL1 = [ "to", "be", "removed" ]
])
? o1.Show()
#-->   COL1
#   -------
#        to
#        be
#   removed

o1.RemoveCol(1)

? @@( o1.Content() )
#--> [ [ "col1", [ "" ] ] ]

? @@( o1.Cell(1, 1) )
#--> ""

? o1.NumberOfCells()
#--> 1

? @@( o1.Cells() )
#--> [ "" ]

? o1.IsEmpty()
#--> TRUE

o1.Show()
#--> COL1
#    ----
#    ""

pf()
# Executed in 0.10 second(s)

/*----------

pr()

o1 = new stzTable([])
o1.Show()
#--> COL1
#    ----
#    ""

? @@( o1.Col(1) )
#--> [ "" ]

? @@( o1.Cell(1, 1) )
#--> ""

pf()
# Executed in 0.09 second(s)

/*----------

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.Cell(3, 2)
#--> "Red"

? o1.Cell(1, 1)
#--> "Red"

? o1.Cell(0, 2)
#--> Error message: Array Access (Index out of range) 

pf()
# Executed in 0.02 second(s)

/*----------

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.Show()
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#         Red      White     Yellow
#        Blue        Red        Red
#        Blue      Green    Magenta
#       White       Gray      Black

o1.RemoveCol(1)
o1.RemoveCol(1)

? o1.Show()
#--> PALETTE3
#    --------
#      Yellow
#         Red
#     Magenta
#       Black

o1.RemoveCol(1)

o1.Show()
#--> COL1
#    ----
#    ""

o1.RemoveCol(2)
#--> Error message:
#    Incorrect value! n must correspond to a valid number of column.

pf()
# Executed in 0.12 second(s)

/*----------

pr()

o1 = new stzTable([
	[ :PALETTE1,   :PALETTE2,   :PALETTE3 ],
	[     "Red",     "White",    "Yellow" ],
	[    "Blue",       "Red",       "Red" ],
	[    "Blue",     "Green",   "Magenta" ],
	[   "White",      "Gray",     "Black" ]
])

? o1.Show()
#--> PALETTE1   PALETTE2   PALETTE3
#    --------- ---------- ---------
#         Red      White     Yellow
#        Blue        Red        Red
#        Blue      Green    Magenta
#       White       Gray      Black

o1.RemoveCols([1, 2])
? o1.Show()
#--> PALETTE3
#    --------
#      Yellow
#         Red
#     Magenta
#       Black

o1.RemoveCol(:PALETTE3)
? o1.Show()
#--> COL1
#    ----
#    ""
      
pf()
#--> Executed in 0.15 second(s) in Ring 1.20
#--> Executed in 0.50 second(s) in Ring 1.17

/*==========

pr()

o1 = new stzTable([
	:ID 	  = [ 10,	20,		30	],
	:EMPLOYEE = [ "Ali",	"Sam",		"Ben"	],
	:SALARY	  = [ 14500,	17630,		20345	]
])

o1.AddRow([ 40, "Peter", 12500 ])
? o1.Row(4)
#--> [ 40, "Peter", 12500 ]

pf()
# Executed in 0.02 second(s)

/*==========

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

o1.AddCol( :TEMPO = [ "any", "any", "any", "any" ])

? @@( o1.Col(:TEMPO) )
#--> [ "any", "any", "any" ]

pf()
#--> Executed in 0.02 second(s)

/*---------

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

o1.AddCol( :TEMPO = [ "any", "any" ])

? @@( o1.Col(:TEMPO) )
#--> [ "any", "any", "" ]

pf()
# Executed in 0.02 second(s)

/*---------

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

o1.AddCol( :TEMPO = [ ])

? @@( o1.Col(:TEMPO) )
#--> [ "", "", "" ]

pf()
# Executed in 0.02 second(s)

/*----------

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

o1.AddCol( :TEMPO = [ NULL, NULL, NULL ])

? o1.LastColName()
#--> "tempo"

? @@(o1.LastCol())
#--> [ "", "", "" ]

pf()
# Executed in 0.02 second(s)

/*----------

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

o1.AddCols([
	:ONES = [ 1, 1, 1 ],
	:TWOS = [ 2, 2, 2 ]
])

? @@NL( o1.Cols() ) + NL
#--> [
#	[ 10, 20, 30 ],
#	[ "Ali", "Dan", "Ben" ],
#	[ 35000, 28900, 25982 ],
#	[ 1, 1, 1 ],
#	[ 2, 2, 2 ]
# ]

? @@( o1.TheseColumns([ :ONES, :TWOS ]) ) + NL
#--> [ [ 1, 1, 1 ], [ 2, 2, 2 ] ]

? @@NL( o1.TheseColumnsXT([ :ONES, :TWOS ]) )
#--> [
#	[ "ones", [ 1, 1, 1 ] ],
#	[ "twos", [ 2, 2, 2 ] ]
# ]

pf()
# Executed in 0.05 second(s) in Ring 1.17
# Executed in 0.30 second(s) in Ring 1.20

/*==========

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY,	:JOB 	],
	[ 10,	"Ali",		35000,		"job1"	],
	[ 20,	"Dan",		28900,		"job2"	],
	[ 30,	"Ben",		25982,		"job3"	]
])

? o1.ShowXT([])

#--> # | ID | EMPLOYEE | SALARY |  JOB
#    --+----+----------+--------+-----
#    1 | 10 |      Ali |  35000 | job1
#    2 | 20 |      Dan |  28900 | job2
#    3 | 30 |      Ben |  25982 | job3

? @@NL( o1.SubTable([ :EMPLOYEE, :SALARY ]) ) + NL
#--> [
#	[ "employee", [ "Ali", "Dan", "Ben" ] ],
#	[ "salary"  , [ 35000, 28900, 25982 ] ]
#    ]

o1.SubTableQRT([ :EMPLOYEE, :SALARY ], :stzTable).Show()

#--> EMPLOYEE   SALARY
#    --------- -------
#         Ali    35000
#         Dan    28900
#         Ben    25982

pf()
# Executed in 0.14 second(s) in Ring 1.20
# Executed in 0.57 second(s) in Ring 1.17

/*-----------

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	]
])

? @@( o1.CellsAsPositions() )
#--> [
#	[ 1, 1 ], [ 2, 1 ], [ 3, 1 ],
#	[ 1, 2 ], [ 2, 2 ], [ 3, 2 ],
#	[ 1, 3 ], [ 2, 3 ], [ 3, 3 ]
# ]

pf()
# Executed in 0.02 second(s)

/*================

pr()

o1 = new stzListOfLists([
	[ 10,	"Ali",		35000	],
	[ 20,	"Dania",	28900	],
	[ 30,	"Ben",		25982	],
	[ 40,	"ali",		"Ali"	]
])

? @@( o1.FindInLists("Ali") )
#--> [ [ 1, 2 ], [ 4, 3 ] ]

? @@( o1.FindInListsCS("ali", :CS = FALSE) )
#--> [ [ 1, 2 ], [ 4, 2 ], [ 4, 3 ] ]

pf()
# Executed in 0.03 second(s)

/*---------

pr()

o1 = new stzListOfLists([
	[ 10, 20, 30, 40 ],
	[ "Ali", "Dania", "Ben", "ali" ],
	[ 35000, 28900, 25982, "Ali" ]
])

? @@( o1.FindInLists("Ali") )
#--> [ [ 2, 1 ], [ 3, 4 ] ]

? @@( o1.FindInListsCS("ali", :CS = FALSE) )
#--> [ [ 2, 1 ], [ 2, 4 ], [ 3, 4 ] ]

pf()
# Executed in 0.03 second(s)

/*---------

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],

	[ 10,	"Ali",		35000	],
	[ 20,	"Dania",	28900	],
	[ 30,	"Ben",		25982	],
	[ 40,	"ali",		"Ali"	]
])

? o1.Contains( :Cell = "Ali" ) # same as ? o1.ContainsCell("Ali")
#--> TRUE

? o1.Contains( :SubValue = "a" ) # same as ? o1.ContainsSubValue("a")
#--> TRUE

? @@( o1.FindCellCS("Ali", FALSE) ) + NL
#--> [ [ 2, 1 ], [ 2, 4 ], [ 3, 4 ] ]
#--> One occurrence of "Ali" in the cell [2, 1]

? @@NL( o1.FindSubValueCS("a", :CaseSensitive = FALSE) )
#--> [
#	[ [ 2, 1 ], [ 1 ] ],
#	[ [ 2, 2 ], [ 2, 5 ] ],
#	[ [ 2, 4 ], [ 1 ] ],
#	[ [ 3, 4 ], [ 1 ] ]
# ]
#--> 5 occurrences of "a" (or "A"):
#	- 1 occurrence in cell [2, 1] ("Ali"), in position 1,
#	- 2 occurrences in cell [2, 2] ("Dania"), in positions 2 and 5
#	- 1 occurrence in cell [2, 4] ("ali"), in position 1, and finally
#	- 1 occurrence in cell [3, 4], ("Ali"), also in position 1

pf()
# Executed in 0.06 second(s)

/*-------------

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Hania",	25982	]
])

? @@( o1.FindNth(1, :Cell = "Ali") ) # Same as ? @@( o1.FindFirst( :Cell = "Ali" ) )
#--> [2, 1]

? @@( o1.FindNthCS(3, :SubValue = "A", :CS = FALSE) )
#--> [ [ 2, 3 ], 2 ]
#--> 3rd occurrence of "A" (or "a") found in the cell [2, 3] ("Hania") in position 2

? @@( o1.FindFirstCS(:SubValue = "A", :CS = FALSE) )
#--> [ [ 2, 1 ], 1 ]

? @@( o1.FindLastCS(:SubValue = "A", :CS = FALSE) )
#--> [ [ 2, 3 ], 5 ]

pf()
# Executed in 0.07 second(s) in Ring 1.20
# Executed in 0.65 second(s) in Ring 1.17

/*-------------

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],

	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Ben",		25982	],
	[ 40,	"ali",		"ALI"	]
])

? o1.Count( :Value = "Ali" )
#--> 1

# Other alternatives of the same function:

? o1.Count( :Cell = "Ali" )
#--> 1

? o1.NumberOfOccurrence( :OfCell = "Ali" )
#--> 1

? o1.CountOfCell( "Ali" )
#--> 1

? o1.CountOfValue("Ali")
#--> 1

? o1.HowMany("Ali")
#--> 1

? o1.HowManyOccurrences( :Of = "Ali" )
#--> 1

pf()
# Executed in 0.07 second(s)

/*-------------

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dan",		28900	],
	[ 30,	"Hania",	25982	]
])

? o1.Count( :SubValue = "a" )
#--> 3

? o1.CountCS( :SubValue = "A", :CaseSensitive = FALSE )
#--> 4

pf()
# Executed in 0.04 second(s)

/*-------------

pr()

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

? o1.Cell(:EMPLOYEE, 3)
#--> "Han"

? @@( o1.CellZ(:EMPLOYEE, 3) ) + NL
#--> [ "Han", [2, 3] ]

? o1.Count( :Cells = "Ali" )
#--> 2
	# Same as NumberOfOccurrence( :OfCell = "Ali" )
	# Or you can say: ? o1.CountOfCell( "Ali" )
	# Or: HowMany( :Cells = "Ali" )

? @@( o1.FindCell("Ali") ) + NL
#--> [ [ 2, 1 ], [2, 4] ]
#--> One occurrence of "Ali" in the cell [2, 1], and
#    one in the cell [ 2, 4 ]

? @@NL( o1.FindSubValue("a") ) + NL
#--> [
#	[ [ 2, 2 ], [ 2, 5 ] ],
#	[ [ 2, 3 ], [ 2 ] ]
#    ]
#--> There are 3 occurrences of of "a" in the table:
#	--> 2 occurrences in cell [2, 2] ("Dania"), in the 2nd and 5th chars.
#	--> 1 occurrence in cell [2, 3] ("Han"), in position 2.

? @@NL( o1.FindSubValueCS("a", :CaseSensitive = FALSE) ) + NL
#--> [
#	[ [ 2, 1 ], [ 1 ] ],
#	[ [ 2, 2 ], [ 2, 5 ] ],
#	[ [ 2, 3 ], [ 2 ] ],
#	[ [ 2, 4 ], [ 1 ] ]
#    ]

? o1.CountCS( :SubValue = "a", :CS= FALSE )
#--> 5
	#--> five occurrences of "A" (or "a"):
	# 	- one occurrence in the cell [2, 1] ("Ali") at the 1st char
	# 	- two occurrences in the cell [2, 2] ("Dania") at the 2nd and 5th chars
	# 	- one occurrence in the cell [2, 3] ("Han") at the 2nd char
	# 	- one occurrence in the cell [2, 4] ("Ali") at the 1st char

pf()
# Executed in 0.08 second(s) in Ring 1.20
# Executed in 1.54 second(s) in Ring 1.17

/*=============

pr()

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

? @@( o1.TheseCells([ [1,2], [2,2], [2,3] ]) )
#--> [ 20, "Dania", "Ben" ]

? @@( o1.TheseCellsZ([ [1,2], [2,2], [2,3] ]) )
#--> [ [ 20, [ 1, 2 ] ], [ "Dania", [ 2, 2 ] ], [ "Han", [ 2, 3 ] ] ]

pf()
# Executed in 0.02 second(s)

/*===============

// Finding all occurrence of a value, or subvalue, in a given list of cells
pr()

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

? @@( o1.FindInCells( [ [1,2], [2,2], [2,3] ], :Value = "Dania" ) ) + NL
#--> [ [2, 2] ]

? @@NL( o1.FindInCells( [ [1,2], [2,2], [2,3] ], :SubValue = "a" ) )
#--> [
#	[ [ 2, 2 ], [ 2, 5 ] ],
#	[ [ 2, 3 ], [ 2 ]    ]
#    ]
#--> There are 3 occurrences of "a" in the specified cells:
#	- 2 occurrences in the cell [2, 2] ("Dania"), in positions 2 and 5, and
#	- 1 occurrence in cell [2, 3] ("Han"), in position 2.

pf()
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.17 second(s) in Ring 1.17

/*-------------

// Finding nth occurrence of a value, or subvalue, in a given list of cells

pr()

o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dania",	28900	],
	[ 30,	"Han",		25982	],
	[ 40,	"ali",		"ALI"	]
])

? @@( o1.FindNthInCells( 1, [ [1,2], [2,2], [2,3] ], :Value = "Dania" ) )
#--> [2, 2]

? @@( o1.FindNthInCells( 1, [ [1,2], [2,2], [2,3] ], :Value = "blabla" ) )
#--> [ ]

? @@( o1.FindNthInCells( 2, [ [1,2], [2,2], [2,3] ], :SubValue = "a" ) ) 
#--> [ [ 2, 2 ], 5 ]
// Same as:  @@( o1.FindNthSubValueInCells( 2, [ [1,2], [2,2], [2,3] ], "a" ) )

? @@( o1.FindFirstInCells([ [1,2], [2,2], [2,3] ], :Value = "Dania" ) )
#--> [ 2, 2 ]

? @@( o1.FindLastInCells([ [1,2], [2,2], [2,3] ], :Value = "Dania" ) )
#--> [ 2, 2 ]

pf()
# Executed in 0.06 second(s) in Ring 1.20
# Executed in 0.52 second(s) in Ring 1.17

/*-------------

pr()
o1 = new stzTable([
	[ :ID,	:EMPLOYEE,	:SALARY	],
	[ 10,	"Ali",		35000	],
	[ 20,	"Dania",	28900	],
	[ 30,	"Han",		25982	],
	[ 40,	"ali",		"ALI"	]
])

? @@( o1.FindNthInCells( 3, [ [2,1], [2,4], [3,4] ], :Value = "ali" ) )
#--> []	// In fact, there is no a 3rd occurrence of 'ali" (in lowercase) in the table!

? @@( o1.FindNthInCellsCS( 3, [ [2,1], [2,4], [3,4] ], :Value = "ali", :CS = FALSE ) )
#--> [2, 4]

pf()
# Executed in 0.10 second(s)

/*------------- #narration

pr()

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

# Let's take this list of cells

aMyCells = [ [2,1], [2,3], [2,4] ]

# And get them along with their positions:

? @@NL( o1.TheseCellsZ( aMyCells ) ) + NL
#--> [
#	[ "Ali", [ 2, 1 ] ],
#	[ "Han", [ 2, 3 ] ],
#	[ "Ali", [ 2, 4 ] ]
# ]

# How many cell made of the value "Ali" does exist in those cells?

? o1.CountInCells( aMyCells, :Value = "Ali" )
#--> 2

# Where do they exist exactly?

? @@( o1.FindInCells( aMyCells, :Value = "Ali" ) )
#--> [ [ 2, 1 ], [ 2, 4 ] ]

# How many subvalue "A" exists in the same list of cells?

? o1.CountInCells( aMyCells, :SubValue = "A" )
#--> 2

# How many subvalue "A" whatever case it has?

? o1.CountInCellsCS( aMyCells, :SubValue = "A", :CS = FALSE )
#--> 3

# And where do they exist exactly?

? @@NL( o1.FindInCellsCS( aMyCells, :SubValue = "A", :CS = FALSE ) )
#--> [
#	[ [ 2, 1 ], [ 1 ] ],
#	[ [ 2, 3 ], [ 2 ] ],
#	[ [ 2, 4 ], [ 1 ] ]
#    ]

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.46 second(s) in Ring 1.17

/*-------------

pr()

// Checking if a given value, or subvalue, exists in a given list of cells

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Ali",		12870	]
])

? o1.CellsContain( [ [2,1], [2,3], [2,4] ], :Cell = "Ali" ) 
#--> TRUE

? o1.CellsContain( [ [2,1], [2,3], [2,4] ], :SubValue = "a" ) // Same as ? o1.CellsContainSubValue("a")
#--> TRUE

? o1.CountInCells( [ [2,1], [2,3], [2,4] ], :Cell = "Ali" )
#--> 2

? o1.CountInCellsCS( [ [2,1], [2,3], [2,4] ], :SubValue = "a", :CS = FALSE )
#--> 3

pf()
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.13 second(s) in Ring 1.17

/*------------- #narration

pr()

# Softanza can find the values of a cell in a stzTable object,
# but also it can find parts of those values.

# In other terms, it can dig inside the cells and tell you if
# the cells contain a sub-value you provide

# It's like your are performing a full-text search of the table!

# Let's see this feature in action...

o1 = new stzTable([
	[ :ID,	 :EMPLOYEE,    	:SALARY	],
	#-------------------------------#
	[ 10,	 "Ali",		35000	],
	[ 20,	 "Dania",	28900	],
	[ 30,	 "Han",		25982	],
	[ 40,	 "Alia Dania",	"12870"	]
])

? @@NL( o1.FindSubValueInCells( [ [2,1], [2,2], [2, 4] ], "ia" ) ) + NL
#--> [
#	[ [ 2, 2 ], [ 4 ] ],	// "ia" exists in cell "Dania" starting at position 4
#	[ [ 2, 4 ], [ 3, 9 ] ]  // "ia" exists in cell "Alia Dania" at positions 3 and 8
# ]

# When the subvalue is a number and the cell is a number-in-string or viceversa,
# Softanza perfprmas the finding operation as if both where numbers-in-strings

? @@NL( o1.FindSubValueInCells( [ [3,1], [3,2], [3,4] ], "0" ) ) + NL
#--> [
#	[ [ 3, 1 ], [ 3, 4, 5 ] ],
#	[ [ 3, 2 ], [ 4, 5 ] ],
#	[ [ 3, 4 ], [ 5 ] ]
# ]

? @@NL( o1.FindSubValueInCells( [ [3,1], [3,2], [3,4] ], 0 ) )
#--> [
#	[ [ 3, 1 ], [ 3, 4, 5 ] ],
#	[ [ 3, 2 ], [ 4, 5 ] ],
#	[ [ 3, 4 ], [ 5 ] ]
# ]

pf()
# Executed in 0.03 second(s)

/*#================= ROW: FindInRow(), CountInRow(), ContainsInRow()

pr()

// Finding all occurrences of a value, or subvalue, in a row

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@( o1.FindInRow(2, :Value = "Ali") ) + NL
#--> [ [ 1, 2 ] ]

? @@( o1.FindInRow(3, :Value = "Ali" ) ) + NL
#--> [ [1, 3], [2, 3] ]

? @@( o1.FindInRow( 2, :SubValue = "a" ) ) + NL
#--> [ 
#	[ [2, 2], [4, 6] ]
#    ]

? @@( o1.FindInRowCS( 2, :SubValue = "a", :CS = FALSE ) )
#--> [
#	[ [1, 2], [1]    ],
#	[ [2, 2], [1, 4, 6] ],
#   ]

pf()
# Executed in 0.16 second(s)

/*------------

// Finding nth occurrence of a value in a row

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@( o1.FindNthInRow(:Nth = 1, :InRow = 2, :OfValue = "Abraham") )
#--> [2, 2]

# Or you can use this short form:

? @@( o1.FindNthInRow(1, 2, "Abraham") )
#--> [2, 2]

? @@( o1.FindNthInRow(:N = 2, :Row = 3, :Value = "Ali") )
#--> [2, 3]

? @@( o1.FindFirstInRow(3, :Value = "Ali") )
#--> [1, 3]

? @@( o1.FindLastInRow(3, :Value = "Ali") )
#--> [2, 3]

pf()
# Executed in 0.05 second(s) in Ring 1.20
# Executed in 0.14 second(s) in Ring 1.17

#-----------

pr()

// Finding nth occurrence of a subvalue in a row

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@( o1.FindInRow(2, :SubValue = "a") ) + NL
#--> [
#	[ [ 2, 2 ], [ 4, 6 ] ]
#    ]

? @@( o1.FindNthInRow(:Nth = 2, :InRow = 2, :OfSubValue = "a") )
#--> [ [ 2, 2 ], 6 ]

pf()
# Executed in 0.05 second(s)

#-----------

pr()

// Counting the number of occurrences of a value, or subvalue, in a row

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? o1.CountInRow(3, :Value = "Ali")
#--> 2

? o1.CountInRow(2, :SubValue = "A")
#--> 2

pf()
# Executed in 0.04 second(s)

#-----------

pr()

// Checking if a given value, or subvalue, exists in a row

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])


? o1.ContainsInRow(2, "Abraham")
#--> TRUE

? o1.RowContains(2, "Abraham")
#--> TRUE

? o1.ContainsInRow(2, :SubValue = "AL")
#--> FALSE

? o1.ContainsInRowCS(2, :SubValue = "AL", :CS = FALSE)
#--> TRUE

pf()
# Executed in 0.04 second(s)

#================= COL: FindInCol(), CountInCol(), ContainsInCol()

pr()

// Finding all occurrences of a value, or subvalue, in a column

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@( o1.FindInCol(:FIRSTNAME, "Ali") ) + NL
#--> [ [ 1, 2 ], [ 1, 3 ] ]

? @@( o1.FindInCol(2, :Value = "Ali") ) + NL
#--> [ [ 2, 3 ] ]

? @@NL( o1.FindInCol(:LASTNAME, :SubValue = "a" ) ) + NL
#--> [
#	[ [ 2, 1 ], [ 2 ] ],
#	[ [ 2, 2 ], [ 4, 6 ] ]
#    ]

? @@NL( o1.FindInColCS(:LASTNAME, :SubValue = "a", :CS = FALSE ) )
#--> [
#	[ [ 2, 1 ], [ 2 ] 	],
#	[ [ 2, 2 ], [ 1, 4, 6 ] ],
#	[ [ 2, 3 ], [ 1 ] 	]
#   ]

pf()
# Executed in 0.11 second(s) in Ring 1.22
# Executed in 0.21 second(s) in Ring 1.20
# Executed in 0.35 second(s) in Ring 1.17

/*------------

pr()

// Finding nth occurrence of a value in a Col

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@( o1.FindNthInCol(:Occurrence = 1, :InCol = :LASTNAME, :OfValue = "Abraham") )
#--> [2, 2]

# Or you can use this short form:

? @@( o1.FindNthInCol(1, 2, "Abraham") )
#--> [2, 2]

? @@( o1.FindNthInCol(2, :FIRSTNAME, "Ali") )
#--> [1, 3]

? @@( o1.FindFirstInCol(:FIRSTNAME, "Ali") )
#--> [1, 2]

? @@( o1.FindLastInCol(:FIRSTNAME, "Ali") )
#--> [1, 3]

pf()
# Executed in 0.19 second(s) in Ring 1.19
# Executed in 0.43 second(s) in Ring 1.17

/*-----------

pr()

// Finding nth occurrence of a subvalue in a Col

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? @@NL( o1.FindInCol(:LASTNAME, :SubValue = "a") ) + NL
#--> [
#	[ [ 2, 1 ], [ 2 ] 	],
#	[ [ 2, 2 ], [ 4, 6 ] 	]
#    ]

? @@( o1.FindNthInCol(:Nth = 2, :InCol = 2, :OfSubValue = "a") ) + NL
#--> [ [ 2, 2 ], 4 ]

? @@( o1.FindFirstInCol(:LASTNAME, :SubValue = "a") )
#--> [ [ 2, 1 ], 2 ]

pf()
# Executed in 0.08 second(s) in Ring 1.20
# Executed in 0.28 second(s) in Ring 1.17

/*-----------

pr()

// Counting the number of occurrences of a value, or subvalue, in a Col

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? o1.CountInCol(:FIRSTNAME, :Value = "Ali")
#--> 2

? o1.CountInCol(:LASTNAME, :SubValue = "A")
#--> 2

pf()
# Executed in 0.04 second(s) in Ring 1.20
# Executed in 0.14 second(s) in Ring 1.17

/*-----------

pr()

// Checking if a given value, or subvalue, exists in a Col

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? o1.ContainsInCol(2, "Abraham")
#--> TRUE

? o1.ColContains(2, "Abraham")
#--> TRUE

? o1.ContainsInCol(2, :SubValue = "AL")
#--> FALSE

? o1.ContainsInColCS(2, :SubValue = "AL", :CS = FALSE)
#--> TRUE

pf()
# Executed in 0.04 second(s)

/*=================

pr()

o1 = new stzTable([
	[ :FIRSTNAME,	:LASTNAME ],
	[ "Andy", 	"Maestro" ],
	[ "Ali", 	"Abraham" ],
	[ "Ali",	"Ali"     ]
])

? o1.Cell(:FIRSTNAME, 3)
#--> "Ali"

o1.ReplaceCell(:FIRSTNAME, 3, :With = "Saber")

? o1.Cell(:FIRSTNAME, 3)
#--> "Saber"

pf()
# Executed in 0.04 second(s)

/*-----------------

pr()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE ],
	[ "___",	"Arabic"  ],
	[ "France",	"___"     ],
	[ "USA",	"___"     ]
])

? o1.Cell(2, 3) + NL
#--> "___"

o1.ReplaceCell(2, 3, :With = "English")

? o1.Cell(2, 3)
#--> "English"

pf()
# Executed in 0.02 second(s)

/*-----------------

pr()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE ],
	[ "___",	"Arabic"  ],
	[ "France",	"___"     ],
	[ "USA",	"___"     ]
])

o1.ReplaceCellsByMany(
	[     [1, 1],   [2, 2],    [2, 3] ],
	[  "Tunisia", "French", "English" ]
)

o1.Show()
#-->  NATION   LANGUAGE
#    -------- ---------
#    Tunisia     Arabic
#     France     French
#        USA    English

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.19 second(s) in Ring 1.17

/*-----------------

pr()

o1 = new stzList([ "A", "B", "C" ])

o1.ExtendXT(:To = 10, :ByRepeatingItems)
? @@( o1.Content() )
#--> [ "A", "B", "C", "A", "B", "C", "A", "B", "C", "A" ]

pf()
# Executed in 0.02 second(s)

/*-----------------

pr()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE ],
	#-------------------------#
	[ "France",	"___"     ],
	[ "USA",	"___"     ],
	[ "Niger",	"___"	  ],
	[ "Egypt",	"___"	  ],
	[ "Kuwait",	"___"     ]
])


o1.ReplaceCellsByManyXT(
	[ [2, 1], [2, 2], [2, 3], [2, 4], [2, 5] ],
	[   "01",   "02",   "03" ]
)

o1.Show()
#--> NATION   LANGUAGE
#    ------- ---------
#    France         01
#       USA         02
#     Niger         03
#     Egypt         01
#    Kuwait         02

pf()
# Executed in 0.10 second(s)

/*-----------------

pr()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE ],
	[ "___",	"Arabic"  ],
	[ "France",	"___"     ],
	[ "USA",	"___"     ]
])

o1.ReplaceAll("___", :By = ".....")

o1.Show()
#--> NATION   LANGUAGE
#    ------- ---------
#     .....     Arabic
#    France      .....
#       USA      .....

pf()
# Executed in 0.13 second(s) in Ring 1.20
# Executed in 0.72 second(s) in Ring 1.17

/*============= #TODO write a #narration

pr()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE   ],
	[ "Tunisia",	"Arabic"    ],
	[ "France",	"French"    ],
	[ "Egypt",	"English"   ],
	[ "Belgium",	"French"    ],
	[ "Yemen",	"Arabic"    ]
])

o1.ReplaceNthCol(2, [ "___", "___" ])
? o1.Show()
#-->  NATION   LANGUAGE
#     -------- ---------
#     Tunisia        ___
#      France        ___
#       Egypt    English 
#     Belgium     Frencg
#       Yemen     Arabic

o1.ReplaceCellsInCol(:LANGUAGE, :By = ".....")
? o1.Show()
#--> NATION   LANGUAGE
#    -------- ---------
#    Tunisia      .....
#     France      .....
#      Egypt      .....
#    Belgium      .....
#      Yemen      .....

o1.ReplaceCol(:LANGUAGE, [ "Arabic", "French" ])
? o1.Show()
#-->  NATION   LANGUAGE
#     -------- ---------
#     Tunisia     Arabic
#      France     French
#       Egypt      .....
#     Belgium      .....
#       Yemen      .....

o1.ReplaceColXT(:LANGUAGE, [ "Arabic", "French" ])
? o1.Show()
#-->  NATION   LANGUAGE
#     -------- ---------
#     Tunisia     Arabic
#      France     French
#       Egypt     Arabic
#     Belgium     French
#       Yemen     Arabic

o1.ReplaceColNameAndData(:LANGUAGE, :CONTINENT, [ "Africa", "Europe", "Africa", "Europe", "Asia" ])
o1.Show()
#-->  NATION   CONTINENT
#     -------- ----------
#     Tunisia      Africa
#      France      Europe
#       Egypt      Africa
#     Belgium      Europe
#       Yemen        Asia

pf()
# Executed in 0.28 second(s)

/*---------

pr()

o1 = new stzTable([
	[ :NATION,	:CONTINENT   ],
	[ "Tunisia",	"Africa"    ],
	[ "France",	"Europe"    ],
	[ "Egypt",	"___"       ],
	[ "Belgium",	"___"       ],
	[ "Yemen",	"___"       ]
])

o1.ReplaceColNameAndDataXT( :CONTINENT, :LANGUAGE, [ "Arabic", "French" ] )
o1.Show()

#-->  NATION   LANGUAGE
#    -------- ---------
#    Tunisia     Arabic
#     France     French
#      Egypt     Arabic
#    Belgium     French
#      Yemen     Arabic

pf()
# Executed in 0.09 second(s)

/*----------------- #TODO write a #narration

pr()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE,	:CAPITAL,	:CONTINENT   ],

	[ "Tunisia",	"Arabic",	"Tunis",	"Africa"    ],
	[ "France",	"French",	"Paris",	"Europe"    ],
	[ "Egypt",	"English",	"Cairo",	"Africa"    ],
	[ "Belgium",	"French",	"Brussel",	"Europe"    ],
	[ "Yemen",	"Arabic",	"Sanaa",	"Asia"	    ]
])

o1.ReplaceRow(2, [ "___", "___" ]) # Or ReplaceNthRow()
? o1.Show()

#-->   NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia     Arabic     Tunis      Africa
#         ___        ___     Paris      Europe
#       Egypt    English     Cairo      Africa
#     Belgium     French   Brussel      Europe
#       Yemen     Arabic     Sanaa        Asia

o1.ReplaceCellsInRow(2, :By = ".....")
? o1.Show()
#-->   NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia     Arabic     Tunis      Africa
#       .....      .....     .....       .....
#       Egypt    English     Cairo      Africa
#     Belgium     French   Brussel      Europe
#       Yemen     Arabic     Sanaa        Asia

o1.ReplaceRowXT(2, [ "____", "~~~~" ])
? o1.Show()
#-->   NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia     Arabic     Tunis      Africa
#       ____      ~~~~     ____           ~~~~
#       Egypt    English     Cairo      Africa
#     Belgium     French   Brussel      Europe
#       Yemen     Arabic     Sanaa        Asia


pf()
# Executed in 0.35 second(s)

/*---------

pr()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE,	:CAPITAL,	:CONTINENT   ],

	[ "Tunisia",	"Arabic",	"Tunis",	"Africa"    ],
	[ "France",	"French",	"Paris",	"Europe"    ],
	[ "Egypt",	"English",	"Cairo",	"Africa"    ],
	[ "Belgium",	"French",	"Brussel",	"Europe"    ],
	[ "Yemen",	"Arabic",	"Sanaa",	"Asia"	    ]
])

o1.ReplaceRows([ "___", "___", "___" ])
? o1.Show()

#--> NATION   LANGUAGE   CAPITAL   CONTINENT
#    ------- ---------- --------- ----------
#       ___        ___       ___      Africa
#       ___        ___       ___      Europe
#       ___        ___       ___      Africa
#       ___        ___       ___      Europe
#       ___        ___       ___        Asia

o1.ReplaceRowsXT([ "___", "~~~" ])
o1.Show()

#--> NATION   LANGUAGE   CAPITAL   CONTINENT
#    ------- ---------- --------- ----------
#       ___        ~~~       ___         ~~~
#       ___        ~~~       ___         ~~~
#       ___        ~~~       ___         ~~~
#       ___        ~~~       ___         ~~~
#       ___        ~~~       ___         ~~~

pf()
# Executed in 0.22 second(s)

/*---------

pr()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE,	:CAPITAL,	:CONTINENT   ],

	[ "Tunisia",	"Arabic",	"Tunis",	"Africa"    ],
	[ "France",	"French",	"Paris",	"Europe"    ],
	[ "Egypt",	"English",	"Cairo",	"Africa"    ],
	[ "Belgium",	"French",	"Brussel",	"Europe"    ],
	[ "Yemen",	"Arabic",	"Sanaa",	"Asia"	    ]
])

o1.ReplaceCols([ "___", "___", "___" ])
? o1.Show()
#-->  NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#         ___        ___       ___         ___
#         ___        ___       ___         ___
#         ___        ___       ___         ___
#     Belgium     French   Brussel      Europe
#       Yemen     Arabic     Sanaa        Asia

o1.ReplaceColsXT([ "___", "~~~" ])
o1.Show()
#--> NATION   LANGUAGE   CAPITAL   CONTINENT
#     ------- ---------- --------- ----------
#        ___        ___       ___         ___
#        ~~~        ~~~       ~~~         ~~~
#        ___        ___       ___         ___
#        ~~~        ~~~       ~~~         ~~~
#        ___        ___       ___         ___

pf()
# Executed in 0.20 second(s)

/*---------

pr()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE,	:CAPITAL,	:CONTINENT   ],

	[ "Tunisia",	"Arabic",	"Tunis",	"Africa"    ],
	[ "France",	"French",	"Paris",	"Europe"    ],
	[ "Egypt",	"English",	"Cairo",	"Africa"    ],
	[ "Belgium",	"French",	"Brussel",	"Europe"    ],
	[ "Yemen",	"Arabic",	"Sanaa",	"Asia"	    ]
])

o1.ReplaceTheseCols( [ :LANGUAGE, :CONTINENT ], [ "___", "___", "___" ] )
? o1.Show()
#-->  NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia        ___     Tunis         ___
#      France        ___     Paris         ___
#       Egypt        ___     Cairo         ___
#     Belgium     French   Brussel      Europe
#       Yemen     Arabic     Sanaa        Asia

o1.ReplaceTheseColsXT( [ :LANGUAGE, :CONTINENT ], [ "___", "~~~" ] )
o1.Show()
#-->  NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia        ___     Tunis         ___
#      France        ~~~     Paris         ~~~
#       Egypt        ___     Cairo         ___
#     Belgium        ~~~   Brussel         ~~~
#       Yemen        ___     Sanaa         ___

pf()
# Executed in 0.22 second(s)

/*---------

pr()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE,	:CAPITAL,	:CONTINENT   ],

	[ "Tunisia",	"Arabic",	"Tunis",	"Africa"    ],
	[ "France",	"French",	"Paris",	"Europe"    ],
	[ "Egypt",	"English",	"Cairo",	"Africa"    ],
	[ "Belgium",	"French",	"Brussel",	"Europe"    ],
	[ "Yemen",	"Arabic",	"Sanaa",	"Asia"	    ]
])

o1.ReplaceTheseRows( [ 3, 5 ], [ "___", "___", "___" ] )
? o1.Show()
#-->   NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia     Arabic     Tunis      Africa
#      France     French     Paris      Europe
#         ___        ___       ___      Africa
#     Belgium     French   Brussel      Europe
#         ___        ___       ___        Asia

o1.ReplaceTheseRowsXT( [ 3, 5 ], [ "___", "~~~" ] )
o1.Show()
#-->  NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia     Arabic     Tunis      Africa
#      France     French     Paris      Europe
#         ___        ~~~       ___         ~~~
#     Belgium     French   Brussel      Europe
#         ___        ~~~       ___         ~~~

pf()
# Executed in 0.26 second(s)

/*---------

pr()

o1 = new stzTable([
	[ :NATION,	:LANGUAGE,	:CAPITAL,	:CONTINENT   ],

	[ "Tunisia",	"Arabic",	"Tunis",	"Africa"    ],
	[ "France",	"French",	"Paris",	"Europe"    ],
	[ "Egypt",	"English",	"Cairo",	"Africa"    ],
	[ "Belgium",	"French",	"Brussel",	"Europe"    ],
	[ "Yemen",	"Arabic",	"Sanaa",	"Asia"	    ]
])

o1.ReplaceCells(
	[ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 3, 3 ], [ 4, 3 ] ],
	:By = "___"
)
? o1.Show()
#-->   NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia     Arabic     Tunis      Africa
#      France     French     Paris      Europe
#         ___        ___       ___      Africa
#     Belgium     French   Brussel      Europe
#         ___        ___       ___        Asia

o1.ReplaceCellsByMany( 
	[ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 3, 3 ], [ 4, 3 ] ],
	:By = [ "~~~", "~~~", "~~~" ]
)
? o1.Show()
#-->   NATION   LANGUAGE   CAPITAL   CONTINENT
#     -------- ---------- --------- ----------
#     Tunisia        ~~~     Tunis      Africa
#      France        ~~~     Paris      Europe
#       Egypt        ~~~       ___         ___
#     Belgium     French   Brussel      Europe
#       Yemen     Arabic     Sanaa        Asia

o1.ReplaceCellsByManyXT( 
	[ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 3, 3 ], [ 4, 3 ] ],
	:By = [ "^^v^^", "~~^~~" ]
)
o1.Show()
#-->  NATION   LANGUAGE   CAPITAL   CONTINENT
#    -------- ---------- --------- ----------
#    Tunisia      ^^v^^     Tunis      Africa
#     France      ~~^~~     Paris      Europe
#      Egypt      ^^v^^     ~~^~~       ^^v^^
#    Belgium     French   Brussel      Europe
#      Yemen     Arabic     Sanaa        Asia

pf()
# Executed in 0.21 second(s)

/*=========

pr()

o1 = new stzTable([
	[ "NATION", "LANGUAGE", "CAPITAL", "CONTINENT" ],

	[ "Tunisia", "Arabic", "Tunis", "Africa" ],
	[ "France", "French", "Paris", "Europe" ],
	[ "Egypt", "English", "Cairo", "Africa" ]
])

o1.Show()

#--> NATION   LANGUAGE   CAPITAL   CONTINENT
#   -------- ---------- --------- ----------
#   Tunisia     Arabic     Tunis      Africa
#    France     French     Paris      Europe
#     Egypt    English     Cairo      Africa

pf()
# Executed in 0.10 second(s)

/*---------

pr()

? Q(:FromFile = "mytable.csv").IsFromFileNamedParam()

pf()
# Executed in 0.02 second(s)

/*----------

pr()

o1 = new stzTable([
	[ :NAME, :HOBBIES		],
	[ "kim", [ "Sport", "Music" ]	],
	[ "Dan", [ "Gaming" ]		],
	[ "Sam", [ "Music", "Travel" ]	]
])

o1.Show()
#--> NAME                HOBBIES
#   ----- ----------------------
#    kim    [ "Sport", "Music" ]
#    Dan            [ "Gaming" ]
#    Sam   [ "Music", "Travel" ]

pf()
# Executed in 0.11 second(s)

#============

pr()

o1 = new stzTable([

	[ "COUNTRY",	"INCOME",	"POPULATION" 	],
	#-----------------------------------------------#
	[ "USA",	   25450,	        340.1	],
	[ "China",	   18150,	       1430.1	],
	[ "Japan",	    5310,		123.2	],
	[ "Germany",	    4490,	         83.3	],
	[ "India",	    3370,	       1430.2	]

])

o1.InsertRow(3, [ "Niger", 3616, 26.21 ])
o1.Show()

#--> COUNTRY   INCOME   POPULATION
#    -------- -------- -----------
#        USA    25450       340.10
#      China    18150      1430.10
#      Niger     3616        26.21
#      Japan     5310       123.20
#    Germany     4490        83.30
#      India     3370      1430.20

pf()
# Executed in 0.02 second(s) without the Show() function
# Executed in 0.10 second(s) with the Show() function

/*-----------

pr()

o1 = new stzTable([

	[ "COUNTRY",	"INCOME",	"POPULATION" 	],
	#-----------------------------------------------#
	[ "USA",	   25450,	        340.1	],
	[ "China",	   18150,	       1430.1	],
	[ "Japan",	    5310,		123.2	],
	[ "Germany",	    4490,	         83.3	],
	[ "India",	    3370,	       1430.2	]

])

o1.InsertRowAt([ 2, 4, 5 ] , [ "~~~~~~~~", "~~~~~~~~", "~~~~~~~~" ])
# Or InsertRowAtPositions() or InsertRow() or InsertRowAt() or
# InsertRow( :At = ...) or InsertRow( :AtPositions = ...)

o1.Show()
#-->  COUNTRY     INCOME   POPULATION
#    --------- ---------- -----------
#         USA      25450       340.10
#    ~~~~~~~~   ~~~~~~~~     ~~~~~~~~
#       China      18150      1430.10
#       Japan       5310       123.20
#    ~~~~~~~~   ~~~~~~~~     ~~~~~~~~
#     Germany       4490        83.30
#    ~~~~~~~~   ~~~~~~~~     ~~~~~~~~
#       India       3370      1430.20

pf()
# Executed in 0.13 second(s)

/*-----------

pr()

# Income in million dollars per year
# Population in million people
# Percapiat (calculated) in thousand dollars per year
# Source: WolframAlpha

o1 = new stzTable([

	[ "COUNTRY",	"INCOME",	"POPULATION" 	],
	#-----------------------------------------------#
	[ "USA",	   25450,	        340.1	],
	[ "China",	   18150,	       1430.1	],
	[ "Japan",	    5310,			123.2	],
	[ "Germany",    4490,	         83.3	],
	[ "India",	    3370,	       1430.2	]

])

o1.AddCalculatedCol(:PERCAPITA, '@(:INCOME) / @(:POPULATION)')
? o1.Show()
#--> COUNTRY   INCOME   POPULATION   PERCAPITA
#    -------- -------- ------------ ----------
#        USA    25450          340       74.85
#      China    18150         1430       12.69
#      Japan     5310          123       43.17
#    Germany     4490        83.30       53.90
#      India     3370         1430        2.36

o1.InsertCalculatedCol(2, :CURRENCY, 'StzCountryQ(@(:COUNTRY)).CurrencyAbbreviation()')
? o1.Show()
#-->
# COUNTRY   CURRENCY   INCOME   POPULATION   PERCAPITA
# -------- ---------- -------- ------------ ----------
#     USA        USD    25450       340.10       74.83
#   China        CNY    18150      1430.10       12.69
#   Japan        JPY     5310       123.20       43.10
# Germany        EUR     4490        83.30       53.90
#   India        INR     3370      1430.20        2.36

? @@( o1.FindCalculatedCols() ) + NL
#--> [ 2, 4 ]

? o1.CalculatedColNames()
#--> [ "currency", "population" ]

? @@NL( o1.CalculatedCols() ) + NL
#--> [
#	[ "USD", "CNY", "JPY", "EUR", "INR" ],
#	[ 340.10, 1430.10, 123.20, 83.30, 1430.20 ]
# ]

#--

o1.AddCalculatedRow([
'', '', '@Sum( @(:INCOME) )', '@Sum( @(:POPULATION) )', '@Average( @(:PERCAPITA) )'
])

? o1.Show()

#--> COUNTRY   INCOME   POPULATION   PERCAPITA
#    -------- -------- ------------ ----------
#        USA    25450       340.10       74.83
#      China    18150      1430.10       12.69
#      Japan     5310       123.20       43.10
#    Germany     4490        83.30       53.90
#      India     3370      1430.20        2.36
#               56770      3406.90       37.38

? @@( o1.FindCalculatedRows() ) + NL
#--> [ 6 ]

? @@( o1.CalculatedRows() ) + NL
#--> [ [ " ", " ", 56770, 3406.90, 37.38 ] ]

pf()
# Executed in 0.52 second(s)

/*---------

pr()

o1 = new stzTable([
	[ :NAME,	:AGE,	:JOB ],
	[ "Folla",	22,	"Singer" ],
	[ "Warda",	28,	"Painter"],
	[ "Yasmine",	24,	"Danser" ]
])
? o1.Show()

#-->     NAME   AGE       JOB
#     -------- ----- --------
#       Folla    22    Singer
#       Warda    28   Painter
#     Yasmine    24    Danser

o1.InsertCol(3, [ :HOBBY, [ "Music", "Painting" ] ])
? o1.Show()

#-->    NAME   AGE       JOB      HOBBY
#    -------- ----- --------- ---------
#      Folla    22    Singer      Music
#      Warda    28   Painter   Painting
#    Yasmine    24    Danser         ""  

pf()
# Executed in 0.15 second(s)

#=================

pr()

o1 = new stzTable([])

? o1.IsEmpty()
#--> TRUE

? o1.NumberOfCols()
#--> 1

? o1.NumberOfRows()
#--> 1

? o1.Show()

#-->
# ╭──────╮
# │ Col1 │
# ├──────┤
# │      │
# ╰──────╯

cCSV = 'NATION;LANGUAGE;CAPITAL;CONTINENT
Tunisia;Arabic;Tunis;Africa
France;French;Paris;Europe
Egypt;English;Cairo;Africa
Belgium;French;Brussel;Europe
Yemen;Arabic;Sanaa;Asia'

o1.FromCSV(cCSV)
o1.Show()

#-->
# ╭─────────┬──────────┬─────────┬───────────╮
# │ Nation  │ Language │ Capital │ Continent │
# ├─────────┼──────────┼─────────┼───────────┤
# │ Tunisia │ Arabic   │ Tunis   │ Africa    │
# │ France  │ French   │ Paris   │ Europe    │
# │ Egypt   │ English  │ Cairo   │ Africa    │
# │ Belgium │ French   │ Brussel │ Europe    │
# │ Yemen   │ Arabic   │ Sanaa   │ Asia      │
# ╰─────────┴──────────┴─────────┴───────────╯

? o1.ToCSV()
#-->
'nation;language;capital;continent
Tunisia;Arabic;Tunis;Africa
France;French;Paris;Europe
Egypt;English;Cairo;Africa
Belgium;French;Brussel;Europe
Yemen;Arabic;Sanaa;Asia'

pf()
# Executed in 0.23 second(s) without the Show() functions
# Executed in 0.33 second(s) with the Show() functions

/*==============

pr()

? @@( @SortListsOn(2, [ [ 2, 2 ], [ 2, 4 ] ] ) ) # You can put the list before and it worlks!
#--> [ [ 2, 2 ], [ 2, 4 ] ]

? @@( @SortLists([ [ 2, 2 ], [ 2, 4 ] ]) ) # Uses SortOn(1, )
#--> [ [ 2, 2 ], [ 2, 4 ] ]

? @@( StzListOfPairsQ([ [ 2, 2 ], [ 2, 4 ] ]).SortedOn(2) ) + NL
#--> [ [ 2, 2 ], [ 2, 4 ] ]

# If the column of sort is the last column in the list, and
# if it is made of the same item, then sort is performed
# on the column just before

? @@NL( SortListsOn( 1, [

	[ 2, 3, 1 ],
	[ 4, 2, 1 ],
	[ 7, 4, 1 ]

]) ) + NL
#--> [
#	[ 2, 3, 1 ],
#	[ 4, 2, 1 ],
#	[ 7, 4, 1 ]
# ]

? @@NL( SortListsOn( 3, [

	[ 3, 1, 5 ],
	[ 7, 1, 3 ],
	[ 2, 1, 3 ]

]) ) + NL
#--> [
#	[ 2, 1, 3 ],
#	[ 7, 1, 3 ],
#	[ 3, 1, 5 ]
# ]

pf()
# Executed in 0.06 second(s) in Ring 1.22
# Executed in 0.11 second(s) in Ring 1.20

/*---------- #narration

pr()

# If the column of sort is uniform (made of same item),
# Softanza looks backward to the columns coming before.

# If a column with distinct items is found, the sort
# is made on it.

# Otherwise, it goes forward and checks the columns
# coming after and does the same thing.

# If a column with distinct items is found, the sort
# is made on it.

# Otherwise, all columns are made of same items, and
# no sort is performed.

? @@NL( SortListsOn( 3, [

	[ 1, 1, 1, 3, 1 ],
	[ 1, 1, 1, 7, 1 ],
	[ 1, 1, 1, 2, 1 ]

]) )
#--> [
#	[ 1, 1, 1, 2, 1 ],
#	[ 1, 1, 1, 3, 1 ],
#	[ 1, 1, 1, 7, 1 ]
# ]

pf()
# Executed in 0.04 second(s)

/*---------

pr()

o1 = new stzTable([

	[ "COUNTRY",	"INCOME",	"POPULATION" 	],
	#-----------------------------------------------#
	[ "USA",	   25450,	        340.1	],
	[ "China",	   18150,	       1430.1	],
	[ "Japan",	    5310,		123.2	],
	[ "Germany",	    4490,	         83.3	],
	[ "India",	    3370,	       1430.2	]

])

? @@( o1.FindSection([ :INCOME, 3 ], [ :POPULATION, 3 ]) ) + NL # OR FindCellsInSection()
#--> [ [ 2, 3 ], [ 2, 4 ], [ 2, 5 ], [ 3, 1 ], [ 3, 2 ], [ 3, 3 ] ]

? @@( o1.FindSection([ :INCOME, 3 ], [ :POPULATION, 1 ]) ) + NL
#--> [ [ 2, 3 ], [ 2, 4 ], [ 2, 5 ], [ 3, 1 ] ]

? @@( o1.FindSection([ :INCOME, 2 ], [ :INCOME, 5 ]) ) + NL
#--> [ [ 2, 2 ], [ 2, 3 ], [ 2, 4 ], [ 2, 5 ] ]

? @@( o1.FindSection([ :POPULATION, 2 ], [ :POPULATION, 4 ]) ) + NL
# [ [ 3, 2 ], [ 3, 3 ], [ 3, 4 ] ]

pf()
# Executed in 0.06 second(s)

/*========= EXCEL-Like functions

pr()

o1 = new stzTable([

	[ "A", "B", "C" ],

	[  12,  10,   8 ],
	[  10,  14,  24 ],
	[   7,   4,   8 ]

])

? o1.KOUNT([ :A, 1 ], [ :C, 3 ]) # We use "K" because we have an other Count() method
#--> 9

? o1.SUM([ :A, 1 ], [ :C, 3 ])
#--> 97

? o1.AVERAGE([ :A, 1 ], [ :C, 3 ])
#--> 10.78

? o1.PRODUCT([ :A, 1 ], [ :C, 3 ])
#--> 722_534_400

? o1.MAX([ :A, 1 ], [ :C, 3 ])
#--> 24

? o1.MIN([ :A, 1 ], [ :C, 3 ])
#--> 4

pf()
# Executed in 0.13 second(s) in Ring 1.22

/*=====

pr()

? IsNumberInString("08/27/2015")
#--> FALSE

? rx(pat(:number)).match("08/27/2015")
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---- Ring vs Softanza file read()
*/
pr()

# The file "tabdata.csv" contains this:

'tree_id;block_id;created_at;tree_dbh;alive
180683;348711;08/27/2015;3;Alive
200540;315986;09/03/2015;21;Alive
204026;218365;09/05/2015;3;Dead
204337;217969;09/05/2015;10;Alive
189565;223043;08/30/2015;21;Alive
190422;106099;08/30/2015;11;Dead
190426;106099;08/30/2015;11;Alive
208649;103940;09/07/2015;9;Alive
209610;407443;09/08/2015;6;Alive
180683;348711;08/27/2015;3;Alive
'

# Let's ceate an empty stzTable object

o1 = new stzTable([])

# The goal is to import the external CSV file inside the table
# To do that, and since stzTable deal only with CSV string and
# has no access to external files, we need to manually read the
# content of the file and store it in a string variable.

# Let's do it first using Ring standart read() function

str = read("tabdata.csv") # EOLs (End-Of-File chars are platform specific)
? o1.FromCSV(str)		 # And hence lines internal split is not correct

o1.Show()
# You will notice that header row is misaligned due to hidden EOL issues
# Each data row also includes extra newlines
#-->                        
'                           
╭─────────┬──────────┬────────────┬──────────┬────────╮
│ Tree_id │ Block_id │ Created_at │ Tree_dbh │ Alive
 │
├─────────┼──────────┼────────────┼──────────┼────────┤
│  180683 │   348711 │ 08/27/2015 │        3 │ Alive
 │
│  200540 │   315986 │ 09/03/2015 │       21 │ Alive
 │
│  204026 │   218365 │ 09/05/2015 │        3 │ Dead
  │
│  204337 │   217969 │ 09/05/2015 │       10 │ Alive
 │
│  189565 │   223043 │ 08/30/2015 │       21 │ Alive
 │
│  190422 │   106099 │ 08/30/2015 │       11 │ Dead
  │
│  190426 │   106099 │ 08/30/2015 │       11 │ Alive
 │
│  208649 │   103940 │ 09/07/2015 │        9 │ Alive
 │
│  209610 │   407443 │ 09/08/2015 │        6 │ Alive
 │
│  180683 │   348711 │ 08/27/2015 │        3 │ Alive  │
╰─────────┴──────────┴────────────┴──────────┴────────╯
'

# Solved automatically Using Softanza stzFile object

oFile = new stzFile("tabdata.csv", :ReadOnly)  # stzFile handles EOLs uniformly
str = oFile.Content()                          # retrieves clean text content

o1.FromCSV(str) # correctly parsed and formatted

o1.Show()
# Output is clean, compact and platform-independent
#-->
'
╭─────────┬──────────┬────────────┬──────────┬───────╮
│ Tree_id │ Block_id │ Created_at │ Tree_dbh │ Alive │
├─────────┼──────────┼────────────┼──────────┼───────┤
│  180683 │   348711 │ 08/27/2015 │        3 │ Alive │
│  200540 │   315986 │ 09/03/2015 │       21 │ Alive │
│  204026 │   218365 │ 09/05/2015 │        3 │ Dead  │
│  204337 │   217969 │ 09/05/2015 │       10 │ Alive │
│  189565 │   223043 │ 08/30/2015 │       21 │ Alive │
│  190422 │   106099 │ 08/30/2015 │       11 │ Dead  │
│  190426 │   106099 │ 08/30/2015 │       11 │ Alive │
│  208649 │   103940 │ 09/07/2015 │        9 │ Alive │
│  209610 │   407443 │ 09/08/2015 │        6 │ Alive │
│  180683 │   348711 │ 08/27/2015 │        3 │ Alive │
╰─────────┴──────────┴────────────┴──────────┴───────╯
'

pf()
#--> Executed in 0.88 second(s) in Ring 1.22


/*=== Filtering stzTable

pr()

# Note: It's more efficient to provide the data in this hashlist format:
#
# o1 = new stzTable([
#     :Region = [
# 		"North", "South", "East",
# 		"West", "North", "South",
# 		"East", "West"
# 	],
# 
#    :Product = [
# 		"Product A", "Product A", "Product A",
# 		"Product A", "Product B", "Product B",
# 		"Product B", "Product B"
# 	],
# 
#     :Quarter = [
# 		"Q1", "Q1", "Q1",
# 		"Q1", "Q2", "Q1",
# 		"Q2", "Q1"
# 	],
# 
#     :Sales = [ 10000, 15000, 11000, 13000, 8000, 9500, 7500, 9000 ],
# 
#     :Units = [ 100, 150, 110, 130, 80, 95, 75, 90 ]
# ]
# 
# This is because the object internally stores its data in this format,
# making it more performant.
# 
# However, in the following example, we use a more expressive structure
# that's easier to read and understand.


o1 = new stzTable([

	[ :Region,	:Product,	:Quarter,	:Sales,	:Units ],

	[ "North",	"Product A",	"Q1",	10000,		100 ],
	[ "South",  "Product A",	"Q1",	15000,		150	],
	[ "East",	"Product A",	"Q1",	11000,		110 ],
	[ "West",	"Product A",	"Q1",	13000,		130 ],
	[ "North",	"Product B",	"Q2",	 8000,		 80 ],
	[ "South",	"Product B",	"Q1",	 9500,		 95 ],
	[ "East",	"Product B",	"Q2",	 7500,		 75 ],
	[ "West",	"Product B",	"Q1",	 9000,		 90 ]
])

# Filter by Single Region (on a copy of the table ~> CQ extension)
#~> The original content is not affected by the filter

o1.FilterByCQ([ :Region = "North", :Quarter = "Q2" ]).Show()
#-->
# ╭────────┬───────────┬─────────┬───────┬───────╮
# │ Region │  Product  │ Quarter │ Sales │ Units │
# ├────────┼───────────┼─────────┼───────┼───────┤
# │ North  │ Product B │ Q2      │  8000 │    80 │
# ╰────────┴───────────┴─────────┴───────┴───────╯

# Full table display (because the filter above operated on
# a copy of the table ane left the original content intact)

o1.Show()
#-->
# ╭────────┬───────────┬─────────┬───────┬───────╮
# │ Region │  Product  │ Quarter │ Sales │ Units │
# ├────────┼───────────┼─────────┼───────┼───────┤
# │ North  │ Product A │ Q1      │ 10000 │   100 │
# │ South  │ Product A │ Q1      │ 15000 │   150 │
# │ East   │ Product A │ Q1      │ 11000 │   110 │
# │ West   │ Product A │ Q1      │ 13000 │   130 │
# │ North  │ Product B │ Q2      │  8000 │    80 │
# │ South  │ Product B │ Q1      │  9500 │    95 │
# │ East   │ Product B │ Q2      │  7500 │    75 │
# │ West   │ Product B │ Q1      │  9000 │    90 │
# ╰────────┴───────────┴─────────┴───────┴───────╯

# Filtering the table only North region)
#~> Now it's content is update to have only the filtered data

o1.FilterBy([ :Region = "North" ])
o1.Show()
#-->
# ╭────────┬───────────┬─────────┬───────┬───────╮
# │ Region │  Product  │ Quarter │ Sales │ Units │
# ├────────┼───────────┼─────────┼───────┼───────┤
# │ North  │ Product A │ Q1      │ 10000 │   100 │
# │ North  │ Product B │ Q2      │  8000 │    80 │
# ╰────────┴───────────┴─────────┴───────┴───────╯

pf()
# Executed in 0.26 second(s) in Ring 1.22

/*--- Filter by Region and Quarter

pr()

o1 = new stzTable([

    :Region = [
		"North", "South", "East",
		"West", "North", "South",
		"East", "West"
	],

    :Product = [
		"Product A", "Product A", "Product A",
		"Product A", "Product B", "Product B",
		"Product B", "Product B"
	],

    :Quarter = [ "Q1", "Q1", "Q1", "Q1", "Q1", "Q1", "Q1", "Q1" ],
    :Sales = [ 10000, 15000, 11000, 13000, 8000, 9500, 7500, 9000 ],
    :Units = [ 100, 150, 110, 130, 80, 95, 75, 90 ]

])

# Returns a table with only East region, Q1 quarter rows

o1.FilterByCQ([
    :Region = "East",
    :Quarter = "Q1"
]).Show()
#-->
# ╭────────┬───────────┬─────────┬───────┬───────╮
# │ Region │  Product  │ Quarter │ Sales │ Units │
# ├────────┼───────────┼─────────┼───────┼───────┤
# │ East   │ Product A │ Q1      │ 11000 │   110 │
# │ East   │ Product B │ Q1      │  7500 │    75 │
# ╰────────┴───────────┴─────────┴───────┴───────╯

# Filter with Multiple Region Values and a given product

o1.FilterByCQ([ 
    :Region = [ "East", "West" ], 
    :Product = "Product A"
]).Show()
#-->
# ╭────────┬───────────┬─────────┬───────┬───────╮
# │ Region │  Product  │ Quarter │ Sales │ Units │
# ├────────┼───────────┼─────────┼───────┼───────┤
# │ East   │ Product A │ Q1      │ 11000 │   110 │
# │ West   │ Product A │ Q1      │ 13000 │   130 │
# ╰────────┴───────────┴─────────┴───────┴───────╯

pf()
# Executed in 0.12 second(s) in Ring 1.22

/*===

pr()

o1 = new stzString("Mansour Ayouni")
? o1.Before("Ayouni")
#--> 'Mansour '

? o1.After("Mansour")
#--> ' Ayouni'

pf()
# Executed in 0.01 second(s) in Ring 1.22

#TODO Add the same feature in stzList

/*---

/*--- Conditional filtering

pr()

o1 = new stzTable([
    [ :Productivity, :Hours ],
    [ 10, 5 ],
    [ 7, 3 ],
    [ 9, 4 ]
])

o1.Show()
#-->
# ╭──────────────┬───────╮
# │ Productivity │ Hours │
# ├──────────────┼───────┤
# │           10 │     5 │
# │            7 │     3 │
# │            9 │     4 │
# ╰──────────────┴───────╯

o1.FilterWQ('@(:Productivity) > 8').Show()
#-->
# ╭──────────────┬───────╮
# │ Productivity │ Hours │
# ├──────────────┼───────┤
# │           10 │     5 │
# │            9 │     4 │
# ╰──────────────┴───────╯

o1.FilterWQ('@(:Productivity) > 8 and @(:Hours) >= 5').Show()
#-->
# ╭──────────────┬───────╮
# │ Productivity │ Hours │
# ├──────────────┼───────┤
# │           10 │     5 │
# ╰──────────────┴───────╯

pf()
# Executed in 0.09 second(s) in Ring 1.22

/*--- Grouping Tests

pr()

o1 = new stzTable([

	[ :Region,	:Product,	:Quarter,	:Sales,	:Units ],

	[ "North",	"Product A",	"Q1",	10000,		100 ],
	[ "South",  "Product A",	"Q1",	15000,		150	],
	[ "East",	"Product A",	"Q1",	11000,		110 ],
	[ "West",	"Product A",	"Q1",	13000,		130 ],
	[ "North",	"Product B",	"Q2",	 8000,		 80 ],
	[ "South",	"Product B",	"Q1",	 9500,		 95 ],
	[ "East",	"Product B",	"Q2",	 7500,		 75 ],
	[ "West",	"Product B",	"Q1",	 9000,		 90 ]
])

# Group by Single Column

o1.GroupBy([ :Region ])

o1.Show()
#-->
# ╭────────┬───────────┬─────────┬───────┬───────╮
# │ Region │  Product  │ Quarter │ Sales │ Units │
# ├────────┼───────────┼─────────┼───────┼───────┤
# │ North  │ Product A │ Q1      │ 10000 │   100 │
# │ South  │ Product A │ Q1      │ 15000 │   150 │
# │ East   │ Product A │ Q1      │ 11000 │   110 │
# │ West   │ Product A │ Q1      │ 13000 │   130 │
# ╰────────┴───────────┴─────────┴───────┴───────╯

pf()
# Executed in 0.10 second(s) in Ring 1.22

/*--- Group by Multiple Columns

pr()

o1 = new stzTable([

	[ :Region,	:Product,	:Quarter,	:Sales,	:Units ],

	[ "North",	"Product A",	"Q1",	10000,		100 ],
	[ "South",  "Product A",	"Q1",	15000,		150	],
	[ "East",	"Product A",	"Q1",	11000,		110 ],
	[ "West",	"Product A",	"Q1",	13000,		130 ],
	[ "North",	"Product B",	"Q2",	 8000,		 80 ],
	[ "South",	"Product B",	"Q1",	 9500,		 95 ],
	[ "East",	"Product B",	"Q2",	 7500,		 75 ],
	[ "West",	"Product B",	"Q1",	 9000,		 90 ]
])

o1.Show()

# Detailed grouping by Region and Product

o1.GroupBy([ :Product, :Region ], [ :Sales = 'Sum', :Units = 'Average' ])
o1.Show()
#-->
# ╭────────┬───────────┬────────┬───────────┬─────────┬───────┬───────╮
# │ Region │  Product  │ Region │  Product  │ Quarter │ Sales │ Units │
# ├────────┼───────────┼────────┼───────────┼─────────┼───────┼───────┤
# │ North  │ Product A │ North  │ Product A │ Q1      │ 10000 │   100 │
# │ South  │ Product A │ South  │ Product A │ Q1      │ 15000 │   150 │
# │ East   │ Product A │ East   │ Product A │ Q1      │ 11000 │   110 │
# │ West   │ Product A │ West   │ Product A │ Q1      │ 13000 │   130 │
# │ North  │ Product B │ North  │ Product B │ Q2      │  8000 │    80 │
# │ South  │ Product B │ South  │ Product B │ Q1      │  9500 │    95 │
# │ East   │ Product B │ East   │ Product B │ Q2      │  7500 │    75 │
# │ West   │ Product B │ West   │ Product B │ Q1      │  9000 │    90 │
# ╰────────┴───────────┴────────┴───────────┴─────────┴───────┴───────╯

o1.ShowXT(:SubTotal = TRUE, :GrandTotal = TRUE)
#-->
# ╭─────────────────┬────────┬────────────┬────────────╮
# │     Product     │ Region │ Sum(sales) │ Sum(units) │
# ├─────────────────┼────────┼────────────┼────────────┤
# │ Product A       │ North  │      10000 │        100 │
# │ Product A       │ South  │      15000 │        150 │
# │ Product A       │ East   │      11000 │        110 │
# │ Product A       │ West   │      13000 │        130 │
# │ --------------- │ ------ │ ---------- │ ---------- │
# │       Sub-total │        │      49000 │        490 │
# │                 │        │            │            │
# │ Product B       │ North  │       8000 │         80 │
# │ Product B       │ South  │       9500 │         95 │
# │ Product B       │ East   │       7500 │         75 │
# │ Product B       │ West   │       9000 │         90 │
# │ --------------- │ ------ │ ---------- │ ---------- │
# │       Sub-total │        │      34000 │        340 │
# ├─────────────────┼────────┼────────────┼────────────┤
# │     GRAND-TOTAL │        │      83000 │        830 │
# ╰─────────────────┴────────┴────────────┴────────────╯

pf()
# Executed in 0.36 second(s) in Ring 1.22

/*--- Aggregation

pr()

o1 = new stzTable([

	[ :Region,	:Product,	:Quarter,	:Sales,	:Units ],

	[ "North",	"Product A",	"Q1",	10000,		100 ],
	[ "South",  "Product A",	"Q1",	15000,		150	],
	[ "East",	"Product A",	"Q1",	11000,		110 ],
	[ "West",	"Product A",	"Q1",	13000,		130 ],
	[ "North",	"Product B",	"Q2",	 8000,		 80 ],
	[ "South",	"Product B",	"Q1",	 9500,		 95 ],
	[ "East",	"Product B",	"Q2",	 7500,		 75 ],
	[ "West",	"Product B",	"Q1",	 9000,		 90 ]
])

# Single Column Aggregation : Calculates total Sales

o1.Aggregate([ :Sales = 'SUM' ])
o1.Show()
#-->
# ╭────────────╮
# │ Sum(sales) │
# ├────────────┤
# │      83000 │
# ╰────────────╯

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Multiple Aggregations

pr()

o1 = new stzTable([

	[ :Region,	:Product,	:Quarter,	:Sales,	:Units ],

	[ "North",	"Product A",	"Q1",	10000,		100 ],
	[ "South",  "Product A",	"Q1",	15000,		150	],
	[ "East",	"Product A",	"Q1",	11000,		110 ],
	[ "West",	"Product A",	"Q1",	13000,		130 ],
	[ "North",	"Product B",	"Q2",	 8000,		 80 ],
	[ "South",	"Product B",	"Q1",	 9500,		 95 ],
	[ "East",	"Product B",	"Q2",	 7500,		 75 ],
	[ "West",	"Product B",	"Q1",	 9000,		 90 ]
])

# Calculating Sum of Sales, Average of Units, Count of Products

o1.Aggregate([
    :Sales 		= 'SUM',
    :Units 		= 'AVERAGE',
    :Product 	= 'COUNT'
])

o1.Show()
#-->
# ╭────────────┬────────────────┬────────────────╮
# │ Sum(sales) │ Average(units) │ Count(product) │
# ├────────────┼────────────────┼────────────────┤
# │      83000 │         103.75 │              8 │
# ╰────────────┴────────────────┴────────────────╯

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*================ GROUP BY + AGGREGATE --> GroupByXT()

pr()

# Creating a sales data table

o1 = new stzTable([
    [ :Region,  :Product,  :Quarter, :Sales,  :Units ],
    
    [ "North",  "Product A", "Q1",     10000,   100  ],
    [ "North",  "Product A", "Q2",     12000,   120  ],
    [ "North",  "Product B", "Q1",      8000,    80  ],
    [ "North",  "Product B", "Q2",      9500,    95  ],
    [ "South",  "Product A", "Q1",     15000,   150  ],
    [ "South",  "Product A", "Q2",     16500,   165  ],
    [ "South",  "Product B", "Q1",      9500,    95  ],
    [ "South",  "Product B", "Q2",     11000,   110  ],
    [ "East",   "Product A", "Q1",     11000,   110  ],
    [ "East",   "Product A", "Q2",     12500,   125  ],
    [ "East",   "Product B", "Q1",      7500,    75  ],
    [ "East",   "Product B", "Q2",      8500,    85  ],
    [ "West",   "Product A", "Q1",     13000,   130  ],
    [ "West",   "Product A", "Q2",     14500,   145  ],
    [ "West",   "Product B", "Q1",      9000,    90  ],
    [ "West",   "Product B", "Q2",     10500,   105  ]
])

# Group by Region with sum aggregation

oCopy = o1.Copy()

oCopy.GroupByXT([ :Region ], [ :Sales = 'Sum', :Units = 'Sum' ] )

# Group by Region with Sales and Units summed

oCopy.Show()
#-->
# ╭────────┬────────────┬───────────╮
# │ Region │ Sum(Sales) │ Sum(Units)│
# ├────────┼────────────┼───────────┤
# │ North  │     39500  │       395 │
# │ South  │     52000  │       520 │
# │ East   │     39500  │       395 │
# │ West   │     47000  │       470 │
# ╰────────┴────────────┴───────────╯

# Group by Region and Product with multiple aggregations

oCopy = o1.Copy()

oCopy.GroupByXT([:Region, :Product], [
    :Sales = 'Sum',
    :Units = 'Average'
])

# Group by Region and Product with sum of Sales and average Units

oCopy.Show()
#-->
# ╭────────┬───────────┬────────────┬───────────────╮
# │ Region │ Product   │ Sum(Sales) │ Average(Units)│
# ├────────┼───────────┼────────────┼───────────────┤
# │ North  │ Product A │     22000  │          110  │
# │ North  │ Product B │     17500  │           87.5│
# │ South  │ Product A │     31500  │          157.5│
# │ South  │ Product B │     20500  │          102.5│
# │ East   │ Product A │     23500  │          117.5│
# │ East   │ Product B │     16000  │           80  │
# │ West   │ Product A │     27500  │          137.5│
# │ West   │ Product B │     19500  │           97.5│
# ╰────────┴───────────┴────────────┴───────────────╯

# Group by Quarter with min/max aggregations

oCopy = o1.Copy()
oCopy.GroupByXT([:Quarter], [
    :Sales = 'Max',
    :Sales = 'Min',
    :Units = 'Count'
])

# Group by Quarter with max/min Sales and count of Units
oCopy.Show()
#-->
# ╭─────────┬────────────┬────────────┬─────────────╮
# │ Quarter │ Max(Sales) │ Min(Sales) │ Count(Units)│
# ├─────────┼────────────┼────────────┼─────────────┤
# │ Q1      │     15000  │      7500  │           8 │
# │ Q2      │     16500  │      8500  │           8 │
# ╰─────────┴────────────┴────────────┴─────────────╯

# Group by Product and Quarter

oCopy = o1.Copy()
oCopy.GroupByXT([ :Product, :Quarter ],
	[ :Sales = 'Sum', :Units = 'Sum' ]
)

# Group by Product and Quarter with sums"
oCopy.Show()
#-->
# ╭───────────┬─────────┬────────────┬───────────╮
# │ Product   │ Quarter │ Sum(Sales) │ Sum(Units)│
# ├───────────┼─────────┼────────────┼───────────┤
# │ Product A │ Q1      │     49000  │       490 │
# │ Product A │ Q2      │     55500  │       555 │
# │ Product B │ Q1      │     34000  │       340 │
# │ Product B │ Q2      │     39500  │       395 │
# ╰───────────┴─────────┴────────────┴───────────╯

pf()
# Executed in 0.46 second(s) in Ring 1.22

#=== Turning the table to a pivot table

pr()
    
# Define employee data in a stzTable object

o1 = new stzTable([

	[ :Department, :Location,   :Gender,  :Experience,  "Salary"   ],
	# ------------------------------------------------------------ #
	[ "Sales",     "New York",  "Male",   "Junior",      45000    ],
	[ "Sales",     "New York",  "Female", "Junior",      46000    ],
	[ "Sales",     "New York",  "Male",   "Senior",      75000    ],
	[ "Sales",     "New York",  "Female", "Senior",      76000    ],
	[ "Sales",     "Chicago",   "Male",   "Junior",      42000    ],
	[ "Sales",     "Chicago",   "Female", "Junior",      43000    ],
	[ "Sales",     "Chicago",   "Male",   "Senior",      72000    ],
	[ "Sales",     "Chicago",   "Female", "Senior",      73000    ],
	[ "IT",        "New York",  "Male",   "Junior",      52000    ],
	[ "IT",        "New York",  "Female", "Junior",      53000    ],
	[ "IT",        "New York",  "Male",   "Senior",      85000    ],
	[ "IT",        "New York",  "Female", "Senior",      86000    ],
	[ "IT",        "Chicago",   "Male",   "Junior",      50000    ],
	[ "IT",        "Chicago",   "Female", "Junior",      51000    ],
	[ "IT",        "Chicago",   "Male",   "Senior",      82000    ],
	[ "IT",        "Chicago",   "Female", "Senior",      83000    ],
	[ "HR",        "New York",  "Male",   "Junior",      42000    ],
	[ "HR",        "New York",  "Female", "Junior",      43000    ],
	[ "HR",        "New York",  "Male",   "Senior",      68000    ],
	[ "HR",        "New York",  "Female", "Senior",      69000    ],
	[ "HR",        "Chicago",   "Male",   "Junior",      40000    ],
	[ "HR",        "Chicago",   "Female", "Junior",      41000    ],
	[ "HR",        "Chicago",   "Male",   "Senior",      65000    ],
	[ "HR",        "Chicago",   "Female", "Senior",      66000    ]
])
    
# Multi-dimensional pivot with Department/Location as rows and
# Experience/Gender as columns

o1.ToStzPivotTable() {

	Analyze([ :Salary ], :Using = :SUM)
	InRowsPut([ :Department, :Location ])
	InColsPut([ :Experience, :Gender ])

	Show()

}
#-->
#	╭───────────────────────┬─────────────────────┬─────────────────────┬─────────╮
#	│                       │       Junior        │       Senior        │         │
#	├────────────┬──────────┼──────────┬──────────┼──────────┬──────────┤         │
#	│ Department │ Location │  Female  │   Male   │  Female  │   Male   │ AVERAGE │
#	├────────────┼──────────┼──────────┼──────────┼──────────┼──────────┼─────────┤
#	│ Sales      │ New York │    46000 │          │    76000 │    75000 │  197000 │
#	│            │ Chicago  │    43000 │    42000 │    73000 │    72000 │  230000 │
#	│            │          │          │          │          │          │         │
#	│ IT         │ New York │    53000 │    52000 │    86000 │    85000 │  276000 │
#	│            │ Chicago  │    51000 │    50000 │    83000 │    82000 │  266000 │
#	│            │          │          │          │          │          │         │
#	│ HR         │ New York │    43000 │    42000 │    69000 │    68000 │  222000 │
#	│            │ Chicago  │    41000 │    40000 │    66000 │    65000 │  212000 │
#	╰────────────┴──────────┴──────────┴──────────┴──────────┴──────────┴─────────╯
#	                AVERAGE │   277000 │   226000 │   453000 │   447000 │ 1403000 

pf()
# Executed in 0.17 second(s) in Ring 1.22

/*==== Grouping data by a column containing lists

pr()

o1 = new stzTable([
	[
		"name",
		[ "Hela", "John  ", "Ali", "Foued" ]
	],
	[
		"age",
		[ 24, 32, 22, 43 ]
	],
	[
		"hobbies",
		[
			[ "Sport", "Music" ],
			[ "Games", "Travel", "Sport" ],
			[ "Painting", "Dansing" ],
			[ "Music", "Travel" ]
		]
	]
])

o1.ShowXT([ :RowNumber = TRUE ])
#-->
# ╭───┬─────────────────┬─────┬────────────────────────────────╮
# │ # │      Name       │ Age │            Hobbies             │
# ├───┼─────────────────┼─────┼────────────────────────────────┤
# │ 1 │ Hela            │  24 │ [ "Sport", "Music" ]           │
# │ 2 │ John            │  32 │ [ "Games", "Travel", "Sport" ] │
# │ 3 │ Ali             │  22 │ [ "Painting", "Dansing" ]      │
# │ 4 │ Foued           │  43 │ [ "Music", "Travel" ]          │
# ╰───┴─────────────────┴─────┴────────────────────────────────╯

o1.GroupBy(:Hobbies)
o1.Show()
#-->
# ╭──────────┬────────┬─────╮
# │ Hobbies  │  Name  │ Age │
# ├──────────┼────────┼─────┤
# │ Sport    │ Hela   │  24 │
# │ Sport    │ John   │  32 │
# │ Music    │ Hela   │  24 │
# │ Music    │ Foued  │  43 │
# │ Games    │ John   │  32 │
# │ Travel   │ John   │  32 │
# │ Travel   │ Foued  │  43 │
# │ Painting │ Ali    │  22 │
# │ Dansing  │ Ali    │  22 │
# ╰──────────┴────────┴─────╯

pf()
# Executed in 0.21 second(s) in Ring 1.22

/*---- #TODO Make a narration

pr()

cCSVTeam = 'Employee;Role;Task;Productivity
Sara;Developer;["Coding", "Debugging"];8.5
Mike;Manager;["Planning", "Review"];7.2
Lena;Designer;["UI", "Prototyping"];9.0
Omar;Developer;["Coding", "Testing"];8.0
Tara;Manager;["Planning", "Coordination"];7.8
Alex;Designer;["UI", "Animation"];8.7'

o1 = new stzTable([])
o1.FromCSV(cCSVTeam)

o1.ShowXT([ :RowNumber = TRUE ])
#-->
# ╭───┬─────────────────┬───────────┬────────────────────────────────┬──────────────╮
# │ # │    Employee     │   Role    │             Task              │ Productivity │
# ├───┼─────────────────┼───────────┼────────────────────────────────┼──────────────┤
# │ 1 │ Sara            │ Developer │ [ "Coding", "Debugging" ]      │         8.50 │
# │ 2 │ Mike            │ Manager   │ [ "Planning", "Review" ]       │         7.20 │
# │ 3 │ Lena            │ Designer  │ [ "UI", "Prototyping" ]        │            9 │
# │ 4 │ Omar            │ Developer │ [ "Coding", "Testing" ]        │            8 │
# │ 5 │ Tara            │ Manager   │ [ "Planning", "Coordination" ] │         7.80 │
# │ 6 │ Alex            │ Designer  │ [ "UI", "Animation" ]          │         8.70 │
# ╰───┴─────────────────┴───────────┴────────────────────────────────┴──────────────╯


o1.GroupBy(:Task)
o1.Show()
#-->
# ╭──────────────┬──────────┬───────────┬──────────────╮
# │    Task      │ Employee │   Role    │ Productivity │
# ├──────────────┼──────────┼───────────┼──────────────┤
# │ Coding       │ Sara     │ Developer │         8.50 │
# │ Coding       │ Omar     │ Developer │            8 │
# │ Debugging    │ Sara     │ Developer │         8.50 │
# │ Planning     │ Mike     │ Manager   │         7.20 │
# │ Planning     │ Tara     │ Manager   │         7.80 │
# │ Review       │ Mike     │ Manager   │         7.20 │
# │ UI           │ Lena     │ Designer  │            9 │
# │ UI           │ Alex     │ Designer  │         8.70 │
# │ Prototyping  │ Lena     │ Designer  │            9 │
# │ Testing      │ Omar     │ Developer │            8 │
# │ Coordination │ Tara     │ Manager   │         7.80 │
# │ Animation    │ Alex     │ Designer  │         8.70 │
# ╰──────────────┴──────────┴───────────┴──────────────╯

# Turining the table into a pivot table

oPivot = o1.ToStzPivotTable()

# Analyzing Productivity in avaerage by task and role

oPivot {

	Analyze([ :Productivity ], :In = :Average)
	By([ :Task ], :And = [ :Role ])

	Show()
}
#-->
# ╭──────────────┬─────────────────────────────────┬─────────╮
# │              │              Role               │         │
# │              │───────────┬──────────┬──────────│         │
# │     Task     │ Developer │ Manager  │ Designer │ AVERAGE │
# ├──────────────┼───────────┼──────────┼──────────┼─────────┤
# │ Coding       │         8 │          │          │       8 │
# │ Debugging    │      8.50 │          │          │    8.50 │
# │ Planning     │           │     7.50 │          │    7.50 │
# │ Review       │           │     7.20 │          │    7.20 │
# │ UI           │           │          │     8.85 │    8.85 │
# │ Prototyping  │           │          │        9 │       9 │
# │ Testing      │         8 │          │          │       8 │
# │ Coordination │           │     7.80 │          │    7.80 │
# │ Animation    │           │          │     8.70 │    8.70 │
# ╰──────────────┴───────────┴──────────┴──────────┴─────────╯
#        AVERAGE │      8.17 │     7.50 │     8.85 │    8.17  

# Pivot Table: Task Distribution

oPivot {

  Analyze([ :Employee ], :COUNT)

  SetRowsBy([ :Task ])
  SetColsBy([ :Role ])

  Show()
}
#-->
# ╭──────────────┬─────────────────────────────────┬───────╮
# │              │              Role               │       │
# │              │───────────┬──────────┬──────────│       │
# │     Task     │ Developer │ Manager  │ Designer │ COUNT │
# ├──────────────┼───────────┼──────────┼──────────┼───────┤
# │ Coding       │         1 │          │          │     1 │
# │ Debugging    │         1 │          │          │     1 │
# │ Planning     │           │        2 │          │     2 │
# │ Review       │           │        1 │          │     1 │
# │ UI           │           │          │        2 │     2 │
# │ Prototyping  │           │          │        1 │     1 │
# │ Testing      │         1 │          │          │     1 │
# │ Coordination │           │        1 │          │     1 │
# │ Animation    │           │          │        1 │     1 │
# ╰──────────────┴───────────┴──────────┴──────────┴───────╯
#         COUNT │         3 │        3 │        3 │     9  

#TODO: Check why Coding/Developer is not returning 2

# High-productivity tasks

o1.FilterW('@(:Productivity) > 8')
o1.Show()

# Critical tasks
CrticalTasks = ["Coding", "Debugging", "Planning"]
o1.AddCalculatedColumn(:Critical, ' @IF( Q(@(:Task)).ContainsOneOfThese(CrticalTasks), "YES", "NO" )')
o1.Show()


o1.ToStzPivotTable() {
  Analyze([ :Productivity ], :Average)
  InRowsPut([ :Task ])
  InColsPut([ :Role])
  Show()
}

pf()
# Executed in 1.06 second(s) in Ring 1.22


/*--- Transposing a table (swapping columns and rows)
*/
pr()


o1 = new stzTable([
	[ :ID,	 :AGE,    :SALARY	],
	#----------------------------------#
	[ 10,	 32,		35000	],
	[ 20,	 27,		28900	],
	[ 30,	 24,		25982	],
	[ 40,	 22,		12870	]
])

o1.Show()
#-->
'
╭────┬─────┬────────╮
│ Id │ Age │ Salary │
├────┼─────┼────────┤
│ 10 │  32 │  35000 │
│ 20 │  27 │  28900 │
│ 30 │  24 │  25982 │
│ 40 │  22 │  12870 │
╰────┴─────┴────────╯
'

o1.TransposeXT() # XT ~> Colnames are also transposed
o1.Show()
#-->
'
╭────────┬───────┬───────┬───────┬───────╮
│  Col1  │ Col2  │ Col3  │ Col4  │ Col5  │
├────────┼───────┼───────┼───────┼───────┤
│ id     │    10 │    20 │    30 │    40 │
│ age    │    32 │    27 │    24 │    22 │
│ salary │ 35000 │ 28900 │ 25982 │ 12870 │
╰────────┴───────┴───────┴───────┴───────╯
'

o1.TransposeBack()
o1.Show()
#-->
'
╭────┬─────┬────────╮
│ Id │ Age │ Salary │
├────┼─────┼────────┤
│ 10 │  32 │  35000 │
│ 20 │  27 │  28900 │
│ 30 │  24 │  25982 │
│ 40 │  22 │  12870 │
╰────┴─────┴────────╯
'

pf()
# Executed in 0.20 second(s) in Ring 1.22
