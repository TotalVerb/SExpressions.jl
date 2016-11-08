(#:each x (List "my [link to](http://example.com)")
  `(,((. StdLib render) x)))
