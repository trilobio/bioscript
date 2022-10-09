--[[---------------------------------------------------------------------------
This module provides a parser for working with FASTQ formatted sequencing
files.

FASTQ is a flat file format developed by the Wellcome Trust Sanger Institute in
~2000 to store sequencing data. It is the standard in bioinformatics for
storing sequencing data.

The primary difference between FASTA and FASTQ files

FASTQ files contain many sequencing entries, each representing a single "read"
off of the sequencer - whether this be a single molecule, or several molecules
of nominally the same sequence. Each entry has 4 lines, which are not broken
by any newlines for formatting. The 4 entry lines are:
 1. '@' followed by a sequence identifier and other information
 2. Sequence data
 3. '+' (usually with nothing else)
 4. Quality value scores of the sequencing data

Quality, from lowest quality to highest quality, is represented between 0x21
(! in ASCII) and 0x7e (~ in ASCII). This quality is arbitrary per sequencer
device. Acceptable quality values:
 !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmn
 opqrstuvwxyz{|}~


For example, one entry in a FASTQ file could look like:
```
 @SEQ_ID
 GATTTGGGGTTCAAAGCAGTATCGATCAAATAGTAAATCCATTTGTTCAACTCACAGTTT
 +
 !''*((((***+))%%%++)(%%%%).1***-+*''))**55CCF>>>>>>CCCCCCC65
```
--]]---------------------------------------------------------------------------
local record fastq
    record Fastq
        identifier: string
        sequence: string
        quality: string
    end
end

--- Parses a given FASTQ string into a list of FASTQ tables.
-- @param input the input FASTQ string
-- @return a list of FASTQ tables, each containing an identifier, a sequence, and a quality score.
-- @usage local fastqs = fastq.parse("@SEQ_ID\nATGTAA\n+\n!''*%+")
function fastq.parse(input: string): {fastq.Fastq}
    -- Initiate basic variables
    local output: {fastq.Fastq} = {}
    local identifier: string = ""
    local sequence: string = ""
    local quality: string = ""
    local quality_next:boolean = false
    local start:boolean = true

    for line in string.gmatch(input, '[^\r\n]+') do
        local s: string = line:sub(1,1)
        -- Process identifier lines
        if s == "@" then
            -- Process first line
            if start then
                identifier = line:sub(2,-1)
                start = false
            else
                -- This hits when it is the end of one entry and the start of the next
                output[#output+1] = {identifier = identifier, sequence = sequence, quality = quality}
                identifier = ""
                sequence = ""
                quality = ""
            end
        -- Process sequence lines
        elseif s ~= "@" then
            if quality_next == false then
                if s == "+" then
                    -- Quality always follows +
                    quality_next = true
                else
                    -- If not quality line or +, must be sequence
                    sequence = sequence .. line:gsub("%s+", "") -- Remove whitespace from sequence
                end
            else
                -- If quality_next, then set quality
                quality = line
                quality_next = false
            end
        end
    end
    -- Final output
    output[#output+1] = {identifier = identifier, sequence = sequence, quality = quality}
    return output
end

return fastq
