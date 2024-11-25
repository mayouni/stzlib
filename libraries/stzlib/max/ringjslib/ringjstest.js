// === ringjstest.js ===
// Test suite for RingJSLib

// Testing variable assignment
	seenl('Testing variable assignment...');
	hr();

	vv('cName', "kathy");
	seenl('Name:', v('cName'));

	vv('aInfo', ["age", 25]);
	seenl('Info:', v('aInfo'));

	vv('cGreeting', 'Hello Ring!');
	seenl('Greeting:', v('cGreeting'));
	nl();

// Test string operations
	seenl('Testing string operations...');
	hr();

	vv('cText', "Hello Ring World");
	seenl('Upper:', upper(v('cText')));
	seenl('Lower:', lower(v('cText')));
	seenl('Left 5:', left(v('cText'), 5));
	seenl('Right 5:', right(v('cText'), 5));
	seenl('Substr(1,5):', substr(v('cText'), 1, 5));
	nl();

// Test list operations
	seenl('Testing list operations...');
	hr();

	vv('aMyList', [1, 2, 3, 4, 5]);
	seenl('Original list:', v('aMyList'));

	vv('aNewList', add(v('aMyList'), 6));
	seenl('After add:', v('aNewList'));

	vv('aAfterDel', del(v('aNewList'), 1));
	seenl('After delete first:', v('aAfterDel'));

	seenl('Get item at position 2:', nth(v('aMyList'), 2));
	nl();

// Test function definition and calling
	seenl("Testing functions...");
	hr();

	func('greet', ['pcPerson'], function() {
   		return 'Hello ' + v('pcPerson');
	});

	seenl( 'Function result:', f('greet', "Kathy") );
	nl();

// Test type checking
	seenl('Testing type checking...');
	hr();

	seenl( "Type of list:", type( v('aMyList') ) );
	seenl( "Type of string:", type( v('cName') ) );
	seenl( "Type of null:", type(null) );
	nl();

// End of the tests
	hr();
	seenl('All tests completed!');