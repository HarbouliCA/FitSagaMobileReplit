import 'package:flutter/material.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/providers/tutorial_provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TutorialProgressTracker extends StatelessWidget {
  final String tutorialId;
  final bool showDetails;
  final VoidCallback? onContinue;

  const TutorialProgressTracker({
    Key? key,
    required this.tutorialId,
    this.showDetails = false,
    this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tutorialProvider = Provider.of<TutorialProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Can't show progress if not authenticated
    if (!authProvider.isAuthenticated || authProvider.currentUser == null) {
      return _buildLoginPrompt(context);
    }
    
    final progress = tutorialProvider.getProgressForTutorial(tutorialId);
    
    // No progress yet
    if (progress == null) {
      return _buildNoProgressView(context);
    }
    
    // Basic progress view or detailed view
    return showDetails
        ? _buildDetailedProgressView(context, progress)
        : _buildSimpleProgressView(context, progress);
  }
  
  Widget _buildLoginPrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          const Text(
            'Sign in to track your progress',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create an account or sign in to save your progress and continue where you left off.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to login page
              // This should be implemented in your app's navigation
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              minimumSize: const Size(double.infinity, 44),
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoProgressView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          const Text(
            'Start this tutorial',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You haven\'t started this tutorial yet. Begin watching to track your progress.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              minimumSize: const Size(double.infinity, 44),
            ),
            child: const Text('Start Now'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSimpleProgressView(BuildContext context, TutorialProgressModel progress) {
    final tutorial = Provider.of<TutorialProvider>(context).getTutorialById(tutorialId);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: progress.isCompleted ? AppTheme.successColor.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: progress.isCompleted ? AppTheme.successColor : Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progress.isCompleted 
                    ? 'Completed' 
                    : 'In Progress - ${(progress.progress * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: progress.isCompleted ? AppTheme.successColor : AppTheme.textPrimaryColor,
                ),
              ),
              if (progress.isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress.isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          if (tutorial != null && !progress.isCompleted && progress.progress > 0)
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                minimumSize: const Size(double.infinity, 44),
              ),
              child: Text(
                'Continue (${_formatTime(progress.lastWatchedPosition)})',
              ),
            ),
          if (progress.isCompleted && progress.userRating != null)
            _buildRatingIndicator(progress.userRating!),
        ],
      ),
    );
  }
  
  Widget _buildDetailedProgressView(BuildContext context, TutorialProgressModel progress) {
    final tutorialProvider = Provider.of<TutorialProvider>(context);
    final tutorial = tutorialProvider.getTutorialById(tutorialId);
    
    if (tutorial == null) {
      return const Center(
        child: Text('Tutorial not found'),
      );
    }
    
    final videoTotalDuration = tutorial.durationMinutes * 60; // Convert to seconds
    final watchPercentage = videoTotalDuration > 0 
        ? (progress.lastWatchedPosition / videoTotalDuration).clamp(0.0, 1.0) 
        : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.play_circle_filled, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: progress.isCompleted 
                      ? AppTheme.successColor 
                      : AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  progress.isCompleted 
                      ? 'Completed' 
                      : '${(progress.progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Progress bar with time indicators
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.progress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress.isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
                  ),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTime(progress.lastWatchedPosition),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    _formatTime(videoTotalDuration),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Watch time statistics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.timelapse,
                label: 'Last position',
                value: _formatTime(progress.lastWatchedPosition),
              ),
              _buildStatItem(
                icon: Icons.calendar_today,
                label: 'Last watched',
                value: DateFormat.MMMd().format(progress.lastAccessedAt),
              ),
              _buildStatItem(
                icon: Icons.percent,
                label: 'Completion',
                value: '${(progress.progress * 100).toInt()}%',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Rating section
          if (progress.isCompleted)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Rating',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                progress.userRating != null
                    ? _buildRatingIndicator(progress.userRating!)
                    : const Text(
                        'You haven\'t rated this tutorial yet.',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ],
            ),
          
          const SizedBox(height: 20),
          
          // Continue button
          if (!progress.isCompleted)
            ElevatedButton.icon(
              onPressed: onContinue,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Continue Learning'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          
          if (progress.isCompleted && progress.userRating == null)
            ElevatedButton.icon(
              onPressed: () => _showRatingDialog(context),
              icon: const Icon(Icons.star),
              label: const Text('Rate this Tutorial'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildRatingIndicator(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: AppTheme.accentColor,
            size: 20,
          );
        }),
        const SizedBox(width: 8),
        Text(
          '$rating/5',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const RateTutorialDialog(tutorialId: ''),
    );
  }
  
  String _formatTime(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }
}

class RateTutorialDialog extends StatefulWidget {
  final String tutorialId;
  
  const RateTutorialDialog({
    Key? key,
    required this.tutorialId,
  }) : super(key: key);

  @override
  State<RateTutorialDialog> createState() => _RateTutorialDialogState();
}

class _RateTutorialDialogState extends State<RateTutorialDialog> {
  int _rating = 0;
  bool _isSubmitting = false;
  
  Future<void> _submitRating() async {
    if (_rating == 0) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      final success = await tutorialProvider.rateTutorial(
        userId: authProvider.currentUser!.id,
        tutorialId: widget.tutorialId,
        rating: _rating,
      );
      
      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you for your rating!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tutorialProvider.error ?? 'Failed to submit rating'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    } else {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to be logged in to rate tutorials'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate this Tutorial'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'What did you think of this tutorial?',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 20),
          if (_isSubmitting)
            const CircularProgressIndicator()
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: AppTheme.accentColor,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
          if (_rating > 0)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _getRatingText(_rating),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _rating > 0 && !_isSubmitting ? _submitRating : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }
  
  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}