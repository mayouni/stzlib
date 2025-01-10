// RingJSCore-tests.js
// Comprehensive test suite for RingJSCore library v0.2

(function() {
    // Test Helper: Provides a friendly way to check if things work
    function createTestRunner() {
        // Store our test results
        const testResults = [];

        // Check if something is true, with a helpful message
        function assert(condition, message) {
            if (!condition) {
                // If something goes wrong, throw an error with details
                const error = new Error(message || "Something didn't work as expected");
                console.error(error);
                throw error;
            }
        }

        // Run a single test and track the results
        function runTest(testName, testFunction) {
            console.log(`Running test: ${testName}`);

            try {
                // Try to run the test
                testFunction(assert);
                
                // If no errors, test passed!
                testResults.push({
                    name: testName,
                    status: 'PASSED ✅'
                });
                console.log(`${testName}: PASSED ✅`);
            } catch (error) {
                // If an error occurred, test failed
                testResults.push({
                    name: testName,
                    status: 'FAILED ❌',
                    error: error.message
                });
                console.error(`${testName}: FAILED ❌`, error);
            }

            return testResults;
        }

        // Show test results on the webpage
        function displayResults(results) {
            const resultsContainer = document.getElementById('test-results');
            
            if (!resultsContainer) {
                // If no display area, log to console
                console.log('Test Results:');
                results.forEach(result => {
                    console.log(`${result.name}: ${result.status}`);
                });
                return;
            }

            // Clear previous results
            resultsContainer.innerHTML = '';

            // Show each test result
            results.forEach(result => {
                const resultElement = document.createElement('div');
                resultElement.textContent = `${result.name}: ${result.status}`;
                
                // Add error details if test failed
                if (result.error) {
                    const errorDetails = document.createElement('pre');
                    errorDetails.textContent = result.error;
                    errorDetails.style.color = 'red';
                    resultElement.appendChild(errorDetails);
                }

                resultsContainer.appendChild(resultElement);
            });
        }

        // Return our test utilities
        return { runTest, displayResults };
    }

    // Comprehensive Test Suite
    function runTestSuite() {
        // Make sure RingJSCore is loaded
        if (typeof RingJSCore === 'undefined') {
            console.error('RingJSCore library not loaded!');
            return;
        }

        // Create our test runner
        const testRunner = createTestRunner();
        const allResults = [];

        // Test 1: Scope Management - Basic Functionality
        allResults.push(testRunner.runTest("Scope Management - Basic", (assert) => {
            const scope = new RingJSCore.Scope();

            // Global scope
            scope.set('globalVar', 100, 'global');
            assert(scope.get('globalVar', 'global') === 100, 
                "Global variable should be set and retrievable");

            // Local scope
            scope.set('localVar', 'Hello');
            assert(scope.get('localVar') === 'Hello', 
                "Local variable should be set and retrievable");
        }));

        // Test 2: Scope Management - Search Order
        allResults.push(testRunner.runTest("Scope Management - Search Order", (assert) => {
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
        allResults.push(testRunner.runTest("Type Checking", (assert) => {
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
        allResults.push(testRunner.runTest("Reference Handling", (assert) => {
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
        allResults.push(testRunner.runTest("Core Utilities", (assert) => {
            let loopCount = 0;
            RingJSCore.Core.loop(3, () => loopCount++);
            assert(loopCount === 3, "Loop should iterate correct number of times");

            let conditionResult = false;
            RingJSCore.Core.when(true, () => conditionResult = true);
            assert(conditionResult === true, "When utility should execute true action");
        }));

        // Flatten results and display
        const flatResults = allResults.reduce((acc, curr) => acc.concat(curr), []);
        testRunner.displayResults(flatResults);
    }

    // Run tests when page loads or in Node.js environment
    if (typeof window !== 'undefined') {
        window.addEventListener('load', runTestSuite);
    } else {
        runTestSuite();
    }
})();