#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZEMULATOR               #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Deploy(:Emulated) -- the programming-phase   #
#                  face of Deploy(). Generates a web mission    #
#                  control from a stzDelivery plan. Main        #
#                  page: a parts GRID (left) + the selected     #
#                  part's auxiliary data (right). Each part     #
#                  opens a maximized device WINDOW split into   #
#                  the device (left) and a live log + query     #
#                  console (right). Calm, standard, usable.     #
#                                                              #
#                  The web ASSETS (emulator.css / emulator.js)  #
#                  are authored files under emulator_assets/,    #
#                  copied verbatim into each bundle and linked   #
#                  from index.html -- a clean web app. Only the  #
#                  data-driven HTML is generated here, since it  #
#                  is a function of the plan.                    #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

  #=============#
 #  FUNCTIONS  #
#=============#

func StzEmulatorQ(poDelivery)
	return new stzEmulator(poDelivery)

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

func _StzEmuFidelity(pcClass)
	if pcClass = "mcu"
		return [ "warn", "2 approximated",
			"Faithful: logic, capability rules, protocol. Approximated: pump timing and sensor noise -- validate on the bench." ]
	ok
	return [ "ok", "faithful",
		"Faithful: logic (same engine artifacts), capability rules, the protocol, the data." ]

func _StzEmuGlyph(pcClass)
	_s_ = "<svg viewBox='0 0 24 24' width='17' height='17' fill='none' stroke='#7b8496' stroke-width='1.6'>"
	if pcClass = "server"
		_s_ += "<rect x='4' y='4' width='16' height='7' rx='1.5'/><rect x='4' y='13' width='16' height='7' rx='1.5'/><circle cx='7' cy='7.5' r='.6' fill='#7b8496'/><circle cx='7' cy='16.5' r='.6' fill='#7b8496'/>"
	but pcClass = "mcu"
		_s_ += "<rect x='5' y='7' width='14' height='10' rx='1.5'/><rect x='9' y='10' width='6' height='4' rx='.6'/><path d='M8 7V5M12 7V5M16 7V5M8 19v-2M12 19v-2M16 19v-2'/>"
	else
		_s_ += "<rect x='7' y='3' width='10' height='18' rx='2.4'/><line x1='10.5' y1='5' x2='13.5' y2='5'/>"
	ok
	_s_ += "</svg>"
	return _s_

func _StzEmuBoardSvg(pcName)
	_s_ = "<svg viewBox='0 0 320 180' width='320' height='180' font-family='system-ui'>"
	_s_ += "<rect x='16' y='22' width='288' height='136' rx='8' fill='#f4faf6' stroke='#8bbf9f' stroke-width='2'/>"
	_s_ += "<path d='M40 22V12M70 22V12M100 22V12M130 22V12M160 22V12M190 22V12M220 22V12' stroke='#8bbf9f' stroke-width='2'/>"
	_s_ += "<path d='M40 158v10M70 158v10M100 158v10M130 158v10M160 158v10M190 158v10M220 158v10' stroke='#8bbf9f' stroke-width='2'/>"
	_s_ += "<rect x='210' y='62' width='64' height='54' rx='4' fill='#fff' stroke='#8bbf9f' stroke-width='1.5'/><text x='224' y='94' font-size='12' fill='#2a6b47'>ESP32</text>"
	_s_ += "<text x='40' y='60' font-size='13' fill='#1b2333'>" + _StzEmuCap(pcName) + "</text>"
	_s_ += "<text x='40' y='84' font-size='11' fill='#8a93a3'>greenhouse node</text>"
	_s_ += "<circle cx='46' cy='120' r='6' fill='#cfd6e2' id='bled-" + pcName + "'/><text x='58' y='124' font-size='11' fill='#8a93a3'>pump</text>"
	_s_ += "</svg>"
	return _s_

func _StzEmuDish(pcName, pcDesc, pnPrice)
	return "<div class='dish'><div><div class='n'>" + pcName + "</div><div class='d'>" + pcDesc + "</div><div class='p'>" + pnPrice + " DT</div></div><button class='add' data-p='" + pnPrice + "' data-n='" + pcName + "' onclick='add(this)' aria-label='add'>+</button></div>"

