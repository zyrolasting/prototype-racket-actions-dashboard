prototype-racket-actions-dashboard
==================================

This is an early stage exploration into a portal for Racket build
reviews and monitoring. Specific requirements are not yet defined,
and the implementation is as unstable as it could possibly be.

* `records.rkt-list` holds a Racket list in the format `((ID . HASH))`, where `ID` is an exact non-negative integer and `HASH` is a Racket hash literal.
* `/build/123` will simply display a formatted document of record with ID `123` from `records.rkt-list`.
