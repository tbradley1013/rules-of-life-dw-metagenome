#===============================================================================
# 
# 
# Tyler Bradley
# 2020-01-02 
#===============================================================================

library(tidyverse)

sra_links <- read_rds("data/sra-links.rds")
proj_summ <- read_csv("data/project-summary.csv")

sra_public <- discard(sra_links, is.null)

proj_summ %>% 
  filter(uid %in% names(sra_public)) %>% 
  write_csv("data/proj-summary-public.csv")
