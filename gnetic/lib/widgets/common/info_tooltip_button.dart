import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'educational_popup_dialog.dart';

class InfoTooltipButton extends StatelessWidget {
  final String topicKey;
  final double size;

  const InfoTooltipButton({
    super.key,
    required this.topicKey,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => EducationalPopupDialog.show(context, topicKey),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.help_outline_rounded,
          size: size,
          color: AppColors.gold,
        ),
      ),
    );
  }
}
