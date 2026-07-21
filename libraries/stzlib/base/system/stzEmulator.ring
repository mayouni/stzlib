#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZEMULATOR               #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Deploy(:Emulated) -- the programming-phase   #
#                  face of Deploy(). Generates a web-based      #
#                  mission control from a stzBuilderBrain plan: #
#                  a live solution MAP, and per part a detail   #
#                  page. A phone/mobile part is shown as a      #
#                  LARGE realistic phone running the ACTUAL app #
#                  (a real frontend in an iframe) -- you use it #
#                  like the real device; the engineering detail #
#                  hides under a collapsible. Server/MCU parts  #
#                  show a device diagram + placement. Hash      #
#                  routing so the browser Back button works.    #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# The phone panel loads a real app frontend (app_<part>.html). Today the generator
# emits a realistic STARTER app; the web-composite build will emit the solution's
# actual frontend into the same slot, and each part's engine wires in once the
# build.zig wasm target emits the plan's engine subset.
#
#   oBrain = new stzBuilderBrain("restolean")
#   oBrain.WithBackend(:api, :LinuxServer).WithSuperApp(:phone, :Android).WithFirmware(:node, :ESP32)
#   oBrain.NeedsIn(:phone, [ :Unicode, :PivotTable, :Collection ])
#   oEmu = oBrain.Deploy(:Emulated)     #--> restolean_emulator/{index.html, app_phone.html, ...}

  #=============#
 #  FUNCTIONS  #
#=============#

func StzEmulatorQ(poBrain)
	return new stzEmulator(poBrain)

func _StzEmuCap(pcS)
	if len(pcS) = 0
		return pcS
	ok
	return upper(left("" + pcS, 1)) + substr("" + pcS, 2)

func _StzEmuIsMobile(pcClass)
	return pcClass = "mobile" or pcClass = "browser"

func _StzEmuStatus(pcClass)
	if pcClass = "server"
		return [ "ok", "healthy" ]
	but pcClass = "mcu"
		return [ "warn", "needs a look" ]
	ok
	return [ "live", "live" ]

func _StzEmuStatusHex(pcStatusClass)
	if pcStatusClass = "ok"
		return "#0a8f4f"
	but pcStatusClass = "warn"
		return "#b45309"
	ok
	return "#2563eb"

func _StzEmuFidelity(pcClass)
	if pcClass = "mcu"
		return [ "warn", "2 approximated",
			"Faithful: logic, capability rules, protocol. Approximated: pump timing and sensor noise -- validate on the bench." ]
	ok
	return [ "ok", "faithful",
		"Faithful: logic (same engine artifacts), capability rules, the protocol, the data." ]

func _StzEmuGlyph(pcClass)
	_s_ = "<svg viewBox='0 0 24 24' width='18' height='18' fill='none' stroke='#7b8496' stroke-width='1.6'>"
	if pcClass = "server"
		_s_ += "<rect x='4' y='4' width='16' height='7' rx='1.5'/><rect x='4' y='13' width='16' height='7' rx='1.5'/><circle cx='7' cy='7.5' r='.6' fill='#7b8496'/><circle cx='7' cy='16.5' r='.6' fill='#7b8496'/>"
	but pcClass = "mcu"
		_s_ += "<rect x='5' y='7' width='14' height='10' rx='1.5'/><rect x='9' y='10' width='6' height='4' rx='.6'/><path d='M8 7V5M12 7V5M16 7V5M8 19v-2M12 19v-2M16 19v-2'/>"
	else
		_s_ += "<rect x='7' y='3' width='10' height='18' rx='2.4'/><line x1='10.5' y1='5' x2='13.5' y2='5'/>"
	ok
	_s_ += "</svg>"
	return _s_

