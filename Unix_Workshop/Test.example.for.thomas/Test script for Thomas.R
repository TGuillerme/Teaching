#MCMC for BMR longevity models test
#15 oct 2013
#Kevin Healy

####-----------------------------------------------------------------------###
####-----------------------------------------------------------------------###
####-------Full tree excluding gliding species-----------------------------###
####----------------------no breakdown-------------------------------------###
####-----------------------------------------------------------------------###
rm(list=ls())
graphics.off()
# load packages
library(MCMCglmm)
library(modeest)
library(ape)
library(caper)
source("MultiTreePGLS_v1.4.f.R")

#data in full warts and all
data <- read.csv('data.csv', sep =",", header =T)

#load tree
trees <- read.tree("trees.tre")#this gives a multiphylo object with 100 trees #I need to update this to the one with 1000 trees



source("MultiTreePGLS_v1.4.f.R")


data.frame <- data
species.col <- "species.m"
formula <- long.m~BMR + mass.m + volant.m + mass.m:volant.m
trees <- trees
opt_ngen <- 1000
thin_n <- 50
opt_converge <- 1.1
framework <- "Bayesian"

#run the models
MultiTreePGLS(data.frame, species.col, formula, trees, output="Model1", framework = framework, opt_ngen, opt_converge, thin_n)

