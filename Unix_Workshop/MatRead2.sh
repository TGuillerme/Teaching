##########################
#Transforming nexus morphological matrices to be read by CharactersStates.R
##########################
#Generates n matrices to be read by CharactersStates.R
#Generates a citation file
##########################

for f in *.nex
 
do

prefix=$(basename $f .nex)

echo ${prefix}


#Extracting the reference name
grep -A 5 'Study reference:' ${prefix}.nex > ${prefix}.nam.tmp
tr '\n' ' ' < ${prefix}.nam.tmp > ${prefix}.name.tmp
sed 's/Study reference: //g' ${prefix}.name.tmp | sed 's/  TreeBASE Study URI:.*//g' > ${prefix}.name





#Extracting the number of taxa
grep 'DIMENSIONS NTAX=' ${prefix}.nex > ${prefix}.ntax.tmp
sed 's/DIMENSIONS NTAX=//g' ${prefix}.ntax.tmp | sed 's/;//g' | sed 's/ //g' > ${prefix}.ntax

grep 'DIMENSIONS NCHAR=' ${prefix}.nex > ${prefix}.nchar.tmp
sed 's/DIMENSIONS NCHAR=//g' ${prefix}.nchar.tmp | sed 's/;//g' | sed 's/ //g' > ${prefix}.nchar



NTAX=$(sed -n '1p' ${prefix}.ntax)
ntaxa=$NTAX
nchar=$(sed -n '1p' ${prefix}.nchar)
let "NTAX += 2"

#Extracting the matrix
grep -A "$NTAX" 'MATRIX' ${prefix}.nex > ${prefix}.mat.tmp
echo $ntaxa $nchar > ${prefix}.mat
sed '1,3d' ${prefix}.mat.tmp | sed 's/.* //g' | sed 's/{..}/?/g' | sed 's/{...}/?/g' | sed 's/{....}/?/g' |sed 's/{.....}/?/g' | sed -e 's/\(.\)/\1 /g' >> ${prefix}.mat

done


for f in *.name ; do paste $f >> citations.txt ; done ; 


#Cleaning temporaries
rm *.name.tmp
rm *.nam.tmp
rm *.ntax.tmp
rm *.ntax
rm *.nchar.tmp
rm *.nchar
rm *.mat.tmp
rm *.name