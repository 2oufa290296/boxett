class VoucherEntity{

  final String voucher;
  final int discount;

  VoucherEntity(this.voucher,this.discount);

  @override
  bool operator ==(other) {
    return this.voucher == other.voucher;
  }

  @override
  int get hashCode => voucher.hashCode;
}