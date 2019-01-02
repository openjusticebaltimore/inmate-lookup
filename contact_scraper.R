# Load required packages

required.packages("plyr")

# Store the inmate lookup site url
base.url<-"http://www.dpscs.state.md.us/inmate/"

# How many inmates show up on a page if there are a lot of search results?
npage<-15

# Function to scrape info for all inmates whose last name starts with letter 
letter.contacts<-function(letter){

# Get the sequence of start numbers, based on the number of inmates whose last name starts with the given letter.

first<-""
last<-letter
url<-paste0(base.url,"search.do?searchType=name&firstnm=",first,"&lastnm=",last)
con<-url(url)
lines<-readLines(con)#[[258]]

n<-regexpr("Total Inmate Found: [0-9]*", lines, perl=TRUE)
n.inmates<-as.numeric(sub("Total Inmate Found: ","",regmatches(lines, n)))
pages<-seq(from=1,to=n.inmates,by=npage)

# scrape the links to inmate detail pages
get.links<-function(page){
page.url<-paste0(base.url,"search.do?searchType=name&lastnm=",last,"&firstnm=&start=",page)
page.con<-url(page.url)

page.lines<-readLines(page.con)
m <- regexpr("search\\.do\\?searchType=detail&id=[0-9]*", page.lines, perl=TRUE)
links<-regmatches(page.lines, m)
links<-paste0(base.url,links)
}

all.links<-unique(unlist(lapply(pages, get.links)))

# Go to each inmate detail page and parse it
parse.link<-function(link){
text<-readLines(url(link))

DOB<-trimws(text[272])  #regmatches(text, regexpr("[0-9]{2,2}/[0-9]{2,2}/[0-9]{4,4}", text, perl=TRUE))
SID<-trimws(text[260])
Last.Name<-trimws(text[263])
First.Name<-trimws(text[266])
Middle.Name<-trimws(text[269])
DOC.ID<-trimws(text[289])
Holding.Facility<-trimws(sub("^.*>","",sub("</a>","",text[296])))
Address<-trimws(sub("</td>","",sub("<br>","",sub("^.*&nbsp;","",text[299]))))
Phone<-trimws(sub("</tr>","",sub("</p>","",sub("^.*&nbsp;","",text[300]))))
row<-as.data.frame(do.call(cbind,list(SID,DOC.ID,Last.Name,First.Name,Middle.Name,DOB,Holding.Facility,Address,Phone)))
names(row)<-c("SID","DOC.ID","Last.Name","First.Name","Middle.Name","DOB","Holding.Facility","Address","Phone")
return(row)
}

# stick the rows together for a given letter
contacts<-rbind.fill(lapply(all.links, parse.link))

}

# A-Z together
inmates<-rbind.fill(lapply(LETTERS, letter.contacts))

# Remove Duplicates
inmates<-inmates[!duplicated(inmates),]

# Add date scraped column
inmates$Date.Scraped<-Sys.Date()

# Clean Prison names (ampersands)
inmates$Holding.Facility<-gsub("&amp;","&",inmates$Holding.Facility)

# OUTPUT
write.csv(inmates,paste0(getwd(),"/MD_Inmate_Lookup_",Sys.Date(),".csv"),
          row.names = F)

# summary(duplicated(inmates))
