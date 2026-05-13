import 'package:flutter/material.dart';

import '../settings_mock_data.dart';

class BusinessProfileCard extends StatelessWidget {
  const BusinessProfileCard({
    required this.profile,
    required this.onSave,
    super.key,
  });

  final BusinessProfileMock profile;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            icon: Icons.store_outlined,
            title: 'İşletme Profili',
          ),
          const SizedBox(height: 16),
          _ProfileField(label: 'İşletme adı', value: profile.businessName),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ProfileField(
                  label: 'Vergi No',
                  value: profile.taxNumber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProfileField(label: 'Sektör', value: profile.industry),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ProfileField(label: 'Şehir', value: profile.city),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProfileField(
                  label: 'Para birimi',
                  value: profile.currency,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Varsayılan KDV',
            style: TextStyle(
              color: Color(0xFF43474E),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final rate in const ['%1', '%10', '%20']) ...[
                Expanded(
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: rate == profile.defaultVatRate
                          ? const Color(0xFF002045)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFC4C6CF)),
                    ),
                    child: Text(
                      rate,
                      style: TextStyle(
                        color: rate == profile.defaultVatRate
                            ? Colors.white
                            : const Color(0xFF191C1D),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (rate != '%20') const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: onSave,
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
              child: const Text('Profili Kaydet'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFC4C6CF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF002045), width: 1.2),
        ),
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF002045), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF191C1D),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}
