--[[---------------------------------------------------------------------------
This module provides a parser for working with FASTA formatted genetic
sequences.

FASTA is a flat text file format developed in 1985 to store nucleotide and
amino acid sequences. It is extremely simple and a nearly universal standard
in the field of bioinformatics.

Each entry in a FASTA file has a header or identifier line which begins with
'>', followed by sequence data. By convention, lines are a maximum of 80
characters (since when FASTA was developed, many DEC VT220 terminals could only
display 80 characters). In the original description of the format, there may be
semicolon lines denoting comments and empty lines for readability, but this has
largely fallen out of practice, with the official National Center for
Biotechnology Information (NCBI)'s FASTA definition[1] not allowing either.

Though not a part of the official format, often additional data is separated
by '|', similar to how commas are used in CSV files for data entry.


=== Example FASTA file ===
```
 >MCHU - Calmodulin - Human, rabbit, bovine, rat, and chicken
 MADQLTEEQIAEFKEAFSLFDKDGDGTITTKELGTVMRSLGQNPTEAELQDMINEVDADGNGTID
 FPEFLTMMARKMKDTDSEEEIREAFRVFDKDGNGYISAAELRHVMTNLGEKLTDEEVDEMIREA
 DIDGDGQVNYEEFVQMMTAK*
 >gi|5524211|gb|AAD44166.1| cytochrome b [Elephas maximus maximus]
 LCLYTHIGRNIYYGSYLYSETWNTGIMLLLITMATAFMGYVLPWGQMSFWGATVITNLFSAIPYIGTNLV
 EWIWGGFSVDKATLNRFFAFHFILPFTMVALAGVHLTFLHETGSNNPLGLTSDSDKIPFHPYYTIKDFLG
 LLILILLLLLLALLSPDMLGDPDNHMPADPLNTPLHIKPEWYFLFAYAILRSVPNKLGGVLALFLSIVIL
 GLMPFLHTSKHRSMMLRPLSQALFWTLTMDLLTLTWIGSQPVEYPYTIIGQMASILYFSIILAFLPIAGX
 IENY
```


=== References===
[1] https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=BlastHelp
--]]---------------------------------------------------------------------------
local record fasta
    record Fasta
        identifier: string
        sequence: string
    end
end

--- Parses a given FASTA string into a list of FASTA tables.
-- @param input the input FASTA string
-- @return a list of FASTA tables, each containing an identifier and a sequence.
-- @usage local fastas = fasta.parse(">test\natgtaa")
function fasta.parse(input: string): {fasta.Fasta}
    -- Initiate basic variables
    local output: {fasta.Fasta} = {}
    local identifier: string = ""
    local sequence: string = ""
    local start:boolean = true

    for line in string.gmatch(input, '[^\r\n]+') do
        local s: string = line:sub(1,1)
        -- Process identifier lines
        if s == ">" then
            -- Process first line
            if start then
                identifier = line:sub(2,-1)
                start = false
            else
                -- This hits when it is the end of one entry and the start of the next
                output[#output+1] = {identifier = identifier, sequence = sequence}
                identifier = ""
                sequence = ""
            end
        -- Process sequence lines
        elseif s ~= ">" and s ~= ";" then
            sequence = sequence .. line:gsub("%s+", "") -- Remove whitespace from sequence
        end
    end
    -- Final output
    output[#output+1] = {identifier = identifier, sequence = sequence}
    return output
end

return fasta
