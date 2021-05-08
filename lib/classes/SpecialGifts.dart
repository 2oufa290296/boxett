class SpecialGifts {
  final String image, name, price, page, id;

  SpecialGifts(this.image, this.name, this.price, this.page, this.id);

  @override
  bool operator ==(other) {
    return this.id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
