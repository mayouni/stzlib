/* emulator.js -- authored routing + interaction for the Deploy(:Emulated) console.
   Consumed by stzEmulator.ring, which copies it verbatim into every generated
   bundle and links it from index.html. Edit HERE, with real JS tooling --
   never inside the Ring generator.

   The rehearsed responses below (API map, moisture readings, pin toggles) are
   placeholders for the programming phase; the build.zig wasm target replaces
   them with each part's real engine calls. */

var openPart = null;

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
	}
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

/* -- query console (interpretation depends on the part's class) -- */

function query(el) {
	var p = el.getAttribute('data-part');
	var c = el.getAttribute('data-cls');
	var inp = document.getElementById('q-' + p);
	var q = (inp.value || '').trim();
	if (!q) return;
	addLine('log-' + p, '> ' + q);
	inp.value = '';
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
