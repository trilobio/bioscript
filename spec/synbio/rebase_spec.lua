local rebase = require("test.synbio.rebase")

local rebase_file = io.open("spec/synbio/data/rebase.txt", "rb")
local rebase_txt = rebase_file:read("*a")
rebase_file:close()

local enzymes = rebase.parse(rebase_txt)

describe("Rebase", function()
  describe("parser", function()
    it("should parse rebase properly", function()
      bsai = enzymes["BsaI"]
      assert(bsai.name == "BsaI")
      assert(#bsai.isoschizomers == 50, "#isoschizomers Got: " .. #bsai.isoschizomers .. " Expected: " .. 50)
      assert(bsai.recognition_sequence == "GGTCTC(1/5)")
      assert(bsai.methylation_site == "-4(6)")
      assert(bsai.microorganism == "Bacillus stearothermophilus 6-55")
      assert(bsai.source == "Z. Chen")
      assert(bsai.commercial_availability[1] == "New England Biolabs")
      assert(#bsai.references == 7, "#references Got: " .. #bsai.references .. " Expected: " .. 7)
    end)
  end)
end)
