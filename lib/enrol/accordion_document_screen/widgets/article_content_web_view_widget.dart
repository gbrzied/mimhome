import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart' as htmltopdf;
import 'package:millime/theme/theme_helper.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html;

class ArticleContentWebViewWidget extends StatefulWidget {
  final String url;
  final String title;
  final String? anchor;
  final String? articleTitle;

  const ArticleContentWebViewWidget({
    Key? key,
    required this.url,
    required this.title,
    this.anchor,
    this.articleTitle,
  }) : super(key: key);

  @override
  _ArticleContentWebViewWidgetState createState() => _ArticleContentWebViewWidgetState();
}

class _ArticleContentWebViewWidgetState extends State<ArticleContentWebViewWidget> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isDisposed = false;
  Timer? _loadTimeoutTimer;

  String pageBody = "";
  dynamic widgets;
  dynamic pdf;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _printPage() async {
    if (_isDisposed) return;
    try {
      final htmlContent = await _controller.runJavaScriptReturningResult(
          "window.document.body.outerHTML;");
      if (htmlContent != null && htmlContent is String) {
        // Generate PDF from HTML content
        pdf = pw.Document();
        widgets = await htmltopdf.HTMLToPdf().convert(htmlContent);
        pdf.addPage(pw.MultiPage(build: (context) => widgets));
        
        // Print the PDF
        await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
      }
    } catch (e) {
      if (!_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'impression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _initializeWebView() {
    try {
      // Create platform-specific WebView controller with better configuration
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..setUserAgent('MillimeApp/1.0')
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (!_isDisposed) {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });
              }
            },
            onPageFinished: (String url) {
              if (!_isDisposed) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (!_isDisposed) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                  _errorMessage = error.description;
                });
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              // Prevent navigation to external URLs for security and stability
              if (request.url.startsWith('http') || request.url.startsWith('https')) {
                return NavigationDecision.prevent;
              }
              
              // Also prevent navigation to potentially problematic URLs
              if (request.url.contains('chrome://') ||
                  request.url.contains('about:') ||
                  request.url.contains('file:///android_') ||
                  request.url.contains('content://')) {
                return NavigationDecision.prevent;
              }
              
              return NavigationDecision.navigate;
            },
          ),
        )
        ..addJavaScriptChannel(
          'Flutter',
          onMessageReceived: (JavaScriptMessage message) async {
            if (_isDisposed) return;
            try {
              pageBody = message.message;
              // Add a small delay to ensure the message is fully received
              await Future.delayed(Duration(milliseconds: 100));
              await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
                pdf = pw.Document();
                widgets = await htmltopdf.HTMLToPdf().convert(pageBody);
                pdf.addPage(pw.MultiPage(build: (context) => widgets));
                return await pdf.save();
              });
            } catch (e) {
              if (!_isDisposed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur lors de la génération PDF: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        );

      // Load the URL with better error handling
      _loadUrl();
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Erreur d\'initialisation: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _loadUrl() async {
    if (_isDisposed) return;
    
    // Clear any existing timeout
    _loadTimeoutTimer?.cancel();
    
    try {
      print("Loading URL: ${widget.url}");
      
      // Add WebView stability configurations
      await _controller.runJavaScript('''
        // Disable console errors that might crash the WebView
        console.error = function() {};
        console.warn = function() {};
        
        // Handle unhandled promise rejections
        window.addEventListener('unhandledrejection', function(event) {
          event.preventDefault();
          console.log('Unhandled rejection:', event.reason);
        });
        
        // Handle errors globally
        window.onerror = function(message, source, lineno, colno, error) {
          console.log('Global error:', message);
          return true; // Prevent default error handling
        };
      ''');
      
      // Set a timeout for loading
      _loadTimeoutTimer = Timer(const Duration(seconds: 30), () {
        if (!_isDisposed && _isLoading) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'Délai de chargement dépassé';
          });
        }
      });
      
      // Check if it's an asset file
      if (widget.url.startsWith('assets/')) {
        // Split URL and anchor if present
        String assetPath = widget.url;
        String? anchor;
        
        if (widget.url.contains('#')) {
          List<String> parts = widget.url.split('#');
          assetPath = parts[0];
          anchor = parts[1];
        }
        
        // Use provided anchor or extract from URL
        String? targetAnchor = widget.anchor ?? anchor;
        String displayTitle = widget.articleTitle ?? widget.title;
        
        print("Asset path: $assetPath");
        print("Target anchor: $targetAnchor");
        print("Display title: $displayTitle");
        
        // Load asset file content
        String fileContent = await rootBundle.loadString(assetPath);
        
        // Extract only the specific article content if anchor is present
        String displayContent = fileContent;
        if (targetAnchor != null && targetAnchor.isNotEmpty) {
          displayContent = await _extractArticleContent(fileContent, targetAnchor, displayTitle);
        } else {
          // If no anchor, create a simple wrapper
          displayContent = _createSimpleWrapper(fileContent, displayTitle);
        }
        
        // Create a data URL with the HTML content
        final String dataUrl = Uri.dataFromString(
          displayContent,
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ).toString();
        
        // Load the data URL
        await _controller.loadRequest(Uri.parse(dataUrl));
        
        // If there's an anchor, navigate to it after loading
        if (targetAnchor != null && targetAnchor.isNotEmpty) {
          // Wait for the page to load completely
          await Future.delayed(const Duration(milliseconds: 2000));
          
          // Try to scroll to the anchor using JavaScript with compatibility checks
          try {
            await _controller.runJavaScript('''
              try {
                var element = document.getElementById('$targetAnchor') || document.querySelector('a[name="$targetAnchor"]') || document.querySelector('[name="$targetAnchor"]');
                if (element) {
                  if (element.scrollIntoView) {
                    element.scrollIntoView({behavior: 'smooth', block: 'start'});
                  } else {
                    element.scrollIntoView();
                  }
                  element.style.backgroundColor = '#ffff99';
                  element.style.padding = '10px';
                  element.style.border = '2px solid #ff6600';
                  element.style.borderRadius = '5px';
                  element.style.margin = '10px 0';
                  console.log('Scrolled to anchor: $targetAnchor');
                } else {
                  console.log('Element with anchor $targetAnchor not found');
                  // Try to find any element containing the anchor text
                  var allElements = document.querySelectorAll('*');
                  for (var i = 0; i < allElements.length; i++) {
                    if (allElements[i].textContent && allElements[i].textContent.includes('$targetAnchor')) {
                      if (allElements[i].scrollIntoView) {
                        allElements[i].scrollIntoView({behavior: 'smooth', block: 'start'});
                      } else {
                        allElements[i].scrollIntoView();
                      }
                      allElements[i].style.backgroundColor = '#ffff99';
                      console.log('Found element containing anchor text');
                      break;
                    }
                  }
                }
              } catch (e) {
                console.log('JavaScript error: ' + e.message);
              }
            ''');
          } catch (jsError) {
            print("JavaScript error: $jsError");
          }
        }
        
      } else {
        await _controller.loadRequest(Uri.parse(widget.url));
      }
      
      // Clear timeout on successful load
      _loadTimeoutTimer?.cancel();
    } catch (e) {
      print("Error loading URL: $e");
      if (!_isDisposed) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Erreur de chargement: $e\nURL: ${widget.url}';
          _isLoading = false;
        });
      }
    }
  }

  /// Extract specific article content from HTML based on anchor
  Future<String> _extractArticleContent(String htmlContent, String anchor, String articleTitle) async {
    try {
      // Parse the HTML document
      final document = html.parse(htmlContent);
      
      // Find the element with the specified anchor
      final targetElement = document.getElementById(anchor) ??
                           document.querySelector('a[name="$anchor"]') ??
                           document.querySelector('[name="$anchor"]');
      
      if (targetElement != null) {
        // Find the article section containing this anchor
        // Look for the closest parent that represents an article section
        var articleSection = targetElement;
        
        // Try to find a logical article container (h1, h2, section, article, etc.)
        while (articleSection != null) {
          if (articleSection.localName == 'article' ||
              articleSection.localName == 'section' ||
              articleSection.localName == 'div' &&
              (articleSection.classes.contains('article') ||
               articleSection.classes.contains('section') ||
               articleSection.attributes['id'] == anchor)) {
            break;
          }
          articleSection = articleSection.parent as dynamic;
        }
        
        // If we found a good container, use it, otherwise use the target element
        final contentElement = articleSection ?? targetElement;
        
        // Create a new HTML document with just the article content
        final articleHtml = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$articleTitle</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #ffffff;
        }
        h1, h2, h3, h4, h5, h6 {
            color: #2c3e50;
            margin-top: 1.5em;
            margin-bottom: 0.5em;
            border-bottom: 2px solid #3498db;
            padding-bottom: 0.3em;
        }
        p {
            margin-bottom: 1em;
        }
        .article-header {
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .article-content {
            font-size: 16px;
        }
        a {
            color: #3498db;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        @media (prefers-color-scheme: dark) {
            body {
                background-color: #1a1a1a;
                color: #e0e0e0;
            }
            h1, h2, h3, h4, h5, h6 {
                color: #ffffff;
            }
            .article-header {
                border-bottom-color: #444;
            }
        }
        /* Highlight the target element */
        .target-element {
            background-color: #e8f4fd;
            border-left: 4px solid #3498db;
            padding: 15px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="article-header">
        <h1>$articleTitle</h1>
    </div>
    <div class="article-content">
        ${contentElement.outerHtml}
    </div>
</body>
</html>
        ''';
        
        return articleHtml;
      } else {
        // If anchor not found, return the full content with a warning
        return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$articleTitle</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #ffffff;
        }
        .error-message {
            background-color: #fff3cd;
            border: 1px solid #ffeaa7;
            color: #856404;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .article-header {
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .article-content {
            font-size: 16px;
        }
        @media (prefers-color-scheme: dark) {
            body {
                background-color: #1a1a1a;
                color: #e0e0e0;
            }
            .error-message {
                background-color: #4a3f00;
                border-color: #6b5a00;
                color: #ffd700;
            }
        }
    </style>
</head>
<body>
    <div class="article-header">
        <h1>$articleTitle</h1>
    </div>
    <div class="error-message">
        <strong>Avertissement:</strong> L'ancre "$anchor" n'a pas été trouvée dans le document.
        Affichage du contenu complet.
    </div>
    <div class="article-content">
        $htmlContent
    </div>
</body>
</html>
        ''';
      }
    } catch (e) {
      print("Error extracting article content: $e");
      // Return full content if extraction fails
      return _createSimpleWrapper(htmlContent, articleTitle);
    }
  }

  /// Create a simple wrapper for content without specific anchor
  String _createSimpleWrapper(String htmlContent, String title) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #ffffff;
        }
        h1, h2, h3, h4, h5, h6 {
            color: #2c3e50;
            margin-top: 1.5em;
            margin-bottom: 0.5em;
            border-bottom: 2px solid #3498db;
            padding-bottom: 0.3em;
        }
        p {
            margin-bottom: 1em;
        }
        .article-header {
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .article-content {
            font-size: 16px;
        }
        a {
            color: #3498db;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        @media (prefers-color-scheme: dark) {
            body {
                background-color: #1a1a1a;
                color: #e0e0e0;
            }
            h1, h2, h3, h4, h5, h6 {
                color: #ffffff;
            }
            .article-header {
                border-bottom-color: #444;
            }
        }
    </style>
</head>
<body>
    <div class="article-header">
        <h1>$title</h1>
    </div>
    <div class="article-content">
        $htmlContent
    </div>
</body>
</html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: <Widget>[
          if (!_hasError && !_isLoading && !_isDisposed)
            IconButton(
              icon: const Icon(Icons.print, color: Colors.white),
              onPressed: _printPage,
              tooltip: 'Imprimer',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              if (!_isDisposed) {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });
                _loadUrl();
              }
            },
            tooltip: 'Actualiser',
          ),
        ],
        backgroundColor: Colors.green,
        elevation: 2,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(appTheme.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Chargement du document...',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (!_isDisposed) {
                    setState(() {
                      _isLoading = true;
                      _hasError = false;
                    });
                    _loadUrl();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isDisposed) {
      return const Center(
        child: Text(
          'WebView fermé\nVeuillez réessayer',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: WebViewWidget(
        controller: _controller,
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _loadTimeoutTimer?.cancel();
    
    // Proper WebView cleanup to prevent memory leaks and crashes
    try {
      _controller.clearCache();
      
      // Load a blank page to release resources
      _controller.loadRequest(Uri.parse('about:blank'));
      
      // Remove all JavaScript channels
      _controller.removeJavaScriptChannel('Flutter');
    } catch (e) {
      print('Error during WebView cleanup: $e');
    }
    
    super.dispose();
  }
}