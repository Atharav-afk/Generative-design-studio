import 'package:flutter/material.dart';
import '../models/constraint_input.dart';

/// Form for entering the design domain, load, boundary condition,
/// material, and optimization targets. Calls [onSubmit] with a valid
/// [ConstraintInput] when the user taps generate.
class ConstraintForm extends StatefulWidget {
  final ValueChanged<ConstraintInput> onSubmit;
  final bool isSubmitting;

  const ConstraintForm({
    super.key,
    required this.onSubmit,
    this.isSubmitting = false,
  });

  @override
  State<ConstraintForm> createState() => _ConstraintFormState();
}

class _ConstraintFormState extends State<ConstraintForm> {
  final _formKey = GlobalKey<FormState>();

  final _length = TextEditingController(text: '200');
  final _width = TextEditingController(text: '50');
  final _height = TextEditingController(text: '50');
  final _load = TextEditingController(text: '1000');
  final _maxMass = TextEditingController(text: '0.5');
  final _minSafety = TextEditingController(text: '1.5');

  BoundaryCondition _boundary = BoundaryCondition.cantilever;
  DesignMaterial _material = DesignMaterial.aluminum6061;

  @override
  void dispose() {
    for (final c in [_length, _width, _height, _load, _maxMass, _minSafety]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _positiveNumberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final n = double.tryParse(value);
    if (n == null) return 'Enter a number';
    if (n <= 0) return 'Must be > 0';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(ConstraintInput(
      lengthMm: double.parse(_length.text),
      widthMm: double.parse(_width.text),
      heightMm: double.parse(_height.text),
      loadN: double.parse(_load.text),
      boundaryCondition: _boundary,
      material: _material,
      maxMassKg: double.parse(_maxMass.text),
      minSafetyFactor: double.parse(_minSafety.text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Design domain (bounding box, mm)'),
          Row(
            children: [
              Expanded(
                  child: _numberField(_length, 'Length',
                      validator: _positiveNumberValidator)),
              const SizedBox(width: 12),
              Expanded(
                  child: _numberField(_width, 'Width',
                      validator: _positiveNumberValidator)),
              const SizedBox(width: 12),
              Expanded(
                  child: _numberField(_height, 'Height',
                      validator: _positiveNumberValidator)),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle('Loading'),
          _numberField(_load, 'Applied load (N)',
              validator: _positiveNumberValidator),
          const SizedBox(height: 12),
          DropdownButtonFormField<BoundaryCondition>(
            value: _boundary,
            decoration: const InputDecoration(
              labelText: 'Boundary condition',
              border: OutlineInputBorder(),
            ),
            items: BoundaryCondition.values
                .map((b) => DropdownMenuItem(value: b, child: Text(b.label)))
                .toList(),
            onChanged: (v) => setState(() => _boundary = v!),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Material'),
          DropdownButtonFormField<DesignMaterial>(
            value: _material,
            decoration: const InputDecoration(
              labelText: 'Material',
              border: OutlineInputBorder(),
            ),
            items: DesignMaterial.values
                .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                .toList(),
            onChanged: (v) => setState(() => _material = v!),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Optimization targets'),
          _numberField(_maxMass, 'Max mass (kg)',
              validator: _positiveNumberValidator),
          const SizedBox(height: 12),
          _numberField(_minSafety, 'Min safety factor',
              validator: _positiveNumberValidator),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: widget.isSubmitting ? null : _submit,
            icon: widget.isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome),
            label:
                Text(widget.isSubmitting ? 'Submitting…' : 'Generate Design'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
      );

  Widget _numberField(TextEditingController controller, String label,
      {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
