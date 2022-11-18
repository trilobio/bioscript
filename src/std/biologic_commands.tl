local inventory = require("inventory")
local mixtures = require("mixtures")

--[[---------------------------------------------------------------------------

                          Protocol functions

---------------------------------------------------------------------------]]--

local record biologic_commands
  -- protocols
  record PcrOptions 
    polymerase: string
    buffer: string
    volume: number
    templates: {string}
    primers: {string}
  end

  record Sample
    uuid: string
    mixture: mixtures.Mixture
  end

  -- BiologicCommands
  record Mix
    samples: {inventory.Sample}
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
    make_mixture: function(BiologicCommands, Mix)
    pcr: function(BiologicCommands, PcrOptions)
  end
  biologic_comamnds_mt: metatable<BiologicCommands>
  make_mixture: function(BiologicCommands, Mix)
  new_protocol: function(string): BiologicCommands

end

--local function pcr(self: biologic_commands.BiologicCommands, pcr_options: biologic_commands.PcrOptions): Sample, {string}
--  -- Default to 25.0uL PCR reactions
--  local volume = pcr_options.volume
--  if volume == nil then
--    volume = 25.0
--  end
--
--  -- Handle buffers
--  local new_mixture: mixtures.Mixture
--  if pcr_options.buffer == "taq_standard" then
--    new_mixture = mixtures.common_reagents["NEB_Taq_Standard_Buffer_10X"]:volume(volume/10) + mixtures.common_reagents["H2O"]:volume(volume - (volume/10))
--  end
--
--  -- Handle polymerase
--  if pcr_options.polymerase == "taq" then
--    -- 80,000 units per mg https://doi.org/10.1371%2Fjournal.pone.0007010
--    local unit = mixtures.proteins["taq"]:g_to_mol(1 * conversions.mg) / 80000
--    -- 1.25 units per 50uL https://www.neb.com/protocols/0001/01/01/taq-dna-polymerase-with-standard-taq-buffer-m0273
--    local units_required = (1.25 * volume) / 50 
--    new_mixture = new_mixture + (mixtures.proteins["taq"] * (unit * units_required))
--  end
--
--  -- Handle template and primers
--  --for _, template in ipairs(pcr_options.templates) do
--  --  --x
--  --end
--
--  -- Add mix function to biologic_commands
--  local command = {biologic_command_type = 1, mix = new_mixture as biologic_commands.Mix} as biologic_commands.BiologicCommand
--  self.biologic_commands[#self.biologic_commands+1] = command
--   
--end

biologic_commands.make_mixture = function(self: biologic_commands.BiologicCommands, mix:biologic_commands.Mix): biologic_commands.BiologicCommand
  local command = {biologic_command_type = 1, mix = mix as biologic_commands.Mix} as biologic_commands.BiologicCommand
  self.biologic_commands[#self.biologic_commands+1] = command
  return command
end

biologic_commands.new_protocol = function(name: string): biologic_commands.BiologicCommands
  local protocol: biologic_commands.BiologicCommands = {name = name, biologic_commands = {}}
  protocol.append = function(self: biologic_commands.BiologicCommands, command: biologic_commands.BiologicCommand)
    self.biologic_commands[#self.biologic_commands+1] = command
  end
  protocol.make_mixture = biologic_commands.make_mixture
  return protocol
end

return biologic_commands
