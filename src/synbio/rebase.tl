--[[---------------------------------------------------------------------------
Module rebase contains a rebase parser for rebase data dump #31.

=== Introduction ===
In 1970, Hamilton O. Smith, Thomas Kelly and Kent Wilcox discovered an enzyme
from Haemophilus influenzae that recognized and cut at a specific sequence of
DNA. These enzymes, known as Type II restriction enzymes (as opposed to Type I,
which cut randomly away from where recognize), were studied for their potential
in genetic manipulation. For example, EcoRI, a Type II restriction enzyme, cuts
the following DNA sequence:

 GAATTC + EcoRI = G    AATTC
 CTTAAG           CTTAA    G

In this case, the sequence "GAATTC" is split in two, with a "AATT" overhang.
If there is another sequence with an "AATT" overhang, you can glue the
sequences together using an enzyme called ligase:

 G     + AATTCGGTCTC + ligase = GAATTCGGTCTC
 CTTAA       GCCAGAG            CTTAAGCCAGAG

It was quickly realized that if you cut two different sequences with the same
restriction enzyme, you could combine them together using ligase into novel
sequences. This ushered in the age of "recombinant DNA" technology. This was
and still is the most popular way of creating recombinant DNA, though there a
newer method called Gibson Assembly has recently been growing in popularity.


=== REBASE ===
Thousands of restriction enzymes have been discovered. In order to use them
in software, we have to know the sequence each one recognizes and how it cuts
that sequence. All of this data is stored in the REBASE database, an amazing
resource run by New England Biolabs listing almost every known restriction
enzyme and how they cut. This parser parses data dump format #31[1], which is
what Bioperl uses[2]. It is updated monthly[3].

The header of this file gives a wonderful explanation of its structure. Below
"References" is the September 2022 data dump header with a single entry.

The REBASE parser is used during the build process to parse certain popular
enzymes, not the entire REBASE database, into the bioscript amalgamation.


=== References ===
[1] http://rebase.neb.com/rebase/rebase.f31.html
[2] https://bioperl.org/howtos/Restriction_Enzyme_Analysis_HOWTO.html
[3] http://rebase.neb.com/rebase/link_withrefm

```
 
REBASE version 210                                              withrefm.210
 
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    REBASE, The Restriction Enzyme Database   http://rebase.neb.com
    Copyright (c)  Dr. Richard J. Roberts, 2022.   All rights reserved.
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 
Rich Roberts                                                    Sep 28 2022
 

<ENZYME NAME>   Restriction enzyme name.
<ISOSCHIZOMERS> Other enzymes with this specificity.
<RECOGNITION SEQUENCE> 
                These are written from 5' to 3', only one strand being given.
                If the point of cleavage has been determined, the precise site
                is marked with ^.  For enzymes such as HgaI, MboII etc., which
                cleave away from their recognition sequence the cleavage sites
                are indicated in parentheses.  

                For example HgaI GACGC (5/10) indicates cleavage as follows:
                                5' GACGCNNNNN^      3'
                                3' CTGCGNNNNNNNNNN^ 5'

                In all cases the recognition sequences are oriented so that
                the cleavage sites lie on their 3' side.

                REBASE Recognition sequences representations use the standard 
                abbreviations (Eur. J. Biochem. 150: 1-5, 1985) to represent 
                ambiguity.
                                R = G or A
                                Y = C or T
                                M = A or C
                                K = G or T
                                S = G or C
                                W = A or T
                                B = not A (C or G or T)
                                D = not C (A or G or T)
                                H = not G (A or C or T)
                                V = not T (A or C or G)
                                N = A or C or G or T



                ENZYMES WITH UNUSUAL CLEAVAGE PROPERTIES:  

                Enzymes that cut on both sides of their recognition sequences,
                such as BcgI, Bsp24I, CjeI and CjePI, have 4 cleavage sites
                each instead of 2.

                Bsp24I
                          5'      ^NNNNNNNNGACNNNNNNTGGNNNNNNNNNNNN^   3'
                          3' ^NNNNNNNNNNNNNCTGNNNNNNACCNNNNNNN^        5'


                This will be described in some REBASE reports as:

                             Bsp24I (8/13)GACNNNNNNTGG(12/7)

<METHYLATION SITE>
                The site of methylation by the cognate methylase when known
                is indicated X(Y) or X,X2(Y,Y2), where X is the base within
                the recognition sequence that is modified.  A negative number
                indicates the complementary strand, numbered from the 5' base 
                of that strand, and Y is the specific type of methylation 
                involved:
                               (6) = N6-methyladenosine 
                               (5) = 5-methylcytosine 
                               (4) = N4-methylcytosine

                If the methylation information is different for the 3' strand,
                X2 and Y2 are given as well.

<MICROORGANISM> Organism from which this enzyme had been isolated.
<SOURCE>        Either an individual or a National Culture Collection.
<COMMERCIAL AVAILABILITY>
                Each commercial source of restriction enzymes and/or methylases
                listed in REBASE is assigned a single character abbreviation 
                code.  For example:

                K        Takara (1/98)
                M        Boehringer Mannheim (10/97)
                N        New England Biolabs (4/98)
 
                The date in parentheses indicates the most recent update of 
                that organization's listings in REBASE.

<REFERENCES>only the primary references for the isolation and/or purification
of the restriction enzyme or methylase, the determination of the recognition
sequence and cleavage site or the methylation specificity are given.


REBASE codes for commercial sources of enzymes

                B        Thermo Fisher Scientific (7/22)
                C        Minotech Biotechnology (1/22)
                E        Agilent Technologies (8/20)
                I        SibEnzyme Ltd. (12/21)
                J        Nippon Gene Co., Ltd. (7/22)
                K        Takara Bio Inc. (3/22)
                M        Roche Applied Science (9/21)
                N        New England Biolabs (7/22)
                O        Toyobo Biochemicals (8/14)
                Q        Molecular Biology Resources - CHIMERx (7/22)
                R        Promega Corporation (11/20)
                S        Sigma Chemical Corporation (5/21)
                V        Vivantis Technologies (1/18)
                X        EURx Ltd. (7/22)
                Y        SinaClon BioScience Co. (1/18)

<1>AaaI
<2>XmaIII,BseX3I,BsoDI,BstZI,EagI,EclXI,Eco52I,SenPT16I,TauII,Tsp504I
<3>C^GGCCG
<4>
<5>Acetobacter aceti ss aceti
<6>M. Fukaya
<7>
<8>Tagami, H., Tayama, K., Tohyama, T., Fukaya, M., Okumura, H., Kawamura, Y., Horinouchi, S., Beppu, T., (1988) FEMS Microbiol. Lett., vol. 56, pp. 161-166.
```

--]]---------------------------------------------------------------------------

