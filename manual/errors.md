## Errors

All exception raised in the library are subclasses of RGFA::Error.
This means that ```rescue RGFA::Error``` catches all library errors.

Different types of errors are defined and are summarized in the following table:

| Error            | Description                                          | Examples                                                 |
|------------------|------------------------------------------------------|----------------------------------------------------------|
| Version          | An unknown or wrong version is specified or implied  | "GFA0"; or GFA1 in GFA2 context                          |
| Value            | The value of an object is invalid                    | a negative position is used                              |
| Type             | The wrong type has been used or specified            | Z instead of i used for VN tag; Hash for an i tag        |
| Format           | The format of an object is wrong                     | a line does not contain the expected number of fields    |
| NotUnique        | Something should be unique but is not                | duplicated tag name or line identifier                   |
| Inconsistency    | Pieces of information collide with each other        | length of sequence and LN tag do not match               |
| Runtime          | The user tried to do something which is not allowed  | editing from/to field in connected links                 |
| Argument         | Problem with the arguments of a method               | wrong number of arguments in dynamically created method  |
| Assertion        | Something unexpected happened                        | there is a bug in the library                            |

Some error types are generic (such as RuntimeError and ArgumentError), and their
definition may overlap that of more specific errors (such as ArgumentError,
which overlaps ValueError and TypeError).
The user should not rely on the type of error alone, but
rather take it as an indication. The error message tries to be informative
and for this reason often prints information on the internal state of the
relevant variables.

Assertion errors are reserved for those situation where something is implied
by the programmer (e.g. a value is implied to be positive at a certain point
of the code). It the checks fails, an assertion error is raised.
The user may report the problem, as this may indicate a bug (unless the user
did something he was not supposed to do, such as calling an API private method).