# a menu page, parameterized by title + tagline + dish rows ([name, desc, price]).
# Used for BOTH a model-driven menu and the no-model demo fallback.
func _StzEmuMenuPage(pcTitle, pcTagline, paDishRows)
	_nm_ = pcTitle
	_a_ = "<!doctype html><html lang='en'><head><meta charset='utf-8'>"
	_a_ += "<meta name='viewport' content='width=device-width, initial-scale=1'>"
	_a_ += "<style>*{box-sizing:border-box;margin:0;-webkit-tap-highlight-color:transparent}html,body{height:100%}body{font-family:system-ui,sans-serif;background:#f6f7f9;color:#1b2333}"
	_a_ += ".app{display:flex;flex-direction:column;height:100%}"
	_a_ += "header{background:#0a8f4f;color:#fff;padding:16px 16px 14px;display:flex;align-items:center;justify-content:space-between}"
	_a_ += "header .b{font-size:17px;font-weight:600}header .cart{background:rgba(255,255,255,.22);border-radius:20px;padding:5px 13px;font-size:13px}"
	_a_ += "main{flex:1;overflow:auto;padding:12px}.hi{font-size:12px;color:#6b7280;margin:2px 4px 12px}"
	_a_ += ".dish{background:#fff;border-radius:14px;padding:12px 14px;margin-bottom:10px;display:flex;align-items:center;justify-content:space-between;box-shadow:0 1px 2px rgba(20,30,60,.06)}"
	_a_ += ".dish .n{font-size:15px}.dish .d{font-size:12px;color:#8a93a3;margin-top:2px}.dish .p{font-size:13px;color:#0a8f4f;margin-top:5px}"
	_a_ += ".add{background:#0a8f4f;color:#fff;border:0;border-radius:50%;width:34px;height:34px;font-size:21px;line-height:1;cursor:pointer;flex:none}"
	_a_ += "footer{background:#fff;border-top:1px solid #eef1f6;padding:12px 16px;display:flex;align-items:center;gap:12px}"
	_a_ += "footer .t{font-size:16px;font-weight:600}footer button{background:#0a8f4f;color:#fff;border:0;border-radius:11px;padding:13px 18px;font-size:14px;flex:1;cursor:pointer}footer button:disabled{background:#c7cdd8}"
	_a_ += ".ok{position:fixed;inset:0;background:#fff;display:none;flex-direction:column;align-items:center;justify-content:center;padding:24px;text-align:center}"
	_a_ += ".ok .c{width:66px;height:66px;border-radius:50%;background:#e3f4ec;color:#0a8f4f;font-size:34px;display:flex;align-items:center;justify-content:center;margin-bottom:16px}"
	_a_ += ".ok h2{font-size:19px;font-weight:600;margin-bottom:6px}.ok p{color:#6b7280;font-size:14px}.ok button{margin-top:20px;background:#0a8f4f;color:#fff;border:0;border-radius:11px;padding:12px 22px;cursor:pointer}"
	_a_ += "</style></head><body><div class='app'>"
	_a_ += "<header><span class='b'>" + _nm_ + "</span><span class='cart' id='cart'>0 items</span></header>"
	_a_ += "<main><div class='hi'>" + pcTagline + "</div>"
	_nd_ = len(paDishRows)
	for _di_ = 1 to _nd_
		_dr_ = paDishRows[_di_]
		_a_ += _StzEmuDish(_dr_[1], _dr_[2], _dr_[3])
	next
	_a_ += "</main>"
	_a_ += "<footer><span class='t' id='total'>0 DT</span><button id='order' disabled onclick='order()'>Order and pay</button></footer></div>"
	_a_ += "<div class='ok' id='ok'><div class='c'>+</div><h2>Order confirmed</h2><p>Your order is on its way to the kitchen.</p><button onclick='reset()'>New order</button></div>"
	_a_ += "<script>var n=0,t=0;function LOG(m){try{parent.postMessage({t:'applog',m:m},'*')}catch(e){}}"
	_a_ += "function add(el){n++;t+=parseInt(el.getAttribute('data-p'),10);document.getElementById('cart').textContent=n+(n===1?' item':' items');document.getElementById('total').textContent=t+' DT';document.getElementById('order').disabled=false;LOG('added '+el.getAttribute('data-n')+' ('+el.getAttribute('data-p')+' DT)')}"
	_a_ += "function order(){if(n>0){document.getElementById('ok').style.display='flex';LOG('order placed: '+n+' items, '+t+' DT')}}"
	_a_ += "function reset(){n=0;t=0;document.getElementById('cart').textContent='0 items';document.getElementById('total').textContent='0 DT';document.getElementById('order').disabled=true;document.getElementById('ok').style.display='none';LOG('new order started')}"
	_a_ += "</script></body></html>"
	return _a_

