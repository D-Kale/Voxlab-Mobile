import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
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
            if (showVoxi) ...[
              Image.asset(
                voxiAsset,
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
            ],
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.error, width: 3),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 48,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.accentRed, width: 3.5),
            boxShadow: const [
              BoxShadow(
                color: AppColors.accentRed,
                offset: Offset(0, 5),
                blurRadius: 0,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Color(0x33D93B27),
                offset: Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh_rounded, size: 20, color: AppColors.accentRed),
              const SizedBox(width: 10),
              Text(
                'Reintentar',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBrown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}