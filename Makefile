SHELL := /bin/bash
all: test build doc

test:
	@rm -rf test ;\
	mkdir test ;\
	tl build -b test -q ;\
	busted -c -m "./test/synbio/?.lua;./test/std/?.lua" ;\
	rm -rf test

build:
	@mkdir build ;\
	sed '$$d' src/synbio/complement.tl >> tmp.tl ;\
	sed '$$d' src/synbio/json.tl >> tmp.tl ;\
	sed '$$d' src/synbio/fasta.tl >> tmp.tl ;\
	sed '$$d' src/synbio/fastq.tl >> tmp.tl ;\
	sed '$$d' src/synbio/primers.tl >> tmp.tl ;\
	sed '$$d' src/synbio/pcr.tl >> tmp.tl ;\
	sed '$$d' src/synbio/genbank.tl >> tmp.tl ;\
	sed '$$d' src/synbio/fragment.tl >> tmp.tl ;\
	sed '$$d' src/synbio/codon.tl >> tmp.tl ;\
	cat src/synbio/synbio.tl >> tmp.tl ;\
	sed -i '/require/d' tmp.tl ;\
	sed -i 's/SUBSTITUTE_WITH_VERSION_NUMBER/0.0.1/g' tmp.tl ;\
	mv tmp.tl bioscript.tl ;\
	tl gen bioscript.tl ;\
	mv bioscript.lua bioscript.tl build/

doc:
	@rm -rf doc ;\
	mkdir doc ;\
	mkdir tmpdoc ;\
	find ./src/synbio/ -name "*.tl" | xargs cp -t tmpdoc/ ;\
	cd tmpdoc ;\
	for f in *.tl; do mv -- "$$f" "$${f%.tl}.lua" ;\
	done ;\
	cd .. ;\
	rm tmpdoc/synbio.lua ;\
	ldoc tmpdoc ;\
	rm -rf tmpdoc
