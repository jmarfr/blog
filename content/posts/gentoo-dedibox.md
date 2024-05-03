+++
title = 'Installation de Gentoo sur Dedibox SC'
date = 2012-02-26T16:13:18+02:00
draft = false
+++

Me voila heureux possesseur d'une Dédibox SC. Mais la liste des OS disponibles dans la console d'installation ne me conviens pas du tout. J'ai donc décidé d'installer mon OS préféré, une gentoo.

## Etape 1: Booter en mode rescue

Cette étape permet d'avoir accès au système car de base le serveur est fourni dans OS.

## Etape 2: Préparer les partitions
Nous allons préparer les partitions afin d'installer le système. L'utilitaire fdisk est notre meilleur ami !

```bash
fdisk /dev/sda
```

Y créer 4 partitions :

| Partition | Taille | Type |
|-----------|--------|------|
| /boot     | 200Mo  | ext3 |
| /         | 20Go   | ext3 |
| swap      | 2Go    | ext3 |
| /home     | 125Go  | ext4 |

## Etape 3: Monter les partitions

```bash
mkdir /mnt/gentoo mount /dev/sda2 /mnt/gentoo
mkdir /mnt/gentoo/boot mount /dev/sda1 /mnt/gentoo/boot
mkdir /mnt/gentoo/home mount /dev/sda4 /mnt/gentoo/home 
```

## Etape 4: Démarrer l'installation stage3

A partir de maintenant, il faut suivre la documentation officielle Gentoo pour une installation stage3 : http://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=1&chap=5

Télécharger l'archive stage3 sur le mirroir officiel puis la décompresser

```bash
links http://www.gentoo.org/main/en/mirrors.xml md5sum -c stage3-i686-.tar.bz2.DIGESTS
tar xvjpf stage3-*.tar.bz2
```
Installer Portage
```bash
links http://www.gentoo.org/main/en/mirrors.xml md5sum -c portage-latest.tar.bz2.md5sum
tar xvjf /mnt/gentoo/portage-latest.tar.bz2 -C /mnt/gentoo/usr 
```

Configurer le fichier make.conf
```bash
## These settings were set by the catalyst build script that automatically 
## built this stage. # Please consult /usr/share/portage/config/make.conf.example for a more
## detailed example. #CFLAGS="-O2 -march=i686 -pipe" #CXXFLAGS="${CFLAGS}" CFLAGS="-march=i686 --param l1-cache-size=64 --param l1-cache-line-size=64 --param l2-cache-size=1024 -mmmx -msse -msse2 -msse3 -mssse3 -mcx16 -msahf -O2 -pipe -fomit-frame-pointer" CXXFLAGS="${CFLAGS}"
## WARNING: Changing your CHOST is not something that should be done lightly.
## Please consult http://www.gentoo.org/doc/en/change-chost.xml before changing. CHOST="i686-pc-linux-gnu" MAKEOPTS="-j2" GENTOO_MIRRORS="[url=ftp://ftp.free.fr/mirrors/ftp.gentoo.org/]ftp://ftp.free.fr/mirrors/ftp.gentoo.org/"[/url] SYNC="rsync://rsync2.fr.gentoo.org/gentoo-portage" ACCEPT_KEYWORDS="~x86" 
```

## Etape 5: Installer le système de base

Copier le fichier resolv.conf
```bash
cp -L /etc/resolv.conf /mnt/gentoo/etc 
```

Chrooter l'environnement
```bash
mount -t proc none /mnt/gentoo/proc
mount -o bind /dev /mnt/gentoo/dev
chroot /mnt/gentoo/ /bin/bash
env-update source /etc/profile export PS1="(chroot)$PS1" 
```

Mise à jour de l'arbre de portage
```bash
 emerge --sync 
```

Génération des locales
```bash
nano -w /etc/locale.gen #Dé-commenter les locales à utiliser locale-gen 
```

## Etape 6: Configuration du kernel

Configuration du fuseau horaire

```bash
cp /usr/share/zoneinfo/Europe/Paris /etc/localtime 
```

Installation des sources du kernel
```bash
emerge gentoo-sources 
```

Compilation du kernel
```bash
cd /usr/src/linux 
nano -w .config
make oldconfig
make
## tea time...
make modules_install
```

## Etape 7: Configuration du système
Création du fichier /etc/fstab
```bash
nano -w /etc/fstab
/dev/sda1 /boot ext3 noauto,noatime 1 2
/dev/sda2 / ext4 noatime 0 1
/dev/sda3 none swap sw 0 0
/dev/sda4 /home ext4 noatime 0 1
```

Configuration du réseau
```bash
echo 'hostname="sd-33642"' > /etc/conf.d/hostname
echo 'nis_domain_lo="dedibox.fr"' > /etc/conf.d/net 
echo 'config_eth0=("88.191.152.102 netmask 255.255.255.0 brd 88.191.152.255" "2a01:e0b:1:152:62eb:69ff:fe8f:18c8/64")' >> /etc/conf.d/net
echo 'routes_eth0=("default via 88.191.152.1")' >> /etc/conf.d/net
echo '127.0.0.1 sd-33642.dedibox.fr sd-33642 localhost' > /etc/hosts 
echo '::1 sd-33642.dedibox.fr sd-33642 localhost' >> /etc/hosts 
```

Configuration du mode passe root

```bash
passwd
```

Configuration de /etc/rc.conf. J'ai laissé ce fichier avec toutes les options de configuration par défaut

Configuration du clavier
```bash
## Use keymap to specify the default console keymap. There is a complete tree
## of keymaps in /usr/share/keymaps to choose from. keymap="fr"
## Should we first load the 'windowkeys' console keymap? Most x86 users will
## say "yes" here. Note that non-x86 users should leave it as "no".
## Loading this keymap will enable VT switching (like ALT+Left/Right)
## using the special windows keys on the linux console. windowkeys="YES"
## The maps to load for extended keyboards. Most users will leave this as is. extended_keymaps=""
##extended_keymaps="backspace keypad euro2" # Tell dumpkeys(1) to interpret character action codes to be
## from the specified character set.
## This only matters if you set unicode="yes" in /etc/rc.conf.
## For a list of valid sets, run `dumpkeys --help` dumpkeys_charset=""
## Some fonts map AltGr-E to the currency symbol ¤ instead of the Euro �~B�
## To fix this, set to "yes" fix_euro="yes" 
```

Configuration de l'horloge

Ajouter clock="local" dans le fichier /etc/conf.d/hwclock

## Etape 8: Installation des outils essentiels au système

Installation d'un logger

```bash
emerge -av syslog-ng 
rc-update add syslog-ng default 
```

Mise en place du démon CRON
```bash
emerge -av vixie-cron 
rc-update add vixie-cron default
```

Indexation du système
```bash
emerge -av mlocate 
```

Ajout de SSH au démarrage du automatique du système

```bash
rc-update add sshd default 
```

## Etape 9: Installation du bootloader

Installation de Grub
```bash
emerge -av grub
```

Mise en place de grub sur le MBR
```bash
grep -v rootfs /proc/mounts > /etc/mtab grub-install --no-floppy /dev/sda 
```