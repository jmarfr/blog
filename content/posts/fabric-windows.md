+++
title = 'Utilisation de Fabric sous Windows'
date = 2013-11-24T14:20:00+02:00
draft = false
+++

## Prérequis

Une version fonctionnelle de [python](https://www.jmar.fr/posts/python-windows). L'installation de Fabric nécessite pycrypto qui est assez compliqué à compiler.

J'ai donc préféré chercher des binaires précompilés sur le net [pycrypto-2.3.1.win7x64-py2.7x64.7z](http://archive.warshaft.com/pycrypto-2.3.1.win7x64-py2.7x64.7z).

Décompresser l'archive à la racine du **virtualenv** utilisé pour Fabric.

## Installation de Fabric

`pip install fabric`