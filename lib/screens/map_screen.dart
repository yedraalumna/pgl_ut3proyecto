//Pantalla del mapa

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';  //El motor del mapa
import 'package:latlong2/latlong.dart';  //Para manejar coordenadas

//StatelessWidget: Como un Fragment estático. No cambia una vez se dibuja.
class MapScreen extends StatelessWidget {
  //Variables que recibimos de la pantalla anterior (Intent Extras)
  final String nombreMunicipio;
  final double latitud;
  final double longitud;

  //El constructor obliga a pasarle el nombre y las coordenadas al abrir esta pantalla
  const MapScreen({
    super.key,
    required this.nombreMunicipio,
    required this.latitud,
    required this.longitud,
  });

  @override
  Widget build(BuildContext context) {
    //Scaffold es el esqueleto básico visual (Barra superior, cuerpo, botón flotante...), igual que en kotlin
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de $nombreMunicipio'),
      ),

      //El cuerpo es el mapa:
      body: FlutterMap(
        options: MapOptions(
          //Centramos el mapa en las coordenadas que recibimos de la bd
          initialCenter: LatLng(latitud, longitud), 
          initialZoom: 13.0,  //Nivel de zoom inicial (13 es nivel ciudad/pueblo)
        ),
        children: [
          //Capa 1: Las imágenes del mapa (Tiles) de OpenStreetMap
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            //IMPORTANTE: Hay que cambiar esto por un ID único o se bloqueará el mapa
            userAgentPackageName: 'com.alumnadom.municipios_gc',
          ),
          
          //Capa 2: El marcador (Pin) rojo
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(latitud, longitud),
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_on,  //Icono de chincheta
                  color: Colors.red,
                  size: 50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}