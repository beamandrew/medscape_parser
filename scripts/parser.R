strip <- function(txt) {
  txt <- gsub("\n"," ",txt)
  txt <- gsub("\t"," ",txt)
  ## Remove reference links ##
  txt <- gsub("\\[[[:digit:]]*\\]","",txt)
  txt <- gsub("( )+"," ",txt)
}

library(rvest)

## Read in the manifest ##
medscape_links <- read.csv("../data/medscape_links.csv",stringsAsFactors=FALSE)

baseurl <- "http://emedicine.medscape.com"

medscape_text <- data.frame()
for(i in 1:nrow(medscape_links)) {
  print(i)
  section <- medscape_links$section[i]
  link <- medscape_links$link[i]
  name <- medscape_links$name[i]
  page <- html(paste0(baseurl,link,"#showall"))
  overview <- page %>% html_node("div.drugdbsectioncontent") %>% html_text()
  text <- strip(overview)
  topic <- "Overview"
  medscape_text <- rbind(medscape_text,cbind(section,name,link,topic,text))
  ## See if this page has other topic pages ##
  topic_nav <- page %>% html_node("div#topic_menu")
  if(!is.null(topic_nav)) {
    topic_links <- topic_nav %>% html_nodes("li")
    for(j in 1:length(topic_links)) {
      topic <- topic_links[[j]] %>% html_text()
      topic_link <-  topic_links[[j]] %>% html_node("a") %>% html_attr("href")
      if(topic != "Overview") {
        topic_page <- html(paste0(baseurl,"/article/",topic_link,"#showall"))
        text <- topic_page %>% html_node("div.drugdbsectioncontent") %>% html_text()
        text <- strip(topic_content)
        link <- topic_link
        medscape_text <- rbind(medscape_text,cbind(section,name,link,topic,text))
      }
    }
  }
}