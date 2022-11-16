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
local primers = require("primers")
local complement = require("complement")

local record pcr
  minimal_primer_length: integer
  design_primers_with_overhang: function(string, string, string, string, number): string, string
  design_primers: function(string, string, number): string, string
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
function pcr.design_primers_with_overhang(template: string, polymerase: string, forward_overhang: string, reverse_overhang: string, target_tm: number, options: pcr.Options): string, string
  if polymerase ~= "taq_standard" then
    error("Got unknown polymerase")
  end
  template = template:upper()

  -- If options are nil, fill default options
  if options == nil then
    options = {}
    options.primer_concentration = primers.default_primer_concentration
    options.salt_concentration = primers.default_salt_concentration
    options.magnesium_concentration = primers.default_magnesium_concentration
  end

  -- Walk out over additional nucleotides until melting tm requirements are met
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
function pcr.design_primers(template: string, polymerase: string, target_tm: number, options: pcr.Options): string, string
  return pcr.design_primers_with_overhang(template, polymerase, "", "", target_tm, options)
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
  -- requires indexes that bind, as well as a primer table of primers that bind
  -- at those particular indexes. This integer data is used to generate a
  -- series of new PCR fragments.
  local function generate_pcr_fragments(s: string, f: integer, r: integer, forward_primer_indexes: {integer}, reverse_primer_indexes: {integer}): {string}
    local gen_pcr_fragments: {string} = {}
    for _, forward_primer_index in ipairs(forward_primer_indexes) do
      local minimal_primer = minimal_primer_binds[forward_primer_index]
      local full_primer_forward = primer_list[forward_primer_index]
      for _, reverse_primer_index in ipairs(reverse_primer_indexes) do
        local full_primer_reverse = complement.reverse_complement(primer_list[reverse_primer_index])
        local pcr_fragment: string = full_primer_forward:sub(1, #full_primer_forward - #minimal_primer) .. s:sub(f,r-1) .. full_primer_reverse
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

return pcr
