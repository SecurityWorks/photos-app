import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:super_logging/super_logging.dart';

class Network {
  final _dio = Dio();

  Network._privateConstructor() {
    _dio.interceptors.add(PrettyDioLogger(
        requestHeader: false,
        responseHeader: false,
        requestBody: true,
        responseBody: true,
        logPrint: (object) async {
          log(object);
          if (Platform.isAndroid) {
            await SuperLogging.logFile.writeAsString(
              object.toString() + "\n",
              encoding: Utf8Codec(allowMalformed: true),
              mode: FileMode.append,
              flush: true,
            );
          }
        }));
  }
  static Network instance = Network._privateConstructor();

  Dio getDio() => _dio;
}
