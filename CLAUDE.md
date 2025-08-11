# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter mobile application project named "pulse". It's a standard Flutter project created from the default template, featuring a simple counter app as the starting point.

## Development Commands

### Setup and Dependencies
```bash
# Get Flutter dependencies
flutter pub get

# Update dependencies
flutter pub upgrade
```

### Running the Application
```bash
# Run on connected device/emulator
flutter run

# Run in debug mode (default)
flutter run --debug

# Run in release mode
flutter run --release

# Run on specific platform
flutter run -d chrome          # Web
flutter run -d macos           # macOS desktop
flutter run -d ios             # iOS simulator/device
flutter run -d android         # Android emulator/device
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run widget tests specifically
flutter test test/widget_test.dart
```

### Code Quality and Analysis
```bash
# Analyze code for issues
flutter analyze

# Format code
flutter format lib/ test/

# Check for linting issues (configured in analysis_options.yaml)
dart analyze
```

### Building
```bash
# Build APK for Android
flutter build apk

# Build iOS app
flutter build ios

# Build for web
flutter build web

# Build for macOS
flutter build macos

# Build for Windows
flutter build windows

# Build for Linux
flutter build linux
```

## Project Structure

- `lib/main.dart` - Entry point with main application widget (MyApp) and counter demo page (MyHomePage)
- `test/widget_test.dart` - Widget tests for the counter functionality
- `pubspec.yaml` - Dependencies and project configuration
- `analysis_options.yaml` - Dart/Flutter linting rules using flutter_lints package
- `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/` - Platform-specific code and configurations

## Architecture Notes

- Uses Material Design with default purple theme (ColorScheme.fromSeed with Colors.deepPurple)
- Follows standard Flutter widget architecture with StatefulWidget for state management
- Current implementation is the default Flutter counter app template
- Uses Cupertino Icons package for iOS-style icons
- Includes flutter_lints for recommended Dart/Flutter coding standards

## Dependencies

### Main Dependencies
- `flutter` - Flutter SDK
- `cupertino_icons: ^1.0.8` - iOS-style icons

### Dev Dependencies  
- `flutter_test` - Testing framework
- `flutter_lints: ^5.0.0` - Linting rules for Flutter

## Environment Requirements

- Dart SDK: ^3.8.1
- Flutter SDK (compatible with Dart 3.8.1+)

## Claude CLI Multi-Agent Configuration

This project is configured for multi-agent development using Claude CLI. See `.claude/` directory for:

- **`.claude/claude.json`** - Main agent configuration file
- **`.claude/claude_agent_config.md`** - Detailed multi-agent architecture documentation  
- **`.claude/README.md`** - Overview of Claude configuration

### Available Agents

1. **market-researcher** - Market analysis and competitive research
2. **product-strategist** - Product roadmap and platform strategy  
3. **system-architect** - Technical architecture and API design
4. **developer** - Flutter development and implementation
5. **code-reviewer** - Code quality and security review
6. **devops** - CI/CD, deployment, and infrastructure
7. **qa-tester** - Test strategy and quality assurance
8. **analytics** - User behavior tracking and optimization
9. **compliance** - Regulatory compliance and security standards

### Quick Start with Agents

```bash
# Initialize Claude CLI (if not already done)
claude init

# Use specific agents for tasks
claude chat --agent developer "Implement user authentication"
claude chat --agent code-reviewer "Review the authentication code"  
claude chat --agent devops "Set up CI/CD for automated testing"
```

For complete agent documentation and workflows, see `.claude/claude_agent_config.md`.