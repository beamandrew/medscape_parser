library(rvest)

baseurl <- "http://emedicine.medscape.com"
base_page <- html(baseurl)

base_links <- base_page %>% html_node("div#browsespecialties") %>% html_nodes("li") 
sections <- data.frame()
for(i in 1:length(base_links)) {
  name <- base_links[[i]] %>% html_text()
  link <-  base_links[[i]] %>% html_node("a") %>% html_attr("href")
  sections <- rbind(sections,cbind(name,link))
}

excluded_sections <- c("Cancer Guidelines","Cancer Treatment & Staging Guides ")

medscape_links <- NULL
## Now go through and get the links for all of the pages in each section ##
for(i in 1:nrow(sections)) {
  print(i)
  subsection <- sections[i,]
  section <- as.character(subsection$name)
  link <- as.character(subsection$link)
  if( length(which(excluded_sections == section)) == 0 ) {
    if( length(grep("http",link)) == 0 ) {
      section_page <- html(paste0(baseurl,link))
    } else {
      section_page <- html(link)
    }  
    section_links <- section_page %>% html_node("div.midcol") 
    if(is.null(section_links)) {
      section_links <- section_page %>% html_node("div.maincolbox") 
    }
    section_links <- section_links %>% html_nodes("li") 
    for(j in 1:length(section_links)) {
      name <- section_links[[j]] %>% html_text()
      link <-  section_links[[j]] %>% html_node("a") %>% html_attr("href")
      medscape_links <- rbind(medscape_links,cbind(section,name,link))
    }
  }
}

write.csv(medscape_links,file="../data/medscape_links.csv",row.names=FALSE)