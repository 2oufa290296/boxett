import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileGifts {
  final String orderId,image, name, giftid,customer,special, state,address,mobile;
  final int price, delivery, total, discount;
  Timestamp deliveryTime;
  final bool reviewed;
  ProfileGifts(this.orderId,this.image, this.name, this.price, this.delivery, this.total,
      this.discount, this.giftid, this.customer,this.address,this.mobile, this.state,this.deliveryTime,this.special, this.reviewed);
}
