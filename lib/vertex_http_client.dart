import 'package:http/http.dart';

// Big thanks to leancode.co for this code snippet
// Code from here: https://leancode.co/blog/how-to-use-gemini-api-in-europe
class VertexHttpClient extends BaseClient {
  VertexHttpClient(this._projectUrl);

  final String _projectUrl;
  final _client = Client();

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    if (request is! Request || request.url.host != 'generativelanguage.googleapis.com') {
      return _client.send(request);
    }

    final vertexRequest = Request(
        request.method,
        Uri.parse(
            request.url.toString().replaceAll('https://generativelanguage.googleapis.com/v1/models', _projectUrl)))
      ..bodyBytes = request.bodyBytes;

    for (final header in request.headers.entries) {
      if (header.key != 'x-goog-api-key' && header.key != 'x-goog-api-client') {
        vertexRequest.headers[header.key] = header.value;
      }
    }

    vertexRequest.headers['Authorization'] = 'Bearer ${request.headers['x-goog-api-key']}';

    return _client.send(vertexRequest);
  }
}
