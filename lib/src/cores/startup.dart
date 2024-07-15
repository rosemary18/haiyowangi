import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/index.dart';
import 'package:hive_flutter/hive_flutter.dart';

startUp() async {

  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await Hive.openBox("storage");
  await getBaseDeviceInfo();
}