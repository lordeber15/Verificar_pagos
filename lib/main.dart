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
  List<String> segmentContent(String content) {
    // Puedes personalizar esto según el formato de los mensajes de Yape
    return content.split('\n');
  }

  @override
  Widget build(BuildContext context) {
    SMSController smsController = Get.put(SMSController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(widget.title),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Obx(
            () => ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    smsController.hasPermission.value
                        ? Colors.green
                        : Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () {
                smsController.requestForPermission();

                final snackBar = SnackBar(
                  content: Text(
                    smsController.hasPermission.value
                        ? '✅ Permiso concedido'
                        : '❌ Permiso denegado o no otorgado',
                  ),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor:
                      smsController.hasPermission.value
                          ? Colors.green
                          : Colors.red,
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              icon: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  smsController.hasPermission.value
                      ? Icons.check_circle
                      : Icons.warning,
                  key: ValueKey<bool>(smsController.hasPermission.value),
                  size: 24,
                ),
              ),
              label: Text(
                smsController.hasPermission.value
                    ? "Permiso Concedido"
                    : "Solicitar Permiso",
              ),
            ),
          ),
          SizedBox(height: 20),
          Text("Todas las Notificaciones"),
          Obx(
            () => Column(
              children:
                  smsController.notificationList
                      .map(
                        (e) => Container(
                          color: Colors.deepPurple.withValues(alpha: 0.2),
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "App: ${e.packageName}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Divider(),
                              ...segmentContent(
                                e.content.toString(),
                              ).map((line) => Text(line)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(
        () => FloatingActionButton(
          backgroundColor:
              smsController.isListening.value ? Colors.red : Colors.green,
          onPressed: () {
            smsController.toggleListening();

            final snackBar = SnackBar(
              content: Text(
                smsController.isListening.value
                    ? '🟢 Captura de notificaciones activada'
                    : '🔴 Captura de notificaciones detenida',
              ),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor:
                  smsController.isListening.value ? Colors.green : Colors.red,
            );

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              smsController.isListening.value
                  ? Icons.notifications_off
                  : Icons.notifications_active,
              key: ValueKey<bool>(smsController.isListening.value),
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
