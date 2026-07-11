import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../config.dart';
import '../models/constraint_input.dart';
import '../models/design_job.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  final http.Client _client;
  final Dio _dio;

  ApiService({http.Client? client, Dio? dio})
      : _client = client ?? http.Client(),
        _dio = dio ?? Dio();

  /// Submits constraints to the pipeline. Returns the new job id.
  Future<String> submitDesign(ConstraintInput input) async {
    final res = await _client
        .post(
          Uri.parse(AppConfig.submitEndpoint()),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(input.toJson()),
        )
        .timeout(AppConfig.requestTimeout);

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw ApiException(
          'Failed to submit design (${res.statusCode}): ${res.body}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final jobId = body['job_id'] as String?;
    if (jobId == null) {
      throw ApiException('Backend did not return a job_id');
    }
    return jobId;
  }

  /// Fetches the current status/metrics for a job.
  Future<DesignJob> getStatus(String jobId) async {
    final res = await _client
        .get(Uri.parse(AppConfig.statusEndpoint(jobId)))
        .timeout(AppConfig.requestTimeout);

    if (res.statusCode != 200) {
      throw ApiException(
          'Failed to fetch job status (${res.statusCode}): ${res.body}');
    }
    return DesignJob.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// Polls until the job reaches a terminal state (completed/failed),
  /// invoking [onUpdate] on every poll.
  Stream<DesignJob> pollJob(String jobId,
      {void Function(DesignJob)? onUpdate}) async* {
    while (true) {
      final job = await getStatus(jobId);
      onUpdate?.call(job);
      yield job;
      if (job.isTerminal) break;
      await Future.delayed(AppConfig.pollInterval);
    }
  }

  /// Downloads the finished STL into the app's documents directory and
  /// returns the local file path. [onProgress] is 0.0-1.0.
  Future<String> downloadStl(String jobId,
      {void Function(double)? onProgress}) async {
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/design_$jobId.stl';

    await _dio.download(
      AppConfig.stlEndpoint(jobId),
      savePath,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress?.call(received / total);
      },
    );
    return savePath;
  }

  void dispose() {
    _client.close();
    _dio.close();
  }
}
