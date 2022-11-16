local atoms = require("atoms")
local conversions = require("conversions")

local record mixtures
  record Chemical
      inchi: string
      formula: function(Chemical): string
      g_to_mol: function(Chemical, number): number
  metamethod __mul: function(Chemical, number): Mixture
  end
  chemical_mt: metatable<Chemical>
  record Sequence
      seqhash: string
      sequence: string
      molecule_type: string
      dna: boolean
      double_stranded: boolean
      circular: boolean
      metamethod __mul: function(Sequence, number): Mixture
  end
  sequence_mt: metatable<Sequence>
  record Protein
      sequence: string
      protein_to_mw: function(Protein): number
      g_to_mol: function(Protein, number): number
      metamethod __mul: function(Protein, number): Mixture
  end
  protein_mt: metatable<Protein>
  record Cell
    name: string
    metamethod __mul: function(Cell, number): Mixture
  end
  cell_mt: metatable<Cell>
  record Environmental
      name: string
      metamethod __mul: function(Environmental, number): Mixture
  end
  environmental_mt: metatable<Environmental>

  -- Mixtures
  record Mixture_ChemicalMix
      chemical: Chemical
      quantity: number
  end
  record Mixture_SequenceMix
      sequence: Sequence
      quantity: number
  end
  record Mixture_ProteinMix
      protein: Protein
      quantity: number
  end
  record Mixture_CellMix
      cell: Cell
      quantity: number
  end
  record Mixture_EnvironmentalMix
      environmental: Environmental
      quantity: number
  end
  record Mixture
    chemicals: {Mixture_ChemicalMix}
    sequences: {Mixture_SequenceMix}
    proteins: {Mixture_ProteinMix}
    cells: {Mixture_CellMix}
    environmentals: {Mixture_EnvironmentalMix}
    volume: function(Mixture, number): Mixture
    metamethod __add: function(Mixture, Mixture): Mixture
    metamethod __mul: function(Mixture, number): Mixture
    metamethod __div: function(Mixture, number): Mixture
  end
  mixture_mt: metatable<Mixture>
  volume: function(Mixture, number): Mixture

  -- Defaults
  chemicals: {string: Chemical}
  amino_acids: {string: Chemical}
  sequences: {string: Sequence}
  proteins: {string: Protein}
  cells: {string: Cell}
  environmentals: {string: Environmental}
  common_reagents: {string: Mixture}

  record ChemicalData
    pka: number
    density: number
  end
  chemical_data: {string: ChemicalData}

  amino_acid_weights: {string: number}
  nucleotide_weights: {string: number}

end

--[[---------------------------------------------------------------------------

                               Base functions for metatables

---------------------------------------------------------------------------]]--

local function deepcopy(obj:any): any
  if type(obj) ~= 'table' then return obj end
  local obj_table: {any:any} = obj as {any:any}
  local res = setmetatable({} as {any:any}, getmetatable(obj as {any:any}))
  for k, v in pairs(obj_table) do res[deepcopy(k)] = deepcopy(v) end
  return res
end

-- Returns a mixture at a certain volume
mixtures.volume = function(self: mixtures.Mixture, volume: number): mixtures.Mixture
  local copy: mixtures.Mixture = deepcopy(self) as mixtures.Mixture
    -- Error check if there is no water
    local water_quantity: number = nil
    for _, chemical in ipairs(copy.chemicals) do
        if chemical.chemical.inchi == mixtures.chemicals.H2O.inchi then
            water_quantity = chemical.quantity
        end
    end
    if water_quantity == nil then
        error("no volume")
    end
    local ratio: number = volume / water_quantity
    for _, chemical in ipairs(copy.chemicals) do
        chemical.quantity = chemical.quantity * ratio
    end

  if copy.cells ~= nil then
    for _, cell in ipairs(copy.cells) do
      cell.quantity = cell.quantity * ratio
    end
  end
    return copy
end

--[[---------------------------------------------------------------------------

                                Metatables

---------------------------------------------------------------------------]]--