local record rebase
    record RestrictionEnzyme
        name: string
        isoschizomers: {string} -- other enzymes with the same recognition and cut site
        recognition_sequence: string
        methylation_site: string
        microorganism: string
        source: string
        commercial_availability: {string}
        references: {string}
    end
    parse: function(string): {string: RestrictionEnzyme}
end

function rebase.parse(input: string): {string: rebase.RestrictionEnzyme}
    local enzymes: {string: rebase.RestrictionEnzyme} = {}
    local enzyme: rebase.RestrictionEnzyme = {isoschizomers = {}, commercial_availability = {}, references = {}}

    local commercial_suppliers: {string: string} = {}
    local start_commercial_parsing: boolean = false
    local commercial_parsing_line: integer = 0

    local first_enzyme = true

    for line in string.gmatch(input, '[^\r\n]+') do
        -- Parse commercial sources
        if line == "REBASE codes for commercial sources of enzymes" then
            start_commercial_parsing = true
        end
        if start_commercial_parsing then
            -- If enzyme parsing has started, break the commercial supplier parsing
            if line:find("<1>") then
                start_commercial_parsing = false
                commercial_parsing_line = 0
            end

            commercial_parsing_line = commercial_parsing_line + 1
            local stripped_line = line:gsub('^%s*(.-)%s*$', '%1')
            if (commercial_parsing_line > 3) and (stripped_line:len() > 0) then
                -- The first letter of the stripped_line is the single letter code
                local commercial_code_letter = stripped_line:sub(1,1)
                -- There are 8 spaces until the commercial companies's name. We
                -- also remove the date parathesis, and then strip the line
                -- once again.
                local commercial_name = stripped_line:sub(9,-1):gsub('%b()', ''):gsub('^%s*(.-)%s*$', '%1')

                commercial_suppliers[commercial_code_letter] = commercial_name
            end
        end

        -- Normal enzyme parsing
        local str = line:sub(4,-1)
        if line:find("<1>") then
            if first_enzyme == true then
              first_enzyme = false
            else
              -- put the current enzyme into enzymeMap and setup a new enzyme
              enzymes[enzyme.name] = enzyme
              enzyme = {isoschizomers = {}, commercial_availability = {}, references = {}}
            end
            enzyme.name = str
        elseif line:find("<2>") then
            for isoschizomer in str:gmatch('([^,]+)') do
                enzyme.isoschizomers[#enzyme.isoschizomers+1] = isoschizomer
            end
        elseif line:find("<3>") then
            enzyme.recognition_sequence = str
        elseif line:find("<4>") then
            enzyme.methylation_site = str
        elseif line:find("<5>") then
            enzyme.microorganism = str
        elseif line:find("<6>") then
            enzyme.source = str
        elseif line:find("<7>") then
            -- we need to get a list of specific commercial suppliers from the
            -- commerical_suppliers table
            for idx = 1, #str do
                enzyme.commercial_availability[#enzyme.commercial_availability+1] = commercial_suppliers[str:sub(idx,idx)]
            end
        elseif line:find("<8>") then
          enzyme.references[#enzyme.references+1] = str
        else
          enzyme.references[#enzyme.references+1] = line
        end
    end
    -- Final enzyme
    enzymes[enzyme.name] = enzyme
    return enzymes
end

return rebase
