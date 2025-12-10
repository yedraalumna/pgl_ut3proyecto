import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/municipio.dart';  //Importamos la clase municipio

class FirebaseService {
  //Instancia de la base de datos:
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _colName = "municipios";

  //Creamos una propiedad privada que ya tiene el convertidor configurado
  //En lugar de ser una 'CollectionReference<Map>', es una 'CollectionReference<Municipio>'
  //Esto es como tener un DAO en JAVA
  CollectionReference<Municipio> get _municipiosRef {
    return _db.collection(_colName).withConverter<Municipio>(
      fromFirestore: Municipio.fromFirestore,  //Le enseñamos a leer
      toFirestore: (Municipio m, _) => m.toFirestore(),  //Le enseñamos a escribir
    );
  }

  //READ: Obtener lista en Tiempo Real (Stream):
  //Devuelve un flujo de datos que YA contiene objetos Municipio
  //No hace falta hacer bucles for ni mapeos ya que Firebase lo hace solo
  Stream<QuerySnapshot<Municipio>> obtenerMunicipios() {
    return _municipiosRef
        .orderBy('nombre')  //Ordenamos alfabéticamente de la A a la Z
        .snapshots();  //Escuchamos cambios en tiempo real
  }

  //READ ONE: Obtener un solo municipio por su ID (nombre):
  Future<Municipio?> obtenerMunicipioPorId(String nombreDocumento) async {
    //Al usar '.doc(nombre).get()', obtenemos un 'DocumentSnapshot<Municipio>'
    final docSnap = await _municipiosRef.doc(nombreDocumento).get();
    
    //'.data()' devuelve el objeto 'Municipio' directamente, o null si no existe
    return docSnap.data(); 
  }
}