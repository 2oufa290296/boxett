class Gifts {
  final String image, name,  page, id,pageId,discount;
  final int price;
  Gifts(this.image, this.name, this.price, this.page, this.id,this.pageId,this.discount);

  @override
  bool operator ==(other) {
    return this.id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
