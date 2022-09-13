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
  record pcr_cleanup_options
    ctx: biologic_commands.BiologicCommands
  end
  record ligation_options
    ctx: biologic_commands.BiologicCommands
    enzyme: string
  end
  record restriction_digest_options
    ctx: biologic_commands.BiologicCommands
  end
  record methylation_options
    ctx: biologic_commands.BiologicCommands
  end
  record goldengate_assembly_options
    ctx: biologic_commands.BiologicCommands
  end
  record gibson_assembly_options
    ctx: biologic_commands.BiologicCommands
  end
  record transformation_options
    ctx: biologic_commands.BiologicCommands
  end
  record colony_pick_options
    ctx: biologic_commands.BiologicCommands
  end
  record liquid_culture_options
    ctx: biologic_commands.BiologicCommands
  end
  record glycerol_stock_options
    ctx: biologic_commands.BiologicCommands
  end
  record miniprep_options
    ctx: biologic_commands.BiologicCommands
  end
  pcr: function(string | Sample, string, string, pcr_options): Sample
  pcr_cleanup: function(Sample, pcr_cleanup_options): Sample
  ligate: function({Sample}, ligation_options): Sample
  restriction_digest: function(Sample, string, restriction_digest_options): Sample
  methylate: function(Sample, string, methylation_options): Sample
  goldengate_assembly: function({Sample}, string, goldengate_assembly_options): Sample
  gibson_assembly: function({Sample}, gibson_assembly_options): Sample
  transform: function(Sample, string, transformation_options): Sample
  colony_pick: function(Sample, colony_pick_options): Sample
  liquid_culture: function(Sample, liquid_culture_options): Sample
  glycerol_stock: function(Sample, glycerol_stock_options): Sample
  miniprep: function(Sample, miniprep_options): Sample
end
return protocols
