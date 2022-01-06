## AP core 배포 script

### 1. common vars clone
```shell
cd ~/workspace
git clone https://github.com/PaaS-TA/common.git
```

<br />

### 2. Stemcell
```shell
vi ~/workspace/paasta-deployment/bosh/upload-stemcell.sh

cd ~/workspace/paasta-deployment/bosh
source upload-stemcell.sh
```

<br />

### 3. Runtime Config
```shell
vi ~/workspace/paasta-deployment/bosh/update-runtime-config.sh

cd ~/workspace/paasta-deployment/bosh
source update-runtime-config.sh

bosh -e micro-bosh runtime-config
bosh -e micro-bosh runtime-config --name=os-conf
```

<br />

### 4. Cloud Config
```shell
bosh -e micro-bosh update-cloud-config ~/workspace/paasta-deployment/cloud-config/aws-cloud-config.yml
bosh -e micro-bosh cloud-config 
```

<br />

### 5. PaaS-TA core
```shell
# common_vars 및 vars 수정 전 아래 두 항목 확인 필요
## bosh client admin id
echo $(bosh int ~/workspace/paasta-deployment/bosh/aws/creds.yml --path /admin_password)
tg4jon5oy4nt8adaqm1h
## bosh 버전 확인
bosh env
271.11

# common_vars.yml 수정
vim ~/workspace/common/common_vars.yml

# vars.yml 수정
vim ~/workspace/paasta-deployment/paasta/vars.yml

# deploy 파일
vim ~/workspace/paasta-deployment/paasta/deploy-aws.sh
chmod +x ~/workspace/paasta-deployment/paasta/*.sh
cd ~/workspace/paasta-deployment/paasta
./deploy-aws.sh

# 설치 완료 후 vm 배포 상태 확인
bosh -e micro-bosh vms -d paasta
```

<br />

### 6. CF
1. CF CLI v7 설치 (PaaS-TA AP 5.1.0 이상)
```shell
wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
sudo apt update
sudo apt install cf7-cli -y
cf --version
```

2. cf 로그인
```shell
cf login -a https://api.52.78.8.142.nip.io --skip-ssl-validation
admin
admin
```

3. 계정 생성
```shell
cf create-user joy-user PaaS-TA@2022
cf create-org joy-org
cf orgs

cf create-space -o joy-org joy-space
cf target -o joy-org -s joy-space
cf spaces

cf set-org-role joy-user joy-org OrgManager
cf set-space-role joy-user joy-org joy-space SpaceDeveloper
```

4. 샘플앱 테스트
```shell
cf push joy-spring-music ~/workspace/user/joy/sample_app/spring-music-war/spring-music.war
```