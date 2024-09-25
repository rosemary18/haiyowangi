import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:haiyowangi/src/index.dart';
import 'package:path_provider/path_provider.dart';

class InsightRepository {

  Future<Response> getData(String storeId, { Map<String, dynamic>? queryParams }) async {

    String url = "/insight/store/$storeId";
    Response response = await getFetch(url, queryParameters: queryParams);

    if (response.statusCode != 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(response.data["message"]! ?? response.statusMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    return response;
  }

  Future<String?> exportInsight(String storeId, String date) async {

    // String url = "https://awsimages.detik.net.id/community/media/visual/2022/11/03/gambar-dekoratif-2.jpeg";
    String url = "${dotenv.env['BASE_PRODUCTION_API']!}/api/insight/export/store/$storeId?date=$date";

    final downloadsDirectory = await getExternalStorageDirectory();

    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: downloadsDirectory!.path,
      fileName: "insigth-$storeId-$date.xlsx",
      showNotification: true,
      openFileFromNotification: true,
      saveInPublicStorage: true
    );

    return taskId;
  }
}