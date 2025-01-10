// RingJSCore-tests.js
// Comprehensive test suite for RingJSCore library v0.3

(function() {
    // Ensure RingJSCore is loaded
    if (typeof RingJSCore === 'undefined') {
        throw new Error('RingJSCore library not loaded!');
    }

    // Safe Test Runner to manage test execution
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

        // Test 1: Scope Management - Basic Functionality
        testResults.push(testRunner.runTest("Scope Management - Basic", (assert) => {
            const scope = new RingJSCore.Scope();

            // Test global scope
            scope.set('globalVar', 100, 'global');
            assert(scope.get('globalVar', 'global') === 100, 
                "Global variable should be set and retrievable");

            // Test local scope
            scope.set('localVar', 'Hello');
            assert(scope.get('localVar') === 'Hello', 
                "Local variable should be set and retrievable");
        }));

        // Test 2: Scope Management - Search Order
        testResults.push(testRunner.runTest("Scope Management - Search Order", (assert) => {
            const scope = new RingJSCore.Scope();

            // Set variables in different scopes
            scope.set('crossScopeVar', 'Global', 'global');
            
            // Enter object scope
            scope.enterScope('object');
            scope.set('crossScopeVar', 'Object');
            
            // Enter local scope
            scope.enterScope('local');
            scope.set('crossScopeVar', 'Local');

            // Check search order
            assert(scope.get('crossScopeVar') === 'Local', 
                "Should find variable in local scope first");
            
            // Exit local scope
            scope.exitScope();
            assert(scope.get('crossScopeVar') === 'Object', 
                "Should find variable in object scope next");
            
            // Exit object scope
            scope.exitScope();
            assert(scope.get('crossScopeVar') === 'Global', 
                "Should find variable in global scope last");
        }));

        // Test 3: Type Checking
        testResults.push(testRunner.runTest("Type Checking", (assert) => {
            const type = new RingJSCore.Type();

            // Soft type checking tests
            const validInputs = [
                { value: 42, type: type.types.NUMBER },
                { value: "Hello", type: type.types.STRING },
                { value: [1,2,3], type: type.types.LIST },
                { value: {}, type: type.types.OBJECT },
                { value: () => {}, type: type.types.FUNCTION }
            ];

            validInputs.forEach(input => {
                const result = type.validate(input.value, input.type);
                assert(result === input.value, 
                    `Should handle ${typeof input.value} type`);
            });
        }));

        // Test 4: Reference Handling
        testResults.push(testRunner.runTest("Reference Handling", (assert) => {
            // Deep copy test
            const original = { nested: { value: 42 } };
            const copied = RingJSCore.Reference.copy(original);
            
            assert(copied !== original, "Should create a new object");
            assert(
                JSON.stringify(copied) === JSON.stringify(original), 
                "Copied object should have same contents"
            );

            // Reference proxy test
            const obj = { count: 1 };
            const ref = RingJSCore.Reference.reference(obj);
            ref.count = 2;
            assert(obj.count === 2, "Reference should allow modifications");
        }));

        // Test 5: Core Utilities
        testResults.push(testRunner.runTest("Core Utilities", (assert) => {
            let loopCount = 0;
            RingJSCore.Core.loop(3, () => loopCount++);
            assert(loopCount === 3, "Loop should iterate correct number of times");

            let conditionResult = false;
            RingJSCore.Core.when(true, () => conditionResult = true);
            assert(conditionResult === true, "When utility should execute true action");
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