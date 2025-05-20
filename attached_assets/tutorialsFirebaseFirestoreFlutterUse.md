# Guide: Using Fitsaga Tutorial Data (Firestore & Firebase Storage) in a Flutter Mobile App

This guide provides information for Flutter developers on how to access and utilize the tutorial data (including videos and images) from the Fitsaga backend, which uses Firestore for metadata and Firebase Storage for media files.

## 1. Firebase Setup in Flutter

Before you begin, ensure your Flutter project is correctly configured to use Firebase:

1.  **Create a Firebase Project:** If you haven't already, create a project in the [Firebase console](https://console.firebase.google.com/).
2.  **Add Flutter Apps:** Register your Android and iOS apps with the Firebase project. Follow the on-screen instructions to download configuration files (`google-services.json` for Android and `GoogleService-Info.plist` for iOS) and add them to your Flutter project.
3.  **Add Firebase Dependencies:** Add the necessary Firebase plugins to your `pubspec.yaml` file:
    ```yaml
    dependencies:
      flutter:
        sdk: flutter
      firebase_core: ^latest_version # Check for the latest version
      cloud_firestore: ^latest_version # For accessing Firestore
      firebase_storage: ^latest_version # For accessing Firebase Storage (though direct URL access is primary here)
      video_player: ^latest_version # For playing videos
      # cached_network_image: ^latest_version # Recommended for image caching
    ```
    Run `flutter pub get`.
4.  **Initialize Firebase:** In your `main.dart` file, initialize Firebase:
    ```dart
    import 'package:firebase_core/firebase_core.dart';
    import 'package:flutter/material.dart';

    void main() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        // Ensure you have firebase_options.dart if using FlutterFire CLI,
        // or configure manually based on platform.
      );
      runApp(MyApp());
    }
    ```

## 2. Data Models (Dart Classes)

Based on the Firestore structure, here are example Dart classes you can use for data modeling. Consider using a JSON serialization library like `json_serializable` for robust parsing.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Tutorial {
  final String id;
  final String name;
  final String description;
  final String section; // 'musculation' or 'diete'
  final String? imageUrl; // Nullable
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final List<TutorialDay> days;

  Tutorial({
    required this.id,
    required this.name,
    required this.description,
    required this.section,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.days,
  });

  factory Tutorial.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Tutorial(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      section: data['section'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      days: (data['days'] as List<dynamic>?)
              ?.map((dayData) => TutorialDay.fromMap(dayData as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TutorialDay {
  final String id;
  final int dayNumber;
  final String title;
  final String description;
  final List<Exercise> exercises;

  TutorialDay({
    required this.id,
    required this.dayNumber,
    required this.title,
    required this.description,
    required this.exercises,
  });

  factory TutorialDay.fromMap(Map<String, dynamic> map) {
    return TutorialDay(
      id: map['id'] ?? '',
      dayNumber: map['dayNumber'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      exercises: (map['exercises'] as List<dynamic>?)
              ?.map((exData) => Exercise.fromMap(exData as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Exercise {
  final String id;
  final String name;
  final String description;
  final int? sets; // Nullable, specific to 'musculation'
  final int? reps; // Nullable
  final int? restTime; // Nullable, in seconds
  final String? imageUrl; // Nullable
  final String? videoUrl; // Nullable, **This is the Firebase Storage download URL**

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    this.sets,
    this.reps,
    this.restTime,
    this.imageUrl,
    this.videoUrl,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      sets: map['sets'],
      reps: map['reps'],
      restTime: map['restTime'],
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
    );
  }
}
```

**Note on Timestamps:** Firestore `Timestamp` objects can be converted to Dart `DateTime` objects using `timestamp.toDate()`.

## 3. Accessing Data from Firestore

You'll primarily interact with the `tutorials` collection.

### Fetching a List of Tutorials:

```dart
FirebaseFirestore firestore = FirebaseFirestore.instance;

Stream<List<Tutorial>> getTutorialsStream() {
  return firestore
      .collection('tutorials')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Tutorial.fromFirestore(doc))
          .toList());
}

// Example Usage in a StreamBuilder
StreamBuilder<List<Tutorial>>(
  stream: getTutorialsStream(),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    List<Tutorial> tutorials = snapshot.data ?? [];
    // Build your UI with the tutorials list
    return ListView.builder(
      itemCount: tutorials.length,
      itemBuilder: (context, index) {
        Tutorial tutorial = tutorials[index];
        return ListTile(
          title: Text(tutorial.name),
          // ...
        );
      },
    );
  },
)
```

### Fetching a Single Tutorial by ID:

```dart
Future<Tutorial?> getTutorialById(String tutorialId) async {
  try {
    DocumentSnapshot doc = await firestore.collection('tutorials').doc(tutorialId).get();
    if (doc.exists) {
      return Tutorial.fromFirestore(doc);
    }
  } catch (e) {
    print('Error fetching tutorial: $e');
  }
  return null;
}
```

## 4. Displaying Images

The `imageUrl` field in both `Tutorial` and `Exercise` objects is a direct download URL from Firebase Storage. You can display these images using Flutter's `Image.network()` widget. For better performance and caching, consider using the `cached_network_image` package.

```dart
// Using Image.network
if (exercise.imageUrl != null)
  Image.network(exercise.imageUrl!),

// Using cached_network_image (recommended)
// import 'package:cached_network_image/cached_network_image.dart';
// if (exercise.imageUrl != null)
//   CachedNetworkImage(
//     imageUrl: exercise.imageUrl!,
//     placeholder: (context, url) => CircularProgressIndicator(),
//     errorWidget: (context, url, error) => Icon(Icons.error),
//   ),
```

## 5. Playing Videos

The `videoUrl` field in the `Exercise` object is a direct download URL from Firebase Storage. You can use the `video_player` package to play these videos.

**Setup `video_player`:**
*   Ensure you've added `video_player` to `pubspec.yaml`.
*   For iOS, add the following to your `Info.plist` to allow network requests:
    ```xml
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    ```
*   For Android, ensure your `AndroidManifest.xml` has the internet permission:
    ```xml
    <uses-permission android:name="android.permission.INTERNET"/>
    ```

**Example Video Player Widget:**

```dart
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class ExerciseVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const ExerciseVideoPlayer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _ExerciseVideoPlayerState createState() => _ExerciseVideoPlayerState();
}

class _ExerciseVideoPlayerState extends State<ExerciseVideoPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized.
      setState(() {});
    }).catchError((error) {
      print("Error initializing video player: $error");
      // Handle error appropriately in your UI
    });
    _controller.setLooping(true); // Optional: Loop the video
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && _controller.value.isInitialized) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                VideoPlayer(_controller),
                VideoProgressIndicator(_controller, allowScrubbing: true),
                _PlayPauseOverlay(controller: _controller),
              ],
            ),
          );
        } else if (snapshot.hasError) {
           return Center(child: Text("Error loading video. Please check the URL or network connection."));
        }
        else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

