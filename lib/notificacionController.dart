import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

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

  void listenNotification() async {
    log("🔁 Se activó listenNotification");

    NotificationListenerService.notificationsStream.listen((event) {
      log("📲 Recibida notificación de ${event.packageName}");

      if (event.packageName == targetPackage) {
        log("✅ Es de Yape, se va a procesar");

        final data = extractData(event.content.toString());
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

  Map<String, String>? extractData(String content) {
    try {
      final nombreRegex = RegExp(r"^(.*?)\s+envio");
      final montoRegex = RegExp(r"por S\/ ([\d.]+)");
      final codRegex = RegExp(r"seguridad es: (\d+)");

      final nombre = nombreRegex.firstMatch(content)?.group(1)?.trim();
      final monto = montoRegex.firstMatch(content)?.group(1)?.trim();
      final codigoseg = codRegex.firstMatch(content)?.group(1)?.trim();

      if (nombre != null && monto != null && codigoseg != null) {
        return {'nombre': nombre, 'monto': monto, 'codigoseg': codigoseg};
      }
    } catch (e) {
      log("Error extrayendo datos: $e");
    }
    return null;
  }

  Future<void> sendToApi({
    String? title,
    String? packageName,
    String? nombre,
    String? monto,
    String? codigoseg,
  }) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        apiUrl,
        data: {
          "title": title ?? "",
          "packageName": packageName ?? "",
          "nombre": nombre ?? "",
          "monto": monto ?? "",
          "codigoseg": codigoseg ?? "",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Enviado correctamente");
        await getNotifications(); // refrescar la lista
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

  void toggleListening() {
    if (!isListening.value) {
      listenNotification(); // asegúrate de volver a enganchar el stream aquí
    }
    isListening.value = !isListening.value;
  }

  void stopListening() {
    isListening.value = false;
  }
}
