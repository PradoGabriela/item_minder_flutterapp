# 🤝 Contributing to Item Minder

Thank you for your interest in contributing to Item Minder! This document provides guidelines and information for contributors.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)

## 📜 Code of Conduct

This project follows a standard code of conduct:

- Be respectful and inclusive
- Use welcoming and inclusive language
- Be collaborative and helpful
- Focus on what's best for the community
- Show empathy towards other community members

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.5.4)
- Dart SDK
- Git
- Firebase account (for testing)
- Android Studio / VS Code
- Knowledge of Flutter, Dart, and Firebase

### Development Setup

1. **Fork and Clone**
   ```bash
   git clone https://github.com/YOUR_USERNAME/item_minder_flutterapp.git
   cd item_minder_flutterapp
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Set Up Firebase**
   - Create your own Firebase project
   - Follow the setup instructions in README.md
   - Configure your own firebase_options.dart

4. **Generate Code**
   ```bash
   flutter packages pub run build_runner build
   ```

5. **Run the App**
   ```bash
   flutter run
   ```

## 🎯 How to Contribute

### Types of Contributions

We welcome various types of contributions:

- 🐛 **Bug Fixes**: Fix existing issues
- ✨ **Features**: Add new functionality
- 📚 **Documentation**: Improve documentation
- 🎨 **UI/UX**: Enhance user interface
- 🧪 **Tests**: Add or improve tests
- 🔧 **Refactoring**: Improve code quality
- 🌐 **Localization**: Add language support

### Finding Work

1. **Check Issues**: Look at open issues labeled `good-first-issue` or `help-wanted`
2. **Feature Requests**: Issues labeled `enhancement`
3. **Bug Reports**: Issues labeled `bug`
4. **Documentation**: Issues labeled `documentation`

### Before You Start

- Check if someone is already working on the issue
- Comment on the issue to express interest
- Discuss your approach for larger changes
- Create an issue for new features before implementing

## 💻 Development Workflow

### Branch Naming

Use descriptive branch names:
- `feature/add-barcode-scanner`
- `bugfix/fix-sync-issue`
- `docs/update-readme`
- `refactor/optimize-managers`

### Making Changes

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Your Changes**
   - Follow the existing code style
   - Add tests for new functionality
   - Update documentation as needed

3. **Test Your Changes**
   ```bash
   flutter test
   flutter run --debug
   ```

4. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "Add feature: description of changes"
   ```

5. **Push and Create PR**
   ```bash
   git push origin feature/your-feature-name
   ```

## 📏 Coding Standards

### Dart/Flutter Style

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

```dart
// ✅ Good
class ItemManager {
  Future<void> addCustomItem({
    required String brandName,
    required String description,
  }) async {
    // Implementation
  }
}

// ❌ Avoid
class itemmanager {
  void addcustomitem(String brandname, String description) {
    // Implementation
  }
}
```

### Architecture Guidelines

1. **Manager Pattern**
   - Use manager classes for business logic
   - Never bypass managers for direct Hive access
   - Keep UI and business logic separated

2. **Firebase Integration**
   - Use Firebase managers for all Firebase operations
   - Handle errors gracefully
   - Add comprehensive debug logging

3. **Error Handling**
   ```dart
   try {
     await someOperation();
     debugPrint('✅ Operation successful');
   } catch (e) {
     debugPrint('❌ Operation failed: $e');
     // Handle error appropriately
   }
   ```

### Documentation Standards

- Use clear, descriptive comments
- Document public methods and classes
- Include usage examples for complex functions
- Use emoji prefixes in debug logs for easy filtering

```dart
/**
 * CRITICAL METHOD: Synchronizes items between Firebase and local storage
 * 
 * This method handles complex 3-way synchronization:
 * 1. Items to REMOVE (exist locally but not in Firebase)
 * 2. Items to ADD (exist in Firebase but not locally)  
 * 3. Items to UPDATE (exist in both but Firebase is newer)
 * 
 * @param groupID The group identifier
 * @param items List of items to synchronize
 * @return true if sync successful, false otherwise
 */
Future<bool> synchronizeItems(String groupID, List<AppItem> items) async {
  // Implementation
}
```

