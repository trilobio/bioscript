local inventory = require("inventory")
local mixtures = require("mixtures")

--[[---------------------------------------------------------------------------

                          Protocol functions

---------------------------------------------------------------------------]]--

local record biologic_commands
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
  end
  new_protocol: function(string): BiologicCommands
  mix: function(Mix): BiologicCommand

end

global protocol: biologic_commands.BiologicCommands = {name = "untitled_protocol", biologic_commands = {}}

biologic_commands.new_protocol = function(name: string): biologic_commands.BiologicCommands
  global protocol: biologic_commands.BiologicCommands = {name = name, biologic_commands = {}}
  protocol.append = function(self: biologic_commands.BiologicCommands, command: biologic_commands.BiologicCommand)
    self.biologic_commands[#self.biologic_commands+1] = command
  end
  return protocol
end

biologic_commands.mix = function(mix:biologic_commands.Mix): biologic_commands.BiologicCommand
  local command = {biologic_command_type = 1, mix = mix as biologic_commands.Mix} as biologic_commands.BiologicCommand
  protocol.biologic_commands[#protocol.biologic_commands+1] = command
  return command
end

return biologic_commands
