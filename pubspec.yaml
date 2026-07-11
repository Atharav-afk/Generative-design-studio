enum JobStatus { queued, generating, simulating, completed, failed }

JobStatus jobStatusFromString(String value) {
  switch (value) {
    case 'queued':
      return JobStatus.queued;
    case 'generating':
      return JobStatus.generating;
    case 'simulating':
      return JobStatus.simulating;
    case 'completed':
      return JobStatus.completed;
    case 'failed':
      return JobStatus.failed;
    default:
      return JobStatus.queued;
  }
}

extension JobStatusLabel on JobStatus {
  String get label {
    switch (this) {
      case JobStatus.queued:
        return 'Queued';
      case JobStatus.generating:
        return 'Generating geometry';
      case JobStatus.simulating:
        return 'Running physics simulation';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.failed:
        return 'Failed';
    }
  }
}

/// Physics-sim results reported back for the generated design.
class DesignMetrics {
  final double massKg;
  final double maxStressMpa;
  final double maxDisplacementMm;
  final double safetyFactor;

  const DesignMetrics({
    required this.massKg,
    required this.maxStressMpa,
    required this.maxDisplacementMm,
    required this.safetyFactor,
  });

  factory DesignMetrics.fromJson(Map<String, dynamic> json) => DesignMetrics(
        massKg: (json['mass_kg'] as num?)?.toDouble() ?? 0,
        maxStressMpa: (json['max_stress_mpa'] as num?)?.toDouble() ?? 0,
        maxDisplacementMm:
            (json['max_displacement_mm'] as num?)?.toDouble() ?? 0,
        safetyFactor: (json['safety_factor'] as num?)?.toDouble() ?? 0,
      );
}

class DesignJob {
  final String jobId;
  final JobStatus status;
  final double? progress; // 0.0 - 1.0, if backend reports it
  final DesignMetrics? metrics;
  final String? errorMessage;

  const DesignJob({
    required this.jobId,
    required this.status,
    this.progress,
    this.metrics,
    this.errorMessage,
  });

  factory DesignJob.fromJson(Map<String, dynamic> json) => DesignJob(
        jobId: json['job_id'] as String,
        status: jobStatusFromString(json['status'] as String),
        progress: (json['progress'] as num?)?.toDouble(),
        metrics: json['metrics'] != null
            ? DesignMetrics.fromJson(json['metrics'] as Map<String, dynamic>)
            : null,
        errorMessage: json['error'] as String?,
      );

  bool get isTerminal =>
      status == JobStatus.completed || status == JobStatus.failed;
}
