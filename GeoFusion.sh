#------------------------------------------------------------------------------------------------------------------------
# Mise en base mongodb GeoFusion du BAN et du BANO
# Author: Christophe Brun
# Société: PapIT
#------------------------------------------------------------------------------------------------------------------------
# début compteur de seconde(s)
STARTTIME=$(date +%s)
# pour trier des floating point à l'américaine avec des "."
export LC_NUMERIC=en_US.utf-8
echo "--------------------------------------------------------------------------------------"
echo "### Cythonization des sources"
echo "--------------------------------------------------------------------------------------"
#------------------------------------------------------------------------------------------------------------------------
# cythonization cython du source adresseInsert.pyx
cython3 --embed adresseInsert.pyx
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur de cythonization cython du source adresseInsert.pyx";
    exit $rc;
else
    echo "Cythonization cython3 réussie pour adresseInsert.pyx";
fi
#------------------------------------------------------------------------------------------------------------------------

echo "--------------------------------------------------------------------------------------"
echo "### Compilation du C"
echo "--------------------------------------------------------------------------------------"
#------------------------------------------------------------------------------------------------------------------------
# compilation C avec gcc du source C adresseInsert.c
gcc -Os -I /usr/include/python3.5m -o adresseInsert adresseInsert.c -lpython3.5m -lpthread -lm -lutil -ldl
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur de compilation de adresseInsert.c";
    exit $rc;
else
    echo "Compilation de adresseInsert.c réussie";
fi
# cythonization cython du source formatBAN.pyx
cython3 --embed formatBAN.pyx
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur de cythonization cython du source formatBAN.pyx";
    exit $rc;
else
    echo "Cythonization cython3 réussie pour formatBAN.pyx";
fi
#------------------------------------------------------------------------------------------------------------------------

echo "--------------------------------------------------------------------------------------"
echo "### Compilation du C"
echo "--------------------------------------------------------------------------------------"
#------------------------------------------------------------------------------------------------------------------------
# compilation C avec gcc du source C formatBAN.c
gcc -Os -I /usr/include/python3.5m -o formatBAN formatBAN.c -lpython3.5m -lpthread -lm -lutil -ldl
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur de compilation de formatBAN.c";
    exit $rc;
else
    echo "Compilation de formatBAN.c réussie";
fi
# cythonization cython du source formatBANO.pyx
cython3 --embed formatBANO.pyx
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur de cythonization cython du source formatBANO.pyx";
    exit $rc;
else
    echo "Cythonization cython3 réussie pour formatBANO.pyx";
fi
#------------------------------------------------------------------------------------------------------------------------

echo "--------------------------------------------------------------------------------------"
echo "### Compilation du C"
echo "--------------------------------------------------------------------------------------"
#------------------------------------------------------------------------------------------------------------------------
# compilation C avec gcc du source C formatBANO.c
gcc -Os -I /usr/include/python3.5m -o formatBANO formatBANO.c -lpython3.5m -lpthread -lm -lutil -ldl
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur de compilation de formatBANO.c";
    exit $rc;
else
    echo "Compilation de formatBANO.c réussie";
fi
echo "Suppression de fichiers"
rm *.csv

#------------------------------------------------------------------------------------------------------------------------
echo "--------------------------------------------------------------------------------------"
echo "### Téléchargement du BAN $(date)"
echo "--------------------------------------------------------------------------------------"
wget https://adresse.data.gouv.fr/data/BAN_licence_gratuite_repartage.zip
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur lors du téléchargement du BAN compressé";
    exit $rc;
else
    echo "Téléchargement du BAN compressé réussi";
fi

echo "--------------------------------------------------------------------------------------"
echo "### Décompression du BAN $(date)"
echo "--------------------------------------------------------------------------------------"
#------------------------------------------------------------------------------------------------------------------------
# décompression par unzip
unzip BAN_licence_gratuite_repartage.zip
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur de décompression par unzip du BAN";
    exit $rc;
else
    echo "Décompression par unzip réussie";
fi
echo "Suppression de fichiers"

rm BAN_licence_gratuite_repartage.zip
rm contenu.txt
rm BAN_Licence_de_repartage.pdf

