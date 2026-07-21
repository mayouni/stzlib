#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZEMULATOR               #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Deploy(:Emulated) -- the programming-phase   #
#                  face of Deploy(). Generates a web mission    #
#                  control from a stzBuilderBrain plan. Main    #
#                  page: a parts GRID (left) + the selected     #
#                  part's auxiliary data (right). Each part     #
#                  opens a maximized device WINDOW split into   #
#                  the device (left) and a live log + query     #
#                  console (right). Calm, standard, usable.     #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#

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

func _StzEmuAppHtml(pcSol, pcPart)
	_nm_ = _StzEmuCap(pcSol)
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
	_a_ += "<main><div class='hi'>Scan . Order . Pay -- table 7</div>"
	_a_ += _StzEmuDish("Royal couscous", "Semolina, lamb, vegetables", 24)
	_a_ += _StzEmuDish("Grilled tajine", "Slow-cooked, with olives", 19)
	_a_ += _StzEmuDish("Brik a l oeuf", "Crispy, egg and tuna", 6)
	_a_ += _StzEmuDish("Mint tea", "With pine nuts", 3)
	_a_ += _StzEmuDish("Makroudh", "Date pastry, honey", 5)
	_a_ += "</main>"
	_a_ += "<footer><span class='t' id='total'>0 DT</span><button id='order' disabled onclick='order()'>Order and pay</button></footer></div>"
	_a_ += "<div class='ok' id='ok'><div class='c'>+</div><h2>Order confirmed</h2><p>Your order is on its way to the kitchen.</p><button onclick='reset()'>New order</button></div>"
	_a_ += "<script>var n=0,t=0;function LOG(m){try{parent.postMessage({t:'applog',m:m},'*')}catch(e){}}"
	_a_ += "function add(el){n++;t+=parseInt(el.getAttribute('data-p'),10);document.getElementById('cart').textContent=n+(n===1?' item':' items');document.getElementById('total').textContent=t+' DT';document.getElementById('order').disabled=false;LOG('added '+el.getAttribute('data-n')+' ('+el.getAttribute('data-p')+' DT)')}"
	_a_ += "function order(){if(n>0){document.getElementById('ok').style.display='flex';LOG('order placed: '+n+' items, '+t+' DT')}}"
	_a_ += "function reset(){n=0;t=0;document.getElementById('cart').textContent='0 items';document.getElementById('total').textContent='0 DT';document.getElementById('order').disabled=true;document.getElementById('ok').style.display='none';LOG('new order started')}"
	_a_ += "</script></body></html>"
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
	_h_ += "<div class='reqs'>"
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

