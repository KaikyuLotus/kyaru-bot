import 'package:http/http.dart';

class InsultsClient {
  final String baseUrl = 'insult.mattbas.org';

  final _client = Client();

  Future<String> getInsult() async {
    var response = await _client
        .get(Uri.https(baseUrl, '/api/insult'))
        .timeout(Duration(seconds: 120));
    return response.body;
  }
}
