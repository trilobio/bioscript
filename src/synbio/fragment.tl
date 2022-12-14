--[[---------------------------------------------------------------------------
The fragment module optimally fragments DNA for GoldenGate systems.

Optimal fragmentation is accomplished by using empirical fidelity data derived
by NEB in the paper "Comprehensive Profiling of Four Base Overhang Ligation
Fidelity by T4 DNA Ligase and Application to DNA Assembly". We use the data
associated with T4 ligase @ 37c for 1hr.
Paper link: https://doi.org/10.1021/acssynbio.8b00333
--]]---------------------------------------------------------------------------
local record fragment
  overhang_efficiency: function(string, string): number
  set_efficiency: function({string}): number
  next_overhangs: function({string}): {string}, {number}
  next_overhang: function({string}): string
  fragmentation_table: {string: integer}
  fragment_sequence: function(string, integer, integer): {string}, number
end

local complement = require("complement")

fragment.fragmentation_table = {["AAAATTTT"]=187,["AAAATTAT"]=1,["AAACTTTT"]=1,["AAACGTTT"]=2888,["AAACGGTT"]=2,["AAACGTGT"]=1,["AAACGTAT"]=3,["AAACGTTG"]=15,["AAACGTTC"]=5,["AAACGTTA"]=4,["AAAGTTTT"]=3,["AAAGCTTT"]=1678,["AAAGATTT"]=1,["AAAGTCTT"]=2,["AAAGCTGT"]=1,["AAAGCCGT"]=1,["AAAGCTCT"]=1,["AAAGCTTG"]=8,["AAAGCTTC"]=7,["AAAGCTTA"]=3,["AAATTTTT"]=5,["AAATGTTT"]=46,["AAATATTT"]=1111,["AAATAATT"]=1,["AAATATGT"]=1,["AAATATAT"]=1,["AAATATTG"]=1,["AAATGTTC"]=1,["AAATATTC"]=1,["AACATGTT"]=1476,["AACAGGTT"]=2,["AACAAGTT"]=1,["AACATGGT"]=1,["AACATGCT"]=1,["AACATGAT"]=2,["AACATGTG"]=1,["AACATGTC"]=1,["AACCGTTT"]=3,["AACCGGTT"]=4307,["AACCCGTT"]=1,["AACCGATT"]=5,["AACCGTGT"]=1,["AACCGGGT"]=7,["AACCGGCT"]=2,["AACCGGAT"]=2,["AACCGGTG"]=8,["AACCGGTC"]=10,["AACCGGAC"]=1,["AACGCTTT"]=3,["AACGTGTT"]=108,["AACGCGTT"]=3372,["AACGAGTT"]=1,["AACGGCTT"]=1,["AACGCATT"]=6,["AACGTGGT"]=1,["AACGCGGT"]=6,["AACGCGCT"]=3,["AACGCGAT"]=1,["AACGCGTG"]=14,["AACGCGTC"]=19,["AACGCGTA"]=5,["AACTTGTT"]=29,["AACTGGTT"]=60,["AACTAGTT"]=2375,["AACTACTT"]=1,["AACTAGGT"]=2,["AACTTGAT"]=1,["AACTAGAT"]=4,["AACTGGTG"]=2,["AACTAGTG"]=4,["AACTAGTC"]=2,["AACTAGTA"]=3,["AAGATCTT"]=405,["AAGACCTT"]=1,["AAGATCCT"]=1,["AAGATCAT"]=1,["AAGCGTTT"]=5,["AAGCGGTT"]=9,["AAGCTCTT"]=1,["AAGCGCTT"]=3586,["AAGCACTT"]=1,["AAGCGATT"]=2,["AAGCGCGT"]=1,["AAGCGGCT"]=1,["AAGCGCCT"]=1,["AAGCGCAT"]=2,["AAGCGGTG"]=1,["AAGCGCTG"]=9,["AAGCGCGG"]=2,["AAGCGAGG"]=1,["AAGCGGTC"]=1,["AAGCGCTC"]=4,["AAGCGCTA"]=2,["AAGCGCGA"]=2,["AAGGCTTT"]=2,["AAGGCGTT"]=1,["AAGGTCTT"]=31,["AAGGCCTT"]=2773,["AAGGACTT"]=2,["AAGGCCGT"]=3,["AAGGCCCT"]=2,["AAGGCTTG"]=1,["AAGGCCTG"]=7,["AAGGCCTC"]=5,["AAGGCCTA"]=2,["AAGGCCGA"]=1,["AAGGCCAA"]=1,["AAGTGTTT"]=1,["AAGTAGTT"]=3,["AAGTTCTT"]=3,["AAGTGCTT"]=53,["AAGTACTT"]=1189,["AAGTAATT"]=1,["AAGTACTG"]=1,["AAGTACTC"]=1,["AATATTTT"]=2,["AATATCTT"]=1,["AATATATT"]=312,["AATCGTTT"]=3,["AATCGGTT"]=12,["AATCGCTT"]=5,["AATCGATT"]=2504,["AATCGAGT"]=1,["AATCGTAT"]=1,["AATCGGAT"]=1,["AATCGATG"]=5,["AATCGATC"]=7,["AATCGATA"]=2,["AATGCTTT"]=5,["AATGCGTT"]=2,["AATGCCTT"]=2,["AATGTATT"]=14,["AATGGATT"]=1,["AATGCATT"]=2259,["AATGAATT"]=2,["AATGCAGT"]=1,["AATGCAAT"]=1,["AATGCATG"]=5,["AATGCATC"]=7,["AATTATTT"]=2,["AATTAGTT"]=1,["AATTTCTT"]=1,["AATTTATT"]=6,["AATTGATT"]=5,["AATTCATT"]=1,["AATTAATT"]=1088,["AATTGTAT"]=1,["AATTTAAT"]=1,["AATTCAAT"]=1,["ACAATTGT"]=310,["ACAAGCGT"]=1,["ACAATTGG"]=5,["ACAATTGC"]=1,["ACACGTTT"]=5,["ACACCGTT"]=1,["ACACTTGT"]=1,["ACACGTGT"]=3412,["ACACGGGT"]=19,["ACACGCGT"]=1,["ACACGAGT"]=1,["ACACGTCT"]=3,["ACACGTTG"]=3,["ACACGTGG"]=84,["ACACGTGC"]=17,["ACACGTTA"]=1,["ACACGTGA"]=3,["ACAGCTTT"]=3,["ACAGTTGT"]=9,["ACAGGTGT"]=1,["ACAGCTGT"]=2701,["ACAGATGT"]=1,["ACAGCGGT"]=1,["ACAGCAGT"]=1,["ACAGCTAT"]=1,["ACAGCTTG"]=3,["ACAGCTGG"]=119,["ACAGTTGC"]=1,["ACAGCTGC"]=20,["ACAGCTTA"]=1,["ACAGCTGA"]=6,["ACAGCTAA"]=1,["ACATTTGT"]=4,["ACATGTGT"]=86,["ACATATGT"]=1762,["ACATAGGT"]=2,["ACATGCGT"]=1,["ACATATTG"]=1,["ACATTTGG"]=1,["ACATGTGG"]=1,["ACATATGG"]=19,["ACATGTGC"]=2,["ACATATGC"]=3,
["ACATGTTA"]=1,["ACATATTA"]=1,["ACCATGTT"]=1,["ACCATGGT"]=2380,["ACCAGGGT"]=3,["ACCAAGGT"]=2,["ACCAGCGT"]=2,["ACCATGAT"]=2,["ACCATGGG"]=9,["ACCATGGA"]=3,["ACCCGGTT"]=3,["ACCCGTGT"]=6,["ACCCTGGT"]=1,["ACCCGGGT"]=4127,["ACCCCGGT"]=1,["ACCCGGAT"]=2,["ACCCGGTG"]=2,["ACCCGGGG"]=63,["ACCCGGGC"]=15,["ACCCGGTA"]=3,["ACCCGGGA"]=3,["ACCCGGCA"]=1,["ACCGGGTT"]=1,["ACCGCGTT"]=3,["ACCGCTGT"]=4,["ACCGATGT"]=1,["ACCGTGGT"]=103,["ACCGGGGT"]=7,["ACCGCGGT"]=4222,["ACCGCAGT"]=2,["ACCGCGAT"]=2,["ACCGCGTG"]=1,["ACCGCTGG"]=1,["ACCGTGGG"]=1,["ACCGCGGG"]=109,["ACCGACCG"]=2,["ACCGCGGC"]=20,["ACCGCGCC"]=1,["ACCGCAAC"]=1,["ACCGCGTA"]=2,["ACCGCGGA"]=9,["ACCTGGTT"]=1,["ACCTTGGT"]=72,["ACCTGGGT"]=44,["ACCTCGGT"]=3,["ACCTAGGT"]=3099,["ACCTGAGT"]=2,["ACCTACCT"]=2,["ACCTAGAT"]=1,["ACCTATGG"]=1,["ACCTTGGG"]=1,["ACCTGGGG"]=1,["ACCTAGGG"]=21,["ACCTAGGC"]=4,["ACCTAGGA"]=1,["ACGATTGT"]=6,["ACGACTGT"]=1,["ACGATGGT"]=2,["ACGATCGT"]=1083,["ACGAGCGT"]=5,["ACGACCGT"]=1,["ACGAACGT"]=2,["ACGATAGT"]=2,["ACGATCTG"]=1,["ACGATCGG"]=2,["ACGATCGC"]=1,["ACGCGCTT"]=4,["ACGCGTGT"]=6,["ACGCGGGT"]=17,["ACGCCGGT"]=1,["ACGCGCGT"]=3446,["ACGCCCGT"]=1,["ACGCACGT"]=2,["ACGCGAGT"]=1,["ACGCGTCT"]=1,["ACGCGCCT"]=1,["ACGCGCTG"]=1,["ACGCGCGG"]=28,["ACGCGCCG"]=1,["ACGCGCTC"]=1,["ACGCGATC"]=1,["ACGCGCGC"]=18,["ACGCGACC"]=1,["ACGCGCTA"]=3,["ACGCGCGA"]=3,["ACGCGTCA"]=1,["ACGGCGTT"]=1,["ACGGCCTT"]=4,["ACGGTTGT"]=1,["ACGGCTGT"]=6,["ACGGCGGT"]=5,["ACGGTCGT"]=62,["ACGGGCGT"]=1,["ACGGCCGT"]=3626,["ACGGACGT"]=5,["ACGGCCAT"]=4,["ACGGCGTG"]=1,["ACGGCCTG"]=8,["ACGGCCGG"]=93,["ACGGTCGC"]=1,["ACGGCCGC"]=58,["ACGGCACC"]=1,["ACGGTCAC"]=1,["ACGGCCTA"]=13,["ACGGCCGA"]=5,["ACGTACTT"]=3,["ACGTATGT"]=4,["ACGTTGGT"]=1,["ACGTGGGT"]=1,["ACGTAGGT"]=6,["ACGTTCGT"]=7,["ACGTGCGT"]=60,["ACGTACGT"]=1744,["ACGTTAGT"]=1,["ACGTGCTG"]=1,["ACGTGCGG"]=1,["ACGTGCGC"]=3,["ACTATTGT"]=1,["ACTACTGT"]=1,["ACTAATGT"]=1,["ACTATGGT"]=3,["ACTACGGT"]=1,["ACTAGCGT"]=1,["ACTATAGT"]=442,["ACTAGAGT"]=2,["ACTATAGC"]=1,["ACTCGTGT"]=5,["ACTCGGGT"]=62,["ACTCGCGT"]=5,["ACTCGAGT"]=2698,["ACTCGATG"]=1,["ACTCGAGG"]=9,["ACTCACTC"]=2,["ACTCGAGA"]=2,["ACTGCATT"]=2,["ACTGCTGT"]=14,["ACTGATGT"]=1,["ACTGCGGT"]=29,["ACTGCCGT"]=1,["ACTGTAGT"]=15,["ACTGGAGT"]=1,["ACTGCAGT"]=1880,["ACTGTTAT"]=1,["ACTGCAAT"]=1,["ACTGGGTG"]=1,["ACTGAGTG"]=1,["ACTGCCGG"]=1,["ACTGTAGG"]=1,["ACTGCAGG"]=43,["ACTGCAGC"]=4,["ACTGCTTA"]=1,["ACTGCAGA"]=3,["ACTTACTT"]=2,["ACTTATGT"]=2,["ACTTTGGT"]=2,["ACTTAGGT"]=5,["ACTTTAGT"]=12,["ACTTGAGT"]=4,["ACTTCAGT"]=1,["AGAATTGT"]=3,["AGAATTCT"]=543,["AGAATTCC"]=1,["AGACGTTT"]=23,["AGACGTGT"]=54,["AGACGTCT"]=3170,["AGACGGCT"]=32,["AGACGACT"]=3,["AGACGTAT"]=5,["AGACGTCG"]=33,["AGACGTCC"]=3,["AGACGGCC"]=1,["AGACGTTA"]=2,["AGACGTCA"]=3,["AGACGGCA"]=1,["AGAGCTTT"]=20,["AGAGCTGT"]=50,["AGAGTTCT"]=10,["AGAGGTCT"]=1,["AGAGCTCT"]=2525,["AGAGCGCT"]=2,["AGAGCCCT"]=1,["AGAGCACT"]=1,["AGAGCTAT"]=10,["AGAGCTTG"]=1,["AGAGCTCG"]=25,["AGAGCCAG"]=1,["AGAGCTTC"]=1,["AGAGCTCC"]=4,["AGAGCTAC"]=1,["AGAGCTTA"]=1,["AGAGCTCA"]=5,["AGAGTTAA"]=1,["AGATGTTT"]=1,["AGATATTT"]=7,["AGATGTGT"]=1,
["AGATATGT"]=28,["AGATTTCT"]=8,["AGATGTCT"]=113,["AGATATCT"]=2084,["AGATAGCT"]=1,["AGATATAT"]=1,["AGATATGG"]=1,["AGATATCG"]=15,["AGATATCC"]=1,["AGATGTCA"]=1,["AGATATCA"]=2,["AGCATGTT"]=2,["AGCAGGTT"]=1,["AGCATGGT"]=16,["AGCATGCT"]=2924,["AGCAGGCT"]=9,["AGCACGCT"]=3,["AGCAAGCT"]=3,["AGCATACT"]=1,["AGCATGAT"]=2,["AGCATGTG"]=1,["AGCATGCG"]=3,["AGCATGCC"]=1,["AGCAGGCC"]=2,["AGCCGTTT"]=1,["AGCCATTT"]=1,["AGCCGGTT"]=28,["AGCCGGGT"]=54,["AGCCGTCT"]=14,["AGCCTGCT"]=2,["AGCCGGCT"]=4246,["AGCCCGCT"]=3,["AGCCAGCT"]=1,["AGCCGCCT"]=1,["AGCCGACT"]=11,["AGCCGGAT"]=8,["AGCCGGTG"]=1,["AGCCGCTG"]=1,["AGCCGTCG"]=1,["AGCCGGCG"]=34,["AGCCGGGC"]=1,["AGCCGGCC"]=18,["AGCCGGCA"]=5,["AGCGCGTT"]=29,["AGCGGCTT"]=1,["AGCGGGGT"]=1,["AGCGCGGT"]=77,["AGCGCTCT"]=16,["AGCGTGCT"]=370,["AGCGGGCT"]=10,["AGCGCGCT"]=3837,["AGCGAGCT"]=16,["AGCGTACT"]=1,["AGCGCACT"]=18,["AGCGTGAT"]=1,["AGCGCGAT"]=13,["AGCGCGTG"]=1,["AGCGGCTG"]=1,["AGCGCGGG"]=1,["AGCGCGCG"]=63,["AGCGCGCC"]=17,["AGCGCGCA"]=6,["AGCTGGTT"]=1,["AGCTAGTT"]=8,["AGCTAGGT"]=29,["AGCTTGCT"]=128,["AGCTGGCT"]=198,["AGCTAGCT"]=3566,["AGCTGGAT"]=1,["AGCTTTGC"]=1,["AGCTATGC"]=1,["AGCTGGTA"]=1,["AGCTGGCA"]=1,["AGGATCTT"]=2,["AGGATTGT"]=1,["AGGATCGT"]=2,["AGGATTCT"]=1,["AGGATGCT"]=1,["AGGATCCT"]=1673,["AGGAGCCT"]=4,["AGGACCCT"]=2,["AGGATCTG"]=1,["AGGCGCTT"]=26,["AGGCGCGT"]=27,["AGGCGTCT"]=7,["AGGCTGCT"]=1,["AGGCGGCT"]=59,["AGGCTCCT"]=1,["AGGCGCCT"]=3804,["AGGCGACT"]=11,["AGGCGCAT"]=8,["AGGCGCTG"]=3,["AGGCGCCG"]=27,["AGGCGACG"]=1,["AGGCGCCC"]=5,["AGGCGCCA"]=1,["AGGGCCTT"]=37,["AGGGCCGT"]=29,["AGGGCTCT"]=9,["AGGGCGCT"]=10,["AGGGTCCT"]=127,["AGGGCCCT"]=3085,["AGGGCACT"]=6,["AGGGCCAT"]=16,["AGGGCCTG"]=2,["AGGGCGCG"]=1,["AGGGTCCG"]=1,["AGGGCCCG"]=30,["AGGGCCCC"]=8,["AGGGCCAC"]=1,["AGGGCCTA"]=1,["AGGGCCCA"]=3,["AGGTGCGT"]=1,["AGGTATCT"]=3,["AGGTGGCT"]=1,["AGGTTCCT"]=9,["AGGTGCCT"]=132,["AGGTCACT"]=1,["AGTATATT"]=1,["AGTATAGT"]=2,["AGTATTCT"]=2,["AGTAATCT"]=2,["AGTATGCT"]=3,["AGTATACT"]=1055,["AGTAGACT"]=2,["AGTCGGTT"]=2,["AGTCGCTT"]=2,["AGTCGATT"]=7,["AGTCGAGT"]=6,["AGTCGTCT"]=2,["AGTCGGCT"]=79,["AGTCGCCT"]=1,["AGTCTACT"]=4,["AGTCGACT"]=3549,["AGTCGAAT"]=3,["AGTCGACG"]=8,["AGTCGACC"]=1,["AGTCGATA"]=1,["AGTCGACA"]=1,["AGTGCATT"]=15,["AGTGCAGT"]=9,["AGTGTTCT"]=1,["AGTGCTCT"]=11,["AGTGCGCT"]=14,["AGTGGCCT"]=1,["AGTGCCCT"]=1,["AGTGTACT"]=27,["AGTGGACT"]=3,["AGTGCACT"]=2541,["AGTGCAAT"]=1,["AGTGCACG"]=14,["AGTGCACC"]=5,["AGTGCACA"]=3,["AGTTATCT"]=1,["AGTTTGCT"]=1,["AGTTTACT"]=37,["AGTTGACT"]=20,["AGTTCACT"]=4,["AGTTATAC"]=1,["AGTTGGGA"]=1,["ATAATTAT"]=78,["ATAAATAT"]=2,["ATAATAAT"]=1,["ATACGTTT"]=6,["ATACGTGT"]=8,["ATACGTAT"]=1711,["ATACGGAT"]=24,["ATACGCAT"]=1,["ATACGAAT"]=7,["ATACGTGG"]=1,["ATACGTAG"]=1,["ATACGTTC"]=1,["ATACGTAC"]=3,["ATACGTTA"]=1,["ATACGGAA"]=1,["ATAGCTTT"]=14,["ATAGCTGT"]=13,["ATAGTTAT"]=2,["ATAGCTAT"]=1089,["ATAGATAT"]=2,["ATAGCGAT"]=3,["ATAGTCAT"]=1,["ATAGCTAG"]=1,["ATAGCCGC"]=1,["ATAGCTAC"]=1,["ATAGCTTA"]=5,["ATAGCTGA"]=1,["ATATTTTT"]=1,["ATATATTT"]=1,["ATATGTAT"]=3,["ATATATAT"]=504,["ATATGGAT"]=1,["ATATGCAT"]=1,
["ATATCAAT"]=1,["ATCATTAT"]=1,["ATCATGAT"]=1427,["ATCAGGAT"]=18,["ATCACGAT"]=3,["ATCATGGG"]=1,["ATCATGAG"]=1,["ATCATGAC"]=2,["ATCATGCA"]=1,["ATCATGAA"]=1,["ATCCGGTT"]=8,["ATCCGATT"]=1,["ATCCGGGT"]=32,["ATCCGGCT"]=1,["ATCCGTAT"]=2,["ATCCTGAT"]=2,["ATCCGGAT"]=3962,["ATCCGCAT"]=1,["ATCCGGTG"]=1,["ATCCGGGG"]=1,["ATCCGGAG"]=1,["ATCCGGAC"]=3,["ATCGCGTT"]=3,["ATCGCGGT"]=13,["ATCGCGCT"]=1,["ATCGTGAT"]=101,["ATCGGGAT"]=1,["ATCGCGAT"]=3545,["ATCGCGGG"]=1,["ATCGCGCG"]=1,["ATCGCGAG"]=4,["ATCGCGAC"]=2,["ATCGCGTA"]=1,["ATCGCGAA"]=2,["ATCTTGTT"]=1,["ATCTGGGT"]=1,["ATCTTTAT"]=1,["ATCTGTAT"]=1,["ATCTTGAT"]=81,["ATCTGGAT"]=30,["ATCTCGAT"]=1,["ATGATCTT"]=1,["ATGATCGT"]=2,["ATGATTAT"]=1,["ATGATGAT"]=1,["ATGATCAT"]=913,["ATGAGCAT"]=5,["ATGACCAT"]=2,["ATGATAAT"]=1,["ATGAGAAT"]=1,["ATGCGCTT"]=5,["ATGCTATT"]=1,["ATGCGCGT"]=51,["ATGCGTCT"]=1,["ATGCGACT"]=1,["ATGCGTAT"]=7,["ATGCGGAT"]=70,["ATGCGCAT"]=3326,["ATGCCCAT"]=1,["ATGCGAAT"]=4,["ATGCGCTG"]=5,["ATGCGCCG"]=1,["ATGCGCAG"]=2,["ATGCGAGC"]=1,["ATGCGCAC"]=1,["ATGCGCTA"]=2,["ATGCGCAA"]=2,["ATGGCCTT"]=13,["ATGGCCGT"]=18,["ATGGCCCT"]=1,["ATGGCTAT"]=3,["ATGGTCAT"]=39,["ATGGGCAT"]=2,["ATGGCCAT"]=2827,["ATGGCCTG"]=2,["ATGGCATG"]=1,["ATGGCCAG"]=6,["ATGGCCTC"]=2,["ATGGCCGC"]=2,["ATGGCTAC"]=1,["ATGGCCTA"]=10,["ATGGCCAA"]=2,["ATGTTGCT"]=1,["ATGTGGCT"]=1,["ATGTTCAT"]=6,["ATGTGCAT"]=16,["ATTATATT"]=2,["ATTATTAT"]=2,["ATTATGAT"]=3,["ATTATAAT"]=453,["ATTAGAAT"]=2,["ATTACAAT"]=1,["ATTATAAC"]=1,["ATTATAAA"]=1,["ATTCGATT"]=3,["ATTCGAGT"]=4,["ATTCGGCT"]=1,["ATTCGACT"]=1,["ATTCGTAT"]=4,["ATTCGGAT"]=65,["ATTCGCAT"]=1,["ATTCTAAT"]=1,["ATTCGAAT"]=2452,["ATTCGTCG"]=1,["ATTCGAAG"]=2,["ATTCATTC"]=2,["ATTCGAAC"]=3,["ATTCGAAA"]=2,["ATTGCTTT"]=1,["ATTGCATT"]=13,["ATTGCGGT"]=1,["ATTGCAGT"]=2,["ATTGCACT"]=1,["ATTGCTAT"]=3,["ATTGTGAT"]=1,["ATTGCGAT"]=25,["ATTGTCAT"]=1,["ATTGCCAT"]=1,["ATTGTAAT"]=29,["ATTGGAAT"]=2,["ATTGCAAT"]=2308,["ATTGCTAG"]=1,["ATTGCAAG"]=2,["ATTGCTTC"]=1,["ATTGCACC"]=1,["ATTGCAAC"]=1,["ATTGCATA"]=1,["ATTTATTT"]=2,["ATTTTGAT"]=2,["ATTTTAAT"]=21,["ATTTGAAT"]=18,["ATTTCAAT"]=1,["CAAACTTT"]=1,["CAAATTTG"]=726,["CAAAGTTG"]=2,["CAAATGTG"]=2,["CAAATTCG"]=1,["CAAATTTC"]=1,["CAACGTTT"]=6,["CAACTTTG"]=1,["CAACGTTG"]=3635,["CAACGGTG"]=27,["CAACGCTG"]=4,["CAACGATG"]=8,["CAACGTGG"]=1,["CAACGGGG"]=1,["CAACGCGG"]=1,["CAACGAGG"]=1,["CAACGTCG"]=10,["CAACGGCG"]=1,["CAACGTAG"]=2,["CAACGTTA"]=3,["CAAGCTTT"]=3,["CAAGTTTG"]=19,["CAAGGTTG"]=4,["CAAGCTTG"]=1848,["CAAGTCTG"]=1,["CAAGCCTG"]=1,["CAAGCATG"]=3,["CAAGTTGG"]=1,["CAAGCTGG"]=2,["CAAGCTCG"]=2,["CAAGCTAG"]=1,["CAAGCGAG"]=1,["CAAGCAAG"]=2,["CAAGCTTC"]=3,["CAAGCTTA"]=3,["CAATTTTG"]=10,["CAATGTTG"]=63,["CAATCTTG"]=1,["CAATTTCG"]=1,["CAATGTTA"]=1,["CACATGTT"]=1,["CACATGTG"]=2758,["CACAGGTG"]=41,["CACACGTG"]=3,["CACATGGG"]=5,["CACATGCG"]=2,["CACATCCG"]=1,["CACACACA"]=2,["CACCGGTT"]=4,["CACCGTTG"]=2,["CACCTGTG"]=4,["CACCGGTG"]=4397,["CACCCGTG"]=1,["CACCGCTG"]=1,["CACCGATG"]=7,["CACCGTGG"]=1,["CACCGGGG"]=48,["CACCGAGG"]=2,["CACCGGCG"]=30,["CACCTGAG"]=1,["CACCGGAG"]=3,["CACCGGTC"]=3,["CACCCACC"]=2,
["CACCGGTA"]=3,["CACCGGCA"]=1,["CACGCGTT"]=4,["CACGCTTG"]=3,["CACGTGTG"]=280,["CACGGGTG"]=10,["CACGCGTG"]=3808,["CACGGATG"]=1,["CACGCATG"]=2,["CACGGTGG"]=3,["CACGCTGG"]=1,["CACGTGGG"]=1,["CACGCGGG"]=18,["CACGCCGG"]=1,["CACGCGCG"]=16,["CACGCACG"]=4,["CACGCTAG"]=1,["CACGCGAG"]=3,["CACGCCAG"]=1,["CACGCGTC"]=3,["CACGCGTA"]=6,["CACTGTTG"]=2,["CACTTGTG"]=170,["CACTGGTG"]=181,["CACTCGTG"]=4,["CACTGGCG"]=1,["CACTGTAG"]=1,["CACTTGAG"]=1,["CAGATCTT"]=1,["CAGATTTG"]=4,["CAGATGTG"]=1,["CAGATCTG"]=1428,["CAGAGCTG"]=11,["CAGACCTG"]=2,["CAGATCGG"]=2,["CAGAGACG"]=1,["CAGATCTA"]=1,["CAGCGCTT"]=6,["CAGCGTTG"]=12,["CAGCGGTG"]=47,["CAGCTCTG"]=1,["CAGCGCTG"]=3973,["CAGCGATG"]=8,["CAGCGCGG"]=5,["CAGCGCCG"]=3,["CAGCGCAG"]=1,["CAGCGCTA"]=5,["CAGCGCCA"]=1,["CAGGCCTT"]=6,["CAGGCTTG"]=1,["CAGGCGTG"]=5,["CAGGTCTG"]=112,["CAGGGCTG"]=1,["CAGGCCTG"]=3301,["CAGGGATG"]=1,["CAGGCATG"]=1,["CAGGCTGG"]=1,["CAGGCCGG"]=4,["CAGGCCCG"]=1,["CAGGTACG"]=1,["CAGGCCAG"]=5,["CAGGCCTC"]=1,["CAGGCCTA"]=3,["CAGTGTTG"]=1,["CAGTGGTG"]=1,["CAGTTCTG"]=7,["CAGTGCTG"]=45,["CAGTTTCG"]=1,["CAGTTCCG"]=1,["CATACTAT"]=1,["CATATTTG"]=1,["CATAGTTG"]=1,["CATATGTG"]=17,["CATAGGTG"]=1,["CATATCTG"]=1,["CATATATG"]=1050,["CATAGATG"]=24,["CATACATG"]=3,["CATAGAGG"]=1,["CATATACG"]=1,["CATCGATT"]=2,["CATCGTTG"]=26,["CATCCTTG"]=1,["CATCGGTG"]=281,["CATCGCTG"]=4,["CATCTATG"]=6,["CATCGATG"]=3711,["CATCCATG"]=5,["CATCGAGG"]=1,["CATCGTCG"]=1,["CATCGGCG"]=1,["CATCGACG"]=11,["CATCGCAG"]=1,["CATCGAAG"]=1,["CATGCATT"]=6,["CATGCTTG"]=26,["CATGTGTG"]=2,["CATGCGTG"]=78,["CATGTCTG"]=1,["CATGCCTG"]=1,["CATGTATG"]=111,["CATGGATG"]=11,["CATGCATG"]=3188,["CATGCTGG"]=1,["CATGCCGG"]=1,["CATGCTAG"]=1,["CATGCCAG"]=1,["CATTTTTG"]=4,["CATTGGTG"]=5,["CATTTCTG"]=1,["CATTGCTG"]=2,["CATTTATG"]=84,["CATTGATG"]=88,["CATTTACG"]=1,["CCAATTTG"]=1,["CCAATTGG"]=1263,["CCAAGTGG"]=5,["CCACGTGT"]=3,["CCACGGCT"]=1,["CCACGTTG"]=2,["CCACTTGG"]=2,["CCACGTGG"]=3530,["CCACGGGG"]=125,["CCACGCGG"]=10,["CCACGAGG"]=9,["CCACGTGA"]=7,["CCAGCTGT"]=1,["CCAGTTGG"]=31,["CCAGGTGG"]=2,["CCAGCTGG"]=3120,["CCAGTGGG"]=1,["CCAGCGGG"]=5,["CCAGCTCG"]=1,["CCAGCTAG"]=1,["CCAGCTGC"]=1,["CCAGCTGA"]=4,["CCATTTGG"]=8,["CCATGTGG"]=87,["CCATTGGG"]=1,["CCCATGGT"]=1,["CCCATGTG"]=1,["CCCATTGG"]=1,["CCCATGGG"]=3286,["CCCAGGGG"]=36,["CCCACGGG"]=8,["CCCAGCGG"]=1,["CCCATGAG"]=1,["CCCATGGC"]=1,["CCCATGGA"]=4,["CCCACCCA"]=2,["CCCCGGGT"]=2,["CCCCGGTG"]=12,["CCCCGTGG"]=2,["CCCCTGGG"]=11,["CCCCGGGG"]=2930,["CCCCCGGG"]=2,["CCCCGCGG"]=1,["CCCCGAGG"]=2,["CCCCGGCG"]=1,["CCCCGGAG"]=2,["CCCCGGGA"]=4,["CCCGCGGT"]=2,["CCCGCGTG"]=2,["CCCGCTGG"]=1,["CCCGTGGG"]=282,["CCCGGGGG"]=11,["CCCGCGGG"]=3700,["CCCGTCGG"]=1,["CCCGCCGG"]=5,["CCCGTAGG"]=1,["CCCGCGCG"]=1,["CCCGCCCG"]=2,["CCCGTGAG"]=1,["CCCGCGAG"]=1,["CCCGCGGC"]=1,["CCCGCGGA"]=4,["CCCTTGGG"]=252,["CCCTGGGG"]=211,["CCCTCGGG"]=8,["CCCTTCGG"]=2,["CCCTTAGG"]=1,["CCCTGGCG"]=1,["CCGATCGT"]=1,["CCGATCTG"]=2,["CCGATTGG"]=25,["CCGATGGG"]=1,["CCGATCGG"]=3077,["CCGAGCGG"]=52,["CCGACCGG"]=3,["CCGATAGG"]=3,["CCGAGAGG"]=3,["CCGACCGA"]=2,["CCGCGCGT"]=2,["CCGCGCTG"]=8,
["CCGCGTGG"]=106,["CCGCCTGG"]=1,["CCGCGGGG"]=56,["CCGCTCGG"]=2,["CCGCGCGG"]=3767,["CCGCGAGG"]=6,["CCGCGCCG"]=1,["CCGCGACG"]=1,["CCGCGCAG"]=1,["CCGCCCGC"]=2,["CCGCGCGA"]=2,["CCGGCCTG"]=10,["CCGGTTGG"]=2,["CCGGCTGG"]=51,["CCGGCGGG"]=11,["CCGGTCGG"]=229,["CCGGGCGG"]=10,["CCGGCCGG"]=4272,["CCGGTAGG"]=1,["CCGTCCGT"]=2,["CCGTGTGG"]=1,["CCGTCTGG"]=1,["CCGTTGGG"]=1,["CCGTTCGG"]=44,["CCGTGCGG"]=175,["CCGTGAGG"]=1,["CCTATGTG"]=1,["CCTATTGG"]=7,["CCTATGGG"]=18,["CCTATAGG"]=1692,["CCTAGAGG"]=13,["CCTATACG"]=1,["CCTCGAGT"]=1,["CCTCGATG"]=4,["CCTCTTGG"]=1,["CCTCGTGG"]=57,["CCTCGGGG"]=259,["CCTCGCGG"]=22,["CCTCTAGG"]=19,["CCTCGAGG"]=3362,["CCTCGTCG"]=1,["CCTCGACG"]=2,["CCTCCCTC"]=2,["CCTCGAGA"]=1,["CCTGCGTG"]=1,["CCTGTATG"]=1,["CCTGTTGG"]=1,["CCTGCTGG"]=47,["CCTGTGGG"]=4,["CCTGGGGG"]=1,["CCTGCGGG"]=177,["CCTGTAGG"]=114,["CCTGGAGG"]=5,["CCTGCTAG"]=1,["CCTTTTTG"]=1,["CCTTTTGG"]=3,["CCTTGTGG"]=1,["CCTTTGGG"]=1,["CCTTGGGG"]=3,["CCTTTCGG"]=1,["CCTTGCGG"]=1,["CCTTTAGG"]=108,["CCTTGAGG"]=128,["CGAATTCT"]=1,["CGAATTTG"]=3,["CGAATTCG"]=1731,["CGAAGTCG"]=5,["CGAATGCG"]=2,["CGAATCCG"]=1,["CGACGTCT"]=10,["CGACGGCT"]=1,["CGACGACT"]=1,["CGACGTTG"]=137,["CGACGGTG"]=1,["CGACGTGG"]=4,["CGACGGGG"]=1,["CGACTTCG"]=2,["CGACGTCG"]=3823,["CGACGGCG"]=142,["CGACGCCG"]=5,["CGACGACG"]=11,["CGACGTAG"]=5,["CGACGGAG"]=2,["CGACGTTC"]=1,["CGACGTCC"]=1,["CGACGTGA"]=1,["CGACGTCA"]=11,["CGACGGAA"]=1,["CGAGCTTT"]=1,["CGAGCTCT"]=4,["CGAGCTTG"]=86,["CGAGCGTG"]=1,["CGAGCTGG"]=7,["CGAGTTCG"]=46,["CGAGGTCG"]=7,["CGAGCTCG"]=2856,["CGAGCGCG"]=9,["CGAGGACG"]=1,["CGAGCTAG"]=2,["CGAGTGAG"]=1,["CGAGCGAG"]=6,["CGAGTTCC"]=1,["CGAGCTCC"]=3,["CGAGCTCA"]=9,["CGATTTGG"]=1,["CGATTTCG"]=18,["CGATGTCG"]=153,["CGATCTCG"]=2,["CGATTGCG"]=1,["CGATGGCG"]=1,["CGATTCCG"]=1,["CGATTGAG"]=2,["CGATGAAG"]=1,["CGCATGCT"]=1,["CGCATGTG"]=5,["CGCATGGG"]=7,["CGCATGCG"]=3227,["CGCAGGCG"]=77,["CGCACGCG"]=29,["CGCATACG"]=2,["CGCATGAG"]=2,["CGCAGGAG"]=1,["CGCCGGCT"]=20,["CGCCGTTG"]=1,["CGCCGGTG"]=110,["CGCCGGGG"]=83,["CGCCGTCG"]=16,["CGCCTGCG"]=32,["CGCCGGCG"]=4056,["CGCCCGCG"]=7,["CGCCGACG"]=40,["CGCCGTAG"]=2,["CGCCGGAG"]=16,["CGCCGAAG"]=1,["CGCCGGTC"]=1,["CGCCGGCC"]=4,["CGCCCGCC"]=2,["CGCCGGAC"]=1,["CGCCGGTA"]=2,["CGCCGTCA"]=1,["CGCCGGCA"]=15,["CGCGGCGT"]=1,["CGCGCGCT"]=12,["CGCGCGTG"]=85,["CGCGTGGG"]=1,["CGCGCGGG"]=32,["CGCGGCGG"]=2,["CGCGTTCG"]=1,["CGCGGTCG"]=1,["CGCGCTCG"]=8,["CGCGTGCG"]=750,["CGCGGGCG"]=25,["CGCGCGCG"]=3538,["CGCGTGAG"]=1,["CGCGGGAG"]=1,["CGCGCGTC"]=1,["CGCGCGGC"]=1,["CGCTGGTG"]=2,["CGCTTGGG"]=2,["CGCTGCGG"]=1,["CGCTTGCG"]=395,["CGCTGGCG"]=311,["CGCTGGAG"]=1,["CGGATCTG"]=5,["CGGATCGG"]=1,["CGGATTCG"]=11,["CGGATGCG"]=3,["CGGATCCG"]=3246,["CGGAGCCG"]=53,["CGGATACG"]=3,["CGGAGACG"]=1,["CGGATCAG"]=1,["CGGACGGA"]=2,["CGGCGCCT"]=9,["CGGCGTTG"]=1,["CGGCGCTG"]=162,["CGGCGCGG"]=13,["CGGCTTCG"]=1,["CGGCGTCG"]=109,["CGGCGGCG"]=198,["CGGCTCCG"]=5,["CGGCGCCG"]=4118,["CGGCGACG"]=49,["CGGCGCAG"]=4,["CGGCGCCC"]=5,["CGGCGCTA"]=1,["CGGCGCCA"]=2,["CGGGCTGG"]=1,["CGGGTTCG"]=3,["CGGGCTCG"]=23,["CGGGTCCG"]=282,["CGGGGCCG"]=10,
["CGGGTCAG"]=1,["CGGTCGGT"]=2,["CGGTTCCT"]=1,["CGGTGGCG"]=1,["CGGTTCCG"]=29,["CGGTGCCG"]=208,["CGGTTACG"]=1,["CGGTGACG"]=1,["CGTATACT"]=1,["CGTATATG"]=4,["CGTATTGG"]=1,["CGTAGTGG"]=1,["CGTATAGG"]=3,["CGTATTCG"]=1,["CGTATGCG"]=23,["CGTAGGCG"]=2,["CGTATCCG"]=1,["CGTAGCCG"]=1,["CGTATACG"]=2290,["CGTAGACG"]=46,["CGTATACC"]=1,["CGTCGGCT"]=1,["CGTCGACT"]=3,["CGTCGATG"]=46,["CGTCGGGG"]=1,["CGTCGCGG"]=1,["CGTCGAGG"]=26,["CGTCTTCG"]=1,["CGTCGTCG"]=10,["CGTCGGCG"]=279,["CGTCGCCG"]=5,["CGTCTACG"]=18,["CGTCGACG"]=4151,["CGTCGTAG"]=2,["CGTCGAAG"]=1,["CGTCGATC"]=1,["CGTCGCGC"]=1,["CGTCGACC"]=1,["CGTCGACA"]=4,["CGTGCTTG"]=2,["CGTGCGTG"]=6,["CGTGCTCG"]=23,["CGTGTGCG"]=2,["CGTGGCCG"]=1,["CGTGTACG"]=188,["CGTGGACG"]=12,["CGTTTAGG"]=1,["CGTTTGCG"]=1,["CGTTGGCG"]=2,["CGTTTACG"]=162,["CGTTGACG"]=125,["CGTTTTAG"]=1,["CTAATTGG"]=1,["CTAATGCG"]=2,["CTAATTAG"]=334,["CTAAGTAG"]=1,["CTAATGAG"]=1,["CTAAGCAG"]=1,["CTACGTAT"]=1,["CTACGTTG"]=17,["CTACGATG"]=1,["CTACGTGG"]=18,["CTACGTCG"]=1,["CTACGTAG"]=2339,["CTACTGAG"]=1,["CTACGGAG"]=71,["CTACGCAG"]=2,["CTACGAAG"]=9,["CTACGTAA"]=1,["CTAGCTGT"]=1,["CTAGCTAT"]=1,["CTAGCTTG"]=21,["CTAGCTGG"]=24,["CTAGTAGG"]=2,["CTAGCTCG"]=1,["CTAGTTAG"]=10,["CTAGGTAG"]=2,["CTAGCTAG"]=866,["CTAGTGAG"]=1,["CTAGTCAG"]=1,["CTATCTAT"]=2,["CTATGGCG"]=1,["CTATTTAG"]=3,["CTATGTAG"]=9,["CTATTCAG"]=1,["CTATTAAG"]=2,["CTCATGTG"]=10,["CTCATGGG"]=9,["CTCATGCG"]=7,["CTCATTAG"]=1,["CTCATGAG"]=1964,["CTCAGGAG"]=38,["CTCAGCAG"]=1,["CTCATAAG"]=1,["CTCATGAC"]=1,["CTCATTGA"]=1,["CTCCTGAT"]=1,["CTCCGGAT"]=1,["CTCCGGTG"]=138,["CTCCGGGG"]=54,["CTCCGCGG"]=2,["CTCCGGCG"]=36,["CTCCTGAG"]=7,["CTCCGGAG"]=3421,["CTCCGCAG"]=1,["CTCCGAAG"]=6,["CTCCGGGA"]=1,["CTCCGGAA"]=1,["CTCGTGGG"]=1,["CTCGTGAG"]=181,["CTCGGGAG"]=7,["CTCTCTCT"]=2,["CTCTTGTG"]=1,["CTCTGGTG"]=1,["CTCTTGGG"]=1,["CTCTTGAG"]=150,["CTCTGGAG"]=180,["CTCTTCAG"]=2,["CTGATCTG"]=5,["CTGATATG"]=1,["CTGAGATG"]=3,["CTGATCGG"]=6,["CTGAGCGG"]=1,["CTGATTAG"]=4,["CTGATGAG"]=1,["CTGATCAG"]=1620,["CTGAGCAG"]=47,["CTGATAAG"]=1,["CTGAGAAG"]=5,["CTGACTGA"]=2,["CTGCGCTT"]=1,["CTGCGGAT"]=1,["CTGCGCAT"]=4,["CTGCGCTG"]=98,["CTGCTCGG"]=1,["CTGCGCGG"]=75,["CTGCGCCG"]=20,["CTGCGACG"]=1,["CTGCGTAG"]=85,["CTGCGGAG"]=97,["CTGCTCAG"]=1,["CTGCGCAG"]=3534,["CTGCGAAG"]=7,["CTGGCTTG"]=1,["CTGGTCTG"]=1,["CTGGTCAG"]=140,["CTGGGCAG"]=3,["CTGTGCTG"]=1,["CTGTGCGG"]=1,["CTGTTTAG"]=1,["CTGTGTAG"]=1,["CTGTTCAG"]=20,["CTGTGCAG"]=120,["CTGTTAAG"]=1,["CTTATTTG"]=1,["CTTAGCTG"]=1,["CTTAGATG"]=1,["CTTAGAGG"]=1,["CTTAGCCG"]=1,["CTTATACG"]=2,["CTTATTAG"]=4,["CTTAGTAG"]=1,["CTTATGAG"]=19,["CTTATAAG"]=814,["CTTAGAAG"]=6,["CTTATAAA"]=1,["CTTCGAAT"]=1,["CTTCGGTG"]=1,["CTTCGATG"]=22,["CTTCGCGG"]=1,["CTTCGAGG"]=9,["CTTCGGCG"]=1,["CTTCGACG"]=10,["CTTCGTAG"]=34,["CTTCGGAG"]=224,["CTTCGCAG"]=5,["CTTCTAAG"]=5,["CTTCGAAG"]=2877,["CTTCGAAA"]=1,["CTTGCTTG"]=4,["CTTGTTAG"]=1,["CTTGGGAG"]=1,["CTTGTAAG"]=51,["CTTGGAAG"]=2,["CTTTGCCG"]=1,["CTTTGACG"]=1,["CTTTTTAG"]=1,["CTTTGGAG"]=6,["CTTTTCAG"]=1,["CTTTTAAG"]=57,["CTTTGAAG"]=94,["GAAATTTT"]=4,["GAAATCTG"]=1,["GAAATTTC"]=841,
["GAAAGTTC"]=1,["GAAATAGC"]=1,["GAAATTCC"]=1,["GAAATTAC"]=2,["GAAAGAAA"]=4,["GAACGTTT"]=66,["GAACGGTT"]=1,["GAACGTGT"]=1,["GAACGTCT"]=1,["GAACGGCT"]=1,["GAACGTTG"]=8,["GAACTTTC"]=4,["GAACGTTC"]=3490,["GAACGGTC"]=5,["GAACGCTC"]=2,["GAACGATC"]=2,["GAACGTGC"]=10,["GAACGTCC"]=6,["GAACGTAC"]=7,["GAACGTTA"]=13,["GAACGTGA"]=1,["GAAGTTTC"]=22,["GAAGGTTC"]=1,["GAAGTGTC"]=1,["GAAGTCTC"]=1,["GAAGTGCC"]=1,["GAATGTTG"]=1,["GAATTTTC"]=10,["GAATGTTC"]=233,["GAATGTAC"]=1,["GAATTTTA"]=1,["GACATGTT"]=10,["GACAGGTT"]=1,["GACATGTG"]=3,["GACATGTC"]=2894,["GACAGGTC"]=17,["GACATATC"]=1,["GACATGGC"]=9,["GACATGCC"]=4,["GACATGTA"]=3,["GACATGGA"]=1,["GACATGCA"]=1,["GACCGGTT"]=113,["GACCGGGT"]=3,["GACCGGCT"]=1,["GACCGGTG"]=8,["GACCGTTC"]=10,["GACCTGTC"]=3,["GACCGGTC"]=4051,["GACCGATC"]=9,["GACCGGGC"]=37,["GACCGGCC"]=25,["GACCGACC"]=2,["GACCGGAC"]=2,["GACCGGTA"]=18,["GACCGGCA"]=1,["GACCGGAA"]=1,["GACGGTCG"]=1,["GACGTGTC"]=331,["GACGGGTC"]=6,["GACGTCTC"]=1,["GACGTATC"]=1,["GACGTGGC"]=1,["GACGGTCC"]=1,["GACGTGTA"]=1,["GACTGACT"]=2,["GACTGTTC"]=2,["GACTTGTC"]=119,["GACTGGTC"]=217,["GACTGATC"]=2,["GACTGGCC"]=1,["GACTGCCC"]=1,["GAGATCTT"]=3,["GAGAGCTT"]=1,["GAGATTTC"]=3,["GAGATGTC"]=3,["GAGATCTC"]=1542,["GAGAGCTC"]=3,["GAGATATC"]=1,["GAGAGATC"]=2,["GAGATCAC"]=1,["GAGCGGTT"]=2,["GAGCGCTT"]=75,["GAGCGATT"]=1,["GAGCGCGT"]=2,["GAGCGCAT"]=1,["GAGCGCTG"]=2,["GAGCGTTC"]=15,["GAGCGGTC"]=22,["GAGCTCTC"]=2,["GAGCGCTC"]=3836,["GAGCGATC"]=5,["GAGCGCGC"]=11,["GAGCGCCC"]=6,["GAGCGCAC"]=5,["GAGCGTTA"]=1,["GAGCGCTA"]=22,["GAGCGCGA"]=1,["GAGGTCTC"]=227,["GAGGGCTC"]=2,["GAGTTCTC"]=16,["GAGTGCTC"]=197,["GAGTTATC"]=1,["GATATATT"]=2,["GATATTTC"]=1,["GATATGTC"]=5,["GATATATC"]=1417,["GATAGATC"]=6,["GATATGGC"]=1,["GATATATA"]=1,["GATAGATA"]=2,["GATATTGA"]=1,["GATCGATT"]=72,["GATCGTTG"]=2,["GATCGATG"]=2,["GATCGTTC"]=7,["GATCTGTC"]=1,["GATCGGTC"]=101,["GATCGCTC"]=3,["GATCTATC"]=5,["GATCGATC"]=3882,["GATCGCGC"]=1,["GATCGGCC"]=2,["GATGGATT"]=1,["GATGTGTC"]=1,["GATGTCTC"]=1,["GATGTATC"]=68,["GATGTATA"]=1,["GATTTATT"]=2,["GATTTTTC"]=1,["GATTGGTC"]=1,["GATTTATC"]=41,["GATTTAGC"]=1,["GCAATTGT"]=3,["GCAATTGG"]=1,["GCAATTGC"]=1396,["GCAAGTGC"]=1,["GCAATGGC"]=1,["GCAATTAC"]=2,["GCAATTGA"]=3,["GCACGTGT"]=92,["GCACGTGG"]=13,["GCACGTTC"]=3,["GCACTTGC"]=4,["GCACGTGC"]=3593,["GCACTGGC"]=2,["GCACGGGC"]=69,["GCACGCGC"]=4,["GCACGTCC"]=2,["GCACGTAC"]=3,["GCACGTGA"]=30,["GCACGGGA"]=1,["GCAGTTGG"]=1,["GCAGGTCG"]=1,["GCAGTTGC"]=76,["GCAGGTGC"]=3,["GCAGGGGC"]=1,["GCAGTGCC"]=1,["GCATGTTC"]=1,["GCATTTGC"]=10,["GCATGTGC"]=443,["GCATGGGC"]=1,["GCATTCGC"]=2,["GCCATGGT"]=172,["GCCAGGGT"]=1,["GCCATGGG"]=3,["GCCATGTC"]=1,["GCCATGGC"]=3480,["GCCAGGGC"]=28,["GCCATAGC"]=1,["GCCATGGA"]=2,["GCCAGCCA"]=4,["GCCCTGGT"]=1,["GCCCGGGT"]=675,["GCCCGGAT"]=1,["GCCCGGGG"]=4,["GCCCGGTC"]=4,["GCCCGTGC"]=12,["GCCCTGGC"]=14,["GCCCGGGC"]=3928,["GCCCGCCC"]=4,["GCCCGGAC"]=5,["GCCCGGTA"]=2,["GCCCGGGA"]=39,["GCCGTGGT"]=5,["GCCGGGCG"]=1,["GCCGGCCG"]=2,["GCCGTGGC"]=406,["GCCGGGGC"]=6,["GCCGTGGA"]=1,["GCCGGGGA"]=1,["GCCTTGGT"]=7,["GCCTGGGT"]=5,["GCCTGTGC"]=1,
["GCCTTGGC"]=312,["GCCTGGGC"]=231,["GCCTGCGC"]=1,["GCCTTAGC"]=1,["GCGATCGT"]=33,["GCGATCAT"]=1,["GCGATCGG"]=2,["GCGATCCG"]=1,["GCGATTGC"]=11,["GCGATGGC"]=2,["GCGATCGC"]=2576,["GCGAGCGC"]=19,["GCGATAGC"]=1,["GCGATCAC"]=1,["GCGATCGA"]=2,["GCGCGCTT"]=1,["GCGCGTGT"]=2,["GCGCGGGT"]=1,["GCGCGCGT"]=405,["GCGCGCGG"]=4,["GCGCGTTC"]=1,["GCGCGGTC"]=1,["GCGCGCTC"]=20,["GCGCGTGC"]=57,["GCGCGGGC"]=56,["GCGCGCGC"]=3166,["GCGGTCGT"]=2,["GCGGTGCG"]=1,["GCGGTTGC"]=2,["GCGGTCGC"]=474,["GCGGTTCC"]=1,["GCGTGCGT"]=2,["GCGTGTGC"]=2,["GCGTTGGC"]=2,["GCGTGGGC"]=1,["GCGTTCGC"]=23,["GCTATAGT"]=7,["GCTATAGG"]=1,["GCTATTGC"]=2,["GCTATGGC"]=10,["GCTAGGGC"]=1,["GCTATAGC"]=2224,["GCTATAAC"]=1,["GCTCGGGT"]=2,["GCTCGCTC"]=2,["GCTCGTGC"]=21,["GCTCGGGC"]=221,["GCTCTAGC"]=10,["GCTGTAGT"]=2,["GCTGTAGG"]=1,["GCTGTCTC"]=1,["GCTGTTGC"]=2,["GCTGTGGC"]=4,["GCTGGGGC"]=1,["GCTGTCGC"]=1,["GCTGTAGC"]=116,["GCTGTGCC"]=1,["GCTTTATC"]=1,["GCTTTTGC"]=1,["GCTTTGGC"]=1,["GCTTGGGC"]=4,["GCTTTAGC"]=92,["GCTTTCAC"]=1,["GGAATTCT"]=6,["GGAATTTC"]=3,["GGAATTGC"]=4,["GGAATTCC"]=2012,["GGAATGCC"]=3,["GGAATCCC"]=2,["GGAATTAC"]=2,["GGAATTAA"]=1,["GGACGTTT"]=1,["GGACGTGT"]=1,["GGACGTCT"]=145,["GGACGTCG"]=25,["GGACGTTC"]=237,["GGACGTGC"]=137,["GGACTTCC"]=2,["GGACGTCC"]=3778,["GGACGGCC"]=77,["GGACTCCC"]=1,["GGACGTAC"]=54,["GGACGTCA"]=47,["GGAGTTCT"]=3,["GGAGTGAT"]=1,["GGAGTTGC"]=2,["GGAGTTCC"]=92,["GGAGGTCC"]=2,["GGAGTCCC"]=1,["GGAGTGAC"]=1,["GGAGTAAC"]=2,["GGATGTTC"]=2,["GGATTTGC"]=1,["GGATGTGC"]=4,["GGATTTCC"]=20,["GGATGTCC"]=536,["GGATTGCC"]=1,["GGATTGAC"]=1,["GGATGTCA"]=1,["GGCATGCT"]=151,["GGCATGCG"]=3,["GGCATGTC"]=31,["GGCAGGTC"]=1,["GGCATGGC"]=46,["GGCATGCC"]=3692,["GGCAGGCC"]=62,["GGCATACC"]=2,["GGCATGAC"]=16,["GGCATGCA"]=9,["GGCCGGTT"]=4,["GGCCGGGT"]=1,["GGCCGGCT"]=708,["GGCCGGCG"]=17,["GGCCGGTC"]=209,["GGCCGTGC"]=2,["GGCCTGGC"]=1,["GGCCGGGC"]=151,["GGCCGTCC"]=23,["GGCCTGCC"]=28,["GGCCGGCC"]=4270,["GGCCGTAC"]=2,["GGCCGGTA"]=1,["GGCCGGGA"]=1,["GGCGTGCT"]=5,["GGCGGGCT"]=1,["GGCGGGCG"]=2,["GGCGTGGC"]=1,["GGCGGTCC"]=2,["GGCGTGCC"]=808,["GGCGTGAC"]=1,["GGCTTGCT"]=9,["GGCTGGTC"]=1,["GGCTGTGC"]=1,["GGCTTGGC"]=2,["GGCTGGGC"]=2,["GGCTTTCC"]=1,["GGCTGTCC"]=1,["GGCTTGCC"]=360,["GGCTTGAC"]=1,["GGGATCGT"]=2,["GGGATCCT"]=17,["GGGATCCG"]=5,["GGGATCTC"]=7,["GGGATCGC"]=4,["GGGATTCC"]=7,["GGGATGCC"]=5,["GGGATCCC"]=3144,["GGGATACC"]=2,["GGGATCAC"]=2,["GGGATCCA"]=1,["GGGCGTCC"]=55,["GGGCTCCC"]=5,["GGGGTCGC"]=1,["GGGGTTCC"]=1,["GGGGTGCC"]=1,["GGGGTCCC"]=572,["GGGGTACC"]=1,["GGGGTCAC"]=2,["GGGTTCCT"]=2,["GGGTTCTC"]=1,["GGGTTTCC"]=1,["GGGTGTCC"]=1,["GGGTTCCC"]=38,["GGGTTACC"]=1,["GGTATACT"]=16,["GGTATACG"]=1,["GGTATATC"]=3,["GGTATAGC"]=5,["GGTATTCC"]=3,["GGTATGCC"]=18,["GGTATACC"]=3067,["GGTATAAC"]=3,["GGTCGTCT"]=1,["GGTCGTCG"]=1,["GGTCGTCC"]=8,["GGTCTACC"]=16,["GGTGTACT"]=4,["GGTGTTAT"]=1,["GGTGTACG"]=1,["GGTGTTCC"]=3,["GGTGGTCC"]=1,["GGTGTGCC"]=6,["GGTGTACC"]=149,["GGTTTACT"]=3,["GGTTTAGC"]=2,["GGTTGTCC"]=1,["GGTTTGCC"]=2,["GGTTTACC"]=152,["GTAATCTT"]=1,["GTAATTAT"]=2,["GTAATTTC"]=2,["GTAATTGC"]=2,["GTAATTAC"]=424,
["GTAAGTAC"]=2,["GTAATAAC"]=1,["GTACGTTT"]=1,["GTACGTCT"]=1,["GTACGTAT"]=15,["GTACGTAG"]=1,["GTACGTTC"]=7,["GTACGTGC"]=68,["GTACGTCC"]=2,["GTACTTAC"]=2,["GTACGTAC"]=2674,["GTACTGAC"]=1,["GTACTCAC"]=1,["GTAGTTTC"]=1,["GTAGTTAC"]=6,["GTATTTAC"]=2,["GTCATGGT"]=1,["GTCATGCT"]=2,["GTCATGAT"]=77,["GTCATGAG"]=1,["GTCATGGC"]=5,["GTCATGCC"]=1,["GTCATGAC"]=2694,["GTCATAAC"]=4,["GTCCGTCC"]=2,["GTCCTGAC"]=9,["GTCGTGAT"]=1,["GTCGTGGC"]=2,["GTCGTGCC"]=2,["GTCGTGAC"]=327,["GTCTTGAT"]=6,["GTCTTGTC"]=2,["GTCTTGGC"]=2,["GTCTTGCC"]=1,["GTCTTGAC"]=294,["GTGATCAT"]=26,["GTGATTTC"]=1,["GTGATCGC"]=3,["GTGATTAC"]=6,["GTGATGAC"]=1,["GTGATCAC"]=2390,["GTGATAAC"]=2,["GTGAGTGA"]=4,["GTGATCGA"]=1,["GTGCGTGT"]=1,["GTGCGTTC"]=1,["GTGCTCAC"]=2,["GTGGTCTC"]=2,["GTGGTCGC"]=3,["GTGGTTAC"]=2,["GTGGTCAC"]=162,["GTGTTACC"]=1,["GTGTTCAC"]=26,["GTGTTAAC"]=1,["GTGTTAAA"]=1,["GTTATACT"]=1,["GTTATAAT"]=12,["GTTATATC"]=1,["GTTATAGC"]=1,["GTTATACC"]=3,["GTTATTAC"]=2,["GTTATGAC"]=21,["GTTATCAC"]=1,["GTTATAAC"]=1488,["GTTATATA"]=1,["GTTCTAAT"]=1,["GTTCGTTC"]=2,["GTTCTAAC"]=14,["GTTGTATC"]=1,["GTTGTTAC"]=1,["GTTGTGAC"]=3,["GTTGTAAC"]=100,["GTTTTAAT"]=1,["GTTTTTTC"]=2,["GTTTTGAC"]=2,["GTTTTAAC"]=88,["TAAATTTA"]=41,["TAAATGTA"]=1,["TAAGTGCT"]=1,["TAATTTTT"]=1,["TAATTTTA"]=1,["TACATGTT"]=16,["TACATGTG"]=18,["TACATGTC"]=4,["TACATGTA"]=380,["TACATGCA"]=1,["TACGTGTG"]=1,["TACGTTGC"]=1,["TACGTGGC"]=1,["TACGTGTA"]=25,["TACGTGGA"]=1,["TACTTACT"]=2,["TACTTGTA"]=5,["TAGATCTT"]=2,["TAGATCTG"]=3,["TAGATCTC"]=1,["TAGATCTA"]=94,["TAGCTCTA"]=1,["TAGGTCTA"]=8,["TAGTTCTA"]=1,["TATATGTT"]=1,["TATATATT"]=2,["TATATATG"]=3,["TATATATC"]=1,["TATATGTA"]=1,["TATATATA"]=42,["TATCTGTG"]=1,["TATGTATG"]=2,["TCAATTGT"]=2,["TCAATTGG"]=3,["TCAATTGA"]=93,["TCAATCGA"]=1,["TCACTCAC"]=2,["TCACTTGA"]=1,["TCAGTTGA"]=2,["TCATTTGA"]=1,["TCCATGGT"]=3,["TCCATGGG"]=90,["TCCATGGC"]=2,["TCCATGGA"]=768,["TCCCTGGG"]=1,["TCCCTGGA"]=1,["TCCGTGGG"]=1,["TCCGTGGA"]=28,["TCCTTGGG"]=2,["TCCTTGGA"]=19,["TCGATCGT"]=2,["TCGATCGG"]=25,["TCGATTGA"]=1,["TCGATCGA"]=296,["TCGGTCGT"]=1,["TCGGTCGG"]=2,["TCTATTGG"]=1,["TCTATGGA"]=3,["TCTGTGGT"]=1,["TCTGTGGA"]=1,["TGAATTCT"]=3,["TGAATTTG"]=1,["TGAATTCG"]=6,["TGAATTCC"]=1,["TGAATGAC"]=1,["TGAATTCA"]=222,["TGACTGAC"]=2,["TGAGTTCG"]=1,["TGAGTTCA"]=8,["TGATTTCT"]=1,["TGCATGTT"]=1,["TGCATGCT"]=48,["TGCATGCG"]=193,["TGCATGCC"]=1,["TGCATGGA"]=1,["TGCATGCA"]=1958,["TGCGTGCT"]=5,["TGCGTGCG"]=10,["TGCGTGGA"]=1,["TGGATTAC"]=1,["TGGATTCA"]=1,["TGGCTGGC"]=2,["TGGGTTCA"]=1,["TGTGTTCG"]=1,["TGTTTTCA"]=1,["TTAATTAT"]=1,["TTAATTAA"]=4,["TTGATTGA"]=2,}

