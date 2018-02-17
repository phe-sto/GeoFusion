#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# mise en forme du BAN
__author__ = 'PapIT'
__email__ = "christophe.brun@papit.fr"
# import de la librairie csv
import csv
# lib système pour passage d'arguments
import sys

BANin_file = open(sys.argv[1], 'r')
BANout_file = open('BANtmp1.tmp', 'a')
# lecture séquentielle du fchier adresse
adresses = csv.reader(BANin_file, delimiter=';', quotechar='"')
# écriture avec quotes
writer = csv.writer(BANout_file, delimiter=',', lineterminator='\n', quoting=csv.QUOTE_MINIMAL)

# traitement du fchier adresse
for row in adresses:
    line = []
    if row[4] == '':
        num = row[3]
    else:
        num = '{0} {1}'.format(row[3], row[4])
    line.append(num.upper())
    line.append(row[1].upper().replace("RU ", "RUE "))
    line.append('{num:^05}'.format(num=row[6].upper()))
    line.append(row[15].upper())
    line.append(row[13].upper())
    line.append(row[14].upper())
    writer.writerow(line)

# fermeture des BAN
BANin_file.close()
BANout_file.close()

# fin du programme sans erreur
sys.exit(0)
