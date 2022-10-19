--[[---------------------------------------------------------------------------
The complement module provides functions for getting the reverse complement
of a given DNA sequence.

DNA, as a double helix, contains two strands of single-stranded DNA bonded to
each other through hydrogren bonds on each strand's base pairs. In DNA, adenine
has two hydrogen bonds with the other stand's complementing thymine. Guanine,
on the other hand, has three hydrogen bonds with the other strand's
complementing cytosine[1].

 A: Adenine
 T: Thymine
 G: Guanine
 C: Cytosine

Each DNA strand has a certain direction (known as the 3prime or 5prime end,
usually written as 3' or 5')[2]. These directions have important biological
consequences: DNA polymerase can only synthesize DNA in the 5' to 3' direction,
while oligos can only be chemically synthesized in the 3' to 5' direction. The
double helix's complementing DNA strands run in opposite directions to each
other. For example, look at the following DNA sequence:

 5' A T G C 3'
 3' T A C G 5'

DNA, when read as a string on a computer, is always in the 5' to 3' direction.
That means the two strands producing the above DNA sequence are "ATGC" and
"GCAT". When a function makes a "reverse complement" of a strand, it means
converting from an input of ATGC to an output of GCAT. Reverse complementing
is important in simulating how enzymes and other strands will interact with
a DNA strand of interest.

Finally, there are certain occassions where we need have "degenerate" base
pairs, which are string representations of different possible base pairs[3].
There are many of them, but the most common are:

 N (any): A, T, G, C
 W (weak): A, T
 S (strong): G, C

This particular module implements a single function to get the reverse
complement of a DNA sequence.


=== References ===
[1] https://en.wikipedia.org/wiki/DNA
[2] https://en.wikipedia.org/wiki/Directionality_(molecular_biology)
[3] https://en.wikipedia.org/wiki/Nucleic_acid_notation

]]-----------------------------------------------------------------------------
local record complement
	COMPLEMENTS: {string:string}
  reverse_complement: function(string): string
end

--- complement.COMPLEMENTS are DNA base complements.
-- @table COMPLEMENTS
complement.COMPLEMENTS = {
	A = "T",
	B = "V",
	C = "G",
	D = "H",
	G = "C",
	H = "D",
	K = "M",
	M = "K",
	N = "N",
	R = "Y",
	S = "S",
	T = "A",
	U = "A",
	V = "B",
	W = "W",
	Y = "R",
}
for k, v in pairs(complement.COMPLEMENTS) do
	complement.COMPLEMENTS[k:lower()] = v:lower()
end

--- Returns reverse complement of a sequence, returns empty string if unknown character.
-- @param sequence the sequence to reverse complement
-- @return the reverse complement
-- @usage local s = complement.reverse_complement("ATGC")
function complement.reverse_complement(sequence: string): string
  sequence = sequence:upper()
	local s: string = ""
	for i = 1, #sequence do
    local base = sequence:sub(i,i)
		if complement.COMPLEMENTS[base] == nil then error("unknown base pair: " .. base) end
		s = s .. complement.COMPLEMENTS[base]
	end
	return s:reverse()
end

return complement
