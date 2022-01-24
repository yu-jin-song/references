```
bosh -d portal-container-infra -n deld; bosh -d paasta -n deld; bosh clean-up --all -n && ./delete-deploy-aws.sh && rm aws/creds.yml && rm -rf ~/.bosh/ && rm -rf ~/.credhub/ && rm -rf ~/.cf && rm ~/.uaac.yml
```
