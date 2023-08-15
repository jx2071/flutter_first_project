import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class CloudNote {
  final String documentId;
  final String userId;
  final String text;

  const CloudNote({
    required this.documentId,
    required this.userId,
    required this.text,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        userId = snapshot.data()[userIdField],
        text = snapshot.data()[textField] as String;
}
