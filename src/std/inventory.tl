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
  record NewTube
    name: string
    datamatrix: string
    address: integer
    capped: boolean
    mixture: mixtures.Mixture
  end

  record Plate
    id: string
    name: string
    labware: Labware
    tubes: {Tube}

    new_tube: function(Plate, NewTube)
    new_well: function(Plate, NewTube)
  end
  record NewPlate
    name: string
    labware: Labware
  end
  new_plate: function(NewPlate): Plate

  record NewTipbox
    labware: Labware
  end
  new_tipbox: function(NewTipbox | string): Plate

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

inventory.new_sample = function(mixture: mixtures.Mixture): inventory.Sample
  return {id = util.uuid(), mixture = mixture} as inventory.Sample
end

local function new_tube(self: inventory.Plate, new_tube_tbl: inventory.NewTube)
  local tube: inventory.Tube = {}
  tube.id = util.uuid()
  tube.name = new_tube_tbl.name
  tube.sample = inventory.new_sample(new_tube_tbl.mixture)
  tube.datamatrix = new_tube_tbl.datamatrix
  tube.capped = new_tube_tbl.capped
  tube.address = new_tube_tbl.address
  self.tubes[#self.tubes+1] = tube
end

inventory.new_plate = function(new_plate_tbl: inventory.NewPlate): inventory.Plate
  local plate: inventory.Plate = {}
  plate.id = util.uuid()
  plate.name = new_plate_tbl.name
  plate.labware = new_plate_tbl.labware
  plate.tubes = {}

  plate.new_tube = new_tube
  plate.new_well = new_tube
  return plate
end

inventory.new_tipbox = function(labware_input: inventory.NewTipbox | string): inventory.Plate
  local plate: inventory.Plate = {}
  local labware: inventory.Labware
  if labware_input is string then
    labware = labware_input as inventory.Labware
  else
    labware = labware_input.labware
  end
  plate.id = util.uuid()
  plate.name = labware
  plate.labware = labware
  plate.tubes = {}
  for i=1,96 do
    local tube: inventory.Tube = {}
    tube.id = util.uuid()
    tube.name = "tip"
    tube.address = i-1
    plate.tubes[i] = tube
  end
  return plate
end

return inventory