# the per-part app -- driven by the solution's app MODEL when one is attached.
# A part's ROLE decides its app: a "menu" part shows its real menu, a "dashboard"
# part shows figures the engine computed. With no model, the demo menu (below).
func _StzEmuAppHtml(poApp, pcSol, pcPart)
	if isObject(poApp) and poApp.HasRoleFor(pcPart)
		_role_ = poApp.RoleOf(pcPart)
		if _role_ = "dashboard"
			return _StzEmuDashboardHtml(poApp, pcSol, pcPart)
		but _role_ = "menu"
			return _StzEmuMenuHtml(poApp, pcSol, pcPart)
		ok
	ok
	return _StzEmuDemoMenuHtml(pcSol)

# a model-driven menu: the real dishes this part's dataset holds.
func _StzEmuMenuHtml(poApp, pcSol, pcPart)
	return _StzEmuMenuPage(_StzEmuCap(pcSol), "Scan . Order . Pay -- table 7", poApp.MenuOf(pcPart))

# the no-model fallback demo (back-compat: unchanged output when no app is set).
func _StzEmuDemoMenuHtml(pcSol)
	_rows_ = [
		[ "Royal couscous", "Semolina, lamb, vegetables", 24 ],
		[ "Grilled tajine", "Slow-cooked, with olives", 19 ],
		[ "Brik a l oeuf", "Crispy, egg and tuna", 6 ],
		[ "Mint tea", "With pine nuts", 3 ],
		[ "Makroudh", "Date pastry, honey", 5 ]
	]
	return _StzEmuMenuPage(_StzEmuCap(pcSol), "Scan . Order . Pay -- table 7", _rows_)

# a model-driven manager dashboard -- its figures are COMPUTED by the engine
# (stzTable aggregation over the real orders), not hardcoded. This is the part's
# declared :PivotTable capability, running for real.
func _StzEmuDashboardHtml(poApp, pcSol, pcPart)
	_d_ = poApp.DashboardOf(pcPart)
	_rows_ = _d_[1]
	_total_ = _d_[2]
	_top_ = _d_[3]
	_topRev_ = _d_[4]
	_nm_ = _StzEmuCap(pcSol)
	_a_ = "<!doctype html><html lang='en'><head><meta charset='utf-8'>"
	_a_ += "<meta name='viewport' content='width=device-width, initial-scale=1'>"
	_a_ += "<style>*{box-sizing:border-box;margin:0}html,body{height:100%}body{font-family:system-ui,sans-serif;background:#f6f7f9;color:#1b2333}"
	_a_ += ".app{display:flex;flex-direction:column;height:100%}"
	_a_ += "header{background:#12324e;color:#fff;padding:16px;display:flex;align-items:center;justify-content:space-between}"
	_a_ += "header .b{font-size:17px;font-weight:600}header .r{font-size:12px;opacity:.8}"
	_a_ += "main{flex:1;overflow:auto;padding:16px}"
	_a_ += ".kpis{display:flex;gap:12px;margin-bottom:16px}.kpi{background:#fff;border-radius:14px;padding:14px 16px;flex:1;box-shadow:0 1px 2px rgba(20,30,60,.06)}"
	_a_ += ".kpi .k{font-size:12px;color:#6b7280}.kpi .v{font-size:22px;font-weight:600;margin-top:4px}.kpi .v.rev{color:#0a8f4f}"
	_a_ += ".card{background:#fff;border-radius:14px;padding:14px 16px;box-shadow:0 1px 2px rgba(20,30,60,.06)}"
	_a_ += ".card h3{font-size:13px;color:#6b7280;font-weight:600;margin-bottom:12px}"
	_a_ += ".bar{margin-bottom:11px}.bar .t{display:flex;justify-content:space-between;font-size:13px;margin-bottom:4px}.bar .t .rv{color:#0a8f4f}"
	_a_ += ".track{background:#eef1f6;border-radius:6px;height:9px;overflow:hidden}.fill{background:#12324e;height:100%;border-radius:6px}"
	_a_ += ".note{font-size:11px;color:#8a93a3;margin-top:14px;text-align:center}"
	_a_ += "</style></head><body><div class='app'>"
	_a_ += "<header><span class='b'>" + _nm_ + "</span><span class='r'>Manager . live</span></header><main>"
	_a_ += "<div class='kpis'><div class='kpi'><div class='k'>Revenue today</div><div class='v rev'>" + _total_ + " DT</div></div>"
	_a_ += "<div class='kpi'><div class='k'>Top seller</div><div class='v'>" + _top_ + "</div></div></div>"
	_a_ += "<div class='card'><h3>Revenue by dish</h3>"
	_nr_ = len(_rows_)
	for _i_ = 1 to _nr_
		_r_ = _rows_[_i_]
		_pct_ = 0
		if _topRev_ > 0
			_pct_ = floor((_r_[3] * 100) / _topRev_)
		ok
		_a_ += "<div class='bar'><div class='t'><span>" + _r_[1] + " <span style='color:#8a93a3'>x" + _r_[2] + "</span></span><span class='rv'>" + _r_[3] + " DT</span></div>"
		_a_ += "<div class='track'><div class='fill' style='width:" + _pct_ + "%'></div></div></div>"
	next
	_a_ += "</div><div class='note'>computed live by the on-device engine (stz.wasm aggregation)</div>"
	_a_ += "</main></div></body></html>"
	return _a_

  #-- the grid (left) + aux (right) of the main page ------------

