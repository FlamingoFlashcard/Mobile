import 'package:dio/dio.dart';
import 'package:lacquer/config/env.dart';

final dio = Dio(
  BaseOptions(baseUrl: Env.serverURL, headers: {'x-platform': 'android'}),
);
