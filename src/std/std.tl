local atoms = require("atoms")
local conversions = require("conversions")
local mixtures = require("mixtures")
local util = require("util")
local biologic_commands = require("biologic_commands")
local record synbio end --require("synbio")

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

