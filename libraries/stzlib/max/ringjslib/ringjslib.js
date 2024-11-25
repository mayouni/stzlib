// === ringjslib.js ===
// ringjslib.js - A Ring-like JavaScript Programming library
// Version 0.3 - @By: Mansour Ayouni and ClaudAI

const RingJSLib = (function() {
    'use strict';
    
    // Private scope
    const _globalScope = new Map();
    const _functions = new Map();
    
    // Utility functions
    function _parseRingAssignment(expr) {
        if (typeof expr !== 'string') return null;
        const match = expr.match(/^:(\w+)\s*=\s*(.+)$/);
        if (!match) return null;
        return {
            name: match[1],
            value: match[2].trim()
        };
    }
    
    function _evaluateValue(value) {
        if (!value) return null;
        
        if (value.startsWith('"') && value.endsWith('"')) {
            return value.slice(1, -1);
        }
        
        if (!isNaN(value)) {
            return Number(value);
        }
        
        if (value.startsWith('[') && value.endsWith(']')) {
            try {
                return JSON.parse(value);
            } catch {
                return null;
            }
        }
        
        return value;
    }
    
    // The library implementation
    const lib = {
        vv(nameOrExpr, directValue) {
            if (typeof nameOrExpr === 'string') {
                const parsed = _parseRingAssignment(nameOrExpr);
                if (parsed) {
                    const value = _evaluateValue(parsed.value);
                    _globalScope.set(parsed.name, value);
                    return value;
                }
                
                if (nameOrExpr.startsWith(':')) {
                    const name = nameOrExpr.slice(1);
                    _globalScope.set(name, directValue);
                    return directValue;
                }
                
                _globalScope.set(nameOrExpr, directValue);
                return directValue;
            }
            return null;
        },
        
        v(name) {
            if (typeof name !== 'string') return null;
            const varName = name.startsWith(':') ? name.slice(1) : name;
            return _globalScope.has(varName) ? _globalScope.get(varName) : null;
        },
        
        func(name, params = [], body) {
            if (typeof name !== 'string') return this;
            
            if (typeof params === 'function') {
                body = params;
                params = [];
            }
            
            _functions.set(name, {
                params: Array.isArray(params) ? params : [],
                body: typeof body === 'function' ? body : () => null
            });
            
            return this;
        },
        
        f(name, ...args) {
            if (!_functions.has(name)) return null;
            
            const func = _functions.get(name);
            const previousScope = new Map(_globalScope);
            
            func.params.forEach((param, index) => {
                if (index < args.length) {
                    this.vv(param, args[index]);
                }
            });
            
            const result = func.body(this);
            
            _globalScope.clear();
            previousScope.forEach((value, key) => {
                _globalScope.set(key, value);
            });
            
            return result;
        },
        
        see(...args) {
            console.log(...args);
            if (typeof document !== 'undefined') {
                const output = document.getElementById('output');
                if (output) {
                    output.innerHTML += args.join(' ') + '<br>';
                }
            }
            return this;
        },

        seenl(...args) {
            this.see(...args, '\n');
            return this;
        },
        
        nl() {
            console.log('');
            if (typeof document !== 'undefined') {
                const output = document.getElementById('output');
                if (output) {
                    output.innerHTML += '<br>';
                }
            }
            return this;
        },
        
        hr() {
            console.log('-'.repeat(80));
            if (typeof document !== 'undefined') {
                const output = document.getElementById('output');
                if (output) {
                    const containerWidth = output.clientWidth;
                    const repeatCount = Math.floor(containerWidth / 10); // Approximate character width
                    output.innerHTML += '<div style="border-top: 1px solid #ccc; width: 100%; margin: 10px 0;"></div>';
                }
            }
            return this;
        },
        
        upper(str) {
            return String(str).toUpperCase();
        },

        lower(str) {
            return String(str).toLowerCase();
        },

        left(str, n) {
            if (typeof str !== 'string' || typeof n !== 'number') return '';
            return str.slice(0, n);
        },
        
        right(str, n) {
            if (typeof str !== 'string' || typeof n !== 'number') return '';
            return str.slice(-n);
        },
        
        substr(str, start, len) {
            if (typeof str !== 'string' || typeof start !== 'number' || typeof len !== 'number') return '';
            return str.substr(start - 1, len);
        },
        
        add(list, item) {
            if (!Array.isArray(list)) return null;
            return [...list, item];
        },
        
        del(list, index) {
            if (!Array.isArray(list) || typeof index !== 'number' || index < 1 || index > list.length) return list;
            return [...list.slice(0, index - 1), ...list.slice(index)];
        },
        
        nth(list, index) {
            if (!Array.isArray(list) || typeof index !== 'number' || index < 1 || index > list.length) return null;
            return list[index - 1];
        },
        
        len(item) {
            if (Array.isArray(item)) return item.length;
            if (typeof item === 'string') return item.length;
            if (item && typeof item === 'object') return Object.keys(item).length;
            return 0;
        },
        
        type(item) {
            if (item === null) return 'NULL';
            if (Array.isArray(item)) return 'LIST';
            return upper(typeof item);
        }
    };
    
    // Safe global function creation
    const globalFunctions = {
        vv: lib.vv.bind(lib),
        v: lib.v.bind(lib),
        see: lib.see.bind(lib),
        seenl: lib.seenl.bind(lib),
        nl: lib.nl.bind(lib),
        hr: lib.hr.bind(lib),
	upper: lib.upper.bind(lib),
	lower: lib.lower.bind(lib),
        left: lib.left.bind(lib),
        right: lib.right.bind(lib),
        substr: lib.substr.bind(lib),
        add: lib.add.bind(lib),
        del: lib.del.bind(lib),
        nth: lib.nth.bind(lib),
        len: lib.len.bind(lib),
        type: lib.type.bind(lib),
        func: lib.func.bind(lib),
        f: lib.f.bind(lib)
    };

    // Export global functions safely
    if (typeof window !== 'undefined') {
        const existingGlobals = new Map();
        
        Object.keys(globalFunctions).forEach(name => {
            if (name in window) {
                existingGlobals.set(name, window[name]);
            }
            window[name] = globalFunctions[name];
        });
        
        window.RingJSLib = {
            ...lib,
            restoreGlobals: function() {
                Object.keys(globalFunctions).forEach(name => {
                    if (existingGlobals.has(name)) {
                        window[name] = existingGlobals.get(name);
                    } else {
                        delete window[name];
                    }
                });
            }
        };
    }
    
    if (typeof module !== 'undefined' && module.exports) {
        module.exports = {
            ...lib,
            ...globalFunctions
        };
    }
    
    return lib;
})();