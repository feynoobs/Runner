import 'dart:collection';
import 'package:logger/logger.dart';
import 'package:crypto/crypto.dart';

abstract class ApiCommon
{
    String entryPoint;
    String method;

    ApiCommon(this.entryPoint, this.method);

    static const String _apiKey = '2hSoAk98Pw9Vk6LNmXOO6hip6';
    static const String _apiSecret = 't7jHT6dysIJvPVzWORgex8FuHW2orZUEul1JzUazgFoaJqnaGx';
    static const String callbackURL  = 'twinida://';

    void Function(String?)? callback;

    void start([final Map<String, String>? param]); 
    void finish(final String? result);

    void startMain({Map<String, String>? request, Map<String, String>? additional, Map<String, String>? rawData, String? oauthToken, String? oauthTokenSecret})
    {
        final logger = Logger();
        logger.v('startMain(${request}, ${additional}, ${rawData}, ${oauthToken}, ${oauthTokenSecret})');

        Map<String, String> header = {
            'oauth_consumer_key': _apiKey,
            'oauth_nonce': DateTime.now().millisecondsSinceEpoch.toString(),
            'oauth_signature_method': "HMAC-SHA1",
            'oauth_timestamp': (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString(),
            'oauth_version': '1.0'
        };
        if (oauthToken != null) {
            header['oauth_token'] = oauthToken;
        }

        String signature = Uri.encodeFull(_apiSecret);
        additional?.forEach((key, value) {
            if (key != 'oauth_token_secret') {
                header[key] = value;
            }
            else {
                signature += Uri.encodeFull(value);
            }
        });
        if (request != null) {
            header.addAll(request);
        }
        if (oauthTokenSecret != null) {
            signature += Uri.encodeFull(oauthTokenSecret);
        }
        String query = '';
        header = SplayTreeMap.from(header, (a, b) => a.compareTo(b));
        header.forEach((key, value) {
             query += '${key}=${value}&';
        });
        query = query.substring(0, query.length - 1);

    }

    void _callStartMain(Map<String, String>? request, Map<String, String>? additional, Map<String, String>? rawData) async
    {


    }
}
