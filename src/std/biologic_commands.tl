local json = require("json")
local mixtures = require("mixtures")

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

return biologic_commands
