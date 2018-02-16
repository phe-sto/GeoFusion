// script de compaction er repair des données
// diminue le file size, à éxécuter avant et après les insertions
// compact
db.runCommand({compact: 'adresse' })
// repair
db.runCommand({repairDatabase: 1})