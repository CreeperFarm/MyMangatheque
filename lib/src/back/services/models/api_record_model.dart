import 'dart:convert';

class ApiRecordModel {
  ApiRecordModel({
    required this.id,
    required this.collectionId,
    required this.data,
  });

  final String id;
  final String collectionId;
  final Map<String, dynamic> data;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'collectionId': collectionId, ...data};
  }

  @override
  String toString() => jsonEncode(toJson());
}

class ApiRecordSubscriptionEvent {
  ApiRecordSubscriptionEvent({
    required this.collectionId,
    required this.action,
    this.record,
  });

  final String collectionId;
  final String action;
  final ApiRecordModel? record;
}

class CompatSubscription {
  CompatSubscription(this._onUnsubscribe);

  final void Function() _onUnsubscribe;

  void unsubscribe() {
    _onUnsubscribe();
  }
}
