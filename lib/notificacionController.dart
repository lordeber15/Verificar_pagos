import 'dart:developer';
import 'package:get/get.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

class SMSController extends GetxController {
  RxList<ServiceNotificationEvent> notificationList =
      <ServiceNotificationEvent>[].obs;
  RxBool isListening = false.obs;
  RxBool hasPermission = false.obs;

  final String targetPackage = "com.bcp.innovacxion.yapeapp";
  @override
  void onInit() {
    super.onInit();
    listenNotification();
  }

  void requestForPermission() async {
    log("Verificando permisos...");
    final bool status = await NotificationListenerService.isPermissionGranted();
    hasPermission.value = status;

    if (!status) {
      log("Sin permisos. Solicitando...");
      final bool granted =
          await NotificationListenerService.requestPermission();
      hasPermission.value = granted;
      log("Permiso otorgado: $granted");
    } else {
      log("Ya se tienen los permisos");
    }
  }

  void listenNotification() async {
    log("Escuchando mensajes");
    NotificationListenerService.notificationsStream.listen((event) {
      log("Estado Actual de notificaciones: $event");
      notificationList.add(event);
    });
  }

  void startListening() {
    if (!isListening.value) {
      isListening.value = true;
      NotificationListenerService.notificationsStream.listen((event) {
        if (event.packageName == targetPackage) {
          notificationList.add(event);
        }
      });
    }
  }

  void stopListening() {
    isListening.value = false;
    // Nota: No hay una forma directa de "cerrar" el stream, pero usamos el flag `isListening`
    // si decides mejorar esto con stream control más adelante.
  }

  void toggleListening() {
    if (isListening.value) {
      stopListening();
    } else {
      startListening();
    }
  }
}
