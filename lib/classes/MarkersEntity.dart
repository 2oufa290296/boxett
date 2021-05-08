import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkersEntity {

  String pageName,imgUrl;
  LatLng position;

  MarkersEntity(this.pageName,this.imgUrl,this.position);
}