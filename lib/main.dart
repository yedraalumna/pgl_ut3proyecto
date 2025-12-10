import 'package:flutter/material.dart';
//Nucleo del firebase:
import 'package:firebase_core/firebase_core.dart';
//Archivo de config generado por el firebase:
import 'firebase_options.dart';
//Pantalla principal:
import 'screens/home_screen.dart';

void main() async {
  //Asegura que el motor gráfico esté listo antes de llamar a código nativo
  WidgetsFlutterBinding.ensureInitialized();

  //Inicializamos Firebase
  //Usamos 'DefaultFirebaseOptions' para que sepa automáticamente si es Android o Web
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //Una vez conectado todo, arrancamos la App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Municipios GC',
      debugShowCheckedModeBanner: false, //Quita la etiqueta roja "Debug"
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      home: const HomeScreen(), //Llamamos a la pantalla principal
    );
  }
}
