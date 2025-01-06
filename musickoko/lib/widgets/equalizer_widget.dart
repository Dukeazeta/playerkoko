import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import '../models/settings.dart';

class EqualizerWidget extends StatefulWidget {
  final AudioHandler? audioHandler;
  final PlayerSettings settings;

  const EqualizerWidget({
    super.key,
    required this.audioHandler,
    required this.settings,
  });

  @override
  State<EqualizerWidget> createState() => _EqualizerWidgetState();
}

class _EqualizerWidgetState extends State<EqualizerWidget> {
  final Map<int, String> _bandLabels = {
    60: '60 Hz',
    170: '170 Hz',
    310: '310 Hz',
    600: '600 Hz',
    1000: '1 kHz',
    3000: '3 kHz',
    6000: '6 kHz',
    12000: '12 kHz',
    14000: '14 kHz',
    16000: '16 kHz',
  };

  late Map<int, double> _bands;

  @override
  void initState() {
    super.initState();
    _bands = Map.from(widget.settings.equalizerBands);
    if (_bands.isEmpty) {
      _bands = Map.fromIterables(
        _bandLabels.keys,
        List.generate(_bandLabels.length, (index) => 0.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Equalizer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: _resetEqualizer,
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _loadPreset('pop'),
                    child: const Text('Pop'),
                  ),
                  TextButton(
                    onPressed: () => _loadPreset('rock'),
                    child: const Text('Rock'),
                  ),
                  TextButton(
                    onPressed: () => _loadPreset('jazz'),
                    child: const Text('Jazz'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _bands.entries.map((entry) {
                return _buildBandSlider(
                  frequency: entry.key,
                  value: entry.value,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBandSlider({
    required int frequency,
    required double value,
  }) {
    return Column(
      children: [
        Expanded(
          child: RotatedBox(
            quarterTurns: -1,
            child: Slider(
              value: value,
              min: -12.0,
              max: 12.0,
              divisions: 24,
              onChanged: (newValue) {
                setState(() {
                  _bands[frequency] = newValue;
                });
                _updateEqualizer();
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _bandLabels[frequency]!,
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          '${value.toStringAsFixed(1)} dB',
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  void _resetEqualizer() {
    setState(() {
      _bands = Map.fromIterables(
        _bandLabels.keys,
        List.generate(_bandLabels.length, (index) => 0.0),
      );
    });
    _updateEqualizer();
  }

  void _loadPreset(String preset) {
    final Map<int, double> presetValues = switch (preset) {
      'pop' => {
          60: 2.0,
          170: 1.0,
          310: 0.0,
          600: -1.0,
          1000: -2.0,
          3000: -1.0,
          6000: 1.0,
          12000: 2.0,
          14000: 3.0,
          16000: 3.0,
        },
      'rock' => {
          60: 3.0,
          170: 2.0,
          310: 1.0,
          600: 0.0,
          1000: -1.0,
          3000: 0.0,
          6000: 1.5,
          12000: 2.5,
          14000: 3.0,
          16000: 3.5,
        },
      'jazz' => {
          60: 2.0,
          170: 1.0,
          310: 0.0,
          600: 0.5,
          1000: 1.0,
          3000: 2.0,
          6000: 1.0,
          12000: 0.5,
          14000: 0.0,
          16000: -0.5,
        },
      _ => _bands,
    };

    setState(() {
      _bands = Map.from(presetValues);
    });
    _updateEqualizer();
  }

  void _updateEqualizer() {
    if (widget.audioHandler != null) {
      widget.audioHandler!.customAction('setEqualizer', {
        'enabled': true,
        'bands': _bands,
      });
    }
  }
}
