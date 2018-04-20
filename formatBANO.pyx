#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# mise en forme du BANO
__author__ = 'PapIT'
__email__ = "christophe.brun@papit.fr"
# import de la librairie csv
import csv
# lib système pour passage d'arguments
import sys

BANOin_file = open(sys.argv[1], 'r')
BANOout_file = open('BANOtmp1.tmp', 'a')
# lecture séquentielle du fchier adresse
adresses = csv.reader(BANOin_file, delimiter=',', quotechar='"')
# écriture avec quotes
writer = csv.writer(BANOout_file, delimiter=',', lineterminator='\n', quoting=csv.QUOTE_MINIMAL)

# traitement du fchier adresse
for row in adresses:
    line = []
    line.append(row[1].strip("0").upper())
    line.append(row[2].upper().replace("RU ", "RUE "))
    line.append('{num:^05}'.format(num=row[3].upper()))
    line.append(row[4].upper())
    line.append(row[7].upper())
    line.append(row[6].upper())
    writer.writerow(line)

# fermeture des BAN
BANOin_file.close()
BANOout_file.close()

# fin du programme sans errreur
sys.exit(0)
