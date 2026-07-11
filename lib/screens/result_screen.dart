import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../models/design_job.dart';
import '../services/api_service.dart';

class ResultScreen extends StatefulWidget {
  final String jobId;
  const ResultScreen({super.key, required this.jobId});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _api = ApiService();
  DesignJob? _job;
  String? _errorMessage;
  double? _downloadProgress;
  String? _downloadedPath;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  void _startPolling() {
    _api.pollJob(widget.jobId).listen(
      (job) {
        if (!mounted) return;
        setState(() => _job = job);
      },
      onError: (e) {
        if (!mounted) return;
        setState(() => _errorMessage = e.toString());
      },
    );
  }

  Future<void> _downloadStl() async {
    setState(() => _downloadProgress = 0);
    try {
      final path = await _api.downloadStl(
        widget.jobId,
        onProgress: (p) => setState(() => _downloadProgress = p),
      );
      setState(() {
        _downloadedPath = path;
        _downloadProgress = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to $path')),
        );
      }
    } catch (e) {
      setState(() => _downloadProgress = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  Future<void> _openStlExternally() async {
    final uri = Uri.parse(AppConfig.stlEndpoint(widget.jobId));
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open STL link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design Result')),
      body: _errorMessage != null
          ? _buildError(_errorMessage!)
          : _job == null
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(_job!),
    );
  }

  Widget _buildError(String message) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700, size: 40),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      );

  Widget _buildBody(DesignJob job) {
    switch (job.status) {
      case JobStatus.queued:
      case JobStatus.generating:
      case JobStatus.simulating:
        return _buildProgress(job);
      case JobStatus.failed:
        return _buildError(job.errorMessage ?? 'Generation failed');
      case JobStatus.completed:
        return _buildCompleted(job);
    }
  }

  Widget _buildProgress(DesignJob job) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(value: job.progress),
            const SizedBox(height: 20),
            Text(job.status.label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'AI is generating geometry and the physics engine is '
              'validating it in the loop…',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleted(DesignJob job) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 320,
            child: ModelViewer(
              src: AppConfig.glbEndpoint(widget.jobId),
              alt: 'Generated design preview',
              ar: false,
              autoRotate: true,
              cameraControls: true,
              backgroundColor: const Color(0xFFEFEFEF),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (job.metrics != null) _buildMetrics(job.metrics!),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _downloadProgress != null ? null : _downloadStl,
          icon: const Icon(Icons.download),
          label: Text(_downloadProgress != null
              ? 'Downloading ${(_downloadProgress! * 100).toStringAsFixed(0)}%'
              : 'Download STL'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _openStlExternally,
          icon: const Icon(Icons.open_in_new),
          label: const Text('Open in another app'),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
        if (_downloadedPath != null) ...[
          const SizedBox(height: 12),
          Text('Saved locally at:\n$_downloadedPath',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }

  Widget _buildMetrics(DesignMetrics m) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Simulation results',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _metricRow('Mass', '${m.massKg.toStringAsFixed(3)} kg'),
            _metricRow('Max stress', '${m.maxStressMpa.toStringAsFixed(1)} MPa'),
            _metricRow('Max displacement',
                '${m.maxDisplacementMm.toStringAsFixed(3)} mm'),
            _metricRow('Safety factor', m.safetyFactor.toStringAsFixed(2),
                highlight: m.safetyFactor < 1.5),
          ],
        ),
      ),
    );
  }

  Widget _metricRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: highlight ? Colors.red.shade700 : null,
            ),
          ),
        ],
      ),
    );
  }
}
