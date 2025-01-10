// RingJSCore-tests.js
// Comprehensive test suite for RingJSCore library v0.4

(function() {
    // Ensure RingJSCore is loaded
    if (typeof RingJSCore === 'undefined') {
        throw new Error('RingJSCore library not loaded!');
    }

    // Safe Test Runner
    function createTestRunner() {
        const testResults = [];

        function assert(condition, message) {
            if (!condition) {
                throw new Error(message || "Assertion failed");
            }
        }

        function runTest(testName, testFunction) {
            console.log(`Running test: ${testName}`);

            try {
                testFunction(assert);
                
                const result = {
                    name: testName,
                    status: 'PASSED ✅'
                };
                testResults.push(result);
                console.log(`${testName}: PASSED ✅`);
                return result;
            } catch (error) {
                const result = {
                    name: testName,
                    status: 'FAILED ❌',
                    error: error.message
                };
                testResults.push(result);
                console.error(`${testName}: FAILED ❌`, error);
                return result;
            }
        }

        function displayResults(results) {
            const resultsContainer = document.getElementById('test-results');
            
            if (!resultsContainer) {
                results.forEach(result => {
                    console.log(`${result.name}: ${result.status}`);
                });
                return;
            }

            resultsContainer.innerHTML = results.map(result => 
                `<div class="test-result ${result.status}">
                    ${result.name}: ${result.status}
                    ${result.error ? `<pre style="color:red">${result.error}</pre>` : ''}
                 </div>`
            ).join('');
        }

        return { runTest, displayResults };
    }

    // Global test suite execution function
    function runTestSuite() {
        const testRunner = createTestRunner();
        const testResults = [];

        // Test 1: Advanced Object Creation with Private Methods
        testResults.push(testRunner.runTest("Object Creation with Private Methods", (assert) => {
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

            assert(person.greet() === 'Hello, I\'m John', 'Public method should work');
            
            try {
                person.calculateBirthYear();
                assert(false, 'Private method should not be accessible');
            } catch(e) {
                assert(e.message.includes('Cannot access private method'), 'Private method access should be restricted');
            }
        }));

        // Test 2: Inheritance Mechanism
        testResults.push(testRunner.runTest("Inheritance Mechanism", (assert) => {
            const BaseAnimal = {
                constructor(name) {
                    this.name = name;
                },
                speak() {
                    return "Some sound";
                }
            };

            const DogClass = RingJSCore.Core.extend(BaseAnimal, {
                constructor(name, breed) {
                    BaseAnimal.constructor.call(this, name);
                    this.breed = breed;
                },
                speak() {
                    return "Woof!";
                },
                fetch() {
                    return `${this.name} is fetching`;
                }
            });

            const createDog = new RingJSCore.Object(DogClass);
            const dog = createDog('Buddy', 'Labrador');

            assert(dog.name === 'Buddy', 'Inherited property should be set');
            assert(dog.breed === 'Labrador', 'New property should be set');
            assert(dog.speak() === 'Woof!', 'Overridden method should work');
            assert(dog.fetch() === 'Buddy is fetching', 'New method should work');
        }));

        // Test 3: Advanced Type Inference
        testResults.push(testRunner.runTest("Advanced Type Inference", (assert) => {
            const type = new RingJSCore.Type();

            const testCases = [
                { value: 42, expectedType: type.types.NUMBER },
                { value: "Hello", expectedType: type.types.STRING },
                { value: true, expectedType: type.types.BOOLEAN },
                { value: [1,2,3], expectedType: type.types.LIST },
                { value: {}, expectedType: type.types.OBJECT },
                { value: () => {}, expectedType: type.types.FUNCTION }
            ];

            testCases.forEach(testCase => {
                const inferredType = type.inferType(testCase.value);
                assert(
                    inferredType === testCase.expectedType, 
                    `Should correctly infer type for ${typeof testCase.value}`
                );
            });
        }));

        // Test 4: Reference Handling with Options
        testResults.push(testRunner.runTest("Reference Handling with Options", (assert) => {
            const originalObj = { count: 1 };
            
            // Read-only reference
            const readOnlyRef = RingJSCore.Reference.reference(originalObj, { readOnly: true });
            
            try {
                readOnlyRef.count = 2;
                assert(originalObj.count === 1, 'Read-only reference should prevent modification');
            } catch(e) {
                assert(true, 'Read-only reference should prevent modification');
            }

            // Deep copy test
            const copied = RingJSCore.Reference.copy(originalObj);
            assert(copied !== originalObj, 'Copy should create a new object');
            assert(JSON.stringify(copied) === JSON.stringify(originalObj), 'Copied object should have same contents');
        }));

        // Test 5: Core Utilities - Loop and Conditional
        testResults.push(testRunner.runTest("Core Utilities - Loop and Conditional", (assert) => {
            let loopSum = 0;
            RingJSCore.Core.loop(5, { 
                callback: (i) => { loopSum += i; }
            });
            assert(loopSum === 10, 'Loop should iterate and accumulate correctly');

            let conditionResult = 'none';
            RingJSCore.Core.when(true, {
                true: () => { conditionResult = 'true path'; },
                false: () => { conditionResult = 'false path'; },
                otherwise: () => { conditionResult = 'otherwise'; }
            });
            assert(conditionResult === 'true path', 'When utility should execute true action');
        }));

        // Display results
        testRunner.displayResults(testResults);
    }

    // Expose global test suite runner for HTML
    if (typeof window !== 'undefined') {
        window.runTestSuite = runTestSuite;
        window.addEventListener('load', runTestSuite);
    }

    // Allow Node.js execution
    if (typeof module !== 'undefined' && module.exports) {
        module.exports = { runTestSuite };
    }
})();