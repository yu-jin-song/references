## BOSH 배포 script

### 1. BOSH CLI 설치
```shell
mkdir -p ~/workspace
cd ~/workspace
sudo apt update
curl -Lo ./bosh https://github.com/cloudfoundry/bosh-cli/releases/download/v6.4.7/bosh-cli-6.4.7-linux-amd64
chmod +x ./bosh
sudo mv ./bosh /usr/local/bin/bosh
bosh -v
```

<br />

### 2. 설치 파일 다운로드
```shell
mkdir -p ~/workspace
cd ~/workspace
git clone https://github.com/PaaS-TA/paasta-deployment.git -b v5.6.6

cd ~/workspace/paasta-deployment
```

<br />

### 3. 설정
```shell
# AWS 환경에 BOSH 설치시 적용하는 변수 설정 파일, 수정 및 확인 필요
vim ~/workspace/paasta-deployment/bosh/aws-vars.yml

# AWS 환경에 BOSH 설치를 위한 Shell Script 파일, 확인 필요
vim ~/workspace/paasta-deployment/bosh/deploy-aws.sh

# 설치
cd ~/workspace/paasta-deployment/bosh
chmod +x ~/workspace/paasta-deployment/bosh/*.sh  
./deploy-aws.sh
```

<br />

### 4. BOSH 로그인
4-1. 수동
```shell
cd ~/workspace/paasta-deployment/bosh

export BOSH_CA_CERT=$(bosh int ./aws/creds.yml --path /director_ssl/ca)
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$(bosh int ./aws/creds.yml --path /admin_password)
bosh alias-env micro-bosh -e 10.0.1.6 --ca-cert <(bosh int ./aws/creds.yml --path /director_ssl/ca)
bosh -e micro-bosh env
```

4-2. shell 스크립트
```shell
vi ~/workspace/paasta-deployment/bosh/create-bosh-login.sh

-----

#!/bin/bash

BOSH_DEPLOYMENT_PATH="~/workspace/paasta-deployment/bosh" 	# (e.g. ~/workspace/paasta-deployment/bosh)
CURRENT_IAAS="aws"				# (e.g. aws/azure/gcp/openstack/vsphere/bosh-lite)
BOSH_IP="10.0.1.6"				# (e.g. 10.0.1.6)
BOSH_CLIENT_ADMIN_ID="admin"			# (e.g. admin)
BOSH_ENVIRONMENT="micro-bosh"			# (e.g. micro-bosh)
BOSH_LOGIN_FILE_PATH="/home/ubuntu/.env"	# (e.g. /home/ubuntu/.env)
BOSH_LOGIN_FILE_NAME="micro-bosh-login-env"	# (e.g. micro-bosh-login-env)

mkdir -p ${BOSH_LOGIN_FILE_PATH}
echo 'export CRED_PATH='${BOSH_DEPLOYMENT_PATH}'
export CURRENT_IAAS='${CURRENT_IAAS}'
export BOSH_CA_CERT=$(bosh int $CRED_PATH/$CURRENT_IAAS/creds.yml --path /director_ssl/ca)
export BOSH_CLIENT='${BOSH_CLIENT_ADMIN_ID}'
export BOSH_CLIENT_SECRET=$(bosh int $CRED_PATH/$CURRENT_IAAS/creds.yml --path /admin_password)
export BOSH_ENVIRONMENT='${BOSH_ENVIRONMENT}'


bosh alias-env $BOSH_ENVIRONMENT -e '${BOSH_IP}' --ca-cert <(bosh int $CRED_PATH/$CURRENT_IAAS/creds.yml --path /director_ssl/ca)

credhub login -s https://'${BOSH_IP}':8844 --skip-tls-validation --client-name=credhub-admin --client-secret=$(bosh int --path /credhub_admin_client_secret $CRED_PATH/$CURRENT_IAAS/creds.yml)


' > ${BOSH_LOGIN_FILE_PATH}/${BOSH_LOGIN_FILE_NAME}

-------------

cd ~/workspace/paasta-deployment/bosh
source create-bosh-login.sh

source /home/ubuntu/.env/micro-bosh-login-env
```

<br />

### 5. CredHub
1. CLI 설치
```shell
wget https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/2.9.0/credhub-linux-2.9.0.tgz
tar -xvf credhub-linux-2.9.0.tgz
chmod +x credhub
sudo mv credhub /usr/local/bin/credhub
credhub --version
```

2. 로그인
```shell
cd ~/workspace/paasta-deployment/bosh
export CREDHUB_CLIENT=credhub-admin
export CREDHUB_SECRET=$(bosh int --path /credhub_admin_client_secret aws/creds.yml)
export CREDHUB_CA_CERT=$(bosh int --path /credhub_tls/ca aws/creds.yml)
credhub login -s https://10.0.1.6:8844 --skip-tls-validation
```

<br />

### 6. Jumpbox
```shell
cd ~/workspace/paasta-deployment/bosh
bosh int aws/creds.yml --path /jumpbox_ssh/private_key > jumpbox.key
chmod 600 jumpbox.key
ssh jumpbox@10.0.1.6 -i jumpbox.key
```



