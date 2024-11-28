// rjsTestMaker - Lightweight Declarative Testing Framework
// Version 0.5 - Optimized for RingJSLib

(function(global) {
    const RT = {
        _tests: {
            positive: []
        },
        _results: {
            positive: [],
            negative: []
        },

        addTestCase(config, type = 'positive') {
            if (!config.title || typeof config.test !== 'function') {
                throw new Error('Invalid test case: title and test function are required');
            }

            config.successMessage = config.successMessage || `Test passed: ${config.title}`;
            config.failureMessage = config.failureMessage || `Test failed: ${config.title}`;

            this._tests[type].push(config);
            return this;
        },

        runAllTests() {
            // Utilize RingJSLib's output methods if available
            if (typeof see === 'function') {
                see('🧪 Running All Tests...');
                hr();
            } else {
                console.log('🧪 Running All Tests...');
            }

            this._results.positive = this._tests.positive.map(testCase => this._runSingleTest(testCase));
            this._displayResults();
            return this._results;
        },

        _runSingleTest(testCase) {
            const startTime = Date.now();
            try {
                const testResult = testCase.test();
                const passed = testCase.expectedValue 
                    ? testCase.expectedValue(testResult) 
                    : !!testResult;

                // Use RingJSLib's output if available
                if (typeof seeNL === 'function') {
                    seeNL(
                        passed ? '✅ ' : '❌ ', 
                        testCase.title, 
                        passed ? 'PASSED' : 'FAILED'
                    );
                }

                return {
                    title: testCase.title,
                    passed: passed,
                    duration: Date.now() - startTime,
                    message: passed ? testCase.successMessage : testCase.failureMessage,
                    details: passed ? null : testResult
                };
            } catch (error) {
                // Use RingJSLib's output if available
                if (typeof seeNL === 'function') {
                    seeNL('❌ ', testCase.title, 'FAILED WITH ERROR');
                }

                return {
                    title: testCase.title,
                    passed: false,
                    duration: Date.now() - startTime,
                    message: testCase.failureMessage,
                    details: error
                };
            }
        },

        _displayResults() {
            const results = this._results.positive;
            const totalTests = results.length;
            const passedTests = results.filter(r => r.passed).length;
            const failedTests = totalTests - passedTests;

            // Use RingJSLib's output if available
            if (typeof see === 'function') {
                hr();
                see(`Total Tests: ${totalTests}`);
                see(`Passed Tests: ${passedTests}`);
                see(`Failed Tests: ${failedTests}`);
                hr();
            } else {
                console.log(`Total Tests: ${totalTests}`);
                console.log(`Passed Tests: ${passedTests}`);
                console.log(`Failed Tests: ${failedTests}`);
            }
        }
    };

    // Universal module export
    if (typeof module !== 'undefined' && module.exports) {
        module.exports = RT;
    } else {
        global.RT = RT;
    }
})(typeof globalThis !== 'undefined' ? globalThis : 
   typeof window !== 'undefined' ? window : this);
