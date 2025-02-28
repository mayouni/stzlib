# EXCIS Transformation Engine: Type Mapping Table

Here's a comprehensive mapping table showing how each supported language's data types are transformed to Ring types:

| Language    | Source Type                   | Ring Type              | Notes                                            |
|-------------|-------------------------------|------------------------|--------------------------------------------------|
| **Python**  | `int`                         | Number                 |                                                  |
|             | `float`                       | Number                 | Scientific notation converts to string           |
|             | `str`                         | String                 |                                                  |
|             | `bool` (`True`)               | `TRUE`                 |                                                  |
|             | `bool` (`False`)              | `FALSE`                |                                                  |
|             | `None`                        | `NULL`                 |                                                  |
|             | `list`                        | List                   |                                                  |
|             | `dict`                        | List of key-value pairs| Each pair as `[key, value]`                      |
|             | Custom objects                | String                 | Via `str()` conversion                           |
| **R**       | `numeric`                     | Number                 | Scientific notation converts to string           |
|             | `character`                   | String                 |                                                  |
|             | `logical` (`TRUE`)            | `TRUE`                 |                                                  |
|             | `logical` (`FALSE`)           | `FALSE`                |                                                  |
|             | `NULL`                        | `NULL`                 |                                                  |
|             | `NA`                          | `NULL`                 |                                                  |
|             | `list`                        | List                   |                                                  |
|             | `data.frame`                  | List of key-value pairs| Column names as keys                             |
|             | `vector` (named)              | List of key-value pairs|                                                  |
|             | `vector` (unnamed)            | List                   |                                                  |
|             | `factor`                      | String                 | Should be converted with `as.character()`        |
| **Julia**   | `Int`                         | Number                 |                                                  |
|             | `Float64`                     | Number                 | Scientific notation converts to string           |
|             | `String`                      | String                 |                                                  |
|             | `Bool` (`true`)               | `TRUE`                 |                                                  |
|             | `Bool` (`false`)              | `FALSE`                |                                                  |
|             | `Nothing`                     | `NULL`                 |                                                  |
|             | `Dict`                        | List of key-value pairs| Each pair as `[key, value]`                      |
|             | `Array`                       | List                   |                                                  |
|             | `Tuple`                       | List                   |                                                  |
|             | Custom structs                | String                 | Via `string()` conversion                        |
| **C**       | `int64_t`                     | Number                 |                                                  |
|             | `double`                      | Number                 | Scientific notation converts to string           |
|             | `char*`                       | String                 |                                                  |
|             | `bool` (`true`)               | `TRUE`                 |                                                  |
|             | `bool` (`false`)              | `FALSE`                |                                                  |
|             | `NULL`                        | `NULL`                 |                                                  |
|             | `Value` (`TYPE_ARRAY`)        | List                   | Custom implementation                            |
|             | `Value` (`TYPE_STRUCT`)       | List of key-value pairs| Custom implementation                            |
| **Prolog**  | `atom`                        | String                 |                                                  |
|             | `string`                      | String                 |                                                  |
|             | `number` (integer)            | Number                 |                                                  |
|             | `number` (float)              | Number                 | Scientific notation converts to string           |
|             | `true`                        | `TRUE`                 |                                                  |
|             | `false`                       | `FALSE`                |                                                  |
|             | `list`                        | List                   |                                                  |
|             | `Key-Value` ('-' operator)    | List `[Key, Value]`    | May be inconsistent                              |
|             | Compound terms                | List                   | Arguments become list elements                   |
