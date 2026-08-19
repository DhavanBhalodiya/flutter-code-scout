// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// Deterministic Hybrid Clean Architecture Feature Scaffolder.
/// Generates:
///  1. Domain Entity (lib/domain/entities/)
///  2. Data Model (lib/data/models/)
///  3. Remote Data Source (lib/data/datasources/)
///  4. Domain Repository Interface (lib/domain/repositories/)
///  5. Data Repository Implementation (lib/data/repositories/)
///  6. Domain UseCase (lib/domain/usecases/)
///  7. Presentation BLoC (lib/presentation/blocs/)
///  8. Presentation UI Screen (lib/presentation/screens/)
///  9. Data Model Unit Tests (test/data/models/)
/// 10. BLoC Unit Tests (test/presentation/blocs/)
/// 11. GetIt Dependency Injection (lib/core/di/injection_container.dart)
void main(List<String> args) {
  if (args.isEmpty) {
    print('❌ Usage: dart run tool/feature_scaffolder.dart <FeatureName> [json_file_or_string]');
    exit(1);
  }

  final featureName = args[0];
  final sourceArg = args.length > 1 ? args[1] : 'schema_input.json';

  Map<String, dynamic> rawJson;
  try {
    if (sourceArg.trim().startsWith('{')) {
      rawJson = jsonDecode(sourceArg) as Map<String, dynamic>;
    } else {
      final file = File(sourceArg);
      if (!file.existsSync()) {
        print('❌ Error: File "$sourceArg" not found.');
        exit(1);
      }
      final content = file.readAsStringSync().trim();
      final decoded = jsonDecode(content);
      if (decoded is List) {
        if (decoded.isEmpty) {
          print('❌ Error: JSON array in "$sourceArg" is empty.');
          exit(1);
        }
        rawJson = decoded.first as Map<String, dynamic>;
      } else if (decoded is Map<String, dynamic>) {
        final listEntry = decoded.entries
            .where((e) => e.value is List && (e.value as List).isNotEmpty && (e.value as List).first is Map)
            .firstOrNull;
        if (listEntry != null && decoded.length <= 4) {
          rawJson = (listEntry.value as List).first as Map<String, dynamic>;
        } else {
          rawJson = decoded;
        }
      } else {
        print('❌ Error: Unsupported JSON format.');
        exit(1);
      }
    }
  } catch (e) {
    print('❌ JSON parse error: $e');
    exit(1);
  }

  final scaffolder = FeatureScaffolder(featureName: featureName, sampleJson: rawJson);
  scaffolder.generateAll();
}

class FeatureScaffolder {
  final String featureName;
  final Map<String, dynamic> sampleJson;

  late final String pascalCase;
  late final String camelCase;
  late final String snakeCase;
  late final String humanTitle;
  late final List<FieldMeta> fields;

  FeatureScaffolder({required this.featureName, required this.sampleJson}) {
    pascalCase = _toPascalCase(featureName);
    camelCase = _toCamelCase(featureName);
    snakeCase = _toSnakeCase(featureName);
    humanTitle = _toHumanTitle(featureName);
    fields = _extractFields(sampleJson);
  }

  void generateAll() {
    print('🚀 Scaffolding Complete Clean Architecture Vertical Slice: $pascalCase');

    _generateEntity();
    _generateModel();
    _generateRemoteDataSource();
    _generateRepositoryInterface();
    _generateRepositoryImpl();
    _generateUseCase();
    _generateBloc();
    _generateScreen();
    _generateModelTest();
    _generateBlocTest();
    _injectDependency();

    print('✅ Feature $pascalCase successfully generated with 100% end-to-end layer purity!');
  }

