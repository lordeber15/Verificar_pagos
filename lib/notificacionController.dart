import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class SMSController extends GetxController {
  RxList<ServiceNotificationEvent> notificationList =
      <ServiceNotificationEvent>[].obs;
  RxList<Map<String, dynamic>> apiNotificationList =
      <Map<String, dynamic>>[].obs;
  RxBool isListening = false.obs;
  RxBool hasPermission = false.obs;

  final String targetPackage = "com.bcp.innovacxion.yapeapp";
  final String apiUrl = "https://backend-verificador.onrender.com/notification";

  @override
  void onInit() {
    super.onInit();
    requestForPermission();
    listenNotification();
    getNotifications();
  }

  void requestForPermission() async {
    final bool status = await NotificationListenerService.isPermissionGranted();
    hasPermission.value = status;

    if (!status) {
      final bool granted =
          await NotificationListenerService.requestPermission();
      hasPermission.value = granted;
    }
  }

  // Inicia el servicio de primer plano para escuchar notificaciones
  void startForegroundService() async {
    await FlutterForegroundTask.startService(
      notificationTitle: 'Escuchando Notificaciones',
      notificationText:
          'Tu aplicación está escuchando mensajes en segundo plano.',
      callback: startBackgroundTask,
    );
  }

  // Función que será ejecutada en segundo plano (callback)
  void startBackgroundTask() {
    // Aquí manejas las notificaciones y cualquier otra lógica en segundo plano
    listenNotification();
  }

  // Método de escucha de notificaciones
  void listenNotification() async {
    if (isListening.value) {
      log("🔁 Ya se está escuchando notificaciones. No se reinicia.");
      return;
    }

    log("🔁 Se activó listenNotification");

    // Cambiar el estado a "escuchando"
    isListening.value = true;

    // Aquí ya comenzamos a escuchar las notificaciones en segundo plano
    NotificationListenerService.notificationsStream.listen((event) {
      log("📲 Recibida notificación de ${event.packageName}");

      if (event.packageName == targetPackage) {
        log("✅ Es de Yape, se va a procesar");

        final data = extractData("${event.content}");
        log("$data");
        if (data != null) {
          sendToApi(
            title: event.title,
            packageName: event.packageName,
            nombre: data['nombre'],
            monto: data['monto'],
            codigoseg: data['codigoseg'],
          );
        }
      }
    });
  }

  // Método para extraer los datos
  Map<String, String>? extractData(String content) {
    try {
      final nombreRegex = RegExp(r"^(.*?)\s+(?:te\s+envió|envió)");
      final montoRegex = RegExp(r"por S\/ ([\d.]+)");
      final codRegex = RegExp(r"codigo\s+de\s+seguridad\s+es: (\d+)");

      final nombre = nombreRegex.firstMatch(content)?.group(1)?.trim();
      final monto = montoRegex.firstMatch(content)?.group(1)?.trim();
      final codigoseg = codRegex.firstMatch(content)?.group(1)?.trim();

      if (nombre != null && monto != null || codigoseg == null) {
        return {
          'nombre': nombre.toString(),
          'monto': monto.toString(),
          'codigoseg': codigoseg.toString(),
        };
      }
    } catch (e) {
      log("Error extrayendo datos: $e");
    }
    return null;
  }

  // Método para enviar los datos al API
  Future<void> sendToApi({
    String? title,
    String? packageName,
    String? nombre,
    String? monto,
    String? codigoseg,
  }) async {
    try {
      int? codigosegInt;
      if (codigoseg != null) {
        codigosegInt = int.tryParse(codigoseg);
      }

      final dio = Dio();
      final response = await dio.post(
        apiUrl,
        data: {
          "title": title ?? "",
          "packageName": packageName ?? "",
          "nombre": nombre ?? "",
          "monto": monto ?? "",
          "codigoseg": codigosegInt ?? 0,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Enviado correctamente");
        await getNotifications();
      } else {
        log("❌ Error al enviar datos: ${response.statusCode}");
      }
    } catch (e) {
      log("❌ Excepción al enviar datos: $e");
    }
  }

  Future<void> getNotifications() async {
    try {
      final dio = Dio();
      final response = await dio.get(apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        apiNotificationList.value = data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      log("❌ Error al obtener notificaciones: $e");
    }
  }

  // Método para iniciar o detener la escucha de notificaciones
  void toggleListening() {
    if (!isListening.value) {
      startForegroundService(); // Iniciar el servicio en primer plano
      listenNotification(); // Iniciar la escucha de notificaciones
    }
    isListening.value = !isListening.value;
  }

  void stopListening() {
    isListening.value = false;
    FlutterForegroundTask.stopService(); // Detener el servicio en primer plano
  }
}
