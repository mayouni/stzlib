// rjsTestMaker.js
// Lightweight and Declarative Testing Framework for RingJS Libraries
// Version: 0.5 - Nov, 2024
// @By: Mansour Ayouni and ClaudeAI

(function(global) {
    const RJTestMaker = {
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
            console.log('🧪 Running All Tests...');
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

                return {
                    title: testCase.title,
                    passed: passed,
                    duration: Date.now() - startTime,
                    message: passed ? testCase.successMessage : testCase.failureMessage,
                    details: passed ? null : testResult
                };
            } catch (error) {
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
            if (typeof document !== 'undefined') {
                const resultsContainer = document.getElementById('test-results');
                if (resultsContainer) {
                    resultsContainer.innerHTML = `
                        ${this._createResultSection(this._results.positive, 'positive')}
                        <br />
                    `;
                }
            }
        },

        _createResultSection(results, type) {
            const totalTests = results.length;
            const passedTests = results.filter(r => r.passed).length;
            const failedTests = totalTests - passedTests;

            return `
                <div class="test-summary ${type}-summary">
                    <p>Total: ${totalTests}, Passed: ${passedTests}, Failed: ${failedTests}</p>
                </div>
                <div class="test-details ${type}-details">
                    ${results.map(result => `
                        <div class="test-result ${result.passed ? 'pass' : 'fail'} ${type}-result">
                            ${result.title}: ${result.passed ? 'PASS ✅' : 'FAIL ❌'}
                            ${result.details ? `<div class="test-details">${JSON.stringify(result.details)}</div>` : ''}
                        </div>
                    `).join('')}
                </div>
            `;
        }
    };

    if (typeof module !== 'undefined' && module.exports) {
        module.exports = RJTestMaker;
    } else {
        global.RJT = RJTestMaker;
    }
})(typeof globalThis !== 'undefined' ? globalThis : typeof window !== 'undefined' ? window : this);