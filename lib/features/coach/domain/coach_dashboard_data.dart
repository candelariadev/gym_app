import 'package:flutter/material.dart';

class CoachDashboardData {
  const CoachDashboardData({
    required this.activeTrainees,
    required this.activeRoutines,
    required this.scheduledSessions,
    required this.recentClients,
  });

  final int activeTrainees;
  final int activeRoutines;
  final int scheduledSessions;
  final List<CoachClient> recentClients;
}

class CoachClient {
  const CoachClient({
    required this.id,
    required this.name,
    required this.initials,
    required this.accentColor,
    required this.statusLabel,
    required this.lastActivityLabel,
    required this.programProgressLabel,
    required this.currentRoutine,
    required this.email,
    required this.goal,
    required this.ageLabel,
    required this.heightLabel,
    required this.weightLabel,
    required this.joinedLabel,
    required this.completedSessions,
    required this.adherenceLabel,
    required this.daysPerWeekLabel,
    required this.programStartLabel,
    required this.programEndLabel,
    required this.programProgressPercent,
    required this.programDurationLabel,
    required this.programLevelLabel,
    required this.currentWeightLabel,
    required this.routineHistory,
  });

  final String id;
  final String name;
  final String initials;
  final Color accentColor;
  final String statusLabel;
  final String lastActivityLabel;
  final String programProgressLabel;
  final String currentRoutine;
  final String email;
  final String goal;
  final String ageLabel;
  final String heightLabel;
  final String weightLabel;
  final String joinedLabel;
  final int completedSessions;
  final String adherenceLabel;
  final String daysPerWeekLabel;
  final String programStartLabel;
  final String programEndLabel;
  final double programProgressPercent;
  final String programDurationLabel;
  final String programLevelLabel;
  final String currentWeightLabel;
  final List<CoachRoutineHistoryItem> routineHistory;
}

class CoachRoutineHistoryItem {
  const CoachRoutineHistoryItem({
    required this.name,
    required this.durationLabel,
    required this.completedAtLabel,
    required this.statusLabel,
  });

  final String name;
  final String durationLabel;
  final String completedAtLabel;
  final String statusLabel;
}

class CoachMockData {
  const CoachMockData._();