func _StzEmuGridRow(poPlan, paPart)
	_cls_ = paPart[4]
	_st_ = _StzEmuStatus(_cls_)
	_fd_ = _StzEmuFidelity(_cls_)
	_c_ = "<div class='grow' data-part='" + paPart[1] + "' onclick='sel(this)'>"
	_c_ += "<span class='grleft'>" + _StzEmuGlyph(_cls_) + " <b>" + _StzEmuCap(paPart[1]) + "</b> <span class='gtarget'>" + paPart[3] + "</span></span>"
	_c_ += "<span class='grright'><span class='stat " + _st_[1] + "'><span class='dot'></span> " + _st_[2] + "</span>"
	_c_ += "<span class='badge " + _fd_[1] + "'>" + _fd_[2] + "</span>"
	_c_ += "<span class='gcaps'>" + len(paPart[5]) + " caps</span></span></div>"
	return _c_

func _StzEmuGridTier(poPlan, pcLabel, paIdx)
	_aP_ = poPlan.Parts()
	_h_ = "<div class='gtier'>" + pcLabel + " <span class='tiern'>" + len(paIdx) + "</span></div>"
	_n_ = len(paIdx)
	for _i_ = 1 to _n_
		_h_ += _StzEmuGridRow(poPlan, _aP_[paIdx[_i_]])
	next
	return _h_

func _StzEmuGridCol(poPlan)
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
	_h_ = "<div class='gridcol'>"
	_h_ += "<div class='filters'><button class='fbtn active' data-f='all' onclick='filt(this)'>All</button>"
	if len(_front_) > 0
		_h_ += "<button class='fbtn' data-f='front' onclick='filt(this)'>Frontends</button>"
	ok
	if len(_back_) > 0
		_h_ += "<button class='fbtn' data-f='back' onclick='filt(this)'>Backends</button>"
	ok
	if len(_dev_) > 0
		_h_ += "<button class='fbtn' data-f='dev' onclick='filt(this)'>Edge devices</button>"
	ok
	_h_ += "</div>"
	if len(_front_) > 0
		_h_ += "<div class='gsection' data-tier='front'>" + _StzEmuGridTier(poPlan, "Frontends", _front_) + "</div>"
	ok
	if len(_back_) > 0
		_h_ += "<div class='gsection' data-tier='back'>" + _StzEmuGridTier(poPlan, "Backends", _back_) + "</div>"
	ok
	if len(_dev_) > 0
		_h_ += "<div class='gsection' data-tier='dev'>" + _StzEmuGridTier(poPlan, "Edge devices", _dev_) + "</div>"
	ok
	_h_ += "<div class='legend'><span class='stat ok'><span class='dot'></span> healthy</span><span class='stat live'><span class='dot'></span> live</span><span class='stat warn'><span class='dot'></span> check</span></div>"
	_h_ += "</div>"
	return _h_

