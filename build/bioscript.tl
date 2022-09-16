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

References:
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

local record json
	decode: function(string): any
	encode: function(any): string
end

--[[---------------------------------------------------------------------------

--                          JSON

---------------------------------------------------------------------------]]--

local encode: function(any, table): string

local escape_char_map: {string:string} = {
	["\\"] = "\\",
	["\""] = "\"",
	[ "\b" ] = "b",
	[ "\f" ] = "f",
	[ "\n" ] = "n",
	[ "\r" ] = "r",
	[ "\t" ] = "t",
}

local escape_char_map_inv: {string:string} = { [ "/" ] = "/" }
for k, v in pairs(escape_char_map) do
  escape_char_map_inv[v] = k
end

local function escape_char(c: string): string
  return "\\" .. (escape_char_map[c] or string.format("u%04x", c:byte()))
end

local function encode_nil(_:any): string
  return "null"
end

local function encode_table(val:table, stack:table): string
  local res = {}
  stack = stack or {}

  -- Circular reference
  if stack[val] then error("circular reference") end
  stack[val] = true

  if rawget(val, 1) ~= nil or next(val) == nil then
    -- Treat as array
    local n = 0
    for k in pairs(val) do
      if type(k) ~= "number" then
        error("invalid table: mixed or invalid key types")
      end
      n = n + 1
    end
    if n ~= #val then
      error("invalid table: sparse array")
    end
    -- Encode
    for _, v in ipairs(val as {any}) do
      table.insert(res, encode(v, stack))
    end
    stack[val] = nil
    return "[" .. table.concat(res, ",") .. "]"

  else
    -- Treat as object
    for k, v in pairs(val) do
      if type(k) ~= "string" then
        error("invalid table: mixed or invalid key types")
      end
      local stack_value = encode(v, stack)
      if stack_value ~= nil then
        table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
      end
    end
    stack[val] = nil
    return "{" .. table.concat(res, ",") .. "}"
  end
end

local function encode_string(val: string): string
  return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
end


local function encode_number(val:number): string
  -- Check for NaN, -inf and inf
  if val ~= val or val <= -math.huge or val >= math.huge then
    error("unexpected number value '" .. tostring(val) .. "'")
  end
  return string.format("%.14g", val)
end


local type_func_map: {string: function(any, any): string} = {
  [ "nil"     ] = encode_nil,
  [ "table"   ] = encode_table,
  [ "string"  ] = encode_string,
  [ "number"  ] = encode_number,
  [ "boolean" ] = tostring,
}

encode = function(val:any, stack:table): string
  local t = type(val)
  local f = type_func_map[t]
  if f then
    return f(val, stack)
  end
  if t ~= "function" then
    error("unexpected type '" .. t .. "'")
  end
end

function json.encode(val: any): string
  return encode(val)
end

local parse: function(str:string, idx:integer): table, integer

local function create_set(...: string): {string:boolean}
  local res: {string:boolean} = {}
  for i = 1, select("#", ...) do
    res[ select(i, ...) ] = true
  end
  return res
end

local space_chars: {string:boolean}   = create_set(" ", "\t", "\r", "\n")
local delim_chars: {string:boolean}   = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
local escape_chars: {string:boolean}  = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
local literals: {string:boolean}      = create_set("true", "false", "null")

local literal_map: {string:boolean} = {
  [ "true"  ] = true,
  [ "false" ] = false,
  [ "null"  ] = nil,
}


local function next_char(str:string, idx:integer, set: {string:boolean}, negate: boolean): integer
  for i = idx, #str do
    if set[str:sub(i, i)] ~= negate then
      return i
    end
  end
  return #str + 1
end


local function decode_error(str:string, idx:integer, msg:string)
  local line_count = 1
  local col_count = 1
  for i = 1, idx - 1 do
    col_count = col_count + 1
    if str:sub(i, i) == "\n" then
      line_count = line_count + 1
      col_count = 1
    end
  end
  error( string.format("%s at line %d col %d", msg, line_count, col_count) )
end


local function codepoint_to_utf8(n:number): string
  -- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
  local f = math.floor
  if n <= 0x7f then
    return string.char(n)
  elseif n <= 0x7ff then
    return string.char(f(n / 64) + 192, n % 64 + 128)
  elseif n <= 0xffff then
    return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
  elseif n <= 0x10ffff then
    return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,
                       f(n % 4096 / 64) + 128, n % 64 + 128)
  end
  error( string.format("invalid unicode codepoint '%x'", n) )
end


local function parse_unicode_escape(s:string): string
  local n1 = tonumber( s:sub(1, 4),  16 )
  local n2 = tonumber( s:sub(7, 10), 16 )
   -- Surrogate pair?
  if n2 then
    return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
  else
    return codepoint_to_utf8(n1)
  end
end


local function parse_string(str:string, i:integer): any, integer
  local res = ""
  local j = i + 1
  local k = j

  while j <= #str do
    local x = str:byte(j)

    if x < 32 then
      decode_error(str, j, "control character in string")

    elseif x == 92 then -- `\`: Escape
      res = res .. str:sub(k, j - 1)
      j = j + 1
      local c = str:sub(j, j)
      if c == "u" then
        local hex = str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1)
                 or str:match("^%x%x%x%x", j + 1)
                 or decode_error(str, j - 1, "invalid unicode escape in string")
        res = res .. parse_unicode_escape(hex)
        j = j + #hex
      else
        if not escape_chars[c] then
          decode_error(str, j - 1, "invalid escape char '" .. c .. "' in string")
        end
        res = res .. escape_char_map_inv[c]
      end
      k = j + 1

    elseif x == 34 then -- `"`: End of string
      res = res .. str:sub(k, j - 1)
      return res, j + 1
    end

    j = j + 1
  end

  decode_error(str, i, "expected closing quote for string")
end


local function parse_number(str: string, i: integer): number, integer
  local x = next_char(str, i, delim_chars)
  local s = str:sub(i, x - 1)
  local n = tonumber(s)
  if not n then
    decode_error(str, i, "invalid number '" .. s .. "'")
  end
  return n, x
end


local function parse_literal(str: string, i: integer): boolean, integer
  local x = next_char(str, i, delim_chars)
  local word = str:sub(i, x - 1)
  if not literals[word] then
    decode_error(str, i, "invalid literal '" .. word .. "'")
  end
  return literal_map[word], x
end


local function parse_array(str:string, i:integer): {any}, integer
  local res = {}
  local n = 1
  i = i + 1
  while 1 do
    local x: table = {}
    i = next_char(str, i, space_chars, true)
    -- Empty / end of array?
    if str:sub(i, i) == "]" then
      i = i + 1
      break
    end
    -- Read token
    x, i = parse(str, i)
    res[n] = x
    n = n + 1
    -- Next token
    i = next_char(str, i, space_chars, true)
    local chr = str:sub(i, i)
    i = i + 1
    if chr == "]" then break end
    if chr ~= "," then decode_error(str, i, "expected ']' or ','") end
  end
  return res, i
end


local function parse_object(str:string, i:integer): table, integer
  local res = {}
  i = i + 1
  while 1 do
    local key: any
    local val: any
    i = next_char(str, i, space_chars, true)
    -- Empty / end of object?
    if str:sub(i, i) == "}" then
      i = i + 1
      break
    end
    -- Read key
    if str:sub(i, i) ~= '"' then
      decode_error(str, i, "expected string for key")
    end
    key, i = parse(str, i)
    -- Read ':' delimiter
    i = next_char(str, i, space_chars, true)
    if str:sub(i, i) ~= ":" then
      decode_error(str, i, "expected ':' after key")
    end
    i = next_char(str, i + 1, space_chars, true)
    -- Read value
    val, i = parse(str, i)
    -- Set
    res[key] = val
    -- Next token
    i = next_char(str, i, space_chars, true)
    local chr = str:sub(i, i)
    i = i + 1
    if chr == "}" then break end
    if chr ~= "," then decode_error(str, i, "expected '}' or ','") end
  end
  return res, i
end


local char_func_map: {string: function(string, integer): any, integer} = {
  [ '"' ] = parse_string,
  [ "0" ] = parse_number,
  [ "1" ] = parse_number,
  [ "2" ] = parse_number,
  [ "3" ] = parse_number,
  [ "4" ] = parse_number,
  [ "5" ] = parse_number,
  [ "6" ] = parse_number,
  [ "7" ] = parse_number,
  [ "8" ] = parse_number,
  [ "9" ] = parse_number,
  [ "-" ] = parse_number,
  [ "t" ] = parse_literal,
  [ "f" ] = parse_literal,
  [ "n" ] = parse_literal,
  [ "[" ] = parse_array,
  [ "{" ] = parse_object,
}

parse = function(str:string, idx:integer): table, integer
  local chr = str:sub(idx, idx)
  local f = char_func_map[chr]
  if f then
    local tbl, newIdx = f(str, idx)
    return tbl as table, newIdx
  end
  decode_error(str, idx, "unexpected character '" .. chr .. "'")
end

function json.decode(str: string): table
  if type(str) ~= "string" then
    error("expected argument of type string, got " .. type(str))
  end
  local res, idx = parse(str, next_char(str, 1, space_chars, true))
  idx = next_char(str, idx, space_chars, true)
  if idx <= #str then
    decode_error(str, idx, "trailing garbage")
  end
  return res
end

