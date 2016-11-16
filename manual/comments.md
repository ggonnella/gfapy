## Comments

GFA lines starting with a ```#``` symbol are considered comments.
In RGFA comments are represented by instances of RGFA::Line::Comment.
They have a similar interface to other line instances (see below),
with some differences, e.g. they do not support tags.

### Comments in RGFA objects

Adding a comment to a RGFA object is done similary to other lines,
by using the ```RGFA#<<(line)``` method (e.g. ```g << "# this is a comment"```).

The comments of a RGFA object can be accessed using the
```RGFA#comments``` method. This returns an array of comment line
instances.

To remove a comment from the RGFA, first find the instance (using the
#comments array), then call ```RGFA::Line::Comment#disconnect``` on it,
or call ```RGFA#rm(line)``` passing the instance as parameter.

### Accessing the comment content

The content of the comment line, excluding the initial +#+ and eventual
initial spacing characters, is included in the field +content+.

The initial spacing characters can be read/changed using the +spacer+
field. The default value is a single space.

Tags are not supported by comment lines. If the line contains tags,
these are nor parsed, but included in the +content+ field.
Trying to set or get tag values raises exceptions.

### Summary of comments-related API methods

```
RGFA#<<(comment_line)
RGFA#comments
RGFA::Line::Comment#disconnect
RGFA#rm(comment_line)
RGFA::Line::Comment#content/content=
RGFA::Line::Comment#spacer/spacer=
```

