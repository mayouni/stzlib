// rjsTestMaker - Lightweight Declarative Testing Framework
// Version 0.7 - Enhanced with Advanced Testing Features

(function(global) {
    const RT = {
        _testGroups: {},
        _currentGroup: null,
        _globalBeforeEach: null,
        _globalAfterEach: null,

        // Enhanced group method with setup and teardown support
        group(groupName, description = '') {
            this._currentGroup = groupName;
            this._testGroups[groupName] = {
                description,
                tests: {
                    positive: []
                },
                results: {
                    positive: []
                },
                beforeEach: null,
                afterEach: null
            };
            return this;
        },

        // Global setup and teardown methods
        beforeEach(callback) {
            if (this._currentGroup) {
                this._testGroups[this._currentGroup].beforeEach = callback;
            } else {
                this._globalBeforeEach = callback;
            }
            return this;
        },

        afterEach(callback) {
            if (this._currentGroup) {
                this._testGroups[this._currentGroup].afterEach = callback;
            } else {
                this._globalAfterEach = callback;
            }
            return this;
        },

        addTestCase(config, type = 'positive') {
            // Ensure a group is selected
            if (!this._currentGroup) {
                throw new Error('Must define a test group before adding test cases');
            }

            if (!config.title || typeof config.test !== 'function') {
                throw new Error('Invalid test case: title and test function are required');
            }

            // Default configurations
            config.successMessage = config.successMessage || `Test passed: ${config.title}`;
            config.failureMessage = config.failureMessage || `Test failed: ${config.title}`;
            config.timeout = config.timeout || 2000; // Default 2 seconds timeout
            config.skip = config.skip || false;
            config.tags = config.tags || [];
            config.runIf = config.runIf || null;

            // Handle parameterized tests
            if (config.testCases) {
                return this._addParameterizedTestCase(config, type);
            }

            this._testGroups[this._currentGroup].tests[type].push(config);
            return this;
        },

        _addParameterizedTestCase(config, type) {
            const parameterizedTests = config.testCases.map(testCase => ({
                ...config,
                title: `${config.title} (${JSON.stringify(testCase)})`,
                currentTestCase: testCase,
                test: () => config.test(testCase),
                expectedValue: (result) => config.expectedValue 
                    ? config.expectedValue(result, testCase) 
                    : !!result
            }));

            this._testGroups[this._currentGroup].tests[type].push(...parameterizedTests);
            return this;
        },

        runAllTests() {
            // Utilize RingJSLib's output methods if available
            if (typeof see === 'function') {
                see('🧪 Running All Tests...');
            } else {
                console.log('🧪 Running All Tests...');
            }

            // Run tests for each group
            Object.keys(this._testGroups).forEach(groupName => {
                const group = this._testGroups[groupName];

                // Run tests in the group
                group.results.positive = group.tests.positive
                    .filter(testCase => this._shouldRunTest(testCase))
                    .map(testCase => this._runSingleTest(testCase, group));
            });

            this._displayOverallResults();
            return this._testGroups;
        },

        _shouldRunTest(testCase) {
            // Check if test should be skipped
            if (testCase.skip) return false;

            // Check conditional execution
            if (testCase.runIf && typeof testCase.runIf === 'function') {
                try {
                    return testCase.runIf();
                } catch {
                    return false;
                }
            }

            return true;
        },

        _runSingleTest(testCase, group) {
            const startTime = Date.now();

            // Execute global and group-level beforeEach
            if (this._globalBeforeEach) this._globalBeforeEach();
            if (group.beforeEach) group.beforeEach();

            try {
                // Implement timeout mechanism
                return new Promise((resolve, reject) => {
                    const timeoutId = setTimeout(() => {
                        reject(new Error(`Test timed out after ${testCase.timeout}ms`));
                    }, testCase.timeout);

                    // Wrap test execution
                    Promise.resolve(testCase.test())
                        .then(testResult => {
                            clearTimeout(timeoutId);
                            
                            // Determine test pass/fail
                            const passed = testCase.expectedValue 
                                ? testCase.expectedValue(testResult) 
                                : !!testResult;

                            // Execute global and group-level afterEach
                            if (group.afterEach) group.afterEach();
                            if (this._globalAfterEach) this._globalAfterEach();

                            // Use RingJSLib's output if available
                            if (typeof seeNL === 'function') {
                                seeNL(
                                    passed ? '✅ ' : '❌ ', 
                                    testCase.title, 
                                    passed ? 'PASSED' : 'FAILED'
                                );
                            }

                            resolve({
                                title: testCase.title,
                                passed: passed,
                                duration: Date.now() - startTime,
                                message: passed ? testCase.successMessage : testCase.failureMessage,
                                details: passed ? null : testResult,
                                tags: testCase.tags || []
                            });
                        })
                        .catch(error => {
                            clearTimeout(timeoutId);

                            // Execute global and group-level afterEach
                            if (group.afterEach) group.afterEach();
                            if (this._globalAfterEach) this._globalAfterEach();

                            // Use RingJSLib's output if available
                            if (typeof seeNL === 'function') {
                                seeNL('❌ ', testCase.title, 'FAILED WITH ERROR');
                            }

                            resolve({
                                title: testCase.title,
                                passed: false,
                                duration: Date.now() - startTime,
                                message: testCase.failureMessage,
                                details: error,
                                tags: testCase.tags || []
                            });
                        });
                });
            } catch (error) {
                // Fallback error handling
                return {
                    title: testCase.title,
                    passed: false,
                    duration: Date.now() - startTime,
                    message: testCase.failureMessage,
                    details: error,
                    tags: testCase.tags || []
                };
            }
        },

        _displayOverallResults() {
            // Comprehensive results reporting
            if (typeof see === 'function') {
                hr();
            }

            let totalTests = 0;
            let passedTests = 0;
            let failedTests = 0;
            let skippedTests = 0;

            // Iterate through groups and compute results
            Object.keys(this._testGroups).forEach(groupName => {
                const group = this._testGroups[groupName];
                const groupTests = group.results.positive;
                
                const groupTotalTests = groupTests.length;
                const groupPassedTests = groupTests.filter(r => r.passed).length;
                const groupFailedTests = groupTests.filter(r => !r.passed).length;
                const groupSkippedTests = group.tests.positive.length - groupTotalTests;

                totalTests += groupTotalTests;
                passedTests += groupPassedTests;
                failedTests += groupFailedTests;
                skippedTests += groupSkippedTests;

            });

            // Overall summary
            if (typeof see === 'function') {
                see('🏁 Overall Summary');
                see(`Total Tests: ${totalTests}`);
                see(`Passed Tests: ${passedTests}`);
                see(`Failed Tests: ${failedTests}`);
                see(`Skipped Tests: ${skippedTests}`);
                hr();
            }

            return {
                totalTests,
                passedTests,
                failedTests,
                skippedTests
            };
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