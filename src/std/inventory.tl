local mixtures = require("mixtures")
local util = require("util")

local record inventory
   
  record Sample
    id: string
    mixture: mixtures.Mixture
  end
  new_sample: function(mixtures.Mixture): Sample
  record Tube
    id: string
    name: string
    datamatrix: string
    address: integer
    capped: boolean
    sample: Sample
  end
  new_tube: function(string, integer, mixtures.Mixture, string, boolean): Tube
  add_tube: function(Tube, integer): Plate
  record Plate
    id: string
    name: string
    labware: Labware
    tubes: {Tube}
  end
  new_plate: function(string, Labware): Plate
  new_tipbox: function(Labware): Plate

  address_to_integer: {string: integer}
  integer_to_address: {integer: string}

  enum Labware
    "agilent_1_reservoir_290ml"
    "axygen_1_reservoir_90ml"
    "biorad_96_wellplate_200ul_pcr"
    "corning_12_wellplate_6.9ml_flat"
    "corning_24_wellplate_3.4ml_flat"
    "corning_384_wellplate_112ul_flat"
    "corning_48_wellplate_1.6ml_flat"
    "corning_6_wellplate_16.8ml_flat"
    "corning_96_wellplate_360ul_flat"
    "eppendorf_96_tiprack_1000ul_eptips"
    "eppendorf_96_tiprack_10ul_eptips"
    "geb_96_tiprack_1000ul"
    "geb_96_tiprack_10ul"
    "nest_12_reservoir_15ml"
    "nest_1_reservoir_195ml"
    "nest_96_wellplate_100ul_pcr_full_skirt"
    "nest_96_wellplate_200ul_flat"
    "nest_96_wellplate_2ml_deep"
    "opentrons_10_tuberack_falcon_4x50ml_6x15ml_conical"
    "opentrons_10_tuberack_falcon_4x50ml_6x15ml_conical_acrylic"
    "opentrons_10_tuberack_nest_4x50ml_6x15ml_conical"
    "opentrons_15_tuberack_falcon_15ml_conical"
    "opentrons_15_tuberack_nest_15ml_conical"
    "opentrons_1_trash_1100ml_fixed"
    "opentrons_1_trash_850ml_fixed"
    "opentrons_24_aluminumblock_generic_2ml_screwcap"
    "opentrons_24_aluminumblock_nest_0.5ml_screwcap"
    "opentrons_24_aluminumblock_nest_1.5ml_screwcap"
    "opentrons_24_aluminumblock_nest_1.5ml_snapcap"
    "opentrons_24_aluminumblock_nest_2ml_screwcap"
    "opentrons_24_aluminumblock_nest_2ml_snapcap"
    "opentrons_24_tuberack_eppendorf_1.5ml_safelock_snapcap"
    "opentrons_24_tuberack_eppendorf_2ml_safelock_snapcap"
    "opentrons_24_tuberack_eppendorf_2ml_safelock_snapcap_acrylic"
    "opentrons_24_tuberack_generic_0.75ml_snapcap_acrylic"
    "opentrons_24_tuberack_generic_2ml_screwcap"
    "opentrons_24_tuberack_nest_0.5ml_screwcap"
    "opentrons_24_tuberack_nest_1.5ml_screwcap"
    "opentrons_24_tuberack_nest_1.5ml_snapcap"
    "opentrons_24_tuberack_nest_2ml_screwcap"
    "opentrons_24_tuberack_nest_2ml_snapcap"
    "opentrons_40_aluminumblock_eppendorf_24x2ml_safelock_snapcap_generic_16x0.2ml_pcr_strip"
    "opentrons_6_tuberack_falcon_50ml_conical"
    "opentrons_6_tuberack_nest_50ml_conical"
    "opentrons_96_aluminumblock_biorad_wellplate_200ul"
    "opentrons_96_aluminumblock_generic_pcr_strip_200ul"
    "opentrons_96_aluminumblock_nest_wellplate_100ul"
    "opentrons_96_filtertiprack_1000ul"
    "opentrons_96_filtertiprack_10ul"
    "opentrons_96_filtertiprack_200ul"
    "opentrons_96_filtertiprack_20ul"
    "opentrons_96_tiprack_1000ul"
    "opentrons_96_tiprack_10ul"
    "opentrons_96_tiprack_20ul"
    "opentrons_96_tiprack_300ul"
    "opentrons_calibrationblock_short_side_left"
    "opentrons_calibrationblock_short_side_right"
    "tipone_96_tiprack_200ul"
    "usascientific_12_reservoir_22ml"
    "usascientific_96_wellplate_2.4ml_deep"
    "agilent_1_reservoir_290ml"
    "axygen_1_reservoir_90ml"
    "biorad_96_wellplate_200ul_pcr"
    "corning_12_wellplate_6.9ml_flat"
    "corning_24_wellplate_3.4ml_flat"
    "corning_384_wellplate_112ul_flat"
    "corning_48_wellplate_1.6ml_flat"
    "corning_6_wellplate_16.8ml_flat"
    "corning_96_wellplate_360ul_flat"
    "eppendorf_96_tiprack_1000ul_eptips"
    "eppendorf_96_tiprack_10ul_eptips"
    "geb_96_tiprack_1000ul"
    "geb_96_tiprack_10ul"
    "nest_12_reservoir_15ml"
    "nest_1_reservoir_195ml"
    "nest_96_wellplate_100ul_pcr_full_skirt"
    "nest_96_wellplate_200ul_flat"
    "nest_96_wellplate_2ml_deep"
    "opentrons_10_tuberack_falcon_4x50ml_6x15ml_conical"
    "opentrons_10_tuberack_falcon_4x50ml_6x15ml_conical_acrylic"
    "opentrons_10_tuberack_nest_4x50ml_6x15ml_conical"
    "opentrons_15_tuberack_falcon_15ml_conical"
    "opentrons_15_tuberack_nest_15ml_conical"
    "opentrons_1_trash_1100ml_fixed"
    "opentrons_1_trash_850ml_fixed"
    "opentrons_24_aluminumblock_generic_2ml_screwcap"
    "opentrons_24_aluminumblock_nest_0.5ml_screwcap"
    "opentrons_24_aluminumblock_nest_1.5ml_screwcap"
    "opentrons_24_aluminumblock_nest_1.5ml_snapcap"
    "opentrons_24_aluminumblock_nest_2ml_screwcap"
    "opentrons_24_aluminumblock_nest_2ml_snapcap"
    "opentrons_24_tuberack_eppendorf_1.5ml_safelock_snapcap"
    "opentrons_24_tuberack_eppendorf_2ml_safelock_snapcap"
    "opentrons_24_tuberack_eppendorf_2ml_safelock_snapcap_acrylic"
    "opentrons_24_tuberack_generic_0.75ml_snapcap_acrylic"
    "opentrons_24_tuberack_generic_2ml_screwcap"
    "opentrons_24_tuberack_nest_0.5ml_screwcap"
    "opentrons_24_tuberack_nest_1.5ml_screwcap"
    "opentrons_24_tuberack_nest_1.5ml_snapcap"
    "opentrons_24_tuberack_nest_2ml_screwcap"
    "opentrons_24_tuberack_nest_2ml_snapcap"
    "opentrons_40_aluminumblock_eppendorf_24x2ml_safelock_snapcap_generic_16x0.2ml_pcr_strip"
    "opentrons_6_tuberack_falcon_50ml_conical"
    "opentrons_6_tuberack_nest_50ml_conical"
    "opentrons_96_aluminumblock_biorad_wellplate_200ul"
    "opentrons_96_aluminumblock_generic_pcr_strip_200ul"
    "opentrons_96_aluminumblock_nest_wellplate_100ul"
    "opentrons_96_filtertiprack_1000ul"
    "opentrons_96_filtertiprack_10ul"
    "opentrons_96_filtertiprack_200ul"
    "opentrons_96_filtertiprack_20ul"
    "opentrons_96_tiprack_1000ul"
    "opentrons_96_tiprack_10ul"
    "opentrons_96_tiprack_20ul"
    "opentrons_96_tiprack_300ul"
    "opentrons_calibrationblock_short_side_left"
    "opentrons_calibrationblock_short_side_right"
    "tipone_96_tiprack_200ul"
    "usascientific_12_reservoir_22ml"
    "usascientific_96_wellplate_2.4ml_deep"

    "cryoking_300ul"
  end
