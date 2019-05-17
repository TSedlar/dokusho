import 'package:dio/dio.dart';

class Internet {
  static final Dio _DIO = Dio();

  static Future<Response> read(String url, [bool proxy = false]) async {
    if (proxy) {
      url = 'https://cors-anywhere.herokuapp.com/' + url;
      // url = 'https://crossorigin.me/' + url;
    }
    return _DIO.get(url);
  }

  static Future<String> readString(String url, [bool proxy = false]) async {
    var response = await read(url, proxy);
    return response.data.toString();
  }
}
