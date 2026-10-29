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
  static const Color _ink = Color(0xFF14181B);
  static const Color _yellow = Color(0xFFFFD86B);

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _ink, width: 1.8),
            boxShadow: const [
              BoxShadow(
                color: _ink,
                offset: Offset(0, 5),
                blurRadius: 0,
              ),
            ],
          ),
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
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _yellow,
                    foregroundColor: _ink,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: _ink, width: 1.8),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ink, width: 1.8),
        boxShadow: const [
          BoxShadow(color: _ink, offset: Offset(0, 5), blurRadius: 0),
        ],
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
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _ink,
                    ),
                  ),
                ),
                if (widget.isDialog)
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: _ink, size: 20),
                  ),
              ],
            ),
            const Text(
              'How is Handy so far?',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF57636C),
              ),
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
                      color: isSelected ? _yellow : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _ink,
                        width: isSelected ? 1.8 : 1.2,
                      ),
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
                fontFamily: 'Inter',
                color: _ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _ink, width: 1.8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _ink, width: 1.8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _ink, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _content,
              minLines: 4,
              maxLines: 6,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: _ink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Tell us what you think',
                hintStyle: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF57636C),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _ink, width: 1.8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _ink, width: 1.8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _ink, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFFF5252)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF5252),
                    width: 1.8,
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
                  backgroundColor: _yellow,
                  foregroundColor: _ink,
                  disabledBackgroundColor: const Color(0xFFFFE7A3),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: _ink, width: 1.8),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: _ink,
                        ),
                      )
                    : const Text(
                        'Send Feedback',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
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
      backgroundColor: const Color(0xFFF3FAFF),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFDDF1FF), Color(0xFFF3FAFF)],
                ),
              ),
              child: CustomPaint(painter: _DotGridPainter()),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(
                          side: BorderSide(color: _ink, width: 1.4),
                        ),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            if (Navigator.canPop(context)) Navigator.pop(context);
                          },
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: _ink,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Feedback',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: _ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22A2F2).withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    const spacing = 26.0;
    for (double x = 14; x < size.width; x += spacing) {
      for (double y = 14; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
