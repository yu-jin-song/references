#!/bin/bash
APP_NAME=<APP_NAME>
NAMESPACE_NAME=<NAMESPACE_NAME>
GREP_WORD=<GREP_WORD>
POD_NAME_LIST=$(kubectl get pod -n ${NAMESPACE_NAME} | grep "${GREP_WORD}" | cut -d ' ' -f1)

cf delete ${APP_NAME} -r -f

#echo "${POD_NAME_LIST[*]}"
for POD in ${POD_NAME_LIST[@]}
do
        kubectl get pod ${POD} -n ${NAMESPACE_NAME} -o yaml | kubectl replace --force -f-
done
