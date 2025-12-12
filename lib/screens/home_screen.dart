//Pantalla principal de la App

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import 'map_screen.dart';
import '../models/municipio.dart'; //Importamos el modelo 'municipio'
import 'table.dart'; //importamos la clase table

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //Instanciamos nuestro servicio (Repository)
  final FirebaseService _firebaseService = FirebaseService();

  //Estado para el municipio seleccionado en el Dropdown
  String? _municipioSeleccionado;

  //En vez de usar 'Map<String, dynamic>', usamos la clase 'Municipio'
  Municipio? _datosMunicipio;

  //INTERFAZ CON DROPDOWN Y NAVEGACION:

  void _cargarDatosMunicipio(String nombre) async {
    setState(() {
      _municipioSeleccionado = nombre;
      _datosMunicipio = null;
    });

    //El servicio ya nos devuelve un objeto Municipio (o null)
    Municipio? municipio = await _firebaseService.obtenerMunicipioPorId(nombre);

    if (municipio != null) {
      setState(() {
        _datosMunicipio = municipio;
      });
    }
  }

  void _irAlMapa() {
    if (_datosMunicipio != null) {
      //Accedemos a las propiedades
      GeoPoint ubicacion = _datosMunicipio!.coordenadas;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(
            nombreMunicipio: _datosMunicipio!.nombre, //Acceso directo
            latitud: ubicacion.latitude,
            longitud: ubicacion.longitude,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Municipios de GC'),
        actions: [
          //BOTÓN DE RESTAURAR DATOS (Llama a table.dart)
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Restaurar Datos',
            onPressed: () {
              //Diálogo de confirmación
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Restaurar Base de Datos"),
                  content: const Text(
                    "Se subirán los datos por defecto de 'table.dart' a Firebase.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Cerrar alerta

                        //AQUÍ LLAMAMOS A la CLASE EXTERNA
                        MunicipiosData.subirDatosMasivos(context);
                      },
                      child: const Text("Subir"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Municipio>>(
        stream: _firebaseService.obtenerMunicipios(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text('Error al cargar'));
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Dale a la nube para cargar datos iniciales.'),
            );
          }

          //Mapeo limpio usando objetos
          List<String> nombresMunicipios = snapshot.data!.docs
              .map((doc) => doc.data().nombre)
              .toList();

          if (_municipioSeleccionado == null && nombresMunicipios.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _cargarDatosMunicipio(nombresMunicipios.first);
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Selecciona un Municipio',
                    border: OutlineInputBorder(),
                  ),
                  value: _municipioSeleccionado,
                  items: nombresMunicipios
                      .map(
                        (nombre) => DropdownMenuItem(
                          value: nombre,
                          child: Text(nombre),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) _cargarDatosMunicipio(val);
                  },
                ),
                const SizedBox(height: 30),
                if (_datosMunicipio != null)
                  _buildDetailsCard(_datosMunicipio!)
                else if (_municipioSeleccionado != null)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        },
      ),
    );
  }

  //El widget recibe un 'Municipio', no un Map
  Widget _buildDetailsCard(Municipio data) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Text(
                data.nombre
                    .toUpperCase(), //Acceso con punto data.(campo) de la clase 'Municipio'
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const Divider(height: 20, thickness: 2),

            //Acceso a todas las propiedades
            _buildDetailRow('Habitantes', '${data.poblacion}'),
            _buildDetailRow('Superficie', '${data.superficie} km²'),
            _buildDetailRow('Patrón/Patrona', data.patron),
            _buildDetailRow('Día Festivo', data.festivo),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton.icon(
                onPressed: _irAlMapa,
                icon: const Icon(Icons.map, color: Colors.white),
                label: const Text(
                  'Ver en el Mapa',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
