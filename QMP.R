# rarefaction to even sampling depth #
# @author Doris Vandeputte           #
######################################
# function rarefy_even_sampling_depth
# with cnv_corrected_abundance_table: a copy number variation corrected abundance table with sample-identifiers as rows, copy number corrected taxa-abundances as columns
# with cell_counts_table: a table with sample-identifiers as rows, cell counts as columns 
# makes use of phyloseq function rarefy_even_depth
library(phyloseq)
rarefy_even_sampling_depth <- function(cnv_corrected_abundance_table, cell_counts_table) 
{
    try(if(all(row.names(cnv_corrected_abundance_table) == row.names(cell_counts_table))==FALSE) stop("Cnv_corrected_abundance_table and cell_counts_table do not have the same sample-names, Please check!"))
    cnv_corrected_abundance_table = ceiling(cnv_corrected_abundance_table) # data values are rounded up in order to make use of integer values during the calculations
    cell_counts_table = t(cell_counts_table[order(row.names(cnv_corrected_abundance_table)),]) # make sure the order of the samples is the same in both files  
    sample_sizes = rowSums(cnv_corrected_abundance_table) # sample size of each sample (total nr of reads)
    sampling_depths = sample_sizes / cell_counts_table # sampling depth of each sample (total nr of reads divided by the cell count)
    minimum_sampling_depth = min(sampling_depths) # minimum of all sampling depths
    rarefy_to = cell_counts_table * minimum_sampling_depth # nr of reads to rarefy in each sample in order to get to an even sampling depth over all samples
    cnv_corrected_abundance_table_phyloseq = otu_table(cnv_corrected_abundance_table, taxa_are_rows = FALSE) # convert to phyloseq otutable
    out=NULL
    for (i in 1:nrow(cnv_corrected_abundance_table_phyloseq))
    {
      x <- rarefy_even_depth(cnv_corrected_abundance_table_phyloseq[i], sample.size = rarefy_to[i], rngseed = 711, replace = FALSE, trimOTUs = F, verbose = FALSE)
      out=rbind(out,x)
    }
    rarefied_matrix = as.matrix(out)
    normalised_rarefied_matrix = rarefied_matrix/rowSums(rarefied_matrix)
    QMP = normalised_rarefied_matrix*cell_counts_table[1,]
    return(QMP)
}

# Example
a = matrix( c(4,4,2,1,8,5,2,0,3,5,3,1,10,8,3,0,0,6,4,3), nrow=5, ncol=4, byrow = TRUE, dimnames = list(c("Sample A", "Sample B", "Sample C", "Sample D", "Sample E"),c("taxa1", "taxa2", "taxa3", "taxa4"))) # my cnv_corrected_abundance_table
b = matrix(c(10,20,34,21,12), nrow=5, ncol=1, byrow = TRUE, dimnames = list(c("Sample A", "Sample B", "Sample C", "Sample D", "Sample E"),c("#")))*100000 # my cell_counts_table
rarefy_even_sampling_depth(a,b)