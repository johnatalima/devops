# devops RD K8S clusters

## rd-prod-eks-cluster-app
### Namespace: drogaraia

Temos 6 deployments nesta namespace, são eles:
 - br-raia-server-api-drogaraia-prod-dp
 - nginx
 - nri-bundle-kube-state-metrics
 - nri-bundle-nri-kube-events
 - nri-bundle-nri-metadata-injection
 - nri-bundle-nri-prometheus


#### **br-raia-server-api-drogaraia-prod-dp** - deployment da API:

Os recursos solicitados por este deployment são 4CPU(max 5cpu) e 4Gb memoria(maximo 4Gb).

O deployment tem um HPA com minimo de 50 pods e maximo 100. O Target de CPU e memoria é 60%.

Total **minimo** de memoria e cpu solicitado por este deployment é de **200CPU** e **200Gb** memoria com um limite de 250CPU e 250Gb memoria. Dado o maxpod do HPA, o total de recursos do deployment maximo é o dobro.

No momento, apenas há 8 Pods com status "Ready" neste deployment, pois há falta de recursos(CPU).


#### **nginx** - Apenas um pod sem recursos configurados.


### Namespace: drogasil

Temos 2 deployments nesta namespace, são eles:
 - br-raia-server-api-drogasil-prod-dp
 - nginx

#### **br-raia-server-api-drogasil-prod-dp** - api server:

Os recursos solicitados por este deployment são 4CPU(max 5cpu) e 4Gb memoria(maximo 4Gb).

O deployment tem um HPA com minimo de 25 pods e maximo 100. O Target de CPU e memoria é 60%.

Total **minimo** de memoria e cpu solicitado por este deployment é de **100CPU** e **100Gb** memoria com um limite de 150CPU e 150Gb memoria. Dado o maxpod=100 do HPA, o total de recursos do deployment maximo é 4x.

No momento, apenas há 25 Pods com status "Ready" neste deployment, numero minimo configurado no HPA.


## Resumo

A quantidade de recursos configurados nos HPAs são maiores que a capacidade do cluster. Os Limits estão acima de 100%.
A quantidade de CPU solicitado para cada pod é muito mais do que o necessario. Mesmo não sendo usado, o k8s reserva os CPUs "request" para cada pod, por isso há pouco uso de CPU mas falta CPU para novos Pods.
Como o request é de 3CPU, cabe apenas 4 Pods da API em cada node. O node estão configurados com 16CPU, mas como não é utilizavel todos os 16, não consegue ter mais de 4 pod de API.
Ainda sobre o request, por estar reservando e não utilizando CPU, o Nós do cluster EKS não escalonam pois não atigem o minimo de utilização.


||Namespace|CPU MIN|Mem Min|CPU max|Mem Max|
|----|------|-------|-------|-------|-------|
||drogaraia|50 x 4 = 200|50 x 4 = 200 | 100 x 5 = 500| 100 x 4 = 400|
||drogasil|25 x 4 = 100|25 x 4 = 100 | 100 x 5 = 500| 100 x 4 = 400|
|Total|x|300|300|1000|800|

||Cluster CPU min|Cluster Mem Min | CLuster CPU max|Cluster Mem Max|
|---|--------|----------|------------|----------|
||11 x 16 = 176 | 11 x 32 = 352 | 20 x 16 = 320 | 20 x 32 = 640|
|Total|176|352|320|640|

### Utilização por nó:

|NAME|CPU(cores)|CPU%|MEMORY(bytes)|MEMORY%|
|------|------|-----|-----|----|
|ip-10-225-1-108.ec2.internal |  1450m | 9%  | 2408Mi| 8%|
|ip-10-225-1-137.ec2.internal |  1881m | 11% | 2162Mi| 7%|
|ip-10-225-1-5.ec2.internal   |  2148m | 13% | 2078Mi| 7%|
|ip-10-225-1-86.ec2.internal  |  1678m | 10% | 2257Mi| 7%|
|ip-10-225-3-127.ec2.internal |  1918m | 12% | 2100Mi| 7%|
|ip-10-225-3-138.ec2.internal |  1714m | 10% | 2105Mi| 7%|
|ip-10-225-3-197.ec2.internal |  2357m | 14% | 1988Mi| 6%|
|ip-10-225-3-28.ec2.internal  |  1117m | 7%  | 2945Mi| 10|%
|ip-10-225-7-170.ec2.internal |  1236m | 7%  | 2193Mi| 7%|
|ip-10-225-7-185.ec2.internal |  2882m | 18% | 2445Mi| 8%|
|ip-10-225-7-234.ec2.internal |  1216m | 7%  | 2558Mi| 9%|


