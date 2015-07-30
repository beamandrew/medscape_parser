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

