+++
title = 'Mise en place de firewalld'
date = 2015-04-26T14:13:00+02:00
draft = false
+++

## Introduction

FirewallD est une surcouche à Iptables installée par défaut sur RedHat 7 et CentOS 7. Contrairement aux anciens modèles de parefeux (system-config-firewall/lokkit), chaque changement nécessitait un redémarrage complet du parefeu.
FirewallD récupère les informations sur les règle parefeu active via D-BUS et réalise les changement dynamiquement via celui-ci en utilisant les méthodes d'authentification de PolicyKit.
FirewallD permet aussi entre autre de créer différentes zones et d'y appliquer des règles différentes.

## Pour commencer

On commence par mettre en place la zone par défaut. Personnellement, j'utilise la zone "public" qui par défaut passe tous les flux à DROP.

```bash
firewall-cmd --set-default-zone=public
```
 
On rend la configuration permanente :

```bash
firewall-cmd --permanent --set-default-zone=public
```
 
Puis on autorise le service SSH

```bash
 firewall-cmd --zone=public --add-service ssh firewall-cmd --permanent --zone=public --add-service ssh
```
 
## Création d'un service perso

La création d'un service perso, permets de se faciliter la vie. J'ai eu besoin d'ouvrir des ports particuliers pour laisser passer mon client torrent.
J'ai donc créer un service transmission.

Les configurations personnelles se trouvent dans **/etc/firewalld/services**. J'y ai donc créé le fichier **transmission.xml**

```xml
<!--?xml version="1.0" encoding="utf-8"?--> 
      <service>
         <short>Transmission</short>
         <description> Transmission Daemon Service</description>
         <port protocol="udp" port="51413">
            <port protocol="tcp" port="51413"> </port>
         </port>
      </service>
```

Le fichier est découpé de la façon suivante :

* La définition du fichier XML
* Ouverture de la définition du service
* Description courte du service (qui apparait dans la liste des services)
* Description complète du service
* Liste des ports à ouvrir. Une ligne par port avec protocol=, port=

## Activation du service

Pour commencer on charge le service :

```bash 
firewall-cmd --permanent --add-service=transmission --zone=public
```

Et on recharge le firewall:

```bash
firewall-cmd --reload
```
