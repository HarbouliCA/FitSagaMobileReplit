# Tutorial System Implementation Guide

## Overview
The tutorial system in FitSAGA allows administrators and instructors to create, manage, and publish structured fitness tutorials. These tutorials can include multiple days of content, each containing various exercises with detailed instructions, videos, and images.

## Database Structure

### Tutorial Document
```typescript
{
  id: string;                             // Unique identifier
  title: string;                          // Tutorial title
  category: 'exercise' | 'nutrition';     // Content category
  description: string;                    // Detailed description
  thumbnailUrl?: string;                  // Preview image URL
  author: string;                         // Creator's display name
  authorId: string;                       // Creator's user ID
  duration: number;                       // Total length in minutes
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  isPublished: boolean;                   // Publication status
  createdAt: Timestamp;                   // Creation timestamp
  updatedAt: Timestamp;                   // Last update timestamp
  days: TutorialDay[];                    // Array of tutorial days
  goals?: string[];                       // Learning objectives
  equipmentRequired?: string[];           // Required equipment
  targetAudience?: string;                // Intended audience
}
```

### Tutorial Day
```typescript
{
  id: string;                           // Day identifier
  dayNumber: number;                    // Sequence number
  title: string;                        // Day title
  description: string;                  // Day description
  duration: number;                     // Duration in minutes
  exercises: TutorialExercise[];        // Exercises for this day
  restDay: boolean;                     // Whether this is a rest day
}
```

### Tutorial Exercise
```typescript
{
  id: string;                          // Exercise identifier
  name: string;                        // Exercise name
  description: string;                 // Detailed description
  videoUrl?: string;                   // Instructional video URL
  thumbnailUrl?: string;               // Preview image
  duration: number;                    // Duration in minutes
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  equipment?: string[];                // Required equipment
  muscleGroups?: string[];             // Target muscle groups
  instructions: string[];              // Step-by-step instructions
  sets: number;                        // Number of sets
  reps?: string;                       // Repetitions (can be a range like "8-12")
  restBetweenSets?: number;           // Rest time between sets in seconds
}
```

## Video Tutorials

### Video Storage and Access

1. **Storage Service**
   - Videos are stored in **Azure Blob Storage**
   - Each video is stored with a unique filename in a structured container system
   - Videos are served via secure HTTPS URLs with SAS tokens

2. **Authentication & Authorization**
   - Access is controlled through Azure Storage SAS tokens
   - Read access is available through generated URLs with limited-time tokens
   - Upload/delete operations require appropriate SAS token permissions

3. **Storage Structure**
   ```
   /sagafitvideos/                 # Main container
     /{tutorialId}/                     # Tutorial-specific folder
       /día {dayNumber}/            # Day-specific folder (Spanish naming)
         {videoFile}.mp4           # Video files
   
   /sagathumbnails/                # Thumbnails container
     /tutorials/
       {tutorialId}/
         {imageFile}.jpg          # Thumbnail images
   ```

4. **Azure Configuration**
   - Environment variables required:
     ```env
     NEXT_PUBLIC_AZURE_STORAGE_ACCOUNT_NAME=your_storage_account
     NEXT_PUBLIC_AZURE_STORAGE_SAS_TOKEN=your_sas_token
     ```
   - Containers used:
     - `sagafitvideos` - For video content
     - `sagathumbnails` - For thumbnail images

5. **Video Upload Process**
   - Uses `@azure/storage-blob` package
   - Files are uploaded to user-specific paths
   - Automatic retry mechanism for failed uploads
   - Progress tracking during upload

6. **Video Playback**
   - Direct streaming from Azure Blob Storage
   - URLs are generated with SAS tokens for secure access
   - Supports common video formats (MP4, WebM, etc.)
   - Responsive video player component

7. **Security**
   - SAS tokens have limited lifetime
   - Container-level access policies
   - HTTPS enforced for all operations
   - CORS properly configured for web access

8. **Cost Considerations**
   - Charges apply for:
     - Storage used (GB/month)
     - Egress bandwidth
     - Operations (read/write/delete)
     - Data redundancy (LRS/ZRS/GRS)
   - Lifecycle policies can be set to archive or delete old content