mixtures.mixture_mt = {
	__add = function<T>(self: mixtures.Mixture, t: mixtures.Mixture): mixtures.Mixture
		local copy: mixtures.Mixture = deepcopy(self) as mixtures.Mixture

		-- Note: I did try to make this generic, but it became unwieldy.
		-- I found it better to have it like this. Perhaps there is a better
		-- way, but I found it good enough.

		-- Handle chemical addition
		if t.chemicals ~= nil then
      if copy.chemicals == nil then copy.chemicals = {} end
			for _, chemicalMix in ipairs(t.chemicals) do
				local found = false
				for i, tbl in ipairs(copy.chemicals) do
					if tbl.chemical.inchi == chemicalMix.chemical.inchi then
						copy.chemicals[i].quantity = copy.chemicals[i].quantity + chemicalMix.quantity
						found = true
					end
				end
				if not found then
					local newSubmix: mixtures.Mixture_ChemicalMix = {chemical = chemicalMix.chemical, quantity = chemicalMix.quantity}
					newSubmix = deepcopy(newSubmix) as mixtures.Mixture_ChemicalMix
					if copy.chemicals == nil then
						copy.chemicals = {newSubmix}
					else
						copy.chemicals[#copy.chemicals+1] = newSubmix
					end
				end
			end
		end

		-- EDIT BELOW USING TEMPLATE FROM ABOVE
		if t.sequences ~= nil then
      if copy.sequences == nil then copy.sequences = {} end
			for _, sequenceMix in ipairs(t.sequences) do
        	    local found = false
        	    for i, tbl in ipairs(copy.sequences) do
        	        if tbl.sequence.seqhash == sequenceMix.sequence.seqhash then
        	            copy.sequences[i].quantity = copy.sequences[i].quantity + sequenceMix.quantity
        	            found = true
        	        end
        	    end
        	   if not found then
        	        local newSubmix: mixtures.Mixture_SequenceMix = {sequence = sequenceMix.sequence, quantity = sequenceMix.quantity}
        	        newSubmix = deepcopy(newSubmix) as mixtures.Mixture_SequenceMix
        	        if copy.sequences == nil then
        	            copy.sequences = {newSubmix}
        	        else
        	            copy.sequences[#copy.sequences+1] = newSubmix
        	        end
        	    end
        	end
		end
		if t.proteins ~= nil then
      if copy.proteins == nil then copy.proteins = {} end
			for _, proteinMix in ipairs(t.proteins) do
        	    local found = false
        	    for i, tbl in ipairs(copy.proteins) do
        	        if tbl.protein.sequence == proteinMix.protein.sequence then
        	            copy.proteins[i].quantity = copy.proteins[i].quantity + proteinMix.quantity
        	            found = true
        	        end
        	    end
        	    if not found then
        	        local newSubmix: mixtures.Mixture_ProteinMix = {protein = proteinMix.protein, quantity = proteinMix.quantity}
        	        newSubmix = deepcopy(newSubmix) as mixtures.Mixture_ProteinMix
        	        if copy.proteins == nil then
        	            copy.proteins = {newSubmix}
        	        else
        	            copy.proteins[#copy.proteins+1] = newSubmix
        	        end
        	    end
        	end
		end
		if t.cells ~= nil then
      if copy.cells == nil then copy.cells = {} end
			for _, cellMix in ipairs(t.cells) do
        	    local found = false
        	    for i, tbl in ipairs(copy.cells) do
        	        if tbl.cell.name == cellMix.cell.name then
        	            copy.cells[i].quantity = copy.cells[i].quantity + cellMix.quantity
        	            found = true
        	        end
        	    end
        	    if not found then
        	        local newSubmix: mixtures.Mixture_CellMix = {cell = cellMix.cell, quantity = cellMix.quantity}
        	        newSubmix = deepcopy(newSubmix) as mixtures.Mixture_CellMix
        	        if copy.cells == nil then
        	            copy.cells = {newSubmix}
        	        else
        	            copy.cells[#copy.cells+1] = newSubmix
        	        end
        	    end
        	end
		end
		if t.environmentals ~= nil then
      if copy.environmentals == nil then copy.environmentals = {} end
			for _, environmentalMix in ipairs(t.environmentals) do
        	    local found = false
        	    for i, tbl in ipairs(copy.environmentals) do
        	        if tbl.environmental.name == environmentalMix.environmental.name then
        	            copy.environmentals[i].quantity = copy.environmentals[i].quantity + environmentalMix.quantity
        	            found = true
        	        end
        	    end
        	    if not found then
        	        local newSubmix: mixtures.Mixture_EnvironmentalMix = {environmental = environmentalMix.environmental, quantity = environmentalMix.quantity}
        	        newSubmix = deepcopy(newSubmix) as mixtures.Mixture_EnvironmentalMix
        	        if copy.environmentals == nil then
        	            copy.environmentals = {newSubmix}
        	        else
        	            copy.environmentals[#copy.environmentals+1] = newSubmix
        	        end
        	    end
        	end
		end

		return copy
	end,

	__mul = function(self: mixtures.Mixture, quantity: number): mixtures.Mixture
		local record Quant
			quantity: number
		end
		local tbls: {{Quant}} = {self.chemicals, self.sequences, self.proteins, self.cells, self.environmentals} as {{Quant}}
		for _, tbl in ipairs(tbls) do
			if tbl ~= nil then
				for _, sub_tbl in ipairs(tbl) do
					sub_tbl.quantity = sub_tbl.quantity * quantity
				end
			end
		end
    	return self
	end,

	__div = function(self: mixtures.Mixture, quantity: number): mixtures.Mixture
		local record Quant
            quantity: number
        end
        local tbls: {{Quant}} = {self.chemicals, self.sequences, self.proteins, self.cells, self.environmentals} as {{Quant}}
        for _, tbl in ipairs(tbls) do
            if tbl ~= nil then
                for _, sub_tbl in ipairs(tbl) do
                    sub_tbl.quantity = sub_tbl.quantity / quantity
                end
            end
        end
        return self
	end
}

mixtures.chemical_mt = {
    __mul = function(self: mixtures.Chemical, quantity: number): mixtures.Mixture
		  local mix = setmetatable({chemicals = {{chemical = self, quantity = quantity}}} as mixtures.Mixture, mixtures.mixture_mt)
		  mix.volume = mixtures.volume
		  return mix
    end
}

mixtures.sequence_mt = {
    __mul = function(self: mixtures.Sequence, quantity: number): mixtures.Mixture
      local mix = setmetatable({sequences = {{sequence = self, quantity = quantity}}} as mixtures.Mixture, mixtures.mixture_mt)
      mix.volume = mixtures.volume
      return mix
    end
}

mixtures.protein_mt = {
    __mul = function(self: mixtures.Protein, quantity: number): mixtures.Mixture
      local mix = setmetatable({proteins = {{protein = self, quantity = quantity}}} as mixtures.Mixture, mixtures.mixture_mt)
      mix.volume = mixtures.volume
      return mix
    end
}

mixtures.cell_mt = {
	__mul = function(self: mixtures.Cell, quantity: number): mixtures.Mixture
		local mix = setmetatable({cells = {{cell = self, quantity = quantity}}} as mixtures.Mixture, mixtures.mixture_mt)
		mix.volume = mixtures.volume
		return mix
	end
}

mixtures.environmental_mt = {
    __mul = function(self: mixtures.Environmental, quantity: number): mixtures.Mixture
      local mix = setmetatable({environmentals = {{environmnetal = self, quantity = quantity}}} as mixtures.Mixture, mixtures.mixture_mt)
      mix.volume = mixtures.volume
      return mix
    end
}

--[[---------------------------------------------------------------------------

Defaults

---------------------------------------------------------------------------]]--

local chemicals: {string: mixtures.Chemical} = {
    -- H2O is special because it contributes to calculated volume
    H2O = {inchi = "InChI=1S/H2O/h1H2"},
    glycerol = {inchi = "InChI=1S/C3H8O3/c4-1-3(6)2-5/h3-6H,1-2H2"},
    sds = {inchi = "InChI=1S/C12H26O4S.Na/c1-2-3-4-5-6-7-8-9-10-11-12-16-17(13,14)15;/h2-12H2,1H3,(H,13,14,15);/q;+1/p-1"},

    biotin = {inchi = "InChI=1S/C10H16N2O3S/c13-8(14)4-2-1-3-7-9-6(5-16-7)11-10(15)12-9/h6-7,9H,1-5H2,(H,13,14)(H2,11,12,15)/t6-,7-,9-/m0/s1"},
    bromophenol_blue = {inchi = "InChI=1S/C19H10Br4O5S/c20-12-5-9(6-13(21)17(12)24)19(10-7-14(22)18(25)15(23)8-10)11-3-1-2-4-16(11)29(26,27)28-19/h1-8,24-25H"},
    C2H3O2K = {inchi = "InChI=1S/C2H4O2.K/c1-2(3)4;/h1H3,(H,3,4);/q;+1/p-1"},
    CaCl2 = {inchi = "InChI=1S/Ca.2ClH/h;2*1H/q+2;;/p-2"},
    CoCl2 = {inchi = "InChI=1S/2ClH.Co/h2*1H;/q;;+2/p-2"},
    CuCl2 = {inchi = "InChI=1S/2ClH.Cu/h2*1H;/q;;+2/p-2"},
    dithiothreitol = {inchi = "InChI=1S/C4H10O2S2/c5-3(1-7)4(6)2-8/h3-8H,1-2H2"},
    EDTA = {inchi = "InChI=1S/C10H16N2O8/c13-7(14)3-11(4-8(15)16)1-2-12(5-9(17)18)6-10(19)20/h1-6H2,(H,13,14)(H,15,16)(H,17,18)(H,19,20)"},
    FeCl3 = {inchi = "InChI=1S/3ClH.Fe/h3*1H;/q;;;+3/p-3"},
    glucose = {inchi = "InChI=1S/C6H12O6/c7-1-2-3(8)4(9)5(10)6(11)12-2/h2-11H,1H2/t2-,3-,4+,5-,6?/m1/s1"},
    H3BO3 = {inchi = "InChI=1S/BH3O3/c2-1(3)4/h2-4H"},
    KH2PO4 = {inchi = "InChI=1S/K.H3O4P/c;1-5(2,3)4/h;(H3,1,2,3,4)/q+1;/p-1"},
    MgSO4 = {inchi = "InChI=1S/Mg.H2O4S/c;1-5(2,3)4/h;(H2,1,2,3,4)/q+2;/p-2"},
    MgCl2 = {inchi = "InChI=1S/2ClH.Mg/h2*1H;/q;;+2/p-2"},
    MnCl2 = {inchi = "InChI=1S/2ClH.Mn/h2*1H;/q;;+2/p-2"},
    Na2HPO4 = {inchi = "InChI=1S/2Na.H3O4P/c;;1-5(2,3)4/h;;(H3,1,2,3,4)/q2*+1;/p-2"},
    NaCl = {inchi = "InChI=1S/ClH.Na/h1H;/q;+1/p-1"},
    NH4Cl = {inchi = "InChI=1S/ClH.H3N/h1H;1H3"},
    thiamin = {inchi = "InChI=1S/C12H17N4OS/c1-8-11(3-4-17)18-7-16(8)6-10-5-14-9(2)15-12(10)13/h5,7,17H,3-4,6H2,1-2H3,(H2,13,14,15)/q+1"}, -- heat sensitive
    ZnCl2 = {inchi = "InChI=1S/2ClH.Zn/h2*1H;/q;;+2/p-2"},

    -- Buffers
    tris_HCl = {inchi = "InChI=1S/C4H11NO3.ClH/c5-4(1-6,2-7)3-8;/h6-8H,1-3,5H2;1H"},
    bis_tris_propane_HCl = {inchi = "InChI=1S/C8H19NO5.ClH/c10-3-1-9(2-4-11)8(5-12,6-13)7-14;/h10-14H,1-7H2;1H"},

    -- Amino acids
    alanine = {inchi = "InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1"},
    arginine = {inchi = "InChI=1S/C6H14N4O2/c7-4(5(11)12)2-1-3-10-6(8)9/h4H,1-3,7H2,(H,11,12)(H4,8,9,10)/t4-/m0/s1"},
    asparagine = {inchi = "InChI=1S/C4H8N2O3/c5-2(4(8)9)1-3(6)7/h2H,1,5H2,(H2,6,7)(H,8,9)/t2-/m0/s1"},
    aspartic_acid = {inchi = "InChI=1S/C4H7NO4/c5-2(4(8)9)1-3(6)7/h2H,1,5H2,(H,6,7)(H,8,9)/t2-/m0/s1"},
    cysteine = {inchi = "InChI=1S/C3H7NO2S/c4-2(1-7)3(5)6/h2,7H,1,4H2,(H,5,6)/t2-/m0/s1"},
    glutamine = {inchi = "InChI=1S/C5H10N2O3/c6-3(5(9)10)1-2-4(7)8/h3H,1-2,6H2,(H2,7,8)(H,9,10)/t3-/m0/s1"},
    glutamic_acid = {inchi = "InChI=1S/C5H9NO4/c6-3(5(9)10)1-2-4(7)8/h3H,1-2,6H2,(H,7,8)(H,9,10)/t3-/m0/s1"},
    glycine = {inchi = "InChI=1S/C2H5NO2/c3-1-2(4)5/h1,3H2,(H,4,5)"},
    histidine = {inchi = "InChI=1S/C6H9N3O2/c7-5(6(10)11)1-4-2-8-3-9-4/h2-3,5H,1,7H2,(H,8,9)(H,10,11)/t5-/m0/s1"},
    isoleucine = {inchi = "InChI=1S/C6H13NO2/c1-3-4(2)5(7)6(8)9/h4-5H,3,7H2,1-2H3,(H,8,9)/t4-,5-/m0/s1"},
    leucine = {inchi = "InChI=1S/C6H13NO2/c1-4(2)3-5(7)6(8)9/h4-5H,3,7H2,1-2H3,(H,8,9)/t5-/m0/s1"},
    lysine = {inchi = "InChI=1S/C6H14N2O2/c7-4-2-1-3-5(8)6(9)10/h5H,1-4,7-8H2,(H,9,10)/t5-/m0/s1"},
    methionine = {inchi = "InChI=1S/C5H11NO2S/c1-9-3-2-4(6)5(7)8/h4H,2-3,6H2,1H3,(H,7,8)/t4-/m0/s1"},
    phenylalanine = {inchi = "InChI=1S/C9H11NO2/c10-8(9(11)12)6-7-4-2-1-3-5-7/h1-5,8H,6,10H2,(H,11,12)/t8-/m0/s1"},
    proline = {inchi = "InChI=1S/C5H9NO2/c7-5(8)4-2-1-3-6-4/h4,6H,1-3H2,(H,7,8)/t4-/m0/s1"},
    serine = {inchi = "InChI=1S/C3H7NO3/c4-2(1-5)3(6)7/h2,5H,1,4H2,(H,6,7)/t2-/m0/s1"},
    threonine = {inchi = "InChI=1S/C4H9NO3/c1-2(6)3(5)4(7)8/h2-3,6H,5H2,1H3,(H,7,8)/t2-,3+/m1/s1"},
    tryptophan = {inchi = "InChI=1S/C11H12N2O2/c12-9(11(14)15)5-7-6-13-10-4-2-1-3-8(7)10/h1-4,6,9,13H,5,12H2,(H,14,15)/t9-/m0/s1"},
    tyrosine = {inchi = "InChI=1S/C9H11NO3/c10-8(9(12)13)5-6-1-3-7(11)4-2-6/h1-4,8,11H,5,10H2,(H,12,13)/t8-/m0/s1"},
    valine = {inchi = "InChI=1S/C5H11NO2/c1-3(2)4(6)5(7)8/h3-4H,6H2,1-2H3,(H,7,8)/t4-/m0/s1"},
    selenocysteine = {inchi = "InChI=1S/C3H6NO2Se/c4-2(1-7)3(5)6/h2H,1,4H2,(H,5,6)/t2-/m0/s1"},
    pyrrolysine = {inchi = "InChI=1S/C12H21N3O3/c1-8-5-7-14-10(8)11(16)15-6-3-2-4-9(13)12(17)18/h7-10H,2-6,13H2,1H3,(H,15,16)(H,17,18)/t8-,9+,10-/m1/s1"},
}

-- g/cm3
local chemical_data: {string: mixtures.ChemicalData} = {
  [chemicals.H2O.inchi] = {pka = 14.0, density = 0.9950}, -- https://pubchem.ncbi.nlm.nih.gov/compound/Water#section=Density https://chem.libretexts.org/Bookshelves/Organic_Chemistry/Supplemental_Modules_(Organic_Chemistry)/Fundamentals/What_is_the_pKa_of_water
  [chemicals.glycerol.inchi] = {pka = 14.4, density = 1.2613}, -- https://pubchem.ncbi.nlm.nih.gov/compound/Glycerol#section=Density https://pubchem.ncbi.nlm.nih.gov/compound/Glycerol#section=Refractive-Index
  [chemicals.sds.inchi] = {density = 1.1}, -- https://pubchem.ncbi.nlm.nih.gov/compound/3423265#section=Density

  [chemicals.biotin.inchi] = {pka = 0},
  [chemicals.bromophenol_blue.inchi] = {pka = 0},
  [chemicals.C2H3O2K.inchi] = {pka = 0},
  [chemicals.CaCl2.inchi] = {pka = 0},
  [chemicals.CoCl2.inchi] = {pka = 0},
  [chemicals.CuCl2.inchi] = {pka = 0},
  [chemicals.dithiothreitol.inchi] = {pka = 0},
  [chemicals.EDTA.inchi] = {pka = 0},
  [chemicals.FeCl3.inchi] = {pka = 0},
  [chemicals.glucose.inchi] = {pka = 0},
  [chemicals.H3BO3.inchi] = {pka = 0},
  [chemicals.KH2PO4.inchi] = {pka = 0},
  [chemicals.MgSO4.inchi] = {pka = 0},
  [chemicals.MgCl2.inchi] = {pka = 0},
  [chemicals.MnCl2.inchi] = {pka = 0},
  [chemicals.Na2HPO4.inchi] = {pka = 0},
  [chemicals.NaCl.inchi] = {pka = 0},
  [chemicals.NH4Cl.inchi] = {pka = 0},
  [chemicals.thiamin.inchi] = {pka = 0},
  [chemicals.sds.inchi] = {pka = 0},
  [chemicals.ZnCl2.inchi] = {pka = 0},

  [chemicals.tris_HCl.inchi] = {pka = 0},
  [chemicals.bis_tris_propane_HCl.inchi] = {pka = 0},

  [chemicals.alanine.inchi] = {pka = 0},
  [chemicals.arginine.inchi] = {pka = 0},
  [chemicals.asparagine.inchi] = {pka = 0},
  [chemicals.aspartic_acid.inchi] = {pka = 0},
  [chemicals.cysteine.inchi] = {pka = 0},
  [chemicals.glutamine.inchi] = {pka = 0},
  [chemicals.glutamic_acid.inchi] = {pka = 0},
  [chemicals.glycine.inchi] = {pka = 0},
  [chemicals.histidine.inchi] = {pka = 0},
  [chemicals.isoleucine.inchi] = {pka = 0},
  [chemicals.leucine.inchi] = {pka = 0},
  [chemicals.lysine.inchi] = {pka = 0},
  [chemicals.methionine.inchi] = {pka = 0},
  [chemicals.phenylalanine.inchi] = {pka = 0},
  [chemicals.proline.inchi] = {pka = 0},
  [chemicals.serine.inchi] = {pka = 0},
  [chemicals.threonine.inchi] = {pka = 0},
  [chemicals.tryptophan.inchi] = {pka = 0},
  [chemicals.tyrosine.inchi] = {pka = 0},
  [chemicals.valine.inchi] = {pka = 0},
  [chemicals.selenocysteine.inchi] = {pka = 0},
  [chemicals.pyrrolysine.inchi] = {pka = 0},

}

mixtures.chemical_data = chemical_data

local function formula(self: mixtures.Chemical): string
  return self.inchi:match("/(.-)/")
end

mixtures.chemicals = {}
for k, v in pairs(chemicals) do
  v.formula = formula
  v.g_to_mol = function(self: mixtures.Chemical, n: number): number return conversions.g_to_mol(n, atoms.formula_to_mw(self:formula())) end
	mixtures.chemicals[k] = setmetatable(v, mixtures.chemical_mt)
end

mixtures.amino_acid_weights = {
  A = atoms.formula_to_mw(mixtures.chemicals.alanine:formula()),
  R = atoms.formula_to_mw(mixtures.chemicals.arginine:formula()),
  N = atoms.formula_to_mw(mixtures.chemicals.asparagine:formula()),
  D = atoms.formula_to_mw(mixtures.chemicals.aspartic_acid:formula()),
  C = atoms.formula_to_mw(mixtures.chemicals.cysteine:formula()),
  Q = atoms.formula_to_mw(mixtures.chemicals.glutamine:formula()),
  E = atoms.formula_to_mw(mixtures.chemicals.glutamic_acid:formula()),
  G = atoms.formula_to_mw(mixtures.chemicals.glycine:formula()),
  H = atoms.formula_to_mw(mixtures.chemicals.histidine:formula()),
  I = atoms.formula_to_mw(mixtures.chemicals.isoleucine:formula()),
  L = atoms.formula_to_mw(mixtures.chemicals.leucine:formula()),
  K = atoms.formula_to_mw(mixtures.chemicals.lysine:formula()),
  M = atoms.formula_to_mw(mixtures.chemicals.methionine:formula()),
  F = atoms.formula_to_mw(mixtures.chemicals.phenylalanine:formula()),
  P = atoms.formula_to_mw(mixtures.chemicals.proline:formula()),
  S = atoms.formula_to_mw(mixtures.chemicals.serine:formula()),
  T = atoms.formula_to_mw(mixtures.chemicals.threonine:formula()),
  W = atoms.formula_to_mw(mixtures.chemicals.tryptophan:formula()),
  Y = atoms.formula_to_mw(mixtures.chemicals.tyrosine:formula()),
  V = atoms.formula_to_mw(mixtures.chemicals.valine:formula()),
  U = atoms.formula_to_mw(mixtures.chemicals.selenocysteine:formula()),
  O = atoms.formula_to_mw(mixtures.chemicals.pyrrolysine:formula()),
}

--[[---------------------------------------------------------------------------

                          Proteins 

---------------------------------------------------------------------------]]--

local proteins: {string: mixtures.Protein} = {
  human_serum_albumin = {sequence = "MKWVTFISLLFLFSSAYSRGVFRRDAHKSEVAHRFKDLGEENFKALVLIAFAQYLQQCPFEDHVKLVNEVTEFAKTCVADESAENCDKSLHTLFGDKLCTVATLRETYGEMADCCAKQEPERNECFLQHKDDNPNLPRLVRPEVDVMCTAFHDNEETFLKKYLYEIARRHPYFYAPELLFFAKRYKAAFTECCQAADKAACLLPKLDELRDEGKASSAKQRLKCASLQKFGERAFKAWAVARLSQRFPKAEFAEVSKLVTDLTKVHTECCHGDLLECADDRADLAKYICENQDSISSKLKECCEKPLLEKSHCIAEVENDEMPADLPSLAADFVESKDVCKNYAEAKDVFLGMFLYEYARRHPDYSVVLLLRLAKTYETTLEKCCAAADPHECYAKVFDEFKPLVEEPQNLIKQNCELFEQLGEYKFQNALLVRYTKKVPQVSTPTLVEVSRNLGKVGSKCCKHPEAKRMPCAEDYLSVVLNQLCVLHEKTPVSDRVTKCCTESLVNRRPCFSALEVDETYVPKEFNAETFTFHADICTLSEKERQIKKQTALVELVKHKPKATKEQLKAVMDDFAAFVEKCCKADDKETCFAEEGKKLVAASQAALGL"}
}
mixtures.proteins = {}
local function protein_to_mw(self: mixtures.Protein): number
  local H2O_mw = atoms.formula_to_mw(mixtures.chemicals.H2O:formula())
  local mw: number = 0.0
  for i = 1,#self.sequence do
    local aa = self.sequence:sub(i,i)
    mw = mw + mixtures.amino_acid_weights[aa]
    mw = mw - H2O_mw
  end
  mw = mw + H2O_mw -- the last amino acid still has water attached
  return mw
end

for k, v in pairs(proteins) do
  v.g_to_mol = function(self: mixtures.Protein, n: number): number return conversions.g_to_mol(n, protein_to_mw(self)) end
  mixtures.proteins[k] = setmetatable(v, mixtures.protein_mt)
end


--[[---------------------------------------------------------------------------

                           Cells

---------------------------------------------------------------------------]]--

local cells: {string: mixtures.Cell} = {
  ["Escherichia coli MG1655"] = {name = "Escherichia coli MG1655"}
}
mixtures.cells = {}
for k, v in pairs(cells) do
  mixtures.cells[k] = setmetatable(v, mixtures.cell_mt)
end


--[[---------------------------------------------------------------------------

                            Common reagents

---------------------------------------------------------------------------]]--

local common_reagents: {string: mixtures.Mixture} = {
  -- M9 recipe https://www.helmholtz-muenchen.de/fileadmin/PEPF/Protocols/M9-medium_150510.pdf
  M9 = (mixtures.chemicals.H2O * conversions.l) +
    (mixtures.chemicals.CaCl2 * 0.3 * conversions.mmol) +
    (mixtures.chemicals.MgSO4 * 1 * conversions.mmol) +
    (mixtures.chemicals.biotin * conversions.g_to_mol(conversions.mg, 244.31)) + -- molecular weight 244.31g/mol, need 1mg.
    (mixtures.chemicals.thiamin * conversions.g_to_mol(conversions.mg, 265.355)) + -- molecular weight 265.355g/mol, need 1mg
    (mixtures.chemicals.glucose * conversions.g_to_mol(4*conversions.g, 180.156)) + -- molecular weight 180.156g/mol, need 4g
    (((mixtures.chemicals.Na2HPO4 * 337 * conversions.mmol) +
      (mixtures.chemicals.KH2PO4 * 220 * conversions.mmol) +
      (mixtures.chemicals.NaCl * 85.5 * conversions.mmol) +
      (mixtures.chemicals.NH4Cl * 93.5 * conversions.mmol)
    ) / 10.0) + -- 10x M9 salt solution
    (((mixtures.chemicals.EDTA * 13.4 * conversions.mmol) +
      (mixtures.chemicals.FeCl3 * 3.1 * conversions.mmol) +
      (mixtures.chemicals.ZnCl2 * 0.62 * conversions.mmol) +
      (mixtures.chemicals.CuCl2 * 76 * conversions.umol) +
      (mixtures.chemicals.CoCl2 * 42 * conversions.umol) +
      (mixtures.chemicals.H3BO3 * 162 * conversions.umol) +
      (mixtures.chemicals.MnCl2 * 8.1 * conversions.umol)
    ) / 100), -- 100x trace elements

    -- NEBuffer r1.1, r2.1, r3.1, rCutsmart
    -- _u denotes nothing about the pH
    ["NEBuffer_r1.1_u"] = (mixtures.chemicals.H2O * conversions.l) +
      (mixtures.chemicals.bis_tris_propane_HCl * 10 * conversions.mmol) +
      (mixtures.chemicals.MgCl2 * 10 * conversions.mmol) +
      (mixtures.proteins.human_serum_albumin * mixtures.proteins.human_serum_albumin:g_to_mol(100 * conversions.ug))
}
mixtures.common_reagents = common_reagents

return mixtures
