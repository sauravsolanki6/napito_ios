class apiuseraddresscall {
  apiuseraddresscall({
    required this.user_id,
    required this.address_type,
  });
  late final String user_id;
  late final String address_type;

  apiuseraddresscall.fromJson(Map<String, dynamic> json) {
    user_id = json['user_id'];
    address_type = json['address_type'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['user_id'] = user_id;
    _data['address_type'] = address_type;
    return _data;
  }
}