end

global plate: inventory.Plate = {}

inventory.new_sample = function(mixture: mixtures.Mixture): inventory.Sample
  return {id = util.uuid(), mixture = mixture} as inventory.Sample
end

inventory.new_tube = function(name: string, address: integer, mixture: mixtures.Mixture, datamatrix: string, capped: boolean): inventory.Tube
  local new_tube: inventory.Tube = {}
  new_tube.id = util.uuid()
  new_tube.name = name
  new_tube.sample = inventory.new_sample(mixture)
  new_tube.datamatrix = datamatrix
  new_tube.capped = capped
  new_tube.address = address
  plate.tubes[#plate.tubes+1] = new_tube
  return new_tube
end

inventory.new_plate = function(name: string, labware: inventory.Labware): inventory.Plate
  global plate: inventory.Plate = {}
  plate.id = util.uuid()
  plate.name = name
  plate.labware = labware
  plate.tubes = {}
  return plate
end

inventory.new_tipbox = function(labware: inventory.Labware): inventory.Plate
  global plate: inventory.Plate = {}
  plate.id = util.uuid()
  plate.name = labware
  plate.labware = labware
  plate.tubes = {}
  for i=1,96 do
    local new_tube: inventory.Tube = {}
    new_tube.id = util.uuid()
    new_tube.name = "tip"
    new_tube.address = i-1
    plate.tubes[i] = new_tube
  end
  return plate
end

return inventory
