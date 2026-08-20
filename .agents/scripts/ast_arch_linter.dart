import 'dart:convert';
import 'dart:io';

/// Clean Architecture AST & Layer Boundary Linter
///
/// Can be invoked in two modes:
/// 1. Hook Mode (PreToolUse): Reads toolCall JSON from stdin and outputs JSON decision to stdout.
/// 2. Standalone Mode: Scans a single file or entire directory passed via CLI arguments.
void main(List<String> args) async {
  if (args.isNotEmpty) {
    // Standalone CLI Mode: e.g. dart ast_arch_linter.dart lib/
    final targetPath = args[0];
    final exitCode = await runCliScan(targetPath);
    exit(exitCode);
  } else {
    // Hook Mode: Read from stdin
    await runHookMode();
  }
}

Future<void> runHookMode() async {
  try {
    final inputString = await stdin.transform(utf8.decoder).join();
    if (inputString.trim().isEmpty) {
      stdout.writeln(jsonEncode({'decision': 'allow'}));
      return;
    }

    final Map<String, dynamic> payload = jsonDecode(inputString);
    final toolCall = payload['toolCall'] as Map<String, dynamic>?;

    if (toolCall == null) {
      stdout.writeln(jsonEncode({'decision': 'allow'}));
      return;
    }

    final toolName = toolCall['name'] as String? ?? '';
    final toolArgs = toolCall['args'] as Map<String, dynamic>? ?? {};

    String? targetFile;
    String? contentToCheck;

    if (toolName == 'write_to_file') {
      targetFile = toolArgs['TargetFile'] as String?;
      contentToCheck = toolArgs['CodeContent'] as String?;
    } else if (toolName == 'replace_file_content') {
      targetFile = toolArgs['TargetFile'] as String?;
      contentToCheck = toolArgs['ReplacementContent'] as String?;
    }

    if (targetFile == null ||
        !targetFile.endsWith('.dart') ||
        !targetFile.contains('/lib/')) {
      stdout.writeln(jsonEncode({'decision': 'allow'}));
      return;
    }

    final violations = checkCodeViolations(targetFile, contentToCheck ?? '');

    if (violations.isEmpty) {
      stdout.writeln(jsonEncode({'decision': 'allow'}));
    } else {
      final reason =
          '🚫 Clean Architecture Boundary Violations in `$targetFile`:\n' +
          violations.map((v) => '  • $v').join('\n') +
          '\n\nPlease correct these imports to preserve strict Clean Architecture boundaries.';
      stdout.writeln(jsonEncode({'decision': 'deny', 'reason': reason}));
    }
  } catch (e) {
    // If hook execution fails unexpectedly, fallback to allow so developer isn't blocked
    stdout.writeln(
      jsonEncode({
        'decision': 'allow',
        'reason': 'Linter hook bypass on error: $e',
      }),
    );
  }
}

Future<int> runCliScan(String targetPath) async {
  final file = File(targetPath);
  final dir = Directory(targetPath);

  final List<String> allViolations = [];

  if (await file.exists()) {
    if (targetPath.endsWith('.dart')) {
      final content = await file.readAsString();
      final violations = checkCodeViolations(targetPath, content);
      allViolations.addAll(violations.map((v) => '[$targetPath] $v'));
    }
  } else if (await dir.exists()) {
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File &&
          entity.path.endsWith('.dart') &&
          !entity.path.endsWith('.g.dart') &&
          !entity.path.endsWith('.freezed.dart')) {
        final content = await entity.readAsString();
        final violations = checkCodeViolations(entity.path, content);
        allViolations.addAll(violations.map((v) => '[${entity.path}] $v'));
      }
    }
  } else {
    stderr.writeln('Target path does not exist: $targetPath');
    return 1;
  }

  if (allViolations.isEmpty) {
    stdout.writeln(
      '✅ Clean Architecture Audit Passed! Zero layer boundary violations found.',
    );
    return 0;
  } else {
    stderr.writeln(
      '❌ Found ${allViolations.length} Clean Architecture Violation(s):',
    );
    for (final v in allViolations) {
      stderr.writeln('  • $v');
    }
    return 1;
  }
}