func _StzEmuAuxCol(poPlan)
	_aP_ = poPlan.Parts()
	_n_ = len(_aP_)
	_h_ = "<div class='auxcol'>"
	_h_ += "<div class='axview' id='ax-none'><div class='axcard axprompt'>Select a part on the left to see where each of its capabilities deploys, then open its emulator.</div></div>"
	for _i_ = 1 to _n_
		_p_ = _aP_[_i_]
		_cls_ = _p_[4]
		_st_ = _StzEmuStatus(_cls_)
		_fd_ = _StzEmuFidelity(_cls_)
		_h_ += "<div class='axview' id='ax-" + _p_[1] + "' style='display:none'><div class='axcard'>"
		_h_ += "<button class='pri' data-part='" + _p_[1] + "' onclick='openEmu(this)'>Open emulator</button>"
		_h_ += "<div class='axhead'>" + _StzEmuGlyph(_cls_) + " <span class='axname'>" + _StzEmuCap(_p_[1]) + "</span> <span class='chip'>" + _p_[3] + "</span>"
		_h_ += " <span class='stat " + _st_[1] + "'><span class='dot'></span> " + _st_[2] + "</span></div>"
		_h_ += "<h4>Runs here</h4><div class='sub2'>where each capability this part uses is delivered</div>"
		_decs_ = _p_[5]
		_m_ = len(_decs_)
		for _k_ = 1 to _m_
			_d_ = _decs_[_k_]
			_lbl_ = poPlan.LabelFor(_d_[3], _cls_)
			_h_ += "<div class='caprow'><span>" + _d_[2] + "</span><span class='vec'>" + _lbl_ + "</span></div>"
		next
		_h_ += "<h4 class='mt'>Fidelity</h4><div class='fid " + _fd_[1] + "'><span class='dot'></span> " + _fd_[3] + "</div>"
		_h_ += "</div></div>"
	next
	_h_ += "</div>"
	return _h_

  #-- the maximized popup: device (left) + log & console (right)

func _StzEmuPhoneDevice(poPlan, paPart)
	return "<div class='bigphone'><iframe class='appscreen' data-src='app_" + paPart[1] + ".html' title='app'></iframe></div>"

func _StzEmuBrowserDevice(poPlan, paPart)
	_h_ = "<div class='deskframe'><div class='deskbar'>"
	_h_ += "<span class='deskre'>&#x2039;&#x2003;&#x203a;</span>"
	_h_ += "<span class='deskurl'>https://" + paPart[1] + ".restolean.app</span>"
	_h_ += "<span class='deskre'>&#x21bb;</span></div>"
	_h_ += "<iframe class='deskscreen' data-src='app_" + paPart[1] + ".html' title='app'></iframe></div>"
	return _h_

func _StzEmuServerDevice(poPlan, paPart)
	_nm_ = paPart[1]
	_h_ = "<div class='console'><div class='consbar'><span class='stat ok'><span class='dot'></span></span> " + _nm_ + " . stz-reactor . native engine warm</div>"
	_h_ += "<div class='hint2'>Call an endpoint of the running backend -- the response appears in the log.</div>"
	# id='reqs-<part>': when an app model is attached, emulator.js rebuilds these
	# buttons from the part's REAL endpoints (the rehearsed set below is fallback).
	_h_ += "<div class='reqs' id='reqs-" + _nm_ + "'>"
	_h_ += "<button class='ghost' data-part='" + _nm_ + "' data-req='GET /menu' onclick='apiReq(this)'>GET /menu</button>"
	_h_ += "<button class='ghost' data-part='" + _nm_ + "' data-req='GET /orders' onclick='apiReq(this)'>GET /orders</button>"
	_h_ += "<button class='ghost' data-part='" + _nm_ + "' data-req='POST /order' onclick='apiReq(this)'>POST /order</button></div></div>"
	return _h_

func _StzEmuMcuDevice(poPlan, paPart)
	_nm_ = paPart[1]
	_h_ = "<div class='board'>" + _StzEmuBoardSvg(_nm_)
	_h_ += "<div class='readouts'><div>moisture (pin 34): <b id='moist-" + _nm_ + "'>--</b></div>"
	_h_ += "<div>pump (pin 26): <b id='pump-" + _nm_ + "'>off</b> <span class='led' id='led-" + _nm_ + "'></span></div></div>"
	_h_ += "<div class='hint2'>Drive the pins -- the board and the log react.</div>"
	_h_ += "<div class='reqs'><button class='ghost' data-part='" + _nm_ + "' data-act='read' onclick='pinAct(this)'>Read moisture (pin 34)</button>"
	_h_ += "<button class='ghost' data-part='" + _nm_ + "' data-act='pump' onclick='pinAct(this)'>Toggle pump (pin 26)</button></div></div>"
	return _h_

