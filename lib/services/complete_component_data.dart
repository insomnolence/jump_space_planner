import '../models/component.dart';

/// Complete component data based on Jump Space Steam Guide
/// Components with identical shapes across all MK levels are consolidated
class CompleteComponentData {
  // JUMP DRIVE
  static Component getJumpDrive() {
    return const Component(
      id: 'jump_drive',
      name: 'Jump Drive',
      type: ComponentType.jumpDrive,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
        GridPosition(x: 0, y: 1),
      ]),
      markLevel: 1,
    );
  }

  // SENSORS
  static Component getSectorScanner() {
    return const Component(
      id: 'sector_scanner',
      name: 'Sector Scanner',
      type: ComponentType.sensor,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
      ]),
      markLevel: 1,
    );
  }

  static Component getSupplyUplinkUnit() {
    return const Component(
      id: 'supply_uplink',
      name: 'Supply Uplink Unit',
      type: ComponentType.sensor,
      shape: ComponentShape([
        GridPosition(x: 1, y: 0),
        GridPosition(x: 2, y: 0),
        GridPosition(x: 0, y: 1),
        GridPosition(x: 1, y: 1),
      ]),
      markLevel: 1,
    );
  }

  static Component getVectorTargetingModule() {
    return const Component(
      id: 'vector_targeting',
      name: 'Vector Targeting Module',
      type: ComponentType.sensor,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
        GridPosition(x: 2, y: 0),
        GridPosition(x: 0, y: 1),
      ]),
      markLevel: 1,
    );
  }

  // ENGINES (All have same shape across MK levels)
  static Component getDriftPhaseEngine() {
    return const Component(
      id: 'drift_phase_engine',
      name: 'Drift Phase Engine (MK1-3)',
      type: ComponentType.engine,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
        GridPosition(x: 2, y: 0),
      ]),
      markLevel: 1,
    );
  }

  static Component getNitroPulseEngine() {
    return const Component(
      id: 'nitro_pulse_engine',
      name: 'Nitro Pulse Engine (MK1-3)',
      type: ComponentType.engine,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
        GridPosition(x: 2, y: 0),
        GridPosition(x: 3, y: 0),
      ]),
      markLevel: 1,
    );
  }

  static Component getMicroplasmaEngine() {
    return const Component(
      id: 'microplasma_engine',
      name: 'Microplasma Engine (MK1-3)',
      type: ComponentType.engine,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
      ]),
      markLevel: 1,
    );
  }

  static Component getMassEjectorEngine() {
    return const Component(
      id: 'mass_ejector_engine',
      name: 'Mass Ejector Engine (MK1-3)',
      type: ComponentType.engine,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
        GridPosition(x: 2, y: 0),
      ]),
      markLevel: 1,
    );
  }

  // PILOT CANNONS
  static Component getFragmentCannon() {
    return const Component(
      id: 'fragment_cannon',
      name: 'Fragment Cannon (MK1-3)',
      type: ComponentType.pilotCannon,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
        GridPosition(x: 2, y: 0),
      ]),
      markLevel: 1,
    );
  }

  static Component getRapidPulseCannon() {
    return const Component(
      id: 'rapid_pulse_cannon',
      name: 'Rapid Pulse Cannon (MK1-3)',
      type: ComponentType.pilotCannon,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
        GridPosition(x: 2, y: 0),
        GridPosition(x: 0, y: 1),
        GridPosition(x: 1, y: 1),
        GridPosition(x: 2, y: 1),
      ]),
      markLevel: 1,
    );
  }

  // Disruptor Laser changes shape between MK levels
  static Component getDisruptorLaserMK1_2() {
    return const Component(
      id: 'disruptor_laser_mk1_2',
      name: 'Disruptor Laser (MK1-2)',
      type: ComponentType.pilotCannon,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
        GridPosition(x: 0, y: 1),
      ]),
      markLevel: 1,
    );
  }

  static Component getDisruptorLaserMK3() {
    return const Component(
      id: 'disruptor_laser_mk3',
      name: 'Disruptor Laser (MK3)',
      type: ComponentType.pilotCannon,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
      ]),
      markLevel: 3,
    );
  }

  static Component getBoltAccelerator() {
    return const Component(
      id: 'bolt_accelerator',
      name: 'Bolt Accelerator (MK1-3)',
      type: ComponentType.pilotCannon,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
        GridPosition(x: 0, y: 1),
        GridPosition(x: 2, y: 0),
        GridPosition(x: 2, y: 1),
      ]),
      markLevel: 1,
    );
  }

  // MULTI TURRETS (All have same shape across MK levels)
  static Component getMiningLasersMK1_2() {
    return const Component(
      id: 'mining_lasers_mk1_2',
      name: 'Mining Lasers (MK1-2)',
      type: ComponentType.multiTurret,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
        GridPosition(x: 0, y: 1),
      ]),
      markLevel: 1,
    );
  }

  static Component getMiningLasersMK3() {
    return const Component(
      id: 'mining_lasers_mk3',
      name: 'Mining Lasers (MK3)',
      type: ComponentType.multiTurret,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
      ]),
      markLevel: 3,
    );
  }

  static Component getAssaultTurrets() {
    return const Component(
      id: 'assault_turrets',
      name: 'Assault Turrets (MK1-3)',
      type: ComponentType.multiTurret,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
        GridPosition(x: 2, y: 0),
        GridPosition(x: 0, y: 1),
      ]),
      markLevel: 1,
    );
  }

  static Component getFlakLauncherTurrets() {
    return const Component(
      id: 'flak_launcher_turrets',
      name: 'Flak Launcher Turrets (MK1-3)',
      type: ComponentType.multiTurret,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
        GridPosition(x: 2, y: 0),
        GridPosition(x: 3, y: 0),
        GridPosition(x: 0, y: 1),
        GridPosition(x: 3, y: 1),
      ]),
      markLevel: 1,
    );
  }

  static Component getGatlingTurrets() {
    return const Component(
      id: 'gatling_turrets',
      name: 'Gatling Turrets (MK1-3)',
      type: ComponentType.multiTurret,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
        GridPosition(x: 2, y: 0),
        GridPosition(x: 0, y: 1),
        GridPosition(x: 1, y: 1),
        GridPosition(x: 2, y: 1),
        GridPosition(x: 0, y: 2),
      ]),
      markLevel: 1,
    );
  }

  // SPECIAL WEAPONS (All have same shape across MK levels)
  static Component getLanceRailgun() {
    return const Component(
      id: 'lance_railgun',
      name: 'Lance Railgun (MK1-3)',
      type: ComponentType.specialWeapon,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
        GridPosition(x: 2, y: 0),
        GridPosition(x: 0, y: 1),
        GridPosition(x: 2, y: 1),
        GridPosition(x: 0, y: 2),
        GridPosition(x: 2, y: 2),
      ]),
      markLevel: 1,
    );
  }

  static Component getMissileLauncher() {
    return const Component(
      id: 'missile_launcher',
      name: 'Missile Launcher (MK1-3)',
      type: ComponentType.specialWeapon,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 0, y: 1),
        GridPosition(x: 0, y: 2),
        GridPosition(x: 1, y: 0),
        GridPosition(x: 1, y: 1),
        GridPosition(x: 1, y: 2),
        GridPosition(x: 2, y: 0),
        GridPosition(x: 2, y: 1),
        GridPosition(x: 2, y: 2),
      ]),
      markLevel: 1,
    );
  }

  static Component getBurstShield() {
    return const Component(
      id: 'burst_shield',
      name: 'Burst Shield (MK1-3)',
      type: ComponentType.specialWeapon,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
        GridPosition(x: 0, y: 1),
        GridPosition(x: 1, y: 1),
      ]),
      markLevel: 1,
    );
  }

  static Component getTargetingModule() {
    return const Component(
      id: 'targeting_module',
      name: 'Targeting Module (MK1-3)',
      type: ComponentType.specialWeapon,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
      ]),
      markLevel: 1,
    );
  }

  // AUXILIARY GENERATORS (All have same shape across MK levels)
  static Component getBioFissionGenerator() {
    return const Component(
      id: 'bio_fission_gen',
      name: 'Bio Fission Generator (MK1-3)',
      type: ComponentType.auxiliaryGenerator,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
        GridPosition(x: 0, y: 1),
        GridPosition(x: 1, y: 1),
      ]),
      markLevel: 1,
    );
  }

  static Component getMateriaShiftGenerator() {
    return const Component(
      id: 'materia_shift_gen',
      name: 'Materia Shift Generator (MK1-3)',
      type: ComponentType.auxiliaryGenerator,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
        GridPosition(x: 2, y: 0),
        GridPosition(x: 0, y: 1),
        GridPosition(x: 1, y: 1),
      ]),
      markLevel: 1,
    );
  }

  static Component getNullTensionGenerator() {
    return const Component(
      id: 'null_tension_gen',
      name: 'Null Tension Generator (MK1-3)',
      type: ComponentType.auxiliaryGenerator,
      shape: ComponentShape([
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
        GridPosition(x: 0, y: 1),
      ]),
      markLevel: 1,
    );
  }

  /// Get all components
  static List<Component> getAllComponents() {
    return [
      getJumpDrive(),

      getSectorScanner(),
      getSupplyUplinkUnit(),
      getVectorTargetingModule(),

      getDriftPhaseEngine(),
      getNitroPulseEngine(),
      getMicroplasmaEngine(),
      getMassEjectorEngine(),

      getFragmentCannon(),
      getRapidPulseCannon(),
      getDisruptorLaserMK1_2(),
      getDisruptorLaserMK3(),
      getBoltAccelerator(),

      getMiningLasersMK1_2(),
      getMiningLasersMK3(),
      getAssaultTurrets(),
      getFlakLauncherTurrets(),
      getGatlingTurrets(),

      getLanceRailgun(),
      getMissileLauncher(),
      getBurstShield(),
      getTargetingModule(),

      getBioFissionGenerator(),
      getMateriaShiftGenerator(),
      getNullTensionGenerator(),
    ];
  }

  /// Get components by type
  static List<Component> getComponentsByType(ComponentType type) {
    return getAllComponents().where((c) => c.type == type).toList();
  }
}
