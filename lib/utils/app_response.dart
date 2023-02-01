import 'package:conduit/conduit.dart';
import 'package:dart_application_conduit_example/models/ModelRespone.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class AppResponse extends Response {
  AppResponse.ok({dynamic body, String? message})
      : super.ok(ModelResponse(data: body, message: message));

  AppResponse.badrequest({String? message})
      : super.badRequest(
            body: ModelResponse(message: message ?? 'Request error'));

  AppResponse.serverError(dynamic error, {String? message})
      : super.serverError(body: _getModelResponse(error, message));

  static ModelResponse _getModelResponse(error, String? message) {
    if (error is QueryException) {
      return ModelResponse(
          error: error.toString(), message: message ?? error.message);
    }

    if (error is JwtException) {
      return ModelResponse(
          error: error.toString(), message: message ?? error.message);
    }
    return ModelResponse(
        error: error.toString(), message: message ?? "Unknown error");
  }
}
