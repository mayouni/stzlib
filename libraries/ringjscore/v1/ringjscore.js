// ringjscore.js - A Ring-friendly JavaScript Programming Library
// Version: 0.1 - Nov, 2024
// @By: Mansour Ayouni and ClaudeAI

// Wrap everything in a function to create a safe namespace
(function(global) {
    // Our main RingJS object to hold all utilities
    const RingJS = {};

    // Type Checking Utility
    // Helps ensure variables are the right kind of data
    class TypeChecker {
        // Define types we can check
        constructor() {
            this.types = {
                // Use symbols to create unique type identifiers
                NUMBER: Symbol('Whole or decimal numbers'),
                STRING: Symbol('Text values'),
                LIST: Symbol('Arrays of items'),
                OBJECT: Symbol('Complex data collections'),
                FUNCTION: Symbol('Executable code blocks')
            };
        }

        // Check if a value matches a specific type
        // This is like a friendly bouncer checking IDs
        validate(value, expectedType) {
            // Map of type-checking rules
            const typeChecks = {
                // Number must be a number, not NaN, not Infinity
                'number': (v) => 
                    typeof v === 'number' && 
                    !isNaN(v) && 
                    isFinite(v),
                
                // String must be text
                'string': (v) => typeof v === 'string',
                
                // List must be an array
                'list': (v) => Array.isArray(v),
                
                // Object must be a non-array object
                'object': (v) => 
                    v !== null && 
                    typeof v === 'object' && 
                    !Array.isArray(v),
                
                // Function must be callable
                'function': (v) => typeof v === 'function'
            };

            // Find the name of the type we're checking
            const typeName = Object.keys(this.types)
                .find(key => this.types[key] === expectedType)
                .toLowerCase();

            // Do the type check
            if (!typeChecks[typeName](value)) {
                throw new TypeError(
                    `Oops! Expected a ${typeName.toUpperCase()}, ` +
                    `but got a ${typeof value}`
                );
            }

            // If we made it here, the type is good!
            return value;
        }
    }

    // Scope Management
    // Helps manage where variables live and how they're accessed
    class ScopeManager {
        constructor() {
            // Three different scopes, just like in Ring!
            this.scopes = {
                global: new Map(),   // Available everywhere
                local: new Map(),    // Available in current function
                object: new Map()    // Available in current object
            };
        }

        // Save a value in a specific scope
        set(key, value, scopeName = 'local') {
            // Check if the scope exists
            if (!this.scopes[scopeName]) {
                throw new Error(`Unknown scope: ${scopeName}`);
            }

            // Store the value
            this.scopes[scopeName].set(key, value);
            return this;
        }

        // Retrieve a value from a scope
        get(key, scopeName = 'local') {
            // Look in different scopes if not found
            const searchOrder = scopeName === 'local' 
                ? ['local', 'object', 'global'] 
                : [scopeName];

            // Try to find the value
            for (let scope of searchOrder) {
                const value = this.scopes[scope].get(key);
                if (value !== undefined) return value;
            }

            // If we can't find it, throw an error
            throw new Error(`Variable '${key}' not found`);
        }
    }

    // Reference Handling
    // Helps copy or reference values safely
    class ReferenceHandler {
        // Create a copy or reference of a value
        static copy(value) {
            // For simple values, return as-is
            if (value === null || value === undefined) return value;
            
            // For complex objects, create a deep copy
            if (typeof value === 'object' || Array.isArray(value)) {
                return structuredClone(value);
            }
            
            // For primitives, return the value
            return value;
        }
    }

    // Main RingJS Utility Class
    class RingCore {
        constructor() {
            // Set up our utilities
            this.type = new TypeChecker();
            this.scope = new ScopeManager();
            this.reference = ReferenceHandler;
        }

        // Simple loop utility
        static loop(count, callback) {
            for (let i = 0; i < count; i++) {
                callback(i);
            }
        }

        // Simple conditional execution
        static when(condition, trueAction, falseAction = null) {
            if (condition) {
                trueAction();
            } else if (falseAction) {
                falseAction();
            }
        }
    }

    // Expose our utilities
    RingJS.Type = TypeChecker;
    RingJS.Scope = ScopeManager;
    RingJS.Reference = ReferenceHandler;
    RingJS.Core = RingCore;

    // Make RingJS available globally
    if (typeof module !== 'undefined' && module.exports) {
        // For Node.js
        module.exports = RingJS;
    } else {
        // For browsers
        global.RingJS = RingJS;
    }
})(typeof globalThis !== 'undefined' ? globalThis : typeof window !== 'undefined' ? window : this);