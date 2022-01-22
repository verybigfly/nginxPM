<p align="center">
	<img src="https://nginxproxymanager.com/github.png">
</p>

# Script D'Installation de Nginx Proxy Manager Avec Restriction Geoip

## Prérequis

- Avoir un Compte sur : [Maxmind Geoip Inscription](https://www.maxmind.com/en/geolite2/signup)
- Avoir un "Account ID" et une "License Key" pour Geoip Update 3.1.1 ou plus récent obtensible ici : [Maxmind Geoip License Key](https://www.maxmind.com/en/accounts/current/license-key)
- Avoir Docker d'installer : [Guide D'Installaation Docker](https://docs.docker.com/engine/install/)
- Avoir Docker Compose d'installer (Ne fonctionne pas avec la V2) : [Guide D'Installaation Docker Compose](https://docs.docker.com/compose/install/)

## Installation

- Toutes les Commandes Sont a Executer en Root ou Avec Votre Utilisateur Docker
- Allez Dans le Dossier ou Vous Souhaitez Installer NPM
- Telechargez le Script D'Installation Sur le Serveur
```bash
wget https://raw.githubusercontent.com/verybigfly/nginxPM-Custom/master/install.sh
```
- Rendez le Executable
```bash
chmod +x install.sh
```
- Executez une Première Fois le Script
```bash
./install.sh
```
- Modifiez les Lignes "GEOIPUPDATE_ACCOUNT_ID" et "GEOIPUPDATE_EDITION_IDS" dans le docker-compose.yml par les Valeurs Corespondante
```bash
nano docker-compose.yml
```
- Relancez le Script
```bash
./install.sh
```
- A la Fin du Script il Faudra Attendre la Fin de la Compilation, Vous Pourrez la Suivre Avec la Commande
```bash
docker logs nginxPM
```
- N'Oubliez pas D'Ajoutez Cette Dans la Configuration Avancé de Chaque host En Remplaçant $HOSTID% Par L'ID ou le Nom de L'Host
```conf
access_log /data/logs/proxy-host-%HOSTID%_access-geo.log proxy_geo;
```



Merci au Site DomoPi Pour le Tutoriel D'installation de Base : https://domopi.eu/ajouter-la-geoip-a-nginx-proxy-manager/
