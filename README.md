# GeoFusion
Upload du BANO et du BAN en base mongo et API de gécodage et reverse géocodage.
Dédoublonnage avant insertion pour garder l'index unique et performance.
Dépendance avec Cython3, les libs de builds qui vont avec et Mongo pour la base, nodejs pour le serveur
de géocodage et reverse-géocodage.

## Exemple de requête de géocodage sur le serveur PapIT:
  Ne ramène que lorsqu'une adresse est trouvée.

  http://vps1.papit.fr:5001/?serv=geocod&commune=paris&limit=5&cp=75018

## Exemple de requête de reverse géocodage sur le serveur PapIT:
  Obtenu grâce à l'index 2d-sphere de mongo.

  http://vps1.papit.fr:5001/?serv=rvrsgeo&lat=9&lon=42
  
## Clone et installation
  > git clone https://github.com/phe-sto/GeoFusion.git
  
  > cd GeoFusion
  
  > npm install
  
## Chargement des adresses
  > sh GeoFusion.sh
  
## Démarrage du serveur de géocodage
  > nodejs GeoCoding.js

### Attention
   Présence d'un:
   > ``rm *.csv``
   
   Difficile à éviter car le BAN décompressé comprend un csv par département. Donc ne stocker pas les passphrases de vos
   wallets plein de crytpomachinchoses dans un csv dans le même dossier :rage4:
   
### Contact
   christophe.brun@papit.fr