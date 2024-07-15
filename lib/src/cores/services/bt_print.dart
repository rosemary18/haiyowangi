// // ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, sort_child_properties_last, prefer_interpolation_to_compose_strings

// import 'dart:async';
// import 'dart:convert';

// import 'package:bluetooth_print/bluetooth_print.dart';
// import 'package:bluetooth_print/bluetooth_print_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// void main() => runApp(const MyApp());

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

//   bool _connected = false;
//   BluetoothDevice? _device;
//   String tips = 'no device connect';

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initBluetooth() async {
//     bluetoothPrint.startScan(timeout: Duration(seconds: 4));

//     bool isConnected=await bluetoothPrint.isConnected??false;

//     bluetoothPrint.state.listen((state) {
//       debugPrint('******************* cur device status: $state');

//       switch (state) {
//         case BluetoothPrint.CONNECTED:
//           setState(() {
//             _connected = true;
//             tips = 'connect success';
//           });
//           break;
//         case BluetoothPrint.DISCONNECTED:
//           setState(() {
//             _connected = false;
//             tips = 'disconnect success';
//           });
//           break;
//         default:
//           break;
//       }
//     });

//     if (!mounted) return;

//     if(isConnected) {
//       setState(() {
//         _connected=true;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//           appBar: AppBar(
//             title: const Text('BluetoothPrint example app'),
//           ),
//           body: RefreshIndicator(
//             onRefresh: () =>
//                 bluetoothPrint.startScan(timeout: const Duration(seconds: 4)),
//             child: SingleChildScrollView(
//               child: Column(
//                 children: <Widget>[
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                         child: Text(tips),
//                       ),
//                     ],
//                   ),
//                   Divider(),
//                   StreamBuilder<List<BluetoothDevice>>(
//                     stream: bluetoothPrint.scanResults,
//                     initialData: const [],
//                     builder: (c, snapshot) => Column(
//                       children: snapshot.data!.map((d) => ListTile(
//                         title: Text(d.name??''),
//                         subtitle: Text(d.address??''),
//                         onTap: () async {
//                           setState(() {
//                             _device = d;
//                           });
//                         },
//                         trailing: _device!=null && _device!.address == d.address?Icon(
//                           Icons.check,
//                           color: Colors.green,
//                         ):null,
//                       )).toList(),
//                     ),
//                   ),
//                   Divider(),
//                   Container(
//                     padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
//                     child: Column(
//                       children: <Widget>[
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             OutlinedButton(
//                               child: Text('connect'),
//                               onPressed:  _connected?null:() async {
//                                 if(_device!=null && _device!.address !=null){
//                                   setState(() {
//                                     tips = 'connecting...';
//                                   });
//                                   await bluetoothPrint.connect(_device!);
//                                 }else{
//                                   setState(() {
//                                     tips = 'please select device';
//                                   });
//                                   debugPrint('please select device');
//                                 }
//                               },
//                             ),
//                             SizedBox(width: 10.0),
//                             OutlinedButton(
//                               child: Text('disconnect'),
//                               onPressed:  _connected?() async {
//                                 setState(() {
//                                   tips = 'disconnecting...';
//                                 });
//                                 await bluetoothPrint.disconnect();
//                               }:null,
//                             ),
//                           ],
//                         ),
//                         Divider(),
//                         OutlinedButton(
//                           child: Text('print receipt(esc)'),
//                           onPressed:  _connected?() async {
//                             Map<String, dynamic> config = {};
//                              config['gap'] = 0;


//                             List<LineText> list = [];

//                             list.add(LineText(type: LineText.TYPE_TEXT, content: 'Haiyo Wangi', weight: 1, align: LineText.ALIGN_CENTER, fontZoom: 4, linefeed: 1));
//                             list.add(LineText(linefeed: 1));
//                             list.add(LineText(type: LineText.TYPE_TEXT, content: 'Rabu, 28/02/2022 12:00', align: LineText.ALIGN_LEFT, linefeed: 1));
                            
//                             list.add(LineText(type: LineText.TYPE_TEXT, content: '--------------------------------', linefeed: 1));
//                             list.add(LineText(type: LineText.TYPE_TEXT, content: '1. x3 @ Rp 12.000 ', align: LineText.ALIGN_LEFT, linefeed: 1, fontZoom: 1));
//                             list.add(LineText(type: LineText.TYPE_TEXT, content: 'Botol Kaca', align: LineText.ALIGN_LEFT, x: 34, linefeed: 1));
//                             list.add(LineText(type: LineText.TYPE_TEXT, content: '2. x3 @ Rp 12.000 ', align: LineText.ALIGN_LEFT, linefeed: 1));
//                             list.add(LineText(type: LineText.TYPE_TEXT, content: 'Botol Plastic', align: LineText.ALIGN_LEFT, x: 34, linefeed: 1));
//                             list.add(LineText(type: LineText.TYPE_TEXT, content: '--------------------------------', linefeed: 1));
//                             list.add(LineText(type: LineText.TYPE_TEXT, content: 'Total     : Rp 24.000', align: LineText.ALIGN_LEFT, linefeed: 1));
//                             list.add(LineText(type: LineText.TYPE_TEXT, content: 'Cash      : Rp 50.000', align: LineText.ALIGN_LEFT, linefeed: 1));
//                             list.add(LineText(type: LineText.TYPE_TEXT, content: 'Kembalian : Rp 26.000', align: LineText.ALIGN_LEFT, linefeed: 1));
//                             list.add(LineText(type: LineText.TYPE_TEXT, content: "Kasir: Adi", align: LineText.ALIGN_LEFT, linefeed: 1));

//                             list.add(LineText(linefeed: 1));
//                             list.add(LineText(type: LineText.TYPE_TEXT, content: "Terima kasih telah berbelanja di Haiyo Wangi", align: LineText.ALIGN_CENTER, linefeed: 1));
//                             list.add(LineText(linefeed: 1));

//                             // Print or process the list as needed

//                             // ByteData data = await rootBundle.load("assets/images/bluetooth_print.png");
//                             // List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//                             // String base64Image = base64Encode(imageBytes);
//                             // list.add(LineText(type: LineText.TYPE_IMAGE, content: base64Image, align: LineText.ALIGN_CENTER, linefeed: 1));

//                             await bluetoothPrint.printReceipt(config, list);
//                           }:null,
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         floatingActionButton: StreamBuilder<bool>(
//           stream: bluetoothPrint.isScanning,
//           initialData: false,
//           builder: (c, snapshot) {
//             if (snapshot.data == true) {
//               return FloatingActionButton(
//                 onPressed: () => bluetoothPrint.stopScan(),
//                 backgroundColor: Colors.red,
//                 child: const Icon(Icons.stop),
//               );
//             } else {
//               return FloatingActionButton(
//                   child: const Icon(Icons.search),
//                   onPressed: () => bluetoothPrint.startScan(timeout: const Duration(seconds: 4)));
//             }
//           },
//         ),
//       ),
//     );
//   }
// }