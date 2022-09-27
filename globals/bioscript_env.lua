local std_func = function() REPLACE_ME end
local std = std_func()

_G.new_tube = std.inventory.new_tube
_G.new_plate = std.inventory.new_plate

_G.chemicals = std.mixtures.chemicals
_G.sequences = std.mixtures.chemicals
_G.cells = std.mixtures.cells
_G.environmentals = std.mixtures.environmentals
_G.common_reagents = std.mixtures.common_reagents

_G.mol = std.conversions.mol
_G.mmol = std.conversions.mmol
_G.umol = std.conversions.umol
_G.nmol = std.conversions.nmol
_G.pmol = std.conversions.pmol
_G.fmol = std.conversions.fmol
_G.amol = std.conversions.amol
_G.l = std.conversions.l 
_G.ml = std.conversions.ml
_G.ul = std.conversions.ul
_G.nl = std.conversions.nl
_G.kg = std.conversions.kg
_G.g = std.conversions.g 
_G.mg = std.conversions.mg
_G.ug = std.conversions.ug
_G.ng = std.conversions.ng
_G.pg = std.conversions.pg
_G.fg = std.conversions.fg

_G.encode = std.json.encode