func _StzEmuDeviceSvg(pcClass, pcName, pcTarget, poStat)
	_nm_ = _StzEmuCap(pcName)
	_hex_ = _StzEmuStatusHex(poStat[1])
	if pcClass = "server"
		_s_ = "<svg viewBox='0 0 230 150' width='230' height='150' font-family='system-ui'>"
		_s_ += "<rect x='3' y='3' width='224' height='144' rx='9' fill='#fff' stroke='#c8cede' stroke-width='2'/>"
		_s_ += "<rect x='16' y='16' width='198' height='26' rx='4' fill='#f8fafc' stroke='#eef1f6'/><circle cx='30' cy='29' r='4' fill='#0a8f4f'/><text x='44' y='33' font-size='11' fill='#4b5566'>stz-reactor</text>"
		_s_ += "<rect x='16' y='48' width='198' height='26' rx='4' fill='#f8fafc' stroke='#eef1f6'/><circle cx='30' cy='61' r='4' fill='#0a8f4f'/><text x='44' y='65' font-size='11' fill='#4b5566'>native engine warm</text>"
		_s_ += "<rect x='16' y='80' width='198' height='26' rx='4' fill='#f8fafc' stroke='#eef1f6'/><circle cx='30' cy='93' r='4' fill='" + _hex_ + "'/><text x='44' y='97' font-size='11' fill='" + _hex_ + "'>" + poStat[2] + "</text>"
		_s_ += "<text x='16' y='132' font-size='11' fill='#8a93a3'>" + _nm_ + " -- " + pcTarget + "</text></svg>"
		return _s_
	ok
	_s_ = "<svg viewBox='0 0 230 150' width='230' height='150' font-family='system-ui'>"
	_s_ += "<rect x='12' y='18' width='206' height='114' rx='7' fill='#f4faf6' stroke='#8bbf9f' stroke-width='2'/>"
	_s_ += "<path d='M30 18V10M50 18V10M70 18V10M90 18V10M110 18V10M130 18V10' stroke='#8bbf9f' stroke-width='2'/>"
	_s_ += "<path d='M30 132v8M50 132v8M70 132v8M90 132v8M110 132v8M130 132v8' stroke='#8bbf9f' stroke-width='2'/>"
	_s_ += "<rect x='150' y='54' width='52' height='44' rx='4' fill='#fff' stroke='#8bbf9f' stroke-width='1.5'/><text x='160' y='80' font-size='10' fill='#2a6b47'>ESP32</text>"
	_s_ += "<text x='28' y='52' font-size='12' fill='#1b2333'>" + _nm_ + "</text>"
	_s_ += "<text x='28' y='72' font-size='10' fill='#8a93a3'>" + pcTarget + "</text>"
	_s_ += "<text x='28' y='96' font-size='11' fill='#0a8f4f'>GPIO rehearsing</text>"
	_s_ += "<text x='28' y='116' font-size='11' fill='" + _hex_ + "'>" + poStat[2] + "</text></svg>"
	return _s_

func _StzEmuAction(pcClass)
	if pcClass = "server"
		return [ "req", "Send a test request" ]
	ok
	return [ "pin", "Read a pin" ]

# a realistic, interactive app frontend for a mobile part -- the SAME kind of app
# the phone will run. (Starter content; the web-composite build emits the real one.)
func _StzEmuDish(pcName, pcDesc, pnPrice)
	return "<div class='dish'><div><div class='n'>" + pcName + "</div><div class='d'>" + pcDesc + "</div><div class='p'>" + pnPrice + " DT</div></div><button class='add' data-p='" + pnPrice + "' onclick='add(this)' aria-label='add'>+</button></div>"

func _StzEmuAppHtml(pcSol, pcPart)
	_nm_ = _StzEmuCap(pcSol)
	_a_ = "<!doctype html><html lang='en'><head><meta charset='utf-8'>"
	_a_ += "<meta name='viewport' content='width=device-width, initial-scale=1'>"
	_a_ += "<style>*{box-sizing:border-box;margin:0;-webkit-tap-highlight-color:transparent}"
	_a_ += "html,body{height:100%}body{font-family:system-ui,sans-serif;background:#f6f7f9;color:#1b2333}"
	_a_ += ".app{display:flex;flex-direction:column;height:100%}"
	_a_ += "header{background:#0a8f4f;color:#fff;padding:16px 16px 14px;display:flex;align-items:center;justify-content:space-between}"
	_a_ += "header .b{font-size:17px;font-weight:600}header .cart{background:rgba(255,255,255,.22);border-radius:20px;padding:5px 13px;font-size:13px}"
	_a_ += "main{flex:1;overflow:auto;padding:12px}"
	_a_ += ".hi{font-size:12px;color:#6b7280;margin:2px 4px 12px}"
	_a_ += ".dish{background:#fff;border-radius:14px;padding:12px 14px;margin-bottom:10px;display:flex;align-items:center;justify-content:space-between;box-shadow:0 1px 2px rgba(20,30,60,.06)}"
	_a_ += ".dish .n{font-size:15px}.dish .d{font-size:12px;color:#8a93a3;margin-top:2px}.dish .p{font-size:13px;color:#0a8f4f;margin-top:5px}"
	_a_ += ".add{background:#0a8f4f;color:#fff;border:0;border-radius:50%;width:34px;height:34px;font-size:21px;line-height:1;cursor:pointer;flex:none}"
	_a_ += "footer{background:#fff;border-top:1px solid #eef1f6;padding:12px 16px;display:flex;align-items:center;gap:12px}"
	_a_ += "footer .t{font-size:16px;font-weight:600}footer button{background:#0a8f4f;color:#fff;border:0;border-radius:11px;padding:13px 18px;font-size:14px;flex:1;cursor:pointer}"
	_a_ += "footer button:disabled{background:#c7cdd8}"
	_a_ += ".ok{position:fixed;inset:0;background:#fff;display:none;flex-direction:column;align-items:center;justify-content:center;padding:24px;text-align:center}"
	_a_ += ".ok .c{width:66px;height:66px;border-radius:50%;background:#e3f4ec;color:#0a8f4f;font-size:34px;display:flex;align-items:center;justify-content:center;margin-bottom:16px}"
	_a_ += ".ok h2{font-size:19px;font-weight:600;margin-bottom:6px}.ok p{color:#6b7280;font-size:14px}.ok button{margin-top:20px;background:#0a8f4f;color:#fff;border:0;border-radius:11px;padding:12px 22px;cursor:pointer}"
	_a_ += "</style></head><body><div class='app'>"
	_a_ += "<header><span class='b'>" + _nm_ + "</span><span class='cart' id='cart'>0 items</span></header>"
	_a_ += "<main><div class='hi'>Scan . Order . Pay -- table 7</div>"
	_a_ += _StzEmuDish("Royal couscous", "Semolina, lamb, vegetables", 24)
	_a_ += _StzEmuDish("Grilled tajine", "Slow-cooked, with olives", 19)
	_a_ += _StzEmuDish("Brik a l oeuf", "Crispy, egg and tuna", 6)
	_a_ += _StzEmuDish("Mint tea", "With pine nuts", 3)
	_a_ += _StzEmuDish("Makroudh", "Date pastry, honey", 5)
	_a_ += "</main>"
	_a_ += "<footer><span class='t' id='total'>0 DT</span><button id='order' disabled onclick='order()'>Order and pay</button></footer>"
	_a_ += "</div>"
	_a_ += "<div class='ok' id='ok'><div class='c'>+</div><h2>Order confirmed</h2><p>Your order is on its way to the kitchen.</p><button onclick='reset()'>New order</button></div>"
	_a_ += "<script>var n=0,t=0;"
	_a_ += "function add(el){n++;t+=parseInt(el.getAttribute('data-p'),10);document.getElementById('cart').textContent=n+(n===1?' item':' items');document.getElementById('total').textContent=t+' DT';document.getElementById('order').disabled=false}"
	_a_ += "function order(){if(n>0){document.getElementById('ok').style.display='flex'}}"
	_a_ += "function reset(){n=0;t=0;document.getElementById('cart').textContent='0 items';document.getElementById('total').textContent='0 DT';document.getElementById('order').disabled=true;document.getElementById('ok').style.display='none'}"
	_a_ += "</script></body></html>"
	return _a_

