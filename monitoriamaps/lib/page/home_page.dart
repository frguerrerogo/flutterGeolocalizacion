import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //obtener el controlador de Googlemapa para acceder al mapa
  Completer<GoogleMapController> _googleMapController = Completer();
  final Set<Marker> markers = new Set(); //marcadores para google map
  static const LatLng showLocation = const LatLng(5.546012, -73.355419); 
  CameraPosition? _cameraPosition;
  late LatLng _defautlatLng;

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() {
    _defautlatLng = const LatLng(11, 11);
    _cameraPosition = CameraPosition(
      target: _defautlatLng,
      zoom: 17.5,
    );

    //el mapa se redirigirá a mi ubicación actual cuando se cargue
    _gotoUserCurrentPosition();
  }

  //
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google maps"),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: const Center(child: Text("Navegación")),
      ),
    );
  }

  Widget _buildBody() {
    final Set<Marker> _markers = Set();
    return Stack(
      children: [
        _getMap(),
      ],
    );
  }

  Widget _getMap() {
    return GoogleMap(
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      myLocationEnabled: true,
      initialCameraPosition: _cameraPosition!, //inicializar la posición de la cámara para el mapa
      mapType: MapType.normal,
      markers: getmarkers(),
      onCameraIdle: () {
        //esta función se activará cuando el usuario deje de arrastrar en el mapa
      },
      onCameraMove: (CameraPosition) {
        //esta función se activará cuando el usuario siga arrastrando en el mapa
      },
      onMapCreated: (GoogleMapController controller) {
        //esta función se activará cuando el mapa esté completamente cargado
        if (!_googleMapController.isCompleted) {
          //configure el controlador en el mapa de Google cuando esté completamente cargado
          _googleMapController.complete(controller);
        }
      },
    );
  }

  Set<Marker> getmarkers() {
    //marcadores para colocar en el mapa
    setState(
      () {
        markers.add(
          Marker(
            //añadir primer marcador
            markerId: MarkerId(showLocation.toString()),
            position: showLocation, //posición del marcador
            infoWindow: const InfoWindow(
              //informacion del pin
              title: 'Marcador Titulo 1 ',
              snippet: 'Subtitulo 1',
            ),
            icon: BitmapDescriptor.defaultMarker, //Icono del marcador
          ),
        );

        markers.add(
          Marker(
            //añadir segundo marcador
            markerId: MarkerId(showLocation.toString()),
            position: const LatLng(5.542139, -73.356765), //posición del marcador
            infoWindow: const InfoWindow(
              //informacion del pin
              title: 'Marcador Titulo 2 ',
              snippet: 'Subtitulo 2',
            ),
            icon: BitmapDescriptor.defaultMarker, //Icon for Marker
          ),
        );

        markers.add(
          Marker(
            //añadir segundo marcador
            markerId: MarkerId(showLocation.toString()),
            position: const LatLng(5.546544, -73.360900), //posición del marcador
            infoWindow: const InfoWindow(
              //informacion del pin
              title: 'Marcador Titulo 3 ',
              snippet: 'Subtitulo 3',
            ),
            icon: BitmapDescriptor.defaultMarker, //Icon for Marker
          ),
        );
      },
    );

    return markers;
  }

  //obtener la ubicación actual del usuario, y configurar el mapa y la cámara a esa ubicación
  Future _gotoUserCurrentPosition() async {
    Position currentPosition = await _determineUserCurrentPosition();
    _gotoSpecificPosition(
      LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      ),
    );
  }

  //ir a una posición específica por lat y lng
  Future _gotoSpecificPosition(LatLng position) async {
    GoogleMapController mapController = await _googleMapController.future;
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 15,
        ),
      ),
    );
  }

  Future _determineUserCurrentPosition() async {
    LocationPermission locationPermission;
    bool isLocationServiceEnable = await Geolocator.isLocationServiceEnabled();
    //verificar si el usuario habilita el servicio para el permiso de ubicación
    if (!isLocationServiceEnable) {
      print("el usuario no habilita el permiso de ubicación");
    }

    locationPermission = await Geolocator.checkPermission();

    //verifique si el usuario negó la ubicación y vuelva a intentar solicitar permiso
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        print("usuario denegado permiso de ubicación");
      }
    }

    //verificar si el usuario negó el permiso para siempre
    if (locationPermission == LocationPermission.deniedForever) {
      print("usuario negó el permiso para siempre");
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }
}
