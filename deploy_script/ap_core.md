# AP core 배포 script

### 1. common vars clone
```shell
cd ~/workspace/deployments
git clone https://github.com/PaaS-TA/common.git
```

<br />

### 2. Stemcell
```shell
vim ~/workspace/deployments/paasta-deployment-v5.7.0/bosh/upload-stemcell.sh

cd ~/workspace/deployments/paasta-deployment-v5.7.0/bosh
source upload-stemcell.sh
```

<br />

### 3. Runtime Config
```shell
vim ~/workspace/deployments/paasta-deployment-v5.7.0/bosh/update-runtime-config.sh

cd ~/workspace/deployments/paasta-deployment-v5.7.0/bosh
source update-runtime-config.sh

bosh -e micro-bosh runtime-config
bosh -e micro-bosh runtime-config --name=os-conf
```

<br />

### 4. Cloud Config
```shell
bosh -e micro-bosh update-cloud-config ~/workspace/deployments/paasta-deployment-v5.7.0/cloud-config/aws-cloud-config.yml
bosh -e micro-bosh cloud-config 
```

<br />

### 5. PaaS-TA core
```shell
# common_vars 및 vars 수정 전 아래 두 항목 확인 필요
## bosh client admin id
echo $(bosh int ~/workspace/deployments/paasta-deployment-v5.7.0/bosh/aws/creds.yml --path /admin_password)

## bosh 버전 확인
bosh env


# common_vars.yml 수정
vim ~/workspace/deployments/common/common_vars.yml

# vars.yml 수정
vim ~/workspace/deployments/paasta-deployment-v5.7.0/paasta/vars.yml

# deploy 파일
vim ~/workspace/deployments/paasta-deployment-v5.7.0/paasta/deploy-aws.sh
chmod +x ~/workspace/deployments/paasta-deployment-v5.7.0/paasta/*.sh
cd ~/workspace/deployments/paasta-deployment-v5.7.0/paasta
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
cf login -a https://api.xx.xx.xx.xx.nip.io --skip-ssl-validation
admin
admin
```

3. 계정 생성
```shell
cf create-user joy-user 비밀번호
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
# 샘플앱 배포
cf push joy-spring-music -p ~/workspace/user/joy/sample_app/spring-music-war/spring-music.war

# 확인
## 터미널
curl -k https://joy-spring-music.xx.xx.xx.xx.nip.io
## 웹브라우저
https://joy-spring-music.xx.xx.xx.xx.nip.io
```

<br />

### 7. common_vars.yml 수정
```shell
# nats password 확인
credhub get -n /micro-bosh/paasta/nats_password

# nats ip, database ip 확인
bosh vms

# common_vars 수정(nats password, nats ip, database ip)
vim ~/workspace/deployments/common/common_vars.yml
```