echo "--------------------------------------------------------------------------------------"
echo "### Supression de la première ligne de chaque fichier  BAN $(date)"
echo "--------------------------------------------------------------------------------------"
#------------------------------------------------------------------------------------------------------------------------
# Supression de la première ligne du BAN
sed -i '1d' *.csv
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur lors de la supression de la première ligne d'un fichier BAN";
    exit $rc;
else
    echo "Supression de la première ligne d'un fichier BAN réussie";
fi

echo "--------------------------------------------------------------------------------------"
echo "### Merge des fichiers BAN $(date)"
echo "--------------------------------------------------------------------------------------"
#------------------------------------------------------------------------------------------------------------------------
# Merge des fichiers BAN
for i in `echo *.csv`; do     cat $i >>  BAN.csv; done
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur lors du merge des fichiers BAN";
    exit $rc;
else
    echo "Merge des fichiers BAN réussie";
fi
echo "Suppression de fichiers"
rm -f BAN_licence_gratuite_repartage*

#------------------------------------------------------------------------------------------------------------------------

echo "--------------------------------------------------------------------------------------"
echo "### Mise en forme du BAN $(date)"
echo "--------------------------------------------------------------------------------------"
#------------------------------------------------------------------------------------------------------------------------
# Mise en forme du BAN
./formatBAN BAN.csv
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur lors de la mise en forme du BAN";
    exit $rc;
else
    echo "Mise en forme du BAN réussie";
fi
echo "Suppression de fichiers"
rm -f BAN.csv

echo "--------------------------------------------------------------------------------------"
echo "### Téléchargement du BANO"
echo "--------------------------------------------------------------------------------------"

#------------------------------------------------------------------------------------------------------------------------
# Téléchargement du fichier compréssé
wget http://bano.openstreetmap.fr/data/full.csv.gz
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur lors du téléchargement du BANO compressé";
    exit $rc;
else
    echo "Téléchargement du BANO compressé réussi";
fi
#------------------------------------------------------------------------------------------------------------------------

echo "--------------------------------------------------------------------------------------"
echo "### Décompression du BANO"
echo "--------------------------------------------------------------------------------------"
#------------------------------------------------------------------------------------------------------------------------
# décompression par gzip
gzip -d full.csv.gz
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur de décompression par gzip du BANO";
    exit $rc;
else
    echo "Décompression par gzip réussie";
fi
#------------------------------------------------------------------------------------------------------------------------

echo "--------------------------------------------------------------------------------------"
echo "### Mise en forme du BANO $(date)"
echo "--------------------------------------------------------------------------------------"
#------------------------------------------------------------------------------------------------------------------------
# Formatage du BANO
./formatBANO full.csv
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur lors de la mise en forme du BANO";
    exit $rc;
else
    echo "Mise en forme du BANO réussie";
fi
echo "Suppression de fichiers"
rm -f full.csv

echo "--------------------------------------------------------------------------------------"
echo "### Merge des fichiers BAN et BANO $(date)"
echo "--------------------------------------------------------------------------------------"
#------------------------------------------------------------------------------------------------------------------------
# Merge des fichiers BAN et BANO
for i in `echo *.tmp`; do     cat $i >>  adresse.csv; done
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur lors du merge des fichiers BAN et BANO";
    exit $rc;
else
    echo "Merge des fichiers BAN et et BANO réussie";
fi
echo "Suppression de fichiers"
rm -f BANOtmp1.tmp
rm -f BANtmp1.tmp

echo "--------------------------------------------------------------------------------------"
echo "### Suppression des adresses en doublons $(date)"
echo "--------------------------------------------------------------------------------------"
#------------------------------------------------------------------------------------------------------------------------
# Suppression des adresses en doublons
sort -t, -nuk1,4 adresse.csv
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur lors de la supression des  doublons du fhcier adresse";
    exit $rc;
else
    echo "Suppression des doublons du fhcier adresse";
fi

echo "--------------------------------------------------------------------------------------"
echo "### Drop de la collection adresse et d'indexes de la mongodb GeoFusion"
echo "--------------------------------------------------------------------------------------"
#------------------------------------------------------------------------------------------------------------------------
# Drop de la collection adresse dans la base mongodb GeoFusion
mongo GeoFusion --eval "db.adresse.drop()"
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur du drop() de la collection adresse dans la mongodb GeoFusion";
    exit $rc;