func _StzEmuSwitch(paParts, pnCur)
	_n_ = len(paParts)
	_h_ = "<div class='switch'>"
	for _j_ = 1 to _n_
		_on_ = "ghost"
		if _j_ = pnCur
			_on_ = "ghost on"
		ok
		_h_ += "<button class='" + _on_ + "' data-part='" + paParts[_j_][1] + "' onclick='go(this)'>" + _StzEmuGlyph(paParts[_j_][4]) + " " + _StzEmuCap(paParts[_j_][1]) + "</button>"
	next
	_h_ += "</div>"
	return _h_

# the ONE auxiliary zone, identical in place and structure for every part: the
# delivery plan (each capability -> its vector) + the fidelity line. Sits at the
# bottom of the device window.
func _StzEmuAuxZone(poPlan, paPart)
	_fd_ = _StzEmuFidelity(paPart[4])
	_h_ = "<div class='aux'><h3>Runs here</h3><div class='sub2'>where each capability this part uses is delivered</div>"
	_decs_ = paPart[5]
	_m_ = len(_decs_)
	for _k_ = 1 to _m_
		_d_ = _decs_[_k_]
		_lbl_ = poPlan.LabelFor(_d_[3], paPart[4])
		_h_ += "<div class='caprow'><span>" + _d_[2] + "</span><span class='vec'>" + _lbl_ + "</span></div>"
	next
	_h_ += "<h3 class='mt'>Fidelity</h3><div class='fid " + _fd_[1] + "'><span class='dot'></span> " + _fd_[3] + "</div>"
	_h_ += "</div>"
	return _h_

# the phone hero -- the real app, centered and large. Use it like the real device.
func _StzEmuPhoneHero(poPlan, paPart)
	_h_ = "<div class='bigphone'><iframe class='appscreen' src='app_" + paPart[1] + ".html' title='app'></iframe></div>"
	_h_ += "<div class='herohint'>The <b>" + _StzEmuCap(poPlan.Name()) + "</b> app, live -- add dishes, pay. It behaves like the shipped app."
	_h_ += " <a onclick='reloadApp2(this)' data-part='" + paPart[1] + "'>reload</a></div>"
	return _h_

# the backend hero -- an API console. Hit the endpoints of the running reactor.
func _StzEmuServerHero(poPlan, paPart)
	_nm_ = paPart[1]
	_h_ = "<div class='console'>"
	_h_ += "<div class='consbar'><span class='stat ok'><span class='dot'></span></span> " + _nm_ + " . stz-reactor . native engine warm</div>"
	_h_ += "<div class='reqs'>"
	_h_ += "<button class='ghost sm' data-part='" + _nm_ + "' data-req='GET /menu' onclick='apiReq(this)'>GET /menu</button>"
	_h_ += "<button class='ghost sm' data-part='" + _nm_ + "' data-req='GET /orders' onclick='apiReq(this)'>GET /orders</button>"
	_h_ += "<button class='ghost sm' data-part='" + _nm_ + "' data-req='POST /order' onclick='apiReq(this)'>POST /order</button>"
	_h_ += "</div><div class='conslog' id='cons-" + _nm_ + "'><div>ready -- send a request to the running backend.</div></div></div>"
	return _h_

