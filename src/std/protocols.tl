local mixtures = require("mixtures")
local biologic_commands = require("biologic_commands")

local record protocols
  record Sample
    uuid: string
    mixture: mixtures.Mixture
  end
  record pcr_options
    ctx: biologic_commands.BiologicCommands
    enzyme: string
  end
  pcr: function(string | Sample, string, string, pcr_options): Sample
end
return protocols
