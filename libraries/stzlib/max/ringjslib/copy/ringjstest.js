// rjsTesMaker Test Suite for RingJSLib
// Ensure RingJSLib is loaded before running tests

const RingJSTests = {
    run() {
        // Variable Assignment Tests
        RT
            .addTestCase({
                title: 'Simple String Variable Assignment',
                test: () => {
                    vv('cName', "kathy");
                    return v('cName');
                },
                expectedValue: (result) => result === "kathy"
            })
            .addTestCase({
                title: 'List Variable Assignment',
                test: () => {
                    vv('aInfo', ["age", 25]);
                    return v('aInfo');
                },
                expectedValue: (result) => JSON.stringify(result) === JSON.stringify(["age", 25])
            })
            .addTestCase({
                title: 'Greeting Variable Assignment',
                test: () => {
                    vv('cGreeting', 'Hello Ring!');
                    return v('cGreeting');
                },
                expectedValue: (result) => result === 'Hello Ring!'
            })

            // String Operation Tests
            .addTestCase({
                title: 'Uppercase Conversion',
                test: () => {
                    vv('cText', "Hello Ring World");
                    return upper(v('cText'));
                },
                expectedValue: (result) => result === "HELLO RING WORLD"
            })
            .addTestCase({
                title: 'Lowercase Conversion',
                test: () => {
                    vv('cText', "Hello Ring World");
                    return lower(v('cText'));
                },
                expectedValue: (result) => result === "hello ring world"
            })
            .addTestCase({
                title: 'Left Substring',
                test: () => {
                    vv('cText', "Hello Ring World");
                    return left(v('cText'), 5);
                },
                expectedValue: (result) => result === "Hello"
            })
            .addTestCase({
                title: 'Right Substring',
                test: () => {
                    vv('cText', "Hello Ring World");
                    return right(v('cText'), 5);
                },
                expectedValue: (result) => result === "World"
            })
            .addTestCase({
                title: 'Substring Extraction',
                test: () => {
                    vv('cText', "Hello Ring World");
                    return substr(v('cText'), 1, 5);
                },
                expectedValue: (result) => result === "Hello"
            })

            // List Operation Tests
            .addTestCase({
                title: 'List Addition',
                test: () => {
                    vv('aMyList', [1, 2, 3, 4, 5]);
                    return add(v('aMyList'), 6);
                },
                expectedValue: (result) => JSON.stringify(result) === JSON.stringify([1, 2, 3, 4, 5, 6])
            })
            .addTestCase({
                title: 'List Item Deletion',
                test: () => {
                    vv('aMyList', [1, 2, 3, 4, 5]);
                    return del(v('aMyList'), 1);
                },
                expectedValue: (result) => JSON.stringify(result) === JSON.stringify([2, 3, 4, 5])
            })
            .addTestCase({
                title: 'Get List Item by Index',
                test: () => {
                    vv('aMyList', [1, 2, 3, 4, 5]);
                    return nth(v('aMyList'), 2);
                },
                expectedValue: (result) => result === 2
            })

            // Function Definition and Calling Tests
            .addTestCase({
                title: 'Function Definition and Calling',
                test: () => {
                    func('greet', ['pcPerson'], function() {
                        return 'Hello ' + v('pcPerson');
                    });
                    return f('greet', "Kathy");
                },
                expectedValue: (result) => result === 'Hello Kathy'
            })

            // Type Checking Tests
            .addTestCase({
                title: 'Type Checking for List',
                test: () => {
                    vv('aMyList', [1, 2, 3, 4, 5]);
                    return type(v('aMyList'));
                },
                expectedValue: (result) => result === 'LIST'
            })
            .addTestCase({
                title: 'Type Checking for String',
                test: () => {
                    vv('cName', "kathy");
                    return type(v('cName'));
                },
                expectedValue: (result) => result === 'STRING'
            })
            .addTestCase({
                title: 'Type Checking for Null',
                test: () => type(null),
                expectedValue: (result) => result === 'NULL'
            })

            // Additional Advanced Tests
            .addTestCase({
                title: 'List Length Calculation',
                test: () => {
                    vv('aMyList', [1, 2, 3, 4, 5]);
                    return len(v('aMyList'));
                },
                expectedValue: (result) => result === 5
            })
            .addTestCase({
                title: 'String Length Calculation',
                test: () => {
                    vv('cText', "Hello Ring World");
                    return len(v('cText'));
                },
                expectedValue: (result) => result === 16
            })
            .addTestCase({
                title: 'Complex Function with Multiple Parameters',
                test: () => {
                    func('multiply', ['x', 'y'], function() {
                        return v('x') * v('y');
                    });
                    return f('multiply', 6, 7);
                },
                expectedValue: (result) => result === 42
            })
            .runAllTests();
    }
};

// Run tests when the script is loaded
RingJSTests.run();
