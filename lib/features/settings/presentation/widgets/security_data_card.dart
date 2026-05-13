import 'package:flutter/material.dart';

class SecurityDataCard extends StatelessWidget {
  const SecurityDataCard({
    required this.notes,
    required this.onResetDemoData,
    required this.onCheckSystem,
    super.key,
  });

  final List<String> notes;
  final VoidCallback onResetDemoData;
  final VoidCallback onCheckSystem;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDAD6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: Color(0xFF93000A),
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sistem şu anda demo modunda çalışmaktadır. Veriler bulut ile senkronize edilmez.',
                    style: TextStyle(
                      color: Color(0xFF93000A),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: onCheckSystem,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF002045),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: const Text('Sistem Durumunu Kontrol Et'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: onResetDemoData,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF002045),
                side: const BorderSide(color: Color(0xFF002045)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: const Text('Demo Verilerini Sıfırla'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C6CF)),
      ),
      child: child,
    );
  }
}
