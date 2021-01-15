#!/bin/bash
#
#  Copyright 2021 HarveyTsang. All rights reserved.
#

SHELL_FOLDER=$(cd "$(dirname "$0")";pwd);
INPUT_FOLDER="${SHELL_FOLDER}/input" #待加固apk文件夹
REINFORCEED_APK_FOLDER="${SHELL_FOLDER}/reinforce" #临时存放加固apk文件夹
OUTPUT_FOLDER="${SHELL_FOLDER}/output" #加固并重签名后的apk文件夹
MS_SHIELD_JAR_PATH="${SHELL_FOLDER}/ms-shield.jar"
APKSIGNER_JAR_PATH="your apksigner.jar" #apksigner.jar路径
LEGU_SECRET_ID="your secretId" #腾讯乐固secretId
LEGU_SECRET_KEY="your secretKey" #腾讯乐固secretKey
KEYSTORE_PATH="your keystore file" #重签名用的.jks文件存放路径
ALIAS="your alias" #签名密钥别名
KS_PASSWORD="your keystore password" #密钥库密码
KEY_PASSWORD="your key password" #密钥密码
V1_SIGN_ENABLE=true #是否采用V1签名方案
V2_SIGN_ENABLE=true #是否采用V2签名方案
V3_SIGN_ENABLE=false #是否采用V3签名方案
V4_SIGN_ENABLE=false #是否采用V4签名方案

function exitWithMessage() {
	echo "-------------"
	echo "${1}"
	echo "-------------"
	exit ${2}
}

function resignAPK() {
	APK_PATH="$1"
	OUTPUT_NAME="$2"

	if [ ! -d "${OUTPUT_FOLDER}" ]; then
		mkdir "${OUTPUT_FOLDER}"
	fi

	# jarsigner -keystore "${KEYSTORE_PATH}" -signedjar "${OUTPUT_FOLDER}/${OUTPUT_NAME}" "${APK_PATH}" ${ALIAS}
	java -Dfile.encoding=utf-8 -jar "${APKSIGNER_JAR_PATH}" sign \
	--ks "${KEYSTORE_PATH}" \
	--ks-pass "pass:${KS_PASSWORD}" \
	--key-pass "pass:${KEY_PASSWORD}" \
	--v1-signing-enabled "${V1_SIGN_ENABLE}" \
	--v2-signing-enabled "${V2_SIGN_ENABLE}" \
	--v3-signing-enabled "${V3_SIGN_ENABLE}" \
	--v4-signing-enabled "${V4_SIGN_ENABLE}" \
	--out "${OUTPUT_FOLDER}/${OUTPUT_NAME}" \
	--verbose \
	"${APK_PATH}"

}

function reinforceSingle() {
	INPUT_APK="$1"

	if [ -d "${REINFORCEED_APK_FOLDER}" ]; then
		rm -rf "${REINFORCEED_APK_FOLDER}"
	fi

	java -Dfile.encoding=utf-8 -jar "${MS_SHIELD_JAR_PATH}" -sid "${LEGU_SECRET_ID}" -skey "${LEGU_SECRET_KEY}" -uploadPath "${INPUT_APK}" -downloadPath "${REINFORCEED_APK_FOLDER}"
	for file in $REINFORCEED_APK_FOLDER/*
	do
		if [ -f "${file}" ]; then
			resignAPK "${file}" "${INPUT_APK##*/}"
		fi
	done

	if [ -d "${REINFORCEED_APK_FOLDER}" ]; then
		rm -rf "${REINFORCEED_APK_FOLDER}"
	fi
}

if [ ! -f "${APKSIGNER_JAR_PATH}" ]; then
	exitWithMessage "apksigner.jar路径未填" 1
fi

if [ ! -f "${KEYSTORE_PATH}" ]; then
	exitWithMessage ".jks文件路径未填" 1
fi

if [ ! -d "${INPUT_FOLDER}" ]; then
	exitWithMessage "input文件夹不存在" 1
fi

if [ ! -d "${REINFORCEED_APK_FOLDER}" ]; then
	mkdir ${REINFORCEED_APK_FOLDER}
fi

if ! $V1_SIGN_ENABLE && ! $V2_SIGN_ENABLE && ! $V3_SIGN_ENABLE && ! $V4_SIGN_ENABLE; then
	exitWithMessage "签名方案不可全不选" 1
fi

APK_COUNT=0
for file in $INPUT_FOLDER/*
do
	if [ -f "${file}" ]; then
		EXT=$(echo $file | sed 's/^.*\.//')
		if [ "$EXT" == apk ]; then
			((APK_COUNT++))
			reinforceSingle "${file}"
		fi
	fi
done

if [ $APK_COUNT == 0 ]; then
	exitWithMessage "没有待加固apk文件" 1
fi