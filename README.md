# PLB_finalproject

Déploiment d'une application hébergée sur Git Hub https://github.com/ilkilab/Multi-Tier-App-Demo.git, déployée dans une infrastructure On Premise décrite dans un Document d'Architecture Technique.

La première étape consiste à déployer sur un provider du cloud (Azure ou AWS) cette infrastructure via Terraform. 

La seconde de déployer l'application sur cette infrastructure cloud via Ansible.

La troisième de conteneuriser l'applications dans Docker via la création d'images correspondant à chaque machine (APP, WEB et BDD).

Et enfin de poursuivre la conteneurisation via l'outil d'orchestration Kubernetes.
