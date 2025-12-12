import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/municipio.dart'; //Importamos el modelo

class MunicipiosData {
  //LISTA COMPLETA DE LOS 21 MUNICIPIOS DE GRAN CANARIA
  static final List<Municipio> listaInicial = [
    Municipio(
      nombre: "Agaete",
      poblacion: 5593,
      superficie: "45,50",
      festivo: "5 de agosto",
      patron: "Nuestra Señora de las Nieves",
      coordenadas: const GeoPoint(28.1017, -15.7088),
    ),
    Municipio(
      nombre: "Aguimes",
      poblacion: 32797,
      superficie: "79,28",
      festivo: "7 de octubre",
      patron: "Nuestra Señora del Rosario",
      coordenadas: const GeoPoint(27.9050, -15.4458),
    ),
    Municipio(
      nombre: "Artenara",
      poblacion: 1036,
      superficie: "66,70",
      festivo: "15 de agosto",
      patron: "Nuestra Señora de la Cuevita",
      coordenadas: const GeoPoint(28.0200, -15.6460),
    ),
    Municipio(
      nombre: "Arucas",
      poblacion: 38655,
      superficie: "33,01",
      festivo: "24 de junio",
      patron: "San Juan Bautista",
      coordenadas: const GeoPoint(28.1192, -15.5208),
    ),
    Municipio(
      nombre: "Firgas",
      poblacion: 7701,
      superficie: "15,77",
      festivo: "16 de agosto",
      patron: "San Roque",
      coordenadas: const GeoPoint(28.1060, -15.5630),
    ),
    Municipio(
      nombre: "Galdar",
      poblacion: 24728,
      superficie: "61,59",
      festivo: "25 de julio",
      patron: "Santiago de los Caballeros",
      coordenadas: const GeoPoint(28.1439, -15.6503),
    ),
    Municipio(
      nombre: "Ingenio",
      poblacion: 32356,
      superficie: "38,15",
      festivo: "2 de febrero",
      patron: "Nuestra Señora de la Candelaria",
      coordenadas: const GeoPoint(27.9208, -15.4319),
    ),
    Municipio(
      nombre: "La Aldea de San Nicolás",
      poblacion: 7523,
      superficie: "123,58",
      festivo: "10 de septiembre",
      patron: "San Nicolás de Tolentino",
      coordenadas: const GeoPoint(27.9825, -15.7797),
    ),
    Municipio(
      nombre: "Las Palmas de Gran Canaria",
      poblacion: 380863,
      superficie: "100,55",
      festivo: "13 de junio",
      patron: "Santa Ana",
      coordenadas: const GeoPoint(28.1248, -15.4300),
    ),
    Municipio(
      nombre: "Mogan",
      poblacion: 20938,
      superficie: "172,44",
      festivo: "13 de junio",
      patron: "San Antonio de Padua",
      coordenadas: const GeoPoint(27.8833, -15.7167),
    ),
    Municipio(
      nombre: "Moya",
      poblacion: 7887,
      superficie: "31,87",
      festivo: "2 de febrero",
      patron: "Nuestra Señora de la Candelaria",
      coordenadas: const GeoPoint(28.1106, -15.5831),
    ),
    Municipio(
      nombre: "San Bartolomé de Tirajana",
      poblacion: 54668,
      superficie: "333,13",
      festivo: "24 de agosto",
      patron: "San Bartolomé Apóstol",
      coordenadas: const GeoPoint(27.9258, -15.5736),
    ),
    Municipio(
      nombre: "Santa Brígida",
      poblacion: 18598,
      superficie: "23,81",
      festivo: "23 de julio",
      patron: "Santa Brígida de Suecia",
      coordenadas: const GeoPoint(28.0333, -15.5000),
    ),
    Municipio(
      nombre: "Santa Lucía de Tirajana",
      poblacion: 76418,
      superficie: "61,56",
      festivo: "13 de diciembre",
      patron: "Santa Lucía de Siracusa",
      coordenadas: const GeoPoint(27.9117, -15.5408),
    ),
    Municipio(
      nombre: "Santa María de Guía de Gran Canaria",
      poblacion: 13971,
      superficie: "42,59",
      festivo: "15 de agosto",
      patron: "Nuestra Señora de Guía",
      coordenadas: const GeoPoint(28.1389, -15.6044),
    ),
    Municipio(
      nombre: "Tejeda",
      poblacion: 1846,
      superficie: "103,30",
      festivo: "8 de septiembre",
      patron: "Nuestra Señora del Socorro",
      coordenadas: const GeoPoint(27.9972, -15.6139),
    ),
    Municipio(
      nombre: "Telde",
      poblacion: 103240,
      superficie: "102,43",
      festivo: "24 de junio",
      patron: "San Juan Bautista",
      coordenadas: const GeoPoint(28.0000, -15.4167),
    ),
    Municipio(
      nombre: "Teror",
      poblacion: 12831,
      superficie: "25,70",
      festivo: "8 de septiembre",
      patron: "Nuestra Señora del Pino",
      coordenadas: const GeoPoint(28.0589, -15.5475),
    ),
    Municipio(
      nombre: "Valleseco",
      poblacion: 3766,
      superficie: "22,11",
      festivo: "5 de abril",
      patron: "San Vicente Ferrer",
      coordenadas: const GeoPoint(28.0500, -15.5667),
    ),
    Municipio(
      nombre: "Valsequillo de Gran Canaria",
      poblacion: 9693,
      superficie: "39,15",
      festivo: "29 de septiembre",
      patron: "San Miguel Arcángel",
      coordenadas: const GeoPoint(27.9808, -15.4989),
    ),
    Municipio(
      nombre: "Vega de San Mateo",
      poblacion: 7785,
      superficie: "37,89",
      festivo: "21 de septiembre",
      patron: "San Mateo Apóstol",
      coordenadas: const GeoPoint(28.0089, -15.5308),
    ),
  ];

  //FUNCION PARA SUBIR DATOS
  //Al ser estática, podemos llamarla sin hacer 'new MunicipiosData()'
  static Future<void> subirDatosMasivos(BuildContext context) async {
    //Feedback visual
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Iniciando carga masiva...")));

    final db = FirebaseFirestore.instance;

    //Referencia con convertidor:
    final collectionRef = db
        .collection('municipios')
        .withConverter<Municipio>(
          fromFirestore: Municipio.fromFirestore,
          toFirestore: (Municipio m, _) => m.toFirestore(),
        );

    int contador = 0;

    //Bucle de subida
    for (var muni in listaInicial) {
      try {
        await collectionRef.doc(muni.nombre).set(muni);
        contador++;
        print("Subido: ${muni.nombre}");
      } catch (e) {
        print("Error en ${muni.nombre}: $e");
      }
    }

    //Mensaje de exito:
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("¡Éxito! Se actualizaron $contador municipios."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
