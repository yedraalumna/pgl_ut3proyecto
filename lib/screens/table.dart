import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/municipio.dart';  //Importamos el modelo

class MunicipiosData {
  //LISTA DE DATOS:
  static final List<Municipio> listaInicial = [
    Municipio(
      nombre: "Las Palmas de Gran Canaria",
      poblacion: 381223,
      superficie: "100.55",
      patron: "San Antonio",
      festivo: "13 de junio",
      coordenadas: const GeoPoint(28.1248, -15.4300),
    ),
    Municipio(
      nombre: "Telde",
      poblacion: 102472,
      superficie: "102.43",
      patron: "San Juan Bautista",
      festivo: "24 de junio",
      coordenadas: const GeoPoint(28.0000, -15.4167),
    ),
    Municipio(
      nombre: "Santa Lucía de Tirajana",
      poblacion: 74263,
      superficie: "61.56",
      patron: "Santa Lucía",
      festivo: "13 de diciembre",
      coordenadas: const GeoPoint(27.9117, -15.5408),
    ),
    Municipio(
      nombre: "Arucas",
      poblacion: 38197,
      superficie: "33.01",
      patron: "San Juan Bautista",
      festivo: "24 de junio",
      coordenadas: const GeoPoint(28.1192, -15.5208),
    ),
    Municipio(
      nombre: "San Bartolomé de Tirajana",
      poblacion: 53643,
      superficie: "333.13",
      patron: "San Bartolomé",
      festivo: "24 de agosto",
      coordenadas: const GeoPoint(27.9258, -15.5736),
    ),
    Municipio(
      nombre: "Ingenio",
      poblacion: 31586,
      superficie: "38.15",
      patron: "Virgen del Buen Suceso",
      festivo: "24 de septiembre",
      coordenadas: const GeoPoint(27.9208, -15.4319),
    ),
    Municipio(
      nombre: "Agüimes",
      poblacion: 31379,
      superficie: "79.28",
      patron: "San Sebastián",
      festivo: "20 de enero",
      coordenadas: const GeoPoint(27.9050, -15.4458),
    ),
  ];

  //FUNCIÓN ESTÁTICA PARA SUBIR DATOS
  //Al ser estática, podemos llamarla sin hacer 'new MunicipiosData()'
  static Future<void> subirDatosMasivos(BuildContext context) async {
    //Feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Iniciando carga masiva...")),
    );

    final db = FirebaseFirestore.instance;
    
    //Referencia con convertidor:
    final collectionRef = db.collection('municipios').withConverter<Municipio>(
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

    //Mensaje de éxito:
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