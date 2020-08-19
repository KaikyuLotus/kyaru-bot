import 'package:http/http.dart';

class InsultsClient {
  final base_url = 'insult.mattbas.org';

  final _client = Client();

  Future<String> getInsult() async {
    return (await _client.get(Uri.https(base_url, '/api/insult')).timeout(Duration(seconds: 120))).body;
  }
}
