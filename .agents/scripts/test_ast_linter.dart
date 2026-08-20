import 'dart:convert';
import 'dart:io';

/// Test runner for AST Architecture Linter Hook
void main() async {
  print('🧪 Testing AST Architecture Linter...\n');

  int passed = 0;
  int failed = 0;

  // Test Case 1: Valid Domain Entity
  const validDomainCode = '''
import 'package:equatable/equatable.dart';
import 'package:flutter_code_scout/core/errors/failures.dart';

class MovieEntity extends Equatable {
  final int id;
  const MovieEntity({required this.id});
  @override
  List<Object?> get props => [id];
}
''';

  // Test Case 2: Illegal Dio in Domain
  const illegalDomainDio = '''
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

class InvalidUseCase {
  final Dio dio;
  InvalidUseCase(this.dio);
}
''';

  // Test Case 3: Illegal Flutter Material in Domain
  const illegalDomainFlutter = '''
import 'package:flutter/material.dart';

class InvalidEntity {
  final Color color;
  InvalidEntity(this.color);
}
''';

  // Test Case 4: Illegal DataSource in Presentation
  const illegalPresentationDataSource = '''
import 'package:flutter/material.dart';
import 'package:flutter_code_scout/data/datasources/movie_remote_data_source.dart';

class MovieView extends StatelessWidget {
  final MovieRemoteDataSource dataSource;
  const MovieView(this.dataSource);
  @override
  Widget build(BuildContext context) => Container();
}
''';

  final testCases = [
    {
      'name': 'Valid Domain Entity',
      'file': 'lib/domain/entities/movie.dart',
      'code': validDomainCode,
      'shouldAllow': true,
    },
    {
      'name': 'Illegal Dio in Domain',
      'file': 'lib/domain/usecases/get_movie.dart',
      'code': illegalDomainDio,
      'shouldAllow': false,
    },
    {
      'name': 'Illegal Flutter UI in Domain',
      'file': 'lib/domain/entities/color_entity.dart',
      'code': illegalDomainFlutter,
      'shouldAllow': false,
    },
    {
      'name': 'Illegal DataSource in Presentation',
      'file': 'lib/presentation/pages/movie_page.dart',
      'code': illegalPresentationDataSource,
      'shouldAllow': false,
    },
  ];

  for (final tc in testCases) {
    final process = await Process.start('dart', [
      '.agents/scripts/ast_arch_linter.dart',
    ]);
    final payload = jsonEncode({
      'toolCall': {
        'name': 'write_to_file',
        'args': {
          'TargetFile':
              '/Users/indianic/FLUTTER/CodeScout/flutter_code_scout/${tc['file']}',
          'CodeContent': tc['code'],
        },
      },
    });

    process.stdin.writeln(payload);
    await process.stdin.close();

    final output = await process.stdout.transform(utf8.decoder).join();
    final json = jsonDecode(output.trim()) as Map<String, dynamic>;

    final isAllowed = json['decision'] == 'allow';
    final expectedAllow = tc['shouldAllow'] as bool;

    if (isAllowed == expectedAllow) {
      print('  ✅ [PASS] ${tc['name']} -> decision: ${json['decision']}');
      passed++;
    } else {
      print(
        '  ❌ [FAIL] ${tc['name']} -> expected allow=$expectedAllow, got: ${json['decision']}',
      );
      failed++;
    }
  }

  print('\n📊 Summary: $passed passed, $failed failed.');
  exit(failed == 0 ? 0 : 1);
}
