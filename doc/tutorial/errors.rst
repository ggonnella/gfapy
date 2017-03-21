.. _errors:

Errors
------

The different types of errors defined in Gfapy are summarized in the
following table. All exception raised in the library are subclasses of
`Error`. Thus, ``except gfapy.Error`` can be use to catch
all library errors.

+-----------------------+-------------------------------+---------------------------------+
| Error                 | Description                   | Examples                        |
+=======================+===============================+=================================+
| `VersionError`        | An unknown or wrong version   | "GFA0"; or GFA1 in GFA2 context |
|                       | is specified or implied       |                                 |
+-----------------------+-------------------------------+---------------------------------+
| `ValueError`          | The value of an object is     | a negative position is used     |
|                       | invalid                       |                                 |
+-----------------------+-------------------------------+---------------------------------+
| `TypeError`           | The wrong type has been used  | Z instead of i used for VN tag; |
|                       | or specified                  | Hash for an i tag               |
+-----------------------+-------------------------------+---------------------------------+
| `FormatError`         | The format of an object is    | a line does not contain the     |
|                       | wrong                         | expected number of fields       |
+-----------------------+-------------------------------+---------------------------------+
| `NotUniqueError`      | Something should be unique    | duplicated tag name or line     |
|                       | but is not                    | identifier                      |
+-----------------------+-------------------------------+---------------------------------+
| `InconsistencyError`  | Pieces of information collide | length of sequence and LN tag   |
|                       | with each other               | do not match                    |
+-----------------------+-------------------------------+---------------------------------+
| `RuntimeError`        | The user tried to do          | editing from/to field in        |
|                       | something which is not        | connected links                 |
|                       | allowed                       |                                 |
+-----------------------+-------------------------------+---------------------------------+
| `ArgumentError`       | Problem with the arguments of | wrong number of arguments in    |
|                       | a method                      | dynamically created method      |
+-----------------------+-------------------------------+---------------------------------+
| `AssertionError`      | Something unexpected happened | there is a bug in the library or|
|                       |                               | the library has been used in    |
|                       |                               | an unintended way               |
+-----------------------+-------------------------------+---------------------------------+