else
    echo "Collection adresse de la mongodb GeoFusion effacée";
fi
#------------------------------------------------------------------------------------------------------------------------
# Drop de la collection adresse dans la base mongodb GeoFusion
mongo GeoFusion --eval "db.adresse.dropIndexes()"
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur du drop des indexes de la collection adresse dans la mongodb GeoFusion";
    exit $rc;
else
    echo "Drop des indexes de la collection adresse de la mongodb GeoFusion";
fi
#------------------------------------------------------------------------------------------------------------------------

echo "--------------------------------------------------------------------------------------"
echo "### Indexation de la base GeoFusion"
echo "--------------------------------------------------------------------------------------"
#------------------------------------------------------------------------------------------------------------------------
# Autorisation des textSearch
mongo GeoFusion --eval "db.adminCommand({setParameter:true,textSearchEnabled:true})"
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur de l'autorisation des textSearch";
    exit $rc;
else
    echo "Autorisation des textSearch";
fi
#------------------------------------------------------------------------------------------------------------------------
# Création de l'index unique sur tous les champs
mongo GeoFusion --eval "db.adresse.createIndex({'num' : 1, 'voie' : 1, 'cp': 1, 'commune' : 1, 'pays': 1},{unique:true})"
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur de l'indexation sur tous les champs";
    exit $rc;
else
    echo "Indexation unique sur tous les champs";
fi
#------------------------------------------------------------------------------------------------------------------------
# Création de l'index 2dsphere
mongo GeoFusion --eval "db.adresse.createIndex({'location': '2dsphere'})"
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur de la création d'index 2dsphere dans db.adresse (db:GeoFusion)";
    exit $rc;
else
    echo "Création d'index 2dsphere dans db.adresse réussie  (db:GeoFusion)";
fi
#------------------------------------------------------------------------------------------------------------------------
# création d'index num
mongo GeoFusion --eval "db.adresse.createIndex( { 'num' : 1 })"
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur de la création d'index sur num dans db.adresse (db:GeoFusion)";
    exit $rc;
else
    echo "Création d'index sur num dans db.adresse réussie  (db:GeoFusion)";
fi
#------------------------------------------------------------------------------------------------------------------------
# création d'index voie
mongo GeoFusion --eval "db.adresse.createIndex( { 'voie' : 1 })"
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur de la création d'index sur voie dans db.adresse (db:GeoFusion)";
    exit $rc;
else
    echo "Création d'index sur voie dans db.adresse réussie  (db:GeoFusion)";
fi
#------------------------------------------------------------------------------------------------------------------------
# création d'index cp
mongo GeoFusion --eval "db.adresse.createIndex( { 'cp' : 1 })"
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur de la création d'index sur cp dans db.adresse (db:GeoFusion)";
    exit $rc;
else
    echo "Création d'index sur cp dans db.adresse réussie  (db:GeoFusion)";
fi
#------------------------------------------------------------------------------------------------------------------------
# création d'index num, voie et commune
mongo GeoFusion --eval "db.adresse.createIndex( { 'commune' : 1 })"
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur de la création d'index sur commune dans db.adresse (db:GeoFusion)";
    exit $rc;
else
    echo "Création d'index sur commune dans db.adresse réussie  (db:GeoFusion)";
fi
#------------------------------------------------------------------------------------------------------------------------

echo "--------------------------------------------------------------------------------------"
echo "### Insertion du fichier adresse dans la base mongodb GeoFusion"
echo "--------------------------------------------------------------------------------------"
#------------------------------------------------------------------------------------------------------------------------
# Insertion du fichier adresse dans la base mongodb GeoFusion
if [ -s "adresse.csv" ]; then
    ./adresseInsert adresse.csv
    rc=$?; 
    if [ $rc != 0 ]; then 
        echo "Erreur pgm adresseInsert lors du traitement du fichier adresse";
        exit $rc;
    else
        echo "adresseInsert inséré le fichier adresse";
    fi
else
    echo "Fichier adresse.csv vide"
fi
#------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------
ENDTIME=$(date +%s)
# fin sans erreur et message
echo "--------------------------------------------------------------------------------------"
echo "Fin du script en $(($ENDTIME - $STARTTIME)) seconde(s)"
exit 0