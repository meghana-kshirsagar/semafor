#!/bin/bash

set -e # fail fast

echo
echo "step 4iii: Training."
echo "params: 1: lambda 2: batch-size"

source "$(dirname ${BASH_SOURCE[0]})/config.sh"


mkdir ${model_dir}/lambda_$1;
echo model dir: ${model_dir}/lambda_$1;
echo ${SCAN_DIR}
echo ${CLASSPATH}

${JAVA_HOME_BIN}/java -classpath ${CLASSPATH} -Xms15g -Xmx60g \
edu.cmu.cs.lti.ark.fn.parsing.TrainArgIdApp \
model:${model_dir}/lambda_$1/svm.argmodel.dat \
alphabetfile:${SCAN_DIR}/parser.conf.unlabeled \
localfeaturescache:${SCAN_DIR}/featurecache.jobj \
lambda:$1 \
numthreads:${num_threads} \
batch-size:$2 \
save-every-k-batches:400 \
num-models-to-save:60

#warm-start-model:${model_dir}/svm.argmodel.dat \

