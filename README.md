# 🎵 Ear Training App

A Flutter app for musicians to practice intervals, chords, and scales.

## Features

- **Interval Training** – Recognize 8 basic intervals (unison to octave)
- **Chord Recognition** – Major, Minor, Dominant 7th
- **Scale Training** – Major and Natural Minor scales
- **Score & Feedback** – Instant visual and audio feedback
- **Progress Tracking** – Local persistence with accuracy stats

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | Flutter / Material 3 |
| State | flutter_riverpod ^2.x |
| Navigation | go_router ^14.x |
| Database | isar ^3.x |
| Audio | just_audio ^0.9.x |
| Models | freezed + json_serializable |

## Architecture

Clean Architecture with Feature-First folder structure:

```
lib/
├── core/
│   ├── audio/          # Audio engine
│   ├── models/         # Data models (freezed)
│   ├── services/       # Business logic
│   ├── storage/        # Isar persistence
│   ├── router/         # go_router setup
│   ├── theme/          # Design system
│   └── widgets/        # Shared widgets
├── features/
│   ├── home/           # Dashboard / navigation hub
│   ├── intervals/      # Interval training
│   ├── chords/         # Chord recognition
│   ├── scales/         # Scale training
│   └── progress/       # Progress & stats
└── main.dart
```

## Getting Started

```bash
flutter pub get
flutter pub run build_runner build
flutter run
```

## MVP Scope (v1.0)

- ✅ Interval Training (8 basic intervals)
- ✅ Chord Recognition (Major, Minor, Dom7)
- ✅ Scale Training (Major, Minor)
- ✅ Multiple Choice (4 options)
- ✅ Instant feedback
- ✅ Session score (X/10 correct)
- ✅ Progress overview