--[[---------------------------------------------------------------------------
This module provides a parser for working with FASTA formatted genetic
sequences.

FASTA is a flat text file format developed in 1985 to store nucleotide and
amino acid sequences. It is extremely simple and well-supported across many
languages.
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
                output[#output+1] = {identifier = identifier, sequence = sequence}
                identifier = ""
                sequence = ""
            end
        -- Process sequence lines
        elseif s ~= ">" and s ~= ";" then
            sequence = sequence .. line:gsub("%s+", "") -- Remove whitespace from sequence
        end
    end
    -- final output
    output[#output+1] = {identifier = identifier, sequence = sequence}
    return output
end

--[[---------------------------------------------------------------------------
This module provides a parser for working with FASTQ formatted sequencing
files.

FASTQ is a flat file format developed by the Wellcome Trust Sanger Institute in
~2000 to store sequencing data along with quality data.
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
                output[#output+1] = {identifier = identifier, sequence = sequence, quality = quality}
                identifier = ""
                sequence = ""
                quality = ""
            end
        -- Process sequence lines
        elseif s ~= "@" then
            if quality_next == true then
                quality = line
                quality_next = false
            else
                if s == "+" then
                    quality_next = true
                else
                    sequence = sequence .. line:gsub("%s+", "") -- Remove whitespace from sequence
                end
            end
        end
    end
    -- final output
    output[#output+1] = {identifier = identifier, sequence = sequence, quality = quality}
    return output
end

--[[---------------------------------------------------------------------------
This module provides functions for calculating primer melting temperatures.
--]]---------------------------------------------------------------------------
local record primers
	-- thermodynamics stores enthalpy (dH, kcal/mol) and entropy (dS, cal/mol-K) values for nucleotide pairs
	record thermodynamics
		h: number
		s: number
	end

	-- This section contains various penalties applied when calculating primer
	-- melting temperature using the SantaLucia algorithm.
	nearest_neighbors_thermodynamics: {string: thermodynamics} -- penalties for nearest neighbor effects
	initial_thermodynamic_penalty: thermodynamics -- penalty for initiating helix
	symmetry_thermodynamic_penalty: thermodynamics -- penalty for self-complementarity
	terminal_at_thermodynamic_penalty: thermodynamics -- penalty for 3' AT

	-- santa_lucia calculates the melting point of a short DNA sequence (15-200
	-- bp), using the Nearest Neighbors method 
	-- [SantaLucia, J. (1998) PNAS, doi:10.1073/pnas.95.4.1460]
	santa_lucia: function(string, number, number, number): number

	-- marmur_doty calculates the melting point of an extremely short DNA
	-- sequence (<15 bp) using a modified Marmur Doty formula 
	-- [Marmur J & Doty P (1962). Determination of the base composition of 
	-- deoxyribonucleic acid from its thermal denaturation temperature. J Mol Biol, 5, 109-118.]
	marmur_doty: function(string, number)

	-- melting_temp calls SantaLucia with default inputs for primer and salt
	-- concentration.
	melting_temp: function(string): number

  default_primer_concentration: number
  default_salt_concentration: number
  default_magnesium_concentration: number
end

primers.nearest_neighbors_thermodynamics = {
    AA = {h = -7.6, s = -21.3},
    TT = {h = -7.6, s = -21.3},
    AT = {h = -7.2, s = -20.4},
    TA = {h = -7.2, s = -21.3},
    CA = {h = -8.5, s = -22.7},
    TG = {h = -8.5, s = -22.7},
    GT = {h = -8.4, s = -22.4},
    AC = {h = -8.4, s = -22.4},
    CT = {h = -7.8, s = -21.0},
    AG = {h = -7.8, s = -21.0},
    GA = {h = -8.2, s = -22.2},
    TC = {h = -8.2, s = -22.2},
    CG = {h = -10.6, s = -27.2},
    GC = {h = -9.8, s = -24.4},
    GG = {h = -8.0, s = -19.9},
    CC = {h = -8.0, s = -19.9},
}
primers.initial_thermodynamic_penalty = {h = 0.2, s = -5.7}
primers.symmetry_thermodynamic_penalty = {h = 0, s = -1.4}
primers.terminal_at_thermodynamic_penalty = {h = 2.2, s = 6.9}

--- Returns the melting temperature of a primer given primer concentration, salt concentration, and magnesium concentration
-- @param sequence sequence of the primer
-- @param primer_concentration concentration of the primer
-- @param salt_concentration concentration of salt in buffer
-- @param magnesium_concentration concentration of magnesium in buffer
-- @return melting temperature
-- @usage local melting_temperature = primers.santa_lucia("CAGGAAACAGCTATGAC", 0.0000001, 0.350, 0)
function primers.santa_lucia(sequence: string, primer_concentration: number, salt_concentration: number, magnesium_concentration: number): number
	-- Initialize outputs
	local melting_temperature: number = 0
	local dH: number = 0
	local dS: number = 0

	sequence = sequence:upper()
    sequence = sequence:gsub("[^ATGC]", "")
	local gas_constant = 1.9872 -- gas constant (cal / mol - K)
	local symmetry_factor = 4

	-- apply initialization penalty
	dH = dH + primers.initial_thermodynamic_penalty.h
	dS = dS + primers.initial_thermodynamic_penalty.s
	-- apply symmetry penalty if sequence is self-complementary
	if sequence == complement.reverse_complement(sequence) then
		dH = dH + primers.symmetry_thermodynamic_penalty.h
		dS = dS + primers.symmetry_thermodynamic_penalty.s
		symmetry_factor = 1
	end
	-- apply penalty if 3' nucleotides are A or T
	if sequence:sub(-1,-1) == "A" or sequence:sub(-1,-1) == "T" then
		dH = dH + primers.terminal_at_thermodynamic_penalty.h
		dS = dS + primers.terminal_at_thermodynamic_penalty.s
	end
	-- apply salt penalty ; von Ahsen et al 1999
	local salt_effect = salt_concentration + (magnesium_concentration * 140)
	dS = dS + ((0.368 * (sequence:len() - 1)) * math.log(salt_effect))
	-- calculate penalty for nearest neighbor effects
	for i=1,sequence:len()-1,1 do
		local dT = primers.nearest_neighbors_thermodynamics[sequence:sub(i,i+1)]
		dH = dH + dT.h
		dS = dS + dT.s
	end

	melting_temperature = dH*1000/(dS+gas_constant*math.log(primer_concentration/symmetry_factor)) - 273.15
	return melting_temperature
end

--- Returns the melting temperature of an extremely short DNA sequence (<15bp)
-- @param sequence the primer sequence
-- @return melting temperature
-- @usage local melting_temperature = primers.marmur_doty("ACGTCCGGACTT")
function primers.marmur_doty(sequence: string): number
	sequence = sequence:upper()
	local _, a_count = sequence:gsub("A","")
	local _, t_count = sequence:gsub("T","")
	local _, g_count = sequence:gsub("G","")
	local _, c_count = sequence:gsub("C","")
	return 2*(a_count+t_count) + 4*(g_count+c_count) - 7.0
end

primers.default_primer_concentration = 0.000000500 -- 500e-9, 500 nM (nanomolar) primer concentration
primers.default_salt_concentration = 0.050 -- 50e-3, 50 mM (millimolar) sodium concentration
primers.default_magnesium_concentration = 0.0 -- 0 mM (millimolar) magnesium concentration

--- Returns the melting temperature using Santa Lucia with reasonable defaults
-- @param sequence the primer sequence
-- @return melting temperature
-- @usage local melting_temperature = primers.melting_temp("ACGTCCGGACTT")
function primers.melting_temp(sequence: string): number
	return primers.santa_lucia(sequence, primers.default_primer_concentration, primers.default_salt_concentration, primers.default_magnesium_concentration)
end
--[[---------------------------------------------------------------------------
The pcr module provides functions for simulating and designing PCR reactions.

The polymerase chain reaction (PCR) is a method to produce billions of copies
of a particular piece of DNA. Invented in 1983, it has become one of the most
widely used biotechnological procedures, used in everything from genetic
engineering to cancer testing to COVID diagnostics.

Conceputally, PCR involves 3 major components: polymerase, a template, and
primers. Polymerase (in particular, DNA polymerase) is an enzyme that
replicates DNA in living cells. The template is a target DNA to be amplified,
and there only needs to be a tiny amount of template to amplify billions of
copies with PCR. The primers are small (~20-60bp) single-stranded DNA templates
that complement to two spots of the template DNA, selecting the segment of
template that needs to be amplified.

primer forward:    ->
primer reverse:          <-
template      : ================= (>1 copy)
result        :    ========       (>1,000,000,000 copies)

PCR cycles between a few different temperatures to accomplish amplification.
One of these is the annealing step, where primers bind to the template
template. The temperature at this particular step is dependent on the template
of the primers (as well as buffer conditions), and this is extremely important
in ensuring the specificity and efficiency of the PCR reaction. Designing and
simulating PCR reactions have to take this into account.

Wikipedia has a more detailed entry on PCR:
https://en.wikipedia.org/wiki/Polymerase_chain_reaction
]]-----------------------------------------------------------------------------

local record pcr
  minimal_primer_length: integer
  design_primers_with_overhang: function(string, string, string, number): string, string
  design_primers: function(string, number): string, string
  record Template
    sequence: string
    circular: boolean
  end
  record Options
    primer_concentration: number
    salt_concentration: number
    magnesium_concentration: number
  end
  simulate_simple: function({Template}, {string}, number): {string}
  simulate: function({Template}, {string}, number): {string}
end

--- pcr.minimal_primer_length is a reasonable default for primer lengths.
pcr.minimal_primer_length = 12

--- pcr.design_primers_with_overhang designs PCR primers containing overhangs
-- on either side. These overhangs are important when designing PCRs whose
-- products are intended to be used in downstream applications, like DNA
-- assembly.
function pcr.design_primers_with_overhang(template: string, forward_overhang: string, reverse_overhang: string, target_tm: number, options: pcr.Options): string, string
  template = template:upper()

  -- If options are nil, fill default options
  if options == nil then
    options = {}
    options.primer_concentration = primers.default_primer_concentration
    options.salt_concentration = primers.default_salt_concentration
    options.magnesium_concentration = primers.default_magnesium_concentration
  end

  -- for both forward and reverse primers.
  local additional_nucleotides: integer = 1
  local forward_primer = template:sub(1, pcr.minimal_primer_length)
  while primers.santa_lucia(forward_primer, options.primer_concentration, options.salt_concentration, options.magnesium_concentration) < target_tm do
    forward_primer = template:sub(1, pcr.minimal_primer_length + additional_nucleotides)
    additional_nucleotides = additional_nucleotides + 1
  end
  additional_nucleotides = 1
  local reverse_primer = complement.reverse_complement(template:sub(#template - pcr.minimal_primer_length, -1))
  while primers.santa_lucia(reverse_primer, options.primer_concentration, options.salt_concentration, options.magnesium_concentration) < target_tm do
    reverse_primer = complement.reverse_complement(template:sub(#template - (pcr.minimal_primer_length + additional_nucleotides), -1))
    additional_nucleotides = additional_nucleotides + 1
  end

  -- Add overhangs to primer
  forward_primer = forward_overhang .. forward_primer
  reverse_primer = complement.reverse_complement(reverse_overhang) .. reverse_primer
  return forward_primer, reverse_primer
end

--- pcr.design_primers designs PCR primers without overhangs. Primers like
-- these are often used in diagnostic or testing settings where the output
-- of the PCR needs to be analyzed, but not used for downstream reactions.
function pcr.design_primers(template: string, target_tm: number, options: pcr.Options): string, string
  return pcr.design_primers_with_overhang(template, "", "", target_tm, options)
end

--- pcr.simulate_simple simulates a single step in a PCR reaction. Whenever
-- possible, pcr.simulate should be used, as it will detect concatemerization
-- and other potential problems with a given PCR.
function pcr.simulate_simple(templates: {pcr.Template}, primer_list: {string}, target_tm: number, options: pcr.Options): {string}
  -- If options are nil, fill default options
  if options == nil then
    options = {}
    options.primer_concentration = primers.default_primer_concentration
    options.salt_concentration = primers.default_salt_concentration
    options.magnesium_concentration = primers.default_magnesium_concentration
  end

  -- Set primers to uppercase and get minimally sized primers
  local minimal_primer_binds: {string} = {}
  local additional_nucleotides: integer
  for idx=1,#primer_list do
    additional_nucleotides = 1
    primer_list[idx] = primer_list[idx]:upper()
    local minimal_primer: string = primer_list[idx]:sub(#primer_list[idx] - pcr.minimal_primer_length, -1)
    local found_minimal_primer: boolean = true
    while primers.santa_lucia(minimal_primer, options.primer_concentration, options.salt_concentration, options.magnesium_concentration) < target_tm do
      local base_idx = #primer_list[idx] - (pcr.minimal_primer_length + additional_nucleotides)
      if base_idx == 0 then
        found_minimal_primer = false
        break
      end
      minimal_primer = primer_list[idx]:sub(base_idx, -1)
      additional_nucleotides = additional_nucleotides + 1
    end
    if found_minimal_primer then
      minimal_primer_binds[idx] = minimal_primer
    else
      minimal_primer_binds[idx] = ""
    end
  end
  
  -- Add generate_pcr_fragments function. Once the heavy lifting of finding
  -- primer binding locations is completed, this function takes over. It only
  -- at those particular indexes. This integer data is used to generate a
  -- series of new PCR fragments.
  local function generate_pcr_fragments(s: string, f: integer, r: integer, forward_primer_indexes: {integer}, reverse_primer_indexes: {integer}): {string}
    local gen_pcr_fragments: {string} = {}
    for _, forward_primer_index in ipairs(forward_primer_indexes) do
      local minimal_primer = minimal_primer_binds[forward_primer_index]
      local full_primer_forward = primer_list[forward_primer_index]
      for _, reverse_primer_index in ipairs(reverse_primer_indexes) do
        local full_primer_reverse = complement.reverse_complement(primer_list[reverse_primer_index])
        local pcr_fragment: string = full_primer_forward:sub(1, #full_primer_forward - #minimal_primer) .. s:sub(f,r) .. full_primer_reverse
        gen_pcr_fragments[#gen_pcr_fragments+1] = pcr_fragment
      end
    end
    return gen_pcr_fragments
  end

  -- Add output pcr_fragments
  local pcr_fragments: {string} = {}

  -- Simulate generation of fragments with every template in this PCR reaction.
  for _, template_record in ipairs(templates) do
    local template = template_record.sequence:upper()
    -- If the template is circular, append it to itself to simulate circularity
    if template_record.circular then
      template = template .. template
    end

    -- First, find the binding sites for each primer
    local forward_locations: {integer: {integer}} = {{}}
    local reverse_locations: {integer: {integer}} = {{}}
    for minimal_primer_idx, minimal_primer in ipairs(minimal_primer_binds) do
      if minimal_primer == "" then break end
      -- Forward locations
      local search_after: integer = 1
      while true do
        local match_start = string.find(template, minimal_primer, search_after, true)
        if match_start == nil then break end
        if forward_locations[minimal_primer_idx] == nil then 
          forward_locations[minimal_primer_idx] = {match_start}
        else
          forward_locations[minimal_primer_idx][#forward_locations[minimal_primer_idx]+1] = match_start
        end
        search_after = match_start + 1
      end
      -- Reverse locations
      search_after = 1
      while true do
        local match_start = string.find(template, complement.reverse_complement(minimal_primer), search_after, true)
        if match_start == nil then break end
        if reverse_locations[minimal_primer_idx] == nil then reverse_locations[minimal_primer_idx] = {} end
        reverse_locations[minimal_primer_idx][#reverse_locations[minimal_primer_idx]+1] = match_start
        search_after = match_start + 1
      end
    end

    -- We are going to create 2 new tables, essentially inverting forward_locations and reverse_locations, binding locations to different primers
    -- We are also going to create a new array that can be sorted for each of those individual values
    local forward_locations_inverted: {integer: {integer}} = {}
    local forward_locations_indexes: {integer} = {}
    local reverse_locations_inverted: {integer: {integer}} = {}
    local reverse_locations_indexes: {integer} = {}
    for idx, values in pairs(forward_locations) do
      for _, value in ipairs(values) do
        if forward_locations_inverted[value] == nil then forward_locations_inverted[value] = {} end
        forward_locations_inverted[value][#forward_locations_inverted[value]+1] = idx
        forward_locations_indexes[#forward_locations_indexes+1] = value
      end
    end
    for idx, values in pairs(reverse_locations) do
      for _, value in ipairs(values) do
        if reverse_locations_inverted[value] == nil then reverse_locations_inverted[value] = {} end
        reverse_locations_inverted[value][#reverse_locations_inverted[value]+1] = idx
        reverse_locations_indexes[#reverse_locations_indexes+1] = value
      end
    end
    -- Sort both forward_locations_indexes and reverse_locations_indexes
    table.sort(forward_locations_indexes)
    table.sort(reverse_locations_indexes)

    for idx, forward_match_start in ipairs(forward_locations_indexes) do
      -- Check that this isn't the last element in forward_locations_indexes
      if forward_locations_indexes[idx+1] ~= nil then
        -- If this isn't the last element in forward_locations_indexes, then we can select the first reverse_location_index that is less than the next forward_locations_index
        for _, reverse_match_start in ipairs(reverse_locations_indexes) do
          if (forward_match_start < reverse_match_start) and (reverse_match_start < forward_locations_indexes[idx+1]) then
            for _, fragment in ipairs(generate_pcr_fragments(template, forward_match_start, reverse_match_start, forward_locations_inverted[forward_match_start], reverse_locations_inverted[reverse_match_start])) do
              pcr_fragments[#pcr_fragments+1] = fragment
            end
              for _, fragment in ipairs(generate_pcr_fragments(template, forward_match_start, reverse_match_start, forward_locations_inverted[forward_match_start], reverse_locations_inverted[  reverse_match_start])) do
                pcr_fragments[#pcr_fragments+1] = fragment
              end
            break
          end
        end
      else
        local found_fragment: boolean = false
        for _, reverse_match_start in ipairs(reverse_locations_indexes) do
          if forward_match_start < reverse_match_start then
            for _, fragment in ipairs(generate_pcr_fragments(template, forward_match_start, reverse_match_start, forward_locations_inverted[forward_match_start], reverse_locations_inverted[  reverse_match_start])) do
              pcr_fragments[#pcr_fragments+1] = fragment
            end
            found_fragment = true
          end
        end
      end
    end
  end

  -- Only return unique fragments
  local fragment_set: {string: boolean} = {}
  for _, fragment in ipairs(pcr_fragments) do
    fragment_set[fragment] = true
  end
  pcr_fragments = {}
  for fragment, _ in pairs(fragment_set) do
    pcr_fragments[#pcr_fragments+1] = fragment
  end
  return pcr_fragments
end

--- pcr.simulate simulates a PCR reaction. It takes in a list of templates as
-- well as a list of primers and computes all combinations of outputs. In
-- typical usage, there will be a single template and a two primers.
-- Concatemerization and zero amplicons are both returned as errors from this
-- function. 
function pcr.simulate(templates: {pcr.Template}, primer_list: {string}, target_tm: number, options: pcr.Options): {string}
  local initial_amplification = pcr.simulate_simple(templates, primer_list, target_tm, options)
  -- Check for >0 amplicons
  if #initial_amplification == 0 then error("no amplicons") end
  for _, fragment in ipairs(initial_amplification) do
    primer_list[#primer_list+1] = fragment
  end
  -- Check for concatemerization
  local subsequent_amplification = pcr.simulate_simple(templates, primer_list, target_tm, options)
  if #initial_amplification ~= #subsequent_amplification then error("concatemerization detected in PCR.") end
  return initial_amplification
end

--[[---------------------------------------------------------------------------
This module provides a parser for working with GenBank formatted genetic
sequences.

GenBank is a flat text file format developed in the 1980s to annotate genetic
sequences, and has since become the standard for sharing annotated genetic
sequences.
--]]---------------------------------------------------------------------------

local record genbank
    record Locus
        name: string
        molecule_type: string
        genbank_division: string
        modification_date: string
        sequence_coding: string
        circular: boolean
    end
    record Reference
        authors: string
        title: string
        journal: string
        pubmed: string
        remark: string
        range: string
    end
    record Meta
        date: string
        definition: string
        accession: string
        version: string
        keywords: string
        organism: string
        source: string
        taxonomy: {string}
        origin: string
        locus: Locus
        references: {Reference}
        other: {string:string}
        name: string
    end
    record Location
        location_start: number -- integer
        location_end: number -- integer
        complement: boolean
        join: boolean
        five_prime_partial: boolean
        three_prime_partial: boolean
        sub_locations: {Location}
    end
    record Feature
        feature_type: string
        description: string
        attributes: {string:string}
        gbk_location_string: string
        location: Location
        sequence: function(Genbank): string
    end
    record Genbank
        meta: Meta
        features: {Feature}
        sequence: string
    end
    GENBANK_MOLECULE_TYPES: {string}
    GENBANK_DIVISIONS: {string}

    from_json: function(string): Genbank
    to_json: function(Genbank): string
end

--- Genbank molecule types; mirrors poly's genbank parser.
-- @table genbank.GENBANK_MOLECULE_TYPES
genbank.GENBANK_MOLECULE_TYPES = {
        "DNA",
        "genomic DNA",
        "genomic RNA",
        "mRNA",
        "tRNA",
        "rRNA",
        "other RNA",
        "other DNA",
        "transcribed RNA",
        "viral cRNA",
        "unassigned DNA",
        "unassigned RNA",
}

--- Genbank divisions; mirrors poly's genbank parser.
-- @table genbank.GENBANK_DIVISIONS
genbank.GENBANK_DIVISIONS = {
        "PRI", --primate sequences
        "ROD", --rodent sequences
        "MAM", --other mamallian sequences
        "VRT", --other vertebrate sequences
        "INV", --invertebrate sequences
        "PLN", --plant, fungal, and algal sequences
        "BCT", --bacterial sequences
        "VRL", --viral sequences
        "PHG", --bacteriophage sequences
        "SYN", --synthetic sequences
        "UNA", --unannotated sequences
        "EST", --EST sequences (expressed sequence tags)
        "PAT", --patent sequences
        "STS", --STS sequences (sequence tagged sites)
        "GSS", --GSS sequences (genome survey sequences)
        "HTG", --HTG sequences (high-throughput genomic sequences)
        "HTC", --unfinished high-throughput cDNA sequencing
        "ENV", --environmental sampling sequences
}

--- Parses a given genbank string into a list of genbank tables
-- @param input the input genbank string
-- @return a list of genbank tables
-- @usage local plasmids = genbank.parse(plasmids_gbk_string)
function genbank.parse(input: string): {genbank.Genbank}
    -- Start helper functions
    local function trim(s: string): string -- from PiL2 20.4
        return (s:gsub("^%s*(.-)%s*$", "%1"))
    end
    
    local function split(s: string, sep: any): {string}
        if sep == nil then
            sep = "[^%s]+"
        end
        local l: {string} = {}
        for token in s:gmatch(sep as string) do
            l[#l+1] = token
        end
        return l
    end
    
    local function deepcopy(obj:any): any
        if type(obj) ~= 'table' then return obj end
        local obj_table: {any:any} = obj as {any:any}
        local res = setmetatable({} as {any:any}, getmetatable(obj as {any:any}))
        for k, v in pairs(obj_table) do res[deepcopy(k)] = deepcopy(v) end
        return res
    end

    local function count_leading_spaces(line: string): integer
        local i: integer = 0
        for idx = 1, #line do
            if line:sub(idx,idx) == " " then
                i = i + 1
            else
                return i
            end
        end
    end
    
    local function parse_locus(locus_string: string): genbank.Locus
        local locus = genbank.Locus
    
        local locus_split = split(trim(locus_string))
        local filtered_locus_split: {string} = {}
        for i, _ in ipairs(locus_split) do
            if locus_split[i] ~= "" then
                filtered_locus_split[#filtered_locus_split+1] = locus_split[i]
            end
    
        end
        locus.name = filtered_locus_split[2]
    
        -- We do not trust the locus sequence length, so it is not included.

        -- get molecule type
        for _, genbank_molecule in ipairs(genbank.GENBANK_MOLECULE_TYPES) do
            if locus_string:find(genbank_molecule) then
                locus.molecule_type = genbank_molecule
            end
        end

        -- circularity flag
        locus.circular = false
        if locus_string:find("circular") then
            locus.circular = true
        end

        -- genbank division
        for _, genbank_division in ipairs(genbank.GENBANK_DIVISIONS) do
            for i, locus_split_without_start in ipairs(locus_split) do
                if i > 2 then
                    if locus_split_without_start:find(genbank_division) then
                        locus.genbank_division = genbank_division
                    end
                end
            end
        end

        -- modification date
        local start_date, end_date = locus_string:find("%d%d.%a%a%a.%d%d%d%d")
        locus.modification_date = locus_string:sub(start_date, end_date)

        return locus
    end
    
    local function parse_metadata(metadata: {string}): string
        local output_metadata: string = ""
        if metadata == nil then
            return "."
        end
        if #metadata == 0 then
            return "."
        end
        for _, data in ipairs(metadata) do
            output_metadata = output_metadata .. trim(data) .. " "
        end
        output_metadata = output_metadata:sub(1,#output_metadata-1) -- Remove trailing metadata
        return output_metadata
    end
    
    local function parse_references(metadata_data: {string}): genbank.Reference
        local function add_key(reference: genbank.Reference, reference_key: string, reference_value: string): nil
            -- TODO improve seed using table lookup
            if reference_key == "AUTHORS" then
                reference.authors = reference_value
            elseif reference_key == "TITLE" then
                reference.title = reference_value
            elseif reference_key == "JOURNAL" then
                reference.journal = reference_value
            elseif reference_key == "PUBMED" then
                reference.pubmed = reference_value
            elseif reference_key == "REMARK" then
                reference.remark = reference_value
            else
                error("Reference_key not in  [AUTHORS, TITLE, JOURNAL, PUBMED, REMARK]. Got: " .. reference_key)
            end
        end
        local reference: genbank.Reference = {}
        if #metadata_data == 1 then
            error("Got reference with no additional information")
        end

        local range_index = metadata_data[1]:find("%(") -- Need to escape " https://stackoverflow.com/questions/9790688/escaping-strings-for-gsub
        if range_index ~= nil then
            reference.range = metadata_data[1]:sub(range_index,-1)
        end

        local reference_key = split(trim(metadata_data[2]))[1]
        local reference_value = trim(metadata_data[2]:sub(reference_key:len()+3,-1))

        -- Significant amount of magic numbers here. See poly reference.
        for index=3,#metadata_data do
            if metadata_data[index]:sub(4,4) ~= " " then
                add_key(reference, reference_key, reference_value)
                reference_key = trim(split(trim(metadata_data[index]))[1])
                reference_value = trim(metadata_data[index]:sub(reference_key:len()+3,-1))
            else
                reference_value = reference_value .. " " .. trim(metadata_data[index])
            end
        end
        add_key(reference, reference_key, reference_value)
        return reference
    end

    local function get_source_organism(metadata_data: {string}): string, string, {string}
        local source:string = trim(metadata_data[1])
        local organism:string = ""
        local taxonomy:{string} = {}

        local data_line: string
        for iterator=2,#metadata_data do
            data_line = metadata_data[iterator]
            local head_string = split(trim(data_line))[1]
            if head_string == "ORGANISM" then
                local _, index = data_line:find("ORGANISM")
                organism = trim(data_line:sub(index+1,-1))
            else
                for _, taxonomy_data in ipairs(split(trim(data_line), "[^;]+")) do
                    local taxonomy_data_trimmed = trim(taxonomy_data)
                    -- Taxonomy ends with a ".", which we check for here
                    if taxonomy_data_trimmed:len() > 1 then
                        if taxonomy_data_trimmed:sub(-1,-1) == "." then
                            taxonomy_data_trimmed = taxonomy_data_trimmed:sub(1, -2)
                        end
                        taxonomy[#taxonomy+1] = taxonomy_data_trimmed
                    end
                end
            end
        end
        return source, organism, taxonomy
    end

    local function parse_location(s: string): genbank.Location
        local location: genbank.Location = {}
		location.sub_locations = {}
        if not s:find("%(") then
            if not s:find("%.") then
                local position = tonumber(s)
                location.location_start = position
                location.location_end = position
            else
                -- to remove FivePrimePartial and ThreePrimePartial indicators from start and end before converting to int.
                local start_end_split = split(s, "[^%.]+")
                location.location_start = tonumber(start_end_split[1])
                location.location_end = tonumber(start_end_split[2])
            end
        else
            local first_outer_parentheses = s:find("%(")
			local last_outer_parentheses = s:find("%)")
	    	local expression = s:sub(first_outer_parentheses+1, last_outer_parentheses-1)
	    	local command = s:sub(1, first_outer_parentheses-1)
	    	if command == "join" then
			    location.join = true
			    -- This case checks for join(complement(x..x),complement(x..x)), or any more complicated derivatives
			    if expression:find("%(") then
				    local first_inner_parentheses = expression:find("%(")
				    local parentheses_count = 1
				    local comma = 0
				    local i = 2
				    while(parentheses_count > 0) do
					    comma = i
					    if expression:sub(first_inner_parentheses + i) == "(" then parentheses_count = parentheses_count + 1 end
					    if expression:sub(first_inner_parentheses + i) == ")" then parentheses_count = parentheses_count - 1 end
					    i = i + 1
				    end
				    local parse_left_location = parse_location(expression:sub(1, first_inner_parentheses+comma+1))
				    local parse_right_location = parse_location(expression:sub(2+first_inner_parentheses+comma, -1))
				    location.sub_locations[#location.sub_locations+1] = parse_left_location
				    location.sub_locations[#location.sub_locations+1] = parse_right_location
			    else -- This is the default join(x..x,x..x)
					for _, number_range in ipairs(split(expression, "[^,]+")) do
						local join_location = parse_location(number_range)
						location.sub_locations[#location.sub_locations+1] = join_location
					end
			    end
	    	end

			if command == "complement" then
				local sub_location = parse_location(expression)
				sub_location.complement = true
				location.sub_locations[#location.sub_locations+1] = sub_location
        	end
		end

		if s:find("%<") then
			location.five_prime_partial = true
		end
		if s:find("%>") then
			location.three_prime_partial = true
		end

		-- if excess root node then trim node. Maybe should just be handled with second arg?
		if location.location_start == 0 and location.location_end and not location.join and not location.complement then
			location = location.sub_locations[1]
		end
		return location
    end

    local record ParseParameters
        new_location: boolean
        quote_active: boolean
        attribute: string
        attribute_value: string
        parse_step: string
        genbank: genbank.Genbank
        feature: genbank.Feature
        features: {genbank.Feature}
        metadata_tag: string
        metadata_data: {string}
        genbank_started: boolean
        current_line: string
        previous_line: string
        multi_line_feature: boolean
    end
    local function params_init(): ParseParameters
        local params: ParseParameters = {}
        params.new_location = true
        params.parse_step = "metadata"
        params.metadata_tag = ""
        params.genbank = genbank.Genbank
        params.genbank_started = false

        -- Init features
        params.attribute_value = ""
        params.feature = genbank.Feature
        params.feature.attributes = {}
        params.features = {}

        -- Init Genbank
        params.genbank = genbank.Genbank
        params.genbank.meta = genbank.Meta
        params.genbank.meta.locus = genbank.Locus
        params.genbank.meta.other = {}
        params.genbank.meta.references = {}
        params.genbank.features = {}
        params.genbank.sequence = ""
        return params
    end
    local params: ParseParameters = params_init()

    -- Setup basic parse parameters
    local genbanks: {genbank.Genbank} = {}
    local copied_feature: genbank.Feature = {}
    local copied_genbank: genbank.Genbank = {}
    local i: integer = 0
    local continue: boolean = false

    -- Iterate line by line
    for line in string.gmatch(input,'[^\r\n]+') do
        local split_line: {string} = split(trim(line))

        local previous_line: string = params.current_line
        params.current_line = line
        params.previous_line = previous_line

        -- keep scanning until we find start of first record
        if not params.genbank_started then
            if line:find("LOCUS") then
                params = params_init()
                params.genbank.meta.locus = parse_locus(line)
                params.genbank_started = true
            end
            continue = true
        end

        -- Parse metadata
        if params.parse_step == "metadata" and not continue then
            -- Handle empty lines
            if line:len() == 0 then
                error("Empty metadata line on " .. i)
            end

            -- If we are currently reading a line, figure out if it is a new meta line.
            if line:sub(1,1) ~= " " or params.metadata_tag == "FEATURES" then
                -- TODO: The following code can be made far more efficient: http://lua-users.org/wiki/SwitchStatement
                if params.metadata_tag == "DEFINITION" then
                    params.genbank.meta.definition = parse_metadata(params.metadata_data)
                elseif params.metadata_tag == "ACCESSION" then
                    params.genbank.meta.accession = parse_metadata(params.metadata_data)
                elseif params.metadata_tag == "VERSION" then
                    params.genbank.meta.version = parse_metadata(params.metadata_data)
                elseif params.metadata_tag == "KEYWORDS" then
                    params.genbank.meta.keywords = parse_metadata(params.metadata_data)
                elseif params.metadata_tag == "SOURCE" then
                    params.genbank.meta.source, params.genbank.meta.organism, params.genbank.meta.taxonomy = get_source_organism(params.metadata_data)
                elseif params.metadata_tag == "REFERENCE" then
                    params.genbank.meta.references[#params.genbank.meta.references+1] = parse_references(params.metadata_data)
                elseif params.metadata_tag == "FEATURES" then
                    params.parse_step = "features"

                    -- We know we are now parsing features, so lets initialize our first feature
                    params.feature.feature_type = trim(split_line[1])
                    params.feature.gbk_location_string = trim(split_line[#split_line])
                    params.new_location = true
                    continue = true
                else
                    if not continue then
                        if params.metadata_tag ~= "" then
                            params.genbank.meta.other[params.metadata_tag] = parse_metadata(params.metadata_data)
                        end
                    end
                end
                if not continue then
                    params.metadata_tag = trim(split_line[1])
                    params.metadata_data = {trim(line:sub(params.metadata_tag:len()+1))}
                end
            else
                params.metadata_data[#params.metadata_data+1] = line
            end
        end

        -- Parse features
        if params.parse_step == "features" and not continue then
            local trimmed_line: string
            -- Switch to sequence parsing
            if line:find("ORIGIN") then
                params.parse_step = "sequence"
                
                -- save our completed attribute / qualifier string to the current feature
                if params.attribute_value ~= nil then
                    params.feature.attributes[params.attribute] = params.attribute_value
                    copied_feature = deepcopy(params.feature) as genbank.Feature
                    params.features[#params.features+1] = copied_feature
                    params.attribute_value = ""
                    params.attribute = ""
                    params.feature = genbank.Feature
                else
                    copied_feature = deepcopy(params.feature) as genbank.Feature
                    params.features[#params.features+1] = copied_feature
                end

                -- add our features to genbank
                for _, feature in ipairs(params.features) do
					feature.location = parse_location(feature.gbk_location_string) 
                    params.genbank.features[#params.genbank.features+1] = feature
                end
                continue = true
            else
                -- check if current line contains anything but whitespace
                trimmed_line = trim(line)
                if trimmed_line:len() < 1 then
                    continue = true
                end
            end -- end sequence parsing logic

            if not continue then
                -- determine if current line is a new top level feature
                if count_leading_spaces(params.current_line) < count_leading_spaces(params.previous_line) or params.previous_line == "FEATURES" then
                    -- save our completed attribute / qualifier to the current feature
                    if params.attribute_value ~= "" then
                        params.feature.attributes[params.attribute] = params.attribute_value
                        copied_feature = deepcopy(params.feature) as genbank.Feature
                        params.features[#params.features+1] = copied_feature 
                        params.attribute_value = ""
                        params.attribute = ""
                        params.feature = {} 
                        params.feature.attributes = {}
                    end

                    -- check for empty types
                    if params.feature.feature_type ~= nil then
                        copied_feature = deepcopy(params.feature) as genbank.Feature
                        params.features[#params.features+1] = copied_feature
                        params.feature = {}
                        params.feature.attributes = {}
                    end

                    -- An initial feature line looks like this: `source          1..2686` with a type separated by its location
                    if #split_line < 2 then
                        error("Feature line malformed on line " .. i .. " . Got line: " .. line)
                    end
                    params.feature.feature_type = trim(split_line[1])
                    params.feature.gbk_location_string = trim(split_line[#split_line])
                    params.multi_line_feature = false -- without this we can't tell if something is a multiline feature or multiline qualifier

                elseif not params.current_line:find("/") then -- current line is continuation of a feature or qualifier (sub-constituent of a feature)
                    -- if it's a continuation of the current feature, add it to the location
                    if not params.current_line:find("\"") and (count_leading_spaces(params.current_line) > count_leading_spaces(params.previous_line) or params.multi_line_feature) then
                        params.feature.gbk_location_string = params.feature.gbk_location_string .. trim(line)
                        params.multi_line_feature = true -- without this we can't tell if something is a multiline feature or multiline qualifier
                    else
                        local remove_attribute_value_quotes = trimmed_line:gsub("\"", "")
                        params.attribute_value = params.attribute_value .. remove_attribute_value_quotes
                    end
                elseif params.current_line:find("/") then
                    if params.attribute_value ~= "" then
                        params.feature.attributes[params.attribute] = params.attribute_value
                    end
                    params.attribute_value = ""
                    local split_attribute = split(line, "[^=]+")
                    local trimmed_space_attribute = trim(split_attribute[1])
                    local removed_forward_slash_attribute = trimmed_space_attribute:gsub("/", "")

                    params.attribute = removed_forward_slash_attribute
                    params.attribute_value = split_attribute[2]:gsub("\"", "")

                    params.multi_line_feature = false
                end
            end
        end

        -- Parse sequence
        if params.parse_step == "sequence" and not continue then
            if #line < 2 then
                error("Too short line found while parsing genbank sequence on line " .. i .. ". Got line: " .. line)
            elseif line:sub(1,3) == "//" then
                copied_genbank = deepcopy(params.genbank) as genbank.Genbank
                genbanks[#genbanks+1] = copied_genbank
                params.genbank_started = false
                params.genbank.sequence = ""
            else
                params.genbank.sequence = params.genbank.sequence .. line:gsub("[0-9]-[%s+]","")
            end
        end
        continue = false
        i = i + 1
    end
    return genbanks
end

function genbank.feature_sequence(self: genbank.Feature, parent: genbank.Genbank): string
	local function get_location(location: genbank.Location, sequence: string): string
		local seq = ""
		if #location.sub_locations == 0 then
			seq = sequence:sub(location.location_start, location.location_end):upper()
		else
			for _, sub_location in ipairs(location.sub_locations) do
				seq = seq .. get_location(sub_location, sequence)
			end
		end
		if location.complement then
			seq = complement.reverse_complement(seq)
		end
		return seq
	end
	return get_location(self.location, parent.sequence)
end

--[[---------------------------------------------------------------------------

--                          JSON

---------------------------------------------------------------------------]]--

function genbank.from_json(str: string): genbank.Genbank
    return json.decode(str) as genbank.Genbank
end

function genbank.to_json(self: genbank.Genbank): string
    return json.encode(self)
end

--[[---------------------------------------------------------------------------
The fragment module optimally fragments DNA for GoldenGate systems.

Optimal fragmentation is accomplished by using empirical fidelity data derived
by NEB in the paper "Comprehensive Profiling of Four Base Overhang Ligation
Fidelity by T4 DNA Ligase and Application to DNA Assembly". We use the data
associated with T4 ligase @ 37c for 1hr.
Paper link: https://doi.org/10.1021/acssynbio.8b00333
--]]---------------------------------------------------------------------------
local record fragment
  overhang_efficiency: function(string, string): number
  set_efficiency: function({string}): number
  next_overhangs: function({string}): {string}, {number}
  next_overhang: function({string}): string
  fragmentation_table: {string: integer}
  fragment_sequence: function(string, integer, integer): {string}, number
end


fragment.fragmentation_table = {["AAAATTTT"]=187,["AAAATTAT"]=1,["AAACTTTT"]=1,["AAACGTTT"]=2888,["AAACGGTT"]=2,["AAACGTGT"]=1,["AAACGTAT"]=3,["AAACGTTG"]=15,["AAACGTTC"]=5,["AAACGTTA"]=4,["AAAGTTTT"]=3,["AAAGCTTT"]=1678,["AAAGATTT"]=1,["AAAGTCTT"]=2,["AAAGCTGT"]=1,["AAAGCCGT"]=1,["AAAGCTCT"]=1,["AAAGCTTG"]=8,["AAAGCTTC"]=7,["AAAGCTTA"]=3,["AAATTTTT"]=5,["AAATGTTT"]=46,["AAATATTT"]=1111,["AAATAATT"]=1,["AAATATGT"]=1,["AAATATAT"]=1,["AAATATTG"]=1,["AAATGTTC"]=1,["AAATATTC"]=1,["AACATGTT"]=1476,["AACAGGTT"]=2,["AACAAGTT"]=1,["AACATGGT"]=1,["AACATGCT"]=1,["AACATGAT"]=2,["AACATGTG"]=1,["AACATGTC"]=1,["AACCGTTT"]=3,["AACCGGTT"]=4307,["AACCCGTT"]=1,["AACCGATT"]=5,["AACCGTGT"]=1,["AACCGGGT"]=7,["AACCGGCT"]=2,["AACCGGAT"]=2,["AACCGGTG"]=8,["AACCGGTC"]=10,["AACCGGAC"]=1,["AACGCTTT"]=3,["AACGTGTT"]=108,["AACGCGTT"]=3372,["AACGAGTT"]=1,["AACGGCTT"]=1,["AACGCATT"]=6,["AACGTGGT"]=1,["AACGCGGT"]=6,["AACGCGCT"]=3,["AACGCGAT"]=1,["AACGCGTG"]=14,["AACGCGTC"]=19,["AACGCGTA"]=5,["AACTTGTT"]=29,["AACTGGTT"]=60,["AACTAGTT"]=2375,["AACTACTT"]=1,["AACTAGGT"]=2,["AACTTGAT"]=1,["AACTAGAT"]=4,["AACTGGTG"]=2,["AACTAGTG"]=4,["AACTAGTC"]=2,["AACTAGTA"]=3,["AAGATCTT"]=405,["AAGACCTT"]=1,["AAGATCCT"]=1,["AAGATCAT"]=1,["AAGCGTTT"]=5,["AAGCGGTT"]=9,["AAGCTCTT"]=1,["AAGCGCTT"]=3586,["AAGCACTT"]=1,["AAGCGATT"]=2,["AAGCGCGT"]=1,["AAGCGGCT"]=1,["AAGCGCCT"]=1,["AAGCGCAT"]=2,["AAGCGGTG"]=1,["AAGCGCTG"]=9,["AAGCGCGG"]=2,["AAGCGAGG"]=1,["AAGCGGTC"]=1,["AAGCGCTC"]=4,["AAGCGCTA"]=2,["AAGCGCGA"]=2,["AAGGCTTT"]=2,["AAGGCGTT"]=1,["AAGGTCTT"]=31,["AAGGCCTT"]=2773,["AAGGACTT"]=2,["AAGGCCGT"]=3,["AAGGCCCT"]=2,["AAGGCTTG"]=1,["AAGGCCTG"]=7,["AAGGCCTC"]=5,["AAGGCCTA"]=2,["AAGGCCGA"]=1,["AAGGCCAA"]=1,["AAGTGTTT"]=1,["AAGTAGTT"]=3,["AAGTTCTT"]=3,["AAGTGCTT"]=53,["AAGTACTT"]=1189,["AAGTAATT"]=1,["AAGTACTG"]=1,["AAGTACTC"]=1,["AATATTTT"]=2,["AATATCTT"]=1,["AATATATT"]=312,["AATCGTTT"]=3,["AATCGGTT"]=12,["AATCGCTT"]=5,["AATCGATT"]=2504,["AATCGAGT"]=1,["AATCGTAT"]=1,["AATCGGAT"]=1,["AATCGATG"]=5,["AATCGATC"]=7,["AATCGATA"]=2,["AATGCTTT"]=5,["AATGCGTT"]=2,["AATGCCTT"]=2,["AATGTATT"]=14,["AATGGATT"]=1,["AATGCATT"]=2259,["AATGAATT"]=2,["AATGCAGT"]=1,["AATGCAAT"]=1,["AATGCATG"]=5,["AATGCATC"]=7,["AATTATTT"]=2,["AATTAGTT"]=1,["AATTTCTT"]=1,["AATTTATT"]=6,["AATTGATT"]=5,["AATTCATT"]=1,["AATTAATT"]=1088,["AATTGTAT"]=1,["AATTTAAT"]=1,["AATTCAAT"]=1,["ACAATTGT"]=310,["ACAAGCGT"]=1,["ACAATTGG"]=5,["ACAATTGC"]=1,["ACACGTTT"]=5,["ACACCGTT"]=1,["ACACTTGT"]=1,["ACACGTGT"]=3412,["ACACGGGT"]=19,["ACACGCGT"]=1,["ACACGAGT"]=1,["ACACGTCT"]=3,["ACACGTTG"]=3,["ACACGTGG"]=84,["ACACGTGC"]=17,["ACACGTTA"]=1,["ACACGTGA"]=3,["ACAGCTTT"]=3,["ACAGTTGT"]=9,["ACAGGTGT"]=1,["ACAGCTGT"]=2701,["ACAGATGT"]=1,["ACAGCGGT"]=1,["ACAGCAGT"]=1,["ACAGCTAT"]=1,["ACAGCTTG"]=3,["ACAGCTGG"]=119,["ACAGTTGC"]=1,["ACAGCTGC"]=20,["ACAGCTTA"]=1,["ACAGCTGA"]=6,["ACAGCTAA"]=1,["ACATTTGT"]=4,["ACATGTGT"]=86,["ACATATGT"]=1762,["ACATAGGT"]=2,["ACATGCGT"]=1,["ACATATTG"]=1,["ACATTTGG"]=1,["ACATGTGG"]=1,["ACATATGG"]=19,["ACATGTGC"]=2,["ACATATGC"]=3,
["ACATGTTA"]=1,["ACATATTA"]=1,["ACCATGTT"]=1,["ACCATGGT"]=2380,["ACCAGGGT"]=3,["ACCAAGGT"]=2,["ACCAGCGT"]=2,["ACCATGAT"]=2,["ACCATGGG"]=9,["ACCATGGA"]=3,["ACCCGGTT"]=3,["ACCCGTGT"]=6,["ACCCTGGT"]=1,["ACCCGGGT"]=4127,["ACCCCGGT"]=1,["ACCCGGAT"]=2,["ACCCGGTG"]=2,["ACCCGGGG"]=63,["ACCCGGGC"]=15,["ACCCGGTA"]=3,["ACCCGGGA"]=3,["ACCCGGCA"]=1,["ACCGGGTT"]=1,["ACCGCGTT"]=3,["ACCGCTGT"]=4,["ACCGATGT"]=1,["ACCGTGGT"]=103,["ACCGGGGT"]=7,["ACCGCGGT"]=4222,["ACCGCAGT"]=2,["ACCGCGAT"]=2,["ACCGCGTG"]=1,["ACCGCTGG"]=1,["ACCGTGGG"]=1,["ACCGCGGG"]=109,["ACCGACCG"]=2,["ACCGCGGC"]=20,["ACCGCGCC"]=1,["ACCGCAAC"]=1,["ACCGCGTA"]=2,["ACCGCGGA"]=9,["ACCTGGTT"]=1,["ACCTTGGT"]=72,["ACCTGGGT"]=44,["ACCTCGGT"]=3,["ACCTAGGT"]=3099,["ACCTGAGT"]=2,["ACCTACCT"]=2,["ACCTAGAT"]=1,["ACCTATGG"]=1,["ACCTTGGG"]=1,["ACCTGGGG"]=1,["ACCTAGGG"]=21,["ACCTAGGC"]=4,["ACCTAGGA"]=1,["ACGATTGT"]=6,["ACGACTGT"]=1,["ACGATGGT"]=2,["ACGATCGT"]=1083,["ACGAGCGT"]=5,["ACGACCGT"]=1,["ACGAACGT"]=2,["ACGATAGT"]=2,["ACGATCTG"]=1,["ACGATCGG"]=2,["ACGATCGC"]=1,["ACGCGCTT"]=4,["ACGCGTGT"]=6,["ACGCGGGT"]=17,["ACGCCGGT"]=1,["ACGCGCGT"]=3446,["ACGCCCGT"]=1,["ACGCACGT"]=2,["ACGCGAGT"]=1,["ACGCGTCT"]=1,["ACGCGCCT"]=1,["ACGCGCTG"]=1,["ACGCGCGG"]=28,["ACGCGCCG"]=1,["ACGCGCTC"]=1,["ACGCGATC"]=1,["ACGCGCGC"]=18,["ACGCGACC"]=1,["ACGCGCTA"]=3,["ACGCGCGA"]=3,["ACGCGTCA"]=1,["ACGGCGTT"]=1,["ACGGCCTT"]=4,["ACGGTTGT"]=1,["ACGGCTGT"]=6,["ACGGCGGT"]=5,["ACGGTCGT"]=62,["ACGGGCGT"]=1,["ACGGCCGT"]=3626,["ACGGACGT"]=5,["ACGGCCAT"]=4,["ACGGCGTG"]=1,["ACGGCCTG"]=8,["ACGGCCGG"]=93,["ACGGTCGC"]=1,["ACGGCCGC"]=58,["ACGGCACC"]=1,["ACGGTCAC"]=1,["ACGGCCTA"]=13,["ACGGCCGA"]=5,["ACGTACTT"]=3,["ACGTATGT"]=4,["ACGTTGGT"]=1,["ACGTGGGT"]=1,["ACGTAGGT"]=6,["ACGTTCGT"]=7,["ACGTGCGT"]=60,["ACGTACGT"]=1744,["ACGTTAGT"]=1,["ACGTGCTG"]=1,["ACGTGCGG"]=1,["ACGTGCGC"]=3,["ACTATTGT"]=1,["ACTACTGT"]=1,["ACTAATGT"]=1,["ACTATGGT"]=3,["ACTACGGT"]=1,["ACTAGCGT"]=1,["ACTATAGT"]=442,["ACTAGAGT"]=2,["ACTATAGC"]=1,["ACTCGTGT"]=5,["ACTCGGGT"]=62,["ACTCGCGT"]=5,["ACTCGAGT"]=2698,["ACTCGATG"]=1,["ACTCGAGG"]=9,["ACTCACTC"]=2,["ACTCGAGA"]=2,["ACTGCATT"]=2,["ACTGCTGT"]=14,["ACTGATGT"]=1,["ACTGCGGT"]=29,["ACTGCCGT"]=1,["ACTGTAGT"]=15,["ACTGGAGT"]=1,["ACTGCAGT"]=1880,["ACTGTTAT"]=1,["ACTGCAAT"]=1,["ACTGGGTG"]=1,["ACTGAGTG"]=1,["ACTGCCGG"]=1,["ACTGTAGG"]=1,["ACTGCAGG"]=43,["ACTGCAGC"]=4,["ACTGCTTA"]=1,["ACTGCAGA"]=3,["ACTTACTT"]=2,["ACTTATGT"]=2,["ACTTTGGT"]=2,["ACTTAGGT"]=5,["ACTTTAGT"]=12,["ACTTGAGT"]=4,["ACTTCAGT"]=1,["AGAATTGT"]=3,["AGAATTCT"]=543,["AGAATTCC"]=1,["AGACGTTT"]=23,["AGACGTGT"]=54,["AGACGTCT"]=3170,["AGACGGCT"]=32,["AGACGACT"]=3,["AGACGTAT"]=5,["AGACGTCG"]=33,["AGACGTCC"]=3,["AGACGGCC"]=1,["AGACGTTA"]=2,["AGACGTCA"]=3,["AGACGGCA"]=1,["AGAGCTTT"]=20,["AGAGCTGT"]=50,["AGAGTTCT"]=10,["AGAGGTCT"]=1,["AGAGCTCT"]=2525,["AGAGCGCT"]=2,["AGAGCCCT"]=1,["AGAGCACT"]=1,["AGAGCTAT"]=10,["AGAGCTTG"]=1,["AGAGCTCG"]=25,["AGAGCCAG"]=1,["AGAGCTTC"]=1,["AGAGCTCC"]=4,["AGAGCTAC"]=1,["AGAGCTTA"]=1,["AGAGCTCA"]=5,["AGAGTTAA"]=1,["AGATGTTT"]=1,["AGATATTT"]=7,["AGATGTGT"]=1,
["AGATATGT"]=28,["AGATTTCT"]=8,["AGATGTCT"]=113,["AGATATCT"]=2084,["AGATAGCT"]=1,["AGATATAT"]=1,["AGATATGG"]=1,["AGATATCG"]=15,["AGATATCC"]=1,["AGATGTCA"]=1,["AGATATCA"]=2,["AGCATGTT"]=2,["AGCAGGTT"]=1,["AGCATGGT"]=16,["AGCATGCT"]=2924,["AGCAGGCT"]=9,["AGCACGCT"]=3,["AGCAAGCT"]=3,["AGCATACT"]=1,["AGCATGAT"]=2,["AGCATGTG"]=1,["AGCATGCG"]=3,["AGCATGCC"]=1,["AGCAGGCC"]=2,["AGCCGTTT"]=1,["AGCCATTT"]=1,["AGCCGGTT"]=28,["AGCCGGGT"]=54,["AGCCGTCT"]=14,["AGCCTGCT"]=2,["AGCCGGCT"]=4246,["AGCCCGCT"]=3,["AGCCAGCT"]=1,["AGCCGCCT"]=1,["AGCCGACT"]=11,["AGCCGGAT"]=8,["AGCCGGTG"]=1,["AGCCGCTG"]=1,["AGCCGTCG"]=1,["AGCCGGCG"]=34,["AGCCGGGC"]=1,["AGCCGGCC"]=18,["AGCCGGCA"]=5,["AGCGCGTT"]=29,["AGCGGCTT"]=1,["AGCGGGGT"]=1,["AGCGCGGT"]=77,["AGCGCTCT"]=16,["AGCGTGCT"]=370,["AGCGGGCT"]=10,["AGCGCGCT"]=3837,["AGCGAGCT"]=16,["AGCGTACT"]=1,["AGCGCACT"]=18,["AGCGTGAT"]=1,["AGCGCGAT"]=13,["AGCGCGTG"]=1,["AGCGGCTG"]=1,["AGCGCGGG"]=1,["AGCGCGCG"]=63,["AGCGCGCC"]=17,["AGCGCGCA"]=6,["AGCTGGTT"]=1,["AGCTAGTT"]=8,["AGCTAGGT"]=29,["AGCTTGCT"]=128,["AGCTGGCT"]=198,["AGCTAGCT"]=3566,["AGCTGGAT"]=1,["AGCTTTGC"]=1,["AGCTATGC"]=1,["AGCTGGTA"]=1,["AGCTGGCA"]=1,["AGGATCTT"]=2,["AGGATTGT"]=1,["AGGATCGT"]=2,["AGGATTCT"]=1,["AGGATGCT"]=1,["AGGATCCT"]=1673,["AGGAGCCT"]=4,["AGGACCCT"]=2,["AGGATCTG"]=1,["AGGCGCTT"]=26,["AGGCGCGT"]=27,["AGGCGTCT"]=7,["AGGCTGCT"]=1,["AGGCGGCT"]=59,["AGGCTCCT"]=1,["AGGCGCCT"]=3804,["AGGCGACT"]=11,["AGGCGCAT"]=8,["AGGCGCTG"]=3,["AGGCGCCG"]=27,["AGGCGACG"]=1,["AGGCGCCC"]=5,["AGGCGCCA"]=1,["AGGGCCTT"]=37,["AGGGCCGT"]=29,["AGGGCTCT"]=9,["AGGGCGCT"]=10,["AGGGTCCT"]=127,["AGGGCCCT"]=3085,["AGGGCACT"]=6,["AGGGCCAT"]=16,["AGGGCCTG"]=2,["AGGGCGCG"]=1,["AGGGTCCG"]=1,["AGGGCCCG"]=30,["AGGGCCCC"]=8,["AGGGCCAC"]=1,["AGGGCCTA"]=1,["AGGGCCCA"]=3,["AGGTGCGT"]=1,["AGGTATCT"]=3,["AGGTGGCT"]=1,["AGGTTCCT"]=9,["AGGTGCCT"]=132,["AGGTCACT"]=1,["AGTATATT"]=1,["AGTATAGT"]=2,["AGTATTCT"]=2,["AGTAATCT"]=2,["AGTATGCT"]=3,["AGTATACT"]=1055,["AGTAGACT"]=2,["AGTCGGTT"]=2,["AGTCGCTT"]=2,["AGTCGATT"]=7,["AGTCGAGT"]=6,["AGTCGTCT"]=2,["AGTCGGCT"]=79,["AGTCGCCT"]=1,["AGTCTACT"]=4,["AGTCGACT"]=3549,["AGTCGAAT"]=3,["AGTCGACG"]=8,["AGTCGACC"]=1,["AGTCGATA"]=1,["AGTCGACA"]=1,["AGTGCATT"]=15,["AGTGCAGT"]=9,["AGTGTTCT"]=1,["AGTGCTCT"]=11,["AGTGCGCT"]=14,["AGTGGCCT"]=1,["AGTGCCCT"]=1,["AGTGTACT"]=27,["AGTGGACT"]=3,["AGTGCACT"]=2541,["AGTGCAAT"]=1,["AGTGCACG"]=14,["AGTGCACC"]=5,["AGTGCACA"]=3,["AGTTATCT"]=1,["AGTTTGCT"]=1,["AGTTTACT"]=37,["AGTTGACT"]=20,["AGTTCACT"]=4,["AGTTATAC"]=1,["AGTTGGGA"]=1,["ATAATTAT"]=78,["ATAAATAT"]=2,["ATAATAAT"]=1,["ATACGTTT"]=6,["ATACGTGT"]=8,["ATACGTAT"]=1711,["ATACGGAT"]=24,["ATACGCAT"]=1,["ATACGAAT"]=7,["ATACGTGG"]=1,["ATACGTAG"]=1,["ATACGTTC"]=1,["ATACGTAC"]=3,["ATACGTTA"]=1,["ATACGGAA"]=1,["ATAGCTTT"]=14,["ATAGCTGT"]=13,["ATAGTTAT"]=2,["ATAGCTAT"]=1089,["ATAGATAT"]=2,["ATAGCGAT"]=3,["ATAGTCAT"]=1,["ATAGCTAG"]=1,["ATAGCCGC"]=1,["ATAGCTAC"]=1,["ATAGCTTA"]=5,["ATAGCTGA"]=1,["ATATTTTT"]=1,["ATATATTT"]=1,["ATATGTAT"]=3,["ATATATAT"]=504,["ATATGGAT"]=1,["ATATGCAT"]=1,
["ATATCAAT"]=1,["ATCATTAT"]=1,["ATCATGAT"]=1427,["ATCAGGAT"]=18,["ATCACGAT"]=3,["ATCATGGG"]=1,["ATCATGAG"]=1,["ATCATGAC"]=2,["ATCATGCA"]=1,["ATCATGAA"]=1,["ATCCGGTT"]=8,["ATCCGATT"]=1,["ATCCGGGT"]=32,["ATCCGGCT"]=1,["ATCCGTAT"]=2,["ATCCTGAT"]=2,["ATCCGGAT"]=3962,["ATCCGCAT"]=1,["ATCCGGTG"]=1,["ATCCGGGG"]=1,["ATCCGGAG"]=1,["ATCCGGAC"]=3,["ATCGCGTT"]=3,["ATCGCGGT"]=13,["ATCGCGCT"]=1,["ATCGTGAT"]=101,["ATCGGGAT"]=1,["ATCGCGAT"]=3545,["ATCGCGGG"]=1,["ATCGCGCG"]=1,["ATCGCGAG"]=4,["ATCGCGAC"]=2,["ATCGCGTA"]=1,["ATCGCGAA"]=2,["ATCTTGTT"]=1,["ATCTGGGT"]=1,["ATCTTTAT"]=1,["ATCTGTAT"]=1,["ATCTTGAT"]=81,["ATCTGGAT"]=30,["ATCTCGAT"]=1,["ATGATCTT"]=1,["ATGATCGT"]=2,["ATGATTAT"]=1,["ATGATGAT"]=1,["ATGATCAT"]=913,["ATGAGCAT"]=5,["ATGACCAT"]=2,["ATGATAAT"]=1,["ATGAGAAT"]=1,["ATGCGCTT"]=5,["ATGCTATT"]=1,["ATGCGCGT"]=51,["ATGCGTCT"]=1,["ATGCGACT"]=1,["ATGCGTAT"]=7,["ATGCGGAT"]=70,["ATGCGCAT"]=3326,["ATGCCCAT"]=1,["ATGCGAAT"]=4,["ATGCGCTG"]=5,["ATGCGCCG"]=1,["ATGCGCAG"]=2,["ATGCGAGC"]=1,["ATGCGCAC"]=1,["ATGCGCTA"]=2,["ATGCGCAA"]=2,["ATGGCCTT"]=13,["ATGGCCGT"]=18,["ATGGCCCT"]=1,["ATGGCTAT"]=3,["ATGGTCAT"]=39,["ATGGGCAT"]=2,["ATGGCCAT"]=2827,["ATGGCCTG"]=2,["ATGGCATG"]=1,["ATGGCCAG"]=6,["ATGGCCTC"]=2,["ATGGCCGC"]=2,["ATGGCTAC"]=1,["ATGGCCTA"]=10,["ATGGCCAA"]=2,["ATGTTGCT"]=1,["ATGTGGCT"]=1,["ATGTTCAT"]=6,["ATGTGCAT"]=16,["ATTATATT"]=2,["ATTATTAT"]=2,["ATTATGAT"]=3,["ATTATAAT"]=453,["ATTAGAAT"]=2,["ATTACAAT"]=1,["ATTATAAC"]=1,["ATTATAAA"]=1,["ATTCGATT"]=3,["ATTCGAGT"]=4,["ATTCGGCT"]=1,["ATTCGACT"]=1,["ATTCGTAT"]=4,["ATTCGGAT"]=65,["ATTCGCAT"]=1,["ATTCTAAT"]=1,["ATTCGAAT"]=2452,["ATTCGTCG"]=1,["ATTCGAAG"]=2,["ATTCATTC"]=2,["ATTCGAAC"]=3,["ATTCGAAA"]=2,["ATTGCTTT"]=1,["ATTGCATT"]=13,["ATTGCGGT"]=1,["ATTGCAGT"]=2,["ATTGCACT"]=1,["ATTGCTAT"]=3,["ATTGTGAT"]=1,["ATTGCGAT"]=25,["ATTGTCAT"]=1,["ATTGCCAT"]=1,["ATTGTAAT"]=29,["ATTGGAAT"]=2,["ATTGCAAT"]=2308,["ATTGCTAG"]=1,["ATTGCAAG"]=2,["ATTGCTTC"]=1,["ATTGCACC"]=1,["ATTGCAAC"]=1,["ATTGCATA"]=1,["ATTTATTT"]=2,["ATTTTGAT"]=2,["ATTTTAAT"]=21,["ATTTGAAT"]=18,["ATTTCAAT"]=1,["CAAACTTT"]=1,["CAAATTTG"]=726,["CAAAGTTG"]=2,["CAAATGTG"]=2,["CAAATTCG"]=1,["CAAATTTC"]=1,["CAACGTTT"]=6,["CAACTTTG"]=1,["CAACGTTG"]=3635,["CAACGGTG"]=27,["CAACGCTG"]=4,["CAACGATG"]=8,["CAACGTGG"]=1,["CAACGGGG"]=1,["CAACGCGG"]=1,["CAACGAGG"]=1,["CAACGTCG"]=10,["CAACGGCG"]=1,["CAACGTAG"]=2,["CAACGTTA"]=3,["CAAGCTTT"]=3,["CAAGTTTG"]=19,["CAAGGTTG"]=4,["CAAGCTTG"]=1848,["CAAGTCTG"]=1,["CAAGCCTG"]=1,["CAAGCATG"]=3,["CAAGTTGG"]=1,["CAAGCTGG"]=2,["CAAGCTCG"]=2,["CAAGCTAG"]=1,["CAAGCGAG"]=1,["CAAGCAAG"]=2,["CAAGCTTC"]=3,["CAAGCTTA"]=3,["CAATTTTG"]=10,["CAATGTTG"]=63,["CAATCTTG"]=1,["CAATTTCG"]=1,["CAATGTTA"]=1,["CACATGTT"]=1,["CACATGTG"]=2758,["CACAGGTG"]=41,["CACACGTG"]=3,["CACATGGG"]=5,["CACATGCG"]=2,["CACATCCG"]=1,["CACACACA"]=2,["CACCGGTT"]=4,["CACCGTTG"]=2,["CACCTGTG"]=4,["CACCGGTG"]=4397,["CACCCGTG"]=1,["CACCGCTG"]=1,["CACCGATG"]=7,["CACCGTGG"]=1,["CACCGGGG"]=48,["CACCGAGG"]=2,["CACCGGCG"]=30,["CACCTGAG"]=1,["CACCGGAG"]=3,["CACCGGTC"]=3,["CACCCACC"]=2,
["CACCGGTA"]=3,["CACCGGCA"]=1,["CACGCGTT"]=4,["CACGCTTG"]=3,["CACGTGTG"]=280,["CACGGGTG"]=10,["CACGCGTG"]=3808,["CACGGATG"]=1,["CACGCATG"]=2,["CACGGTGG"]=3,["CACGCTGG"]=1,["CACGTGGG"]=1,["CACGCGGG"]=18,["CACGCCGG"]=1,["CACGCGCG"]=16,["CACGCACG"]=4,["CACGCTAG"]=1,["CACGCGAG"]=3,["CACGCCAG"]=1,["CACGCGTC"]=3,["CACGCGTA"]=6,["CACTGTTG"]=2,["CACTTGTG"]=170,["CACTGGTG"]=181,["CACTCGTG"]=4,["CACTGGCG"]=1,["CACTGTAG"]=1,["CACTTGAG"]=1,["CAGATCTT"]=1,["CAGATTTG"]=4,["CAGATGTG"]=1,["CAGATCTG"]=1428,["CAGAGCTG"]=11,["CAGACCTG"]=2,["CAGATCGG"]=2,["CAGAGACG"]=1,["CAGATCTA"]=1,["CAGCGCTT"]=6,["CAGCGTTG"]=12,["CAGCGGTG"]=47,["CAGCTCTG"]=1,["CAGCGCTG"]=3973,["CAGCGATG"]=8,["CAGCGCGG"]=5,["CAGCGCCG"]=3,["CAGCGCAG"]=1,["CAGCGCTA"]=5,["CAGCGCCA"]=1,["CAGGCCTT"]=6,["CAGGCTTG"]=1,["CAGGCGTG"]=5,["CAGGTCTG"]=112,["CAGGGCTG"]=1,["CAGGCCTG"]=3301,["CAGGGATG"]=1,["CAGGCATG"]=1,["CAGGCTGG"]=1,["CAGGCCGG"]=4,["CAGGCCCG"]=1,["CAGGTACG"]=1,["CAGGCCAG"]=5,["CAGGCCTC"]=1,["CAGGCCTA"]=3,["CAGTGTTG"]=1,["CAGTGGTG"]=1,["CAGTTCTG"]=7,["CAGTGCTG"]=45,["CAGTTTCG"]=1,["CAGTTCCG"]=1,["CATACTAT"]=1,["CATATTTG"]=1,["CATAGTTG"]=1,["CATATGTG"]=17,["CATAGGTG"]=1,["CATATCTG"]=1,["CATATATG"]=1050,["CATAGATG"]=24,["CATACATG"]=3,["CATAGAGG"]=1,["CATATACG"]=1,["CATCGATT"]=2,["CATCGTTG"]=26,["CATCCTTG"]=1,["CATCGGTG"]=281,["CATCGCTG"]=4,["CATCTATG"]=6,["CATCGATG"]=3711,["CATCCATG"]=5,["CATCGAGG"]=1,["CATCGTCG"]=1,["CATCGGCG"]=1,["CATCGACG"]=11,["CATCGCAG"]=1,["CATCGAAG"]=1,["CATGCATT"]=6,["CATGCTTG"]=26,["CATGTGTG"]=2,["CATGCGTG"]=78,["CATGTCTG"]=1,["CATGCCTG"]=1,["CATGTATG"]=111,["CATGGATG"]=11,["CATGCATG"]=3188,["CATGCTGG"]=1,["CATGCCGG"]=1,["CATGCTAG"]=1,["CATGCCAG"]=1,["CATTTTTG"]=4,["CATTGGTG"]=5,["CATTTCTG"]=1,["CATTGCTG"]=2,["CATTTATG"]=84,["CATTGATG"]=88,["CATTTACG"]=1,["CCAATTTG"]=1,["CCAATTGG"]=1263,["CCAAGTGG"]=5,["CCACGTGT"]=3,["CCACGGCT"]=1,["CCACGTTG"]=2,["CCACTTGG"]=2,["CCACGTGG"]=3530,["CCACGGGG"]=125,["CCACGCGG"]=10,["CCACGAGG"]=9,["CCACGTGA"]=7,["CCAGCTGT"]=1,["CCAGTTGG"]=31,["CCAGGTGG"]=2,["CCAGCTGG"]=3120,["CCAGTGGG"]=1,["CCAGCGGG"]=5,["CCAGCTCG"]=1,["CCAGCTAG"]=1,["CCAGCTGC"]=1,["CCAGCTGA"]=4,["CCATTTGG"]=8,["CCATGTGG"]=87,["CCATTGGG"]=1,["CCCATGGT"]=1,["CCCATGTG"]=1,["CCCATTGG"]=1,["CCCATGGG"]=3286,["CCCAGGGG"]=36,["CCCACGGG"]=8,["CCCAGCGG"]=1,["CCCATGAG"]=1,["CCCATGGC"]=1,["CCCATGGA"]=4,["CCCACCCA"]=2,["CCCCGGGT"]=2,["CCCCGGTG"]=12,["CCCCGTGG"]=2,["CCCCTGGG"]=11,["CCCCGGGG"]=2930,["CCCCCGGG"]=2,["CCCCGCGG"]=1,["CCCCGAGG"]=2,["CCCCGGCG"]=1,["CCCCGGAG"]=2,["CCCCGGGA"]=4,["CCCGCGGT"]=2,["CCCGCGTG"]=2,["CCCGCTGG"]=1,["CCCGTGGG"]=282,["CCCGGGGG"]=11,["CCCGCGGG"]=3700,["CCCGTCGG"]=1,["CCCGCCGG"]=5,["CCCGTAGG"]=1,["CCCGCGCG"]=1,["CCCGCCCG"]=2,["CCCGTGAG"]=1,["CCCGCGAG"]=1,["CCCGCGGC"]=1,["CCCGCGGA"]=4,["CCCTTGGG"]=252,["CCCTGGGG"]=211,["CCCTCGGG"]=8,["CCCTTCGG"]=2,["CCCTTAGG"]=1,["CCCTGGCG"]=1,["CCGATCGT"]=1,["CCGATCTG"]=2,["CCGATTGG"]=25,["CCGATGGG"]=1,["CCGATCGG"]=3077,["CCGAGCGG"]=52,["CCGACCGG"]=3,["CCGATAGG"]=3,["CCGAGAGG"]=3,["CCGACCGA"]=2,["CCGCGCGT"]=2,["CCGCGCTG"]=8,
["CCGCGTGG"]=106,["CCGCCTGG"]=1,["CCGCGGGG"]=56,["CCGCTCGG"]=2,["CCGCGCGG"]=3767,["CCGCGAGG"]=6,["CCGCGCCG"]=1,["CCGCGACG"]=1,["CCGCGCAG"]=1,["CCGCCCGC"]=2,["CCGCGCGA"]=2,["CCGGCCTG"]=10,["CCGGTTGG"]=2,["CCGGCTGG"]=51,["CCGGCGGG"]=11,["CCGGTCGG"]=229,["CCGGGCGG"]=10,["CCGGCCGG"]=4272,["CCGGTAGG"]=1,["CCGTCCGT"]=2,["CCGTGTGG"]=1,["CCGTCTGG"]=1,["CCGTTGGG"]=1,["CCGTTCGG"]=44,["CCGTGCGG"]=175,["CCGTGAGG"]=1,["CCTATGTG"]=1,["CCTATTGG"]=7,["CCTATGGG"]=18,["CCTATAGG"]=1692,["CCTAGAGG"]=13,["CCTATACG"]=1,["CCTCGAGT"]=1,["CCTCGATG"]=4,["CCTCTTGG"]=1,["CCTCGTGG"]=57,["CCTCGGGG"]=259,["CCTCGCGG"]=22,["CCTCTAGG"]=19,["CCTCGAGG"]=3362,["CCTCGTCG"]=1,["CCTCGACG"]=2,["CCTCCCTC"]=2,["CCTCGAGA"]=1,["CCTGCGTG"]=1,["CCTGTATG"]=1,["CCTGTTGG"]=1,["CCTGCTGG"]=47,["CCTGTGGG"]=4,["CCTGGGGG"]=1,["CCTGCGGG"]=177,["CCTGTAGG"]=114,["CCTGGAGG"]=5,["CCTGCTAG"]=1,["CCTTTTTG"]=1,["CCTTTTGG"]=3,["CCTTGTGG"]=1,["CCTTTGGG"]=1,["CCTTGGGG"]=3,["CCTTTCGG"]=1,["CCTTGCGG"]=1,["CCTTTAGG"]=108,["CCTTGAGG"]=128,["CGAATTCT"]=1,["CGAATTTG"]=3,["CGAATTCG"]=1731,["CGAAGTCG"]=5,["CGAATGCG"]=2,["CGAATCCG"]=1,["CGACGTCT"]=10,["CGACGGCT"]=1,["CGACGACT"]=1,["CGACGTTG"]=137,["CGACGGTG"]=1,["CGACGTGG"]=4,["CGACGGGG"]=1,["CGACTTCG"]=2,["CGACGTCG"]=3823,["CGACGGCG"]=142,["CGACGCCG"]=5,["CGACGACG"]=11,["CGACGTAG"]=5,["CGACGGAG"]=2,["CGACGTTC"]=1,["CGACGTCC"]=1,["CGACGTGA"]=1,["CGACGTCA"]=11,["CGACGGAA"]=1,["CGAGCTTT"]=1,["CGAGCTCT"]=4,["CGAGCTTG"]=86,["CGAGCGTG"]=1,["CGAGCTGG"]=7,["CGAGTTCG"]=46,["CGAGGTCG"]=7,["CGAGCTCG"]=2856,["CGAGCGCG"]=9,["CGAGGACG"]=1,["CGAGCTAG"]=2,["CGAGTGAG"]=1,["CGAGCGAG"]=6,["CGAGTTCC"]=1,["CGAGCTCC"]=3,["CGAGCTCA"]=9,["CGATTTGG"]=1,["CGATTTCG"]=18,["CGATGTCG"]=153,["CGATCTCG"]=2,["CGATTGCG"]=1,["CGATGGCG"]=1,["CGATTCCG"]=1,["CGATTGAG"]=2,["CGATGAAG"]=1,["CGCATGCT"]=1,["CGCATGTG"]=5,["CGCATGGG"]=7,["CGCATGCG"]=3227,["CGCAGGCG"]=77,["CGCACGCG"]=29,["CGCATACG"]=2,["CGCATGAG"]=2,["CGCAGGAG"]=1,["CGCCGGCT"]=20,["CGCCGTTG"]=1,["CGCCGGTG"]=110,["CGCCGGGG"]=83,["CGCCGTCG"]=16,["CGCCTGCG"]=32,["CGCCGGCG"]=4056,["CGCCCGCG"]=7,["CGCCGACG"]=40,["CGCCGTAG"]=2,["CGCCGGAG"]=16,["CGCCGAAG"]=1,["CGCCGGTC"]=1,["CGCCGGCC"]=4,["CGCCCGCC"]=2,["CGCCGGAC"]=1,["CGCCGGTA"]=2,["CGCCGTCA"]=1,["CGCCGGCA"]=15,["CGCGGCGT"]=1,["CGCGCGCT"]=12,["CGCGCGTG"]=85,["CGCGTGGG"]=1,["CGCGCGGG"]=32,["CGCGGCGG"]=2,["CGCGTTCG"]=1,["CGCGGTCG"]=1,["CGCGCTCG"]=8,["CGCGTGCG"]=750,["CGCGGGCG"]=25,["CGCGCGCG"]=3538,["CGCGTGAG"]=1,["CGCGGGAG"]=1,["CGCGCGTC"]=1,["CGCGCGGC"]=1,["CGCTGGTG"]=2,["CGCTTGGG"]=2,["CGCTGCGG"]=1,["CGCTTGCG"]=395,["CGCTGGCG"]=311,["CGCTGGAG"]=1,["CGGATCTG"]=5,["CGGATCGG"]=1,["CGGATTCG"]=11,["CGGATGCG"]=3,["CGGATCCG"]=3246,["CGGAGCCG"]=53,["CGGATACG"]=3,["CGGAGACG"]=1,["CGGATCAG"]=1,["CGGACGGA"]=2,["CGGCGCCT"]=9,["CGGCGTTG"]=1,["CGGCGCTG"]=162,["CGGCGCGG"]=13,["CGGCTTCG"]=1,["CGGCGTCG"]=109,["CGGCGGCG"]=198,["CGGCTCCG"]=5,["CGGCGCCG"]=4118,["CGGCGACG"]=49,["CGGCGCAG"]=4,["CGGCGCCC"]=5,["CGGCGCTA"]=1,["CGGCGCCA"]=2,["CGGGCTGG"]=1,["CGGGTTCG"]=3,["CGGGCTCG"]=23,["CGGGTCCG"]=282,["CGGGGCCG"]=10,
["CGGGTCAG"]=1,["CGGTCGGT"]=2,["CGGTTCCT"]=1,["CGGTGGCG"]=1,["CGGTTCCG"]=29,["CGGTGCCG"]=208,["CGGTTACG"]=1,["CGGTGACG"]=1,["CGTATACT"]=1,["CGTATATG"]=4,["CGTATTGG"]=1,["CGTAGTGG"]=1,["CGTATAGG"]=3,["CGTATTCG"]=1,["CGTATGCG"]=23,["CGTAGGCG"]=2,["CGTATCCG"]=1,["CGTAGCCG"]=1,["CGTATACG"]=2290,["CGTAGACG"]=46,["CGTATACC"]=1,["CGTCGGCT"]=1,["CGTCGACT"]=3,["CGTCGATG"]=46,["CGTCGGGG"]=1,["CGTCGCGG"]=1,["CGTCGAGG"]=26,["CGTCTTCG"]=1,["CGTCGTCG"]=10,["CGTCGGCG"]=279,["CGTCGCCG"]=5,["CGTCTACG"]=18,["CGTCGACG"]=4151,["CGTCGTAG"]=2,["CGTCGAAG"]=1,["CGTCGATC"]=1,["CGTCGCGC"]=1,["CGTCGACC"]=1,["CGTCGACA"]=4,["CGTGCTTG"]=2,["CGTGCGTG"]=6,["CGTGCTCG"]=23,["CGTGTGCG"]=2,["CGTGGCCG"]=1,["CGTGTACG"]=188,["CGTGGACG"]=12,["CGTTTAGG"]=1,["CGTTTGCG"]=1,["CGTTGGCG"]=2,["CGTTTACG"]=162,["CGTTGACG"]=125,["CGTTTTAG"]=1,["CTAATTGG"]=1,["CTAATGCG"]=2,["CTAATTAG"]=334,["CTAAGTAG"]=1,["CTAATGAG"]=1,["CTAAGCAG"]=1,["CTACGTAT"]=1,["CTACGTTG"]=17,["CTACGATG"]=1,["CTACGTGG"]=18,["CTACGTCG"]=1,["CTACGTAG"]=2339,["CTACTGAG"]=1,["CTACGGAG"]=71,["CTACGCAG"]=2,["CTACGAAG"]=9,["CTACGTAA"]=1,["CTAGCTGT"]=1,["CTAGCTAT"]=1,["CTAGCTTG"]=21,["CTAGCTGG"]=24,["CTAGTAGG"]=2,["CTAGCTCG"]=1,["CTAGTTAG"]=10,["CTAGGTAG"]=2,["CTAGCTAG"]=866,["CTAGTGAG"]=1,["CTAGTCAG"]=1,["CTATCTAT"]=2,["CTATGGCG"]=1,["CTATTTAG"]=3,["CTATGTAG"]=9,["CTATTCAG"]=1,["CTATTAAG"]=2,["CTCATGTG"]=10,["CTCATGGG"]=9,["CTCATGCG"]=7,["CTCATTAG"]=1,["CTCATGAG"]=1964,["CTCAGGAG"]=38,["CTCAGCAG"]=1,["CTCATAAG"]=1,["CTCATGAC"]=1,["CTCATTGA"]=1,["CTCCTGAT"]=1,["CTCCGGAT"]=1,["CTCCGGTG"]=138,["CTCCGGGG"]=54,["CTCCGCGG"]=2,["CTCCGGCG"]=36,["CTCCTGAG"]=7,["CTCCGGAG"]=3421,["CTCCGCAG"]=1,["CTCCGAAG"]=6,["CTCCGGGA"]=1,["CTCCGGAA"]=1,["CTCGTGGG"]=1,["CTCGTGAG"]=181,["CTCGGGAG"]=7,["CTCTCTCT"]=2,["CTCTTGTG"]=1,["CTCTGGTG"]=1,["CTCTTGGG"]=1,["CTCTTGAG"]=150,["CTCTGGAG"]=180,["CTCTTCAG"]=2,["CTGATCTG"]=5,["CTGATATG"]=1,["CTGAGATG"]=3,["CTGATCGG"]=6,["CTGAGCGG"]=1,["CTGATTAG"]=4,["CTGATGAG"]=1,["CTGATCAG"]=1620,["CTGAGCAG"]=47,["CTGATAAG"]=1,["CTGAGAAG"]=5,["CTGACTGA"]=2,["CTGCGCTT"]=1,["CTGCGGAT"]=1,["CTGCGCAT"]=4,["CTGCGCTG"]=98,["CTGCTCGG"]=1,["CTGCGCGG"]=75,["CTGCGCCG"]=20,["CTGCGACG"]=1,["CTGCGTAG"]=85,["CTGCGGAG"]=97,["CTGCTCAG"]=1,["CTGCGCAG"]=3534,["CTGCGAAG"]=7,["CTGGCTTG"]=1,["CTGGTCTG"]=1,["CTGGTCAG"]=140,["CTGGGCAG"]=3,["CTGTGCTG"]=1,["CTGTGCGG"]=1,["CTGTTTAG"]=1,["CTGTGTAG"]=1,["CTGTTCAG"]=20,["CTGTGCAG"]=120,["CTGTTAAG"]=1,["CTTATTTG"]=1,["CTTAGCTG"]=1,["CTTAGATG"]=1,["CTTAGAGG"]=1,["CTTAGCCG"]=1,["CTTATACG"]=2,["CTTATTAG"]=4,["CTTAGTAG"]=1,["CTTATGAG"]=19,["CTTATAAG"]=814,["CTTAGAAG"]=6,["CTTATAAA"]=1,["CTTCGAAT"]=1,["CTTCGGTG"]=1,["CTTCGATG"]=22,["CTTCGCGG"]=1,["CTTCGAGG"]=9,["CTTCGGCG"]=1,["CTTCGACG"]=10,["CTTCGTAG"]=34,["CTTCGGAG"]=224,["CTTCGCAG"]=5,["CTTCTAAG"]=5,["CTTCGAAG"]=2877,["CTTCGAAA"]=1,["CTTGCTTG"]=4,["CTTGTTAG"]=1,["CTTGGGAG"]=1,["CTTGTAAG"]=51,["CTTGGAAG"]=2,["CTTTGCCG"]=1,["CTTTGACG"]=1,["CTTTTTAG"]=1,["CTTTGGAG"]=6,["CTTTTCAG"]=1,["CTTTTAAG"]=57,["CTTTGAAG"]=94,["GAAATTTT"]=4,["GAAATCTG"]=1,["GAAATTTC"]=841,
["GAAAGTTC"]=1,["GAAATAGC"]=1,["GAAATTCC"]=1,["GAAATTAC"]=2,["GAAAGAAA"]=4,["GAACGTTT"]=66,["GAACGGTT"]=1,["GAACGTGT"]=1,["GAACGTCT"]=1,["GAACGGCT"]=1,["GAACGTTG"]=8,["GAACTTTC"]=4,["GAACGTTC"]=3490,["GAACGGTC"]=5,["GAACGCTC"]=2,["GAACGATC"]=2,["GAACGTGC"]=10,["GAACGTCC"]=6,["GAACGTAC"]=7,["GAACGTTA"]=13,["GAACGTGA"]=1,["GAAGTTTC"]=22,["GAAGGTTC"]=1,["GAAGTGTC"]=1,["GAAGTCTC"]=1,["GAAGTGCC"]=1,["GAATGTTG"]=1,["GAATTTTC"]=10,["GAATGTTC"]=233,["GAATGTAC"]=1,["GAATTTTA"]=1,["GACATGTT"]=10,["GACAGGTT"]=1,["GACATGTG"]=3,["GACATGTC"]=2894,["GACAGGTC"]=17,["GACATATC"]=1,["GACATGGC"]=9,["GACATGCC"]=4,["GACATGTA"]=3,["GACATGGA"]=1,["GACATGCA"]=1,["GACCGGTT"]=113,["GACCGGGT"]=3,["GACCGGCT"]=1,["GACCGGTG"]=8,["GACCGTTC"]=10,["GACCTGTC"]=3,["GACCGGTC"]=4051,["GACCGATC"]=9,["GACCGGGC"]=37,["GACCGGCC"]=25,["GACCGACC"]=2,["GACCGGAC"]=2,["GACCGGTA"]=18,["GACCGGCA"]=1,["GACCGGAA"]=1,["GACGGTCG"]=1,["GACGTGTC"]=331,["GACGGGTC"]=6,["GACGTCTC"]=1,["GACGTATC"]=1,["GACGTGGC"]=1,["GACGGTCC"]=1,["GACGTGTA"]=1,["GACTGACT"]=2,["GACTGTTC"]=2,["GACTTGTC"]=119,["GACTGGTC"]=217,["GACTGATC"]=2,["GACTGGCC"]=1,["GACTGCCC"]=1,["GAGATCTT"]=3,["GAGAGCTT"]=1,["GAGATTTC"]=3,["GAGATGTC"]=3,["GAGATCTC"]=1542,["GAGAGCTC"]=3,["GAGATATC"]=1,["GAGAGATC"]=2,["GAGATCAC"]=1,["GAGCGGTT"]=2,["GAGCGCTT"]=75,["GAGCGATT"]=1,["GAGCGCGT"]=2,["GAGCGCAT"]=1,["GAGCGCTG"]=2,["GAGCGTTC"]=15,["GAGCGGTC"]=22,["GAGCTCTC"]=2,["GAGCGCTC"]=3836,["GAGCGATC"]=5,["GAGCGCGC"]=11,["GAGCGCCC"]=6,["GAGCGCAC"]=5,["GAGCGTTA"]=1,["GAGCGCTA"]=22,["GAGCGCGA"]=1,["GAGGTCTC"]=227,["GAGGGCTC"]=2,["GAGTTCTC"]=16,["GAGTGCTC"]=197,["GAGTTATC"]=1,["GATATATT"]=2,["GATATTTC"]=1,["GATATGTC"]=5,["GATATATC"]=1417,["GATAGATC"]=6,["GATATGGC"]=1,["GATATATA"]=1,["GATAGATA"]=2,["GATATTGA"]=1,["GATCGATT"]=72,["GATCGTTG"]=2,["GATCGATG"]=2,["GATCGTTC"]=7,["GATCTGTC"]=1,["GATCGGTC"]=101,["GATCGCTC"]=3,["GATCTATC"]=5,["GATCGATC"]=3882,["GATCGCGC"]=1,["GATCGGCC"]=2,["GATGGATT"]=1,["GATGTGTC"]=1,["GATGTCTC"]=1,["GATGTATC"]=68,["GATGTATA"]=1,["GATTTATT"]=2,["GATTTTTC"]=1,["GATTGGTC"]=1,["GATTTATC"]=41,["GATTTAGC"]=1,["GCAATTGT"]=3,["GCAATTGG"]=1,["GCAATTGC"]=1396,["GCAAGTGC"]=1,["GCAATGGC"]=1,["GCAATTAC"]=2,["GCAATTGA"]=3,["GCACGTGT"]=92,["GCACGTGG"]=13,["GCACGTTC"]=3,["GCACTTGC"]=4,["GCACGTGC"]=3593,["GCACTGGC"]=2,["GCACGGGC"]=69,["GCACGCGC"]=4,["GCACGTCC"]=2,["GCACGTAC"]=3,["GCACGTGA"]=30,["GCACGGGA"]=1,["GCAGTTGG"]=1,["GCAGGTCG"]=1,["GCAGTTGC"]=76,["GCAGGTGC"]=3,["GCAGGGGC"]=1,["GCAGTGCC"]=1,["GCATGTTC"]=1,["GCATTTGC"]=10,["GCATGTGC"]=443,["GCATGGGC"]=1,["GCATTCGC"]=2,["GCCATGGT"]=172,["GCCAGGGT"]=1,["GCCATGGG"]=3,["GCCATGTC"]=1,["GCCATGGC"]=3480,["GCCAGGGC"]=28,["GCCATAGC"]=1,["GCCATGGA"]=2,["GCCAGCCA"]=4,["GCCCTGGT"]=1,["GCCCGGGT"]=675,["GCCCGGAT"]=1,["GCCCGGGG"]=4,["GCCCGGTC"]=4,["GCCCGTGC"]=12,["GCCCTGGC"]=14,["GCCCGGGC"]=3928,["GCCCGCCC"]=4,["GCCCGGAC"]=5,["GCCCGGTA"]=2,["GCCCGGGA"]=39,["GCCGTGGT"]=5,["GCCGGGCG"]=1,["GCCGGCCG"]=2,["GCCGTGGC"]=406,["GCCGGGGC"]=6,["GCCGTGGA"]=1,["GCCGGGGA"]=1,["GCCTTGGT"]=7,["GCCTGGGT"]=5,["GCCTGTGC"]=1,
["GCCTTGGC"]=312,["GCCTGGGC"]=231,["GCCTGCGC"]=1,["GCCTTAGC"]=1,["GCGATCGT"]=33,["GCGATCAT"]=1,["GCGATCGG"]=2,["GCGATCCG"]=1,["GCGATTGC"]=11,["GCGATGGC"]=2,["GCGATCGC"]=2576,["GCGAGCGC"]=19,["GCGATAGC"]=1,["GCGATCAC"]=1,["GCGATCGA"]=2,["GCGCGCTT"]=1,["GCGCGTGT"]=2,["GCGCGGGT"]=1,["GCGCGCGT"]=405,["GCGCGCGG"]=4,["GCGCGTTC"]=1,["GCGCGGTC"]=1,["GCGCGCTC"]=20,["GCGCGTGC"]=57,["GCGCGGGC"]=56,["GCGCGCGC"]=3166,["GCGGTCGT"]=2,["GCGGTGCG"]=1,["GCGGTTGC"]=2,["GCGGTCGC"]=474,["GCGGTTCC"]=1,["GCGTGCGT"]=2,["GCGTGTGC"]=2,["GCGTTGGC"]=2,["GCGTGGGC"]=1,["GCGTTCGC"]=23,["GCTATAGT"]=7,["GCTATAGG"]=1,["GCTATTGC"]=2,["GCTATGGC"]=10,["GCTAGGGC"]=1,["GCTATAGC"]=2224,["GCTATAAC"]=1,["GCTCGGGT"]=2,["GCTCGCTC"]=2,["GCTCGTGC"]=21,["GCTCGGGC"]=221,["GCTCTAGC"]=10,["GCTGTAGT"]=2,["GCTGTAGG"]=1,["GCTGTCTC"]=1,["GCTGTTGC"]=2,["GCTGTGGC"]=4,["GCTGGGGC"]=1,["GCTGTCGC"]=1,["GCTGTAGC"]=116,["GCTGTGCC"]=1,["GCTTTATC"]=1,["GCTTTTGC"]=1,["GCTTTGGC"]=1,["GCTTGGGC"]=4,["GCTTTAGC"]=92,["GCTTTCAC"]=1,["GGAATTCT"]=6,["GGAATTTC"]=3,["GGAATTGC"]=4,["GGAATTCC"]=2012,["GGAATGCC"]=3,["GGAATCCC"]=2,["GGAATTAC"]=2,["GGAATTAA"]=1,["GGACGTTT"]=1,["GGACGTGT"]=1,["GGACGTCT"]=145,["GGACGTCG"]=25,["GGACGTTC"]=237,["GGACGTGC"]=137,["GGACTTCC"]=2,["GGACGTCC"]=3778,["GGACGGCC"]=77,["GGACTCCC"]=1,["GGACGTAC"]=54,["GGACGTCA"]=47,["GGAGTTCT"]=3,["GGAGTGAT"]=1,["GGAGTTGC"]=2,["GGAGTTCC"]=92,["GGAGGTCC"]=2,["GGAGTCCC"]=1,["GGAGTGAC"]=1,["GGAGTAAC"]=2,["GGATGTTC"]=2,["GGATTTGC"]=1,["GGATGTGC"]=4,["GGATTTCC"]=20,["GGATGTCC"]=536,["GGATTGCC"]=1,["GGATTGAC"]=1,["GGATGTCA"]=1,["GGCATGCT"]=151,["GGCATGCG"]=3,["GGCATGTC"]=31,["GGCAGGTC"]=1,["GGCATGGC"]=46,["GGCATGCC"]=3692,["GGCAGGCC"]=62,["GGCATACC"]=2,["GGCATGAC"]=16,["GGCATGCA"]=9,["GGCCGGTT"]=4,["GGCCGGGT"]=1,["GGCCGGCT"]=708,["GGCCGGCG"]=17,["GGCCGGTC"]=209,["GGCCGTGC"]=2,["GGCCTGGC"]=1,["GGCCGGGC"]=151,["GGCCGTCC"]=23,["GGCCTGCC"]=28,["GGCCGGCC"]=4270,["GGCCGTAC"]=2,["GGCCGGTA"]=1,["GGCCGGGA"]=1,["GGCGTGCT"]=5,["GGCGGGCT"]=1,["GGCGGGCG"]=2,["GGCGTGGC"]=1,["GGCGGTCC"]=2,["GGCGTGCC"]=808,["GGCGTGAC"]=1,["GGCTTGCT"]=9,["GGCTGGTC"]=1,["GGCTGTGC"]=1,["GGCTTGGC"]=2,["GGCTGGGC"]=2,["GGCTTTCC"]=1,["GGCTGTCC"]=1,["GGCTTGCC"]=360,["GGCTTGAC"]=1,["GGGATCGT"]=2,["GGGATCCT"]=17,["GGGATCCG"]=5,["GGGATCTC"]=7,["GGGATCGC"]=4,["GGGATTCC"]=7,["GGGATGCC"]=5,["GGGATCCC"]=3144,["GGGATACC"]=2,["GGGATCAC"]=2,["GGGATCCA"]=1,["GGGCGTCC"]=55,["GGGCTCCC"]=5,["GGGGTCGC"]=1,["GGGGTTCC"]=1,["GGGGTGCC"]=1,["GGGGTCCC"]=572,["GGGGTACC"]=1,["GGGGTCAC"]=2,["GGGTTCCT"]=2,["GGGTTCTC"]=1,["GGGTTTCC"]=1,["GGGTGTCC"]=1,["GGGTTCCC"]=38,["GGGTTACC"]=1,["GGTATACT"]=16,["GGTATACG"]=1,["GGTATATC"]=3,["GGTATAGC"]=5,["GGTATTCC"]=3,["GGTATGCC"]=18,["GGTATACC"]=3067,["GGTATAAC"]=3,["GGTCGTCT"]=1,["GGTCGTCG"]=1,["GGTCGTCC"]=8,["GGTCTACC"]=16,["GGTGTACT"]=4,["GGTGTTAT"]=1,["GGTGTACG"]=1,["GGTGTTCC"]=3,["GGTGGTCC"]=1,["GGTGTGCC"]=6,["GGTGTACC"]=149,["GGTTTACT"]=3,["GGTTTAGC"]=2,["GGTTGTCC"]=1,["GGTTTGCC"]=2,["GGTTTACC"]=152,["GTAATCTT"]=1,["GTAATTAT"]=2,["GTAATTTC"]=2,["GTAATTGC"]=2,["GTAATTAC"]=424,
["GTAAGTAC"]=2,["GTAATAAC"]=1,["GTACGTTT"]=1,["GTACGTCT"]=1,["GTACGTAT"]=15,["GTACGTAG"]=1,["GTACGTTC"]=7,["GTACGTGC"]=68,["GTACGTCC"]=2,["GTACTTAC"]=2,["GTACGTAC"]=2674,["GTACTGAC"]=1,["GTACTCAC"]=1,["GTAGTTTC"]=1,["GTAGTTAC"]=6,["GTATTTAC"]=2,["GTCATGGT"]=1,["GTCATGCT"]=2,["GTCATGAT"]=77,["GTCATGAG"]=1,["GTCATGGC"]=5,["GTCATGCC"]=1,["GTCATGAC"]=2694,["GTCATAAC"]=4,["GTCCGTCC"]=2,["GTCCTGAC"]=9,["GTCGTGAT"]=1,["GTCGTGGC"]=2,["GTCGTGCC"]=2,["GTCGTGAC"]=327,["GTCTTGAT"]=6,["GTCTTGTC"]=2,["GTCTTGGC"]=2,["GTCTTGCC"]=1,["GTCTTGAC"]=294,["GTGATCAT"]=26,["GTGATTTC"]=1,["GTGATCGC"]=3,["GTGATTAC"]=6,["GTGATGAC"]=1,["GTGATCAC"]=2390,["GTGATAAC"]=2,["GTGAGTGA"]=4,["GTGATCGA"]=1,["GTGCGTGT"]=1,["GTGCGTTC"]=1,["GTGCTCAC"]=2,["GTGGTCTC"]=2,["GTGGTCGC"]=3,["GTGGTTAC"]=2,["GTGGTCAC"]=162,["GTGTTACC"]=1,["GTGTTCAC"]=26,["GTGTTAAC"]=1,["GTGTTAAA"]=1,["GTTATACT"]=1,["GTTATAAT"]=12,["GTTATATC"]=1,["GTTATAGC"]=1,["GTTATACC"]=3,["GTTATTAC"]=2,["GTTATGAC"]=21,["GTTATCAC"]=1,["GTTATAAC"]=1488,["GTTATATA"]=1,["GTTCTAAT"]=1,["GTTCGTTC"]=2,["GTTCTAAC"]=14,["GTTGTATC"]=1,["GTTGTTAC"]=1,["GTTGTGAC"]=3,["GTTGTAAC"]=100,["GTTTTAAT"]=1,["GTTTTTTC"]=2,["GTTTTGAC"]=2,["GTTTTAAC"]=88,["TAAATTTA"]=41,["TAAATGTA"]=1,["TAAGTGCT"]=1,["TAATTTTT"]=1,["TAATTTTA"]=1,["TACATGTT"]=16,["TACATGTG"]=18,["TACATGTC"]=4,["TACATGTA"]=380,["TACATGCA"]=1,["TACGTGTG"]=1,["TACGTTGC"]=1,["TACGTGGC"]=1,["TACGTGTA"]=25,["TACGTGGA"]=1,["TACTTACT"]=2,["TACTTGTA"]=5,["TAGATCTT"]=2,["TAGATCTG"]=3,["TAGATCTC"]=1,["TAGATCTA"]=94,["TAGCTCTA"]=1,["TAGGTCTA"]=8,["TAGTTCTA"]=1,["TATATGTT"]=1,["TATATATT"]=2,["TATATATG"]=3,["TATATATC"]=1,["TATATGTA"]=1,["TATATATA"]=42,["TATCTGTG"]=1,["TATGTATG"]=2,["TCAATTGT"]=2,["TCAATTGG"]=3,["TCAATTGA"]=93,["TCAATCGA"]=1,["TCACTCAC"]=2,["TCACTTGA"]=1,["TCAGTTGA"]=2,["TCATTTGA"]=1,["TCCATGGT"]=3,["TCCATGGG"]=90,["TCCATGGC"]=2,["TCCATGGA"]=768,["TCCCTGGG"]=1,["TCCCTGGA"]=1,["TCCGTGGG"]=1,["TCCGTGGA"]=28,["TCCTTGGG"]=2,["TCCTTGGA"]=19,["TCGATCGT"]=2,["TCGATCGG"]=25,["TCGATTGA"]=1,["TCGATCGA"]=296,["TCGGTCGT"]=1,["TCGGTCGG"]=2,["TCTATTGG"]=1,["TCTATGGA"]=3,["TCTGTGGT"]=1,["TCTGTGGA"]=1,["TGAATTCT"]=3,["TGAATTTG"]=1,["TGAATTCG"]=6,["TGAATTCC"]=1,["TGAATGAC"]=1,["TGAATTCA"]=222,["TGACTGAC"]=2,["TGAGTTCG"]=1,["TGAGTTCA"]=8,["TGATTTCT"]=1,["TGCATGTT"]=1,["TGCATGCT"]=48,["TGCATGCG"]=193,["TGCATGCC"]=1,["TGCATGGA"]=1,["TGCATGCA"]=1958,["TGCGTGCT"]=5,["TGCGTGCG"]=10,["TGCGTGGA"]=1,["TGGATTAC"]=1,["TGGATTCA"]=1,["TGGCTGGC"]=2,["TGGGTTCA"]=1,["TGTGTTCG"]=1,["TGTTTTCA"]=1,["TTAATTAT"]=1,["TTAATTAA"]=4,["TTGATTGA"]=2,}

fragment.overhang_efficiency = function(fwd: string, rev: string): integer
  local to_check: string
  -- Sort overhangs alphabetically
  if fwd < rev then
    to_check = fwd .. rev
  else
    to_check = rev .. fwd
  end
  local output = fragment.fragmentation_table[to_check]
  if output == nil then output = 0 end
  return output
end

fragment.set_efficiency = function(overhangs: {string}): number
  local efficiency:number = 1.0
  for _, overhang in ipairs(overhangs) do
    if overhang == nil or overhang == "" then error("Got bad overhang") end
    local n_correct = fragment.overhang_efficiency(overhang, complement.reverse_complement(overhang))
    local n_total:number = n_correct
    -- Detect palindromes. This halves this overhang's efficiency
    if overhang == complement.reverse_complement(overhang) then
      n_total = n_total + n_correct
    end
    for _, overhang2 in ipairs(overhangs) do
      if overhang2 ~= overhang then
        local fragment_offset = fragment.overhang_efficiency(overhang, complement.reverse_complement(overhang2))
        n_total = n_total + fragment_offset
      end
    end
    efficiency = efficiency * (n_correct / n_total)
  end
  return efficiency
end

--[[---------------------------------------------------------------------------
fragment.next_overhangs and fragment.next_overhang have some fundamental
limitations. The algorithm to find the most effective next overhang is rather
naive, since it doesn't actually look more than 1 step ahead. For example, if
AAAA and ATGC are of equal efficiency this round, but ATGC eliminates a lot of
possible overhangs next round, fragment.next_overhangs cannot differentiate
between AAAA and ATGC

--]]---------------------------------------------------------------------------

fragment.next_overhangs = function(overhangs: {string}): {string}, {number}
  -- Build a current overhang table
  local current_overhangs: {string:boolean} = {}
  for _, overhang in ipairs(overhangs) do
    current_overhangs[overhang] = true
  end
  local overhangs_to_test:{string} = {}
  local bases = {"A", "T", "G", "C"}
  for base1=1,4 do
    for base2=1,4 do
      for base3=1,4 do
        for base4=1,4 do
          local quad_base = bases[base1] .. bases[base2] .. bases[base3] .. bases[base4]
          if current_overhangs[quad_base] == nil then
            overhangs_to_test[#overhangs_to_test+1] = quad_base
          end
        end
      end
    end
  end
  local overhang_efficiency:{number} = {}
  for idx, quad_base in ipairs(overhangs_to_test) do
    local test_set: {string} = {}
    for _, overhang in ipairs(overhangs) do
      test_set[#test_set+1] = overhang
    end
    test_set[#test_set+1] = quad_base
    overhang_efficiency[idx] = fragment.set_efficiency(test_set)
  end
  return overhangs_to_test, overhang_efficiency
end

fragment.next_overhang = function(overhangs: {string}): string
  local overhangs_to_test, efficiencies = fragment.next_overhangs(overhangs)
  local max_efficiency: number = 0
  local new_overhang: string = ""
  for i, overhang in ipairs(overhangs_to_test) do
    if efficiencies[i] > max_efficiency then
      max_efficiency = efficiencies[i]
      new_overhang = overhang
    end
  end
  if new_overhang == "" then error("no new overhangs available") end
  return new_overhang
end

fragment.fragment_sequence = function(sequence: string, min_length: integer, max_length: integer): {string}, number
  sequence = sequence:upper()
  -- min_length cannot be greater than max_length
  if min_length > max_length then error("min_length larger than max_length") end

  -- Minimum lengths (given oligos) for assembly is 8 base pairs.
  -- https://doi.org/10.1186/1756-0500-3-291
  -- For GoldenGate, 2 8bp oligos create 12 base pairs (4bp overhangs on two sides of 4bp),
  if min_length < 12 then error("min_length too small") end

  -- begin optimization after checks
  local function optimize_overhang_iteration(s: string, min: integer, max: integer, existing_fragments: {string}, existing_overhangs: {string}): {string}, number
    -- If the sequence is smaller than max_length, stop iteration.
    if #s < max then
      existing_fragments[#existing_fragments+1] = s
      return existing_fragments, fragment.set_efficiency(existing_overhangs)
    end

    -- If our iteration is approaching the end of the sequence, that means we
    -- need to gracefully handle the end so we aren't left with a tiny fragment
    -- that cannot be synthesized. For example, if our goal is fragments of
    -- 100bp, and we have 110 base pairs left, we want each final fragment to
    -- be 55bp, not 100bp and 10bp
    local min_len = min
    local max_len = max
    if #s < 2*max then
      local max_and_min_difference = max - min
      local max_fragment_size_buffer = (#s + max_and_min_difference) / 2 as integer
      if max_fragment_size_buffer > max then
        max_fragment_size_buffer = max
      end
      min_len = (max_fragment_size_buffer - max_and_min_difference) as integer
      max_len = max_fragment_size_buffer as integer
    end

    -- Get all sets of 4 between min and max fragment size
    local best_overhang_efficiency: number = 0
    local best_overhang_position: integer = 0
    local already_exists: boolean = false
    local offset = 0
    while offset <= max_len-min_len do
      -- We go from max -> min so that we maximize the size of our fragments
      local overhang_position = (max_len - offset) as integer
      local overhang_to_test = s:sub(overhang_position-3, overhang_position)

      -- Check to make this overhang doesn't already exist
      already_exists = false
      for _, existing_overhang in ipairs(existing_overhangs) do
        if (existing_overhang == overhang_to_test) or (complement.reverse_complement(existing_overhang) == overhang_to_test) then
          already_exists = true
        end
      end
      
      if not already_exists then
        local test_set: {string} = {}
        for _, overhang in ipairs(existing_overhangs) do
          test_set[#test_set+1] = overhang
        end
        test_set[#test_set+1] = overhang_to_test
        local set_efficiency = fragment.set_efficiency(test_set)
        if set_efficiency > best_overhang_efficiency then
          best_overhang_position = overhang_position
          best_overhang_efficiency = set_efficiency
        end
      end

      offset = offset + 1
    end

    -- Set variables
    existing_fragments[#existing_fragments+1] = s:sub(1, best_overhang_position)
    existing_overhangs[#existing_overhangs+1] = s:sub(best_overhang_position-3, best_overhang_position)
    s = s:sub(best_overhang_position-3,-1)
    return optimize_overhang_iteration(s, min, max, existing_fragments, existing_overhangs)

  end

  return optimize_overhang_iteration(sequence, min_length, max_length, {}, {})
end

--[[---------------------------------------------------------------------------
The codon module provides functions to work with codon tables, including the
translation of DNA/RNA into protein and the codon optimization (given a certain
organism's codon table) of a protein sequence into a nucleotide sequence.
]]-----------------------------------------------------------------------------
local record codon
    record Codon
        triplet: string
        weight: number
    end
    record AminoAcid
        letter: string
        codons: {Codon}
    end

    record CodonTable
        start_codons: {Codon}
        amino_acids: {AminoAcid}
    end

    CODON_TABLES: {number:{string, string}}
end

--[[---------------------------------------------------------------------------
July, 06, 2022

Codon table generation begins here.

Different organisms use different codons to represent different amino acids.
NCBI publishes this weird data format for developers to use for generating
codon tables and mapping codons for different organisms. All of the following
codon tables are experimentally validated.

]]-----------------------------------------------------------------------------

--- codon.CODON_TABLES are current NCBI sanctioned codon tables with their respective numbers.
-- @field 1 Translation table 1
-- @field 2 Translation table 2
-- @field 3 Translation table 3
-- @field 4 Translation table 4
-- @field 5 Translation table 5
-- @field 6 Translation table 6
-- @field 7 Translation table 7
-- @field 8 Translation table 8
-- @field 9 Translation table 9
-- @field 10 Translation table 10
-- @field 11 Translation table 11
-- @field 12 Translation table 12
-- @field 13 Translation table 13
-- @field 14 Translation table 14
-- @field 15 Translation table 15
-- @field 16 Translation table 16
-- @field 17 Translation table 17
-- @field 18 Translation table 18
-- @field 19 Translation table 19
-- @field 20 Translation table 20
-- @field 21 Translation table 21
-- @field 22 Translation table 22
-- @field 23 Translation table 23
-- @field 24 Translation table 24
-- @field 25 Translation table 25
-- @field 26 Translation table 26
-- @field 27 Translation table 27
-- @field 28 Translation table 28
-- @field 29 Translation table 29
-- @field 30 Translation table 30
-- @field 31 Translation table 31
-- @field 32 Translation table 32
-- @field 33 Translation table 33
-- @table CODON_TABLES
codon.CODON_TABLES = {
    [1] = {"FFLLSSSSYY**CC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", "---M------**--*----M---------------M----------------------------"},
    [2] = {"FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIMMTTTTNNKKSS**VVVVAAAADDEEGGGG", "----------**--------------------MMMM----------**---M------------"},
    [3] = {"FFLLSSSSYY**CCWWTTTTPPPPHHQQRRRRIIMMTTTTNNKKSSRRVVVVAAAADDEEGGGG", "----------**----------------------MM---------------M------------"},
    [4] = {"FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", "--MM------**-------M------------MMMM---------------M------------"},
    [5] = {"FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIMMTTTTNNKKSSSSVVVVAAAADDEEGGGG", "---M------**--------------------MMMM---------------M------------"},
    [6] = {"FFLLSSSSYYQQCC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", "--------------*--------------------M----------------------------"},
    [9] = {"FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIIMTTTTNNNKSSSSVVVVAAAADDEEGGGG", "----------**-----------------------M---------------M------------"},
    [10] = {"FFLLSSSSYY**CCCWLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", "----------**-----------------------M----------------------------"},
    [11] = {"FFLLSSSSYY**CC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", "---M------**--*----M------------MMMM---------------M------------"},
    [12] = {"FFLLSSSSYY**CC*WLLLSPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", "----------**--*----M---------------M----------------------------"},
    [13] = {"FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIMMTTTTNNKKSSGGVVVVAAAADDEEGGGG", "---M------**----------------------MM---------------M------------"},
    [14] = {"FFLLSSSSYYY*CCWWLLLLPPPPHHQQRRRRIIIMTTTTNNNKSSSSVVVVAAAADDEEGGGG", "-----------*-----------------------M----------------------------"},
    [16] = {"FFLLSSSSYY*LCC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", "----------*---*--------------------M----------------------------"},
    [21] = {"FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIMMTTTTNNNKSSSSVVVVAAAADDEEGGGG", "----------**-----------------------M---------------M------------"},
    [22] = {"FFLLSS*SYY*LCC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", "------*---*---*--------------------M----------------------------"},
    [23] = {"FF*LSSSSYY**CC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", "--*-------**--*-----------------M--M---------------M------------"},
    [24] = {"FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSSKVVVVAAAADDEEGGGG", "---M------**-------M---------------M---------------M------------"},
    [25] = {"FFLLSSSSYY**CCGWLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", "---M------**-----------------------M---------------M------------"},
    [26] = {"FFLLSSSSYY**CC*WLLLAPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", "----------**--*----M---------------M----------------------------"},
    [27] = {"FFLLSSSSYYQQCCWWLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", "--------------*--------------------M----------------------------"},
    [28] = {"FFLLSSSSYYQQCCWWLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", "----------**--*--------------------M----------------------------"},
    [29] = {"FFLLSSSSYYYYCC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", "--------------*--------------------M----------------------------"},
    [30] = {"FFLLSSSSYYEECC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", "--------------*--------------------M----------------------------"},
    [31] = {"FFLLSSSSYYEECCWWLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", "----------**-----------------------M----------------------------"},
    [33] = {"FFLLSSSSYYY*CCWWLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSSKVVVVAAAADDEEGGGG", "---M-------*-------M---------------M---------------M------------"},
}


--- Generates a codon table from a list of amino acids and a list of start codons, given in the standard NCBI codon table format.
-- @param amino_acids the amino acid string
-- @param starts the start codon string
-- @return a codon table
-- @usage local ct = codon.ncbi_standard_to_codon_table("FFLLSSSSYY**CC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", "---M------**--*----M------------MMMM---------------M------------")
function codon.ncbi_standard_to_codon_table(amino_acids: string, starts:string): codon.CodonTable 
    local base1 = "TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG"
    local base2 = "TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG"
    local base3 = "TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG"
    local amino_acid_table: {string:{codon.Codon}} = {}
    local ct: codon.CodonTable = {}
    ct.start_codons = {}
    for i = 1, #amino_acids do
        local triplet: string = base1:sub(i,i) .. base2:sub(i,i) .. base3:sub(i,i)
        -- Generate start_codons
        if starts:sub(i,i) == "M" then
            local start_codon: codon.Codon
            start_codon = {triplet = triplet, weight = 0}
            ct.start_codons[#ct.start_codons+1] = start_codon
        end
        -- Generate amino_acids
        local amino_acid = amino_acids:sub(i,i)
        if amino_acid_table[amino_acid] == nil then
            amino_acid_table[amino_acid] = {{triplet = triplet, weight = 0}}
        else
            amino_acid_table[amino_acid][#amino_acid_table[amino_acid]+1] = {triplet = triplet, weight = 0}
        end
    end

    -- Fill in codon table
    ct.amino_acids = {}
    for amino_acid, codons in pairs(amino_acid_table) do
        ct.amino_acids[#ct.amino_acids+1] = {letter = amino_acid, codons = codons}
    end
    return ct
end

--- Generates a new codon table given an NCBI codon table number.
-- @param table_number the table number
-- @return a codon table
-- @usage local ct = codon.new_table(11)
function codon.new_table(table_number: number): codon.CodonTable
    return codon.ncbi_standard_to_codon_table(codon.CODON_TABLES[table_number][1], codon.CODON_TABLES[table_number][2])
end
--[[---------------------------------------------------------------------------
July, 21, 2022

Codon table filling begins here.

In order to be useful for optimization or fixing, codon tables need to be
filled with data.

]]-----------------------------------------------------------------------------

--[[---------------------------------------------------------------------------
July, 21, 2022

Compromise + Add codon table begins here.

## Compromise tables
If you want to codon optimize a protein for two or more organisms, you will
want a codon table that works for both organisms. Compromise codon tables
standardize codon counts so the weights are equal between both organisms.
Then, they are added together. There is also a variable for removing rare
codons, which is essential to get good protein yield in many organisms(however,
this feature makes compromise tables lossy).

]]-----------------------------------------------------------------------------

--[[---------------------------------------------------------------------------
The synbio module contains all of synbiolua in a single module to enable
embedding into larger programs. All other modules are built into synbio.
]]-----------------------------------------------------------------------------


local record synbio
    version: string
    complement: complement
    fasta: fasta
    fastq: fastq
    primers: primers
    pcr: pcr
    genbank: genbank
    codon: codon
    fragment: fragment
    json: json
end

synbio.version = "0.0.1"
synbio.complement = complement
synbio.fasta = fasta
synbio.fastq = fastq
synbio.primers = primers
synbio.pcr = pcr
synbio.genbank = genbank
synbio.codon = codon
synbio.fragment = fragment
synbio.json = json

--[[---------------------------------------------------------------------------

                           Atoms 

---------------------------------------------------------------------------]]--

local record atoms
  atoms_mw: {string: number}
  formula_to_mw: function(string): number
end

atoms.atoms_mw = {
  H = 1.007,
  He = 4.002,
  Li = 6.941,
  Be = 9.012,
  B = 10.811,
  C = 12.011,
  N = 14.007,
  O = 15.999,
  F = 18.998,
  Ne = 20.18,
  Na = 22.99,
  Mg = 24.305,
  Al = 26.982,
  Si = 28.086,
  P = 30.974,
  S = 32.065,
  Cl = 35.453,
  Ar = 39.948,
  K = 39.098,
  Ca = 40.078,
  Sc = 44.956,
  Ti = 47.867,
  V = 50.942,
  Cr = 51.996,
  Mn = 54.938,
  Fe = 55.845,
  Co = 58.933,
  Ni = 58.693,
  Cu = 63.546,
  Zn = 65.38,
  Ga = 69.723,
  Ge = 72.64,
  As = 74.922,
  Se = 78.96,
  Br = 79.904,
  Kr = 83.798,
  Rb = 85.468,
  Sr = 87.62,
  Y = 88.906,
  Zr = 91.224,
  Nb = 92.906,
  Mo = 95.96,
  Tc = 98,
  Ru = 101.07,
  Rh = 102.906,
  Pd = 106.42,
  Ag = 107.868,
  Cd = 112.411,
  In = 114.818,
  Sn = 118.71,
  Sb = 121.76,
  Te = 127.6,
  I = 126.904,
  Xe = 131.293,
  Cs = 132.905,
  Ba = 137.327,
  La = 138.905,
  Ce = 140.116,
  Pr = 140.908,
  Nd = 144.242,
  Pm = 145,
  Sm = 150.36,
  Eu = 151.964,
  Gd = 157.25,
  Tb = 158.925,
  Dy = 162.5,
  Ho = 164.93,
  Er = 167.259,
  Tm = 168.934,
  Yb = 173.054,
  Lu = 174.967,
  Hf = 178.49,
  Ta = 180.948,
  W = 183.84,
  Re = 186.207,
  Os = 190.23,
  Ir = 192.217,
  Pt = 195.084,
  Au = 196.967,
  Hg = 200.59,
  Tl = 204.383,
  Pb = 207.2,
  Bi = 208.98,
  Po = 210,
  At = 210,
  Rn = 222,
  Fr = 223,
  Ra = 226,
  Ac = 227,
  Th = 232.038,
  Pa = 231.036,
  U = 238.029,
  Np = 237,
  Pu = 244,
  Am = 243,
  Cm = 247,
  Bk = 247,
  Cf = 251,
  Es = 252,
  Fm = 257,
  Md = 258,
  No = 259,
  Lr = 262,
  Rf = 261,
  Db = 262,
  Sg = 266,
  Bh = 264,
  Hs = 267,
  Mt = 268,
  Ds  = 271,
  Rg  = 272,
  Cn  = 285,
  Nh = 284,
  Fl = 289,
  Mc = 288,
  Lv = 292,
  Ts = 295,
  Og = 294,
}

atoms.formula_to_mw = function(formula: string): number
  local mw: number = 0
  local atom: string
  local lower_case_character: string
  local quantity: integer
  for group in formula:gmatch("([^.]+)") do -- splits formula by .
    local multipler: integer = nil
    local multipler_string = group:match("^[%d]+")
    if multipler_string == nil then multipler = 1 else multipler = tonumber(multipler_string) as integer end
    if multipler == nil then multipler = 1 end -- if multipler is nil, it is equal to 1
    group = group:gsub("^[%d]+", "") -- remove beginning digits
    while group:match("^%u") do -- So long as there is another atom, continue along

      atom = group:match("^%u") -- Match atom char 1
      group = group:gsub("^%u", "")

      lower_case_character = nil -- Match atom char 2
      lower_case_character = group:match("^%l")
      if lower_case_character ~= nil then
        group = group:gsub("^%l", "")
        atom = atom .. lower_case_character
      end

      -- Get quantity
      quantity = nil
      local quantity_string = group:match("^[%d]+")
      if quantity_string == nil then quantity = 1 else quantity = tonumber(quantity_string) as integer end
      group = group:gsub("^[%d]+", "") -- Remove quantity from string

      -- Append quantity to mw
      quantity = quantity * multipler -- Add multipler
      mw = mw + (atoms.atoms_mw[atom] * quantity)
    end
  end
  return mw
end

--[[---------------------------------------------------------------------------

                                Conversions

---------------------------------------------------------------------------]]--

local record conversions
  -- Useful conversions
  mol: number
  mmol: number
  umol: number
  nmol: number
  pmol: number
  fmol: number
  amol: number
  
  l: number
  ml: number
  ul: number
  nl: number
  
  kg: number
  g: number
  mg: number
  ug: number
  ng: number
  pg: number
  fg: number
  g_to_mol: function(number, number): number
end

-- Conversions
conversions.mol = 6.02214076*(10^23) -- BIPM effective 20 May 2019
conversions.mmol = conversions.mol  / 1000
conversions.umol = conversions.mmol / 1000
conversions.nmol = conversions.umol / 1000
conversions.pmol = conversions.nmol / 1000
conversions.fmol = conversions.pmol / 1000
conversions.amol = conversions.fmol / 1000

conversions.l = (1000 / 18.02) * conversions.mol -- 18.02g per mole of water, 1000g in 1 L
conversions.ml = conversions.l  / 1000
conversions.ul = conversions.ml / 1000
conversions.nl = conversions.ul / 1000

conversions.kg = 1000
conversions.g = 1
conversions.mg = conversions.g / 1000
conversions.ug = conversions.mg / 1000
conversions.ng = conversions.ug / 1000
conversions.pg = conversions.ng / 1000
conversions.fg = conversions.pg / 1000

function conversions.g_to_mol(g: number, molecular_weight: number): number
    return g / molecular_weight * conversions.mol
end


local record mixtures
  record Chemical
      inchi: string
      formula: function(Chemical): string
      g_to_mol: function(Chemical, number): number
  metamethod __mul: function(Chemical, number): Mixture
  end
  chemical_mt: metatable<Chemical>
  record Sequence
      seqhash: string
      sequence: string
      molecule_type: string
      dna: boolean
      double_stranded: boolean
      circular: boolean
      metamethod __mul: function(Sequence, number): Mixture
  end
  sequence_mt: metatable<Sequence>
  record Protein
      sequence: string
      protein_to_mw: function(Protein): number
      g_to_mol: function(Protein, number): number
      metamethod __mul: function(Protein, number): Mixture
  end
  protein_mt: metatable<Protein>
  record Cell
    name: string
    metamethod __mul: function(Cell, number): Mixture
  end
  cell_mt: metatable<Cell>
  record Environmental
      name: string
      metamethod __mul: function(Environmental, number): Mixture
  end
  environmental_mt: metatable<Environmental>

  -- Mixtures
  record Mixture_ChemicalMix
      chemical: Chemical
      quantity: number
  end
  record Mixture_SequenceMix
      sequence: Sequence
      quantity: number
  end
  record Mixture_ProteinMix
      protein: Protein
      quantity: number
  end
  record Mixture_CellMix
      cell: Cell
      quantity: number
  end
  record Mixture_EnvironmentalMix
      environmental: Environmental
      quantity: number
  end
  record Mixture
    chemicals: {Mixture_ChemicalMix}
    sequences: {Mixture_SequenceMix}
    proteins: {Mixture_ProteinMix}
    cells: {Mixture_CellMix}
    environmentals: {Mixture_EnvironmentalMix}
    volume: function(Mixture, number): Mixture
    metamethod __add: function(Mixture, Mixture): Mixture
    metamethod __mul: function(Mixture, number): Mixture
    metamethod __div: function(Mixture, number): Mixture
  end
  mixture_mt: metatable<Mixture>
  volume: function(Mixture, number): Mixture

  -- Defaults
  chemicals: {string: Chemical}
  amino_acids: {string: Chemical}
  sequences: {string: Sequence}
  proteins: {string: Protein}
  cells: {string: Cell}
  environmentals: {string: Environmental}
  common_reagents: {string: Mixture}

  amino_acid_weights: {string: number}
  nucleotide_weights: {string: number}

end

--[[---------------------------------------------------------------------------

                               Base functions for metatables

---------------------------------------------------------------------------]]--

local function deepcopy(obj:any): any
  if type(obj) ~= 'table' then return obj end
  local obj_table: {any:any} = obj as {any:any}
  local res = setmetatable({} as {any:any}, getmetatable(obj as {any:any}))
  for k, v in pairs(obj_table) do res[deepcopy(k)] = deepcopy(v) end
  return res
end

-- Returns a mixture at a certain volume
mixtures.volume = function(self: mixtures.Mixture, volume: number): mixtures.Mixture
  local copy: mixtures.Mixture = deepcopy(self) as mixtures.Mixture
    -- Error check if there is no water
    local water_quantity: number = nil
    for _, chemical in ipairs(copy.chemicals) do
        if chemical.chemical.inchi == mixtures.chemicals.H2O.inchi then
            water_quantity = chemical.quantity
        end
    end
    if water_quantity == nil then
        error("no volume")
    end
    local ratio: number = volume / water_quantity
    for _, chemical in ipairs(copy.chemicals) do
        chemical.quantity = chemical.quantity * ratio
    end

  if copy.cells ~= nil then
    for _, cell in ipairs(copy.cells) do
      cell.quantity = cell.quantity * ratio
    end
  end
    return copy
end

--[[---------------------------------------------------------------------------

                                Metatables

---------------------------------------------------------------------------]]--

mixtures.mixture_mt = {
	__add = function<T>(self: mixtures.Mixture, t: mixtures.Mixture): mixtures.Mixture
		local copy: mixtures.Mixture = deepcopy(self) as mixtures.Mixture

		-- Note: I did try to make this generic, but it became unwieldy.
		-- I found it better to have it like this. Perhaps there is a better
		-- way, but I found it good enough.

		-- Handle chemical addition
		if t.chemicals ~= nil then
      if copy.chemicals == nil then copy.chemicals = {} end
			for _, chemicalMix in ipairs(t.chemicals) do
				local found = false
				for i, tbl in ipairs(copy.chemicals) do
					if tbl.chemical.inchi == chemicalMix.chemical.inchi then
						copy.chemicals[i].quantity = copy.chemicals[i].quantity + chemicalMix.quantity
						found = true
					end
				end
				if not found then
					local newSubmix: mixtures.Mixture_ChemicalMix = {chemical = chemicalMix.chemical, quantity = chemicalMix.quantity}
					newSubmix = deepcopy(newSubmix) as mixtures.Mixture_ChemicalMix
					if copy.chemicals == nil then
						copy.chemicals = {newSubmix}
					else
						copy.chemicals[#copy.chemicals+1] = newSubmix
					end
				end
			end
		end

		-- EDIT BELOW USING TEMPLATE FROM ABOVE
		if t.sequences ~= nil then
      if copy.sequences == nil then copy.sequences = {} end
			for _, sequenceMix in ipairs(t.sequences) do
        	    local found = false
        	    for i, tbl in ipairs(copy.sequences) do
        	        if tbl.sequence.seqhash == sequenceMix.sequence.seqhash then
        	            copy.sequences[i].quantity = copy.sequences[i].quantity + sequenceMix.quantity
        	            found = true
        	        end
        	    end
        	   if not found then
        	        local newSubmix: mixtures.Mixture_SequenceMix = {sequence = sequenceMix.sequence, quantity = sequenceMix.quantity}
        	        newSubmix = deepcopy(newSubmix) as mixtures.Mixture_SequenceMix
        	        if copy.sequences == nil then
        	            copy.sequences = {newSubmix}
        	        else
        	            copy.sequences[#copy.sequences+1] = newSubmix
        	        end
        	    end
        	end
		end
		if t.proteins ~= nil then
      if copy.proteins == nil then copy.proteins = {} end
			for _, proteinMix in ipairs(t.proteins) do
        	    local found = false
        	    for i, tbl in ipairs(copy.proteins) do
        	        if tbl.protein.sequence == proteinMix.protein.sequence then
        	            copy.proteins[i].quantity = copy.proteins[i].quantity + proteinMix.quantity
        	            found = true
        	        end
        	    end
        	    if not found then
        	        local newSubmix: mixtures.Mixture_ProteinMix = {protein = proteinMix.protein, quantity = proteinMix.quantity}
        	        newSubmix = deepcopy(newSubmix) as mixtures.Mixture_ProteinMix
        	        if copy.proteins == nil then
        	            copy.proteins = {newSubmix}
        	        else
        	            copy.proteins[#copy.proteins+1] = newSubmix
        	        end
        	    end
        	end
		end
		if t.cells ~= nil then
      if copy.cells == nil then copy.cells = {} end
			for _, cellMix in ipairs(t.cells) do
        	    local found = false
        	    for i, tbl in ipairs(copy.cells) do
        	        if tbl.cell.name == cellMix.cell.name then
        	            copy.cells[i].quantity = copy.cells[i].quantity + cellMix.quantity
        	            found = true
        	        end
        	    end
        	    if not found then
        	        local newSubmix: mixtures.Mixture_CellMix = {cell = cellMix.cell, quantity = cellMix.quantity}
        	        newSubmix = deepcopy(newSubmix) as mixtures.Mixture_CellMix
        	        if copy.cells == nil then
        	            copy.cells = {newSubmix}
        	        else
        	            copy.cells[#copy.cells+1] = newSubmix
        	        end
        	    end
        	end
		end
		if t.environmentals ~= nil then
      if copy.environmentals == nil then copy.environmentals = {} end
			for _, environmentalMix in ipairs(t.environmentals) do
        	    local found = false
        	    for i, tbl in ipairs(copy.environmentals) do
        	        if tbl.environmental.name == environmentalMix.environmental.name then
        	            copy.environmentals[i].quantity = copy.environmentals[i].quantity + environmentalMix.quantity
        	            found = true
        	        end
        	    end
        	    if not found then
        	        local newSubmix: mixtures.Mixture_EnvironmentalMix = {environmental = environmentalMix.environmental, quantity = environmentalMix.quantity}
        	        newSubmix = deepcopy(newSubmix) as mixtures.Mixture_EnvironmentalMix
        	        if copy.environmentals == nil then
        	            copy.environmentals = {newSubmix}
        	        else
        	            copy.environmentals[#copy.environmentals+1] = newSubmix
        	        end
        	    end
        	end
		end

		return copy
	end,

	__mul = function(self: mixtures.Mixture, quantity: number): mixtures.Mixture
		local record Quant
			quantity: number
		end
		local tbls: {{Quant}} = {self.chemicals, self.sequences, self.proteins, self.cells, self.environmentals} as {{Quant}}
		for _, tbl in ipairs(tbls) do
			if tbl ~= nil then
				for _, sub_tbl in ipairs(tbl) do
					sub_tbl.quantity = sub_tbl.quantity * quantity
				end
			end
		end
    	return self
	end,

	__div = function(self: mixtures.Mixture, quantity: number): mixtures.Mixture
		local record Quant
            quantity: number
        end
        local tbls: {{Quant}} = {self.chemicals, self.sequences, self.proteins, self.cells, self.environmentals} as {{Quant}}
        for _, tbl in ipairs(tbls) do
            if tbl ~= nil then
                for _, sub_tbl in ipairs(tbl) do
                    sub_tbl.quantity = sub_tbl.quantity / quantity
                end
            end
        end
        return self
	end
}

mixtures.chemical_mt = {
    __mul = function(self: mixtures.Chemical, quantity: number): mixtures.Mixture
		  local mix = setmetatable({chemicals = {{chemical = self, quantity = quantity}}} as mixtures.Mixture, mixtures.mixture_mt)
		  mix.volume = mixtures.volume
		  return mix
    end
}

mixtures.sequence_mt = {
    __mul = function(self: mixtures.Sequence, quantity: number): mixtures.Mixture
      local mix = setmetatable({sequences = {{sequence = self, quantity = quantity}}} as mixtures.Mixture, mixtures.mixture_mt)
      mix.volume = mixtures.volume
      return mix
    end
}

mixtures.protein_mt = {
    __mul = function(self: mixtures.Protein, quantity: number): mixtures.Mixture
      local mix = setmetatable({proteins = {{protein = self, quantity = quantity}}} as mixtures.Mixture, mixtures.mixture_mt)
      mix.volume = mixtures.volume
      return mix
    end
}

mixtures.cell_mt = {
	__mul = function(self: mixtures.Cell, quantity: number): mixtures.Mixture
		local mix = setmetatable({cells = {{cell = self, quantity = quantity}}} as mixtures.Mixture, mixtures.mixture_mt)
		mix.volume = mixtures.volume
		return mix
	end
}

mixtures.environmental_mt = {
    __mul = function(self: mixtures.Environmental, quantity: number): mixtures.Mixture
      local mix = setmetatable({environmentals = {{environmnetal = self, quantity = quantity}}} as mixtures.Mixture, mixtures.mixture_mt)
      mix.volume = mixtures.volume
      return mix
    end
}

--[[---------------------------------------------------------------------------

Defaults

---------------------------------------------------------------------------]]--

local chemicals: {string: mixtures.Chemical} = {
    -- H2O is special because it contributes to calculated volume
    H2O = {inchi = "InChI=1S/H2O/h1H2"},

    biotin = {inchi = "InChI=1S/C10H16N2O3S/c13-8(14)4-2-1-3-7-9-6(5-16-7)11-10(15)12-9/h6-7,9H,1-5H2,(H,13,14)(H2,11,12,15)/t6-,7-,9-/m0/s1"},
    C2H3O2K = {inchi = "InChI=1S/C2H4O2.K/c1-2(3)4;/h1H3,(H,3,4);/q;+1/p-1"},
    CaCl2 = {inchi = "InChI=1S/Ca.2ClH/h;2*1H/q+2;;/p-2"},
    CoCl2 = {inchi = "InChI=1S/2ClH.Co/h2*1H;/q;;+2/p-2"},
    CuCl2 = {inchi = "InChI=1S/2ClH.Cu/h2*1H;/q;;+2/p-2"},
    EDTA = {inchi = "InChI=1S/C10H16N2O8/c13-7(14)3-11(4-8(15)16)1-2-12(5-9(17)18)6-10(19)20/h1-6H2,(H,13,14)(H,15,16)(H,17,18)(H,19,20)"},
    FeCl3 = {inchi = "InChI=1S/3ClH.Fe/h3*1H;/q;;;+3/p-3"},
    glucose = {inchi = "InChI=1S/C6H12O6/c7-1-2-3(8)4(9)5(10)6(11)12-2/h2-11H,1H2/t2-,3-,4+,5-,6?/m1/s1"},
    H3BO3 = {inchi = "InChI=1S/BH3O3/c2-1(3)4/h2-4H"},
    KH2PO4 = {inchi = "InChI=1S/K.H3O4P/c;1-5(2,3)4/h;(H3,1,2,3,4)/q+1;/p-1"},
    MgSO4 = {inchi = "InChI=1S/Mg.H2O4S/c;1-5(2,3)4/h;(H2,1,2,3,4)/q+2;/p-2"},
    MgCl2 = {inchi = "InChI=1S/2ClH.Mg/h2*1H;/q;;+2/p-2"},
    MnCl2 = {inchi = "InChI=1S/2ClH.Mn/h2*1H;/q;;+2/p-2"},
    Na2HPO4 = {inchi = "InChI=1S/2Na.H3O4P/c;;1-5(2,3)4/h;;(H3,1,2,3,4)/q2*+1;/p-2"},
    NaCl = {inchi = "InChI=1S/ClH.Na/h1H;/q;+1/p-1"},
    NH4Cl = {inchi = "InChI=1S/ClH.H3N/h1H;1H3"},
    thiamin = {inchi = "InChI=1S/C12H17N4OS/c1-8-11(3-4-17)18-7-16(8)6-10-5-14-9(2)15-12(10)13/h5,7,17H,3-4,6H2,1-2H3,(H2,13,14,15)/q+1"}, -- heat sensitive
    ZnCl2 = {inchi = "InChI=1S/2ClH.Zn/h2*1H;/q;;+2/p-2"},

    -- Buffers
    tris_HCl = {inchi = "InChI=1S/C4H11NO3.ClH/c5-4(1-6,2-7)3-8;/h6-8H,1-3,5H2;1H"},
    bis_tris_propane_HCl = {inchi = "InChI=1S/C8H19NO5.ClH/c10-3-1-9(2-4-11)8(5-12,6-13)7-14;/h10-14H,1-7H2;1H"},

    -- Amino acids
    alanine = {inchi = "InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1"},
    arginine = {inchi = "InChI=1S/C6H14N4O2/c7-4(5(11)12)2-1-3-10-6(8)9/h4H,1-3,7H2,(H,11,12)(H4,8,9,10)/t4-/m0/s1"},
    asparagine = {inchi = "InChI=1S/C4H8N2O3/c5-2(4(8)9)1-3(6)7/h2H,1,5H2,(H2,6,7)(H,8,9)/t2-/m0/s1"},
    aspartic_acid = {inchi = "InChI=1S/C4H7NO4/c5-2(4(8)9)1-3(6)7/h2H,1,5H2,(H,6,7)(H,8,9)/t2-/m0/s1"},
    cysteine = {inchi = "InChI=1S/C3H7NO2S/c4-2(1-7)3(5)6/h2,7H,1,4H2,(H,5,6)/t2-/m0/s1"},
    glutamine = {inchi = "InChI=1S/C5H10N2O3/c6-3(5(9)10)1-2-4(7)8/h3H,1-2,6H2,(H2,7,8)(H,9,10)/t3-/m0/s1"},
    glutamic_acid = {inchi = "InChI=1S/C5H9NO4/c6-3(5(9)10)1-2-4(7)8/h3H,1-2,6H2,(H,7,8)(H,9,10)/t3-/m0/s1"},
    glycine = {inchi = "InChI=1S/C2H5NO2/c3-1-2(4)5/h1,3H2,(H,4,5)"},
    histidine = {inchi = "InChI=1S/C6H9N3O2/c7-5(6(10)11)1-4-2-8-3-9-4/h2-3,5H,1,7H2,(H,8,9)(H,10,11)/t5-/m0/s1"},
    isoleucine = {inchi = "InChI=1S/C6H13NO2/c1-3-4(2)5(7)6(8)9/h4-5H,3,7H2,1-2H3,(H,8,9)/t4-,5-/m0/s1"},
    leucine = {inchi = "InChI=1S/C6H13NO2/c1-4(2)3-5(7)6(8)9/h4-5H,3,7H2,1-2H3,(H,8,9)/t5-/m0/s1"},
    lysine = {inchi = "InChI=1S/C6H14N2O2/c7-4-2-1-3-5(8)6(9)10/h5H,1-4,7-8H2,(H,9,10)/t5-/m0/s1"},
    methionine = {inchi = "InChI=1S/C5H11NO2S/c1-9-3-2-4(6)5(7)8/h4H,2-3,6H2,1H3,(H,7,8)/t4-/m0/s1"},
    phenylalanine = {inchi = "InChI=1S/C9H11NO2/c10-8(9(11)12)6-7-4-2-1-3-5-7/h1-5,8H,6,10H2,(H,11,12)/t8-/m0/s1"},
    proline = {inchi = "InChI=1S/C5H9NO2/c7-5(8)4-2-1-3-6-4/h4,6H,1-3H2,(H,7,8)/t4-/m0/s1"},
    serine = {inchi = "InChI=1S/C3H7NO3/c4-2(1-5)3(6)7/h2,5H,1,4H2,(H,6,7)/t2-/m0/s1"},
    threonine = {inchi = "InChI=1S/C4H9NO3/c1-2(6)3(5)4(7)8/h2-3,6H,5H2,1H3,(H,7,8)/t2-,3+/m1/s1"},
    tryptophan = {inchi = "InChI=1S/C11H12N2O2/c12-9(11(14)15)5-7-6-13-10-4-2-1-3-8(7)10/h1-4,6,9,13H,5,12H2,(H,14,15)/t9-/m0/s1"},
    tyrosine = {inchi = "InChI=1S/C9H11NO3/c10-8(9(12)13)5-6-1-3-7(11)4-2-6/h1-4,8,11H,5,10H2,(H,12,13)/t8-/m0/s1"},
    valine = {inchi = "InChI=1S/C5H11NO2/c1-3(2)4(6)5(7)8/h3-4H,6H2,1-2H3,(H,7,8)/t4-/m0/s1"},
    selenocysteine = {inchi = "InChI=1S/C3H6NO2Se/c4-2(1-7)3(5)6/h2H,1,4H2,(H,5,6)/t2-/m0/s1"},
    pyrrolysine = {inchi = "InChI=1S/C12H21N3O3/c1-8-5-7-14-10(8)11(16)15-6-3-2-4-9(13)12(17)18/h7-10H,2-6,13H2,1H3,(H,15,16)(H,17,18)/t8-,9+,10-/m1/s1"},
}

local function formula(self: mixtures.Chemical): string
  return self.inchi:match("/(.-)/")
end

mixtures.chemicals = {}
for k, v in pairs(chemicals) do
  v.formula = formula
  v.g_to_mol = function(self: mixtures.Chemical, n: number): number return conversions.g_to_mol(n, atoms.formula_to_mw(self:formula())) end
	mixtures.chemicals[k] = setmetatable(v, mixtures.chemical_mt)
end

mixtures.amino_acid_weights = {
  A = atoms.formula_to_mw(mixtures.chemicals.alanine:formula()),
  R = atoms.formula_to_mw(mixtures.chemicals.arginine:formula()),
  N = atoms.formula_to_mw(mixtures.chemicals.asparagine:formula()),
  D = atoms.formula_to_mw(mixtures.chemicals.aspartic_acid:formula()),
  C = atoms.formula_to_mw(mixtures.chemicals.cysteine:formula()),
  Q = atoms.formula_to_mw(mixtures.chemicals.glutamine:formula()),
  E = atoms.formula_to_mw(mixtures.chemicals.glutamic_acid:formula()),
  G = atoms.formula_to_mw(mixtures.chemicals.glycine:formula()),
  H = atoms.formula_to_mw(mixtures.chemicals.histidine:formula()),
  I = atoms.formula_to_mw(mixtures.chemicals.isoleucine:formula()),
  L = atoms.formula_to_mw(mixtures.chemicals.leucine:formula()),
  K = atoms.formula_to_mw(mixtures.chemicals.lysine:formula()),
  M = atoms.formula_to_mw(mixtures.chemicals.methionine:formula()),
  F = atoms.formula_to_mw(mixtures.chemicals.phenylalanine:formula()),
  P = atoms.formula_to_mw(mixtures.chemicals.proline:formula()),
  S = atoms.formula_to_mw(mixtures.chemicals.serine:formula()),
  T = atoms.formula_to_mw(mixtures.chemicals.threonine:formula()),
  W = atoms.formula_to_mw(mixtures.chemicals.tryptophan:formula()),
  Y = atoms.formula_to_mw(mixtures.chemicals.tyrosine:formula()),
  V = atoms.formula_to_mw(mixtures.chemicals.valine:formula()),
  U = atoms.formula_to_mw(mixtures.chemicals.selenocysteine:formula()),
  O = atoms.formula_to_mw(mixtures.chemicals.pyrrolysine:formula()),
}

--[[---------------------------------------------------------------------------

                          Proteins 

---------------------------------------------------------------------------]]--

local proteins: {string: mixtures.Protein} = {
  human_serum_albumin = {sequence = "MKWVTFISLLFLFSSAYSRGVFRRDAHKSEVAHRFKDLGEENFKALVLIAFAQYLQQCPFEDHVKLVNEVTEFAKTCVADESAENCDKSLHTLFGDKLCTVATLRETYGEMADCCAKQEPERNECFLQHKDDNPNLPRLVRPEVDVMCTAFHDNEETFLKKYLYEIARRHPYFYAPELLFFAKRYKAAFTECCQAADKAACLLPKLDELRDEGKASSAKQRLKCASLQKFGERAFKAWAVARLSQRFPKAEFAEVSKLVTDLTKVHTECCHGDLLECADDRADLAKYICENQDSISSKLKECCEKPLLEKSHCIAEVENDEMPADLPSLAADFVESKDVCKNYAEAKDVFLGMFLYEYARRHPDYSVVLLLRLAKTYETTLEKCCAAADPHECYAKVFDEFKPLVEEPQNLIKQNCELFEQLGEYKFQNALLVRYTKKVPQVSTPTLVEVSRNLGKVGSKCCKHPEAKRMPCAEDYLSVVLNQLCVLHEKTPVSDRVTKCCTESLVNRRPCFSALEVDETYVPKEFNAETFTFHADICTLSEKERQIKKQTALVELVKHKPKATKEQLKAVMDDFAAFVEKCCKADDKETCFAEEGKKLVAASQAALGL"}
}
mixtures.proteins = {}
local function protein_to_mw(self: mixtures.Protein): number
  local H2O_mw = atoms.formula_to_mw(mixtures.chemicals.H2O:formula())
  local mw: number = 0.0
  for i = 1,#self.sequence do
    local aa = self.sequence:sub(i,i)
    mw = mw + mixtures.amino_acid_weights[aa]
    mw = mw - H2O_mw
  end
  mw = mw + H2O_mw -- the last amino acid still has water attached
  return mw
end

for k, v in pairs(proteins) do
  v.g_to_mol = function(self: mixtures.Protein, n: number): number return conversions.g_to_mol(n, protein_to_mw(self)) end
  mixtures.proteins[k] = setmetatable(v, mixtures.protein_mt)
end


--[[---------------------------------------------------------------------------

                           Cells

---------------------------------------------------------------------------]]--

local cells: {string: mixtures.Cell} = {
  ["Escherichia coli MG1655"] = {name = "Escherichia coli MG1655"}
}
mixtures.cells = {}
for k, v in pairs(cells) do
  mixtures.cells[k] = setmetatable(v, mixtures.cell_mt)
end


--[[---------------------------------------------------------------------------

                            Common reagents

---------------------------------------------------------------------------]]--

local common_reagents: {string: mixtures.Mixture} = {
  -- M9 recipe https://www.helmholtz-muenchen.de/fileadmin/PEPF/Protocols/M9-medium_150510.pdf
  M9 = (mixtures.chemicals.H2O * conversions.l) +
    (mixtures.chemicals.CaCl2 * 0.3 * conversions.mmol) +
    (mixtures.chemicals.MgSO4 * 1 * conversions.mmol) +
    (mixtures.chemicals.biotin * conversions.g_to_mol(conversions.mg, 244.31)) + -- molecular weight 244.31g/mol, need 1mg.
    (mixtures.chemicals.thiamin * conversions.g_to_mol(conversions.mg, 265.355)) + -- molecular weight 265.355g/mol, need 1mg
    (mixtures.chemicals.glucose * conversions.g_to_mol(4*conversions.g, 180.156)) + -- molecular weight 180.156g/mol, need 4g
    (((mixtures.chemicals.Na2HPO4 * 337 * conversions.mmol) +
      (mixtures.chemicals.KH2PO4 * 220 * conversions.mmol) +
      (mixtures.chemicals.NaCl * 85.5 * conversions.mmol) +
      (mixtures.chemicals.NH4Cl * 93.5 * conversions.mmol)
    ) / 10.0) + -- 10x M9 salt solution
    (((mixtures.chemicals.EDTA * 13.4 * conversions.mmol) +
      (mixtures.chemicals.FeCl3 * 3.1 * conversions.mmol) +
      (mixtures.chemicals.ZnCl2 * 0.62 * conversions.mmol) +
      (mixtures.chemicals.CuCl2 * 76 * conversions.umol) +
      (mixtures.chemicals.CoCl2 * 42 * conversions.umol) +
      (mixtures.chemicals.H3BO3 * 162 * conversions.umol) +
      (mixtures.chemicals.MnCl2 * 8.1 * conversions.umol)
    ) / 100), -- 100x trace elements

    -- NEBuffer r1.1, r2.1, r3.1, rCutsmart
    -- _u denotes nothing about the pH
    ["NEBuffer_r1.1_u"] = (mixtures.chemicals.H2O * conversions.l) +
      (mixtures.chemicals.bis_tris_propane_HCl * 10 * conversions.mmol) +
      (mixtures.chemicals.MgCl2 * 10 * conversions.mmol) +
      (mixtures.proteins.human_serum_albumin * mixtures.proteins.human_serum_albumin:g_to_mol(100 * conversions.ug))
}
mixtures.common_reagents = common_reagents

--[[---------------------------------------------------------------------------

                            Basic functions

---------------------------------------------------------------------------]]--

local record util
  uuid: function(): string
end

util.uuid = function(): string
  local u, _ = string.gsub('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', '[xy]', function (c:string): string
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
  return u
end


--[[---------------------------------------------------------------------------

                          Protocol functions

---------------------------------------------------------------------------]]--

local record biologic_commands
  -- BiologicCommands
  record Mix
    mixture: mixtures.Mixture
  end
  record BiologicCommand
    biologic_command_type: integer
    mix: Mix
  end
  record BiologicCommands
    biologic_commands: {BiologicCommand}
    name: string
    append: function(BiologicCommands, BiologicCommand)
    to_json: function(BiologicCommands): string
  end
  new_protocol: function(string): BiologicCommands
  new_mix_command: function(mixtures.Mixture): BiologicCommand

end

biologic_commands.new_protocol = function(name: string): biologic_commands.BiologicCommands
  local protocol: biologic_commands.BiologicCommands = {name = name, biologic_commands = {}}
  protocol.append = function(self: biologic_commands.BiologicCommands, command: biologic_commands.BiologicCommand)
    self.biologic_commands[#self.biologic_commands+1] = command
  end
  protocol.to_json = function(self:biologic_commands.BiologicCommands): string 
    return json.encode(self)
  end
  return protocol
end

biologic_commands.new_mix_command = function(mixture: mixtures.Mixture): biologic_commands.BiologicCommand
  return {biologic_command_type = 1, mix = {mixture = mixture} as biologic_commands.Mix} as biologic_commands.BiologicCommand
end


local record std
  atoms: atoms
  conversions: conversions
  mixtures: mixtures
  util: util
  biologic_commands: biologic_commands
  synbio: synbio
end

std.atoms = atoms
std.conversions = conversions
std.mixtures = mixtures
std.util = util
std.biologic_commands = biologic_commands
std.synbio = synbio

return std

