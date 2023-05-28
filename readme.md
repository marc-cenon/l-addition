Test L'Addition
============================

## Sujet
Installation sur un cluster minikube de mariadb + wordpress avec terraform et le provider helm.
Temps limite de 3h.

### Organisation du dépôt git
> Structure du projet

	├── manifests				# contient les yamls pour wordpress et mariadb
	│  ├── mariadb
	│  │  ├── configmap.yml
	│  │  ├── deployment.yml
	│  │  ├── namespace.yml
	│  │  ├── secrets.yml
	│  │  └── service.yml
	│  └── wordpress
	│     ├── configmap.yml
	│     ├── deployment.yml
	│     ├── namespace.yml
	│     ├── secrets.yml
	│     └── service.yml
	├── mariadb-wordpress-helm		# Chart Helm construite à partir des manifests ci-dessus
	│  ├── Chart.yaml
	│  ├── charts
	│  ├── templates
	│  │  ├── mariadb-configmap.yml
	│  │  ├── mariadb-deployment.yml
	│  │  ├── mariadb-namespace.yml
	│  │  ├── mariadb-secrets.yml
	│  │  ├── mariadb-service.yml
	│  │  ├── wordpress-configmap.yml
	│  │  ├── wordpress-deployment.yml
	│  │  ├── wordpress-namespace.yml
	│  │  ├── wordpress-secrets.yml
	│  │  └── wordpress-service.yml
	│  └── values.yaml			# fichier values utilisé pour paramétrer l'installation de la Chart Helm
	├── readme.md				# informations sur ce projet
	├── setup.sh				# script shell pour configurer une vm sous Ubuntu avec tous les outils nécessaires
	├── terraform				# contient le code terraform
	   ├── mariadb-wordpress-helm.tf			
	   ├── providers.tf

## Prérequis
- avoir les outils suivants:

```sh
- minikube
- docker
- terraform
- kubectl
- helm

```

- le script shell setup.sh est disponible pour installer les outils ci-dessus sur un OS Ubuntu
- s'assurer que le le chemin du fichier kubeconfig est bien renseigné pour le provider Helm. 

### Versions
Les versions peuvent être modifiées dans le fichier values.yaml de la Chart Helm.
- utilisation de wordpress:php8.2
- utilisation de mariadb:10.6


### Choix techniques
- création d'une Chart Helm à partir de manifests crées dans un premier temps pour tester le fonctionnement des différentes applications
- utilisation du provider Helm dans terraform pour installer wordpress et mariadb
- utilisation et configuration des ressources CPU et Memoire pour mariadb et wordpress. Comme ces applications seront installé sur un poste en local sur minikube avec un seul node, j'ai paramétré les ressources CPU et Mémoire de la façon suivante :
```sh
#mariadb
ressource:
    limit:
      cpu: "1"
      mem: "1Gi"
    requests:
      cpu: "500m"
      mem: "512Mi"

#wordpress
  ressource:
    limit:
      cpu: "1"
      mem: "1Gi"
    requests:
      cpu: "0.5"
      mem: "512Mi"
```
- la persistance des données est assurée par l'utilisation de volumes hostPath et elles se trouvent sur la VM MINIKUBE, accessible depuis un terminal avec les commandes :

```sh
minikube ssh
cd /data
ls
```

### Installation
- s'assurer de disposer des droits / outils / prérequis nécessaires
- démarrer minikube avec la commande:
```sh
minikube start
```

- se déplacer dans le dossier terraform et utiliser les commandes suivantes :

```
terraform init	# initialisation du backend terraform et du provider helm
terraform plan	# visualisation du plan d'execution de terraform
terraform apply	# application du plan d'execution de terraform
```
- on peura détruire et reconstruire l'environnement avec la commande :
```sh
terraform destroy
```

### Vérifications
- l'url de connexion à wordpress est disponible avec la commande :

```sh
minikube service list | grep wordpress
```

A la première connexion sur le wordpress, il faudra configurer l'instance en renseignant les differents éléments sur la page de configuration.
On pourra également vérifier que la Chart Helm est correctement installée avec la commande suivante :

```sh
helm list
```

### Répartition approximative de mon temps:
- 10min pour créer une VM sur Proxmox
- 15min pour créer le script setup.sh
- 40min pour créer les manifests mariadb et wordpress et les tester sur le cluster
- 1h pour créer la Chart Helm à partir des manifests et tester la Chart Helm sur le cluster
- 20min pour créer le code Terraform avec le provider Helm et tester la solution
- 30min pour la création du dépot git et de la doc



### Améliorations à apporter
- configuration du HPA - Horizontal Pod Autoscaler pour anticiper la charge.
- utilisation d'un operator kubernetes Mariadb pour installer Mariadb. Cela permettra de facilement configurer un cluster Mariadb en HA avec réplication, backup et monitoring.
- utiliser une approche GitOps avec un outil comme ArgoCD pour déployer les applicatifs sur minikube depuis un dépôt git.
- les secrets sont en clair dans le fichier de values de la Chart Helm. Il conviendra de les stocker dans un Vault ou AWS Secret Manager, et de les injecter dans la Chart Helm.
- Worpress est accessible via un service de type NodePort, il faudra sécuriser l'accès via un ingress + Certificats TLS pour plus de sécurité et implémenter ces modifications dans la Chart Helm
- création d'une sonde liveness probe dans kubernetes pour surveiller que les applications tournent correctement
- possibilité d'utiliser une Chart Helm existante comme celle de bitnami qui apporte de nombreuses fonctions et paramétrages comme :
	- réplication mariadb
	- memcached pour mettre en cache les requêtes
	- création d'ingress
	- gestion des metrics
	- meilleure configuration de wordpress (paramétrage auto, option multisites, HA, ...) 