# the firmware hero -- the board. Drive the pins; the readouts react.
func _StzEmuMcuHero(poPlan, paPart)
	_nm_ = paPart[1]
	_st_ = _StzEmuStatus("mcu")
	_h_ = "<div class='board'>" + _StzEmuDeviceSvg("mcu", _nm_, paPart[3], _st_)
	_h_ += "<div class='readouts'><div>moisture (pin 34): <b id='moist-" + _nm_ + "'>--</b></div>"
	_h_ += "<div>pump (pin 26): <b id='pump-" + _nm_ + "'>off</b> <span class='led' id='led-" + _nm_ + "'></span></div></div>"
	_h_ += "<div class='reqs'>"
	_h_ += "<button class='ghost sm' data-part='" + _nm_ + "' data-act='read' onclick='pinAct(this)'>Read moisture (pin 34)</button>"
	_h_ += "<button class='ghost sm' data-part='" + _nm_ + "' data-act='pump' onclick='pinAct(this)'>Toggle pump (pin 26)</button>"
	_h_ += "</div><div class='conslog' id='cons-" + _nm_ + "'><div>ready -- drive the pins; the board reacts.</div></div></div>"
	return _h_

# the MAIN-PAGE part view: shown when a part is picked on the map. It carries the
# auxiliary data (placement + fidelity) -- NOT the popup -- plus the way to (re)open
# the device emulator.
func _StzEmuAuxViews(poPlan)
	_aP_ = poPlan.Parts()
	_n_ = len(_aP_)
	_h_ = ""
	for _i_ = 1 to _n_
		_p_ = _aP_[_i_]
		_st_ = _StzEmuStatus(_p_[4])
		_h_ += "<div class='partview' id='ax-" + _p_[1] + "' style='display:none'>"
		_h_ += "<div class='pvhead'>" + _StzEmuGlyph(_p_[4]) + " <span class='pvname'>" + _StzEmuCap(_p_[1]) + "</span> <span class='chip'>" + _p_[3] + "</span>"
		_h_ += " <span class='stat " + _st_[1] + "'><span class='dot'></span> " + _st_[2] + "</span>"
		_h_ += "<span class='pvacts'><button class='pri sm' data-part='" + _p_[1] + "' onclick='openEmu(this)'>Open emulator</button></span></div>"
		_h_ += _StzEmuAuxZone(poPlan, _p_)
		_h_ += "</div>"
	next
	return _h_

# the POPUP: one part's device emulator only -- its interactive UI, guiding text,
# live status and actions. No switcher (one popup = one part; you open another from
# the map), no auxiliary data (that lives on the main page).
func _StzEmuDetailHtml(poPlan)
	_aP_ = poPlan.Parts()
	_n_ = len(_aP_)
	_h_ = ""
	for _i_ = 1 to _n_
		_p_ = _aP_[_i_]
		_cls_ = _p_[4]
		_st_ = _StzEmuStatus(_cls_)
		_wc_ = "window"
		if _StzEmuIsMobile(_cls_)
			_wc_ = "window wphone"
		ok
		_h_ += "<div class='modal' id='m-" + _p_[1] + "' onclick='bg(event)'><div class='" + _wc_ + "'>"
		_h_ += "<div class='wbar'><span class='wdots'><i></i><i></i><i></i></span>"
		_h_ += "<span class='wtitle'>" + _StzEmuGlyph(_cls_) + " " + _StzEmuCap(_p_[1]) + " <span class='chip'>" + _p_[3] + "</span></span>"
		_h_ += "<span class='wlive stat " + _st_[1] + "'><span class='dot'></span> " + _st_[2] + "</span>"
		_h_ += "<button class='wclose' onclick='closeEmu()' aria-label='close'>&times;</button></div>"
		_h_ += "<div class='wbody'><div class='hero'>"
		if _StzEmuIsMobile(_cls_)
			_h_ += _StzEmuPhoneHero(poPlan, _p_)
		but _cls_ = "mcu"
			_h_ += _StzEmuMcuHero(poPlan, _p_)
		else
			_h_ += _StzEmuServerHero(poPlan, _p_)
		ok
		_h_ += "</div></div></div></div>"
	next
	return _h_

