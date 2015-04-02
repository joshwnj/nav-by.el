nav-by.el
====

Idea: abstract the concept of moving forwards or backwards.

When in "nav mode" you choose a unit and then use `.` and `,` to move around. Currently supported units:

- line
- paragraph
- error (uses `(next-error)` and `(previous-error)`, so works on most things that use the compilation buffer, eg. grep matches)
- mark (requires [`show-marks.el`](https://github.com/vapniks/mark))
- isearch matches

Example
----

- `C-n`: activate Nav mode
- `C-s`: starts an `isearch` as usual, but also tells Nav mode to use search units
- `RET`: after typing a search term
- `.` and `,`: move to next / previous match

Movement amounts
----

Some units allow you to specify an amount. Eg:

- `C-n`: activate Nav mode
- `SPC l`: switch to "lines" unit
- `5 .`: move forward by 5 lines. This also records `5` as the movement amount.
- `.`: move forward by another 5 lines
- `,`: move backward by 5 lines
- `0 .` or `0 ,`: reset the movement amount

Contributions
----

Very welcome!

License
----

MIT
