(#:each x (List "my [link to](http://example.com)")
  `(,((. StdLib rendermd) x)))