func _StzEmuCard(poPlan, paPart, pbHub)
	_cls_ = paPart[4]
	_st_ = _StzEmuStatus(_cls_)
	_fd_ = _StzEmuFidelity(_cls_)
	_decs_ = paPart[5]
	_m_ = len(_decs_)
	_kb_ = 0
	for _k_ = 1 to _m_
		if _decs_[_k_][3] = "engine"
			_kb_ += _decs_[_k_][5]
		ok
	next
	_metric_ = "" + _m_ + " capabilities"
	if _kb_ > 0
		_metric_ += " &middot; engine subset ~" + _kb_ + " KB"
	ok
	_c_ = "<div class='part"
	if pbHub
		_c_ += " hub"
	ok
	_c_ += "' data-part='" + paPart[1] + "' onclick='go(this)'>"
	_c_ += "<div class='phead'>" + _StzEmuGlyph(_cls_) + "<span>" + _StzEmuCap(paPart[1]) + "</span> <span class='chip'>" + paPart[3] + "</span></div>"
	_c_ += "<div><span class='stat " + _st_[1] + "'><span class='dot'></span> " + _st_[2] + "</span></div>"
	_c_ += "<div class='metric'>" + _metric_ + "</div>"
	_c_ += "<div class='pfoot'><span class='badge " + _fd_[1] + "'>" + _fd_[2] + "</span><button class='ghost'>Open &rarr;</button></div>"
	_c_ += "</div>"
	return _c_

# one tier of the architecture (a labelled, wrapping grid of parts). Tiers scale:
# many frontends / backends / devices each wrap within their own grid.
func _StzEmuTier(poPlan, pcLabel, paIdx)
	_aP_ = poPlan.Parts()
	_h_ = "<div class='tier'><div class='tierlbl'>" + pcLabel + " <span class='tiern'>" + len(paIdx) + "</span></div><div class='tierrow'>"
	_n_ = len(paIdx)
	for _i_ = 1 to _n_
		_h_ += _StzEmuCard(poPlan, _aP_[paIdx[_i_]], FALSE)
	next
	_h_ += "</div></div>"
	return _h_

func _StzEmuFlow(pcLabel)
	return "<div class='flow'><span class='fline'></span><span class='flbl'>" + pcLabel + "</span><span class='fline'></span></div>"

# the solution map as a TIERED architecture: frontends over backends over edge
# devices, with the flows between them. Scales to many parts and richer topologies.
func _StzEmuMapHtml(poPlan)
	_aP_ = poPlan.Parts()
	_n_ = len(_aP_)
	_front_ = []
	_back_ = []
	_dev_ = []
	for _i_ = 1 to _n_
		_cls_ = _aP_[_i_][4]
		if _StzEmuIsMobile(_cls_)
			_front_ + _i_
		but _cls_ = "mcu"
			_dev_ + _i_
		else
			_back_ + _i_
		ok
	next
	_h_ = ""
	if len(_front_) > 0
		_h_ += _StzEmuTier(poPlan, "Frontends", _front_)
	ok
	if len(_front_) > 0 and len(_back_) > 0
		_h_ += _StzEmuFlow("REST API")
	ok
	if len(_back_) > 0
		_h_ += _StzEmuTier(poPlan, "Backends", _back_)
	ok
	if len(_dev_) > 0 and (len(_back_) > 0 or len(_front_) > 0)
		_h_ += _StzEmuFlow("telemetry")
	ok
	if len(_dev_) > 0
		_h_ += _StzEmuTier(poPlan, "Edge devices", _dev_)
	ok
	_h_ += "<div class='legend'><span class='stat ok'><span class='dot'></span> healthy</span>"
	_h_ += "<span class='stat live'><span class='dot'></span> live traffic</span>"
	_h_ += "<span class='stat warn'><span class='dot'></span> check before shipping</span>"
	_h_ += "<span class='hint'>Click a part to open its page. The engine runs the same in emulation and in production.</span></div>"
	_h_ += "<div class='cta'><div class='t'><b>Ready to ship.</b> Every part runs its real engine here -- production ships the same parts.</div>"
	_h_ += "<button class='pri' onclick='deployProd()'>Deploy to production</button></div>"
	return _h_

