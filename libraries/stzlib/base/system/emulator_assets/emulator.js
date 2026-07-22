/* emulator.js -- authored routing + interaction for the Deploy(:Emulated) console.
   Consumed by stzEmulator.ring, which copies it verbatim into every generated
   bundle and links it from index.html. Edit HERE, with real JS tooling --
   never inside the Ring generator.

   The rehearsed responses below (API map, moisture readings, pin toggles) are
   placeholders for the programming phase; the build.zig wasm target replaces
   them with each part's real engine calls. */

var openPart = null;
var engineMods = {};       // part -> { mod, groups } once its stz.wasm subset loads
var engineHinted = {};     // parts whose window has shown the engine-ready hint

/* -- device windows (modals) -- */

function closeModals() {
	var m = document.getElementsByClassName('modal');
	for (var i = 0; i < m.length; i++) m[i].classList.remove('open');
	openPart = null;
}

function openPop(n) {
	closeModals();
	var m = document.getElementById('m-' + n);
	if (m) {
		m.classList.add('open');
		openPart = n;
		// lazy-load the part's app iframe only when its window first opens
		var f = m.querySelector('iframe[data-src]');
		if (f && !f.getAttribute('src')) { f.setAttribute('src', f.getAttribute('data-src')); }
		loadEngineFor(n);
	}
}

// Load a part's OWN engine subset (named in the plan map), then hint what it
// carries. Only the capabilities this part uses are shipped, so its console can
// run exactly those verbs -- nothing more.
function loadEngineFor(n) {
	if (typeof window.STZ_PARTS === 'undefined' || !window.STZ_PARTS[n]) return; // no engine for this part
	if (engineMods[n]) { engineHint(n); return; }
	if (typeof StzWasm === 'undefined') return;
	var spec = window.STZ_PARTS[n];
	StzWasm.load(spec.wasm).then(function (m) {
		engineMods[n] = { mod: m, groups: spec.groups };
		if (openPart === n) engineHint(n);
	}).catch(function () { /* subset binary absent -> console keeps rehearsed verbs */ });
}

// Announce the part's real engine subset, once, when its stz.wasm has loaded.
function engineHint(n) {
	var em = engineMods[n];
	if (!em || engineHinted[n]) return;
	engineHinted[n] = true;
	addLine('log-' + n, 'stz.wasm ready (abi ' + em.mod.abi + ') -- this part carries the ' + em.groups + ' engine subset.');
	var tips = [];
	if (em.groups.indexOf('solver') >= 0) { tips.push('solve 2 -8'); }
	if (em.groups.indexOf('aggregation') >= 0) { tips.push('mean 10 20 30 40'); }
	if (em.groups.indexOf('numtheory') >= 0) { tips.push('prime 100'); tips.push('gcd 48 36'); }
	if (tips.length) { addLine('log-' + n, 'try:  ' + tips.join('   .   ')); }
}

function openEmu(el) { openPop(el.getAttribute('data-part')); }
function closeEmu() { closeModals(); }
function bg(e) { if (e.target.classList.contains('modal')) { closeEmu(); } }

/* -- master/detail: grid selection + role filter -- */

function sel(el) {
	var n = el.getAttribute('data-part');
	var g = document.getElementsByClassName('grow');
	for (var i = 0; i < g.length; i++) g[i].classList.remove('sel');
	el.classList.add('sel');
	var a = document.getElementsByClassName('axview');
	for (var j = 0; j < a.length; j++) a[j].style.display = 'none';
	var v = document.getElementById('ax-' + n);
	if (v) v.style.display = 'block';
}

function filt(el) {
	var f = el.getAttribute('data-f');
	var b = document.getElementsByClassName('fbtn');
	for (var i = 0; i < b.length; i++) b[i].classList.remove('active');
	el.classList.add('active');
	var s = document.getElementsByClassName('gsection');
	for (var k = 0; k < s.length; k++) {
		s[k].style.display = (f === 'all' || s[k].getAttribute('data-tier') === f) ? 'block' : 'none';
	}
}

/* -- live log -- */

function addLine(id, t) {
	var log = document.getElementById(id);
	var d = document.createElement('div');
	d.className = 'ln';
	d.textContent = t;
	log.appendChild(d);
	log.scrollTop = log.scrollHeight;
}

/* -- backend device (endpoints) -- */

var API = {
	'GET /menu': '200 OK  5 dishes',
	'GET /orders': '200 OK  12 rows',
	'POST /order': '201 Created  order #1043'
};

function apiReq(el) {
	var p = el.getAttribute('data-part');
	var r = el.getAttribute('data-req');
	addLine('log-' + p, '> ' + r);
	addLine('log-' + p, '  ' + (API[r] || '200 OK'));
}

/* -- mcu device (pins) -- */

var pumpOn = {};

function pinAct(el) { doPin(el.getAttribute('data-part'), el.getAttribute('data-act')); }

