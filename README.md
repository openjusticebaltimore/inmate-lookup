# inmate-lookup
Scraper for the Maryland Division of Corrections Inmate Lookup

## Getting Started
### Requirements
[R](https://www.r-project.org/) (required) 

[RStudio](https://www.rstudio.com/products/rstudio/download/) (optional, recommended) 
A decent internet connection


## Execution

Open contact_scraper.R in R or RStudio.

Optionally set the working directory to which you would like to write the program output using the setwd command.

```
setwd("C:/MyFolder")
```

Execute the script. If using RStudio, you can either click the "Source" button or select all the text in the code editor and press Ctrl+Enter

The program will take several minutes to run. The last thing it does is write a CSV with detail info for all inmates to the working directory.

If you did not set the working directory, you can print its location in a character string by executing the command getwd() from the console.


### Program Parameters

#### the inmate lookup site url

This will need to be updated if the site changes

```
base.url <- "http://www.dpscs.state.md.us/inmate/"
```


#### How many results show up on a page if a query returns more than one?

This will need to be updated if the number of of query results displayed on a page changes.

```
npage <- 15
```

## Program Notes

The MDOC Inmate Lookup uses 2 types of url based queries:

* name queries have 3 parameters: last name, first name, and start number

```
http://www.dpscs.state.md.us/inmate/search.do?searchType=name&lastnm=A&firstnm=&start=1
```

* detail  queries use a unique ID for each inmate.

```
http://www.dpscs.state.md.us/inmate/search.do?searchType=detail&id=79172211
```

A query that returns multiple results will show a page with embedded links to the detail page for each inmate matched by the query.


The main program function is letter.contacts. It has has one argument, letter, which defines the last name value of the name type url query.

The program applies this function to each letter of the alphabet. 

The function stores the number of results of each query, found by a regular expression match in the html text of the results page.

This number and the npage parameter are used to generate a sequence of start numbers, which can be specified in the url query to view a page of results for a query that returns many.

The text of each page of results is read and the embedded urls are stored.

A connection is opened for each of these urls and the html text is read and parsed to get inmate detail info. The parsing section uses line numbers of html text. These will need to be changed if the structure of the detail page template changes. It may be a good idea to go ahead and change the parsing section to use regular expression matches instead.
  
Some inmates have duplicate records (on all fields). These are removed.

