import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import 'chunky.dart';
import 'motion.dart';
import '../../../core/network/api_client.dart';
import 'voxi_state.dart';

class ErrorView extends ConsumerWidget {
  const ErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.showVoxi = true,
    this.voxiState = VoxiState.awake,
  });

  final Object error;
  final VoidCallback? onRetry;
  final bool showVoxi;
  final VoxiState voxiState;

  String _message() => friendlyErrorMessage(error);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voxiAsset = voxiState == VoxiState.awake
        ? 'assets/images/voxi_awake.png'
        : 'assets/images/voxi_sleeping.png';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Voxi carries the mood when shown; the alert icon is only the
            // fallback, so the two never stack.
            if (showVoxi)
              Bob(
                child: Image.asset(
                  voxiAsset,
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: AppColors.accentRedContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 40,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              _message(),
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: AppColors.darkBrown,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 28),
              _RetryButton(onPressed: onRetry!),
            ],
          ],
        ),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ChunkyButton(
      label: 'REINTENTAR',
      icon: Icons.refresh_rounded,
      onPressed: onPressed,
    );
  }
}
