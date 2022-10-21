local inventory = require("test.std.inventory")
local mixtures = require("test.std.mixtures")
local conversions = require("test.std.conversions")

describe("inventory", function()
  describe("plate test", function()
    it("should build correct addresses and chemicals", function()
      plate = inventory.new_plate{name="test_plate", labware="cryoking_300ul"}
      plate:new_tube{name="m9", address=0, mixture=mixtures.common_reagents["M9"]:volume(50*conversions.ul)}
      assert(plate.tubes[1].sample.mixture.chemicals[1].chemical.inchi == "InChI=1S/H2O/h1H2")
    end)
  end)
  describe("tipbox", function()
    it("should generate correctly", function()
      tipbox = inventory.new_tipbox("opentrons_96_filtertiprack_200ul")
      tipbox2 = inventory.new_tipbox{labware="opentrons_96_filtertiprack_200ul"}
      assert(tipbox.tubes[10].address == 9)
      assert(tipbox.labware == "opentrons_96_filtertiprack_200ul")
      assert(tipbox2.tubes[10].address == 9)
      assert(tipbox2.labware == "opentrons_96_filtertiprack_200ul")
    end)
  end)
end)
