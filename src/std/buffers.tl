local conversions = require("conversions")
local mixtures = require("mixtures")

local neb: {string: mixtures.Mixture} = {
  --[[---------------------------------------------------------------------------

  NEB series buffers

  ---------------------------------------------------------------------------]]--
  ["10x _u Antarctic Phosphatase Reaction Buffer"] = (mixtures.chemicals.H2O * conversions.l) +
    ( -- 1X Buffer Components
      ((mixtures.chemicals.MgCl2 * conversions.mmol) +
      (mixtures.chemicals.ZnCl2 * conversions.mmol * 0.1))
    * 10),
  ["Blue Protein Loading Dye"] = (mixtures.chemicals.H2O * conversions.l),
  ["Diluent A"] = (mixtures.chemicals.H2O * conversions.l),
  ["Diluent B"] = (mixtures.chemicals.H2O * conversions.l),
  ["Diluent C"] = (mixtures.chemicals.H2O * conversions.l),
  ["DNase I Reaction Buffer"] = (mixtures.chemicals.H2O * conversions.l),
  ["Endoglycosidase Reaction Buffer Pack"] = (mixtures.chemicals.H2O * conversions.l),
  ["Exonuclease I Reaction Buffer"] = (mixtures.chemicals.H2O * conversions.l),
  ["Gel Loading Dye, Blue (6X)"] = (mixtures.chemicals.H2O * conversions.l),
  ["Gel Loading Dye, Orange (6X)"] = (mixtures.chemicals.H2O * conversions.l),
  ["Gel Loading Dye, Purple (6X)"] = (mixtures.chemicals.H2O * conversions.l),
  ["Gel Loading Dye, Purple (6X), no SDS"] = (mixtures.chemicals.H2O * conversions.l),
  ["Isothermal Amplification Buffer II Pack"] = (mixtures.chemicals.H2O * conversions.l),
  ["Magnesium Chloride (MgCl2) Solution"] = (mixtures.chemicals.H2O * conversions.l),
  ["Magnesium Sulfate (MgSO4) Solution "] = (mixtures.chemicals.H2O * conversions.l),
  ["Monarch DNA Cleanup Binding Buffer "] = (mixtures.chemicals.H2O * conversions.l),
  ["Monarch DNA Elution Buffer"] = (mixtures.chemicals.H2O * conversions.l),
  ["Monarch DNA Wash Buffer"] = (mixtures.chemicals.H2O * conversions.l),
  ["Monarch Gel Dissolving Buffer"] = (mixtures.chemicals.H2O * conversions.l),
  ["Monarch Plasmid Lysis Buffer (B2)"] = (mixtures.chemicals.H2O * conversions.l),
  ["Monarch Plasmid Neutralization Buffer (B3)"] = (mixtures.chemicals.H2O * conversions.l),
  ["Monarch Plasmid Resuspension Buffer (B1)"] = (mixtures.chemicals.H2O * conversions.l),
  ["Monarch Plasmid Wash Buffer 1"] = (mixtures.chemicals.H2O * conversions.l),
  ["Monarch Plasmid Wash Buffer 2"] = (mixtures.chemicals.H2O * conversions.l),
  ["NEB 10-beta/Stable Outgrowth Medium"] = (mixtures.chemicals.H2O * conversions.l),
  ["NEBNext® Adaptor Dilution Buffer"] = (mixtures.chemicals.H2O * conversions.l),
  ["NEBNext® dA-Tailing Reaction Buffer"] = (mixtures.chemicals.H2O * conversions.l),
  ["NEBNext® End Repair Reaction Buffer"] = (mixtures.chemicals.H2O * conversions.l),
  ["NEBNext® Library Dilution Buffer"] = (mixtures.chemicals.H2O * conversions.l),
  ["NEBNext® Quick Ligation Reaction Buffer "] = (mixtures.chemicals.H2O * conversions.l),
  ["NEBNext® Second Strand Synthesis (dNTP-free) Reaction Buffer"] = (mixtures.chemicals.H2O * conversions.l),
  ["NEBNext® dsDNA Fragmentase® Reaction Buffer v2"] = (mixtures.chemicals.H2O * conversions.l),
  ["NEBuffer 1"] = (mixtures.chemicals.H2O * conversions.l),
  ["NEBuffer 2"] = (mixtures.chemicals.H2O * conversions.l),
  ["NEBuffer 3"] = (mixtures.chemicals.H2O * conversions.l),
  ["NEBuffer 4"] = (mixtures.chemicals.H2O * conversions.l),
  ["NEBuffer r1.1"] = (mixtures.chemicals.H2O * conversions.l),
  ["NEBuffer r2.1"] = (mixtures.chemicals.H2O * conversions.l),
  ["NEBuffer r3.1"] = (mixtures.chemicals.H2O * conversions.l),
  ["rCutSmart Buffer"] = (mixtures.chemicals.H2O * conversions.l),
  ["NEBuffer EcoRI/SspI"] = (mixtures.chemicals.H2O * conversions.l),
  ["NEBuffer DpnII"] = (mixtures.chemicals.H2O * conversions.l),
  ["Phusion HF Buffer"] = (mixtures.chemicals.H2O * conversions.l),
  ["Phusion GC Buffer"] = (mixtures.chemicals.H2O * conversions.l),
  ["Q5 Reaction Buffer"] = (mixtures.chemicals.H2O * conversions.l),
  ["Recombinant Albumin, Molecular Biology Grade "] = (mixtures.chemicals.H2O * conversions.l),
  ["RNA Loading Dye, (2X)"] = (mixtures.chemicals.H2O * conversions.l),
  ["S-adenosylmethionine (SAM)"] = (mixtures.chemicals.H2O * conversions.l),
  ["SOC Outgrowth Medium"] = (mixtures.chemicals.H2O * conversions.l),
  ["Standard Taq Reaction Buffer"] = (mixtures.chemicals.H2O * conversions.l),
  ["StickTogether DNA Ligase Buffer "] = (mixtures.chemicals.H2O * conversions.l),
  ["T4 DNA Ligase Reaction Buffer "] = (mixtures.chemicals.H2O * conversions.l),
  ["T4 Polynucleotide Kinase Reaction Buffer"] = (mixtures.chemicals.H2O * conversions.l),
  ["T4 RNA Ligase Reaction Buffer"] = (mixtures.chemicals.H2O * conversions.l),
  ["Taq DNA Ligase Reaction Buffer"] = (mixtures.chemicals.H2O * conversions.l),
  ["ThermoPol Reaction Buffer Pack "] = (mixtures.chemicals.H2O * conversions.l),
  ["Yeast Carbon Base Medium Powder"] = (mixtures.chemicals.H2O * conversions.l),
  [" β-Nicotinamide adenine dinucleotide (NAD+)"] = (mixtures.chemicals.H2O * conversions.l),

}
return neb
