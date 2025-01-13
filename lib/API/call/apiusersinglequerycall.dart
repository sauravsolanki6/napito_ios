class ApiUserSingleQuerycall {
  ApiUserSingleQuerycall({
    required this.user_id,
    required this.selected_ticket_id,
  });
  late final String user_id;
  late final String selected_ticket_id;
  
  ApiUserSingleQuerycall.fromJson(Map<String, dynamic> json){
    user_id = json['user_id'];
    selected_ticket_id = json['selected_ticket_id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['user_id'] = user_id;
    _data['selected_ticket_id'] = selected_ticket_id;
    return _data;
  }
}