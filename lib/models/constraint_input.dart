enum BoundaryCondition { cantilever, simplySupported, fixedBothEnds }

extension BoundaryConditionLabel on BoundaryCondition {
  String get label {
    switch (this) {
      case BoundaryCondition.cantilever:
        return 'Cantilever';
      case BoundaryCondition.simplySupported:
        return 'Simply Supported';
      case BoundaryCondition.fixedBothEnds:
        return 'Fixed Both Ends';
    }
  }

  String get apiValue {
    switch (this) {
      case BoundaryCondition.cantilever:
        return 'cantilever';
      case BoundaryCondition.simplySupported:
        return 'simply_supported';
      case BoundaryCondition.fixedBothEnds:
        return 'fixed_both_ends';
    }
  }
}

enum DesignMaterial { aluminum6061, steel1018, titaniumTi6Al4V, pla }

extension DesignMaterialLabel on DesignMaterial {
  String get label {
    switch (this) {
      case DesignMaterial.aluminum6061:
        return 'Aluminum 6061-T6';
      case DesignMaterial.steel1018:
        return 'Steel 1018';
      case DesignMaterial.titaniumTi6Al4V:
        return 'Titanium Ti-6Al-4V';
      case DesignMaterial.pla:
        return 'PLA (3D print)';
    }
  }

  String get apiValue {
    switch (this) {
      case DesignMaterial.aluminum6061:
        return 'al_6061_t6';
      case DesignMaterial.steel1018:
        return 'steel_1018';
      case DesignMaterial.titaniumTi6Al4V:
        return 'ti_6al4v';
      case DesignMaterial.pla:
        return 'pla';
    }
  }
}

/// Everything the generative pipeline needs: the design domain, applied
/// load, boundary condition, material, and the optimization targets.
class ConstraintInput {
  final double lengthMm;
  final double widthMm;
  final double heightMm;
  final double loadN;
  final BoundaryCondition boundaryCondition;
  final DesignMaterial material;
  final double maxMassKg;
  final double minSafetyFactor;

  const ConstraintInput({
    required this.lengthMm,
    required this.widthMm,
    required this.heightMm,
    required this.loadN,
    required this.boundaryCondition,
    required this.material,
    required this.maxMassKg,
    required this.minSafetyFactor,
  });

  Map<String, dynamic> toJson() => {
        'domain': {
          'length_mm': lengthMm,
          'width_mm': widthMm,
          'height_mm': heightMm,
        },
        'load_n': loadN,
        'boundary_condition': boundaryCondition.apiValue,
        'material': material.apiValue,
        'constraints': {
          'max_mass_kg': maxMassKg,
          'min_safety_factor': minSafetyFactor,
        },
      };
}
