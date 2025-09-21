# Gym Tracker

A comprehensive Flutter app for tracking gym workouts, creating custom workout plans, and monitoring fitness progress.

## Features

✅ **Dark Mode UI** - Premium dark theme with elegant design  
✅ **Workout Plans** - Create custom plans or use predefined templates  
✅ **Pre-defined Plans** - Push/Pull/Legs, Upper/Lower, Full Body splits  
✅ **Exercise Library** - Comprehensive database of exercises  
✅ **Workout Tracking** - Track sets, reps, weight, and duration  
✅ **Calendar Integration** - Schedule and plan workouts  
✅ **Import/Export** - JSON-based workout plan sharing  
✅ **Progress Tracking** - Monitor your fitness journey  

## Predefined Workout Plans

- **Push/Pull/Legs Split** - 3-6 day program focusing on movement patterns
- **Upper/Lower Split** - 4-day alternating upper and lower body
- **Full Body Beginner** - 3-day full body routine for beginners

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

## Architecture

- **Provider** for state management
- **SQLite** for local data storage
- **JSON Serializable** for data models
- **Material Design 3** with custom dark theme

## Data Models

- Exercise definitions with muscle groups and instructions
- Workout plans with customizable exercises and sets
- Session tracking for progress monitoring
- Calendar integration for scheduling