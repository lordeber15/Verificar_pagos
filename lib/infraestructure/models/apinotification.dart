class Apinotification {
  final int id;
  final String title;
  final String packageName;
  final String nombre;
  final String monto;
  final int codigoseg;
  final DateTime createdAt;
  final DateTime updatedAt;

  Apinotification({
    required this.id,
    required this.title,
    required this.packageName,
    required this.nombre,
    required this.monto,
    required this.codigoseg,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Apinotification.fromJson(Map<String, dynamic> json) =>
      Apinotification(
        id: json["id"],
        title: json["title"],
        packageName: json["packageName"],
        nombre: json["nombre"],
        monto: json["monto"],
        codigoseg: json["codigoseg"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "packageName": packageName,
    "nombre": nombre,
    "monto": monto,
    "codigoseg": codigoseg,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}