func _StzEmuPopups(poPlan)
	_aP_ = poPlan.Parts()
	_n_ = len(_aP_)
	_h_ = ""
	for _i_ = 1 to _n_
		_p_ = _aP_[_i_]
		_cls_ = _p_[4]
		_st_ = _StzEmuStatus(_cls_)
		if _cls_ = "server"
			_ph_ = "e.g. GET /orders"
		but _cls_ = "mcu"
			_ph_ = "e.g. read 34, or pump on"
		else
			_ph_ = "type a note to the app"
		ok
		_h_ += "<div class='modal' id='m-" + _p_[1] + "' onclick='bg(event)'><div class='window wide'>"
		_h_ += "<div class='wbar'>"
		_h_ += "<span class='wtitle'>" + _StzEmuGlyph(_cls_) + " " + _StzEmuCap(_p_[1]) + " <span class='chip'>" + _p_[3] + "</span></span>"
		_h_ += "<span class='wlive stat " + _st_[1] + "'><span class='dot'></span> " + _st_[2] + "</span>"
		_h_ += "<button class='wclose' onclick='closeEmu()' aria-label='close'>&times;</button></div>"
		_h_ += "<div class='wsplit'><div class='dzone'>"
		if _cls_ = "browser"
			_h_ += _StzEmuBrowserDevice(poPlan, _p_)
		but _StzEmuIsMobile(_cls_)
			_h_ += _StzEmuPhoneDevice(poPlan, _p_)
		but _cls_ = "mcu"
			_h_ += _StzEmuMcuDevice(poPlan, _p_)
		else
			_h_ += _StzEmuServerDevice(poPlan, _p_)
		ok
		_h_ += "</div><div class='rzone'><div class='rhead'>Live log &amp; console</div>"
		_h_ += "<div class='rlog' id='log-" + _p_[1] + "'><div class='ln muted'>ready.</div></div>"
		_h_ += "<div class='rconsole'><input id='q-" + _p_[1] + "' placeholder='" + _ph_ + "' onkeydown='qk(event,this)' data-part='" + _p_[1] + "' data-cls='" + _cls_ + "'>"
		_h_ += "<button class='pri sm' data-part='" + _p_[1] + "' data-cls='" + _cls_ + "' onclick='query(this)'>Send</button></div>"
		_h_ += "</div></div></div></div>"
	next
	return _h_

  #-- the web assets (emulator.css / emulator.js) are authored files that
  #-- live beside this module, NOT strings built here. Build() copies them
  #-- verbatim into each bundle and index.html links them. Edit them with
  #-- real CSS/JS tooling. Only the plan-driven HTML above is generated.

func _StzEmuAssetsDir()
	return _StzBaseDir() + "/system/emulator_assets"

func _StzEmuHtml(pcName, poPlan)
	_h_ = "<!doctype html>" + nl + "<html lang='en'><head><meta charset='utf-8'>" + nl
	_h_ += "<meta name='viewport' content='width=device-width, initial-scale=1'>" + nl
	_h_ += "<title>" + pcName + " -- Deploy(:Emulated)</title>" + nl
	_h_ += "<link rel='stylesheet' href='emulator.css'></head><body>" + nl
	_h_ += "<div class='head'><h1>" + pcName + " <span class='chip'>emulation</span></h1>" + nl
	_h_ += "<span class='stat ok'><span class='dot'></span> parts healthy</span></div>" + nl
	_h_ += "<div class='sub'>The whole solution, emulated in the browser -- each part runs its real engine. What works here ships as-is.</div>" + nl
	_h_ += "<div class='deploybar'><div class='t'><b>Ready to ship.</b> Every part runs its real engine here -- what works in emulation ships as-is.</div><button class='crit' onclick='deployProd()'>Deploy to production</button></div>" + nl
	_h_ += "<div class='page'>" + _StzEmuGridCol(poPlan) + _StzEmuAuxCol(poPlan) + "</div>" + nl
	_h_ += _StzEmuPopups(poPlan) + nl
	_h_ += "<script src='stz_parts.js'></script>" + nl
	_h_ += "<script src='stz_appdata.js'></script>" + nl
	_h_ += "<script src='stz.js'></script>" + nl
	_h_ += "<script src='emulator.js'></script>" + nl
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

