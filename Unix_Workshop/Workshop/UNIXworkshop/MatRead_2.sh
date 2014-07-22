##########################
#Transforming nexus morphological matrices to be read by MatRead.R
##########################
#Generates n matrices to be read by MatRead.R
#Generates a citation file
##########################


#Creating a folder for the output and cleaning the old ones
rm -R matrices
rm citations.txt
mkdir matrices

#Initiating the loop
for f in MatricesSet2/*.nex
do
prefix=$(basename $f .nex)
echo ${prefix}

#Extracting the matrices references
grep -A 5 'Study reference:' MatricesSet2/${prefix}.nex > ${prefix}.nam.tmp
tr '\n' ' ' < ${prefix}.nam.tmp > ${prefix}.name.tmp
sed 's/Study reference: //g' ${prefix}.name.tmp | sed 's/  TreeBASE Study URI:.*//g' > ${prefix}.name


#Extracting the number of taxa in order to isolate the matrix
grep 'DIMENSIONS NTAX=' MatricesSet2/${prefix}.nex > ${prefix}.ntax.tmp
sed 's/DIMENSIONS NTAX=//g' ${prefix}.ntax.tmp | sed 's/;//g' | sed 's/ //g' > ${prefix}.ntax
NTAX=$(sed -n '1p' ${prefix}.ntax)
let 'NTAX += 2'

#Extracting the matrix, adding a space between each characters in order to read in in R as tab.delim and collapsing the uncertainties (e.g. {01}) into missing data (?)
grep -A $NTAX 'MATRIX' MatricesSet2/${prefix}.nex > ${prefix}.mat.tmp
sed '1,3d' ${prefix}.mat.tmp | sed 's/.* //g' | sed 's/{..}/?/g' | sed 's/{...}/?/g' | sed 's/{....}/?/g' | sed 's/{.....}/?/g' | sed -e 's/\(.\)/\1 /g' > matrices/${prefix}.mat

done

#Writing the citation file
for f in *.name ; do paste $f >> citations.txt ; done ; 

#Cleaning temporaries files
rm *.name.tmp
rm *.nam.tmp
rm *.ntax.tmp
rm *.ntax
rm *.mat.tmp
rm *.name
echo 'End'
#Analysing and ploting the results through R
R --no-save < MatRead.R