function doPin(p, a) {
	if (a === 'read') {
		var v = Math.round(450 + Math.random() * 120);
		var mo = document.getElementById('moist-' + p);
		if (mo) mo.textContent = v;
		addLine('log-' + p, 'digitalRead(34) -> ' + v);
	} else {
		pumpOn[p] = !pumpOn[p];
		var pm = document.getElementById('pump-' + p);
		if (pm) pm.textContent = pumpOn[p] ? 'ON' : 'off';
		var l = document.getElementById('led-' + p);
		if (l) l.className = 'led' + (pumpOn[p] ? ' on' : '');
		var b = document.getElementById('bled-' + p);
		if (b) b.setAttribute('fill', pumpOn[p] ? '#0a8f4f' : '#cfd6e2');
		addLine('log-' + p, 'digitalWrite(26,' + (pumpOn[p] ? 1 : 0) + ') -> pump ' + (pumpOn[p] ? 'ON' : 'off'));
	}
}

/* -- real engine verbs, run on stz.wasm (the differential edge) -------------
   These call the SAME Zig logic that backs the native DLLs, compiled to wasm.
   Available in every window's console once stz.wasm has loaded. */
function tryEngine(p, q) {
	var em = engineMods[p];
	if (!em) return false;
	var e = em.mod.exports;
	var t = q.trim().split(/\s+/);
	var cmd = t[0].toLowerCase();
	// a verb whose function is not in THIS part's subset is reported as such --
	// the whole point of per-part emission is visible here.
	function need(fn, label) {
		if (typeof e[fn] === 'function') { return true; }
		addLine('log-' + p, '  ' + label + ' is not in this part\'s engine subset (' + em.groups + ')');
		return false;
	}
	try {
		if (cmd === 'solve' && t.length === 3) {
			if (need('stz_solve_linear', 'solve')) { addLine('log-' + p, '  stz.wasm . solve ' + t[1] + 'x + (' + t[2] + ') = 0  ->  x = ' + e.stz_solve_linear(parseFloat(t[1]), parseFloat(t[2]))); }
			return true;
		}
		if (cmd === 'prime' && t.length === 2) {
			if (need('stz_nth_prime', 'prime')) { addLine('log-' + p, '  stz.wasm . nth_prime(' + t[1] + ') = ' + e.stz_nth_prime(parseInt(t[1], 10))); }
			return true;
		}
		if (cmd === 'isprime' && t.length === 2) {
			if (need('stz_is_prime', 'isprime')) { addLine('log-' + p, '  stz.wasm . is_prime(' + t[1] + ') = ' + (e.stz_is_prime(BigInt(t[1])) ? 'yes' : 'no')); }
			return true;
		}
		if (cmd === 'gcd' && t.length === 3) {
			if (need('stz_gcd', 'gcd')) { addLine('log-' + p, '  stz.wasm . gcd(' + t[1] + ', ' + t[2] + ') = ' + e.stz_gcd(BigInt(t[1]), BigInt(t[2]))); }
			return true;
		}
		if (cmd === 'fib' && t.length === 2) {
			if (need('stz_fib', 'fib')) { addLine('log-' + p, '  stz.wasm . fib(' + t[1] + ') = ' + e.stz_fib(parseInt(t[1], 10))); }
			return true;
		}
		if ((cmd === 'mean' || cmd === 'sum') && t.length > 1) {
			var fn = (cmd === 'mean') ? 'stz_mean' : 'stz_sum';
			if (need(fn, cmd)) {
				var arr = t.slice(1).map(Number);
				var m = em.mod.f64s(arr);
				var r = e[fn](m.ptr, m.len);
				em.mod.reset();
				addLine('log-' + p, '  stz.wasm . ' + cmd + '([' + arr.join(', ') + ']) = ' + r);
			}
			return true;
		}
	} catch (err) {
		addLine('log-' + p, '  stz.wasm error: ' + err);
		return true;
	}
	return false;
}

/* -- query console (real engine verbs first, then class-specific rehearsal) -- */

function query(el) {
	var p = el.getAttribute('data-part');
	var c = el.getAttribute('data-cls');
	var inp = document.getElementById('q-' + p);
	var q = (inp.value || '').trim();
	if (!q) return;
	addLine('log-' + p, '> ' + q);
	inp.value = '';
	if (tryEngine(p, q)) { return; }
	if (c === 'server') {
		addLine('log-' + p, '  ' + (API[q] || '200 OK'));
	} else if (c === 'mcu') {
		var m = q.toLowerCase();
		if (m.indexOf('read') === 0) { doPin(p, 'read'); }
		else if (m.indexOf('pump') === 0) { doPin(p, 'pump'); }
		else { addLine('log-' + p, '  unknown pin command'); }
	} else {
		addLine('log-' + p, '  app: ' + q + ' (noted)');
	}
}

function qk(e, el) { if (e.key === 'Enter' || e.keyCode === 13) { query(el); } }

/* -- the phone app streams its taps into the open window's log -- */
window.addEventListener('message', function (e) {
	if (e.data && e.data.t === 'applog' && openPart) { addLine('log-' + openPart, e.data.m); }
});

/* -- Escape closes the open device window -- */
document.addEventListener('keydown', function (e) {
	if (e.key === 'Escape' || e.keyCode === 27) { closeModals(); }
});

function deployProd() {
	alert('Production deploy ships these same parts via the governed crossing. Run: brain.Deploy(:Production)');
}

/* select the first part on load so the detail zone is never empty */
var first = document.getElementsByClassName('grow')[0];
if (first) sel(first);

/* Each part loads its OWN engine subset when its window first opens
   (loadEngineFor, from openPop) -- ship and run only what the part uses. */
