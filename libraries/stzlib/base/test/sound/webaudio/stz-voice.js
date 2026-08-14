// stz-voice.js -- VC5. The browser's half of the voice plane.
//
// The same two doors as the native tier: text -> speech, and speech -> text.
// The same capability model: PER LANGUAGE and PER DIRECTION, refusing rather
// than substituting, because speaking French to an operator who asked for
// English is worse than saying nothing.
//
// ── WHAT MOVES BETWEEN TIERS UNCHANGED, AND WHAT DOES NOT ──
//
// A DECLARATION moves. `useLanguage('fr-FR')` then `speak('...')` reads the
// same here as it does in Ring, and a refusal reads the same too.
//
// A VOICE DOES NOT MOVE, and on Windows it cannot. The OS keeps TWO voice
// registries and the two tiers read different ones:
//
//     HKLM\SOFTWARE\Microsoft\Speech\Voices\Tokens           <- SAPI, stz_voice.dll
//     HKLM\SOFTWARE\Microsoft\Speech_OneCore\Voices\Tokens   <- Chrome, Edge
//
// Measured on the development machine: SAPI sees Zira (en-US) and Hortense
// (fr-FR); the browser sees Hortense, Julie and Paul, ALL fr-FR. So `en-US`
// is speakable natively and NOT speakable in the browser ON THE SAME MACHINE.
// That is not a bug in either tier and no amount of trying harder fixes it.
// It is why the model is per-language and why capability is ASKED rather than
// assumed.
//
// ── THE ONE THING THE BROWSER CANNOT DO AT ALL ──
//
// `speechSynthesis` speaks to the SPEAKER. There is no captureStream, no audio
// sink, no route into WebAudio -- measured, not assumed, in voice_spike.html.
//
// The voice plan's section 1 rests on "a platform voice renders to a BUFFER,
// and a buffer is a stzSound". That is TRUE natively and FALSE here, so the
// primary verb INVERTS: natively `ToSoundOf` returns data and speaking is a
// convenience built on it; here speaking is primitive and there is no data.
//
// Everything the sound plane does to a spoken phrase -- LUFS, onsets, filters,
// spectrograms, saving a WAV, composing an earcon and a phrase into ONE buffer
// as VC4 does -- is unavailable to a browser voice. Not because a face is
// missing, but because the audio never exists as data. `toSoundOf` is present
// and REFUSES with that reason, so portable code can ask instead of crashing.

