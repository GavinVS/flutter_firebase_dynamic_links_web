library firebase_dynamic_links_web;

import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:http/http.dart' as http;

export 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart'
    show
        AndroidParameters,
        DynamicLinkParameters,
        FirebaseDynamicLinksPlatform,
        GoogleAnalyticsParameters,
        IOSParameters,
        ITunesConnectAnalyticsParameters,
        NavigationInfoParameters,
        PendingDynamicLinkData,
        PendingDynamicLinkDataAndroid,
        PendingDynamicLinkDataIOS,
        ShortDynamicLink,
        ShortDynamicLinkType,
        SocialMetaTagParameters;

part 'src/firebase_dynamic_links_web.dart';