## 🧪 Testing Guidelines

### Unit Tests

Write unit tests for:
- Manager class methods
- Utility functions
- Data model operations

```dart
// test/unit/item_manager_test.dart
void main() {
  group('ItemManager', () {
    test('should add item successfully', () async {
      // Arrange
      final itemManager = ItemManager();
      
      // Act
      await itemManager.addCustomItem(/* ... */);
      
      // Assert
      expect(/* validation */, isTrue);
    });
  });
}
```

### Integration Tests

Test complete user workflows:
- Creating and joining groups
- Adding and syncing items
- Offline/online scenarios

### Manual Testing Checklist

Before submitting a PR, test:
- [ ] App builds without errors
- [ ] New features work as expected
- [ ] Existing functionality not broken
- [ ] Firebase sync works correctly
- [ ] Offline mode functions properly
- [ ] UI is responsive and intuitive

## 📝 Commit Guidelines

### Commit Message Format

Use conventional commits:

```
type(scope): brief description

Detailed explanation if needed.

- List any breaking changes
- Reference issues: Fixes #123
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples
```bash
feat(inventory): add barcode scanning functionality

Implemented QR code and barcode scanning using camera.
Users can now scan items to automatically populate item details.

- Added new scanner widget
- Integrated with camera permission system
- Updated item creation flow

Fixes #45

fix(sync): resolve conflict resolution timing issue

Fixed race condition in Firebase listeners that caused
data inconsistencies when multiple devices updated simultaneously.

Closes #67

docs(readme): update setup instructions

Added more detailed Firebase configuration steps
and troubleshooting section for common issues.
```

## 🔄 Pull Request Process

### PR Checklist

Before submitting a PR, ensure:

- [ ] Code follows project style guidelines
- [ ] Tests pass (`flutter test`)
- [ ] App builds successfully (`flutter build apk`)
- [ ] Documentation updated if needed
- [ ] Self-review completed
- [ ] No merge conflicts
- [ ] PR description is clear and detailed

### PR Template

```markdown
## Description
Brief description of the changes made.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Code refactoring
- [ ] Performance improvement

## Testing
Describe the tests you ran to verify your changes.

## Screenshots (if applicable)
Include screenshots for UI changes.

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No breaking changes (or documented)

## Related Issues
Fixes #123
Relates to #456
```

### Review Process

1. **Automated Checks**: CI/CD will run tests automatically
2. **Code Review**: Maintainers will review your code
3. **Feedback**: Address any requested changes
4. **Approval**: Once approved, your PR will be merged

## 🐛 Issue Reporting

### Bug Reports

Use the bug report template:

```markdown
## Bug Description
Clear description of the bug.

## Steps to Reproduce
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

## Expected Behavior
What you expected to happen.

## Actual Behavior
What actually happened.

## Environment
- Device: [e.g. iPhone 12, Samsung Galaxy S21]
- OS: [e.g. iOS 15.0, Android 11]
- App Version: [e.g. 1.0.0]
- Flutter Version: [e.g. 3.5.4]

## Screenshots
Add screenshots if applicable.

## Additional Context
Any other relevant information.
```

### Feature Requests

```markdown
## Feature Description
Clear description of the proposed feature.

## Problem Statement
What problem does this feature solve?

## Proposed Solution
Detailed description of your proposed solution.

## Alternative Solutions
Other approaches you've considered.

## Additional Context
Screenshots, mockups, or examples.
```

## 🏷️ Labels and Milestones

### Common Labels
- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Improvements to documentation
- `good-first-issue`: Good for newcomers
- `help-wanted`: Extra attention is needed
- `priority-high`: High priority issue
- `wontfix`: This will not be worked on

## 🙋 Getting Help

If you need help:

1. **Check Documentation**: README.md and DEVELOPMENT.md
2. **Search Issues**: Look for similar problems
3. **Ask Questions**: Create an issue with `question` label
4. **Join Discussions**: Participate in GitHub Discussions

## 🎉 Recognition

Contributors will be:
- Listed in the project contributors
- Mentioned in release notes for significant contributions
- Credited in the app's about section

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

---

Thank you for contributing to Item Minder! Your efforts help make this project better for everyone. 🚀
