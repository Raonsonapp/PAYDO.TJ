import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';

/// Тугмаи хурди "chip" барои пайвандҳои иҷтимоӣ (Instagram/WhatsApp).
/// Дар PHASE 5 (Business Profile) ин ҳамон виҷет истифода мешавад —
/// бинобар ин дар core/widgets на дар profile/ ҷойгир аст.
class SocialLinkChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String url;

  const SocialLinkChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.url,
  });

  factory SocialLinkChip.instagram(String usernameOrUrl) {
    final url = usernameOrUrl.startsWith('http')
        ? usernameOrUrl
        : 'https://instagram.com/${usernameOrUrl.replaceAll('@', '')}';
    return SocialLinkChip(
      icon: Icons.camera_alt_outlined,
      label: 'Instagram',
      color: const Color(0xFFE1306C),
      url: url,
    );
  }

  factory SocialLinkChip.whatsapp(String phoneOrUrl) {
    final url = phoneOrUrl.startsWith('http')
        ? phoneOrUrl
        : 'https://wa.me/${phoneOrUrl.replaceAll(RegExp(r'[^0-9]'), '')}';
    return SocialLinkChip(
      icon: Icons.chat_bubble_outline_rounded,
      label: 'WhatsApp',
      color: const Color(0xFF25D366),
      url: url,
    );
  }

  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label кушода нашуд.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Toggle барои "нишон додан/пинҳон кардан" (phone/age privacy).
class VisibilityToggleRow extends StatelessWidget {
  final String label;
  final bool isVisible;
  final ValueChanged<bool> onChanged;

  const VisibilityToggleRow({
    super.key,
    required this.label,
    required this.isVisible,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 18,
          color: AppColors.textSecondaryLight,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        Switch(
          value: isVisible,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
