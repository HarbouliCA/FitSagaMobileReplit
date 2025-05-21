# FitSAGA Mobile App Demo

## App Overview

FitSAGA is a comprehensive gym management application with three user roles (Admin, Instructor, Client), a credit-based session booking system, and an integrated tutorial video library.

## Key Features

### 1. Role-Based Access Control

![Role Selection Screen](https://i.imgur.com/VVq1IHe.png)

- **Admin**: Full access to manage sessions, tutorials, users, and analytics
- **Instructor**: Can create/manage sessions and tutorials
- **Client**: Can book sessions and access tutorials

### 2. Session Management

![Sessions Calendar View](https://i.imgur.com/nkEJTPd.png)

- Calendar view with week navigation
- Filter sessions by type
- View session details with availability indicators
- Book sessions using gym credits or interval credits

### 3. Credit-Based Booking System

![Credit Booking Dialog](https://i.imgur.com/2m9Zj7V.png)

- Clients use credits to book sessions
- Two credit types: Gym Credits and Interval Credits
- Credit deduction with booking confirmation
- Cancellation policy with tiered refunds (100%, 50%, 0% based on timing)

### 4. Tutorial Video System with Firebase Integration

![Video Library Screen](https://i.imgur.com/JL9szf5.png)

The tutorial system integrates directly with your existing Firebase video collection:

- **Browse videos by type** (strength/cardio) and body part
- **Select videos** to combine into complete tutorials
- **Access metadata** from Firebase (plan ID, day number, exercise type)
- **Play videos** directly from Firebase storage

## Video Selection Interface

The tutorial creation screen allows instructors/admins to:

1. Browse all videos from the Firebase collection
2. Filter by exercise type (strength, cardio)
3. Search by title or muscle group
4. View exercise details (targeted muscles, plan/day info)
5. Select multiple videos to create a comprehensive tutorial

## Integration with Firebase Video Collection

The system connects to your Firebase collection containing:

- Video ID and URL
- Thumbnail URL
- Activity name
- Body part targeted
- Exercise type (strength, cardio)
- Day ID and name
- Plan ID

This information is displayed in the video selection interface, allowing efficient browsing and organization of workout content.

## User Interface Flow

### Tutorial Creation (Admin/Instructor)

1. Navigate to "Create Tutorial"
2. Enter tutorial details (name, description, difficulty)
3. Browse the video library
4. Filter videos by type, search by keyword
5. Select videos by tapping on them
6. Review selected videos
7. Create and publish the tutorial

### Viewing Tutorials (Client)

1. Browse available tutorials
2. Filter by category or difficulty
3. Open tutorial details
4. View included exercises
5. Play individual exercise videos
6. Track progress through the tutorial