import 'package:flutter/material.dart';

import '../settings_mock_data.dart';

class SettingsSidePanel extends StatelessWidget {
  const SettingsSidePanel({
    required this.activeModules,
    required this.activities,
    required this.checklist,
    super.key,
  });

  final List<String> activeModules;
  final List<SettingsActivityMock> activities;
  final List<SetupChecklistMock> checklist;

  @override
  Widget build(BuildContext context) {
    final modules = activeModules
        .where(
          (module) =>
              ['Dashboard', 'Stok', 'Finans', 'AI Asistan'].contains(module),
        )
        .toList();

    return Column(
      children: [
        _SettingsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AKTİF MODÜLLER',
                style: TextStyle(
                  color: Color(0xFF43474E),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 4.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 8,
                children: [
                  for (final module in modules)
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF2C694E),
                          size: 14,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            module,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SettingsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Son Etkinlikler',
                style: TextStyle(
                  color: Color(0xFF191C1D),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              _ActivityRow(
                icon: Icons.settings,
                title: 'AI Modu Değiştirildi',
                time: '10 dakika önce',
              ),
              const Divider(height: 1, color: Color(0xFFE1E3E4)),
              _ActivityRow(
                icon: Icons.notifications_outlined,
                title: 'Bildirim Saati Güncellendi',
                time: 'Dün 18:45',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.time,
  });

  final IconData icon;
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE7E8E9),
            child: Icon(icon, color: const Color(0xFF002045), size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF191C1D),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF43474E),
                    fontSize: 11,
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
