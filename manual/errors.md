## Errors

All exception raised in the library are subclasses of RGFA::Error.
This means that ```rescue RGFA::Error``` catches all library errors.

Different types of errors are defined and are summarized in the following table:

|--------------------------|------------------------------------------------------|-----------------------------------------------------------------------------|
| RGFA::VersionError       | An unknown or wrong version is specified or implied. | e.g. "GFA0"; or GFA1 in GFA2 context                                        |
| RGFA::ValueError         | The value of an object is invalid.                   | e.g. a negative position is used                                            |
| RGFA::TypeError          | The wrong type has been used or specified.           | e.g. Z instead of i used for VN tag; an Hash used for a integer field       |
| RGFA::FormatError        | The format of an object is wrong.                    | e.g. a line does not contain the expected number of fields                  |
| RGFA::NotUniqueError     | Something is not unique, as it should be.            | e.g. duplicated tag name or line identifier                                 |
| RGFA::InconsistencyError | Two pieces of information collide with each other.   | e.g. length of a segment sequence and value of LN tag.                      |
|--------------------------|------------------------------------------------------|-----------------------------------------------------------------------------|
| RGFA::RuntimeError       | The user tried to do something which is not allowed. | e.g. a segment name in a connected link line instance is edited directly    |
| RGFA::ArgumentError      | The argument of a method is not compatible with it.  | e.g the wrong number of arguments is used for a dynamically created method  |
|--------------------------|------------------------------------------------------|-----------------------------------------------------------------------------|
| RGFA::AssertionError     | Something unexpected happened.                       | e.g. there is a bug in the library                                          |
|--------------------------|------------------------------------------------------|-----------------------------------------------------------------------------|

Some error types are generic (such as RuntimeError and ArgumentError), and their
definition may overlap that of more specific errors (such as ValueError and
ArgumentError). The user should not rely on the type of error alone, but
rather take it as an indication. The error message tries to be informative
and for this reason often prints information on the internal state of the
relevant variables.

Assertion errors are reserved for those situation where something is implied
by the programmer (e.g. a value is implied to be positive at a certain point
of the code). It the checks fails, an assertion error is raised.
The user may report the problem, as this may indicate a bug (unless the user
did something he was not supposed to do, such as calling an API private method).
