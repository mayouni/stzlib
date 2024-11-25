// Test script for RingOnJS

// ===== String Operations Demo =====

SeeNL('Testing string operations...');

// String test with Ring-style syntax
vv(':text', 'Hello Ring World');

// Ring-style functions (1-based)
SeeNL('Upper:', r$j.upper(v(':text')));
SeeNL('Lower:', r$j.lower(v(':text')));
SeeNL('Left 5:', r$j.left(v(':text'), 5));
SeeNL('Right 5:', r$j.right(v(':text'), 5));
SeeNL('Substring (1-5):', r$j.substring(v(':text'), 1, 5));

// ===== List Operations Demo =====
See('\nTesting list operations...\n');

// List creation with Ring-style syntax
vv(':myList', [1, 2, 3, 4, 5]);

SeeNL('Original List:', v(':myList'));
SeeNL('Get item at position 1:', r$j.get(v(':myList'), 1));
SeeNL('Find position of 3:', r$j.find(v(':myList'), 3));

// Test list addition
vv(':myList', r$j.add(v(':myList'), 6));
SeeNL('After adding 6:', v(':myList'));

// Test list deletion
vv(':myList', r$j.del(v(':myList'), 1));
SeeNL('After deleting position 1:', v(':myList'));

// ===== Loop System Demo =====
See('\nTesting loop system (1-based)...\n');

r$j.for(':i').from(1).to(5, _(() => {
    SeeNL('Loop index (1-based):', v(':i'));
}));

// ===== Class System Demo =====
See('\nTesting class system...\n');

r$j.class('Person').Block(function() {
    this.attr(':name', '');
    this.attr(':age', 0);
    
    this.def('init', function(name, age) {
        this.name = name;
        this.age = age;
    });
    
    this.def('info', function() {
        return `${this.name} is ${this.age} years old`;
    });
});

r$j.class('Employee')
    .From('Person')
    .Block(function() {
        this.attr(':salary', 0);
        
        this.def('init', function(name, age, salary) {
            this.name = name;
            this.age = age;
            this.salary = salary;
        });
        
        this.def('info', function() {
            return `${this.name} is ${this.age} years old earning ${this.salary}`;
        });
    });

// Test classes
vv(':john', v('Person').new('John', 25));
SeeNL('Person:', v(':john').info());

vv(':alice', v('Employee').new('Alice', 28, 50000));
SeeNL('Employee:', v(':alice').info());

See('\nAll tests completed!\n');