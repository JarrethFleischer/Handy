import 'package:flutter/material.dart';
import 'package:handy/services/feedback_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key, this.isDialog = false});

  /// Call this static method from the Profile page button:
  /// onTap: () => FeedbackScreen.show(context)
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54, // Dim background effect
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        child: FeedbackScreen(isDialog: true),
      ),
    );
  }

  final bool isDialog;

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static const Color _brandBlue = Color(0xFF2B9DF4);
  static const Color _brandYellow = Color(0xFFFFD56B);
  static const Color _brandBlack = Color(0xFF0F0F0F);
  static const Color _profileLightBlue = Color(0xFFEAF3FF);
  static const Color _profileCurveBlue = Color(0xFF95C6F6);

  final _formKey = GlobalKey<FormState>();
  final _content = TextEditingController();
  bool _loading = false;

  int _selectedRating = 4; // 0 to 4
  String _selectedCategory = '💡 Idea';

  final List<String> _emojis = ['😠', '😕', '😐', '🙂', '🤩'];
  final List<String> _categories = ['💡 Idea', '🐞 Bug', '🎨 Design', '❤️ Other'];

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // TODO(dynamic-user): replace dummy user ID with the logged-in user's ID
    // (e.g. set CurrentUser.id after login and use it here).
    const int userId = 8;

    final emoji = _emojis[_selectedRating];
    final formattedContent =
        '[$emoji ${_selectedRating + 1}/5 | $_selectedCategory] ${_content.text.trim()}';

    setState(() => _loading = true);
    try {
      await FeedbackService.create(
        userId: userId,
        content: formattedContent,
      );
      _content.clear();
      await _showResult(success: true, message: 'Thank you for your feedback');
    } on FeedbackException catch (e) {
      await _showResult(success: false, message: e.message);
    } catch (e) {
      // Catches anything FeedbackService doesn't wrap (e.g. dart:io is
      // unsupported on web, so the API can never work in the Chrome preview).
      await _showResult(success: false, message: e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Result pop-up shown after submit. In dialog mode the feedback card is
  /// closed first so only the result is visible.
  Future<void> _showResult({required bool success, required String message}) async {
    if (!mounted) return;
    final bool wasDialog = widget.isDialog;
    if (wasDialog) Navigator.pop(context); // close feedback card
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: success ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  success ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                success ? message : 'Error. Reason: $message',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // If opened as a full page (preview), go back after the pop-up closes.
    if (!wasDialog && mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Widget _buildCardContent(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Main Blue Card
        Container(
          margin: const EdgeInsets.only(top: 28),
          padding: const EdgeInsets.fromLTRB(22, 44, 22, 24),
          decoration: BoxDecoration(
            color: _brandBlue,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _brandBlack, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: _brandBlack,
                blurRadius: 0,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Close button if shown as popup dialog
                if (widget.isDialog)
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),

                const Text(
                  'We Value Your\nFeedback!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'How is your experience with Handy so far?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),

                // Emoji Rating Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_emojis.length, (i) {
                      final isSelected = _selectedRating == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedRating = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? _brandYellow : Colors.transparent,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: _brandBlack, width: 2)
                                : null,
                          ),
                          child: Text(
                            _emojis[i],
                            style: TextStyle(fontSize: isSelected ? 26 : 22),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),

                // Category Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? _brandYellow : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _brandBlack, width: 1.5),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: _brandBlack,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Text Input
                TextFormField(
                  controller: _content,
                  minLines: 4,
                  maxLines: 6,
                  style: const TextStyle(color: _brandBlack),
                  decoration: InputDecoration(
                    hintText: 'Tell us what you think...',
                    hintStyle: const TextStyle(
                      color: Colors.black38,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: _brandBlack,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: _brandYellow,
                        width: 2.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: _brandYellow,
                        width: 2,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: _brandYellow,
                        width: 2.5,
                      ),
                    ),
                    errorStyle: const TextStyle(
                      color: _brandYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please write something'
                      : null,
                ),
                const SizedBox(height: 18),

                // Submit Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandBlack,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.black54,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: _brandYellow,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Send Feedback',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Floating Yellow Top Badge
        Positioned(
          top: 0,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _brandYellow,
              shape: BoxShape.circle,
              border: Border.all(color: _brandBlack, width: 2.5),
            ),
            child: const Icon(
              Icons.mark_chat_unread_rounded,
              color: _brandBlack,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // If opened as a dialog pop-up, just return the card directly
    if (widget.isDialog) {
      return SingleChildScrollView(child: _buildCardContent(context));
    }

    // Otherwise, render full screen with the Profile page's light-blue styling as fallback
    return Scaffold(
      backgroundColor: _profileLightBlue,
      body: Stack(
        children: [
          // Profile curved top wave background effect
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: Container(
              decoration: const BoxDecoration(
                color: _profileCurveBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: InkWell(
                    onTap: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: _brandBlack,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: _buildCardContent(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}