# The plan-derived engine map, as a tiny JS asset emulator.js reads: for each
# frontend part, its own stz.wasm subset file + the groups it carries. This is
# how a device console knows to load ONLY its part's subset.
func _StzEmuPartsJs(paWasmParts)
	_j_ = "window.STZ_PARTS = {" + nl
	_n_ = len(paWasmParts)
	for _i_ = 1 to _n_
		_wp_ = paWasmParts[_i_]
		_j_ += "  '" + _wp_[1] + "': { wasm: '" + _wp_[2] + "', groups: '" + _wp_[3] + "' }"
		if _i_ < _n_
			_j_ += ","
		ok
		_j_ += nl
	next
	_j_ += "};" + nl
	return _j_

# The app MODEL, as a JS asset emulator.js reads (window.STZ_APPDATA): each api
# part's real endpoints (with the engine-computed /stats) and each device part's
# pins + automation rule. This is what makes the backend/device consoles answer
# with REAL data + REAL logic instead of a rehearsed map. Empty when no model.
func _StzEmuAppDataJs(poApp, poPlan)
	_j_ = "window.STZ_APPDATA = {" + nl
	if NOT isObject(poApp)
		return _j_ + "};" + nl
	ok
	_aP_ = poPlan.Parts()
	_n_ = len(_aP_)
	_entries_ = []
	for _i_ = 1 to _n_
		_pn_ = _aP_[_i_][1]
		if poApp.RoleOf(_pn_) = "api"
			_entries_ + _StzEmuApiEntry(poApp, _pn_)
		but poApp.HasDevice(_pn_)
			_entries_ + _StzEmuDeviceEntry(poApp, _pn_)
		ok
	next
	_ne_ = len(_entries_)
	for _i_ = 1 to _ne_
		_j_ += "  " + _entries_[_i_]
		if _i_ < _ne_
			_j_ += ","
		ok
		_j_ += nl
	next
	_j_ += "};" + nl
	return _j_

func _StzEmuApiEntry(poApp, pcPart)
	_eps_ = poApp.ApiEndpointsFor(pcPart)
	_s_ = "'" + pcPart + "': { kind: 'api', endpoints: ["
	_n_ = len(_eps_)
	for _i_ = 1 to _n_
		_e_ = _eps_[_i_]
		if _e_[2] = -1
			_st_ = _e_[3]
			_s_ += "{ req: '" + _e_[1] + "', stats: { total: " + _st_[1] + ", top: " + _StzEmuJs(_st_[2]) + ", topRev: " + _st_[3] + " } }"
		else
			_s_ += "{ req: '" + _e_[1] + "', count: " + _e_[2] + " }"
		ok
		if _i_ < _n_
			_s_ += ", "
		ok
	next
	_s_ += "] }"
	return _s_

func _StzEmuDeviceEntry(poApp, pcPart)
	_d_ = poApp.DeviceOf(pcPart)
	_pins_ = _d_[1]
	_rule_ = _d_[2]
	_s_ = "'" + pcPart + "': { kind: 'device', pins: ["
	_n_ = len(_pins_)
	for _i_ = 1 to _n_
		_p_ = _pins_[_i_]
		_s_ += "{ pin: " + _p_[1] + ", label: " + _StzEmuJs(_p_[2]) + ", role: " + _StzEmuJs(_p_[3]) + ", value: " + _p_[4] + " }"
		if _i_ < _n_
			_s_ += ", "
		ok
	next
	_s_ += "]"
	if len(_rule_) = 3
		_s_ += ", rule: { sensor: " + _StzEmuJs(_rule_[1]) + ", threshold: " + _rule_[2] + ", actuator: " + _StzEmuJs(_rule_[3]) + " }"
	ok
	_s_ += " }"
	return _s_

# a single-quoted JS string literal, apostrophes escaped.
func _StzEmuJs(pcS)
	return "'" + StzReplace("" + pcS, "'", char(92) + "'") + "'"


  #===============#
 #  STZEMULATOR   #
#===============#

