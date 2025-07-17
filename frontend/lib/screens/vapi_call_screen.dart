import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:qalbcare/utils/constants.dart';
import 'package:qalbcare/widgets/islamic_loading_indicator.dart';
import 'package:qalbcare/widgets/islamic_decorations.dart';
import 'package:qalbcare/services/environment_service.dart';
import 'package:qalbcare/services/firestore_service.dart';
import 'dart:async';

class VapiCallScreen extends StatefulWidget {
  final String? userName;
  
  const VapiCallScreen({super.key, this.userName});

  @override
  State<VapiCallScreen> createState() => _VapiCallScreenState();
}

class _VapiCallScreenState extends State<VapiCallScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  final FirestoreService _firestoreService = FirestoreService();
  
  Timer? _callTimer;
  int _remainingSeconds = 0;
  bool _isCallActive = false;
  int _availableExtraMinutes = 0;

  @override
  void initState() {
    super.initState();
    _initializeCallTimer();
    _initializeWebView();
  }

  Future<void> _initializeCallTimer() async {
    try {
      _availableExtraMinutes = await _firestoreService.getVapiCallTimeInMinutes();
      _remainingSeconds = _availableExtraMinutes * 60;
      
      if (_availableExtraMinutes > 0) {
        _startCallTimer();
      }
    } catch (e) {
      debugPrint('Error initializing call timer: $e');
    }
  }

  void _startCallTimer() {
    _isCallActive = true;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _endCall();
      }
    });
  }

  void _endCall() {
    _callTimer?.cancel();
    _isCallActive = false;
    
    // Deduct points for the time used
    final minutesUsed = _availableExtraMinutes - (_remainingSeconds / 60).ceil();
    if (minutesUsed > 0) {
      _firestoreService.deductVapiExtendedPoints(minutesUsed);
    }
    
    // Show dialog and navigate back
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: IslamicContainer(
          backgroundColor: AppColors.cardBackground,
          borderColor: AppColors.primaryGreen,
          elevation: IslamicUI.elevationMedium,
          borderRadius: IslamicUI.borderRadiusLarge,
          padding: const EdgeInsets.all(IslamicUI.spacingLarge),
          margin: const EdgeInsets.all(IslamicUI.spacingMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(IslamicUI.spacingMedium),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.call_end,
                  size: 40,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: IslamicUI.spacingMedium),
              // Title
              Text(
                'Call Ended',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IslamicUI.spacingSmall),
              // Content
              Text(
                'Your allocated time has finished. Thank you for using our service.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: IslamicUI.spacingLarge),
              // Islamic decorative divider
              const IslamicDivider(
                height: 20,
                color: AppColors.primaryGreen,
                thickness: 1.0,
                indent: 0,
                endIndent: 0,
              ),
              const SizedBox(height: IslamicUI.spacingMedium),
              // Button
              IslamicButton(
                text: 'OK',
                backgroundColor: AppColors.primaryGreen,
                textColor: Colors.white,
                borderColor: AppColors.secondaryGold,
                icon: Icons.check,
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _initializeWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading progress if needed
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
              hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              isLoading = false;
              hasError = true;
              errorMessage =
                  'Failed to load therapist interface. Please check your internet connection.';
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation for the therapy interface
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('${EnvironmentService.vapiTherapistUrl}${widget.userName != null ? '?userName=${Uri.encodeComponent(widget.userName!)}' : ''}'));
  }

  void _refreshWebView() {
    setState(() {
      hasError = false;
      isLoading = true;
    });
    controller.reload();
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Talking to Mustafa',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (_isCallActive && _remainingSeconds > 0)
              Text(
                'Time remaining: ${_formatTime(_remainingSeconds)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (hasError)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: _refreshWebView,
            ),
        ],
      ),
      body: Stack(
        children: [
          // WebView
          if (!hasError) WebViewWidget(controller: controller),

          // Error Screen
          if (hasError)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Connection Error',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    errorMessage ??
                        'Unable to connect to the therapist interface.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 30),
                    ElevatedButton.icon(
                    onPressed: _refreshWebView,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Back to Chat',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Loading Indicator
          if (isLoading && !hasError)
            Container(
              color: AppColors.background.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
const IslamicLoadingIndicator(
                      showQuote: false,
                      size: 50,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Connecting to Mustafa...',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Please wait while we prepare your voice therapy session',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
