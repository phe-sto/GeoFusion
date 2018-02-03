#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# insert du fichier adresse in MongoDB adresse collection
__author__ = 'PapIT'
# lib système pour passage d'arguments
import sys
# import de la librairie csv
import csv
# pour le timestamp (ts) de la donnée
from datetime import datetime
# client mongodb
from pymongo import MongoClient

# connection au serveur mongodb
client = MongoClient('localhost', 27017)

# choix de la base mongodb GeoFusion
db = client.GeoFusion

# paquet de documents sous forme d'array
documents = []

adresse_file = open(sys.argv[1], 'r')
# lecture séquentielle du fchier adresse
adresses = csv.reader(adresse_file, delimiter=',', quotechar='"')

# traitement du fchier adresse
for row in adresses:
# documents à insérer en base mongo
# {num, voie, cp, commune, pays, location:{type, coordinates:[lon, lat]}, origin, ts}
    print(str(row))
    document = {'num': row[0],
    'voie':row[1],
    'cp': row[2],
    'commune':row[3],
    'pays': 'FRANCE',
    'location': {'type':'Point',
        'coordinates': [float(row[4]),float(row[5])]
        },
    'origin': 'GeoFusion.sh',
    'ts':datetime.now(),
    }
    documents.append(document)
        
    # si le taleau dépasse 100MBytes
    if sys.getsizeof(documents) > 10000000:
        # insert un par paquet
        db.adresse.insert_many(documents)
        documents = []

# fermeture du adresse_file
adresse_file.close()

# si présence de document(s)
if documents == []:
    pass
else:
    # insert un par paquet
    db.adresse.insert_many(documents)

count = db.adresse.count()
print("{0} adresses en base".format(count))

# fin du programme sans errreur
sys.exit(0)