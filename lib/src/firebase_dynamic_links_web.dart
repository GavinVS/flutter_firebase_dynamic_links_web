part of firebase_dynamic_links_web;

class FlutterFirebaseDynamicLinksPlugin extends FirebaseDynamicLinksPlatform {
  static final Map<String, FlutterFirebaseDynamicLinksPlugin> _cachedInstances = {};

  static FlutterFirebaseDynamicLinksPlugin get instance {
    return instanceFor(app: Firebase.app());
  }

  static FlutterFirebaseDynamicLinksPlugin instanceFor({required FirebaseApp app}) {
    return _cachedInstances.putIfAbsent(app.name, () => FlutterFirebaseDynamicLinksPlugin._(app));
  }

  static void registerWith(Registrar registrar) {
    FirebaseDynamicLinksPlatform.instance = FlutterFirebaseDynamicLinksPlugin.instance;
  }

  final FirebaseApp _app;

  FlutterFirebaseDynamicLinksPlugin._(this._app);

  // TODO: Explain this.
  @override
  Stream<PendingDynamicLinkData> get onLink => const Stream.empty();

  // TODO: Expplain why this is always null.
  @override
  Future<PendingDynamicLinkData?> getInitialLink() async => null;

  // TODO: Ditto.
  @override
  Future<PendingDynamicLinkData?> getDynamicLink(Uri url) async => null;

  @override
  Future<Uri> buildLink(DynamicLinkParameters parameters) async {
    var uri = Uri.parse(parameters.uriPrefix);

    return Uri(
      scheme: uri.scheme,
      userInfo: uri.userInfo,
      host: uri.host,
      port: uri.port,
      path: uri.path,
      queryParameters: _removingNulls({
        'link': parameters.link.toString(),
        'apn': parameters.androidParameters?.packageName,
        'afl': parameters.androidParameters?.fallbackUrl?.toString(),
        'amv': parameters.androidParameters?.minimumVersion?.toString(),
        'ibi': parameters.iosParameters?.bundleId,
        'ifl': parameters.iosParameters?.fallbackUrl?.toString(),
        'ius': parameters.iosParameters?.customScheme,
        'ipfl': parameters.iosParameters?.ipadFallbackUrl?.toString(),
        'ipbi': parameters.iosParameters?.ipadBundleId,
        'isi': parameters.iosParameters?.appStoreId,
        'imv': parameters.iosParameters?.minimumVersion,
        'efr': parameters.navigationInfoParameters?.forcedRedirectEnabled?.toString(),
        'st': parameters.socialMetaTagParameters?.title,
        'sd': parameters.socialMetaTagParameters?.description,
        'si': parameters.socialMetaTagParameters?.imageUrl?.toString(),
        'utm_source': parameters.googleAnalyticsParameters?.source,
        'utm_medium': parameters.googleAnalyticsParameters?.medium,
        'utm_campaign': parameters.googleAnalyticsParameters?.campaign,
        'utm_term': parameters.googleAnalyticsParameters?.term,
        'utm_content': parameters.googleAnalyticsParameters?.content,
        'at': parameters.itunesConnectAnalyticsParameters?.affiliateToken,
        'ct': parameters.itunesConnectAnalyticsParameters?.campaignToken,
        'pt': parameters.itunesConnectAnalyticsParameters?.providerToken,
      }),
    );
  }

  @override
  Future<ShortDynamicLink> buildShortLink(
    DynamicLinkParameters parameters, {
    ShortDynamicLinkType shortLinkType = ShortDynamicLinkType.short,
  }) async {
    var response = await http.post(
      Uri.parse('https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=${_app.options.apiKey}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(_toJson(parameters, shortLinkType)),
    );

    var json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return ShortDynamicLink(
      type: shortLinkType,
      shortUrl: Uri.parse(json['shortLink']),
      previewLink: json['previewLink'] != null ? Uri.parse(json['previewLink']) : null,
    );
  }

  Map<String, dynamic> _toJson(DynamicLinkParameters parameters, ShortDynamicLinkType shortLinkType) {
    return {
      'dynamicLinkInfo': {
        'domainUriPrefix': parameters.uriPrefix,
        'link': parameters.link.toString(),
        if (parameters.androidParameters != null) 'androidInfo': _androidParametersJson(parameters.androidParameters!),
        if (parameters.iosParameters != null) 'iosInfo': _iosParametersJson(parameters.iosParameters!),
        if (parameters.navigationInfoParameters != null)
          'navigationInfo': _navigationParametersJson(parameters.navigationInfoParameters!),
        'analyticsInfo': {
          if (parameters.googleAnalyticsParameters != null)
            'googlePlayAnalytics': _googleAnalyticsJson(parameters.googleAnalyticsParameters!),
          if (parameters.itunesConnectAnalyticsParameters != null)
            'itunesConnectAnalytics': _itunesAnalyticsJson(parameters.itunesConnectAnalyticsParameters!),
        },
        if (parameters.socialMetaTagParameters != null)
          'socialMetaTagInfo': _socialMetaTagJson(parameters.socialMetaTagParameters!),
      },
      'suffix': {
        'option': shortLinkType.name.toUpperCase(),
      }
    };
  }

  Map<String, dynamic> _androidParametersJson(AndroidParameters parameters) {
    return _removingNulls({
      'androidPackageName': parameters.packageName,
      'androidFallbackLink': parameters.fallbackUrl?.toString(),
      'androidMinPackageVersionCode': parameters.minimumVersion?.toString(),
    });
  }

  Map<String, dynamic> _iosParametersJson(IOSParameters parameters) {
    return _removingNulls({
      'iosBundleId': parameters.bundleId,
      'iosFallbackLink': parameters.fallbackUrl?.toString(),
      'iosCustomScheme': parameters.customScheme,
      'iosIpadFallbackLink': parameters.ipadFallbackUrl?.toString(),
      'iosIpadBundleId': parameters.ipadBundleId,
      'iosAppStoreId': parameters.appStoreId,
    });
  }

  Map<String, dynamic> _navigationParametersJson(NavigationInfoParameters parameters) {
    return _removingNulls({
      'enableForcedRedirect': parameters.forcedRedirectEnabled,
    });
  }

  Map<String, dynamic> _googleAnalyticsJson(GoogleAnalyticsParameters parameters) {
    return _removingNulls({
      'utmSource': parameters.source,
      'utmMedium': parameters.medium,
      'utmCampaign': parameters.campaign,
      'utmTerm': parameters.term,
      'utmContent': parameters.content,
    });
  }

  Map<String, dynamic> _itunesAnalyticsJson(ITunesConnectAnalyticsParameters parameters) {
    return _removingNulls({
      'at': parameters.affiliateToken,
      'ct': parameters.campaignToken,
      'pt': parameters.providerToken,
    });
  }

  Map<String, dynamic> _socialMetaTagJson(SocialMetaTagParameters parameters) {
    return _removingNulls({
      'socialTitle': parameters.title,
      'socialDescription': parameters.description,
      'socialImageLink': parameters.imageUrl,
    });
  }

  Map<K, V> _removingNulls<K, V>(Map<K, V> map) {
    map.removeWhere((key, value) => value == null);
    return map;
  }
}
