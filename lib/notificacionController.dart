import 'dart:developer';
import 'package:get/get.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

class SMSController extends GetxController {
  RxList notificationList = RxList<ServiceNotificationEvent>();

  @override
  void onInit() {
    super.onInit();
    listenNotification();
  }

  void requestForPermission() async {
    log("Solicitando Permisos");
    final bool status = await NotificationListenerService.isPermissionGranted();
    if (status != true) {
      log("sin Permisos");
      final bool statuss =
          await NotificationListenerService.requestPermission();
      listenNotification();
      log(statuss.toString());
    }
  }

  void listenNotification() async {
    log("Escuchando mensajes");
    NotificationListenerService.notificationsStream.listen((event) {
      log("Estado Actual de notificaciones: $event");
      notificationList.add(event);
    });
  }
}
