+++
title = 'Python sous Windows'
date = 2013-11-24T14:13:00+02:00
draft = false
+++

## Installation
Pour commencer télécharger l'installeur python2.7 sur le site officiel [http://python.org/ftp/python/2.7.4/python-2.7.4.msi](http://python.org/ftp/python/2.7.4/python-2.7.4.msi)

### Mise en place de setuptool et pip

Afin de faciliter l'installation des paquets python, il faut installer setuptool et pip.
Pour ce faire, la documentation officiel python propose deux scripts qui font tout le travail. ez_setup.py et get-pip.py 
Une fois les deux scripts téléchargés, il suffit de les lancer `.\ez_setup.py .\get-pip.py` 

Ajouter les entrées suivantes dans le PATH Windows : C:\Python27\;C:\Python27\Scripts\

### Installation de virtualenv
J'ai pour habitude d'utiliser les virtualenvs afin de ne pas polluer mon installation python par des modules en tous genres que je teste. `pip install virtualenv` 

## Création d'un environnement virtuel
```bash
cd mon\repertoire\de\scripting 
virtualenv monenvironnemnet 
monenvironnement\Scripts\activate 
```