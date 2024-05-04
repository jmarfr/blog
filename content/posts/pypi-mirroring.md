+++
title = 'Pypi Mirroring'
date = 2014-08-12T14:13:00+02:00
draft = false
+++

## Installation d'un mirroir Pypi local

$ROOTDIR = Répertoire de stockage du projet.

* Création d'un virtualenv pour héberger le projet

```bash
virtualenv pypimirror
```

* Installation de pypimirror

```bash
source pypimirror/bin/activate pip install pypimirror
```
 
Depuis la version 1.0.15, il est demandé d'installer BeautifulSoup en version <=3.0.9999 hors ces versions ne sont plus disponibles sur Pypi ... J'ai donc installé la 1.0.14.

```bash
cd $ROOTDIR/pypimirror
wget https://pypi.python.org/packages/source/z/z3c.pypimirror/z3c.pypimirror-1.0.14.tar.gz
tar xvzf z3c.pypimirror-1.0.14.tar.gz cd z3c.pypimirror-1.0.14 python setup.py install 

```

* Création du fichier de configuration. il existe un fichier d'exemple fourni avec avec pypimirror
```bash
cp $ROOTDIR/pypimirror/lib/python2.x/site-packages/pypimirror/pypimirror.cfg.sample $ROOTDIR/pypimirror/pypimirror.cfg 
```

* Voici les lignes que j'ai modifié pour mon usage perso :
```ini

--- pypimirror.cfg.sample       2014-08-12 11:54:04.000000000 +0200
+++ pypimirror.cfg              2014-08-12 11:54:29.380704186 +0200
@@ -1,10 +1,10 @@
[DEFAULT]
# the root folder of all mirrored packages.
# if necessary it will be created for you
-mirror_file_path = /tmp/mirror
+mirror_file_path = $ROOTDIR/data

# where's your mirror on the net?
-base_url = http://your-host.com/    +base_url = http://pypi.ks.jmar.fr/    
# lock file to avoid duplicate runs of the mirror script
lock_file_name = /tmp/pypi-poll-access.lock
@@ -23,8 +23,7 @@
# Pattern for package names; only packages having matching names will
# be mirrored
package_matches =
-    zope.*
-    plone.*
+    *

# remove packages not on pypi (or externals) anymore
cleanup = True

```

Premier lancement (nous sommes toujours dans le virtualenv)

```bash
$ROOTDIR/pypimirror/bin/pypimirror $ROOTDIR/pypimirror/pypimirror.cfg --initial-fetch
```

Mise en place de la tâche cron

```bash
0 8 * * * pypimirror $ROOTDIR/pypimirror/bin/pypimirror $ROOTDIR/pypimirror/pypimirror.cfg --update-fetch
```