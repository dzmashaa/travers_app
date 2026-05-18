import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travers_app/core/utils/time_extension.dart';

class ManualTimeEditDialog extends StatefulWidget {
  final int initialMilliseconds;

  const ManualTimeEditDialog({super.key, required this.initialMilliseconds});

  @override
  State<ManualTimeEditDialog> createState() => _ManualTimeEditDialogState();
}

class _ManualTimeEditDialogState extends State<ManualTimeEditDialog> {
  late TextEditingController _minController;
  late TextEditingController _secController;
  late TextEditingController _hdController;

  @override
  void initState() {
    super.initState();
    final timeParts = widget.initialMilliseconds.toTimeParts();
    _minController = TextEditingController(text: timeParts.min);
    _secController = TextEditingController(text: timeParts.sec);
    _hdController = TextEditingController(text: timeParts.hd);
  }

  @override
  void dispose() {
    _minController.dispose();
    _secController.dispose();
    _hdController.dispose();
    super.dispose();
  }

  void _save() {
    final minText = _minController.text.trim();
    final secText = _secController.text.trim();
    final hdText = _hdController.text.trim();

    final min = int.tryParse(minText.isEmpty ? '0' : minText) ?? 0;
    final sec = int.tryParse(secText.isEmpty ? '0' : secText) ?? 0;
    final hd = int.tryParse(hdText.isEmpty ? '0' : hdText) ?? 0;

    final totalMs = (min * 60000) + (sec * 1000) + (hd * 10);
    Navigator.pop(context, totalMs);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Редагування часу', textAlign: TextAlign.center),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimeField(_minController, 'Хв'),
          const Text(
            ' : ',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          _buildTimeField(_secController, 'Сек'),
          const Text(
            ' . ',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          _buildTimeField(_hdController, 'Соті'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Скасувати', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Зберегти'),
        ),
      ],
    );
  }

  Widget _buildTimeField(TextEditingController controller, String label) {
    return SizedBox(
      width: 54,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        maxLength: 2,
        decoration: InputDecoration(
          counterText: '',
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
