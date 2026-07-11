import 'package:flutter/material.dart';

import '../models/constraint_input.dart';
import '../services/api_service.dart';
import '../widgets/constraint_form.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(ConstraintInput input) async {
    setState(() => _isSubmitting = true);
    try {
      final jobId = await _api.submitDesign(input);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResultScreen(jobId: jobId)),
      );
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generative Design Studio')),
      body: ConstraintForm(
        onSubmit: _handleSubmit,
        isSubmitting: _isSubmitting,
      ),
    );
  }
}
