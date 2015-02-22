#!/bin/bash

# reg: $1
#************************************ PREPROCESSING *******************************************#
suffix=$1;
infix=test

source "$(dirname `readlink -f ${0}`)/training/config.sh"
pwd
relation_modified_file="${SEMAFOR_HOME}/../framenet_data/frRelationModified.xml";
frames_single_file="${SEMAFOR_HOME}/../framenet_data/framesSingleFile.xml";
tokenizedfile=${training_dir_old}/cv.${infix}.sentences.tokenized
#tokenizedfile=${datadir}/naacl2012_splits/mstparsed_by_me/cv.${infix}.sentences.tokenized

#temp=temp_siblings
temp=temp_frust_fn_lus/on_fn
mkdir ${temp}
echo "temp directory: $temp"
echo ${frames_single_file} 
echo ${relation_modified_file}

end=`wc -l ${tokenizedfile}`
end=`expr ${end% *}`
echo "Start:0"
echo "End:${end}"

echo "Exact Results"
perl ${SEMAFOR_HOME}/scripts/scoring/fnSemScore_modified.pl -c ${temp} \
-l \
-n \
-f \
-e \
-v \
${frames_single_file} ${relation_modified_file} \
$temp/file.gold.xml \
$temp/file.predict.xml > evaluation/results/argid_${infix}_ll_beam_1_exact_verbose_${suffix}
