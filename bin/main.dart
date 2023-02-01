import 'dart:io';
import 'package:conduit/conduit.dart';
import 'package:dart_application_conduit_example/dart_application_conduit_example.dart';



void main() async {
  final port = int.parse(Platform.environment["PORT"] ?? "8888");

  final service = Application<DatabaseChannel>()
  ..options.port = port
  ..options.certificateFilePath = 'config.yaml';

  await service.start(numberOfInstances: 3, consoleLogging: true);
}
