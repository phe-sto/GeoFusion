// script de création de la collection adresse
// liste des collection dans la base
var collections = db.runCommand({ listCollections: 1 })
var collectionExist = false
var i = collections.cursor.length;

while (i--) {
    // si la collection adresse existe
    if (collections.cursor[i].name == 'adresse') {
        collectionExist = true
    }
}

// mais si elle n'éxista pas la cré
if (!collectionExist) {
    db.createCollection('adresse')
}
// purge
db.adresse.drop()
// autorisation du textSearch pour le score
db.adminCommand({ setParameter: true, textSearchEnabled: true })
// création des indexes
// évite les doublons
db.adresse.createIndex({ 'num': 1, 'voie': 1, 'cp': 1, 'commune': 1, 'pays': 1 }, { unique: true })
// pour repérer les adresses dans l'espace
db.adresse.createIndex({ 'location': '2dsphere' })
// indexes par champs recherché
db.adresse.createIndex({ 'num': 1 })
db.adresse.createIndex({ 'voie': 1 })
db.adresse.createIndex({ 'cp': 1 })
db.adresse.createIndex({ 'commune': 1 })