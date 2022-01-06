# portal 관련 issue
## 1. smtp
- 이메일 계정 접속 > 아래의 url로 이동 > `보안 수준이 낮은 앱 허용: 사용` 설정
  - url :: https://www.google.com/settings/security/lesssecureapps

<br />

---

# AP portal VM Type 배포 script

## Prequisite
### 1. UAA client 설치
```shell
sudo gem install cf-uaac
uaac -v
```

<br />

### 2. portal-deployment git clone
```shell
git clone https://github.com/PaaS-TA/portal-deployment.git -b v5.2.3
```

<br />

---

## UI

### 1. 설정
```shell
# common_vars 내 ui 관련 항목 확인 및 수정
vim ~/workspace/common/common_vars.yml

# portal-ui 설정 파일 수정
vim ~/workspace/portal-deployment/portal-ui/vars.yml
```

<br />

### 2. 배포
```shell
# deploy shell 파일 수정 및 확인
vim ~/workspace/portal-deployment/portal-ui/deploy.sh

# 배포
cd ~/workspace/portal-deployment/portal-ui   
sh ./deploy.sh  

# 배포 완료 후 vm 확인
bosh -e micro-bosh -d portal-ui vms
```

<br />

### 3. Portal SSH 설치
```shell
# Portal 배포를 위한 조직 및 공간 생성 및 설정
cf create-quota portal_quota -m 20G -i -1 -s -1 -r -1 --reserved-route-ports -1 --allow-paid-service-plans
cf create-org portal -q portal_quota
cf create-space system -o portal
cf target -o portal -s system

# Portal SSH 다운로드 및 배포
cd ~/workspace/portal-deployment
wget --content-disposition https://nextcloud.paas-ta.org/index.php/s/awPjYDYCMiHY7yF/download
unzip portal-ssh.zip
cd portal-ssh
cf push
```

<br />

### 4. 사용자 조직 생성 Flag 활성화
```shell
cf enable-feature-flag user_org_creation
```

<br /><br />

## API
### 1. 설정
```shell
vim ~/workspace/portal-deployment/portal-api/vars.yml
```

### 2. 설치
```shell
# 배포 파일 수정 및 확인
vim ~/workspace/portal-deployment/portal-api/deploy.sh

cd ~/workspace/portal-deployment/portal-api 
sh ./deploy.sh 

# 설치 완료 후 vm 확인
bosh -e micro-bosh -d portal-api vms
```

<br />

---

## 공통
- url
  - user :: http://portal-web-user.52.78.153.22.nip.io
  - admin :: http://portal-web-admin.52.78.153.22.nip.io
- 계정 정보
  - id :: admin
  - pw :: admin