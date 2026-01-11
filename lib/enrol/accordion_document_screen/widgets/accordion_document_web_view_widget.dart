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

class AccordionDocumentWebViewWidget extends StatefulWidget {
  final String url;
  final String title;
final String? anchor;
  const AccordionDocumentWebViewWidget(this.url, this.title, {this.anchor, Key? key}) : super(key: key);

  @override
  _AccordionDocumentWebViewWidgetState createState() => _AccordionDocumentWebViewWidgetState();
}

class _AccordionDocumentWebViewWidgetState extends State<AccordionDocumentWebViewWidget> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isDisposed = false;
  Timer? _loadTimeoutTimer;

  String pageBody = "";
  pw.Document? pdf;
  List<pw.Widget>? widgets;
  String? _articleAnchor;

  String? _articleTitle;

  Future<void> _printPage() async {
    if (_isDisposed) return;
    try {
      final htmlContent = await _controller.runJavaScriptReturningResult(
          "window.document.body.outerHTML;");
      if (htmlContent != null && htmlContent is String) {
        // Generate PDF from HTML content
        pdf = pw.Document();
        widgets = await htmltopdf.HTMLToPdf().convert(htmlContent);
        if (widgets != null && pdf != null) {
          pdf!.addPage(pw.MultiPage(build: (context) => widgets!));
        }
        
        // Print the PDF
        if (pdf != null) {
          await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf!.save());
        }
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

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    try {
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
              if (pageBody.isNotEmpty) {
                final doc = pw.Document();
                final convertedWidgets = await htmltopdf.HTMLToPdf().convert(pageBody);
                if (convertedWidgets != null) {
                  doc.addPage(pw.MultiPage(build: (context) => convertedWidgets));
                  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
                }
              }
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
      
      // Add compatibility check for older Android versions
      if (defaultTargetPlatform == TargetPlatform.android) {
        // For Android 9 and below, use a simpler approach
        await _controller.runJavaScript('''
          if (typeof window.matchMedia !== 'undefined') {
            try {
              window.matchMedia('(prefers-color-scheme: dark)').addListener(function() {});
            } catch (e) {
              console.log('matchMedia not supported, using fallback');
            }
          }
        ''');
      }
      
      // Check if it's an asset file
      if (widget.url.startsWith('assets/')) {
        // Split URL and anchor if present
        String assetPath = widget.url;
        String? anchor = widget.anchor;
        
        if (widget.url.contains('#')) {
          List<String> parts = widget.url.split('#');
          assetPath = parts[0];
          anchor = parts[1];
        }
        
        _articleAnchor = anchor;
        _articleTitle = widget.title;
        
        print("Asset path: $assetPath");
        print("Anchor: $anchor");
           print("Anchor: $_articleTitle");
        // Load asset file content
        String fileContent;
        try {
          fileContent = await rootBundle.loadString(assetPath);
        } catch (e) {
          print("Error loading asset: $e");
          if (!_isDisposed) {
            setState(() {
              _hasError = true;
              _errorMessage = 'Erreur de chargement de l\'asset: $e';
              _isLoading = false;
            });
          }
          return;
        }
        
        // Extract only the specific article content if anchor is present
        String displayContent = fileContent;
        if (anchor != null && anchor.isNotEmpty) {
          displayContent = await _extractArticleContent(fileContent, anchor);
        }
        
        // Create a data URL with the HTML content
        final String dataUrl = Uri.dataFromString(
          displayContent,
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ).toString();
        
        // Load the data URL first
        await _controller.loadRequest(Uri.parse(dataUrl));
        
        // If there's an anchor, navigate to it after loading
        if (anchor != null && anchor.isNotEmpty) {
          // Wait for the page to load completely
          await Future.delayed(const Duration(milliseconds: 2000));
          
          // Try to scroll to the anchor using JavaScript with compatibility checks
          try {
            await _controller.runJavaScript('''
              try {
                var element = document.getElementById('${anchor}') || document.querySelector('a[name="${anchor}"]') || document.querySelector('[name="${anchor}"]');
                if (element) {
                  if (element.scrollIntoView) {
                    element.scrollIntoView({behavior: 'smooth', block: 'start'});
                  } else {
                    element.scrollIntoView();
                  }
                  element.style.color = 'black';
                  console.log('Scrolled to anchor: $anchor');
                } else {
                  console.log('Element with anchor $anchor not found');
                  // Try to find any element containing the anchor text
                  var allElements = document.querySelectorAll('*');
                  for (var i = 0; i < allElements.length; i++) {
                    if (allElements[i].textContent && allElements[i].textContent.includes('${anchor}')) {
                      if (allElements[i].scrollIntoView) {
                        allElements[i].scrollIntoView({behavior: 'smooth', block: 'start'});
                      } else {
                        allElements[i].scrollIntoView();
                      }
                      allElements[i].style.color = 'black';
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Extract article number from anchor or use widget title
    String articleNumber = widget.anchor ?? (widget.url.contains('#') ? widget.url.split('#')[1] : '1');
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
       
            // Split the title into two lines
            if (widget.title.isNotEmpty) ...[
              Text(
                widget.title.split(' ').take((widget.title.split(' ').length / 2).round()).join(' '),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                widget.title.split(' ').skip((widget.title.split(' ').length / 2).round()).join(' '),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ] else ...[
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
        toolbarHeight: 100, // Increased height to accommodate three lines
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
        backgroundColor: appTheme.primaryColor,
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

  /// Extract specific article content from HTML based on anchor
  Future<String> _extractArticleContent(String htmlContent, String anchor) async {
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
        dynamic articleSection = targetElement;
        
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
          articleSection = articleSection.parent;
        }
        
        // If we found a good container, use it, otherwise use the target element
        final contentElement = articleSection ?? targetElement;
        
        // Create a new HTML document with just the article content
        final articleNumber = anchor ?? '1'; // Use anchor as article number, default to 1 if not available
        final articleHtml = '''
<!DOCTYPE html>
<html>
<head>
   <meta charset="utf-8">
   <meta name="viewport" content="width=device-width, initial-scale=1.0">
   <title>Article numéro ${anchor ?? '1'} - ${_articleTitle ?? 'Article'}</title>
   <style>
       body {
           font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
           line-height: 1.6;
           color: black;
           max-width: 800px;
           margin: 0 auto;
           padding: 20px;
           background-color: #ffffff;
       }
       h1, h2, h3, h4, h5, h6 {
           color: black;
           margin-top: 1.5em;
           margin-bottom: 0.5em;
           padding-bottom: 0.3em;
       }
       p {
           margin-bottom: 1em;
           color: black;
       }

       .article-header {
           text-align: center;
           margin-bottom: 2em;
           padding: 1em;
       }
       .article-number {
           font-size: 1.2em;
           font-weight: bold;
           color: black;
           margin-bottom: 0.5em;
       }
       .article-title {
           font-size: 1.5em;
           font-weight: bold;
           color: black;
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
           p {
               color: #e0e0e0;
           }
           .article-number {
               color: #ffffff;
           }
           .article-title {
               color: #ffffff;
           }
       }
   </style>
</head>
<body>



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
    <title>Article numéro ${anchor ?? '1'} - ${_articleTitle ?? 'Article'}</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            line-height: 1.6;
            color: black;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #ffffff;
        }
        .error-message {
            background-color: #fff3cd;
            color: black;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        @media (prefers-color-scheme: dark) {
            body {
                background-color: #1a1a1a;
                color: #e0e0e0;
            }
            .error-message {
                background-color: #4a3f00;
                color: #ffd700;
            }
        }
    </style>
</head>
<body>
    <div class="error-message">
        <strong>Avertissement:</strong> L'ancre "$anchor" n'a pas été trouvée dans le document.
        Affichage du contenu complet.
    </div>
    <div>
        $htmlContent
    </div>
</body>
</html>
        ''';
      }
    } catch (e) {
      print("Error extracting article content: $e");
      // Return full content if extraction fails
      return htmlContent;
    }
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