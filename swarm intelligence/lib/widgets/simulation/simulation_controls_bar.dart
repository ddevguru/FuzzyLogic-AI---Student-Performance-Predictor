import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/simulation_controller.dart';

class SimulationControlsBar extends StatelessWidget {
  final SimulationController controller;

  const SimulationControlsBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRunning = controller.isRunning;
    final isPaused = controller.isPaused;
    final isIdle = controller.isIdle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Playback Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Start / Resume / Pause
              if (isIdle || controller.isCompleted)
                ElevatedButton.icon(
                  onPressed: () => controller.start(),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                  ),
                )
              else if (isRunning)
                ElevatedButton.icon(
                  onPressed: () => controller.pause(),
                  icon: const Icon(Icons.pause_rounded, size: 20),
                  label: const Text('Pause'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.darkBackground,
                  ),
                )
              else if (isPaused)
                ElevatedButton.icon(
                  onPressed: () => controller.resume(),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text('Resume'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              const SizedBox(width: 8),

              // Step Button
              OutlinedButton.icon(
                onPressed: isRunning ? null : () => controller.stepSingle(),
                icon: const Icon(Icons.skip_next_rounded, size: 18),
                label: const Text('Step'),
              ),
              const SizedBox(width: 8),

              // Stop Button
              IconButton.filledTonal(
                tooltip: 'Stop Simulation',
                onPressed: (isRunning || isPaused) ? () => controller.stop() : null,
                icon: const Icon(Icons.stop_rounded, size: 20),
                color: AppColors.error,
              ),
              const SizedBox(width: 4),

              // Reset Button
              IconButton.outlined(
                tooltip: 'Reset to Initial State',
                onPressed: () => controller.reset(),
                icon: const Icon(Icons.refresh_rounded, size: 20),
              ),
            ],
          ),

          // Speed & Progress Indicators
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Speed: ',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: controller.stepDelayMs,
                  dropdownColor: isDark ? AppColors.darkSurface : AppColors.white,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.mainText,
                  ),
                  items: const [
                    DropdownMenuItem(value: 300, child: Text('0.5x (Slow)')),
                    DropdownMenuItem(value: 120, child: Text('1.0x (Normal)')),
                    DropdownMenuItem(value: 50, child: Text('2.0x (Fast)')),
                    DropdownMenuItem(value: 20, child: Text('5.0x (Turbo)')),
                  ],
                  onChanged: (val) {
                    if (val != null) controller.setStepDelay(val);
                  },
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2E47) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Iter: ${controller.currentIteration} / ${controller.maxIterations}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