func _StzEmuScript()
	_j_ = "function closeModals(){var m=document.getElementsByClassName('modal');for(var i=0;i<m.length;i++)m[i].classList.remove('open')}" + nl
	_j_ += "function hideViews(){var v=document.getElementsByClassName('partview');for(var i=0;i<v.length;i++)v[i].style.display='none'}" + nl
	_j_ += "function openPop(n){var m=document.getElementById('m-'+n);if(m){m.classList.add('open');m.scrollTop=0}}" + nl
	_j_ += "function cap(s){return s.charAt(0).toUpperCase()+s.slice(1)}" + nl
	_j_ += "function setCrumb(n){document.getElementById('crumb-part').innerHTML=n?(' &rsaquo; '+cap(n)):''}" + nl
	_j_ += "function route(){var h=location.hash.replace('#','');closeModals();var map=document.getElementById('map');" + nl
	_j_ += "if(h.indexOf('part/')===0){var n=h.slice(5);var v=document.getElementById('ax-'+n);if(v){hideViews();map.style.display='none';v.style.display='block';setCrumb(n)}else{hideViews();map.style.display='block';setCrumb('')}}" + nl
	_j_ += "else{hideViews();map.style.display='block';setCrumb('')}window.scrollTo(0,0)}" + nl
	_j_ += "function go(el){location.hash='part/'+el.getAttribute('data-part')}" + nl
	_j_ += "function goMap(){location.hash='map'}" + nl
	_j_ += "function closeEmu(){closeModals()}" + nl
	_j_ += "function openEmu(el){openPop(el.getAttribute('data-part'))}" + nl
	_j_ += "function bg(e){if(e.target.classList.contains('modal')){closeEmu()}}" + nl
	_j_ += "window.addEventListener('hashchange',route);" + nl
	_j_ += "function reloadApp2(el){var f=document.querySelector('#d-'+el.getAttribute('data-part')+' iframe');if(f){f.src=f.src}}" + nl
	_j_ += "function addLine(id,t){var log=document.getElementById(id);var d=document.createElement('div');d.textContent=t;log.appendChild(d);log.scrollTop=log.scrollHeight}" + nl
	_j_ += "var API={'GET /menu':'200 OK  5 dishes','GET /orders':'200 OK  12 rows','POST /order':'201 Created  order #1043'};" + nl
	_j_ += "function apiReq(el){var p=el.getAttribute('data-part');var r=el.getAttribute('data-req');addLine('cons-'+p,'> '+r);addLine('cons-'+p,'  '+(API[r]||'200 OK'))}" + nl
	_j_ += "var pumpOn={};" + nl
	_j_ += "function pinAct(el){var p=el.getAttribute('data-part');var a=el.getAttribute('data-act');" + nl
	_j_ += "if(a==='read'){var v=Math.round(450+Math.random()*120);document.getElementById('moist-'+p).textContent=v;addLine('cons-'+p,'digitalRead(34) -> '+v)}" + nl
	_j_ += "else{pumpOn[p]=!pumpOn[p];document.getElementById('pump-'+p).textContent=pumpOn[p]?'ON':'off';document.getElementById('led-'+p).className='led'+(pumpOn[p]?' on':'');addLine('cons-'+p,'digitalWrite(26,'+(pumpOn[p]?1:0)+') -> pump '+(pumpOn[p]?'ON':'off'))}}" + nl
	_j_ += "function deployProd(){alert('Production deploy ships these same parts via the governed crossing. Run: brain.Deploy(:Production)')}" + nl
	_j_ += "route();" + nl
	return _j_