9. **Troubleshooting**
   - **Access Denied**: Verify SAS token is valid and not expired
   - **CORS Issues**: Check Azure CORS settings for the storage account
   - **Upload Failures**: Verify network connectivity and permissions
   - **Playback Issues**: Check video format compatibility and CORS headers

## User Interface

### 1. Tutorial List View
- Displays all tutorials in a grid/card layout
- Filtering by category, difficulty, and publication status
- Search functionality by title/description
- Sort by creation date, title, or difficulty
- "Create New" button for admins/instructors

### 2. Tutorial Creation/Editing
- Multi-step form for creating/editing tutorials
- Basic info section (title, description, category, etc.)
- Day management interface
- Exercise builder with drag-and-drop reordering
- Preview functionality
- Save as draft/publish options

### 3. Tutorial Viewer
- Responsive layout for different devices
- Progress tracking
- Video player for exercise demonstrations
- Text instructions with images
- Navigation between days/exercises
- Completion tracking

## API Endpoints

### GET /api/tutorials
- List all tutorials (with filtering/sorting)
- Required role: Any authenticated user
- Query params: category, difficulty, isPublished, sortBy, search

### GET /api/tutorials/:id
- Get tutorial details by ID
- Required role: Any authenticated user

### POST /api/tutorials
- Create a new tutorial
- Required role: admin or instructor
- Request body: Tutorial object

### PUT /api/tutorials/:id
- Update an existing tutorial
- Required role: admin or original creator
- Request body: Updated tutorial object

### DELETE /api/tutorials/:id
- Delete a tutorial
- Required role: admin or original creator

### POST /api/tutorials/:id/publish
- Publish/unpublish a tutorial
- Required role: admin or original creator
- Request body: { isPublished: boolean }

## Security Rules

```javascript
// Firestore Security Rules
match /tutorials/{tutorialId} {
  // Allow read for all authenticated users
  allow read: if request.auth != null;
  
  // Allow create for admins and instructors
  allow create: if request.auth != null && 
    (getUserRole() == 'admin' || getUserRole() == 'instructor');
    
  // Allow update/delete for admins or original creator
  allow update, delete: if request.auth != null && 
    (getUserRole() == 'admin' || resource.data.authorId == request.auth.uid);
}
```

## Workflow

### Creating a New Tutorial
1. Click "Create Tutorial" button
2. Fill in basic information (title, description, category, etc.)
3. Add days to the tutorial
4. For each day, add exercises with details
5. Upload any necessary media (images/videos)
6. Save as draft or publish immediately

### Editing an Existing Tutorial
1. Navigate to the tutorial
2. Click "Edit" button
3. Make necessary changes
4. Save changes
5. (Optional) Update publication status

### Publishing/Unpublishing
1. Navigate to the tutorial
2. Click "Publish" or "Unpublish" button
3. Confirm the action

## Best Practices

1. **Media Optimization**
   - Compress images before uploading
   - Use web-optimized video formats (MP4 with H.264)
   - Consider using a CDN for media delivery

2. **Content Organization**
   - Keep tutorials focused on specific goals
   - Use clear, consistent naming conventions
   - Include detailed descriptions and instructions

3. **Performance**
   - Implement pagination for tutorial lists
   - Lazy load images and videos
   - Cache tutorial data when possible

4. **Accessibility**
   - Add alt text to all images
   - Include closed captions for videos
   - Ensure proper color contrast
   - Support keyboard navigation

## Future Enhancements

1. **User Progress Tracking**
   - Save user progress through tutorials
   - Mark exercises as complete
   - Track time spent on each exercise

2. **Social Features**
   - Allow users to rate and review tutorials
   - Share progress on social media
   - Comment on tutorials

3. **Offline Support**
   - Download tutorials for offline use
   - Sync progress when back online

4. **AI-Powered Recommendations**
   - Suggest tutorials based on user goals and history
   - Adaptive difficulty adjustment

## Troubleshooting

### Common Issues
1. **Media upload failures**
   - Check file size limits
   - Verify file formats (images: JPG/PNG, videos: MP4)
   - Ensure sufficient storage space

2. **Permission errors**
   - Verify user role has necessary permissions
   - Check if the tutorial is published (for viewers)

3. **Performance issues**
   - Optimize media files
   - Implement pagination for large lists
   - Use Firestore indexes for complex queries
