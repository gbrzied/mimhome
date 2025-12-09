import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart' as htmltopdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class AccordionDocumentWebViewWidget extends StatefulWidget {
  final String url;
  final String title;

  const AccordionDocumentWebViewWidget(this.url, this.title, {Key? key}) : super(key: key);

  @override
  _AccordionDocumentWebViewWidgetState createState() => _AccordionDocumentWebViewWidgetState();
}

class _AccordionDocumentWebViewWidgetState extends State<AccordionDocumentWebViewWidget> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  String pageBody = "";
  dynamic widgets;
  dynamic pdf;

  Future<void> _printPage() async {
    try {
      await _controller.runJavaScript(
          "(function(){Flutter.postMessage(window.document.body.outerHTML)})();");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'impression: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              setState(() {
                _isLoading = false;
                _hasError = true;
                _errorMessage = error.description;
              });
            },
          ),
        )
        ..addJavaScriptChannel(
          'Flutter',
          onMessageReceived: (JavaScriptMessage message) async {
            try {
              pageBody = message.message;
              await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
                pdf = pw.Document();
                widgets = await htmltopdf.HTMLToPdf().convert(pageBody);
                pdf.addPage(pw.MultiPage(build: (context) => widgets));
                return await pdf.save();
              });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur lors de la génération PDF: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );

      // Load the URL with better error handling
      _loadUrl();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Erreur d\'initialisation: $e';
        _isLoading = false;
      });
    }
  }

  void _loadUrl() async {
    try {
      print("Loading URL: ${widget.url}");
      
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
        
        print("Asset path: $assetPath");
        print("Anchor: $anchor");
        
        // Load asset file content
        String fileContent = await rootBundle.loadString(assetPath);
        
        // Create a data URL with the HTML content
        final String dataUrl = Uri.dataFromString(
          fileContent,
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ).toString();
        
        // Load the data URL first
        await _controller.loadRequest(Uri.parse(dataUrl));
        
        // If there's an anchor, navigate to it after loading
        if (anchor != null && anchor.isNotEmpty) {
          // Wait for the page to load completely
          await Future.delayed(const Duration(milliseconds: 2000));
          
          // Try to scroll to the anchor using JavaScript
          try {
            await _controller.runJavaScript('''
              var element = document.getElementById('$anchor') || document.querySelector('a[name="$anchor"]') || document.querySelector('[name="$anchor"]');
              if (element) {
                element.scrollIntoView({behavior: 'smooth', block: 'start'});
                element.style.backgroundColor = '#ffff99';
                element.style.padding = '10px';
                element.style.border = '2px solid #ff6600';
                element.style.borderRadius = '5px';
                element.style.margin = '10px 0';
                console.log('Scrolled to anchor: $anchor');
              } else {
                console.log('Element with anchor $anchor not found');
                // Try to find any element containing the anchor text
                var allElements = document.querySelectorAll('*');
                for (var i = 0; i < allElements.length; i++) {
                  if (allElements[i].textContent && allElements[i].textContent.includes('$anchor')) {
                    allElements[i].scrollIntoView({behavior: 'smooth', block: 'start'});
                    allElements[i].style.backgroundColor = '#ffff99';
                    console.log('Found element containing anchor text');
                    break;
                  }
                }
              }
            ''');
          } catch (jsError) {
            print("JavaScript error: $jsError");
          }
        }
        
      } else {
        await _controller.loadRequest(Uri.parse(widget.url));
      }
    } catch (e) {
      print("Error loading URL: $e");
      setState(() {
        _hasError = true;
        _errorMessage = 'Erreur de chargement: $e\nURL: ${widget.url}';
        _isLoading = false;
      });
    }
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
          if (!_hasError && !_isLoading)
            IconButton(
              icon: const Icon(Icons.print, color: Colors.white),
              onPressed: _printPage,
              tooltip: 'Imprimer',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
              _loadUrl();
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
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
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
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                  _loadUrl();
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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}