(function (global) {
	'use strict';

	// ---------------------------------------------------------------- helpers

	function tagsOf(voices) {
		var by = {};
		for (var i = 0; i < voices.length; i++) {
			var v = voices[i], t = v.lang || '';
			if (!t) continue;
			if (!by[t]) by[t] = { tag: t, voices: [], local: 0 };
			by[t].voices.push(v.name);
			if (v.localService) by[t].local++;
		}
		return by;
	}

	// 'fr' matches 'fr-FR'; 'fr-FR' does not match 'fr-CA'. Same rule the Ring
	// face uses, so a tag that works in one tier is refused in the other for a
	// reason a caller can read rather than for a reason of case or dashes.
	function matches(want, have) {
		want = String(want).toLowerCase().replace('_', '-');
		have = String(have).toLowerCase().replace('_', '-');
		if (want === have) return true;
		return have.indexOf(want + '-') === 0;
	}

	// ---------------------------------------------------------------- the voice

	function Voice() {
		this._lang = '';
		this._voice = null;
		this._rate = 1;      // the browser's scale is 0.1..10, 1 is normal
		this._refusals = 0;
		this._lastError = '';
		this._speaking = null;
	}

	// The voice list arrives ASYNCHRONOUSLY in Chrome, and a caller that reads
	// it once reports zero voices on a machine that has three. This waits for
	// onvoiceschanged and then settles, so `ready()` is the honest entry point
	// and every other method may assume the list is populated.
	Voice.prototype.ready = function () {
		var self = this;
		if (!('speechSynthesis' in global)) {
			this._lastError = 'this browser has no speechSynthesis';
			return Promise.resolve(false);
		}
		return new Promise(function (resolve) {
			var got = speechSynthesis.getVoices();
			if (got.length) return resolve(true);
			var done = false;
			var finish = function () {
				if (done) return; done = true;
				resolve(speechSynthesis.getVoices().length > 0);
			};
			speechSynthesis.onvoiceschanged = finish;
			setTimeout(finish, 2500);
		}).then(function (any) {
			if (!any) self._lastError = 'this browser reports no voices at all';
			return any;
		});
	};

	Voice.prototype.voices = function () {
		if (!('speechSynthesis' in global)) return [];
		return speechSynthesis.getVoices();
	};

	// THE CAPABILITY MODEL, in the shape the native tier reports it: which
	// languages, how many voices each, and how many of those stay on the
	// machine. `canBuffer` is the field that differs between tiers, and it is
	// reported rather than left for a caller to discover by crashing.
	Voice.prototype.capabilities = function () {
		var vs = this.voices();
		var by = tagsOf(vs);
		var tags = Object.keys(by).sort();
		return {
			tier: 'browser',
			voiceCount: vs.length,
			languages: tags,
			byLanguage: by,
			canSpeak: vs.length > 0,
			// the asymmetry, named
			canBuffer: false,
			canBufferReason: 'speechSynthesis speaks to the speaker; there is ' +
			                 'no captureStream and no route into WebAudio',
			canListen: !!(global.SpeechRecognition || global.webkitSpeechRecognition)
		};
	};

	// REFUSES rather than substitutes, and names what the machine actually has
	// -- the single most useful thing a refusal can do, and the same wording
	// the Ring face uses.
	Voice.prototype.useLanguage = function (tag) {
		var vs = this.voices();
		if (!vs.length) {
			this._refusals++;
			this._lastError = 'no voice on this machine to speak with';
			return false;
		}
		var pick = null;
		for (var i = 0; i < vs.length; i++) {
			if (matches(tag, vs[i].lang)) { pick = vs[i]; break; }
		}
		if (!pick) {
			this._refusals++;
			var have = Object.keys(tagsOf(vs)).sort().join(', ');
			this._lastError = "no voice speaks '" + tag + "' -- this browser has: " + have;
			return false;
		}
		this._lang = pick.lang;
		this._voice = pick;
		this._lastError = '';
		return true;
	};

	Voice.prototype.language = function () { return this._lang; };
	Voice.prototype.lastError = function () { return this._lastError; };
	Voice.prototype.refusals = function () { return this._refusals; };

	// 0.1..10 in the browser, where the native tier takes -10..10. CLAMPED and
	// COUNTED rather than silently accepted, because a setting that quietly
	// does nothing is worse than one that says no.
	Voice.prototype.setRate = function (r) {
		var c = Math.max(0.1, Math.min(10, r));
		if (c !== r) {
			this._refusals++;
			this._lastError = 'rate ' + r + ' clamped to ' + c + ' (the browser takes 0.1..10)';
		}
		this._rate = c;
		return c;
	};

	// THE ABSENT VERB, present so it can refuse.
	Voice.prototype.toSoundOf = function () {
		this._refusals++;
		this._lastError = 'toSoundOf is not available in the browser: ' +
		                  this.capabilities().canBufferReason +
		                  '. Use speak(), or synthesise on the native tier.';
		return null;
	};

	// Resolves when the phrase has been SPOKEN, not when it was queued -- a
	// promise that resolves on submission would make sequencing impossible,
	// and sequencing is the only way the browser can put an earcon before a
	// phrase (see stz-earcons.js).
	Voice.prototype.speak = function (text) {
		var self = this;
		if (!('speechSynthesis' in global)) {
			this._refusals++;
			this._lastError = 'this browser has no speechSynthesis';
			return Promise.resolve(false);
		}
		if (!text) return Promise.resolve(true);
		return new Promise(function (resolve) {
			var u = new SpeechSynthesisUtterance(text);
			if (self._voice) { u.voice = self._voice; u.lang = self._voice.lang; }
			u.rate = self._rate;
			var settled = false;
			var done = function (okFlag, why) {
				if (settled) return; settled = true;
				self._speaking = null;
				if (!okFlag) { self._lastError = why || 'speech ended without finishing'; }
				resolve(okFlag);
			};
			u.onend = function () { done(true); };
			u.onerror = function (e) {
				// 'interrupted' and 'canceled' are what cancel() produces and
				// are NOT faults -- they are the contract working.
				done(e.error === 'interrupted' || e.error === 'canceled', 'speech error: ' + e.error);
			};
			self._speaking = u;
			speechSynthesis.speak(u);
		});
	};

	Voice.prototype.cancel = function () {
		if ('speechSynthesis' in global) speechSynthesis.cancel();
		this._speaking = null;
	};

	Voice.prototype.isSpeaking = function () {
		return ('speechSynthesis' in global) && speechSynthesis.speaking;
	};

	// ---------------------------------------------------------------- listening

	function Listener() {
		this._words = [];
		this._text = '';
		this._confidence = 0;
		this._noMatch = false;
		this._refusals = 0;
		this._lastError = '';
		this._lang = 'en-US';
	}

	Listener.prototype.isAvailable = function () {
		return !!(global.SpeechRecognition || global.webkitSpeechRecognition);
	};

	// WHERE THE AUDIO GOES, reported rather than assumed.
	//
	// VC3 chose CLSID_SpInprocRecognizer natively and refused the shared
	// recognizer, because the shared one can be routed to Windows' online
	// speech service: a microphone is a consent boundary, and a microphone
	// that reaches a network is a different product.
	//
	// The browser's default has historically been the opposite -- audio goes
	// to the vendor. `processLocally` is the W3C draft that would change that,
	// and `availableOnDevice()` is how a page is supposed to check. Both are
	// PROBED here, so a caller is told what is true of the browser it is
	// running in rather than what was true when this was written.
	Listener.prototype.privacy = function () {
		var R = global.SpeechRecognition || global.webkitSpeechRecognition;
		var hasFlag = false, hasCheck = false;
		if (R) {
			try { hasFlag = 'processLocally' in new R(); } catch (e) {}
			hasCheck = typeof R.availableOnDevice === 'function';
		}
		return {
			hasProcessLocally: hasFlag,
			hasAvailableOnDevice: hasCheck,
			// the honest headline: the flag alone does not prove on-device
			onDeviceProvable: hasFlag && hasCheck,
			note: hasFlag && hasCheck
				? 'this browser can be asked for on-device recognition and can be ' +
				  'asked whether it is available'
				: 'this browser cannot PROVE on-device recognition; assume audio ' +
				  'may leave the machine and say so to the user'
		};
	};

	// CLOSED GRAMMAR ONLY, exactly as VC3 ships. That was not a preference: on
	// clean synthetic audio, free dictation scored 66.7% exact against a closed
	// grammar's 100%, and every miss was a WRITTEN FORM rather than a
	// mishearing ('annuler' -> 'annule'). A closed grammar cannot make that
	// mistake, because it maps the sound to the string the caller DECLARED.
	Listener.prototype.accept = function (phrases) {
		if (!phrases || !phrases.length) {
			this._refusals++;
			this._lastError = 'accept: an empty grammar hears nothing, forever';
			return false;
		}
		this._words = phrases.slice();
		this._lastError = '';
		return true;
	};

	Listener.prototype.useLanguage = function (tag) { this._lang = tag; return true; };

	Listener.prototype.hearMicrophoneFor = function (seconds) {
		var self = this;
		var R = global.SpeechRecognition || global.webkitSpeechRecognition;
		if (!R) {
			this._refusals++;
			this._lastError = 'this browser has no SpeechRecognition';
			return Promise.resolve(false);
		}
		if (!this._words.length) {
			this._refusals++;
			this._lastError = 'nothing has been accepted -- call accept() first';
			return Promise.resolve(false);
		}
		this._text = ''; this._confidence = 0; this._noMatch = false;

		var r = new R();
		r.lang = this._lang;
		r.continuous = false;
		r.interimResults = false;
		r.maxAlternatives = 1;
		if ('processLocally' in r) r.processLocally = true;   // ask; do not assume

		var GL = global.SpeechGrammarList || global.webkitSpeechGrammarList;
		if (GL) {
			var jsgf = '#JSGF V1.0; grammar stz; public <cmd> = ' +
			           this._words.join(' | ') + ' ;';
			var list = new GL();
			list.addFromString(jsgf, 1);
			r.grammars = list;
		}

		return new Promise(function (resolve) {
			var settled = false;
			var end = function (v) { if (!settled) { settled = true; resolve(v); } };
			r.onresult = function (e) {
				var best = e.results[0][0];
				var heard = (best.transcript || '').trim();
				// A phrase outside the grammar is a NO-MATCH, which is a RESULT
				// and not a refusal: "somebody said something that is not a
				// command" is information a control surface needs. The
				// dangerous alternative is a confident wrong command.
				var inGrammar = self._words.some(function (w) {
					return w.toLowerCase() === heard.toLowerCase();
				});
				if (inGrammar) {
					self._text = heard;
					self._confidence = best.confidence || 0;
				} else {
					self._noMatch = true;
					self._text = '';
					self._confidence = 0;
					self._lastError = 'heard something outside the grammar: ' + heard;
				}
				end(true);
			};
			r.onnomatch = function () { self._noMatch = true; end(true); };
			r.onerror = function (e) {
				self._lastError = 'recognition error: ' + e.error;
				end(false);
			};
			r.onend = function () { end(true); };
			try { r.start(); } catch (e) {
				self._lastError = 'could not start: ' + e.message;
				end(false);
			}
			setTimeout(function () { try { r.stop(); } catch (e) {} }, seconds * 1000);
		});
	};

	Listener.prototype.heardText = function () { return this._text; };
	// A SEPARATE CALL, so it cannot be skipped by accident. Even a closed
	// grammar is not certain: VC3 measured one command at 0.747 on clean audio.
	Listener.prototype.confidence = function () { return this._confidence; };
	Listener.prototype.wasNoMatch = function () { return this._noMatch; };
	Listener.prototype.lastError = function () { return this._lastError; };
	Listener.prototype.refusals = function () { return this._refusals; };

	global.StzVoice = {
		Voice: Voice,
		Listener: Listener,
		newVoice: function () { return new Voice(); },
		newListener: function () { return new Listener(); }
	};
})(typeof window !== 'undefined' ? window : this);