/// Checks imports against architectural boundaries based on file layer path
List<String> checkCodeViolations(String filePath, String content) {
  final violations = <String>[];
  final normalizedPath = filePath.replaceAll('\\', '/');

  // Extract all import and export directives
  final importRegex = RegExp(
    r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
    multiLine: true,
  );
  final matches = importRegex.allMatches(content);

  for (final match in matches) {
    final importUri = match.group(1) ?? '';

    // -------------------------------------------------------------
    // 1. DOMAIN LAYER BOUNDARIES (lib/domain/...)
    // Must be pure Dart & business logic. Zero dependencies on Flutter UI, Dio, or Data layer.
    // -------------------------------------------------------------
    if (normalizedPath.contains('/lib/domain/')) {
      if (importUri.startsWith('package:flutter/') &&
          !importUri.startsWith('package:flutter/foundation.dart')) {
        violations.add(
          'Domain layer cannot import Flutter UI (`$importUri`). Domain must be pure Dart.',
        );
      }
      if (importUri.contains('/data/') || importUri.endsWith('/data.dart')) {
        violations.add(
          'Domain layer cannot import Data layer (`$importUri`). Invert dependency using interfaces.',
        );
      }
      if (importUri.contains('/presentation/') ||
          importUri.endsWith('/presentation.dart')) {
        violations.add(
          'Domain layer cannot import Presentation layer (`$importUri`).',
        );
      }
      if (importUri.startsWith('package:dio') ||
          importUri.startsWith('package:http') ||
          importUri.startsWith('package:sqflite') ||
          importUri.startsWith('package:shared_preferences') ||
          importUri.startsWith('package:hive') ||
          importUri.startsWith('package:isar')) {
        violations.add(
          'Domain layer cannot directly import infrastructure/network driver (`$importUri`).',
        );
      }
    }

    // -------------------------------------------------------------
    // 2. DATA LAYER BOUNDARIES (lib/data/...)
    // Can import Domain and Core. Must NEVER import Presentation or UI widgets.
    // -------------------------------------------------------------
    if (normalizedPath.contains('/lib/data/')) {
      if (importUri.contains('/presentation/') ||
          importUri.endsWith('/presentation.dart')) {
        violations.add(
          'Data layer cannot import Presentation layer (`$importUri`).',
        );
      }
      if (importUri == 'package:flutter/material.dart' ||
          importUri == 'package:flutter/cupertino.dart' ||
          importUri == 'package:flutter/widgets.dart') {
        violations.add(
          'Data layer cannot import Flutter UI widgets (`$importUri`).',
        );
      }
    }

    // -------------------------------------------------------------
    // 3. PRESENTATION LAYER BOUNDARIES (lib/presentation/...)
    // Must NOT bypass BLoC/UseCases to talk directly to DataSources or low-level network drivers.
    // -------------------------------------------------------------
    if (normalizedPath.contains('/lib/presentation/')) {
      if (importUri.contains('/data/datasources/') ||
          importUri.contains('_datasource.dart') ||
          importUri.contains('_remote_data_source.dart')) {
        violations.add(
          'Presentation layer cannot directly import DataSources (`$importUri`). Interact via UseCases & BLoC.',
        );
      }
      if (importUri.startsWith('package:dio/') ||
          importUri == 'package:dio/dio.dart') {
        violations.add(
          'Presentation layer cannot directly import Dio client (`$importUri`).',
        );
      }
      if (importUri.startsWith('package:sqflite') ||
          importUri.startsWith('package:hive')) {
        violations.add(
          'Presentation layer cannot directly access database drivers (`$importUri`).',
        );
      }
    }

    // -------------------------------------------------------------
    // 4. CORE LAYER BOUNDARIES (lib/core/...)
    // Core should not depend on concrete feature presentation pages
    // -------------------------------------------------------------
    if (normalizedPath.contains('/lib/core/')) {
      if (importUri.contains('/presentation/pages/') ||
          importUri.contains('/presentation/screens/')) {
        violations.add(
          'Core utility layer cannot depend on specific presentation pages (`$importUri`).',
        );
      }
    }
  }

  return violations;
}
