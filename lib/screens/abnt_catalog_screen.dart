import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AbntCatalogScreen extends StatefulWidget {
  static const String routeName = '/abnt-catalog';

  const AbntCatalogScreen({Key? key}) : super(key: key);

  @override
  State<AbntCatalogScreen> createState() => _AbntCatalogScreenState();
}

class _AbntCatalogScreenState extends State<AbntCatalogScreen> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? _webViewController;
  late PullToRefreshController _pullToRefreshController;
  double _progress = 0;
  final String _initialUrl = "https://www.abntcatalogo.com.br/";

  @override
  void initState() {
    super.initState();

    _pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.blue, // Standard refresh indicator color
      ),
      onRefresh: () async {
        if (Theme.of(context).platform == TargetPlatform.android) {
          _webViewController?.reload();
        } else if (Theme.of(context).platform == TargetPlatform.iOS) {
          _webViewController?.loadUrl(
              urlRequest: URLRequest(url: await _webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo ABNT'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            tooltip: 'Voltar na página',
            onPressed: () async {
              if (await _webViewController?.canGoBack() ?? false) {
                _webViewController?.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            tooltip: 'Avançar na página',
            onPressed: () async {
              if (await _webViewController?.canGoForward() ?? false) {
                _webViewController?.goForward();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar Página',
            onPressed: () {
              _webViewController?.reload();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (_progress < 1.0)
            LinearProgressIndicator(value: _progress, minHeight: 3.0),
          Expanded(
            child: InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(url: WebUri(_initialUrl)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true, // Important for login sessions
                databaseEnabled: true,   // For websites that use local DB
                thirdPartyCookiesEnabled: true, // ABNT might use third-party for auth/federation
                useShouldOverrideUrlLoading: true,
                useOnLoadResource: true,
                cacheEnabled: true,
                // Allow mixed content for broader compatibility, though ABNT should be HTTPS
                // mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              ),
              pullToRefreshController: _pullToRefreshController,
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                // Handle page load start
              },
              onLoadStop: (controller, url) async {
                _pullToRefreshController.endRefreshing();
                // You can inject JavaScript here if needed, but not for MVP
              },
              onReceivedError: (controller, request, error) {
                _pullToRefreshController.endRefreshing();
                // Handle errors, maybe show a custom error page or message
                print("WebView error: ${error.description}");
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  _pullToRefreshController.endRefreshing();
                }
                setState(() {
                  _progress = progress / 100;
                });
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                // Allow all navigation actions
                return NavigationActionPolicy.ALLOW;
              },
            ),
          ),
        ],
      ),
    );
  }
}
