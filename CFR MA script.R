## COVID mortality rate by testing
rm(list = ls())

library(rvest)
library(data.table)
library(stringr)
library(meta)

# timestamp for saving the file. 
timestamp  = Sys.time()

## set working  directory 
#setwd("C:/users/jasono/OneDrive/Documents/")

cases_url = 'https://www.worldometers.info/coronavirus/'
cases = read_html(cases_url)  
casedata = html_nodes(cases, '#main_table_countries_today')
cdt = html_table(casedata)

# extract the updating time 
timest = html_nodes(cases,'div:nth-child(5)')
ts = html_text(timest)[[1]]

## turn the data into a data.table object
cdt = setDT(cdt[[1]])
setnames(cdt,old = 'Country,Other', new = 'Country')
cdt[,TotalDeaths:=as.numeric(str_replace(TotalDeaths,",",""))]
cdt[,TotalCases:=as.numeric(str_replace(TotalCases,",",""))]

# change character to numeric variables 
cdt[,TotalDeaths:=as.numeric(TotalDeaths)] 
cdt[,NewDeaths:=as.numeric(NewDeaths)]
cdt[is.na(TotalDeaths), TotalDeaths:=0]
cdt[is.na(NewDeaths), NewDeaths:=0]
cdt[,CFR:=((TotalDeaths)/TotalCases)*100, by = Country]
cdt[Country=="S. Korea", Country:="South Korea"]

## Exclusions 
cdt2 = cdt[TotalDeaths > 3]
cdt3 = cdt2[!{Country=="Diamond Princess" | Country=="Total:"}]

## Change the layour of the confidence interval 
cilayout(bracket = "(", separator = " to ")

## Run the meta-analysis 
MA = metaprop(event = TotalDeaths, 
              n = TotalCases, 
              data = cdt3,
              studlab = Country,
              comb.random = F, 
              prediction  = T,
              method = "Inverse",
)

# set up the unique file name for the graph. 

fnm = paste0("COVID data/CFR_analysis",substring(timestamp,0,10),".png")
#png(filename = fnm, res = 300, height= 2400, width = 3000)
forest(MA,sortvar = -cdt3$CFR,prediction = T,leftlabs = c("Country","Deaths","Cases"), digits.tau2 = 2, 
       pscale = 100, rightlabs = c("Case Fatality (%)","95%-CI"),xlim=c(0,15), 
       overall = F, colgap.left = "4mm",fontsize = 10,
       text.addline1 = "\n", text.addline2 = paste0(ts), 
       ff.addline = "bold")
#dev.off()
