##########################
#R code example using MultiTreePGLS function - TESTING VERSION
##########################
#Running a comparative analysis in a Bayesian framework on multiple phylogenetic tree to measure the effect of ecological traits on life span
#This analysis has been used in Healy.et.al in review.
#----
#healyke(at)tcd.ie & guillert(at)tcd.ie - 15/09/2013
##########################

#Loading packages and scripts
require(MCMCglmm)
require(modeest)
require(ape)
require(caper)
source('MultiTreePGLS_v1.4.f.R')

#Data input
data <- read.csv('Data_425sp.csv', sep =',', header =T)
trees <- read.tree('Trees_24tr.tre')

#Options setting
data.frame <- data
species.col <- "species.m"
formula <- long.m~BMR + mass.m + volant.m + mass.m:volant.m
trees <- trees
opt_ngen <- 1000
thin_n <- 50
opt_converge <- 1.1
framework <- 'Bayesian'
output <- '<OUTPUT>'

#Run the models
MultiTreePGLS(data.frame, species.col, formula, trees, output, framework, opt_ngen, opt_converge, thin_n)

