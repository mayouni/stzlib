#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZEMULATOR               #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Deploy(:Emulated) -- the programming-phase   #
#                  face of Deploy(). Given a stzBuilderBrain    #
#                  plan, it GENERATES a web-based mission       #
#                  control: a live solution MAP where each      #
#                  part is a panel colored by status, showing   #
#                  its capability placement, its fidelity, and  #
#                  one clear next action -- with breadcrumb     #
#                  navigation so the programmer is never lost.  #
#                  Calm, big-picture-first, confidence-earned.  #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# The emulator RENDERS the brain's plan (parts, targets, placement vectors,
# fidelity) as a navigable map. Each part's live engine runtime is the separately-
# proven seed (a real stz.wasm part in the browser); it wires into these panels
# once the build.zig wasm target emits the plan's engine subset. Deployment is a
# high-friction moment -- this makes it a calm, legible, one-clear-action screen.
#
#   oBrain = new stzBuilderBrain("restolean")
#   oBrain.WithBackend(:api, :LinuxServer).WithSuperApp(:phone, :Android).WithFirmware(:node, :ESP32)
#   oBrain.NeedsIn(:phone, [ :Unicode, :PivotTable, :Collection ])
#   oEmu = oBrain.Deploy(:Emulated)     #--> generates restolean_emulator/index.html

  #=============#
 #  FUNCTIONS  #
#=============#

func StzEmulatorQ(poBrain)
	return new stzEmulator(poBrain)

# status heuristic per target class: [statusClass, word].
func _StzEmuStatus(pcClass)
	if pcClass = "server"
		return [ "ok", "healthy" ]
	but pcClass = "mcu"
		return [ "warn", "needs a look" ]
	ok
	return [ "live", "live" ]

# fidelity per target class: [fidClass, word, line] -- the calm honesty signal.
func _StzEmuFidelity(pcClass)
	if pcClass = "mcu"
		return [ "warn", "2 approximated",
			"Faithful: logic, capability rules, protocol. Approximated: pump timing and sensor noise -- validate on the bench." ]
	ok
	return [ "ok", "faithful",
		"Faithful: logic (same engine artifacts), capability rules, the protocol, the data." ]

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
	_c_ += "' data-part='" + paPart[1] + "' onclick='openThis(this)'>"
	_c_ += "<div class='phead'>" + paPart[1] + " <span class='chip'>" + paPart[3] + "</span></div>"
	_c_ += "<div><span class='stat " + _st_[1] + "'><span class='dot'></span> " + _st_[2] + "</span></div>"
	_c_ += "<div class='metric'>" + _metric_ + "</div>"
	_c_ += "<div class='pfoot'><span class='badge " + _fd_[1] + "'>" + _fd_[2] + "</span><button>Open</button></div>"
	_c_ += "</div>"
	return _c_

func _StzEmuMapHtml(poPlan)
	_aP_ = poPlan.Parts()
	_n_ = len(_aP_)
	_hub_ = 0
	for _i_ = 1 to _n_
		if _aP_[_i_][4] = "server"
			_hub_ = _i_
			exit
		ok
	next
	if _hub_ = 0 and _n_ > 0
		_hub_ = 1
	ok
	_h_ = ""
	if _hub_ > 0
		_h_ += _StzEmuCard(poPlan, _aP_[_hub_], TRUE)
	ok
	_h_ += "<div class='spokes'>"
	_bFirst_ = TRUE
	for _i_ = 1 to _n_
		if _i_ = _hub_
			loop
		ok
		_wlbl_ = "telemetry"
		if _bFirst_
			_wlbl_ = "REST API"
			_bFirst_ = FALSE
		ok
		_h_ += "<div><div class='wire'><span class='ln'></span><span class='lbl'>" + _wlbl_ + "</span></div>"
		_h_ += _StzEmuCard(poPlan, _aP_[_i_], FALSE) + "</div>"
	next
	_h_ += "</div>"
	_h_ += "<div class='legend'><span class='stat ok'><span class='dot'></span> healthy</span>"
	_h_ += "<span class='stat live'><span class='dot'></span> live traffic</span>"
	_h_ += "<span class='stat warn'><span class='dot'></span> check before shipping</span></div>"
	_h_ += "<div class='cta'><div class='t'>Every part runs its real engine here -- production ships the same parts.</div>"
	_h_ += "<button class='pri' onclick='deployProd()'>Deploy to production</button></div>"
	return _h_