func _StzEmuCss()
	_c_ = "*{box-sizing:border-box} body{margin:0;font-family:system-ui,sans-serif;background:#fff;color:#1b2333;padding:24px;max-width:940px;margin:0 auto}" + nl
	_c_ += "h1{font-size:20px;font-weight:500;margin:0 0 3px} h3{font-size:14px;font-weight:500;margin:0 0 3px}" + nl
	_c_ += ".sub{color:#6b7280;font-size:13px;margin-bottom:18px} .sub2{color:#8a93a3;font-size:12px;margin-bottom:10px} .mt{margin-top:16px}" + nl
	_c_ += ".head{display:flex;align-items:center;justify-content:space-between;gap:12px}" + nl
	_c_ += ".chip{font-size:12px;color:#6b7280;background:#f0f2f7;padding:2px 9px;border-radius:8px}" + nl
	_c_ += ".crumb{font-size:13px;color:#6b7280;margin:14px 0}.crumb a{color:#2563eb;cursor:pointer}" + nl
	_c_ += ".card{background:#fff;border:1px solid #e6e9f0;border-radius:12px;padding:16px 18px;box-shadow:0 1px 2px rgba(20,30,60,.05);margin-bottom:14px}" + nl
	_c_ += ".part{background:#fff;border:1px solid #e6e9f0;border-radius:12px;padding:14px 16px;cursor:pointer;box-shadow:0 1px 2px rgba(20,30,60,.05)}" + nl
	_c_ += ".part:hover{border-color:#93b4f5;box-shadow:0 2px 8px rgba(37,99,235,.10)}.part.hub{border:2px solid #93b4f5}" + nl
	_c_ += ".phead{display:flex;align-items:center;gap:8px;font-size:15px;margin-bottom:9px}.phead svg{flex:none}" + nl
	_c_ += ".stat{display:inline-flex;align-items:center;gap:7px;font-size:13px}" + nl
	_c_ += ".dot{width:9px;height:9px;border-radius:50%;display:inline-block;flex:none}" + nl
	_c_ += ".ok{color:#0a8f4f}.ok .dot{background:#0a8f4f}" + nl
	_c_ += ".live{color:#2563eb}.live .dot{background:#2563eb;animation:pl 1.6s infinite}" + nl
	_c_ += ".warn{color:#b45309}.warn .dot{background:#b45309}" + nl
	_c_ += "@keyframes pl{0%,100%{opacity:1}50%{opacity:.3}}" + nl
	_c_ += ".metric{font-size:12px;color:#8a93a3;margin:8px 0 12px}" + nl
	_c_ += ".pfoot{display:flex;align-items:center;justify-content:space-between;gap:8px}" + nl
	_c_ += ".badge{font-size:12px;padding:3px 9px;border-radius:8px}" + nl
	_c_ += ".badge.ok{background:#e3f4ec;color:#0a6c3d}.badge.warn{background:#fdf0e3;color:#8a4008}" + nl
	_c_ += "button{font-size:13px;padding:7px 13px;border-radius:8px;cursor:pointer;border:1px solid #d3d9e4;background:#fff;color:#1b2333}" + nl
	_c_ += "button:hover{background:#f5f7fb} button.pri{background:#0a8f4f;color:#fff;border-color:#0a8f4f} button.pri:hover{background:#098544}" + nl
	_c_ += "button.ghost{background:#fff} button.sm{font-size:12px;padding:6px 11px} .acts{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:6px}" + nl
	_c_ += ".tier{margin-bottom:2px}.tierlbl{font-size:11px;color:#9aa3b2;text-transform:uppercase;letter-spacing:.5px;margin-bottom:9px}.tiern{background:#eef1f6;color:#8a93a3;border-radius:10px;padding:1px 7px;font-size:11px}" + nl
	_c_ += ".tierrow{display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:14px}" + nl
	_c_ += ".flow{display:flex;align-items:center;gap:12px;margin:15px 0;color:#9aa3b2;font-size:11px}.flow .fline{flex:1;height:1px;background:#dfe3ea}.flow .flbl{white-space:nowrap;text-transform:uppercase;letter-spacing:.5px}" + nl
	_c_ += ".legend{display:flex;gap:18px;font-size:12px;color:#6b7280;margin-top:18px;align-items:center;flex-wrap:wrap}.legend .hint{color:#9aa3b2;margin-left:auto}" + nl
	_c_ += ".cta{background:#f0faf4;border:1px solid #b7e0ca;border-radius:12px;padding:14px 16px;margin-top:16px;display:flex;align-items:center;justify-content:space-between;gap:12px}.cta .t{font-size:14px;color:#0a6c3d}" + nl
	_c_ += ".switch{display:flex;gap:8px;margin-bottom:18px;flex-wrap:wrap}.switch button{display:inline-flex;align-items:center;gap:6px}.switch button.on{border-color:#2563eb;color:#2563eb}" + nl
	_c_ += ".modal{position:fixed;inset:0;background:rgba(22,28,42,.5);display:none;align-items:flex-start;justify-content:center;padding:34px 18px;overflow:auto;z-index:50}.modal.open{display:flex}" + nl
	_c_ += ".window{background:#fff;border-radius:14px;max-width:720px;width:100%;max-height:94vh;box-shadow:0 24px 60px rgba(10,15,30,.32);overflow:auto;margin:auto 0}.wphone{width:auto;max-width:94vw}" + nl
	_c_ += ".wbar{display:flex;align-items:center;gap:10px;padding:11px 15px;border-bottom:1px solid #eef1f6;background:#fafbfc;position:sticky;top:0}" + nl
	_c_ += ".wdots{display:inline-flex;gap:6px}.wdots i{width:11px;height:11px;border-radius:50%;display:inline-block;background:#e0e4ea}.wdots i:first-child{background:#efb0ac}.wdots i:nth-child(2){background:#f0d29a}.wdots i:last-child{background:#a9d9b6}" + nl
	_c_ += ".wtitle{display:flex;align-items:center;gap:8px;font-size:14px}.wlive{margin-left:auto;font-size:12px}.wclose{margin-left:10px;border:0;background:transparent;font-size:22px;color:#8a93a3;cursor:pointer;padding:0 6px;line-height:1}.wclose:hover{color:#1b2333}" + nl
	_c_ += ".wbody{padding:16px 20px 20px}.wphone .wbody{padding:14px}.wphone .hero{margin:4px 0 0}" + nl
	_c_ += ".partview{margin-top:4px}.pvhead{display:flex;align-items:center;gap:10px;margin-bottom:8px;flex-wrap:wrap}.pvname{font-size:17px}.pvacts{margin-left:auto;display:flex;gap:8px}" + nl
	_c_ += ".hero{display:flex;flex-direction:column;align-items:center;margin:10px 0 20px}" + nl
	_c_ += ".bigphone{height:min(600px,72vh);aspect-ratio:300/620;background:#4a5162;border-radius:42px;padding:11px;box-shadow:0 8px 24px rgba(50,60,80,.14);flex:none}" + nl
	_c_ += ".appscreen{width:100%;height:100%;border:0;border-radius:33px;background:#fff;display:block}" + nl
	_c_ += ".herohint{font-size:12px;color:#8a93a3;margin-top:12px;text-align:center}.herohint a{color:#2563eb;cursor:pointer}" + nl
	_c_ += ".console,.board{width:100%;max-width:600px}.board{display:flex;flex-direction:column;align-items:center}.board svg{width:340px;height:auto}" + nl
	_c_ += ".consbar{font-size:13px;color:#4b5566;margin-bottom:12px;display:flex;gap:8px;align-items:center}" + nl
	_c_ += ".reqs{display:flex;gap:8px;flex-wrap:wrap;margin:12px 0}" + nl
	_c_ += ".readouts{display:flex;gap:28px;font-size:13px;margin:10px 0 2px;color:#4b5566}.readouts b{color:#1b2333}" + nl
	_c_ += ".led{width:11px;height:11px;border-radius:50%;background:#cfd6e2;display:inline-block;vertical-align:middle}.led.on{background:#0a8f4f}" + nl
	_c_ += ".conslog{background:#161c28;color:#8fe3b0;font-family:ui-monospace,monospace;font-size:12px;border-radius:10px;padding:12px 14px;min-height:112px;max-height:220px;overflow:auto;line-height:1.8;width:100%}" + nl
	_c_ += ".caprow{display:flex;align-items:center;justify-content:space-between;font-size:13px;padding:6px 0;border-bottom:1px solid #f0f2f7}" + nl
	_c_ += ".vec{font-family:ui-monospace,monospace;font-size:11px;color:#4b5566;background:#f0f2f7;padding:2px 8px;border-radius:8px}" + nl
	_c_ += ".fid{font-size:13px;display:flex;gap:8px;align-items:baseline}.fid.ok{color:#0a6c3d}.fid.warn{color:#8a4008}.fid .dot{margin-top:5px}" + nl
	_c_ += ".aux{border-top:1px solid #eef1f6;padding-top:16px;margin-top:12px}" + nl
	return _c_

