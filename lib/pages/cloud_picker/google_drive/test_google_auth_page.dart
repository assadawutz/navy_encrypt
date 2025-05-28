import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:navy_encrypt/etc/utils.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

final _authorizationEndpoint =
    Uri.parse('https://accounts.google.com/o/oauth2/v2/auth');
final _tokenEndpoint = Uri.parse('https://oauth2.googleapis.com/token');

class TestGoogleAuthPage extends StatefulWidget {
  const TestGoogleAuthPage({
    @required this.builder,
    this.clientId =
        '786699358980-90rs6o7099l2r6plrhkvlq1u691776v7.apps.googleusercontent.com',
    this.clientSecret = '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',
    this.scope = 'https://www.googleapis.com/auth/drive',
  });

  final AuthenticatedBuilder builder;
  final String clientId;
  final String clientSecret;
  final String scope;

  @override
  _TestGoogleAuthPageState createState() => _TestGoogleAuthPageState();
}

typedef AuthenticatedBuilder = Widget Function(
  BuildContext context,
  oauth2.Client client,
);

class _TestGoogleAuthPageState extends State<TestGoogleAuthPage> {
  HttpServer _redirectServer;
  oauth2.Client _client;

  @override
  Widget build(BuildContext context) {
    final client = _client;
    if (client != null) {
      showOkDialog(context, 'SUCCESS!');
      return widget.builder(context, client);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _redirectServer?.close();
            // Bind to an ephemeral port on localhost
            _redirectServer = await HttpServer.bind('localhost', 0);
            var authenticatedHttpClient = await _getOAuth2Client(
              Uri.parse('http://localhost:${_redirectServer.port}'),
            );
            setState(() {
              _client = authenticatedHttpClient;
            });
          },
          child: const Text('Login to Google'),
        ),
      ),
    );
  }

  Future<oauth2.Client> _getOAuth2Client(Uri redirectUrl) async {
    if (widget.clientId.isEmpty || widget.clientSecret.isEmpty) {
      throw const LoginException(
          'githubClientId and githubClientSecret must be not empty. '
          'See `lib/github_oauth_credentials.dart` for more detail.');
    }
    var grant = oauth2.AuthorizationCodeGrant(
      widget.clientId,
      _authorizationEndpoint,
      _tokenEndpoint,
      secret: widget.clientSecret,
      httpClient: _JsonAcceptingHttpClient(),
    );
    var authorizationUrl =
        grant.getAuthorizationUrl(redirectUrl, scopes: [widget.scope]);

    await _redirect(authorizationUrl);
    var responseQueryParameters = await _listen();
    var client =
        await grant.handleAuthorizationResponse(responseQueryParameters);
    return client;
  }

  Future<void> _redirect(Uri authorizationUrl) async {
    var url = authorizationUrl.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw LoginException('Could not launch $url');
    }
  }

  Future<Map<String, String>> _listen() async {
    var request = await _redirectServer.first;
    var params = request.uri.queryParameters;
    request.response.statusCode = 200;
    request.response.headers.set('content-type', 'text/plain');
    request.response.writeln('SUCCESS');
    await request.response.close();
    await _redirectServer.close();
    _redirectServer = null;
    return params;
  }
}

class _JsonAcceptingHttpClient extends http.BaseClient {
  final _httpClient = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';
    return _httpClient.send(request);
  }
}

class LoginException implements Exception {
  const LoginException(this.message);

  final String message;

  @override
  String toString() => message;
}
