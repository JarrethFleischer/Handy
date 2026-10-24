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
  static const Color _navy = Color(0xFF14304A);
  static const Color _page = Color(0xFFEAF5FF);
  static const Color _header = Color(0xFF9AD5FF);
  static const Color _button = Color(0xFF67B5FF);

  final _formKey = GlobalKey<FormState>();
  final _content = TextEditingController();
  bool _loading = false;

  int _selectedRating = 4; // 0 to 4
  String _selectedCategory = '💡 Idea';

  final List<String> _emojis = ['😠', '😕', '😐', '🙂', '🤩'];
  final List<String> _categories = [
    '💡 Idea',
    '🐞 Bug',
    '🎨 Design',
    '❤️ Other',
  ];

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final emoji = _emojis[_selectedRating];
    final formattedContent =
        '[$emoji ${_selectedRating + 1}/5 | $_selectedCategory] ${_content.text.trim()}';

    setState(() => _loading = true);
    try {
      await FeedbackService.create(content: formattedContent);
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
  Future<void> _showResult({
    required bool success,
    required String message,
  }) async {
    if (!mounted) return;
    final bool wasDialog = widget.isDialog;
    if (wasDialog) Navigator.pop(context); // close feedback card
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: success
                      ? const Color(0xFFE7F6EA)
                      : const Color(0xFFFDECEC),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  success ? Icons.check_rounded : Icons.close_rounded,
                  color: success
                      ? const Color(0xFF237A22)
                      : const Color(0xFFC93B2B),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _button,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Feedback',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _navy,
                    ),
                  ),
                ),
                if (widget.isDialog)
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: _navy, size: 20),
                  ),
              ],
            ),
            const Text(
              'How is Handy so far?',
              style: TextStyle(fontSize: 14, color: _navy),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_emojis.length, (i) {
                final isSelected = _selectedRating == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? _header : _page,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _emojis[i],
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedCategory = value);
              },
              style: const TextStyle(
                color: _navy,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: _page,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _button, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _content,
              minLines: 4,
              maxLines: 6,
              style: const TextStyle(color: _navy, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Tell us what you think',
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                filled: true,
                fillColor: _page,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _button, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFC93B2B)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFC93B2B),
                    width: 1.5,
                  ),
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please write something'
                  : null,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _button,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _header,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Send Feedback',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
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
      backgroundColor: _page,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: _header,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(
                    MediaQuery.of(context).size.width,
                    150,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                    color: _navy,
                  ),
                  label: const Text(
                    'Back',
                    style: TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: _buildCardContent(context),
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
