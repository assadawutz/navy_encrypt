import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:navy_encrypt/storage/prefs.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

//https://codelabs.developers.google.com/codelabs/flutter-github-graphql-client#3
class MyOAuth {
  final String serviceName;
  final Uri authEndpoint;
  final Uri tokenEndpoint;
  final String clientId;
  final String clientSecret;
  final String scope;
  HttpServer _redirectServer;

  MyOAuth({
    @required String this.serviceName,
    @required String authEndpoint,
    @required String tokenEndpoint,
    @required this.clientId,
    @required this.clientSecret,
    @required this.scope,
  })  : authEndpoint = Uri.parse(authEndpoint),
        tokenEndpoint = Uri.parse(tokenEndpoint);

  Future<oauth2.Client> connect() async {
    var credentialsJson = await MyPrefs.getOAuthCredentials(serviceName);
    if (credentialsJson != null) {
      var credentials = oauth2.Credentials.fromJson(credentialsJson);
      if (credentials.isExpired) {
        try {
          credentials = await credentials.refresh();
          await MyPrefs.setOAuthCredentials(serviceName, credentials.toJson());
        } catch (e) {
          print(e);
          credentials = null;
        }
      }
      if (credentials != null) return oauth2.Client(credentials);
    }

    try {
      await _redirectServer?.close();
      // Bind to an ephemeral port on localhost
      _redirectServer = await HttpServer.bind('localhost', 0);
      var authenticatedHttpClient = await _getOAuth2Client(
        Uri.parse('http://localhost:${_redirectServer.port}'),
      );
      var credentialsJson = authenticatedHttpClient.credentials.toJson();
      await MyPrefs.setOAuthCredentials(serviceName, credentialsJson);
      return authenticatedHttpClient;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<oauth2.Client> _getOAuth2Client(Uri redirectUrl) async {
    var grant = oauth2.AuthorizationCodeGrant(
      clientId,
      authEndpoint,
      tokenEndpoint,
      secret: clientSecret,
      httpClient: _JsonAcceptingHttpClient(),
    );
    var authorizationUrl =
        grant.getAuthorizationUrl(redirectUrl, scopes: [scope]);

    await _redirect(authorizationUrl);
    var responseQueryParameters = await _listen();
    //logOneLineWithBorderSingle('QUERY PARAMETERS: $responseQueryParameters');

    var client =
        await grant.handleAuthorizationResponse(responseQueryParameters);
    //logOneLineWithBorderSingle('CREDENTIALS: ${client.credentials.toJson()}');

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
    request.response.writeln(
        'Success! You can close this window and return to \'SEND AND RECEIVE FILES\' application.');
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