func _StzEmuHtml(pcName, poPlan)
	_h_ = "<!doctype html>" + nl + "<html lang='en'><head><meta charset='utf-8'>" + nl
	_h_ += "<meta name='viewport' content='width=device-width, initial-scale=1'>" + nl
	_h_ += "<title>" + pcName + " -- Deploy(:Emulated)</title>" + nl
	_h_ += "<style>" + nl + _StzEmuCss() + "</style></head><body>" + nl
	_h_ += "<div class='head'><h1>" + pcName + " <span class='chip'>emulation</span></h1>" + nl
	_h_ += "<span class='stat ok'><span class='dot'></span> parts healthy</span></div>" + nl
	_h_ += "<div class='sub'>The whole solution, emulated in the browser -- each part runs its real engine. What works here ships as-is.</div>" + nl
	_h_ += "<div class='crumb'><a onclick='goMap()'>&larr; Solution map</a><span id='crumb-part'></span></div>" + nl
	_h_ += "<div id='map'>" + _StzEmuMapHtml(poPlan) + "</div>" + nl
	_h_ += _StzEmuAuxViews(poPlan) + nl
	_h_ += _StzEmuDetailHtml(poPlan) + nl
	_h_ += "<script>" + nl + _StzEmuScript() + "</script>" + nl
	_h_ += "</body></html>" + nl
	return _h_

func _StzEmuManifest(pcName, poPlan)
	_cQ_ = char(34)
	_c_ = "{" + nl + "  " + _cQ_ + "name" + _cQ_ + ": " + _cQ_ + pcName + _cQ_ + "," + nl
	_c_ += "  " + _cQ_ + "kind" + _cQ_ + ": " + _cQ_ + "emulator" + _cQ_ + "," + nl
	_c_ += "  " + _cQ_ + "entry" + _cQ_ + ": " + _cQ_ + "index.html" + _cQ_ + "," + nl
	_c_ += "  " + _cQ_ + "parts" + _cQ_ + ": ["
	_aP_ = poPlan.Parts()
	_n_ = len(_aP_)
	for _i_ = 1 to _n_
		_c_ += _cQ_ + _aP_[_i_][1] + _cQ_
		if _i_ < _n_
			_c_ += ", "
		ok
	next
	_c_ += "]" + nl + "}" + nl
	return _c_


  #===============#
 #  STZEMULATOR   #
#===============#

class stzEmulator from stzObject

	@oBrain = NULL
	@cOutDir = ""
	@aFiles = []
	@bBuilt = FALSE

	def init(poBrain)
		@oBrain = poBrain

	def OutDir(pcDir)
		@cOutDir = "" + pcDir
		return This

	def BundleDir()
		if @cOutDir != ""
			return @cOutDir
		ok
		return @oBrain.Name() + "_emulator"

	def Build()
		_oPlan_ = @oBrain.Plan()
		_cDir_ = This.BundleDir()
		StzEngineDirCreatePath(_cDir_)
		@aFiles = []
		write(_cDir_ + "/index.html", _StzEmuHtml(@oBrain.Name(), _oPlan_))
		@aFiles + "index.html"
		# a real app frontend per mobile/browser part -- the phone runs it for real
		_aP_ = _oPlan_.Parts()
		_n_ = len(_aP_)
		for _i_ = 1 to _n_
			if _StzEmuIsMobile(_aP_[_i_][4])
				_cApp_ = "app_" + _aP_[_i_][1] + ".html"
				write(_cDir_ + "/" + _cApp_, _StzEmuAppHtml(@oBrain.Name(), _aP_[_i_][1]))
				@aFiles + _cApp_
			ok
		next
		write(_cDir_ + "/manifest.json", _StzEmuManifest(@oBrain.Name(), _oPlan_))
		@aFiles + "manifest.json"
		@bBuilt = TRUE
		return This

		def BuildQ()
			This.Build()
			return This

	def Files()
		return @aFiles

	def IsBuilt()
		return @bBuilt

	def ShellPath()
		return This.BundleDir() + "/index.html"
