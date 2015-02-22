#!/bin/bash

# reg: $1
#************************************ PREPROCESSING *******************************************#

source "$(dirname `readlink -f ${0}`)/training/config.sh"

suffix=$1;
#model_dir=$2;
infix=test

#echo model dir = ${model_dir}

training_dir_old=${datadir}/naacl2012_splits/from_dipanjan/another_set
#processedfile=${training_dir_old}/cv.${infix}.sentences.all.lemma.tags
processedfile_new=${datadir}/naacl2012_splits/mstparsed_by_me/cv.${infix}.sentences.all.lemma.tags
processedfile=$processedfile_new
#tokenizedfile=${training_dir_old}/cv.${infix}.sentences.tokenized
tokenizedfile=${datadir}/naacl2012_splits/mstparsed_by_me/cv.${infix}.sentences.tokenized
fefile=${training_dir_old}/cv.${infix}.sentences.frame.elements
framesfile_new=${datadir}/naacl2012_splits/from_dipanjan/cv.${infix}.sentences.frames
relation_modified_file="${SEMAFOR_HOME}/../framenet_data/frRelationModified.xml";
frames_single_file="${SEMAFOR_HOME}/../framenet_data/framesSingleFile.xml";
echo ${CLASSPATH}
echo ${CLASSPATH_OLD}

#temp=temp_frust_fn_lus/on_fn
#temp=temp_siblings/on_fn
#temp=temp_siblings_fn_lus/on_fn
#temp=temp_ancestors_fn_lus/on_fn
temp=temp_lus_only/on_fn
#temp=temp_ancestors/on_fn
#temp=temp_adadelta_fn_with_lus/on_fn
mkdir -p ${temp}
echo "temp directory: $temp"

end=`wc -l ${tokenizedfile}`
end=`expr ${end% *}`
echo "Start:0"
echo "End:${end}"

#**********************************ARGUMENT IDENTIFICATION********************************************#
$JAVA_HOME_BIN/java -classpath ${CLASSPATH} -Xms4000m -Xmx8g edu.cmu.cs.lti.ark.fn.parsing.CreateAlphabet \
${framesfile_new} \
${processedfile_new} \
${temp}/file.fe.events.bin \
${model_dir}/scan/parser.conf.unlabeled \
${temp}/file.frame.elements.spans \
false \
1 \
null > /tmp/test.spans.out

##
#exit;

$JAVA_HOME_BIN/java -classpath ${CLASSPATH_OLD} -Xms4000m -Xmx4000m edu.cmu.cs.lti.ark.fn.parsing.DecodingMainArgs \
${model_dir}/svm.argmodel.dat \
${model_dir}/scan/parser.conf.unlabeled \
${temp}/file.fe.events.bin \
${temp}/file.frame.elements.spans \
${temp}/file.predict.frame.elements \
${fefile} \
overlapcheck > /tmp/output  ## nooverlapcheck to get Naive search results

#exit;

#**********************************END OF ARGUMENT IDENTIFICATION********************************************#


cat ${fefile} | awk '{print "0""\t"$0}' > $temp/file.gold.frame.elements

$JAVA_HOME_BIN/java -classpath ${CLASSPATH_OLD} -Xms1000m -Xmx1000m edu.cmu.cs.lti.ark.fn.evaluation.PrepareFullAnnotationXML \
testFEPredictionsFile:$temp/file.predict.frame.elements \
startIndex:0 \
endIndex:${end} \
testParseFile:${processedfile} \
testTokenizedFile:${tokenizedfile} \
outputFile:$temp/file.predict.xml

$JAVA_HOME_BIN/java -classpath ${CLASSPATH_OLD} -Xms1000m -Xmx1000m edu.cmu.cs.lti.ark.fn.evaluation.PrepareFullAnnotationXML \
testFEPredictionsFile:$temp/file.gold.frame.elements \
startIndex:0 \
endIndex:${end} \
testParseFile:${processedfile} \
testTokenizedFile:${tokenizedfile} \
outputFile:$temp/file.gold.xml

echo "Exact Results"
perl ${SEMAFOR_HOME}/scripts/scoring/fnSemScore_modified.pl -c ${temp} \
-l \
-n \
-e \
-v \
${frames_single_file} ${relation_modified_file} \
$temp/file.gold.xml \
$temp/file.predict.xml > evaluation/results/argid_${infix}_ll_beam_1_exact_verbose_${suffix}
