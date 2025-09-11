# Thinking in SQL Within Ring: Softanza's stzExtCode Facility

Softanza's stzExtCode facility brings SQL's declarative paradigm directly into Ring code. Instead of switching between SQL and procedural logic, developers apply SQL thinking to craft and manipulate structured data stored in variables, maintaining the same mental model throughout.

## Creating a Table: SQL-Inspired Structure in Ring

Traditional SQL (for databases):
```sql
CREATE TABLE persons (
    id     SMALLINT,
    name   VARCHAR(30), 
    score  SMALLINT
);
```

SQL-inspired syntax in Ring (for in-memory data):
```ring
@CREATE_TABLE( :persons ) {
    @([
        :id    = SMALLINT,     // SQL datatypes referenced but adapted to Ring
        :name  = VARCHAR(30),
        :score = SMALLINT
    ])
};
```

The `v()` function accesses the created named variable:

```ring
v(:persons).Show() + NL
#-->
╭────┬──────┬───────╮
│ Id │ Name │ Score │
├────┼──────┼───────┤
│    │      │       │
╰────┴──────┴───────╯
```

## Inserting Data: SQL-Style Population

Traditional SQL (for databases):
```sql
INSERT INTO persons (id, name, score)
VALUES (1, "Bob", 89),
       (2, "Dan", 120),
       (3, "Tim", 56);
```

SQL-inspired syntax in Ring (for in-memory data):
```ring
@INSERT_INTO( :persons, [ :id, :name, :score ] )
@VALUES([
    [ 1, 'Bob',  89 ],
    [ 2, 'Dan', 120 ],
    [ 3, 'Tim',  56 ]
]);
```

Data populates the variable:

```ring
v(:persons).Show()
#-->
╭────┬──────┬───────╮
│ Id │ Name │ Score │
├────┼──────┼───────┤
│  1 │ Bob  │    89 │
│  2 │ Dan  │   120 │
│  3 │ Tim  │    56 │
╰────┴──────┴───────╯
```

Add more rows incrementally:

```ring
@VALUES([
    [ 4, 'Roy', 100 ],
    [ 5, 'Sam', 78 ]
]);

v(:persons).Show()
#-->
╭────┬──────┬───────╮
│ Id │ Name │ Score │
├────┼──────┼───────┤
│  1 │ Bob  │    89 │
│  2 │ Dan  │   120 │
│  3 │ Tim  │    56 │
│  4 │ Roy  │   100 │
│  5 │ Sam  │    78 │
╰────┴──────┴───────╯
```

## Querying Data: SQL Logic Applied to Variables

Traditional SQL (for databases):
```sql
WITH sql AS (
    SELECT name, score
    FROM persons
    WHERE score > 80
)
```

SQL-inspired syntax in Ring (for in-memory data):
```ring
@WITH(:sql).AS([
    @SELECT([ :name, :score ]),
    @FROM( :persons ),
    @WHERE( 'score > 80' )  // Supports conditions like 'name = "Dan"'
])
```

Results available in named variables:

```ring
? v(:sql)  # Or v(:sqlData)
#--> [ ["Bob", 89], ["Dan", 120], ["Roy", 100] ]

v(:sqlTable).Show()  # Or v(:sqlObject)
#-->
╭──────┬───────╮
│ Name │ Score │
├──────┼───────┤
│ Bob  │    89 │
│ Dan  │   120 │
│ Roy  │   100 │
╰──────┴───────╯
```

## Sorting Data: SQL-Style Ordering

Traditional SQL (for databases):
```sql
WITH sql AS (
    SELECT * FROM persons
    ORDER BY score DESC
)
```

SQL-inspired syntax in Ring (for in-memory data):
```ring
@WITH(:sql).AS([
    @SELECT('*'), 
    @FROM(:persons),
    @ORDER_BY(:SCORE, :DESC)  // Or :ASC
])
```

View the sorted data:

```ring
v(:sqlTable).Show()
#-->
╭──────┬───────╮
│ Name │ Score │
├──────┼───────┤
│ Dan  │   120 │
│ Roy  │   100 │
│ Bob  │    89 │
╰──────┴───────╯
```

## The Approach Benefits

This approach bridges database operations and in-memory manipulation:

- **Unified Thinking**: After loading database data, continue with SQL paradigm in Ring—no mental model switching
- **Progressive Development**: Build, query, and transform data step-by-step using declarative SQL patterns
- **Native Integration**: Results stored in Ring variables, fully integrated with Softanza objects
- **Real-World Flow**: Seamless transition from external data sources to in-app manipulation

The facility leverages SQL's proven effectiveness for structured data while maintaining Ring's object-oriented capabilities.