class stzEmulator from stzObject

	@oDelivery = NULL
	@cOutDir = ""
	@aFiles = []
	@bBuilt = FALSE
	@bEngine = TRUE   # compile each part's stz.wasm subset (off = wiring only, fast)

	def init(poDelivery)
		@oDelivery = poDelivery

	def SetOutDirQ(pcDir)
		@cOutDir = "" + pcDir
		return This

	# Toggle the per-part engine compilation. Default ON (device consoles run the
	# real engine). CompileEngineQ(FALSE) emits the plan map + graceful fallback without
	# invoking Zig -- for fast, toolchain-free generation (and guards).
	def CompileEngineQ(pbOn)
		@bEngine = pbOn
		return This

	def BundleDir()
		if @cOutDir != ""
			return @cOutDir
		ok
		return @oDelivery.Name() + "_emulator"

	def Build()
		_oPlan_ = @oDelivery.Plan()
		_cDir_ = This.BundleDir()
		StzEngineDirCreatePath(_cDir_)
		@aFiles = []
		write(_cDir_ + "/index.html", _StzEmuHtml(@oDelivery.Name(), _oPlan_))
		@aFiles + "index.html"

		# copy the authored web assets into the bundle (clean web app: linked, not inlined)
		_cSrc_ = _StzEmuAssetsDir()
		if StzEngineFileExists(_cSrc_ + "/emulator.css") = 0 or StzEngineFileExists(_cSrc_ + "/emulator.js") = 0
			stzraise("stzEmulator: web assets not found at " + _cSrc_ + " (expected emulator.css / emulator.js).")
		ok
		write(_cDir_ + "/emulator.css", read(_cSrc_ + "/emulator.css"))
		@aFiles + "emulator.css"
		write(_cDir_ + "/emulator.js", read(_cSrc_ + "/emulator.js"))
		@aFiles + "emulator.js"
		write(_cDir_ + "/stz.js", read(_cSrc_ + "/stz.js"))
		@aFiles + "stz.js"

		# Each frontend part: its app shell + its OWN engine subset. The subset is
		# the plan's [stz.wasm]-placed capabilities for THAT part, mapped to build
		# groups -- emit ONLY what the part uses (a part that only pivots ships only
		# aggregation, no solver, no number theory). Identical subsets are built
		# once and shared. Ring read/write copies the binary faithfully.
		_aP_ = _oPlan_.Parts()
		_n_ = len(_aP_)
		_aWasmParts_ = []   # [ part, wasmFile, groupsCsv ] -> the page's engine map
		_aByKey_ = []       # dedup: [ groupsCsv, wasmFile ] already built this run
		for _i_ = 1 to _n_
			_p_ = _aP_[_i_]
			if NOT _StzEmuIsMobile(_p_[4])
				loop
			ok
			_cApp_ = "app_" + _p_[1] + ".html"
			write(_cDir_ + "/" + _cApp_, _StzEmuAppHtml(@oDelivery.App(), @oDelivery.Name(), _p_[1]))
			@aFiles + _cApp_
			_grp_ = StzWasmGroupsFor(_oPlan_.EngineCapsFor(_p_[1]))
			if len(_grp_) = 0
				loop
			ok
			_csv_ = _grp_[1]
			for _j_ = 2 to len(_grp_)
				_csv_ += "," + _grp_[_j_]
			next
			_cWFile_ = "stz_" + _p_[1] + ".wasm"
			if @bEngine
				_cPrior_ = ""
				_nb_ = len(_aByKey_)
				for _k_ = 1 to _nb_
					if _aByKey_[_k_][1] = _csv_
						_cPrior_ = _aByKey_[_k_][2]
					ok
				next
				if _cPrior_ != ""
					write(_cDir_ + "/" + _cWFile_, read(_cDir_ + "/" + _cPrior_))
				else
					if StzBuildEngineWasmSubset(_grp_, _cDir_ + "/" + _cWFile_) != ""
						_aByKey_ + [ _csv_, _cWFile_ ]
					ok
				ok
			ok
			if StzEngineFileExists(_cDir_ + "/" + _cWFile_) = 1
				@aFiles + _cWFile_
			ok
			_aWasmParts_ + [ _p_[1], _cWFile_, _csv_ ]
		next

		# the plan-derived engine map (always emitted, even without the binaries):
		# emulator.js reads it to load each part's own subset.
		write(_cDir_ + "/stz_parts.js", _StzEmuPartsJs(_aWasmParts_))
		@aFiles + "stz_parts.js"

		# the app model as data -- the backend/device consoles answer from it.
		write(_cDir_ + "/stz_appdata.js", _StzEmuAppDataJs(@oDelivery.App(), _oPlan_))
		@aFiles + "stz_appdata.js"

		write(_cDir_ + "/manifest.json", _StzEmuManifest(@oDelivery.Name(), _oPlan_))
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
