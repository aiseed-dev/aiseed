import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Webサイトプレビュー画面
class WebPreviewScreen extends StatefulWidget {
  final String html;

  const WebPreviewScreen({super.key, required this.html});

  @override
  State<WebPreviewScreen> createState() => _WebPreviewScreenState();
}

class _WebPreviewScreenState extends State<WebPreviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadHtmlString(widget.html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プレビュー'),
        backgroundColor: AppColors.spatial.withOpacity(0.1),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'HTMLをコピー',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.html));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('HTMLをコピーしました'),
                  backgroundColor: AppColors.naturalistic,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'HTMLを表示',
            onPressed: () => _showHtmlCode(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.spatial),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'QRコードからこのページが表示されます',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.html));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('HTMLをコピーしました。Cloudflare Pagesにアップロードして公開できます。'),
                      backgroundColor: AppColors.naturalistic,
                      duration: Duration(seconds: 4),
                    ),
                  );
                },
                icon: const Icon(Icons.cloud_upload, size: 18),
                label: const Text('公開準備'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.spatial,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHtmlCode() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Text('🔧', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('HTMLコード', style: AppTextStyles.titleMedium),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.html));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('HTMLをコピーしました'),
                          backgroundColor: AppColors.naturalistic,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    widget.html,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Color(0xFFD4D4D4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
