+++
title = 'Serveur Bind en master/slave'
date = 2012-06-02T14:13:00+02:00
draft = false
+++

## Installer bind
Installation de bind via l'outil de gestion de paquet du système: apt/yum/emerge

```bash
apt-get/yum install named
emerge -av bind
```

## Configuration du Master

* Génération de la clé de transfert entre NS1 et NS2
```bash
/usr/sbin/dnssec-keygen -a HMAC-MD5 -b 512 -r /dev/urandom -n HOST ns2
```

* Fichier /etc/named.conf
```bind
 options {

        directory "/var/cache/bind";

     

        // If there is a firewall between you and nameservers you want

        // to talk to, you may need to fix the firewall to allow multiple

        // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

     

        // If your ISP provided one or more IP addresses for stable

        // nameservers, you probably want to use them as forwarders.

        // Uncomment the following block, and insert the addresses replacing

        // the all-0\'s placeholder.

     

        // forwarders {

        //     0.0.0.0;

        // };

     

        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
        dnssec-enable yes;

        // Le transfert se fait ici par une clé présente sur les deux serveurs.
        allow-transfer { key ns1-ns2; };

        // Si la zone n'existe pas sur le DNS, alors on forward vers cette adresse.
        forwarders { 10.0.0.1; }; 
        forward first;
    };

     // Définition de la clé.

    key "ns1-ns2" {
        algorithm hmac-md5;
        secret "---Coller la clé générée plus haut---";
    };

    include /etc/bind/zones.conf;
    include /etc/bind/rndc.key;
```

* Fichier /etc/bind/zones.conf
```bind
    zone "jmar.fr" {
        type master;
        file "/etc/bind/zones/jmar.fr"; 
    };
```

* Fichier /etc/bind/zones/jmar.fr
```bind
   $TTL 3D
  
    @  IN  SOA ns1.jmar.fr. hostmaster.linux.lan. (
        199802154       ; serial, todays date + todays serial 
        8H              ; refresh, seconds
        2H              ; retry, seconds
        4W              ; expire, seconds
        1D )            ; minimum, seconds

        TXT     "Linux.LAN, serving YOUR domain :)"
        NS      ns1             ; Inet Address of name server
        NS      ns2
        MX      10 mail        ; Primary Mail Exchanger

    A    88.191.152.102 ; Primary IP
    localhost    A    127.0.0.1
    ns1          A    10.0.0.145
    ns2          A    10.0.0.109
    ns           A    10.0.0.145
    ns           A    10.0.0.109
    www          A    10.0.0.1
```

## Configuration du Slave

Comme pour le master, il faut installer bind via l'outil de package disponible sur le système (apt / yum / emerge ...)

```bind
//Options générales

options {

    directory "/var/cache/bind";  

    // If there is a firewall between you and nameservers you want
    // to talk to, you may need to fix the firewall to allow multiple
    // ports to talk.  See http://www.kb.cert.org/vuls/id/800113


    // If your ISP provided one or more IP addresses for stable
    // nameservers, you probably want to use them as forwarders.
    // Uncomment the following block, and insert the addresses replacing
    // the all-0\'s placeholder.

    auth-nxdomain no;    # conform to RFC1035
    listen-on-v6 { any; };
    dnssec-enable yes;
};

 

key "ns1-ns2" {

        algorithm hmac-md5;
        secret "---Coller ici la clé générée sur NS1---";
};

 
// On définie la clé à utiliser pour communiquer avec le master.
server 10.0.0.145 { 
    keys { ns1-ns2; };
};

// On définie qui peut utiliser RNDC (ici localhost et le master) 
// avec la clé rndc.key. La clé doit être identique à celle de NS1.
controls {
    inet * allow { 127.0.0.1; 10.0.0.145; } keys { "rndc-key"; };
};

include /etc/bind/zones.conf
include /etc/bind/rndc.conf

```

* /etc/bind/zones.conf
```bind
zone "jmar.fr" {
    //Zone esclave
    type slave;
    
    //emplacement du fichier de zone. Ne pas toucher aux fichiers
    file "/etc/bind/zones/slave_jmar.fr"; 
    
    // Addresse du master
    masters { 10.0.0.145; }; 
    
    // Autorise le serveur master à mettre à jour la zone.
    allow-notify { 10.0.0.145; }; 
    };
```

### Dernière étape

Configurer **ntpd** pour que les deux serveurs soient à la même heure