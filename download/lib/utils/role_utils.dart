import 'package:fitsaga/config/constants.dart';

class RoleUtils {
  // Check if a user has specific role
  static bool hasRole(String userRole, String requiredRole) {
    if (userRole == AppConstants.roleAdmin) {
      // Admin has all roles
      return true;
    }
    
    if (userRole == AppConstants.roleInstructor && 
        requiredRole == AppConstants.roleInstructor) {
      return true;
    }
    
    if ((userRole == AppConstants.roleUser || userRole == AppConstants.roleClient) && 
        (requiredRole == AppConstants.roleUser || requiredRole == AppConstants.roleClient)) {
      return true;
    }
    
    return userRole == requiredRole;
  }
  
  // Get display name for role
  static String getRoleDisplayName(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return 'Administrator';
      case AppConstants.roleInstructor:
        return 'Instructor';
      case AppConstants.roleClient:
        return 'Client';
      case AppConstants.roleUser:
        return 'User';
      default:
        return 'User';
    }
  }
  
  // Get role color
  static int getRoleColor(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return 0xFF9C27B0; // Purple
      case AppConstants.roleInstructor:
        return 0xFF1976D2; // Blue
      case AppConstants.roleClient:
      case AppConstants.roleUser:
        return 0xFF4CAF50; // Green
      default:
        return 0xFF9E9E9E; // Grey
    }
  }
  
  // Check if user has admin access
  static bool hasAdminAccess(String role) {
    return role == AppConstants.roleAdmin;
  }
  
  // Check if user has instructor access
  static bool hasInstructorAccess(String role) {
    return role == AppConstants.roleAdmin || role == AppConstants.roleInstructor;
  }
  
  // Check if user has client access
  static bool hasClientAccess(String role) {
    // All roles have client access
    return true;
  }
  
  // Get home route based on role
  static String getHomeRouteForRole(String role) {
    if (role == AppConstants.roleAdmin) {
      return '/admin/dashboard';
    } else if (role == AppConstants.roleInstructor) {
      return '/instructor/dashboard';
    } else {
      return '/home';
    }
  }
  
  // Get role icon
  static String getRoleIcon(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return 'shield';
      case AppConstants.roleInstructor:
        return 'award';
      case AppConstants.roleClient:
      case AppConstants.roleUser:
        return 'user';
      default:
        return 'user';
    }
  }
  
  // Check if can manage users
  static bool canManageUsers(String role) {
    return role == AppConstants.roleAdmin;
  }
  
  // Check if can manage activities
  static bool canManageActivities(String role) {
    return role == AppConstants.roleAdmin;
  }
  
  // Check if can manage sessions
  static bool canManageSessions(String role) {
    return role == AppConstants.roleAdmin || role == AppConstants.roleInstructor;
  }
  
  // Check if can manage tutorials
  static bool canManageTutorials(String role) {
    return role == AppConstants.roleAdmin;
  }
  
  // Check if can adjust credits
  static bool canAdjustCredits(String role) {
    return role == AppConstants.roleAdmin;
  }
}