fragment.overhang_efficiency = function(fwd: string, rev: string): integer
  local to_check: string
  -- Sort overhangs alphabetically
  if fwd < rev then
    to_check = fwd .. rev
  else
    to_check = rev .. fwd
  end
  local output = fragment.fragmentation_table[to_check]
  if output == nil then output = 0 end
  return output
end

fragment.set_efficiency = function(overhangs: {string}): number
  local efficiency:number = 1.0
  for _, overhang in ipairs(overhangs) do
    if overhang == nil or overhang == "" then error("Got bad overhang") end
    local n_correct = fragment.overhang_efficiency(overhang, complement.reverse_complement(overhang))
    local n_total:number = n_correct
    -- Detect palindromes. This halves this overhang's efficiency
    if overhang == complement.reverse_complement(overhang) then
      n_total = n_total + n_correct
    end
    for _, overhang2 in ipairs(overhangs) do
      if overhang2 ~= overhang then
        local fragment_offset = fragment.overhang_efficiency(overhang, complement.reverse_complement(overhang2))
        n_total = n_total + fragment_offset
      end
    end
    efficiency = efficiency * (n_correct / n_total)
  end
  return efficiency
end

--[[---------------------------------------------------------------------------
fragment.next_overhangs and fragment.next_overhang have some fundamental
limitations. The algorithm to find the most effective next overhang is rather
naive, since it doesn't actually look more than 1 step ahead. For example, if
AAAA and ATGC are of equal efficiency this round, but ATGC eliminates a lot of
possible overhangs next round, fragment.next_overhangs cannot differentiate
between AAAA and ATGC

--]]---------------------------------------------------------------------------