  static const List<CoachClient> clients = [
    CoachClient(
      id: 'client-1',
      name: 'Maria Gonzalez',
      initials: 'MG',
      accentColor: Color(0xFF7B4DFF),
      statusLabel: 'Activo',
      lastActivityLabel: 'Hace 2 horas',
      programProgressLabel: 'Semana 3 de 8',
      currentRoutine: 'Rutina Full Body - Principiante',
      email: 'maria@gym.com',
      goal: 'Tonificacion',
      ageLabel: '28 anios',
      heightLabel: '1.63 m',
      weightLabel: '59 kg',
      joinedLabel: 'Enero 2025',
      completedSessions: 14,
      adherenceLabel: '92%',
      daysPerWeekLabel: '3 dias',
      programStartLabel: '15 Dic 2025',
      programEndLabel: '9 Feb 2026',
      programProgressPercent: 0.375,
      programDurationLabel: '45-60 min',
      programLevelLabel: 'Principiante',
      currentWeightLabel: '65 kg',
      routineHistory: [
        CoachRoutineHistoryItem(
          name: 'Rutina de Adaptacion',
          durationLabel: '4 semanas',
          completedAtLabel: '10 Dic 2025',
          statusLabel: 'Completada',
        ),
        CoachRoutineHistoryItem(
          name: 'Rutina Cardio Basico',
          durationLabel: '6 semanas',
          completedAtLabel: '5 Nov 2025',
          statusLabel: 'Completada',
        ),
        CoachRoutineHistoryItem(
          name: 'Rutina de Inicio',
          durationLabel: '2 semanas',
          completedAtLabel: '20 Oct 2025',
          statusLabel: 'Completada',
        ),
      ],
    ),
    CoachClient(
      id: 'client-2',
      name: 'Carlos Ramirez',
      initials: 'CR',
      accentColor: Color(0xFF6B4EFF),
      statusLabel: 'Activo',
      lastActivityLabel: 'Hace 5 horas',
      programProgressLabel: 'Semana 2 de 6',
      currentRoutine: 'Full Body Intermedio',
      email: 'carlos@gym.com',
      goal: 'Ganar masa muscular',
      ageLabel: '31 anios',
      heightLabel: '1.74 m',
      weightLabel: '73 kg',
      joinedLabel: 'Febrero 2025',
      completedSessions: 11,
      adherenceLabel: '88%',
      daysPerWeekLabel: '4 dias',
      programStartLabel: '2 Mar 2026',
      programEndLabel: '14 Abr 2026',
      programProgressPercent: 0.33,
      programDurationLabel: '60 min',
      programLevelLabel: 'Intermedio',
      currentWeightLabel: '73 kg',
      routineHistory: [
        CoachRoutineHistoryItem(
          name: 'Hipertrofia Inicial',
          durationLabel: '5 semanas',
          completedAtLabel: '18 Feb 2026',
          statusLabel: 'Completada',
        ),
      ],
    ),
    CoachClient(
      id: 'client-3',
      name: 'Lucia Morales',
      initials: 'LM',
      accentColor: Color(0xFF18B66E),
      statusLabel: 'Activo',
      lastActivityLabel: 'Ayer',
      programProgressLabel: 'Semana 5 de 10',
      currentRoutine: 'Pierna y Gluteo',
      email: 'lucia@gym.com',
      goal: 'Mejorar resistencia',
      ageLabel: '26 anios',
      heightLabel: '1.68 m',
      weightLabel: '62 kg',
      joinedLabel: 'Octubre 2024',
      completedSessions: 22,
      adherenceLabel: '95%',
      daysPerWeekLabel: '4 dias',
      programStartLabel: '10 Ene 2026',
      programEndLabel: '20 Mar 2026',
      programProgressPercent: 0.5,
      programDurationLabel: '50 min',
      programLevelLabel: 'Intermedio',
      currentWeightLabel: '62 kg',
      routineHistory: [
        CoachRoutineHistoryItem(
          name: 'Resistencia Base',
          durationLabel: '8 semanas',
          completedAtLabel: '5 Ene 2026',
          statusLabel: 'Completada',
        ),
      ],
    ),
    CoachClient(
      id: 'client-4',
      name: 'Jorge Castillo',
      initials: 'JC',
      accentColor: Color(0xFFFFA23A),
      statusLabel: 'Pendiente',
      lastActivityLabel: 'Hace 2 dias',
      programProgressLabel: 'Semana 1 de 4',
      currentRoutine: 'Adaptacion inicial',
      email: 'jorge@gym.com',
      goal: 'Recuperar condicion fisica',
      ageLabel: '35 anios',
      heightLabel: '1.78 m',
      weightLabel: '84 kg',
      joinedLabel: 'Marzo 2025',
      completedSessions: 4,
      adherenceLabel: '76%',
      daysPerWeekLabel: '3 dias',
      programStartLabel: '5 Mar 2026',
      programEndLabel: '5 Abr 2026',
      programProgressPercent: 0.18,
      programDurationLabel: '40 min',
      programLevelLabel: 'Inicial',
      currentWeightLabel: '84 kg',
      routineHistory: [
        CoachRoutineHistoryItem(
          name: 'Reinicio de movilidad',
          durationLabel: '3 semanas',
          completedAtLabel: '12 Feb 2026',
          statusLabel: 'Completada',
        ),
      ],
    ),
    CoachClient(
      id: 'client-5',
      name: 'Sofia Herrera',
      initials: 'SH',
      accentColor: Color(0xFFE848A5),
      statusLabel: 'Activo',
      lastActivityLabel: 'Hace 3 horas',
      programProgressLabel: 'Semana 4 de 8',
      currentRoutine: 'Core y movilidad',
      email: 'sofia@gym.com',
      goal: 'Reducir grasa corporal',
      ageLabel: '29 anios',
      heightLabel: '1.60 m',
      weightLabel: '57 kg',
      joinedLabel: 'Diciembre 2024',
      completedSessions: 16,
      adherenceLabel: '90%',
      daysPerWeekLabel: '5 dias',
      programStartLabel: '1 Feb 2026',
      programEndLabel: '30 Mar 2026',
      programProgressPercent: 0.48,
      programDurationLabel: '45 min',
      programLevelLabel: 'Intermedio',
      currentWeightLabel: '57 kg',
      routineHistory: [
        CoachRoutineHistoryItem(
          name: 'Cardio y Core',
          durationLabel: '6 semanas',
          completedAtLabel: '25 Ene 2026',
          statusLabel: 'Completada',
        ),
      ],
    ),
  ];

  static const CoachDashboardData dashboard = CoachDashboardData(
    activeTrainees: 24,
    activeRoutines: 18,
    scheduledSessions: 12,
    recentClients: clients,
  );
}
