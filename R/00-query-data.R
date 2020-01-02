#===============================================================================
# A script to pull data from drinking water bulk water and biofilm metagenomic
# publically available datasets
# 
# Tyler Bradley
# 2019-12-26 
#===============================================================================

library(rentrez) # to query NCBI
library(tidyverse) # data manipulation

# get all the projects with the words drinking water distribution system in the title
project_srch <- entrez_search(db = "bioproject", term = "Drinking Water Distribution System",
                              retmax = 100) 

# get all of the summary data for each of the projects
proj_sum_raw <- entrez_summary(db = "bioproject", id = project_srch$ids)

# parse the data into a dataframe
proj_sum <- map_dfr(proj_sum_raw, function(z){
  out <- imap_dfc(z, ~{
    field <- quo(.y)
    field <- quo_name(.y)
    
    out <- tibble(!!field := paste(.x, collapse = ", "))
    return(out)
  })
  
  return(out)
})

write_csv(proj_sum, "data/project-summary.csv")

sra_links <- map(project_srch$ids, ~{
  links <- entrez_link(dbfrom = "bioproject", id = .x, db = "sra")
  out <- links$links$bioproject_sra
  if (length(out) == 0) return(NULL)
  
  return(out)
})

names(sra_links) <- project_srch$ids

write_rds(sra_links, "data/sra-links.rds")

sra_links_tbl <- imap_dfr(sra_links, ~{
  if (is.null(.x)) return()
  
  out <- tibble(
    bioproject = .y,
    sra = paste(.x, collapse = ", ")
  )
  
  return(out)
})

write_csv(sra_links_tbl, "data/sra-links-tbl.csv")