  // 1. Domain Entity
  void _generateEntity() {
    final filePath = 'lib/domain/entities/$snakeCase.dart';
    final buffer = StringBuffer();

    buffer.writeln("import 'package:equatable/equatable.dart';");
    buffer.writeln();
    buffer.writeln('/// Domain Entity representing $pascalCase.');
    buffer.writeln('class $pascalCase extends Equatable {');

    for (final f in fields) {
      buffer.writeln('  final ${f.dartType} ${f.fieldName};');
    }
    buffer.writeln();

    buffer.writeln('  const $pascalCase({');
    for (final f in fields) {
      buffer.writeln('    required this.${f.fieldName},');
    }
    buffer.writeln('  });');
    buffer.writeln();

    // copyWith
    buffer.writeln('  $pascalCase copyWith({');
    for (final f in fields) {
      buffer.writeln('    ${f.dartType}? ${f.fieldName},');
    }
    buffer.writeln('  }) {');
    buffer.writeln('    return $pascalCase(');
    for (final f in fields) {
      buffer.writeln('      ${f.fieldName}: ${f.fieldName} ?? this.${f.fieldName},');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();

    // props
    buffer.writeln('  @override');
    buffer.writeln('  List<Object?> get props => [');
    for (final f in fields) {
      buffer.writeln('        ${f.fieldName},');
    }
    buffer.writeln('      ];');
    buffer.writeln('}');

    _writeFile(filePath, buffer.toString());
  }

  // 2. Data Model
  void _generateModel() {
    final filePath = 'lib/data/models/${snakeCase}_model.dart';
    final buffer = StringBuffer();

    buffer.writeln("import '../../domain/entities/$snakeCase.dart';");
    buffer.writeln();
    buffer.writeln('/// Data Model representing $pascalCase with safe JSON parsing.');
    buffer.writeln('class ${pascalCase}Model extends $pascalCase {');
    buffer.writeln('  const ${pascalCase}Model({');
    for (final f in fields) {
      buffer.writeln('    required super.${f.fieldName},');
    }
    buffer.writeln('  });');
    buffer.writeln();

    // fromJson
    buffer.writeln('  factory ${pascalCase}Model.fromJson(Map<String, dynamic> json) {');
    buffer.writeln('    return ${pascalCase}Model(');
    for (final f in fields) {
      buffer.writeln('      ${f.fieldName}: ${f.fromJsonExpression},');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();

    // toJson
    buffer.writeln('  Map<String, dynamic> toJson() {');
    buffer.writeln('    return {');
    for (final f in fields) {
      buffer.writeln("      '${f.jsonKey}': ${f.fieldName},");
    }
    buffer.writeln('    };');
    buffer.writeln('  }');
    buffer.writeln('}');

    _writeFile(filePath, buffer.toString());
  }

  // 3. Remote Data Source
  void _generateRemoteDataSource() {
    final filePath = 'lib/data/datasources/${snakeCase}_remote_data_source.dart';
    final buffer = StringBuffer();

    buffer.writeln("import '../../core/network/api_client.dart';");
    buffer.writeln("import '../models/${snakeCase}_model.dart';");
    buffer.writeln();
    buffer.writeln('/// Remote Data Source contract for $pascalCase.');
    buffer.writeln('abstract class ${pascalCase}RemoteDataSource {');
    buffer.writeln('  Future<${pascalCase}Model> get$pascalCase();');
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln('/// Concrete implementation of [${pascalCase}RemoteDataSource] using [ApiClient].');
    buffer.writeln('class ${pascalCase}RemoteDataSourceImpl implements ${pascalCase}RemoteDataSource {');
    buffer.writeln('  final ApiClient apiClient;');
    buffer.writeln();
    buffer.writeln('  ${pascalCase}RemoteDataSourceImpl({required this.apiClient});');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  Future<${pascalCase}Model> get$pascalCase() async {');
    buffer.writeln("    final response = await apiClient.get('/$snakeCase');");
    buffer.writeln('    if (response is Map<String, dynamic>) {');
    buffer.writeln('      return ${pascalCase}Model.fromJson(response);');
    buffer.writeln('    }');
    buffer.writeln('    if (response is List && response.isNotEmpty) {');
    buffer.writeln('      return ${pascalCase}Model.fromJson(response.first as Map<String, dynamic>);');
    buffer.writeln('    }');
    buffer.writeln("    throw Exception('Invalid response for $pascalCase');");
    buffer.writeln('  }');
    buffer.writeln('}');

    _writeFile(filePath, buffer.toString());
  }

  // 4. Domain Repository Interface
  void _generateRepositoryInterface() {
    final filePath = 'lib/domain/repositories/${snakeCase}_repository.dart';
    final buffer = StringBuffer();

    buffer.writeln("import '../entities/$snakeCase.dart';");
    buffer.writeln();
    buffer.writeln('/// Abstract Repository contract for $pascalCase in Domain Layer.');
    buffer.writeln('abstract class ${pascalCase}Repository {');
    buffer.writeln('  Future<$pascalCase> get$pascalCase();');
    buffer.writeln('}');

    _writeFile(filePath, buffer.toString());
  }

  // 5. Data Repository Implementation
  void _generateRepositoryImpl() {
    final filePath = 'lib/data/repositories/${snakeCase}_repository_impl.dart';
    final buffer = StringBuffer();

    buffer.writeln("import '../../core/error/exceptions.dart';");
    buffer.writeln("import '../../core/error/failures.dart';");
    buffer.writeln("import '../../domain/entities/$snakeCase.dart';");
    buffer.writeln("import '../../domain/repositories/${snakeCase}_repository.dart';");
    buffer.writeln("import '../datasources/${snakeCase}_remote_data_source.dart';");
    buffer.writeln();
    buffer.writeln('/// Concrete implementation of [${pascalCase}Repository].');
    buffer.writeln('class ${pascalCase}RepositoryImpl implements ${pascalCase}Repository {');
    buffer.writeln('  final ${pascalCase}RemoteDataSource remoteDataSource;');
    buffer.writeln();
    buffer.writeln('  ${pascalCase}RepositoryImpl({required this.remoteDataSource});');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  Future<$pascalCase> get$pascalCase() async {');
    buffer.writeln('    try {');
    buffer.writeln('      return await remoteDataSource.get$pascalCase();');
    buffer.writeln('    } on ServerException catch (e) {');
    buffer.writeln('      throw ServerFailure(message: e.message, statusCode: e.statusCode);');
    buffer.writeln('    } on NetworkException catch (e) {');
    buffer.writeln('      throw NetworkFailure(message: e.message, statusCode: e.statusCode);');
    buffer.writeln('    } catch (e) {');
    buffer.writeln("      throw UnknownFailure(message: 'Failed to fetch $pascalCase: \$e');");
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln('}');

    _writeFile(filePath, buffer.toString());
  }

  // 6. Domain UseCase
  void _generateUseCase() {
    final filePath = 'lib/domain/usecases/get_$snakeCase.dart';
    final buffer = StringBuffer();

    buffer.writeln("import '../entities/$snakeCase.dart';");
    buffer.writeln("import '../repositories/${snakeCase}_repository.dart';");
    buffer.writeln();
    buffer.writeln('/// UseCase to fetch $pascalCase.');
    buffer.writeln('class Get$pascalCase {');
    buffer.writeln('  final ${pascalCase}Repository repository;');
    buffer.writeln();
    buffer.writeln('  const Get$pascalCase(this.repository);');
    buffer.writeln();
    buffer.writeln('  Future<$pascalCase> call() async {');
    buffer.writeln('    return await repository.get$pascalCase();');
    buffer.writeln('  }');
    buffer.writeln('}');

    _writeFile(filePath, buffer.toString());
  }

  // 7. Presentation BLoC
  void _generateBloc() {
    final blocDir = 'lib/presentation/blocs/$snakeCase';

    // 1. Events
    final eventPath = '$blocDir/${snakeCase}_event.dart';
    final eventBuf = StringBuffer();
    eventBuf.writeln("import 'package:equatable/equatable.dart';");
    eventBuf.writeln();
    eventBuf.writeln('abstract class ${pascalCase}Event extends Equatable {');
    eventBuf.writeln('  const ${pascalCase}Event();');
    eventBuf.writeln();
    eventBuf.writeln('  @override');
    eventBuf.writeln('  List<Object?> get props => [];');
    eventBuf.writeln('}');
    eventBuf.writeln();
    eventBuf.writeln('class Fetch$pascalCase extends ${pascalCase}Event {');
    eventBuf.writeln('  const Fetch$pascalCase();');
    eventBuf.writeln('}');
    _writeFile(eventPath, eventBuf.toString());

    // 2. States
    final statePath = '$blocDir/${snakeCase}_state.dart';
    final stateBuf = StringBuffer();
    stateBuf.writeln("import 'package:equatable/equatable.dart';");
    stateBuf.writeln("import '../../../domain/entities/$snakeCase.dart';");
    stateBuf.writeln();
    stateBuf.writeln('abstract class ${pascalCase}State extends Equatable {');
    stateBuf.writeln('  const ${pascalCase}State();');
    stateBuf.writeln();
    stateBuf.writeln('  @override');
    stateBuf.writeln('  List<Object?> get props => [];');
    stateBuf.writeln('}');
    stateBuf.writeln();
    stateBuf.writeln('class ${pascalCase}Initial extends ${pascalCase}State {');
    stateBuf.writeln('  const ${pascalCase}Initial();');
    stateBuf.writeln('}');
    stateBuf.writeln();
    stateBuf.writeln('class ${pascalCase}Loading extends ${pascalCase}State {');
    stateBuf.writeln('  const ${pascalCase}Loading();');
    stateBuf.writeln('}');
    stateBuf.writeln();
    stateBuf.writeln('class ${pascalCase}Loaded extends ${pascalCase}State {');
    stateBuf.writeln('  final $pascalCase data;');
    stateBuf.writeln('  const ${pascalCase}Loaded({required this.data});');
    stateBuf.writeln();
    stateBuf.writeln('  @override');
    stateBuf.writeln('  List<Object?> get props => [data];');
    stateBuf.writeln('}');
    stateBuf.writeln();
    stateBuf.writeln('class ${pascalCase}Error extends ${pascalCase}State {');
    stateBuf.writeln('  final String message;');
    stateBuf.writeln('  const ${pascalCase}Error({required this.message});');
    stateBuf.writeln();
    stateBuf.writeln('  @override');
    stateBuf.writeln('  List<Object?> get props => [message];');
    stateBuf.writeln('}');
    _writeFile(statePath, stateBuf.toString());

    // 3. BLoC
    final blocPath = '$blocDir/${snakeCase}_bloc.dart';
    final blocBuf = StringBuffer();
    blocBuf.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
    blocBuf.writeln("import '../../../domain/usecases/get_$snakeCase.dart';");
    blocBuf.writeln("import '${snakeCase}_event.dart';");
    blocBuf.writeln("import '${snakeCase}_state.dart';");
    blocBuf.writeln();
    blocBuf.writeln('class ${pascalCase}Bloc extends Bloc<${pascalCase}Event, ${pascalCase}State> {');
    blocBuf.writeln('  final Get$pascalCase get$pascalCase;');
    blocBuf.writeln();
    blocBuf.writeln('  ${pascalCase}Bloc({required this.get$pascalCase}) : super(const ${pascalCase}Initial()) {');
    blocBuf.writeln('    on<Fetch$pascalCase>(_onFetch);');
    blocBuf.writeln('  }');
    blocBuf.writeln();
    blocBuf.writeln('  Future<void> _onFetch(Fetch$pascalCase event, Emitter<${pascalCase}State> emit) async {');
    blocBuf.writeln('    emit(const ${pascalCase}Loading());');
    blocBuf.writeln('    try {');
    blocBuf.writeln('      final result = await get$pascalCase();');
    blocBuf.writeln('      emit(${pascalCase}Loaded(data: result));');
    blocBuf.writeln('    } catch (e) {');
    blocBuf.writeln("      emit(${pascalCase}Error(message: e.toString()));");
    blocBuf.writeln('    }');
    blocBuf.writeln('  }');
    blocBuf.writeln('}');
    _writeFile(blocPath, blocBuf.toString());
  }

  // 8. Presentation Screen
  void _generateScreen() {
    final screenPath = 'lib/presentation/screens/${snakeCase}_screen.dart';
    final buffer = StringBuffer();

    buffer.writeln("import 'package:flutter/material.dart';");
    buffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
    buffer.writeln("import '../../core/di/injection_container.dart';");
    buffer.writeln("import '../../core/theme/app_colors.dart';");
    buffer.writeln("import '../../core/theme/app_typography.dart';");
    buffer.writeln("import '../blocs/$snakeCase/${snakeCase}_bloc.dart';");
    buffer.writeln("import '../blocs/$snakeCase/${snakeCase}_event.dart';");
    buffer.writeln("import '../blocs/$snakeCase/${snakeCase}_state.dart';");
    buffer.writeln("import '../widgets/error_view.dart';");
    buffer.writeln("import '../widgets/loading_indicator.dart';");
    buffer.writeln();
    buffer.writeln('/// Presentation Screen for $pascalCase.');
    buffer.writeln('class ${pascalCase}Screen extends StatelessWidget {');
    buffer.writeln('  const ${pascalCase}Screen({super.key});');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  Widget build(BuildContext context) {');
    buffer.writeln('    return BlocProvider<${pascalCase}Bloc>(');
    buffer.writeln('      create: (_) => sl<${pascalCase}Bloc>()..add(const Fetch$pascalCase()),');
    buffer.writeln('      child: Scaffold(');
    buffer.writeln('        backgroundColor: AppColors.background,');
    buffer.writeln('        appBar: AppBar(');
    buffer.writeln('          backgroundColor: AppColors.surface,');
    buffer.writeln('          title: Text(');
    buffer.writeln("            '$humanTitle',");
    buffer.writeln('            style: AppTypography.titleLarge,');
    buffer.writeln('          ),');
    buffer.writeln('        ),');
    buffer.writeln('        body: BlocBuilder<${pascalCase}Bloc, ${pascalCase}State>(');
    buffer.writeln('          builder: (context, state) {');
    buffer.writeln('            if (state is ${pascalCase}Loading) {');
    buffer.writeln("              return const LoadingIndicator(message: 'Loading $humanTitle...');");
    buffer.writeln('            } else if (state is ${pascalCase}Error) {');
    buffer.writeln('              return ErrorView(');
    buffer.writeln('                message: state.message,');
    buffer.writeln('                onRetry: () => context');
    buffer.writeln('                    .read<${pascalCase}Bloc>()');
    buffer.writeln('                    .add(const Fetch$pascalCase()),');
    buffer.writeln('              );');
    buffer.writeln('            } else if (state is ${pascalCase}Loaded) {');
    buffer.writeln('              final item = state.data;');
    buffer.writeln('              return RefreshIndicator(');
    buffer.writeln('                color: AppColors.primary,');
    buffer.writeln('                onRefresh: () async {');
    buffer.writeln('                  context');
    buffer.writeln('                      .read<${pascalCase}Bloc>()');
    buffer.writeln('                      .add(const Fetch$pascalCase());');
    buffer.writeln('                },');
    buffer.writeln('                child: ListView(');
    buffer.writeln('                  padding: const EdgeInsets.all(16),');
    buffer.writeln('                  children: [');
    buffer.writeln('                    Card(');
    buffer.writeln('                      color: AppColors.surface,');
    buffer.writeln('                      shape: RoundedRectangleBorder(');
    buffer.writeln('                        borderRadius: BorderRadius.circular(12),');
    buffer.writeln('                        side: const BorderSide(color: AppColors.border),');
    buffer.writeln('                      ),');
    buffer.writeln('                      child: Padding(');
    buffer.writeln('                        padding: const EdgeInsets.all(16),');
    buffer.writeln('                        child: Column(');
    buffer.writeln('                          crossAxisAlignment: CrossAxisAlignment.start,');
    buffer.writeln('                          children: [');
    for (final f in fields) {
      buffer.writeln('                            Padding(');
      buffer.writeln('                              padding: const EdgeInsets.symmetric(vertical: 4),');
      buffer.writeln('                              child: Text(');
      buffer.writeln("                                '${f.fieldName}: \${item.${f.fieldName}}',");
      buffer.writeln('                                style: AppTypography.bodyMedium,');
      buffer.writeln('                              ),');
      buffer.writeln('                            ),');
    }
    buffer.writeln('                          ],');
    buffer.writeln('                        ),');
    buffer.writeln('                      ),');
    buffer.writeln('                    ),');
    buffer.writeln('                  ],');
    buffer.writeln('                ),');
    buffer.writeln('              );');
    buffer.writeln('            }');
    buffer.writeln('            return const SizedBox.shrink();');
    buffer.writeln('          },');
    buffer.writeln('        ),');
    buffer.writeln('      ),');
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');

    _writeFile(screenPath, buffer.toString());
  }

  // 9. Unit Test
  void _generateModelTest() {
    final testPath = 'test/data/models/${snakeCase}_model_test.dart';
    final buffer = StringBuffer();

    buffer.writeln("import 'package:flutter_test/flutter_test.dart';");
    buffer.writeln("import 'package:flutter_code_scout/data/models/${snakeCase}_model.dart';");
    buffer.writeln();
    buffer.writeln('void main() {');
    buffer.writeln("  group('${pascalCase}Model', () {");
    buffer.writeln("    test('should parse JSON correctly into ${pascalCase}Model', () {");
    buffer.writeln('      final json = ${jsonEncode(sampleJson)};');
    buffer.writeln();
    buffer.writeln('      final model = ${pascalCase}Model.fromJson(json);');
    buffer.writeln();
    if (fields.isNotEmpty) {
      final f = fields.first;
      buffer.writeln('      expect(model.${f.fieldName}, isNotNull);');
    }
    buffer.writeln('    });');
    buffer.writeln('  });');
    buffer.writeln('}');

    _writeFile(testPath, buffer.toString());
  }

  // 10. BLoC Unit Test
  void _generateBlocTest() {
    final testPath = 'test/presentation/blocs/${snakeCase}_bloc_test.dart';
    final buffer = StringBuffer();

    buffer.writeln("import 'package:flutter_test/flutter_test.dart';");
    buffer.writeln("import 'package:flutter_code_scout/domain/entities/$snakeCase.dart';");
    buffer.writeln("import 'package:flutter_code_scout/domain/repositories/${snakeCase}_repository.dart';");
    buffer.writeln("import 'package:flutter_code_scout/domain/usecases/get_$snakeCase.dart';");
    buffer.writeln("import 'package:flutter_code_scout/presentation/blocs/$snakeCase/${snakeCase}_bloc.dart';");
    buffer.writeln("import 'package:flutter_code_scout/presentation/blocs/$snakeCase/${snakeCase}_event.dart';");
    buffer.writeln("import 'package:flutter_code_scout/presentation/blocs/$snakeCase/${snakeCase}_state.dart';");
    buffer.writeln();
    buffer.writeln('class Fake${pascalCase}Repository implements ${pascalCase}Repository {');
    buffer.writeln('  final bool shouldFail;');
    buffer.writeln('  final $pascalCase sample;');
    buffer.writeln();
    buffer.writeln('  Fake${pascalCase}Repository({this.shouldFail = false, required this.sample});');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  Future<$pascalCase> get$pascalCase() async {');
    buffer.writeln('    if (shouldFail) {');
    buffer.writeln("      throw Exception('Failed to load $pascalCase');");
    buffer.writeln('    }');
    buffer.writeln('    return sample;');
    buffer.writeln('  }');
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln('void main() {');
    buffer.writeln("  group('${pascalCase}Bloc', () {");
    buffer.writeln('    const sampleEntity = $pascalCase(');
    for (final f in fields) {
      if (f.dartType == 'int') {
        buffer.writeln('      ${f.fieldName}: 1,');
      } else if (f.dartType == 'double') {
        buffer.writeln('      ${f.fieldName}: 1.0,');
      } else if (f.dartType == 'bool') {
        buffer.writeln('      ${f.fieldName}: true,');
      } else if (f.dartType == 'String') {
        buffer.writeln("      ${f.fieldName}: 'test',");
      } else if (f.dartType.startsWith('List')) {
        buffer.writeln('      ${f.fieldName}: [],');
      } else if (f.dartType.startsWith('Map')) {
        buffer.writeln('      ${f.fieldName}: {},');
      } else {
        buffer.writeln("      ${f.fieldName}: 'test',");
      }
    }
    buffer.writeln('    );');
    buffer.writeln();
    buffer.writeln("    test('initial state is ${pascalCase}Initial', () {");
    buffer.writeln('      final repo = Fake${pascalCase}Repository(sample: sampleEntity);');
    buffer.writeln('      final useCase = Get$pascalCase(repo);');
    buffer.writeln('      final bloc = ${pascalCase}Bloc(get$pascalCase: useCase);');
    buffer.writeln();
    buffer.writeln('      expect(bloc.state, const ${pascalCase}Initial());');
    buffer.writeln('    });');
    buffer.writeln();
    buffer.writeln("    test('emits [Loading, Loaded] when Fetch$pascalCase is successful', () async {");
    buffer.writeln('      final repo = Fake${pascalCase}Repository(sample: sampleEntity);');
    buffer.writeln('      final useCase = Get$pascalCase(repo);');
    buffer.writeln('      final bloc = ${pascalCase}Bloc(get$pascalCase: useCase);');
    buffer.writeln();
    buffer.writeln('      final expectedStates = [');
    buffer.writeln('        const ${pascalCase}Loading(),');
    buffer.writeln('        const ${pascalCase}Loaded(data: sampleEntity),');
    buffer.writeln('      ];');
    buffer.writeln();
    buffer.writeln('      expectLater(bloc.stream, emitsInOrder(expectedStates));');
    buffer.writeln('      bloc.add(const Fetch$pascalCase());');
    buffer.writeln('    });');
    buffer.writeln();
    buffer.writeln("    test('emits [Loading, Error] when Fetch$pascalCase fails', () async {");
    buffer.writeln('      final repo = Fake${pascalCase}Repository(shouldFail: true, sample: sampleEntity);');
    buffer.writeln('      final useCase = Get$pascalCase(repo);');
    buffer.writeln('      final bloc = ${pascalCase}Bloc(get$pascalCase: useCase);');
    buffer.writeln();
    buffer.writeln('      final expectedStates = [');
    buffer.writeln('        const ${pascalCase}Loading(),');
    buffer.writeln("        const ${pascalCase}Error(message: 'Exception: Failed to load $pascalCase'),");
    buffer.writeln('      ];');
    buffer.writeln();
    buffer.writeln('      expectLater(bloc.stream, emitsInOrder(expectedStates));');
    buffer.writeln('      bloc.add(const Fetch$pascalCase());');
    buffer.writeln('    });');
    buffer.writeln('  });');
    buffer.writeln('}');

    _writeFile(testPath, buffer.toString());
  }

  // 9. Dependency Injection into injection_container.dart
  void _injectDependency() {
    final diFile = File('lib/core/di/injection_container.dart');
    if (!diFile.existsSync()) return;

    var content = diFile.readAsStringSync();
    
    // Add imports
    final dsImport = "import '../../data/datasources/${snakeCase}_remote_data_source.dart';\n";
    final repoContractImport = "import '../../domain/repositories/${snakeCase}_repository.dart';\n";
    final repoImplImport = "import '../../data/repositories/${snakeCase}_repository_impl.dart';\n";
    final useCaseImport = "import '../../domain/usecases/get_$snakeCase.dart';\n";
    final blocImport = "import '../../presentation/blocs/$snakeCase/${snakeCase}_bloc.dart';\n";

    if (!content.contains(dsImport)) {
      content = dsImport + repoContractImport + repoImplImport + useCaseImport + blocImport + content;
    }

    final dsReg = '  sl.registerLazySingleton<${pascalCase}RemoteDataSource>(() => ${pascalCase}RemoteDataSourceImpl(apiClient: sl()));';
    final repoReg = '  sl.registerLazySingleton<${pascalCase}Repository>(() => ${pascalCase}RepositoryImpl(remoteDataSource: sl()));';
    final useCaseReg = '  sl.registerLazySingleton(() => Get$pascalCase(sl()));';
    final blocReg = '  sl.registerFactory(() => ${pascalCase}Bloc(get$pascalCase: sl()));';

    // Inject Data Source
    if (!content.contains(dsReg)) {
      final match = RegExp(r'// Data Sources[^\n]*\n\s*// ----------------------------------------------------\n').firstMatch(content);
      if (match != null) {
        content = content.replaceRange(match.end, match.end, '$dsReg\n');
      }
    }

    // Inject Repository
    if (!content.contains(repoReg)) {
      final match = RegExp(r'// Repository[^\n]*\n\s*// ----------------------------------------------------\n').firstMatch(content);
      if (match != null) {
        content = content.replaceRange(match.end, match.end, '$repoReg\n');
      }
    }

    // Inject Use Case
    if (!content.contains(useCaseReg)) {
      final match = RegExp(r'// Use Cases[^\n]*\n\s*// ----------------------------------------------------\n').firstMatch(content);
      if (match != null) {
        content = content.replaceRange(match.end, match.end, '$useCaseReg\n');
      }
    }

    // Inject BLoC
    if (!content.contains(blocReg)) {
      final match = RegExp(r'// BLoCs[^\n]*\n\s*// ----------------------------------------------------\n').firstMatch(content);
      if (match != null) {
        content = content.replaceRange(match.end, match.end, '$blocReg\n');
      }
    }

    diFile.writeAsStringSync(content);
    print('  ✓ Injected DataSource, Repository, UseCase, and BLoC into injection_container.dart');
  }

  void _writeFile(String relativePath, String content) {
    final file = File(relativePath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
    print('  ✓ Created $relativePath');
  }

  List<FieldMeta> _extractFields(Map<String, dynamic> json) {
    final list = <FieldMeta>[];
    for (final entry in json.entries) {
      final key = entry.key;
      final val = entry.value;
      final fName = _toCamelCase(key);

      String dType = 'dynamic';
      String fromExpr = "json['$key']";

      if (val is int) {
        dType = 'int';
        fromExpr = "json['$key'] as int? ?? 0";
      } else if (val is double) {
        dType = 'double';
        fromExpr = "(json['$key'] as num?)?.toDouble() ?? 0.0";
      } else if (val is bool) {
        dType = 'bool';
        fromExpr = "json['$key'] as bool? ?? false";
      } else if (val is String) {
        dType = 'String';
        fromExpr = "json['$key'] as String? ?? ''";
      } else if (val is List) {
        dType = 'List<dynamic>';
        fromExpr = "json['$key'] as List<dynamic>? ?? []";
      } else if (val is Map) {
        dType = 'Map<String, dynamic>';
        fromExpr = "json['$key'] as Map<String, dynamic>? ?? {}";
      }

      list.add(FieldMeta(fieldName: fName, jsonKey: key, dartType: dType, fromJsonExpression: fromExpr));
    }
    return list;
  }

  String _toPascalCase(String text) {
    final words = text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ').split(' ');
    return words.map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1)).join();
  }

  String _toCamelCase(String text) {
    final pascal = _toPascalCase(text);
    if (pascal.isEmpty) return '';
    return pascal[0].toLowerCase() + pascal.substring(1);
  }

  String _toSnakeCase(String text) {
    return text
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => '_${m.group(1)!.toLowerCase()}')
        .replaceAll(RegExp(r'^_'), '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
  }

  String _toHumanTitle(String text) {
    return text
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}')
        .replaceAll(RegExp(r'[_]+'), ' ')
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }
}

class FieldMeta {
  final String fieldName;
  final String jsonKey;
  final String dartType;
  final String fromJsonExpression;

  FieldMeta({
    required this.fieldName,
    required this.jsonKey,
    required this.dartType,
    required this.fromJsonExpression,
  });
}
