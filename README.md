# README

[![Release](https://img.shields.io/docker/v/jcpd/dknr-zwave?sort=semver)](https://img.shields.io/docker/v/jcpd/dknr-zwave?sort=semver)
[![Pull](https://img.shields.io/docker/pulls/jcpd/dknr-zwave)](https://img.shields.io/docker/pulls/jcpd/dknr-zwave)
[![Issue](https://img.shields.io/github/issues/jcdenis/dknr-zwave)](https://img.shields.io/github/issues/jcdenis/dknr-zwave)
[![License](https://img.shields.io/github/license/jcdenis/dknr-zwave)](https://github.com/JcDenis/dknr-zwave/blob/master/LICENSE)


## A propos

**dknr-zwave** est un projet consacré au pilotage, à la récupération et à l'exploitation des données des appareils Z-Wave en local. Ce projet s'appuie sur [Z-Wave JS UI](https://github.com/zwave-js/zwave-js-ui), qui gère le contrôleur et le réseau Z-Wave, et reprend ses nœuds dans la même arborescence MQTT que les autres projets DKNR.


## Fonctionnalités

- **Tous les appareils supportés par Z-Wave JS** : prises, interrupteurs, variateurs, capteurs, serrures, télécommandes...
- **Entités construites automatiquement** à partir des valeurs de chaque nœud : valeurs numériques, états, listes de choix, textes, boutons. La valeur courante et la valeur cible d'une commande (ex : état et consigne d'un interrupteur) forment une seule entité.
- **Identifiant stable** : un appareil est identifié par son numéro de nœud, le renommer ou le déplacer dans Z-Wave JS UI ne change ni ses topics ni ses entités Home Assistant.
- **Pilotage** de toutes les valeurs modifiables, y compris les paramètres de configuration.
- **Réseau** : état de la passerelle et du contrôleur, liste des nœuds (batterie, dernière activité, état), inclusion et exclusion, renommage, emplacement et suppression d'un nœud défaillant.
- **Support Home-Assistant Discovery** en lecture et pilotage (capteurs, interrupteurs, nombres, sélecteurs, textes, boutons). Les paramètres de configuration sont créés désactivés et les entités d'un nœud mort deviennent indisponibles.


## Matériel requis

Le matériel exact dépend de l'installation, mais l'utilisation du projet nécessite généralement :

* un contrôleur Z-Wave (clé USB) compatible Z-Wave JS.
* un serveur MQTT, utilisé à la fois par Z-Wave JS UI et par ce projet.
* une machine exécutant le logiciel docker.


## Installation

Des images Docker prêtes à l'emploi sont disponibles.
Le fichier docker-compose.yaml à la racine du dépôt lance **Z-Wave JS UI** et **DKNR Z-Wave**. Fournissez les variables d'environnement suivantes :

* **DKNR_USERNAME** : login de l'interface node-red.
* **DKNR_PASSWORD** : mot de passe de l'interface node-red.
* **DKNR_SECRET**   : un mot secret pour encrypter les credits.

Adaptez si besoin le port série du contrôleur Z-Wave (`/dev/ttyACM0`).

Le tableau de bord DKNR est disponible sur `http://<ip du serveur docker>/`, l'éditeur Node-RED sur `http://<ip du serveur docker>/admin` et l'interface de Z-Wave JS UI sur `http://<ip du serveur docker>:1880/`.


## Configuration

### Z-Wave JS UI

Dans **Settings** de Z-Wave JS UI :

* **MQTT** : renseignez le serveur MQTT (**Host url** avec l'adresse IP réelle du serveur, **Port**). L'option **Disable Gateway** doit rester décochée. Notez le **Prefix** (`zwave` par défaut). Laissez **Retain** activé pour que l'état de la passerelle soit retrouvé au démarrage.
* **Gateway** : activez **Send Z-Wave Events** pour que les changements de valeurs et d'état des nœuds soient transmis immédiatement. Sans cette option, choisissez **Payload type : Entire ValueId Object** ; à défaut, les valeurs ne sont relues que toutes les 5 minutes.

Le websocket de Z-Wave JS (port 3000) reste disponible pour l'intégration Z-Wave JS de Home Assistant. Si vous l'utilisez, chaque appareil apparaîtra deux fois dans Home Assistant : laissez alors vide le topic de discovery Home Assistant de DKNR Z-Wave, ou n'utilisez que l'une des deux.

### MQTT

Dans la page **Configurer** :

* **Adresse IP**, **port**, **utilisateur** et **mot de passe** du serveur MQTT, le même que celui de Z-Wave JS UI.
* **Topic** : racine des topics DKNR (`dknr` par défaut).
* **Z-Wave JS UI topic** : le **Prefix** MQTT de Z-Wave JS UI (`zwave` par défaut).
* **Home Assistant Discovery topic** : laissez vide pour ne pas publier la discovery Home Assistant.

La passerelle Z-Wave JS UI est trouvée automatiquement grâce à son topic `<prefix>/_CLIENTS/ZWAVE_GATEWAY-<nom>/status`.

### Inclure un appareil

Dans la page **Réseau**, cliquez sur **Inclure** puis mettez l'appareil en mode inclusion. Pour un appareil sécurisé S2 (serrure, alarme...), faites l'inclusion depuis l'interface de Z-Wave JS UI, qui demande le code DSK de l'appareil.


## MQTT

Avec le topic `dknr` par défaut, l'identifiant d'un appareil est son numéro de nœud (ex : `5`) et le nom d'une entité est `<command class>_<endpoint>_<propriété>[_<clé>]` (ex : `37_0_currentValue`, `49_0_Air_temperature`, `50_0_value_65537`) :

* `dknr/get/zwave/<nœud>/<entité>` : valeurs publiées (retenues, sauf scènes et notifications) à chaque changement. Les états binaires valent `ON` ou `OFF`, les listes de choix leur libellé.
* `dknr/set/zwave/<nœud>/<entité>` : commande, `ON`, `OFF` ou `TOGGLE` pour un état binaire, un nombre, un libellé (ou sa valeur) pour une liste de choix.
* `dknr/discovery/zwave/<nœud>/<entité>` : description des entités.
* `homeassistant/<type>/zwave/<nœud>_<entité>/config` : Home Assistant Discovery.

Chaque nœud a aussi les entités `status` (Vivant, Endormi, Réveillé, Mort) et `lastActive` (dernière activité).

La passerelle Z-Wave JS UI est publiée comme un appareil d'identifiant `controller` : `state` (en ligne), `inclusion` et `exclusion` (pilotables) et `version`.

Les command classes de gestion du protocole (association, version, sécurité...) ne sont pas publiées.


## A faire

* Entités Home Assistant *light*, *cover*, *lock* et *climate* complètes (les fonctions sont aujourd'hui publiées séparément).
* Valeurs de durée et de couleur.
* Groupes multicast de Z-Wave JS UI.


## Contribuer

Ce projet est **open-source**, vous pouvez participer en créant des [tickets](https://github.com/JcDenis/dknr-zwave/issues) ou en proposant de [requêtes](https://github.com/JcDenis/dknr-zwave/pulls) sur le dépôt github du projet.


## Voir aussi

- [DKNR Teleinfo](https://github.com/JcDenis/dknr-teleinfo)
- [DKNR APSystems](https://github.com/JcDenis/dknr-apsystems)
- [DKNR Daikin](https://github.com/JcDenis/dknr-daikin)
- [DKNR Zendure](https://github.com/JcDenis/dknr-zendure)
- [DKNR RFXCom](https://github.com/JcDenis/dknr-rfxcom)
- [DKNR Nuki](https://github.com/JcDenis/dknr-nuki)
- [DKNR Zigbee](https://github.com/JcDenis/dknr-zigbee)
- [Z-Wave JS UI : MQTT](https://zwave-js.github.io/zwave-js-ui/#/guide/mqtt)
