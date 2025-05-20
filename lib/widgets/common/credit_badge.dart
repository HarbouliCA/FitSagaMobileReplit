import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/credit_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';

class CreditBadge extends StatelessWidget {
  final bool showInDrawer;
  
  const CreditBadge({
    Key? key,
    this.showInDrawer = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CreditProvider>(
      builder: (context, creditProvider, _) {
        final isLoading = creditProvider.loading;
        final isUnlimited = creditProvider.hasUnlimitedCredits;
        final credits = creditProvider.displayCredits;
        final intervalCredits = creditProvider.intervalCredits;
        
        // Determine credit display color based on value
        Color creditColor = AppTheme.creditColor;
        if (!isUnlimited) {
          final numericCredits = int.tryParse(credits) ?? 0;
          if (numericCredits <= 1) {
            creditColor = AppTheme.creditEmptyColor;
          } else if (numericCredits <= 3) {
            creditColor = AppTheme.creditLowColor;
          }
        }
        
        if (showInDrawer) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  isLoading ? '...' : 'Credits: $credits',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (intervalCredits > 0 && !isUnlimited) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(+$intervalCredits)',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          );
        } else {
          return Container(
            margin: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () {
                _showCreditInfoDialog(context, creditProvider);
              },
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isUnlimited 
                      ? AppTheme.secondaryColor
                      : creditColor,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUnlimited ? Icons.all_inclusive : Icons.stars,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isLoading ? '...' : credits,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
  
  void _showCreditInfoDialog(BuildContext context, CreditProvider creditProvider) {
    final isUnlimited = creditProvider.hasUnlimitedCredits;
    final credits = creditProvider.displayCredits;
    final intervalCredits = creditProvider.intervalCredits;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Credits'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isUnlimited ? Icons.all_inclusive : Icons.stars,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  isUnlimited 
                      ? 'Unlimited access' 
                      : 'Available credits: $credits',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Credits are used to book sessions at the gym. Each activity requires a specific number of credits.',
              style: TextStyle(fontSize: 14),
            ),
            if (intervalCredits > 0 && !isUnlimited) ...[
              const SizedBox(height: 16),
              Text(
                'You also have $intervalCredits interval credits available.',
                style: const TextStyle(fontSize: 14),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Credits are replenished based on your subscription plan.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
