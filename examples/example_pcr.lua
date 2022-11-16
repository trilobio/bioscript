-- Example of PCR prep using Taq Polymerase with Standard Taq Buffer
-- https://www.neb.com/products/m0273-taq-dna-polymerase-with-standard-taq-buffer#Product%20Information

-- Start a new protocol
protocol = new_protocol("lacZ PCR")

-- Setup target gene. In this case, lacZ (alpha fragment, http://parts.igem.org/Part:BBa_I732006)
gene = "atgaccatgattacggattcactggccgtcgttttacaacgtcgtgactgggaaaaccctggcgttacccaacttaatcgccttgcagcacatccccctttcgccagctggcgtaatagcgaagaggcccgcaccgatcgcccttcccaacagttgcgcagcctgaatggcgaatggcgctttgcctggtttccggcaccagaagcggtgccggaaagctggctggagtaataa"

-- Get PCR primers for this gene with a tm of 55
forward, reverse = synbio.pcr.design_primers(gene, "taq_standard", 55)

-- Create a new PCR mixture with the gene and primers designed above
protocol:new_reaction{reaction="taq_standard", templates={gene}, primers={forward,reverse}}

return protocol