Mesmo se o cluster fizer scale para o max de pod configurado no node group, não seria suficiente para fazer scale do maximo de pods configurados no HPA.

O pod que deveria fazer o autoscale do cluster não está running, está morrendo com por "OOMKilled", isso faz com que não tenhamos scaling do cluster:

```yaml
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       OOMKilled
      Exit Code:    137
//----------------------------------------
    Limits:
      cpu:     100m
      memory:  300Mi
    Requests:
      cpu:        100m
      memory:     300Mi
```

O Cluster tem apenas um node group.

**Obs**: Aviso na console "A versão do Kubernetes no cluster não é mais compatível com o Amazon EKS".

## Cluster: rd-eks-app-prod

### Namespace: drogasil

Temos 1 deployment nesta namespace:
 - br-raiadrogasil-server-api-drogasil-prod-dp

Os recursos solicitados por este deployment são 3CPU(max 4cpu) e 750Mi memoria(maximo 1200Mi). Isso faz com que os Pods reservem recursos do node, principalmente CPU e não utilizam. Exemplo abaixo:

O deployment tem um HPA com minimo de 6 pods e maximo 100. O Target de CPU é 65% memoria é 70%.

Total **minimo** de memoria e cpu solicitado por este deployment é de **18CPU** e **4500Mi** memoria, com um limite de 24CPU e 7200Mi memoria. Dado o maxpod=100 do HPA, o total de recursos do deployment maximo é de 300CPU e 75Gi de memoria.

No momento, apenas há 7 Pods com status "Ready" neste deployment, 1 a mais que o numero minimo configurado no HPA.

### Resumo

No cluster há alguns Jobs e CronJonbs com erros (Terminated Error Exit Code 134(SIGABORT)).

O pod de autoscale do cluster está running, então acredito que o autoscale do cluster está ok. Só precisamos confirmar se os min e max do cluster estão de acordo com o HPA. 

|NAME|CPU(cores)|CPU%|MEMORY(bytes)|MEMORY%|
|----|----------|----|-------------|-------|
|ip-10-225-161-167.ec2.internal |  281m |1%| 1938Mi| 6%|
|ip-10-225-164-71.ec2.internal  |  170m |1%| 2622Mi| 9%|
|ip-10-225-166-225.ec2.internal |  280m |1%| 1832Mi| 6%|
|ip-10-225-172-80.ec2.internal  |  179m |1%| 2225Mi| 7%|quand

Os auto scaling do deployment e do EKS não estão alinhados. O deployment do app drogasil conta com um auto scaling que em sua capacidade(recursos de CPU e Memoria) maxima, é maior do que a capacidade do cluster eks.

O auto scaling do app está acontecendo apenas por uso de memoria, mas reservando 3CPU por pod e não está utilizando. Isso faz com que os pods escalonem, até o limite dos nodes, mas os nodes não, pois não há utilização de CPU suficiente para o auto scaling. 


Ferramentas:
Gitlab CI
yarn gerenciador de pacotes https://yarnpkg.com/
fastlane https://docs.fastlane.tools/best-practices/continuous-integration/gitlab/


Ciclo de vida:
Não dar pra saber muito mas usam master e release, deduzo que usam gitflow (tem uma documentação falando disso)

Automação:

Há um job para staging e um para release em cada app. O deploy para staging acontece quando há commit para uma branch release.*. O job release acontece quando é feito merge para master.
Todos os jobs são executados manualmente

br-raia-app-hybrid-master
      usa o fastlane para fazer o deploy dos apps
      Jobs:
              android_staging_drogasil - branch release
              android_staging_drogaraia branch release
              android_release_drogasil
              android_release_drogaraia
              ios_staging_drogasil branch release
              ios_staging_drogaraia branch release
              ios_release_drogaraia ios_release_drogaraia

Gap:
Não há stage de testes.


Ferramentas:
Gitlab-ci
envsubst - ferramenta que substitui env vars para os arquivos
S3 - arquivo com secrets usuarios e senhas abertos
buildah - ferramenta para fazer build de images oci
kubectl - deploy dos manifestos k8s

Gap:
senhas exportas no repositorio e no s3.


ci-mage2/
  build.gitlab-ci.yml
