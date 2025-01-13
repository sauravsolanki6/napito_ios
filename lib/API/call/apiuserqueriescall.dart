class ApiUserQueriesCall {
  ApiUserQueriesCall({
    required this.user_id,
  });
  late final String user_id;
  
  ApiUserQueriesCall.fromJson(Map<String, dynamic> json){
    user_id = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['user_id'] = user_id;
    return _data;
  }
}
