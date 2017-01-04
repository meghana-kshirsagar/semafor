#!/bin/sh
SEMAFOR_HOME="/usr0/home/mkshirsa/research/transf_learn_semafor/semafor"
SEMAFOR_ADADELTA="/usr0/home/mkshirsa/research/transf_learn_semafor/semafor_adadelta"
SEMAFOR_OLD="/usr0/home/mkshirsa/research/transf_learn_semafor/semafor-semantic-parser-branch"

#CLASSPATH=".:${SEMAFOR_ADADELTA}/target/Semafor-3.0-alpha-05-srl-spansfeats.jar"
#CLASSPATH=".:${SEMAFOR_ADADELTA}/target/Semafor-3.0-alpha-05-adadelta-guides.jar"
CLASSPATH=".:${SEMAFOR_ADADELTA}/target/Semafor-3.0-alpha-05-adadelta.jar"
#CLASSPATH=".:${SEMAFOR_ADADELTA}/target/Semafor-3.0-alpha-05-adadelta-ancestor.jar"
#CLASSPATH=".:${SEMAFOR_ADADELTA}/target/Semafor-3.0-alpha-05-adadelta-siblings.jar"
#CLASSPATH=".:${SEMAFOR_ADADELTA}/target/Semafor-3.0-alpha-05-adadelta-frust-easy.jar"
CLASSPATH_OLD="${SEMAFOR_OLD}:${SEMAFOR_OLD}/lib/semafor-deps.jar"

JAVA_HOME_BIN="/usr/bin"

# the directory that contains framenet.frame.element.map and framenet.original.map
datadir="${SEMAFOR_HOME}/training/data"
#training_dir="${datadir}/lu_data"
#training_dir="${datadir}/frust_fn_and_lus"
training_dir="${datadir}/fn_with_lus"
#training_dir="${datadir}/naacl2012_splits/from_dipanjan"
#training_dir="${datadir}/naacl2012_splits/mstparsed_by_me"
#training_dir="${datadir}/semlinkmapping"
training_dir_old="${SEMAFOR_OLD}/data"

MALT_MODEL_DIR="${SEMAFOR_HOME}/training/models/semafor_malt_model_20121129"

# choose a name for the model to train
model_name="srl_fn_lus"
#model_name="fn_and_srl_spans_features"
#model_name="siblings"
#model_name="ancestors_level2"
#model_name="siblings_fn_lus"
#model_name="fn_with_lus"
#model_name="fn_with_lus_recall"
#model_name="ancestor_level2_fn_lus"
#model_name="semlink_only"
#model_name="lus_only"
#model_name="lus_guides"

# should set to roughly the number of cores available
num_threads=28
gc_threads=2

classpath="${CLASSPATH}"

# the directory the resulting model will end up in
model_dir="${SEMAFOR_ADADELTA}/training/models/${model_name}"

id_features="ancestor"

fn_id_req_data_file="${model_dir}/reqData.jobj"

# paths to the gold-standard annotated sentences, and dependency-parsed version of it
fe_file="${training_dir}/cv.train.sentences.frame.elements"
parsed_file="${training_dir}/cv.train.sentences.all.lemma.tags"
fe_file_length=`wc -l ${fe_file}`
fe_file_length=`expr ${fe_file_length% *}`

# path to store the alphabet we create:
alphabet_file="${model_dir}/alphabet.dat"

SCAN_DIR="${model_dir}/scan"
mkdir -p ${SCAN_DIR}

echo model_dir="${model_dir}"
