import 'package:flutter/material.dart';
import 'package:yape_listener/notificacionController.dart';
import "package:get/get.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Verificar Yapes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Notificaciones yape'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    SMSController smsController = Get.put(SMSController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,

        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          Center(),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              smsController.requestForPermission();
            },
            child: Text("Escuchar Notificaciones"),
          ),
          SizedBox(height: 20),
          Text("Todas las Notificaciones"),
          Obx(
            () => Column(
              children:
                  smsController.notificationList.value
                      .map(
                        (e) => Container(
                          color: Colors.deepPurple.withValues(alpha: 0.2),
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(5),
                          child: Column(
                            children: [
                              Row(children: [Text("Aplicacione x")]),
                              Row(children: [Text(e.content)]),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