func _StzEmuScript()
	_j_ = "var openPart=null;" + nl
	_j_ += "function closeModals(){var m=document.getElementsByClassName('modal');for(var i=0;i<m.length;i++)m[i].classList.remove('open');openPart=null}" + nl
	_j_ += "function openPop(n){closeModals();var m=document.getElementById('m-'+n);if(m){m.classList.add('open');openPart=n;var f=m.querySelector('iframe[data-src]');if(f&&!f.getAttribute('src')){f.setAttribute('src',f.getAttribute('data-src'))}}}" + nl
	_j_ += "function sel(el){var n=el.getAttribute('data-part');var g=document.getElementsByClassName('grow');for(var i=0;i<g.length;i++)g[i].classList.remove('sel');el.classList.add('sel');" + nl
	_j_ += "var a=document.getElementsByClassName('axview');for(var j=0;j<a.length;j++)a[j].style.display='none';var v=document.getElementById('ax-'+n);if(v)v.style.display='block'}" + nl
	_j_ += "function filt(el){var f=el.getAttribute('data-f');var b=document.getElementsByClassName('fbtn');for(var i=0;i<b.length;i++)b[i].classList.remove('active');el.classList.add('active');var s=document.getElementsByClassName('gsection');for(var k=0;k<s.length;k++){s[k].style.display=(f==='all'||s[k].getAttribute('data-tier')===f)?'block':'none'}}" + nl
	_j_ += "function openEmu(el){openPop(el.getAttribute('data-part'))}" + nl
	_j_ += "function closeEmu(){closeModals()}" + nl
	_j_ += "function bg(e){if(e.target.classList.contains('modal')){closeEmu()}}" + nl
	_j_ += "function addLine(id,t){var log=document.getElementById(id);var d=document.createElement('div');d.className='ln';d.textContent=t;log.appendChild(d);log.scrollTop=log.scrollHeight}" + nl
	_j_ += "var API={'GET /menu':'200 OK  5 dishes','GET /orders':'200 OK  12 rows','POST /order':'201 Created  order #1043'};" + nl
	_j_ += "function apiReq(el){var p=el.getAttribute('data-part');var r=el.getAttribute('data-req');addLine('log-'+p,'> '+r);addLine('log-'+p,'  '+(API[r]||'200 OK'))}" + nl
	_j_ += "var pumpOn={};" + nl
	_j_ += "function pinAct(el){var p=el.getAttribute('data-part');var a=el.getAttribute('data-act');doPin(p,a)}" + nl
	_j_ += "function doPin(p,a){if(a==='read'){var v=Math.round(450+Math.random()*120);var mo=document.getElementById('moist-'+p);if(mo)mo.textContent=v;addLine('log-'+p,'digitalRead(34) -> '+v)}" + nl
	_j_ += "else{pumpOn[p]=!pumpOn[p];var pm=document.getElementById('pump-'+p);if(pm)pm.textContent=pumpOn[p]?'ON':'off';var l=document.getElementById('led-'+p);if(l)l.className='led'+(pumpOn[p]?' on':'');var b=document.getElementById('bled-'+p);if(b)b.setAttribute('fill',pumpOn[p]?'#0a8f4f':'#cfd6e2');addLine('log-'+p,'digitalWrite(26,'+(pumpOn[p]?1:0)+') -> pump '+(pumpOn[p]?'ON':'off'))}}" + nl
	_j_ += "function query(el){var p=el.getAttribute('data-part');var c=el.getAttribute('data-cls');var inp=document.getElementById('q-'+p);var q=(inp.value||'').trim();if(!q)return;addLine('log-'+p,'> '+q);inp.value='';" + nl
	_j_ += "if(c==='server'){addLine('log-'+p,'  '+(API[q]||'200 OK'))}" + nl
	_j_ += "else if(c==='mcu'){var m=q.toLowerCase();if(m.indexOf('read')===0){doPin(p,'read')}else if(m.indexOf('pump')===0){doPin(p,'pump')}else{addLine('log-'+p,'  unknown pin command')}}" + nl
	_j_ += "else{addLine('log-'+p,'  app: '+q+' (noted)')}}" + nl
	_j_ += "function qk(e,el){if(e.key==='Enter'||e.keyCode===13){query(el)}}" + nl
	_j_ += "window.addEventListener('message',function(e){if(e.data&&e.data.t==='applog'&&openPart){addLine('log-'+openPart,e.data.m)}});" + nl
	_j_ += "document.addEventListener('keydown',function(e){if(e.key==='Escape'||e.keyCode===27){closeModals()}});" + nl
	_j_ += "function deployProd(){alert('Production deploy ships these same parts via the governed crossing. Run: brain.Deploy(:Production)')}" + nl
	_j_ += "var first=document.getElementsByClassName('grow')[0];if(first)sel(first);" + nl
	return _j_

