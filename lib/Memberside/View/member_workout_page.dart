import 'package:azanto/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MemberWorkoutPage extends StatelessWidget {
  const MemberWorkoutPage({super.key});

  static const List<_WorkoutDay> _days = [
    _WorkoutDay(label: 'Mon', dayNumber: '12'),
    _WorkoutDay(label: 'Tues', dayNumber: '12'),
    _WorkoutDay(label: 'Wed', dayNumber: '12'),
    _WorkoutDay(label: 'Thur', dayNumber: '12', isSelected: true),
    _WorkoutDay(label: 'Fri', dayNumber: '12'),
    _WorkoutDay(label: 'Sat', dayNumber: '12'),
    _WorkoutDay(label: 'Sun', dayNumber: '12'),
  ];

  static const List<_WorkoutExercise> _exercises = [
    _WorkoutExercise(
        title: 'Bench Press', sets: 4, reps: 10, isCompleted: true),
    _WorkoutExercise(title: 'Bench Press', sets: 4, reps: 10),
    _WorkoutExercise(title: 'Bench Press', sets: 4, reps: 10),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3C3C3C),
            Color(0xFF343434),
            Color(0xFF2D2D2D),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
           
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 72,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, index) => _DayCard(day: _days[index]),
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemCount: _days.length,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const _WorkoutFocusCard(),
                    const SizedBox(height: 14),
                    Text(
                      'Target Exercise',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._exercises.map(
                      (exercise) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ExerciseCard(exercise: exercise),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _CompleteButton(
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.04),
        ),
        child: Icon(icon, color: Colors.white70, size: 19),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day});

  final _WorkoutDay day;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = day.isSelected;

    return Column(
      children: [
        Text(
          day.label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.white38,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 52,
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFF4F9618) : const Color(0xFF515151),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.brandGreen : Colors.transparent,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.brandGreen.withValues(alpha: 0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              day.dayNumber,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 29,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkoutFocusCard extends StatelessWidget {
  const _WorkoutFocusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF353535),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upper Body Focus',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Day 3 . Strength',
                      style: GoogleFonts.poppins(
                        color: Colors.white38,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Chest & Triceps',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.dumbbell,
                color: AppColors.brandGreen.withValues(alpha: 0.35),
                size: 40,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const LinearProgressIndicator(
                    value: 0.60,
                    minHeight: 10,
                    backgroundColor: Color(0xFF696969),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.brandGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '60%',
                style: GoogleFonts.poppins(
                  color: AppColors.brandGreen,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise});

  final _WorkoutExercise exercise;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4B4B4B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.dumbbell,
              color: AppColors.brandGreen,
              size: 17,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.diamond,
                      size: 12,
                      color: Colors.white38,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${exercise.sets} Sets',
                      style: GoogleFonts.poppins(
                        color: Colors.white38,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      LucideIcons.repeat2,
                      size: 12,
                      color: Colors.white38,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${exercise.reps} Reps',
                      style: GoogleFonts.poppins(
                        color: Colors.white38,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: exercise.isCompleted
                  ? AppColors.brandGreen
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: exercise.isCompleted
                    ? AppColors.brandGreen
                    : Colors.white.withValues(alpha: 0.20),
                width: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompleteButton extends StatelessWidget {
  const _CompleteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: [Color(0xFF5ACF00), Color(0xFF74FF2A)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandGreen.withValues(alpha: 0.20),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Mark as Completed',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkoutDay {
  const _WorkoutDay({
    required this.label,
    required this.dayNumber,
    this.isSelected = false,
  });

  final String label;
  final String dayNumber;
  final bool isSelected;
}

class _WorkoutExercise {
  const _WorkoutExercise({
    required this.title,
    required this.sets,
    required this.reps,
    this.isCompleted = false,
  });

  final String title;
  final int sets;
  final int reps;
  final bool isCompleted;
}
