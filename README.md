# Bioscript
__code coverage: 87.21%__

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

# Reading the source

## File formats
1. `src/synbio/fasta.tl`
2. `src/synbio/fastq.tl`
3. `src/synbio/genbank.tl`

## Education on DNA
1. `src/synbio/complement.tl`

### GoldenGate assembly tract
1. `src/synbio/rebase.tl`
2. `src/synbio/restriction_digest.tl`
3. `src/synbio/ligation.tl`
4. `src/synbio/goldengate.tl`

### Gibson assembly tract
1. `src/synbio/pcr.tl`
2. `src/synbio/primers.tl`
3. `src/synbio/ligation.tl`
4. `src/synbio/gibson.tl`


### Thanks
Much of the code here is translated from [Poly](https://github.com/TimothyStiles/poly), a wonderful project you should follow.
