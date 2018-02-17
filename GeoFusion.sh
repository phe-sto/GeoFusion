#------------------------------------------------------------------------------------------------------------------------
# Mise en base mongodb GeoFusion du BAN et du BANO
# Author: Christophe Brun
# Société: PapIT
#------------------------------------------------------------------------------------------------------------------------
# dépendance avec avec python pour la compilation du cython
MODULE_PYTHON=lpython3.5m
INCLUDE_PYTHON=/usr/include/python3.5
# création de l'argument éventuel pour adresseInsert 
if [ -n "$1" ]; then
    ARG_PREF='-cp '
    ARG_CP=$ARG_PREF$1
else
    ARG_CP=''
fi
# Fonction de compact and repair utilisé avant et après insertion
Repair(){
    echo "--------------------------------------------------------------------------------------"
    echo "### Compact et repair des données et de la base"
    echo "--------------------------------------------------------------------------------------"
    #------------------------------------------------------------------------------------------------------------------------
    # Compaction de la collection adresse
    mongo GeoFusion CompactRepair.js
    rc=$?; 
    if [ $rc != 0 ]; then 
        echo "Erreur de compact ou repair de la collection adresse (db:GeoFusion)";
        exit $rc;
    else
        echo "Compact ou repair de la collection adresse réussie (db:GeoFusion)";
    fi
}

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
gcc -Os -I $INCLUDE_PYTHON -o adresseInsert adresseInsert.c -$MODULE_PYTHON -lpthread -lm -lutil -ldl
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
gcc -Os -I $INCLUDE_PYTHON -o formatBAN formatBAN.c -$MODULE_PYTHON -lpthread -lm -lutil -ldl
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
gcc -Os -I $INCLUDE_PYTHON -o formatBANO formatBANO.c -$MODULE_PYTHON -lpthread -lm -lutil -ldl
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
for i in `echo *.tmp`; do     cat $i >>  adresseDup.csv; done
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
sort -t, -uk1,4 adresseDup.csv > adresse.csv
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur lors de la supression des  doublons du fhcier adresse";
    exit $rc;
else
    echo "Suppression des doublons du fhcier adresse";
fi
echo "Suppression de fichiers"
rm adresseDup.csv

echo "--------------------------------------------------------------------------------------"
echo "### Drop et création de la collection adresse et d'indexes de la mongodb GeoFusion"
echo "--------------------------------------------------------------------------------------"
#------------------------------------------------------------------------------------------------------------------------
# Drop et création de la collection adresse dans la base mongodb GeoFusion
mongo GeoFusion CreateCollection.js
rc=$?; 
if [ $rc != 0 ]; then 
    echo "Erreur du drop et création de la collection adresse dans la mongodb GeoFusion";
    exit $rc;
else
    echo "Collection adresse créée avec succès dans la mongodb GeoFusion";
fi
#------------------------------------------------------------------------------------------------------------------------

# avant insertion minise le filesize
Repair

echo "--------------------------------------------------------------------------------------"
echo "### Insertion du fichier adresse dans la base mongodb GeoFusion"
echo "--------------------------------------------------------------------------------------"
#------------------------------------------------------------------------------------------------------------------------
# Insertion du fichier adresse dans la base mongodb GeoFusion
if [ -s "adresse.csv" ]; then
    ./adresseInsert -f adresse.csv $ARG_CP
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
echo "Suppression de fichiers"
rm adresse.csv

# après insertion minise le filesize
Repair

#------------------------------------------------------------------------------------------------------------------------
ENDTIME=$(date +%s)
# fin sans erreur et message
echo "--------------------------------------------------------------------------------------"
echo "Fin du script en $(($ENDTIME - $STARTTIME)) seconde(s)"
exit 0