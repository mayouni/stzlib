// rjsTesMaker Test Suite for RingJSLib
// Ensure RingJSLib is loaded before running tests

const RingJSTests = {
    run() {
        // Global setup before all tests
        RT.beforeEach(() => {
            // Reset global scope before each test if needed
            // This is just a demonstration
            if (typeof vv === 'function') {
                vv('testPrefix', 'TEST_');
            }
        });

        RT
            // Variable Assignment Group
            .group('Variable Assignment', 'Tests for basic variable creation and retrieval')
            .addTestCase({
                title: 'Simple String Variable Assignment',
                test: () => {
                    vv('cName', "kathy");
                    return v('cName');
                },
                expectedValue: (result) => result === "kathy",
                tags: ['core', 'variable']
            })
            .addTestCase({
                title: 'Parameterized List Variable Assignment',
                testCases: [
                    ["age", 25],
                    ["name", "john"],
                    ["hobbies", ["reading", "coding"]]
                ],
                test: (testCase) => {
                    vv('aInfo', testCase);
                    return v('aInfo');
                },
                expectedValue: (result, testCase) => {
                    return JSON.stringify(result) === JSON.stringify(testCase);
                },
                tags: ['core', 'variable', 'parameterized']
            })
            .addTestCase({
                title: 'Skipped Test',
                skip: true,
                test: () => false,
                expectedValue: () => true
            })
            .addTestCase({
                title: 'Conditionally Run Test',
                runIf: () => {
                    // Only run this test if certain conditions are met
                    return typeof vv === 'function';
                },
                test: () => {
                    vv('cGreeting', 'Hello Conditional Ring!');
                    return v('cGreeting');
                },
                expectedValue: (result) => result === 'Hello Conditional Ring!'
            })

            // String Operation Group
            .group('String Operations', 'Tests for string manipulation functions')
            .addTestCase({
                title: 'Uppercase Conversion',
                test: () => {
                    vv('cText', "Hello Ring World");
                    return upper(v('cText'));
                },
                expectedValue: (result) => result === "HELLO RING WORLD",
                tags: ['string', 'transformation']
            })
            .addTestCase({
                title: 'Lowercase Conversion',
                test: () => {
                    vv('cText', "Hello Ring World");
                    return lower(v('cText'));
                },
                expectedValue: (result) => result === "hello ring world",
                tags: ['string', 'transformation']
            })

            // Function Definition Group
            .group('Function Definition', 'Tests for function creation and calling')
            .beforeEach(() => {
                // Setup before each test in this group
                vv('testPrefix', 'FUNC_');
            })
            .addTestCase({
                title: 'Simple Function Definition and Calling',
                test: () => {
                    func('greet', ['pcPerson'], function() {
                        return 'Hello ' + v('pcPerson');
                    });
                    return f('greet', "Kathy");
                },
                expectedValue: (result) => result === 'Hello Kathy',
                timeout: 1000 // Optional timeout for this specific test
            })

            .runAllTests();
    }
};

// Run tests when the script is loaded
RingJSTests.run();