func _StzEmuCss()
	_c_ = "*{box-sizing:border-box} body{margin:0;font-family:system-ui,sans-serif;background:#fff;color:#1b2333;padding:24px;max-width:1080px;margin:0 auto}" + nl
	_c_ += "h1{font-size:20px;font-weight:500;margin:0 0 3px} h4{font-size:13px;font-weight:500;margin:16px 0 3px}.mt{margin-top:16px}" + nl
	_c_ += ".sub{color:#6b7280;font-size:13px;margin-bottom:18px}.sub2{color:#8a93a3;font-size:12px;margin-bottom:10px}" + nl
	_c_ += ".head{display:flex;align-items:center;justify-content:space-between;gap:12px}.chip{font-size:12px;color:#6b7280;background:#f0f2f7;padding:2px 9px;border-radius:8px}" + nl
	_c_ += ".stat{display:inline-flex;align-items:center;gap:7px;font-size:13px}.dot{width:9px;height:9px;border-radius:50%;display:inline-block;flex:none}" + nl
	_c_ += ".ok{color:#0a8f4f}.ok .dot{background:#0a8f4f}.live{color:#2563eb}.live .dot{background:#2563eb;animation:pl 1.6s infinite}.warn{color:#b45309}.warn .dot{background:#b45309}@keyframes pl{0%,100%{opacity:1}50%{opacity:.3}}" + nl
	_c_ += ".badge{font-size:12px;padding:3px 9px;border-radius:8px}.badge.ok{background:#e3f4ec;color:#0a6c3d}.badge.warn{background:#fdf0e3;color:#8a4008}" + nl
	_c_ += "button{font-size:13px;padding:7px 13px;border-radius:8px;cursor:pointer;border:1px solid #d3d9e4;background:#fff;color:#1b2333}button:hover{background:#f5f7fb}button.pri{background:#0a8f4f;color:#fff;border-color:#0a8f4f}button.pri:hover{background:#098544}button.sm{font-size:12px;padding:6px 11px}button.ghost{background:#fff}" + nl
	_c_ += ".deploybar{display:flex;align-items:center;justify-content:space-between;gap:12px;background:#f0faf4;border:1px solid #b7e0ca;border-radius:12px;padding:12px 18px;margin-bottom:18px}.deploybar .t{font-size:13px;color:#0a6c3d}" + nl
	_c_ += ".page{display:flex;gap:22px;align-items:flex-start}.gridcol{flex:1;min-width:0}.auxcol{width:344px;flex:none;position:sticky;top:24px;align-self:flex-start;height:calc(100vh - 48px)}" + nl
	_c_ += ".filters{display:flex;gap:8px;margin-bottom:16px;flex-wrap:wrap}.fbtn{font-size:13px;padding:6px 15px;border-radius:20px;border:1px solid #e0e4ea;background:#fff;color:#4b5566;cursor:pointer}.fbtn:hover{background:#f5f7fb}.fbtn.active{background:#1b2333;color:#fff;border-color:#1b2333}" + nl
	_c_ += ".gtier{font-size:11px;color:#9aa3b2;text-transform:uppercase;letter-spacing:.5px;margin:16px 0 7px}.gtier:first-child{margin-top:0}.tiern{background:#eef1f6;color:#8a93a3;border-radius:10px;padding:1px 7px;font-size:11px}" + nl
	_c_ += ".grow{display:flex;align-items:center;justify-content:space-between;gap:10px;padding:10px 13px;border:1px solid #e6e9f0;border-radius:9px;margin-bottom:7px;cursor:pointer;font-size:14px}.grow:hover{border-color:#93b4f5;background:#f7f9fd}.grow.sel{border-color:#2563eb;background:#f0f5ff}" + nl
	_c_ += ".grleft{display:flex;align-items:center;gap:8px}.grleft svg{flex:none}.gtarget{font-size:12px;color:#8a93a3}.grright{display:flex;align-items:center;gap:12px}.gcaps{font-size:12px;color:#8a93a3;min-width:52px;text-align:right}" + nl
	_c_ += ".legend{display:flex;gap:16px;font-size:12px;color:#6b7280;margin-top:16px}" + nl
	_c_ += ".axview{height:100%}.axcard{background:#fff;border:1px solid #e6e9f0;border-radius:12px;padding:18px;box-shadow:0 1px 2px rgba(20,30,60,.05);height:100%;display:flex;flex-direction:column;overflow:auto}.axprompt{color:#8a93a3;font-size:13px}.axhead{display:flex;align-items:center;gap:8px;font-size:15px;margin:0 0 16px;flex-wrap:wrap}.axname{font-size:16px}.axcard .pri{align-self:flex-start;margin-bottom:16px}" + nl
	_c_ += ".caprow{display:flex;align-items:center;justify-content:space-between;font-size:13px;padding:6px 0;border-bottom:1px solid #f0f2f7}.vec{font-family:ui-monospace,monospace;font-size:11px;color:#4b5566;background:#f0f2f7;padding:2px 8px;border-radius:8px}" + nl
	_c_ += ".fid{font-size:13px;display:flex;gap:8px;align-items:baseline}.fid.ok{color:#0a6c3d}.fid.warn{color:#8a4008}.fid .dot{margin-top:5px}" + nl
	_c_ += ".modal{position:fixed;inset:0;background:rgba(22,28,42,.5);display:none;align-items:center;justify-content:center;padding:2.5vh 2vw;z-index:50}.modal.open{display:flex}" + nl
	_c_ += ".window.wide{width:96vw;height:95vh;max-width:1400px;background:#fff;border-radius:14px;box-shadow:0 24px 60px rgba(10,15,30,.34);display:flex;flex-direction:column;overflow:hidden}" + nl
	_c_ += ".wbar{display:flex;align-items:center;gap:10px;padding:11px 15px;border-bottom:1px solid #eef1f6;background:#fafbfc;flex:none}" + nl
	_c_ += ".deskframe{width:100%;max-width:960px;height:min(100%,calc(95vh - 120px));background:#fff;border:1px solid #d3d9e4;border-radius:10px;box-shadow:0 10px 30px rgba(50,60,80,.16);display:flex;flex-direction:column;overflow:hidden}.deskbar{display:flex;align-items:center;gap:12px;padding:10px 14px;background:#f1f3f5;border-bottom:1px solid #e0e4ea}.deskurl{flex:1;background:#fff;border:1px solid #e0e4ea;border-radius:16px;padding:6px 15px;font-size:12px;color:#6b7280;font-family:ui-monospace,monospace}.deskre{color:#a3abb8;font-size:14px}.deskscreen{flex:1;width:100%;border:0;background:#fff}" + nl
	_c_ += ".wtitle{display:flex;align-items:center;gap:8px;font-size:14px}.wlive{margin-left:auto;font-size:12px}.wclose{margin-left:10px;border:0;background:transparent;font-size:22px;color:#8a93a3;cursor:pointer;padding:0 6px;line-height:1}.wclose:hover{color:#1b2333}" + nl
	_c_ += ".wsplit{flex:1;display:flex;min-height:0}.dzone{flex:1;min-width:0;overflow:auto;padding:22px;display:flex;flex-direction:column;align-items:center;justify-content:center;background:#f7f8fa}.rzone{width:380px;flex:none;border-left:1px solid #eef1f6;display:flex;flex-direction:column;min-height:0}" + nl
	_c_ += ".rhead{font-size:12px;color:#6b7280;text-transform:uppercase;letter-spacing:.5px;padding:14px 16px 8px}.rlog{flex:1;overflow:auto;padding:0 16px;font-family:ui-monospace,monospace;font-size:12px;line-height:1.9}.rlog .ln{color:#1b2333}.rlog .muted{color:#9aa3b2}" + nl
	_c_ += ".rconsole{display:flex;gap:8px;padding:12px 16px;border-top:1px solid #eef1f6}.rconsole input{flex:1;border:1px solid #d3d9e4;border-radius:8px;padding:8px 11px;font-size:13px;font-family:ui-monospace,monospace}" + nl
	_c_ += ".bigphone{height:min(100%,calc(95vh - 90px));aspect-ratio:300/620;background:#4a5162;border-radius:40px;padding:11px;box-shadow:0 8px 24px rgba(50,60,80,.16);flex:none}.appscreen{width:100%;height:100%;border:0;border-radius:31px;background:#fff;display:block}" + nl
	_c_ += ".console,.board{width:100%;max-width:560px}.board{display:flex;flex-direction:column;align-items:center}.board svg{max-width:100%}.consbar{font-size:13px;color:#4b5566;margin-bottom:8px;display:flex;gap:8px;align-items:center}.hint2{font-size:12px;color:#8a93a3;margin-bottom:14px}" + nl
	_c_ += ".reqs{display:flex;gap:8px;flex-wrap:wrap;margin-top:6px;justify-content:center}.readouts{display:flex;gap:28px;font-size:13px;margin:12px 0 4px;color:#4b5566}.readouts b{color:#1b2333}.led{width:11px;height:11px;border-radius:50%;background:#cfd6e2;display:inline-block;vertical-align:middle}.led.on{background:#0a8f4f}" + nl
	return _c_

func _StzEmuHtml(pcName, poPlan)
	_h_ = "<!doctype html>" + nl + "<html lang='en'><head><meta charset='utf-8'>" + nl
	_h_ += "<meta name='viewport' content='width=device-width, initial-scale=1'>" + nl
	_h_ += "<title>" + pcName + " -- Deploy(:Emulated)</title>" + nl
	_h_ += "<style>" + nl + _StzEmuCss() + "</style></head><body>" + nl
	_h_ += "<div class='head'><h1>" + pcName + " <span class='chip'>emulation</span></h1>" + nl
	_h_ += "<span class='stat ok'><span class='dot'></span> parts healthy</span></div>" + nl
	_h_ += "<div class='sub'>The whole solution, emulated in the browser -- each part runs its real engine. What works here ships as-is.</div>" + nl
	_h_ += "<div class='deploybar'><div class='t'><b>Ready to ship.</b> Every part runs its real engine here -- what works in emulation ships as-is.</div><button class='pri' onclick='deployProd()'>Deploy to production</button></div>" + nl
	_h_ += "<div class='page'>" + _StzEmuGridCol(poPlan) + _StzEmuAuxCol(poPlan) + "</div>" + nl
	_h_ += _StzEmuPopups(poPlan) + nl
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
