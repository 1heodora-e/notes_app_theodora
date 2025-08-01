Notes App
📝 Project Description
A simple, yet robust, mobile application built with Flutter for managing personal notes. It features secure user authentication and real-time synchronization of notes using Firebase Firestore. This project demonstrates a clean architecture approach with Bloc for state management and a Repository Pattern for data abstraction.

✨ Features
User Authentication: Secure sign-up and login with email and password using Firebase Authentication.

Real-time Notes Management (CRUD):

Create: Add new notes with a title and content.

Read: View all your notes in a real-time updated list.

Update: Edit existing notes.

Delete: Remove notes from your collection.

User-Specific Data: Each user's notes are private and accessible only by them.

Clear User Feedback: Utilizes SnackBar messages for authentication errors and successful note operations.

🚀 Technologies Used
Frontend: Flutter (Dart)

Backend/Database: Firebase

Firebase Authentication

Firebase Firestore

State Management: Flutter Bloc / Cubit

Data Immutability: Equatable

🏛️ Architecture
The application follows a clean architecture pattern to ensure separation of concerns, testability, and maintainability:

Presentation Layer: Flutter Widgets, managing UI and dispatching events to Cubits.

Application/Domain Layer (Bloc/Cubit): AuthCubit and NotesCubit handle business logic and manage application state.

Data Layer (Repository Pattern):

NotesRepository (abstract interface) defines data operations.

FirestoreNotesRepository (concrete implementation) handles actual interaction with Firebase Firestore.

🛠️ Setup & Installation
Prerequisites
Flutter SDK installed and configured.

Firebase CLI installed.

A Firebase project set up in the Firebase Console.

Steps

cd notes_app

Install Flutter dependencies:

flutter pub get

Connect to your Firebase Project:

Ensure you have authenticated the Firebase CLI: firebase login

Configure your Flutter project with Firebase:

flutterfire configure

Follow the prompts to select your Firebase project and platforms. This will generate lib/firebase_options.dart.

Configure Firestore Security Rules:

Go to your Firebase Console > Firestore Database > Rules tab.

Replace the existing rules with the following to ensure secure, user-specific data access and real-time updates:

rules_version = '2';
service cloud.firestore {
match /databases/{database}/documents {
match /notes/{noteId} {
allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
allow read, update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
}
}
}

Click Publish.

🏃 Running the App
To run the app on an emulator or a connected device:

flutter run

💡 Usage
Sign Up / Login: Create a new account or log in with existing credentials.

Add Notes: Tap the + button on the Notes screen to add a new note.

View Notes: Your notes will appear in a list and update in real-time.

Edit Notes: Tap the pencil icon next to a note to edit its title or content.

Delete Notes: Tap the trash can icon next to a note to delete it. A confirmation dialog will appear.

📁 Project Structure
notes_app/
├── lib/
│   ├── cubits/           # Bloc/Cubit state management logic
│   │   ├── auth/         # Authentication Cubit and states
│   │   └── notes/        # Notes Cubit and states
│   ├── models/           # Data models (e.g., Note)
│   ├── repositories/     # Data access layer (abstract and concrete implementations)
│   │   ├── firestore_notes_repository.dart
│   │   └── notes_repository.dart
│   ├── screens/          # UI screens (e.g., AuthScreen, NotesScreen)
│   ├── firebase_options.dart # Firebase configuration (generated by flutterfire)
│   └── main.dart         # Main entry point and Bloc/Firebase initialization
├── pubspec.yaml          # Project dependencies
├── README.md             # This file
└── ... (other Flutter project files)

🐛 Debugging Notes
During development, various issues were encountered and resolved. Key areas to check for common problems include:

pubspec.yaml: Ensure all flutter_bloc, equatable, and Firebase dependencies are correctly listed and flutter pub get has been run.

Firebase Console: Verify Firebase project setup, enabled Authentication methods (Email/Password), and correct Firestore Security Rules.

Console Output: Utilize print() statements in Cubits and Repositories to trace data flow and state changes, especially for real-time issues.

IDE's "Problems" Tab: Address any syntax errors or critical warnings that might prevent compilation.

🤝 Contributing
Feel free to fork the repository and contribute!