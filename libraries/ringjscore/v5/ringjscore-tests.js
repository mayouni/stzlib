// RingJSCore-tests.js
// Comprehensive Test Suite for RingJSCore Library
// Version: 0.6 - Nov, 2024

// Ensure dependencies are loaded
if (typeof RingJSCore === 'undefined' || typeof RJT === 'undefined') {
    throw new Error('RingJSCore or RJT library not loaded!');
}

(function() {
	
    // SCOPE MANAGEMENT TESTS
	
    RJT.addTestCase({
        title: "Scope Management: Basic Operations",
        test: () => {
            const scope = new RingJSCore.Scope();
            
            // Test setting and getting values in different scopes
            scope.set('globalVar', 'global value');
            scope.enterScope('local');
            scope.set('localVar', 'local value');

            return {
                globalScopePreserved: scope.get('globalVar') === 'global value',
                localScopeWorks: scope.get('localVar') === 'local value',
                globalVarAccessibleInLocalScope: scope.get('globalVar') === 'global value'
            };
        },
        successMessage: "Scope Management Basics Functioning Correctly 🌐"
    })
	
    .addTestCase({
        title: "Scope Management: Private Scope Protection",
        test: () => {
            const scope = new RingJSCore.Scope();
            
            // Test private scope isolation
            scope.setPrivate('secretKey', 'confidential info');

            return {
                privateValueSet: scope.getPrivate('secretKey') === 'confidential info',
                privateAccessThrowsError: (() => {
                    try {
                        scope.get('secretKey');
                        return false;
                    } catch(e) {
                        return e instanceof ReferenceError;
                    }
                })()
            };
        },
        successMessage: "Private Scope Protection Working Perfectly 🔐"
    })

    // TYPE CHECKING TESTS
	
    .addTestCase({
        title: "Type Inference: Comprehensive Type Detection",
        test: () => {
            const type = new RingJSCore.Type();

            // Test type inference for various data types
            const testCases = [
                { value: 42, expectedType: type.types.NUMBER, description: 'Number detection' },
                { value: "Hello", expectedType: type.types.STRING, description: 'String detection' },
                { value: true, expectedType: type.types.BOOLEAN, description: 'Boolean detection' },
                { value: [1,2,3], expectedType: type.types.LIST, description: 'List detection' },
                { value: {}, expectedType: type.types.OBJECT, description: 'Object detection' },
                { value: () => {}, expectedType: type.types.FUNCTION, description: 'Function detection' },
                
                // Edge cases
                { value: null, expectedType: null, description: 'Null type handling' },
                { value: undefined, expectedType: null, description: 'Undefined type handling' }
            ];

            return testCases.every(testCase => {
                const inferredType = type.inferType(testCase.value);
                return inferredType === testCase.expectedType;
            });
        },
        successMessage: "Advanced Type Inference Mastered! 🔬"
    })
	
    .addTestCase({
        title: "Type Validation: Soft Type Checking",
        test: () => {
            const type = new RingJSCore.Type();

            // Test soft type validation
            const testCases = [
                { value: 42, expectedType: type.types.NUMBER, shouldWarn: false },
                { value: "42", expectedType: type.types.NUMBER, shouldWarn: true },
                { value: [], expectedType: type.types.LIST, shouldWarn: false }
            ];

            // Mock console.warn to check warning behavior
            const originalWarn = console.warn;
            let warningTriggered = false;
            console.warn = () => { warningTriggered = true; };

            const results = testCases.map(testCase => {
                warningTriggered = false;
                type.validate(testCase.value, testCase.expectedType);
                return warningTriggered === testCase.shouldWarn;
            });

            // Restore original console.warn
            console.warn = originalWarn;

            return results.every(result => result);
        },
        successMessage: "Soft Type Validation Functioning Perfectly! 🛡️"
    })

    // REFERENCE HANDLING TESTS
	
    .addTestCase({
        title: "Reference Handling: Deep Copying",
        test: () => {
            const originalObj = { 
                nested: { 
                    value: 42, 
                    arr: [1, 2, 3] 
                }
            };

            const copiedObj = RingJSCore.Reference.copy(originalObj);

            return {
                differentObjectInstances: copiedObj !== originalObj,
                nestedObjectCopied: copiedObj.nested !== originalObj.nested,
                contentPreserved: JSON.stringify(copiedObj) === JSON.stringify(originalObj),
                arrayIndependence: copiedObj.nested.arr !== originalObj.nested.arr
            };
        },
        successMessage: "Deep Copying Mechanism Robust! 📋"
    })

	.addTestCase({
		title: "Reference Handling: Read-only References",
		test: () => {
			const originalObj = { count: 1 };
			
			// Create a read-only reference
			const readOnlyRef = RingJSCore.Reference.reference(originalObj, { readOnly: true });

			try {
				// Attempt to modify the read-only reference
				readOnlyRef.count = 2;
				
				// If modification succeeds, the test fails
				return {
					errorMessage: "Read-only reference was modified when it should not have been",
					originalValue: originalObj.count,
					attemptedNewValue: readOnlyRef.count
				};
				
			} catch (e) {
				// If an error is thrown, the test passes
				return true;
			}
		},
		expectedValue: (result) => result === true,
		successMessage: "Read-only Reference Protection Working! 🔒"
	})
	
    // OBJECT CREATION AND INHERITANCE TESTS
	
    .addTestCase({
        title: "Object Creation with Private Methods",
        test: () => {
            const PersonClass = {
                constructor(name, age) {
                    this.name = name;
                    this.age = age;
                },
                greet() { 
                    return `Hello, I'm ${this.name}`; 
                },
                PRIVATE: ['calculateBirthYear'],
                calculateBirthYear() { 
                    return new Date().getFullYear() - this.age; 
                }
            };

            const createPerson = new RingJSCore.Object(PersonClass);
            const person = createPerson('John', 30);

            return {
                publicMethodWorks: person.greet() === 'Hello, I\'m John',
                privateMethodBlocked: (() => {
                    try {
                        person.calculateBirthYear();
                        return false;
                    } catch(e) {
                        return e.message.includes('Cannot access private method');
                    }
                })()
            };
        },
        successMessage: "Private Method Protection Works Perfectly! 🔐"
    })
	
    .addTestCase({
        title: "Inheritance Mechanism with Complex Extension",
        test: () => {
            const BaseAnimal = {
                constructor(name) {
                    this.name = name;
                },
                speak() { return "Some generic sound"; }
            };

            const DogClass = RingJSCore.Core.extend(BaseAnimal, {
                constructor(name, breed) {
                    BaseAnimal.constructor.call(this, name);
                    this.breed = breed;
                },
                speak() { return "Woof!"; },
                fetch() { return `${this.name} is fetching`; }
            });

            const createDog = new RingJSCore.Object(DogClass);
            const dog = createDog('Buddy', 'Labrador');

            return {
                inheritedName: dog.name === 'Buddy',
                newProperty: dog.breed === 'Labrador',
                overriddenMethod: dog.speak() === 'Woof!',
                newMethod: dog.fetch() === 'Buddy is fetching'
            };
        },
        successMessage: "Complex Inheritance Mechanism Mastered! 🐶"
    })

    // CORE UTILITY TESTS
	
    .addTestCase({
        title: "Core Utility: Advanced Looping",
        test: () => {
            let sum = 0;
            let callCount = 0;

            RingJSCore.Core.loop(5, {
                start: 1,
                step: 2,
                callback: (i) => {
                    sum += i;
                    callCount++;
                }
            });

            return {
                correctSum: sum === 9, // 1 + 3 + 5
                correctIterations: callCount === 3
            };
        },
        successMessage: "Advanced Looping Utility Functioning! 🔁"
    })
	
    .addTestCase({
        title: "Core Utility: Conditional Execution",
        test: () => {
            let result = 'none';

            // Test true condition
            RingJSCore.Core.when(true, {
                true: () => { result = 'true path'; },
                false: () => { result = 'false path'; },
                otherwise: () => { result = 'otherwise'; }
            });

            const trueResult = result;

            // Reset and test false condition
            result = 'none';
            RingJSCore.Core.when(false, {
                true: () => { result = 'true path'; },
                false: () => { result = 'false path'; },
                otherwise: () => { result = 'otherwise'; }
            });

            const falseResult = result;

            return {
                truePathExecuted: trueResult === 'true path',
                falsePathExecuted: falseResult === 'false path'
            };
        },
        successMessage: "Conditional Execution Utility Perfected! 🎯"
    });

    // Optional: Automatically run tests when the script loads
    if (typeof window !== 'undefined') {
        window.addEventListener('load', () => RJT.runAllTests());
    }
})();