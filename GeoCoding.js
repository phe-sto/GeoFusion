// déclaration des modules nécessaire
var MongoClient = require('mongodb').MongoClient
// http pour la création du serveur et l'écoute du port 5001
var http = require('http');

// analyse de l'URL
var url = require('url');

// express
var express = require("express");
var app = express();

// connection à la db GeoFusion
var mongoDataBase = "mongodb://localhost:27017/GeoFusion";

// object résultat
var queryResult = {}
//create a server object:
app.get('/', function(req, res) {
  // header
  res.contentType = 'application/json';
  res.setHeader('Content-Type', 'application/json');

  // parsing de la query
  var q = url.parse(req.url, true).query;

  // Géodage ou reverseGéocodage
  // Géocodage
  // URL http://localhost:5001/?serv=geocod&voie=RUE%20HENRI%20IV&commune=PAU&limit=5 pour les tests
  if (q.serv == "geocod") {
    // mise en foorme des variables recherchée
    // numéro de batiment
    if (q.num) {
      var num = RegExp("^" + q.num.toUpperCase())
    } else {
      var num = new RegExp("^" + "")
    }

    // nom de voie
    if (q.voie) {
      var voie = new RegExp("^" + q.voie.toUpperCase())
    } else {
      var voie = new RegExp("^" + "R")
    }

    // nom de commune
    if (q.commune) {
      var commune = new RegExp("^" + q.commune.toUpperCase())
    } else {
      var commune = new RegExp("^" + "")
    }

    // cp
    if (q.cp) {
      var cp = new RegExp("^" + q.cp.toUpperCase())
    } else {
      var cp = new RegExp("^" + "")
    }

    // pays
    if (q.pays) {
      var pays = new RegExp("^" + q.pays.toUpperCase())
    } else {
      var pays = new RegExp("^" + "")
    }

    // limit
    if (q.limit) {
      var limit = Number(q.limit)
    } else {
      var limit = 5
    }

    MongoClient.connect(mongoDataBase, function(err, db) {
      // erreur à la connection
      if (err) res.send({
        "errorMessage": err
      });

      // passage de la requête
      db.collection("adresse").find({
        "num": num,
        "voie": voie,
        "commune": commune,
        "cp": cp,
        "pays": pays
      }).limit(limit).toArray(function(err, array) {
        // erreur lors du find
        if (err) res.send({
          "errorMessage": err
        });

        // fermeture de la base
        db.close();
        // passage du resultat
        res.send(array)
      });
    });
  }
  // reverse Geocodage
  // URL http://localhost:5001/?serv=rvrsgeo&lat=9&lon=42 pour les tests
  else if (q.serv == "rvrsgeo") {
    // latitude
    if (q.lat) {
      var lat = Number(q.lat)
    } else {
      var lat = 0
    }

    // longitude
    if (q.lon) {
      var lon = Number(q.lon)
    } else {
      var lon = 0
    }

    MongoClient.connect(mongoDataBase, function(err, db) {
      // erreur à la connection
      if (err) res.send({
        "errorMessage": err
      });
      // passage de la requête
      db.collection("adresse").findOne({
        location: {
          $geoNear: {
            $geometry: {
              "type": "Point",
              "coordinates": [lon, lat]
            }
          }
        }
      }, function(err, adresse) {
        // erreur lors du find
        if (err) res.send({
          "errorMessage": err
        });
        // fermeture de la base
        db.close();
        // passage de l'adresse
        res.send(adresse)
      });
    });
  }
  // service non reconnu
  else {
    res.send({
      "errorMessage": "Malformed request"
    });
  }

});
// the server object listens on port 5001
app.listen(5001);
