##########################
#Run PGLS on multiPhylo object
##########################
#Runing a given PGLS model on a set of given trees. PGLS can be calculated on likelihood or baysian frame work. Save the results in a list of model files and print the summary of each model
#v1.4.2
#----
#guillert(at)tcd.ie & healyke(at)tcd.ie - 01/03/2013
##########################


MultiTreePGLS<-function(data.frame, species.col, formula, trees, output="Model1",framework="Bayesian", opt_ngen, opt_converge, thin_n)
{#Runs PGLS model on the trees provided using the input formula and species string
	#Library
	require(ape)
	require(caper)
	require(mvtnorm)
	
#Data checking
	##framwork
	if(((-is(framework, "character"))==0)) {stop("framework should be 'ML' or 'Bayesian'")} else {ok<-"ok"}
	if(framework=="ML"){ok<-"ok"} else {
		if(framework=="Bayesian"){require(MCMCglmm); require(modeest)} else {
			stop("framework should be 'ML' or 'Bayesian'")}}
	##data.frame
	if(((-is(data.frame, "data.frame"))==0)) {stop("'data.frame' is not a data.frame object")} else {ok<-"ok"}
	names(data.frame)<-sub(species.col,"sp.col",names(data.frame))
	data.frame["animal"]<-NA
	data.frame$animal<-data.frame$sp.col
	##formula
	if(((-is(formula, "formula"))==0)) {stop("'formula' is not a formula object")} else {ok<-"ok"}
	##trees
	if(((-is(trees, "multiPhylo"))==0)) {stop("'trees' is not a multiPhylo object")} else {ok<-"ok"}
	sp.tree<-lapply(trees, function (x) x$tip.label)
	Sp.tree<-lapply(sp.tree, function (x) sort(x))
	sp.data<-sort(data.frame$sp.col)
	###matching the tree labels with the data.frame labels (if necessary)
	trees<-lapply(trees, function (x) if(length(which(is.na(match(x$tip.label, sp.data))))==0) {x<-x} else {
		x<-drop.tip(x, which(is.na(match(x$tip.label, as.character(data.frame$sp.col)))))
		cat("Trees tip label are now corresponding to species column")})
	class(trees)<-"multiPhylo"	
#	ifelse(framework=="Bayesian", trees<-lapply(trees, function (x) if(is.ultrametric(x)){x<-x} else {x<-chronoMPL(x)}), NA)
#	class(trees)<-"multiPhylo"
	##save.result
	if(((-is(output, "character"))==0)) {warning("Output name is not correct")} else {ok<-"ok"}
	##optionals
	if(missing(opt_ngen))
		{ngen<-500000}else{
			if(is(opt_ngen, "numeric")) {ngen<-opt_ngen} else {
				if(framework=="Bayesian") {stop("opt_ngen is not numeric")} else {ok<-"ok"}}}
	if(missing(opt_converge))
		{converge<-1.1}else{
			if(is(opt_converge, "numeric")) {converge<-opt_converge} else {
				if(framework=="Bayesian") {stop("opt_converge is not numeric")} else {ok<-"ok"}}}
	if(missing(thin_n))
		{thin_n<-100}else{
			if(is(thin_n, "numeric")) {thinn<-thin_n} else {
				if(framework=="Bayesian") {stop("thin_n is not numeric")} else {ok<-"ok"}}}
		
#Runing the models
	##creating the file names
	file.names<-vector("list", length(trees))
	for (i in (1:length(trees))){
		file.names[[i]]<-paste(output, as.character("tree"),as.character(i), sep="_")
		file.names[[i]]<-paste(file.names[[i]], as.character("R"), sep=".")}
#	if(framework=="Bayesian"){
#		converge<-vector("list", length(trees))
#		for (i in (1:length(trees))){
#			converge[[i]]<-paste(as.character("converge"), output, as.character("tree"),as.character(i), sep="_")
#			converge[[i]]<-paste(converge[[i]], as.character("R"), sep=".")}} else {ok<-"ok"}
		
	##runing the models (overwriting)
	if(framework=='ML'){
		for (i in (1:length(trees))){
			model<-pgls(formula, comparative.data(data=data.frame, phy=trees[[i]], names.col="sp.col", vcv=TRUE, vcv.dim=3), lambda='ML', bounds=list(lambda=c(1e-03,1),kappa=c(1e-06,3),delta=c(1e-06,3)))
			save(model, file=as.character(file.names[[i]]))
			cat(format(Sys.time(), "%H:%M:%S"), "-", output, "on tree", as.character(i), "done", "\n")}}
	
	else {prior<-list(R = list(V = 1/2, nu=0.002), G = list(G1=list(V = 1/2, nu=0.002)))
		for (i in (1:length(trees))){
			model<-MCMCglmm(formula, random=~animal,pedigree=trees[[i]],prior=prior,data=comparative.data(data=data.frame, phy=trees[[i]], names.col="sp.col", vcv=FALSE)$data,verbose=FALSE,family=c("gaussian"),nitt=ngen,burnin=as.integer(ngen/6),thin=thinn)
			model.1<-MCMCglmm(formula, random=~animal,pedigree=trees[[i]],prior=prior,data=comparative.data(data=data.frame, phy=trees[[i]], names.col="sp.col", vcv=FALSE)$data,verbose=FALSE,family=c("gaussian"),nitt=ngen/50,burnin=as.integer(ngen/300),thin=thinn/50)
			
			convergence<-gelman.diag(mcmc.list(as.mcmc(model.1$Sol[1:(length(model.1$Sol[,1])),]),as.mcmc(model$Sol[1:(length(model.1$Sol[,1])),])))
#			conv<-all(convergence$psrf[,1]<converge)
			save(model, file=as.character(file.names[[i]]))
#			save(convergence, file=as.character(converge[[i]]))
			cat(format(Sys.time(), "%H:%M:%S"), "-", output, "on tree", as.character(i), "done", "\n")
			cat(format(Sys.time(), "%H:%M:%S"), "-", "Effective sample size is >1000:",all(effectiveSize(model$Sol[])>1000), "\n")
			cat(format(Sys.time(), "%H:%M:%S"), "-", "All levels converged:",all(convergence$psrf[,1]<converge), "\n")}}
			
			
#Output
cat(format(Sys.time(), "%H:%M:%S"), "-", output, "run and saved on all trees","\n")
cat("Use SumMultiPGLS function to summarise the output", "\n")
}