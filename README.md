# Bioscript

Bioscript is a synthetic biology language built for digital representation and physical execution of synthetic biology procedures.

* __Reproducible:__ bioscript written today should act the same way as it does 10 years from now.
* __Embeddable:__ bioscript can be embedded in larger programs.
* __Modern:__ bioscript is built for engineering in the modern day, from codon optimization to synthesis fixing.
* __Maintainable:__ bioscript is built for long term stability and continuous testing.

### Directories
* `src` contains bioscript source code (written in [teal](https://github.com/teal-language))
* `build` contains the full bioscript library, in both teal and lua
* `spec` contains unit tests

### Building and testing
To build from source and run all tests, run:
```
make
```

### Thanks
Much of the code here is translated from [Poly](https://github.com/TimothyStiles/poly), a wonderful project you should follow.
