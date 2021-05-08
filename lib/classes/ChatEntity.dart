import 'package:cloud_firestore/cloud_firestore.dart';

class ChatEntity {

  final String message,time;
  bool you;
  Timestamp timeStamp;
  
  
  ChatEntity(this.message,this.time,this.you,this.timeStamp);

   @override
  bool operator ==(other) {
    return this.timeStamp == other.timeStamp;
  }

  @override
  int get hashCode => time.hashCode;
}