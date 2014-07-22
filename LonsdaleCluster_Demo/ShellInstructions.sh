#Loading the correct modules and the correct R version
source /etc/profile.d/modules.sh
export http_proxy=http://proxy.tchpc.tcd.ie:8080
module load cports R/3.0.2-gnu
module load cports gsl/1.16-gnu

#Installing R packages ----- IF NEEDED
#echo "options(repos=structure(c(CRAN='http://ftp.heanet.ie/mirrors/cran.r-project.org/')))
#install.packages(c('MCMCglmm','modeest','ape','caper'))" > required_packages.tmp
#R --no-save < required_packages.tmp
#rm required_packages.tmp

#Preparing the R-codes jobs
for ((i=1 , j=3, k=0 ; i<=24 , j<=24 , k<=7 ; i+=3 , j+=3 , k+=1))
do sed 's/trees <- trees/trees <- trees['"$i"':'"$j"']/g' R_short_version.R | sed 's/<OUTPUT>/Trees_'"$i"'-'"$j"'/g'> R_script_${i}-${j}.R
echo "R --no-save < R_script_${i}-${j}.R" > R${k}.sh
done

#Preparing the job config file for multi core
for ((k=0 ;  k<=7 ;  k+=1))
do echo "$k sh R${k}.sh" >> Rjob.config
done

#Preparing the batch job file ----- I didn't tried the actual time but it should take just a few minutes, you can probably adjust the #SBATCH -t option here.
echo '#!/bin/sh
#SBATCH -n 8
#SBATCH -t 4-00:00:00
#SBATCH -p compute
#SBATCH -J MultiTreePGLS
source /etc/profile.d/modules.sh
export http_proxy=http://proxy.tchpc.tcd.ie:8080
module load cports R/3.0.2-gnu
module load cports gsl/1.16-gnu

srun --multi-prog Rjob.config' > Rjob.sh

#Submitting the job
sbatch Rjob.sh

#End