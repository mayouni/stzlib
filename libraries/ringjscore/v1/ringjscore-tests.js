// ringjs-tests.js
// This file tests our RingJSCore version 0.1

// Wrap our tests in a function to avoid global variables
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
                    status: 'PASSED ✅',
                    //color: 'green'
                });
                console.log(`${testName}: PASSED ✅`);
            } catch (error) {
                // If an error occurred, test failed
                testResults.push({
                    name: testName,
                    status: 'FAILED ❌',
                    //color: 'red',
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
                resultElement.style.color = result.color;

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

    // Run all our tests
    function runTestSuite() {
        // Make sure RingJS is loaded
        if (typeof RingJS === 'undefined') {
            console.error('RingJS library not loaded. Check your setup!');
            return;
        }

        // Create our test runner
        const testRunner = createTestRunner();
        const allResults = [];

        // Test 1: Type Checking
        allResults.push(testRunner.runTest("Type Checking", (assert) => {
            const type = new RingJS.Type();

            // Test valid number
            const validNumber = type.validate(42, type.types.NUMBER);
            assert(validNumber === 42, "Valid number should pass");

            // Test invalid number types
            const invalidInputs = [
                "not a number",  // string
                null,            // null
                undefined,       // undefined
                NaN,             // Not a Number
                Infinity         // Infinity
            ];

            // Try to validate each invalid input
            invalidInputs.forEach(input => {
                try {
                    type.validate(input, type.types.NUMBER);
                    assert(false, `Should reject ${input}`);
                } catch (error) {
                    assert(
                        error instanceof TypeError, 
                        `Incorrect error type for ${input}`
                    );
                }
            });
        }));

        // Test 2: Scope Management
        allResults.push(testRunner.runTest("Scope Management", (assert) => {
            const scope = new RingJS.Scope();

            // Set and get global variable
            scope.set('globalVar', 100, 'global');
            assert(
                scope.get('globalVar', 'global') === 100, 
                "Global variable should be retrievable"
            );

            // Set local variable
            scope.set('localVar', 'Hello');
            assert(
                scope.get('localVar') === 'Hello', 
                "Local variable should be retrievable"
            );
        }));

        // Test 3: Reference Handling
        allResults.push(testRunner.runTest("Reference Copying", (assert) => {
            // Primitive value
            const number = 42;
            const copiedNumber = RingJS.Reference.copy(number);
            assert(copiedNumber === number, "Primitive should copy directly");

            // Complex object
            const original = { name: "Test", values: [1, 2, 3] };
            const copied = RingJS.Reference.copy(original);
            
            // Check it's a new object
            assert(copied !== original, "Should create a new object");
            
            // Check contents are the same
            assert(
                JSON.stringify(copied) === JSON.stringify(original), 
                "Copied object should have same contents"
            );
        }));

        // Flatten results and display
        const flatResults = allResults.reduce((acc, curr) => acc.concat(curr), []);
        testRunner.displayResults(flatResults);
    }

    // Run tests when page loads
    if (typeof window !== 'undefined') {
        window.addEventListener('load', runTestSuite);
    } else {
        runTestSuite();
    }
})();