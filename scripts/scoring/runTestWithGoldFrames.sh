#!/bin/bash
#set -e # fail fast

cv=$1  # "test" or "dev"
experiments_dir=$2
SCALA_HOME_BIN="/usr0/home/mkshirsa/research/packages/scala-2.10.4/bin"

source "$(dirname ${BASH_SOURCE[0]})/../../training/config.sh"

test_dir="${datadir}/fn_data"
all_lemma_tags_file="${test_dir}/cv.${cv}.sentences.all.lemma.tags"
tokenizedfile="${test_dir}/cv.${cv}.sentences.tokenized"
gold_fe_file="${test_dir}/cv.${cv}.sentences.frame.elements"


fn_1_5_dir="${SEMAFOR_HOME}/../framenet_data"
frames_single_file="${fn_1_5_dir}/framesSingleFile.xml"
relation_modified_file="${fn_1_5_dir}/frRelationModified.xml"

results_dir="${experiments_dir}/results"
mkdir -p "${results_dir}"
results_file="${results_dir}/argid_${cv}_exact"

mkdir "${experiments_dir}/output"
predicted_xml="${experiments_dir}/output/${cv}.argid.predict.xml"
gold_xml="${experiments_dir}/output/${cv}.gold.xml"



# make a gold xml file whose tokenization matches the tokenization used for parsing
# (hack around the fact that SEMAFOR mangles token offsets)
end=`wc -l ${tokenizedfile}`
end=`expr ${end% *}`
echo "Start:0"
echo "End:${end}"
${JAVA_HOME_BIN}/java -classpath ${classpath} -Xms1g -Xmx1g \
    edu.cmu.cs.lti.ark.fn.evaluation.PrepareFullAnnotationXML \
    testFEPredictionsFile:${gold_fe_file} \
    startIndex:0 \
    endIndex:${end} \
    testParseFile:${all_lemma_tags_file} \
    testTokenizedFile:${tokenizedfile} \
    outputFile:${gold_xml}


echo "Performing argument identification on ${cv} set, with model \"${model_name}\"..."
${SCALA_HOME_BIN}/scala \
  -cp "${classpath}" \
  -J-Xms4g \
  -J-Xmx4g \
  -J-XX:ParallelGCThreads=2 \
  scripts/scoring/parseToXmlWithGoldFrames.scala \
  ${model_name} \
  ${cv} \
  ${experiments_dir}


echo "Evaluating argument identification on ${cv} set..."
${SEMAFOR_HOME}/scripts/scoring/fnSemScore_modified.pl \
    -l \
    -n \
    -e \
    -v \
    ${frames_single_file} \
    ${relation_modified_file} \
    ${gold_xml} \
    ${predicted_xml} > "${results_file}"

tail -n1 "${results_file}"
