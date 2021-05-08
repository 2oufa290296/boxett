import 'package:cloud_firestore/cloud_firestore.dart';

class SearchGifts {
  final String image, name, page, id,pageId,discount;
  final Timestamp date;
  final num rate,price;

  SearchGifts(this.image, this.name, this.price, this.page, this.id,this.pageId,this.date,this.rate,this.discount);

  @override
  bool operator ==(other) {
    return this.id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
