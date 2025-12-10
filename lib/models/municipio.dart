import 'package:cloud_firestore/cloud_firestore.dart';

class Municipio {
  final String nombre;
  final int poblacion;
  final String superficie;
  final String festivo;
  final String patron;
  final GeoPoint coordenadas;

  Municipio({
    required this.nombre,
    required this.poblacion,
    required this.superficie,
    required this.festivo,
    required this.patron,
    required this.coordenadas,
  });

  //METODO PARA LEER
  //Convierte lo que viene de la BD (snapshot) en un objeto 'Municipio'
  factory Municipio.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Municipio(
      nombre: data?['nombre'] ?? '',
      poblacion: data?['poblacion'] ?? 0,
      superficie: data?['superficie'] ?? '',
      festivo: data?['festivo'] ?? '',
      patron: data?['patron'] ?? '',
      coordenadas: data?['coordenadas'] ?? const GeoPoint(0, 0),
    );
  }

  //Convierte el objeto 'Municipio' en un Map para que Firebase lo entienda
  Map<String, dynamic> toFirestore() {
    return {
      "nombre": nombre,
      "poblacion": poblacion,
      "superficie": superficie,
      "festivo": festivo,
      "patron": patron,
      "coordenadas": coordenadas,
    };
  }
}
