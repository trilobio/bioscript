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
  grams_to_molecules: function(number, number): number
  molecules_to_grams: function(number, number): number
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

function conversions.grams_to_molecules(g: number, molecular_weight: number): number
    return g / molecular_weight * conversions.mol
end

function conversions.molecules_to_grams(molecules: number, molecular_weight: number): number
  return molecular_weight * (molecules/conversions.mol)
end

return conversions
