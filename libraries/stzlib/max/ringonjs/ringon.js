// ringon.js - RingOnJS: Ring-like Programming Library for JavaScript
// Version 2.5

const GlobalScope = {};

const r$j = {
    // Core state
    _scope: GlobalScope,
    _funcs: {},

    // Utility function to convert Ring 1-based index to JS 0-based index
    _toJSIndex(index) {
        return index - 1;
    },

    // Core Functions
    vv(nameOrExpr, value) {
        // Ensure we're working with the correct scope
        const self = this;
        
        // Handle Ring-style assignment with colon
        if (typeof nameOrExpr === 'string') {
            // Parse ":name = value" syntax
            const matches = nameOrExpr.match(/^:(\w+)\s*=\s*(.*)$/);
            if (matches) {
                const [, name, valueExpr] = matches;
                self._scope[name] = value !== undefined ? value : eval(valueExpr);
                return self._scope[name];
            }
            // Handle simple :name syntax
            if (nameOrExpr.startsWith(':')) {
                const name = nameOrExpr.substring(1);
                self._scope[name] = value;
                return value;
            }
            // Regular name assignment
            self._scope[nameOrExpr] = value;
            return value;
        }
        return null;
    },

    v(name) {
        // Ensure we're working with the correct scope
        const self = this;
        
        if (typeof name === 'string') {
            // Handle :name syntax
            if (name.startsWith(':')) {
                name = name.substring(1);
            }
            return self._scope[name] ?? null;
        }
        return null;
    },

    // Function wrapper to replace 'function'
    _(body) {
        return body;
    },

    func(name, params = [], body) {
        const self = this;
        if (typeof params === 'function') {
            body = params;
            params = [];
        }
        self._funcs[name] = { params, body };
        return self;
    },

    f(name, ...args) {
        const self = this;
        const func = self._funcs[name];
        if (!func) return null;
        
        const prevScope = { ...self._scope };
        func.params.forEach((param, i) => self.vv(param, args[i]));
        const result = func.body(self);
        self._scope = prevScope;
        return result;
    },

    // Output Functions
    See(...args) {
        console.log(...args);
        if (typeof document !== 'undefined') {
            const output = document.getElementById('output');
            if (output) {
                output.innerHTML += args.join(' ') + '<br>';
            }
        }
    },

    SeeNL(...args) {
        this.See(...args, '\n');
    },

    // Ring-like String Functions (1-based indexing)
    upper(str) {
        return String(str).toUpperCase();
    },

    lower(str) {
        return String(str).toLowerCase();
    },

    left(str, n) {
        return String(str).substring(0, n);
    },

    right(str, n) {
        return String(str).substring(String(str).length - n);
    },

    substring(str, start, end) {
        return String(str).substring(this._toJSIndex(start), end);
    },

    // Ring-like Core Functions
    len(item) {
        if (Array.isArray(item)) return item.length;
        if (typeof item === 'string') return item.length;
        if (typeof item === 'object') return Object.keys(item).length;
        return 0;
    },

    type(item) {
        if (item === null) return 'null';
        if (Array.isArray(item)) return 'list';
        return typeof item;
    },

    // List Operations
    add(list, item) {
        if (!Array.isArray(list)) return null;
        return [...list, item];
    },

    del(list, index) {
        if (!Array.isArray(list)) return null;
        return list.filter((_, i) => i !== this._toJSIndex(index));
    },

    first(list) {
        if (!Array.isArray(list)) return null;
        return list[0] ?? null;
    },

    last(list) {
        if (!Array.isArray(list)) return null;
        return list[list.length - 1] ?? null;
    },

    find(list, item) {
        if (!Array.isArray(list)) return null;
        return list.indexOf(item) + 1;
    },

    sort(list) {
        if (!Array.isArray(list)) return null;
        return [...list].sort();
    },

    reverse(list) {
        if (!Array.isArray(list)) return null;
        return [...list].reverse();
    },

    get(list, index) {
        if (!Array.isArray(list)) return null;
        return list[this._toJSIndex(index)] ?? null;
    },

    // Enhanced Loop System
    for(value) {
        const self = this;
        return {
            In: (list, fn) => {
                if (!Array.isArray(list)) return self;
                if (typeof fn === 'function') {
                    list.forEach(item => fn(item));
                } else {
                    list.forEach(item => {
                        self.vv(value, item);
                        fn.callback();
                    });
                }
                return self;
            },
            from: (start) => ({
                to: (end, fn) => {
                    for (let i = self._toJSIndex(start); i < end; i++) {
                        self.vv(value, i + 1);
                        fn();
                    }
                    return self;
                }
            })
        };
    },

    class(name, parent = null) {
        const self = this;
        return {
            From(parentName) {
                parent = self.v(parentName);
                return this;
            },
            Block(classDef) {
                const classScope = {};
                const methods = {};
                
                const classBuilder = {
                    attr(name, defaultValue) {
                        if (typeof name === 'string' && name.startsWith(':')) {
                            name = name.substring(1);
                        }
                        classScope[name] = defaultValue;
                    },
                    def(methodName, fn) {
                        methods[methodName] = fn;
                    }
                };
                
                // Call classDef with proper binding to classBuilder
                if (typeof classDef === 'function') {
                    classDef.call(classBuilder);
                }
                
                // Create the class constructor
                self._scope[name] = {
                    _classScope: classScope,
                    _methods: methods,
                    
                    new(...args) {
                        // Create a new instance with its own scope
                        const instance = {};
                        
                        // Copy class scope properties
                        Object.entries(this._classScope).forEach(([key, value]) => {
                            instance[key] = value;
                        });
                        
                        // Copy parent properties if exists
                        if (parent) {
                            Object.entries(parent._classScope).forEach(([key, value]) => {
                                if (!(key in instance)) {
                                    instance[key] = value;
                                }
                            });
                        }
                        
                        // Add methods with proper binding
                        Object.entries(this._methods).forEach(([key, fn]) => {
                            instance[key] = fn.bind(instance);
                        });
                        
                        // Add parent methods if exists
                        if (parent) {
                            Object.entries(parent._methods).forEach(([key, fn]) => {
                                if (!(key in instance)) {
                                    instance[key] = fn.bind(instance);
                                }
                            });
                        }
                        
                        // Call init if exists
                        if (instance.init) {
                            instance.init(...args);
                        }
                        
                        return instance;
                    }
                };
                
                return self._scope[name];
            }
        };
    }

};

// Create properly bound global shortcuts
const boundR$j = {
    ...r$j,
    _scope: r$j._scope,
    _funcs: r$j._funcs
};

const vv = boundR$j.vv.bind(boundR$j);
const v = boundR$j.v.bind(boundR$j);
const _ = boundR$j._.bind(boundR$j);
const func = boundR$j.func.bind(boundR$j);
const f = boundR$j.f.bind(boundR$j);
const See = boundR$j.See.bind(boundR$j);
const SeeNL = boundR$j.SeeNL.bind(boundR$j);
const len = boundR$j.len.bind(boundR$j);
const type = boundR$j.type.bind(boundR$j);

// Make r$j available globally with proper binding
if (typeof window !== 'undefined') {
    window.r$j = boundR$j;
}