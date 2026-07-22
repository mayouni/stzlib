# Per-part APP LOGIC -- each part runs its OWN app, driven by the solution's
# app MODEL, not a shared placeholder.
#
# A stzSolutionApp holds the solution's real domain DATA (a menu, an order
# history) and gives each part a ROLE over it. The emulator then renders each
# part FROM the model: a "menu" part shows its real menu; a "dashboard" part
# shows figures the ENGINE computed (revenue by dish -- the part's declared
# :PivotTable capability, running for real via stzTable). One definition drives
# every part; no two parts are the same hardcoded screen.
#
# Ring traps avoided: no oR/nL locals; main before the first func; no inline
# new X().M(); StzFindFirst (scalar), not StzFind (a list).

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cDir = WorkingDirectory() + "/_partapp_scratch"

# the solution's real data -- computed expectations are independent (below).
aMenu = [
	[ "Royal couscous", "Semolina, lamb, vegetables", 24 ],
	[ "Grilled tajine", "Slow-cooked, with olives",    19 ],
	[ "Brik a l oeuf",  "Crispy, egg and tuna",         6 ],
	[ "Mint tea",       "With pine nuts",               3 ],
	[ "Makroudh",       "Date pastry, honey",           5 ]
]
aOrders = [
	[ "Royal couscous", 12 ],   # 12 * 24 = 288
	[ "Grilled tajine",  8 ],   #  8 * 19 = 152
	[ "Brik a l oeuf",  20 ],   # 20 *  6 = 120
	[ "Mint tea",       30 ],   # 30 *  3 =  90
	[ "Makroudh",       10 ]    # 10 *  5 =  50
]                               # total = 700, top = Royal couscous @ 288

oApp = new stzSolutionApp("restolean")
oApp.AddDatasetQ(:menu, aMenu)
oApp.AddDatasetQ(:orders, aOrders)
oApp.SetPartRoleQ(:phone, :menu, :menu)       # the guest-facing waiter app
oApp.SetPartRoleQ(:admin, :dashboard, :orders) # the manager dashboard

? "-- Scene 1: the app MODEL holds the solution's real data + per-part roles --"
chk("the phone part's role is 'menu'", oApp.RoleOf(:phone) = "menu")
chk("...the admin part's role is 'dashboard'", oApp.RoleOf(:admin) = "dashboard")
chk("the menu the phone shows is the real dataset (5 dishes)", len(oApp.MenuOf(:phone)) = 5)
chk("...a part with no role declared has none", NOT oApp.HasRoleFor(:ghost))

? ""
? "-- Scene 2: the dashboard is COMPUTED by the engine, not hardcoded --"
aDash = oApp.DashboardOf(:admin)
aRevRows = aDash[1]
nTotal = aDash[2]
cTop = aDash[3]
nTopRev = aDash[4]
chk("revenue is computed per dish (5 rows)", len(aRevRows) = 5)
chk("total revenue = the engine's SumCol (288+152+120+90+50 = 700)", nTotal = 700)
chk("...the top seller is Royal couscous (12 x 24 = 288)", cTop = "Royal couscous" and nTopRev = 288)
chk("...each figure is real: Brik = 20 x 6 = 120", aRevRows[3][1] = "Brik a l oeuf" and aRevRows[3][3] = 120)

? ""
? "-- Scene 3: the emulator renders each part FROM the model --"
oDelivery = new stzDelivery("restolean")
oDelivery.AddSuperApp(:phone, :Android)     # mobile  -> gets an app screen
oDelivery.AddApp(:admin, :Browser)          # browser -> gets an app screen
oDelivery.AddBackend(:api, :LinuxServer)    # server  -> console, no app html
oDelivery.NeedsIn(:phone, [ :Unicode, :Collection ])
oDelivery.NeedsIn(:admin, [ :PivotTable, :Collection ])
oDelivery.NeedsIn(:api, [ :PivotTable ])
oDelivery.RunsAppQ(oApp)
chk("the delivery now carries an app model", oDelivery.HasApp())

oEmu = new stzEmulator(oDelivery)
oEmu.CompileEngineQ(FALSE)                   # map-only: fast, no wasm toolchain
oEmu.SetOutDirQ(cDir + "/dist")
oEmu.Build()
chk("the emulator built the bundle", oEmu.IsBuilt())
chk("...it emitted a per-part app for the phone AND the admin", StzEngineFileExists(cDir + "/dist/app_phone.html") = 1 and StzEngineFileExists(cDir + "/dist/app_admin.html") = 1)

cPhone = read(cDir + "/dist/app_phone.html")
cAdmin = read(cDir + "/dist/app_admin.html")

? ""
? "-- Scene 4: the WAITER app shows the real menu; the ADMIN a computed dashboard --"
chk("the waiter app lists a real menu dish (Royal couscous)", StzFindFirst("Royal couscous", cPhone) > 0)
chk("...with the menu markup (orderable dishes)", StzFindFirst("class='dish'", cPhone) > 0)
chk("...and its price from the data (24 DT)", StzFindFirst("24 DT", cPhone) > 0)
chk("the admin app is a dashboard -- 'Revenue by dish'", StzFindFirst("Revenue by dish", cAdmin) > 0)
chk("...showing the engine-computed total (700 DT)", StzFindFirst("700 DT", cAdmin) > 0)
chk("...naming the top seller (Royal couscous)", StzFindFirst("Royal couscous", cAdmin) > 0)
chk("...and it credits the on-device engine", StzFindFirst("on-device engine", cAdmin) > 0)

? ""
? "-- Scene 5: the two parts are DIFFERENT apps (not one placeholder) --"
chk("the admin app is NOT the waiter menu (no orderable dishes)", StzFindFirst("class='dish'", cAdmin) = 0)
chk("...the waiter app is NOT the dashboard (no revenue view)", StzFindFirst("Revenue by dish", cPhone) = 0)

? ""
? "-- Scene 6: back-compat -- a solution with NO app model still renders --"
oPlain = new stzDelivery("plain")
oPlain.AddSuperApp(:phone, :Android)
oPlain.NeedsIn(:phone, [ :Unicode, :Collection ])
oEmu2 = new stzEmulator(oPlain)
oEmu2.CompileEngineQ(FALSE)
oEmu2.SetOutDirQ(cDir + "/dist2")
oEmu2.Build()
cDemo = read(cDir + "/dist2/app_phone.html")
chk("no app model -> the demo menu still generates (fallback intact)", StzFindFirst("class='dish'", cDemo) > 0 and StzFindFirst("Order and pay", cDemo) > 0)

StzDirDeleteAll(cDir)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