// Optional: Custom Play/Pause Overlay
class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key? key, required this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () {
            setState(() {
              controller.value.isPlaying ? controller.pause() : controller.play();
            });
          },
          child: Container(
            color: Colors.transparent, // Make overlay tappable
            child: Center(
              child: Icon(
                controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 50.0,
                semanticLabel: controller.value.isPlaying ? 'Pause' : 'Play',
              ),
            ),
          ),
        );
      },
    );
  }
}

// Usage:
// if (exercise.videoUrl != null)
//   ExerciseVideoPlayer(videoUrl: exercise.videoUrl!),
```

## 6. Firestore and Firebase Storage Security Rules

While the admin portal manages uploads and has its own security rules, your client-side Flutter application will primarily be reading data. Ensure that your Firebase project has appropriate security rules for Firestore and Firebase Storage that allow read access for authenticated (or public, if applicable) users.

**Example Firestore Rules (allow public read for `tutorials`):**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /tutorials/{tutorialId} {
      allow read: if true; // Or restrict to authenticated users: if request.auth != null;
      allow write: if false; // Client app should not write directly unless intended
    }
    // Add rules for other collections as needed
  }
}
```

**Example Firebase Storage Rules (allow public read for files under `tutorials/`):**
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /tutorials/{allPaths=**} {
      allow read: if true; // Or restrict to authenticated users: if request.auth != null;
      allow write: if false; // Client app should not write directly unless intended
    }
  }
}
```
**Important:** Review and tailor these security rules carefully based on your application's authentication and authorization requirements.

## 7. Conclusion

By using the `cloud_firestore` package to fetch tutorial metadata and the `video_player` package (or similar) with the direct `videoUrl` from Firebase Storage, you can effectively integrate Fitsaga's tutorial content into your Flutter mobile application. Remember to model your data correctly and handle potential null values for URLs.
