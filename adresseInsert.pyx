#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# insert de fichier csv dans une base mongo
# parse de l'argument filtre
import argparse
# import de la librairie csv
import csv
# lib système pour passage d'arguments
import sys
# pour le timestamp (ts) de la donnée
from datetime import datetime

# client mongodb
from pymongo import MongoClient


# insert du fichier adresse in MongoDB adresse collection
def insertion(db, documents):
    """
    Insert un paquet de document dans la base mongo

    :param db: la base dans laquelle insérer
    :param documents: les documents à insérer sous formede JSON array
    :return: une liste vide et l'indice à zéro
    """
    # insert un par paquet
    db.adresse.insert_many(documents)
    count = db.adresse.count()
    print("{0} adresses en base à {1}".format(count, datetime.now()))
    return []


def document(row):
    """
    Créé un dictionnaire avec une line d'un csv

    :param row: line du cvs
    :return: un document sous forme de dictionnaire
    """
    document = {'num': row[0],
                'voie': row[1],
                'cp': row[2],
                'commune': row[3],
                'pays': 'FRANCE',
                'location': {'type': 'Point',
                             'coordinates': [float(row[4]), float(row[5])]
                             },
                'origin': 'GeoFusion.sh',
                'ts': datetime.now(),
                }
    return document


__author__ = 'PapIT'
__email__ = "christophe.brun@papit.fr"

# gestion des arguments
parser = argparse.ArgumentParser(
    description="Filtre sur le code postal avec une d'expression régulière")
parser.add_argument('-f', '--file', type=str,
                    help='fichier à insérer', required=True)
parser.add_argument('-cp', '--code_postal', type=str, help='Expression régulière sur le code postal avec quote',
                    required=False)

args = parser.parse_args()
filter_argument = args.code_postal
# absence d'argument
if filter_argument is None:
    pass
# si argument
else:
    import re

# connection au serveur mongodb
client = MongoClient('localhost', 27017)

# choix de la base mongodb GeoFusion
db = client.GeoFusion

# paquet de documents sous forme d'array
documents = []

# ouverture du fichire adresse
adresse_file = open(args.file, 'r')

# lecture séquentielle du fchier adresse
adresses = csv.reader(adresse_file, delimiter=',', quotechar='"')

# traitement du fchier adresse
for row in adresses:
    # absence d'argument filtre
    if filter_argument is None:
        documents.append(document(row))
    # argument filtre doit fullmatcher
    else:
        match_filter = re.fullmatch(filter_argument, row[2])
        if match_filter is None:
            pass
        else:
            documents.append(document(row))
    # si le taleau est à un million d'adresses
    if len(documents) == 1000000:
        documents = insertion(db, documents)

# fermeture du adresse_file
adresse_file.close()

# si présence de document(s)
if documents == []:
    pass
else:
    documents = insertion(db, documents)

# fin du programme sans erreur
sys.exit(0)
