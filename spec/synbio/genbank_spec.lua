local genbank = require("test.synbio.genbank")

local function read_file(input)
  local file = io.open(input, "rb")
  local s = file:read("*a")
  file:close()
  local gb = genbank.parse(s)
  print(gb[1].meta.locus.name)
  return gb
end

local plasmid = read_file("spec/synbio/data/puc19.gbk")[1]
local pichia = read_file("spec/synbio/data/pichia_chr1_head.gb")[1]

describe("Genbank", function()
	describe("parser", function()
		it("should parse locus name", function()
			assert(plasmid.meta.locus.name == "puc19.gbk")
      assert(pichia.meta.locus.name == "FR839628")
		end)
	end)

	describe("feature", function()
		it("should return proper sequence from simple parse", function()
			assert(genbank.feature_sequence(plasmid.features[10], plasmid) == "ATGACCATGATTACGCCAAGCTTGCATGCCTGCAGGTCGACTCTAGAGGATCCCCGGGTACCGAGCTCGAATTCACTGGCCGTCGTTTTACAACGTCGTGACTGGGAAAACCCTGGCGTTACCCAACTTAATCGCCTTGCAGCACATCCCCCTTTCGCCAGCTGGCGTAATAGCGAAGAGGCCCGCACCGATCGCCCTTCCCAACAGTTGCGCAGCCTGAATGGCGAATGGCGCCTGATGCGGTATTTTCTCCTTACGCATCTGTGCGGTATTTCACACCGCATATGGTGCACTCTCAGTACAATCTGCTCTGATGCCGCATAG") -- get CDS
		end)
    it("should parse multiline features", function()
      local gbk_location = pichia.features[-1].location.gbk_location_string
      assert(gbk_location == "join(<459260..459456,459556..459637,459685..459739,459810..>460126)")
    end)
	end)
end)
