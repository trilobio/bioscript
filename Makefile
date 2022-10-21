SHELL := /bin/bash
all: test build

test:
	@rm -rf test ;\
	mkdir test ;\
	tl build -b test -q ;\
	busted -c -m "./test/synbio/?.lua;./test/std/?.lua" ;\
	rm -rf test ;\
	tail luacov.report.out -c 10 | xargs echo "__code coverage:" | sed -e 's/$$/__/' | awk -v n="$$(</dev/stdin)" 'NR==2 {$$0=n} { print }' README.md > README.md.tmp && mv README.md.tmp README.md

build:
	@mkdir build ;\
	sed '$$d' src/std/json.tl >> tmp.tl ;\
	sed '$$d' src/synbio/complement.tl >> tmp.tl ;\
	sed '$$d' src/synbio/fasta.tl >> tmp.tl ;\
	sed '$$d' src/synbio/fastq.tl >> tmp.tl ;\
	sed '$$d' src/synbio/primers.tl >> tmp.tl ;\
	sed '$$d' src/synbio/pcr.tl >> tmp.tl ;\
	sed '$$d' src/synbio/genbank.tl >> tmp.tl ;\
	sed '$$d' src/synbio/fragment.tl >> tmp.tl ;\
	sed '$$d' src/synbio/rebase.tl >> tmp.tl ;\
	sed '$$d' src/synbio/codon.tl >> tmp.tl ;\
	sed '$$d' src/synbio/synbio.tl >> tmp.tl ;\
	sed '$$d' src/std/atoms.tl >> tmp.tl ;\
	sed '$$d' src/std/conversions.tl >> tmp.tl ;\
	sed '$$d' src/std/mixtures.tl >> tmp.tl ;\
	sed '$$d' src/std/util.tl >> tmp.tl ;\
	sed '$$d' src/std/inventory.tl >> tmp.tl ;\
	sed '$$d' src/std/biologic_commands.tl >> tmp.tl ;\
	cat src/std/std.tl >> tmp.tl ;\
	sed -i '/require/d' tmp.tl ;\
	sed -i 's/SUBSTITUTE_WITH_VERSION_NUMBER/0.0.1/g' tmp.tl ;\
	mv tmp.tl bioscript.tl ;\
	tl gen bioscript.tl ;\
	mv bioscript.lua bioscript.tl build/