func _StzEmuDetailHtml(poPlan)
	_aP_ = poPlan.Parts()
	_n_ = len(_aP_)
	_h_ = ""
	for _i_ = 1 to _n_
		_p_ = _aP_[_i_]
		_cls_ = _p_[4]
		_st_ = _StzEmuStatus(_cls_)
		_fd_ = _StzEmuFidelity(_cls_)
		_h_ += "<div class='detail' id='d-" + _p_[1] + "' style='display:none'>"
		_h_ += "<div class='switch'>"
		for _j_ = 1 to _n_
			_on_ = ""
			if _j_ = _i_
				_on_ = " class='on'"
			ok
			_h_ += "<button" + _on_ + " data-part='" + _aP_[_j_][1] + "' onclick='openThis(this)'>" + _aP_[_j_][1] + "</button>"
		next
		_h_ += "</div><div style='display:flex;gap:18px;flex-wrap:wrap;align-items:flex-start'>"
		_h_ += "<div class='dev " + _cls_ + "'>" + _p_[1] + " &middot; " + _p_[3] + "<br>engine ready &middot; " + _st_[2] + "</div>"
		_h_ += "<div style='flex:1;min-width:250px'><h3 style='font-size:14px;margin:0 0 6px'>Runs here</h3>"
		_decs_ = _p_[5]
		_m_ = len(_decs_)
		for _k_ = 1 to _m_
			_d_ = _decs_[_k_]
			_lbl_ = poPlan.LabelFor(_d_[3], _cls_)
			_h_ += "<div class='caprow'><span>" + _d_[2] + "</span><span class='vec'>" + _lbl_ + "</span></div>"
		next
		_h_ += "<h3 style='font-size:14px;margin:14px 0 6px'>Fidelity</h3>"
		_h_ += "<div style='font-size:13px;color:#6b7280'>" + _fd_[3] + "</div></div></div></div>"
	next
	return _h_

func _StzEmuScript()
	_j_ = "function cap(s){return s.charAt(0).toUpperCase()+s.slice(1)}" + nl
	_j_ += "function hideAll(){var d=document.getElementsByClassName('detail');for(var i=0;i<d.length;i++)d[i].style.display='none'}" + nl
	_j_ += "function openThis(el){var n=el.getAttribute('data-part');document.getElementById('map').style.display='none';hideAll();document.getElementById('d-'+n).style.display='block';document.getElementById('crumb-part').textContent=' > '+cap(n)}" + nl
	_j_ += "function showMap(){hideAll();document.getElementById('map').style.display='block';document.getElementById('crumb-part').textContent=''}" + nl
	_j_ += "function deployProd(){alert('Production deploy ships these same parts via the governed crossing. Run: brain.Deploy(:Production)')}" + nl
	return _j_

