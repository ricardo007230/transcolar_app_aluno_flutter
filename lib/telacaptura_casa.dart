import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class TelaCapturaCasa extends StatefulWidget {
  const TelaCapturaCasa({super.key});

  @override
  State<TelaCapturaCasa> createState() => _TelaCapturaCasaState();
}

class _TelaCapturaCasaState extends State<TelaCapturaCasa> {
  bool isTracking = false;
  Color _buttonColor = Colors.green;
  late MapController mapCont = MapController();
  List<LatLng> point = [];

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Casa'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 15,),
              Expanded(
                  child: FlutterMap(
                        mapController: mapCont,
                        options: const MapOptions(
                          initialCenter: LatLng(-14.0383624, -53.1762305),
                          initialZoom: 4.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          ),
                          PolylineLayer(polylines: [
                            Polyline(
                              points: point,
                              color: Colors.blue,
                              strokeWidth: 5,
                            ),
                          ]),
                          //MarkerLayer(markers: getMarkers()),
                          const SimpleAttributionWidget(
                            source: Text('OpenStreetMap contributors'),
                          ),
                        ]),
              ),
              const SizedBox(height: 15,),
              ElevatedButton(
                  onPressed: () async {
                    if (await requestLocationPermission()) {
                      setState(() {
                        isTracking = !isTracking;
                        _buttonColor = isTracking ? Colors.red : Colors.green;
                      });

                      if(isTracking) {
                        LocationData loc;
                        loc = await getLocation();
                        if(loc.latitude != null && loc.longitude != null) {
                          point.add(LatLng(loc.latitude!, loc.longitude!));
                        }
                        if (point.isNotEmpty) {
                          mapCont.move(point[point.length - 1], 16);
                        }
                      }

                    } else {
                      _exibirAlertaFalha(context);
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => const ViagensView()));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonColor,
                    minimumSize: Size(MediaQuery.of(context).size.width, 70),
                  ),
                  child: Text(
                    isTracking ? 'Finalizar registro' : 'Registrar casa',
                    style: const TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
            ]),
      ),
    );
  }

  Future<bool> requestLocationPermission() async {
    ph.PermissionStatus status = await ph.Permission.location.request();
    return status.isGranted ? true : false;
  }

  void _exibirAlertaFalha(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aviso'),
          content: const Text('Localização necessária. Por favor habilite.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o alerta
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  Future<LocationData> getLocation() async {
    Location location = Location();

    final locationData = await location.getLocation();
    return locationData;
  }
}

