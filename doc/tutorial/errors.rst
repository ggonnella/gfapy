Errors
------

All exception raised in the library are subclasses of ``gfapy.Error``.
This means that ``except gfapy.Error`` catches all library errors.

Different types of errors are defined and are summarized in the
following table:

+------------+-------------------------------+---------------------------------+
| Error      | Description                   | Examples                        |
+============+===============================+=================================+
| Version    | An unknown or wrong version   | "GFA0"; or GFA1 in GFA2 context |
|            | is specified or implied       |                                 |
+------------+-------------------------------+---------------------------------+
| Value      | The value of an object is     | a negative position is used     |
|            | invalid                       |                                 |
+------------+-------------------------------+---------------------------------+
| Type       | The wrong type has been used  | Z instead of i used for VN tag; |
|            | or specified                  | Hash for an i tag               |
+------------+-------------------------------+---------------------------------+
| Format     | The format of an object is    | a line does not contain the     |
|            | wrong                         | expected number of fields       |
+------------+-------------------------------+---------------------------------+
| NotUnique  | Something should be unique    | duplicated tag name or line     |
|            | but is not                    | identifier                      |
+------------+-------------------------------+---------------------------------+
| Inconsiste | Pieces of information collide | length of sequence and LN tag   |
| ncy        | with each other               | do not match                    |
+------------+-------------------------------+---------------------------------+
| Runtime    | The user tried to do          | editing from/to field in        |
|            | something which is not        | connected links                 |
|            | allowed                       |                                 |
+------------+-------------------------------+---------------------------------+
| Argument   | Problem with the arguments of | wrong number of arguments in    |
|            | a method                      | dynamically created method      |
+------------+-------------------------------+---------------------------------+
| Assertion  | Something unexpected happened | there is a bug in the library   |
+------------+-------------------------------+---------------------------------+

Some error types are generic (such as RuntimeError and ArgumentError),
and their definition may overlap that of more specific errors (such as
ArgumentError, which overlaps ValueError and TypeError). The user should
not rely on the type of error alone, but rather take it as an
indication. The error message tries to be informative and for this
reason often prints information on the internal state of the relevant
variables.

Assertion errors are reserved for those situation where something is
implied by the programmer (e.g. a value is implied to be positive at a
certain point of the code). It the checks fails, an assertion error is
raised. The user may report the problem, as this may indicate a bug
(unless the user did something he was not supposed to do, such as
calling an API private method).