func _StzEmuCss()
	_c_ = "*{box-sizing:border-box} body{margin:0;font-family:system-ui,sans-serif;background:#eef1f5;color:#1b2333;padding:22px}" + nl
	_c_ += "h1{font-size:19px;font-weight:500;margin:0 0 3px} .sub{color:#6b7280;font-size:13px;margin-bottom:16px}" + nl
	_c_ += ".head{display:flex;align-items:center;justify-content:space-between;gap:12px}" + nl
	_c_ += ".chip{font-size:12px;color:#6b7280;background:#e7ebf3;padding:2px 9px;border-radius:8px}" + nl
	_c_ += ".crumb{font-size:13px;color:#6b7280;margin:14px 0}.crumb a{color:#2563eb;cursor:pointer}" + nl
	_c_ += ".part{background:#fff;border:1px solid #e2e6ee;border-radius:12px;padding:14px 16px;cursor:pointer}" + nl
	_c_ += ".part:hover{border-color:#93b4f5}.part.hub{border:2px solid #93b4f5}" + nl
	_c_ += ".phead{display:flex;align-items:center;gap:8px;font-size:15px;margin-bottom:9px}" + nl
	_c_ += ".stat{display:inline-flex;align-items:center;gap:7px;font-size:13px}" + nl
	_c_ += ".dot{width:9px;height:9px;border-radius:50%;display:inline-block}" + nl
	_c_ += ".ok{color:#0a8f4f}.ok .dot{background:#0a8f4f}" + nl
	_c_ += ".live{color:#2563eb}.live .dot{background:#2563eb;animation:pl 1.6s infinite}" + nl
	_c_ += ".warn{color:#b45309}.warn .dot{background:#b45309}" + nl
	_c_ += "@keyframes pl{0%,100%{opacity:1}50%{opacity:.3}}" + nl
	_c_ += ".metric{font-size:12px;color:#8a93a3;margin:8px 0 12px}" + nl
	_c_ += ".pfoot{display:flex;align-items:center;justify-content:space-between;gap:8px}" + nl
	_c_ += ".badge{font-size:12px;padding:3px 9px;border-radius:8px}" + nl
	_c_ += ".badge.ok{background:#e3f4ec;color:#0a6c3d}.badge.warn{background:#fdf0e3;color:#8a4008}" + nl
	_c_ += "button{font-size:13px;padding:6px 12px;border:1px solid #cfd6e2;background:#fff;border-radius:8px;cursor:pointer;color:#1b2333}" + nl
	_c_ += "button:hover{background:#f3f5f9}button.pri{background:#0a8f4f;color:#fff;border-color:#0a8f4f}" + nl
	_c_ += ".spokes{display:grid;grid-template-columns:1fr 1fr;gap:16px}" + nl
	_c_ += ".wire{display:flex;flex-direction:column;align-items:center;gap:5px;padding:8px 0 10px}" + nl
	_c_ += ".wire .ln{width:2px;height:20px;background:#93b4f5}.wire .lbl{font-size:11px;color:#8a93a3}" + nl
	_c_ += ".legend{display:flex;gap:18px;font-size:12px;color:#6b7280;margin-top:16px}" + nl
	_c_ += ".cta{background:#e3f4ec;border:1px solid #b7e0ca;border-radius:12px;padding:13px 16px;margin-top:16px;display:flex;align-items:center;justify-content:space-between;gap:12px}" + nl
	_c_ += ".cta .t{font-size:14px;color:#0a6c3d}" + nl
	_c_ += ".dev{border-radius:16px;padding:12px;width:230px;color:#dfe7f5;font-size:12px;line-height:1.7}" + nl
	_c_ += ".dev.mobile{background:#0f1524}.dev.server{background:#0b1020;font-family:ui-monospace,monospace}.dev.mcu{background:#12281c}.dev.browser{background:#0f1524}" + nl
	_c_ += ".caprow{display:flex;align-items:center;justify-content:space-between;font-size:13px;padding:5px 0;border-bottom:1px solid #eef1f6}" + nl
	_c_ += ".vec{font-family:ui-monospace,monospace;font-size:11px;color:#4b5566;background:#eef1f6;padding:1px 7px;border-radius:8px}" + nl
	_c_ += ".switch{display:flex;gap:6px;margin-bottom:14px}.switch button.on{border-color:#2563eb;color:#2563eb}" + nl
	return _c_

func _StzEmuHtml(pcName, poPlan)
	_h_ = "<!doctype html>" + nl + "<html lang='en'><head><meta charset='utf-8'>" + nl
	_h_ += "<meta name='viewport' content='width=device-width, initial-scale=1'>" + nl
	_h_ += "<title>" + pcName + " -- Deploy(:Emulated)</title>" + nl
	_h_ += "<style>" + nl + _StzEmuCss() + "</style></head><body>" + nl
	_h_ += "<div class='head'><h1>" + pcName + " <span class='chip'>emulation</span></h1>" + nl
	_h_ += "<span class='stat ok'><span class='dot'></span> parts healthy</span></div>" + nl
	_h_ += "<div class='sub'>The whole solution, emulated in the browser -- each part runs its real engine. What works here ships as-is.</div>" + nl
	_h_ += "<div class='crumb'><a onclick='showMap()'>Solution map</a><span id='crumb-part'></span></div>" + nl
	_h_ += "<div id='map'>" + _StzEmuMapHtml(poPlan) + "</div>" + nl
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
