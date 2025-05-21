import 'package:flutter/material.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/utils/role_utils.dart';
import 'package:fitsaga/utils/date_formatter.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final bool isEditable;
  final VoidCallback? onEdit;
  
  const ProfileHeader({
    Key? key,
    required this.user,
    this.isEditable = false,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(color: Colors.black, opacity: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile picture
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: user.photoURL != null 
                    ? NetworkImage(user.photoURL!) 
                    : null,
                child: user.photoURL == null 
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ) 
                    : null,
              ),
              
              // Edit button for profile picture
              if (isEditable)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: AppTheme.primaryColor,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: onEdit,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingLarge),
          
          // User name
          Text(
            user.name,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeExtraLarge,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppTheme.spacingSmall),
          
          // User email
          Text(
            user.email,
            style: TextStyle(
              fontSize: AppTheme.fontSizeRegular,
              color: Colors.white.withValues(color: Colors.white, opacity: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppTheme.spacingRegular),
          
          // User role badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(color: Colors.white, opacity: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            ),
            child: Text(
              RoleUtils.getRoleDisplayName(user.role),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingRegular),
          
          // Member since
          Text(
            'Member since ${DateFormatter.formatDate(user.memberSince)}',
            style: TextStyle(
              fontSize: AppTheme.fontSizeSmall,
              color: Colors.white.withValues(color: Colors.white, opacity: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          
          // Edit profile button
          if (isEditable) ...[
            const SizedBox(height: AppTheme.spacingLarge),
            ElevatedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingLarge,
                  vertical: AppTheme.paddingRegular,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
