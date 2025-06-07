import 'package:flutter/material.dart';

class SpeechAdjustment extends StatefulWidget {
  final double initialSpeed;
  final String initialAccent;

  const SpeechAdjustment({
    super.key,
    required this.initialSpeed,
    required this.initialAccent,
  });

  @override
  State<SpeechAdjustment> createState() => _SpeechAdjustmentState();
}

class _SpeechAdjustmentState extends State<SpeechAdjustment> {
  late double _speechSpeed;
  late String _selectedAccent;

  final Map<String, String> _accents = {
    'US English': 'en-US',
    'UK English': 'en-GB',
    'Australian': 'en-AU',
    'Indian': 'en-IN',
  };

  @override
  void initState() {
    super.initState();
    _speechSpeed = widget.initialSpeed.clamp(0.1, 1.0);

    _selectedAccent =
        _accents.containsKey(widget.initialAccent)
            ? widget.initialAccent
            : 'US English';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Speech Settings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Speed", style: TextStyle(fontSize: 16)),
                Text(_speechSpeed.toStringAsFixed(2)),
              ],
            ),
            Slider(
              value: _speechSpeed,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: _speechSpeed.toStringAsFixed(2),
              onChanged: (value) {
                setState(() {
                  _speechSpeed = value;
                });
              },
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Accent", style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedAccent,
              items:
                  _accents.keys.map((accent) {
                    return DropdownMenuItem<String>(
                      value: accent,
                      child: Text(accent),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedAccent = value;
                  });
                }
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                final languageCode = _accents[_selectedAccent] ?? 'en-US';
                Navigator.of(
                  context,
                ).pop({'speed': _speechSpeed, 'accent': languageCode});
              },
              child: const Text("Apply"),
            ),
          ],
        ),
      ),
    );
  }
}