fragment.next_overhangs = function(overhangs: {string}): {string}, {number}
  -- Build a current overhang table
  local current_overhangs: {string:boolean} = {}
  for _, overhang in ipairs(overhangs) do
    current_overhangs[overhang] = true
  end
  local overhangs_to_test:{string} = {}
  local bases = {"A", "T", "G", "C"}
  for base1=1,4 do
    for base2=1,4 do
      for base3=1,4 do
        for base4=1,4 do
          local quad_base = bases[base1] .. bases[base2] .. bases[base3] .. bases[base4]
          if current_overhangs[quad_base] == nil then
            overhangs_to_test[#overhangs_to_test+1] = quad_base
          end
        end
      end
    end
  end
  local overhang_efficiency:{number} = {}
  for idx, quad_base in ipairs(overhangs_to_test) do
    local test_set: {string} = {}
    for _, overhang in ipairs(overhangs) do
      test_set[#test_set+1] = overhang
    end
    test_set[#test_set+1] = quad_base
    overhang_efficiency[idx] = fragment.set_efficiency(test_set)
  end
  return overhangs_to_test, overhang_efficiency
end

fragment.next_overhang = function(overhangs: {string}): string
  local overhangs_to_test, efficiencies = fragment.next_overhangs(overhangs)
  local max_efficiency: number = 0
  local new_overhang: string = ""
  for i, overhang in ipairs(overhangs_to_test) do
    if efficiencies[i] > max_efficiency then
      max_efficiency = efficiencies[i]
      new_overhang = overhang
    end
  end
  if new_overhang == "" then error("no new overhangs available") end
  return new_overhang
end

fragment.fragment_sequence = function(sequence: string, min_length: integer, max_length: integer): {string}, number
  sequence = sequence:upper()
  -- min_length cannot be greater than max_length
  if min_length > max_length then error("min_length larger than max_length") end

  -- Minimum lengths (given oligos) for assembly is 8 base pairs.
  -- https://doi.org/10.1186/1756-0500-3-291
  -- For GoldenGate, 2 8bp oligos create 12 base pairs (4bp overhangs on two sides of 4bp),
  if min_length < 12 then error("min_length too small") end

  -- begin optimization after checks
  local function optimize_overhang_iteration(s: string, min: integer, max: integer, existing_fragments: {string}, existing_overhangs: {string}): {string}, number
    -- If the sequence is smaller than max_length, stop iteration.
    if #s < max then
      existing_fragments[#existing_fragments+1] = s
      return existing_fragments, fragment.set_efficiency(existing_overhangs)
    end

    -- If our iteration is approaching the end of the sequence, that means we
    -- need to gracefully handle the end so we aren't left with a tiny fragment
    -- that cannot be synthesized. For example, if our goal is fragments of
    -- 100bp, and we have 110 base pairs left, we want each final fragment to
    -- be 55bp, not 100bp and 10bp
    local min_len = min
    local max_len = max
    if #s < 2*max then
      local max_and_min_difference = max - min
      local max_fragment_size_buffer = (#s + max_and_min_difference) / 2 as integer
      if max_fragment_size_buffer > max then
        max_fragment_size_buffer = max
      end
      min_len = (max_fragment_size_buffer - max_and_min_difference) as integer
      max_len = max_fragment_size_buffer as integer
    end

    -- Get all sets of 4 between min and max fragment size
    local best_overhang_efficiency: number = 0
    local best_overhang_position: integer = 0
    local already_exists: boolean = false
    local offset = 0
    while offset <= max_len-min_len do
      -- We go from max -> min so that we maximize the size of our fragments
      local overhang_position = math.floor(max_len - offset)

      local overhang_to_test = s:sub(overhang_position-3, overhang_position)

      -- Check to make this overhang doesn't already exist
      already_exists = false
      for _, existing_overhang in ipairs(existing_overhangs) do
        if (existing_overhang == overhang_to_test) or (complement.reverse_complement(existing_overhang) == overhang_to_test) then
          already_exists = true
        end
      end
      
      if not already_exists then
        local test_set: {string} = {}
        for _, overhang in ipairs(existing_overhangs) do
          test_set[#test_set+1] = overhang
        end
        test_set[#test_set+1] = overhang_to_test
        local set_efficiency = fragment.set_efficiency(test_set)
        if set_efficiency > best_overhang_efficiency then
          best_overhang_position = overhang_position
          best_overhang_efficiency = set_efficiency
        end
      end

      offset = offset + 1
    end

    -- Set variables
    existing_fragments[#existing_fragments+1] = s:sub(1, best_overhang_position)
    existing_overhangs[#existing_overhangs+1] = s:sub(best_overhang_position-3, best_overhang_position)
    s = s:sub(best_overhang_position-3,-1)
    return optimize_overhang_iteration(s, min, max, existing_fragments, existing_overhangs)

  end

  return optimize_overhang_iteration(sequence, min_length, max_length, {}, {})
end

return fragment
