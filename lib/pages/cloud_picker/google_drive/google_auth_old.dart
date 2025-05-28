import 'package:url_launcher/url_launcher.dart';

class GoogleAuthOld {
  static const String clientId =
      '786699358980-90rs6o7099l2r6plrhkvlq1u691776v7.apps.googleusercontent.com';
  static const String clientSecret = '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';

  static const String authHost = 'accounts.google.com';
  static const String authEndpoint = '/o/oauth2/v2/auth';

  static const String scope = 'https://www.googleapis.com/auth/drive';

  Future<bool> connect() {
    final authUrl = Uri.https(authHost, authEndpoint, {
      'response_type': 'code',
      'client_id': clientId,
      'scope': scope,
      'redirect_uri': 'http://localhost',
      //'state': state,
    });

    _launchURL(authUrl.toString());
    return null;
  }

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
}
