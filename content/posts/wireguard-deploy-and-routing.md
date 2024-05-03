+++
title = 'Wireguard: Déploiement et routage'
date = 2021-08-24T14:13:00+02:00
draft = false
+++

## Installation

L'installation est très simple. Il y a beaucoup de sources disponibles sur internet. Perso j'ai suivi la doc de https://wiki.archlinux.org/title/WireGuard qui est très complète. L'installation et la connexion se révèle très simple et ne pose pas de problème particulier.

### Configuration serveur

```ini
[Interface]
ListenPort = 51871
PrivateKey = (hidden)
Address = 192.168.10.1/24, fdc9:281f:04d7:9ee9::1/64

[Peer]
PublicKey = oENZzrPBIl1fBguDPNAzTEzBZtXh/3i1DoEXTBOg7jI=
AllowedIPs = 192.168.10.2/32,fdc9:281f:04d7:9ee9::2/128
Endpoint = [2a01:cb05:83c2:5300:6665:4c49:6699:c6ea]:51871
```

 
### Configuration côté client

```ini
[Interface]
Address = 192.168.10.2/24, fdc9:281f:04d7:9ee9::2/64
ListenPort = 51871
PrivateKey = (hidden)

[Peer]
PublicKey = xOUJZ3xPKlZlXxpj7zOxK+7+5vT+Ey8iK38OnN/L8T0=
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = [2001:41d0:1:8c07::1]:51871
```

 
## Routage des clients

Pour router l'ensemble du trafic des clients à travers le vpn, il y a quelques configurations à faire. Tout d'abord dans wireguard, il faut configurer les adresses autorisées côté client.

```ini
AllowedIPs = 0.0.0.0/0, ::/0
``` 

Si vous oubliez cette partie, vous aurez des messages de type `ping: sendmsg: Required key not available` lorsque vous tenterez un ping vers une IP en dehors de votre réseau.

Pour cette partie, il est fortement recommandé d'utiliser le script wg-quick qui est inclus dans le paquet wireguard-tools. Ce script va prendre la configuration de votre interface dans /etc/wireguard/<interface>.conf pour créer l'interface réseau, lui associer les adresses IP que vous avez configurées et réaliser la partie la plus complexe qui est la création des règles de routage.

Ce script permet aussi de démarrer et arrêter simplement les tunnels.

## Gestion du firewalling côté serveur

Côté serveur j'utilise firewalld pour gérer mes règles de firewall en fonction de différentes zones. J'ai tout d'abord créé une zone dédiée à wireguard que j'ai attaché à mon interface wg0. L'ensemble des fluxs de cette interface sont autorisés.

```bash
firewall-cmd --new-zone=wireguard --permanent 
firewall-cmd --reload 
firewall-cmd --zone=wireguard --set-target ACCEPT --permanent 
firewall-cmd --zone=wireguard --change-interface=wg0 
firewall-cmd --reload
```

Mon serveur est maintenant accessible depuis le client via le tunnel

```bash
root@ARCH wireguard# ping 192.168.10.1 
PING 192.168.10.1 (192.168.10.1) 56(84) octets de données. 
64 octets de 192.168.10.1 : icmp_seq=1 ttl=64 temps=18.1 ms 
64 octets de 192.168.10.1 : icmp_seq=2 ttl=64 temps=17.7 ms 
64 octets de 192.168.10.1 : icmp_seq=3 ttl=64 temps=17.3 ms 
^C - statistiques ping 192.168.10.1 - 3 paquets transmis, 3 reçus, 0% packet loss, time 2003ms rtt min/avg/max/mdev = 17.258/17.676/18.085/0.337 ms

```

Par contre, je ne peux toujours pas accéder à internet à travers mon tunnel. Pour ce faire, il faut que j'active le masquerading (le SNAT automatique d'IPtables) à travers firewalld. Pour IPv4 pas de problème c'est supporté nativement dans firewalld et en plus il active automatiquement le forwarding d'ip.

```bash
firewall-cmd --zone=public --add-masquerade --permanent 
firewall-cmd --reload

```

Pour IPv6, il faut faire une "rich rule"

```bash
firewall-cmd add-rich-rule='rule family=ipv6 masquerade' --permanent
firewall-cmd --reload
```

et tadaaaaa notre client a maintenant accès à internet à travers wireguard en IPv4 et IPv6