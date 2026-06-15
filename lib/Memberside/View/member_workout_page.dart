import 'dart:async';
import 'dart:ui';

import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/workout_service.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/models/workout_model.dart';
import 'package:azanto/views/widgets/azanto_mobile_shell.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MemberWorkoutPage extends StatefulWidget {
  const MemberWorkoutPage({
    super.key,
    this.isActive = false,
  });

  final bool isActive;

  @override
  State<MemberWorkoutPage> createState() => _MemberWorkoutPageState();
}

class _MemberWorkoutPageState extends State<MemberWorkoutPage> {
  late final WorkoutService _workoutService;

  List<WorkoutCategoryModel> _categories = const [];
  WorkoutCategoryModel? _selectedCategory;
  List<WorkoutBodyPartModel> _bodyParts = const [];
  WorkoutBodyPartModel? _selectedBodyPart;
  final Map<String, List<WorkoutExerciseModel>> _exercisesByBodyPart = {};
  final Map<String, WorkoutTrackingModel> _trackingByExerciseId = {};
  final Set<String> _selectedExerciseIds = {};

  String? _currentLogId;
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isSubmitting = false;
  DateTime _now = DateTime.now();
  Timer? _clockTimer;

  // Persistent controllers for bottom sheets to avoid dispose-during-transition errors
  late final TextEditingController _categoryNameCtrl;
  late final TextEditingController _categoryDescCtrl;
  late final TextEditingController _bodyPartNameCtrl;
  late final TextEditingController _exerciseNameCtrl;
  late final TextEditingController _exerciseDescCtrl;
  late final TextEditingController _exerciseSetsCtrl;
  late final TextEditingController _exerciseRepsCtrl;
  late final TextEditingController _trackSetsCtrl;
  late final TextEditingController _trackRepsCtrl;

  @override
  void initState() {
    super.initState();
    _categoryNameCtrl = TextEditingController();
    _categoryDescCtrl = TextEditingController();
    _bodyPartNameCtrl = TextEditingController();
    _exerciseNameCtrl = TextEditingController();
    _exerciseDescCtrl = TextEditingController();
    _exerciseSetsCtrl = TextEditingController();
    _exerciseRepsCtrl = TextEditingController();
    _trackSetsCtrl = TextEditingController();
    _trackRepsCtrl = TextEditingController();

    _workoutService = Get.isRegistered<WorkoutService>()
        ? Get.find<WorkoutService>()
        : WorkoutService();
    _startClock();
    if (widget.isActive) {
      _loadInitialData();
    }
  }

  @override
  void didUpdateWidget(covariant MemberWorkoutPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadInitialData();
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _categoryNameCtrl.dispose();
    _categoryDescCtrl.dispose();
    _bodyPartNameCtrl.dispose();
    _exerciseNameCtrl.dispose();
    _exerciseDescCtrl.dispose();
    _exerciseSetsCtrl.dispose();
    _exerciseRepsCtrl.dispose();
    _trackSetsCtrl.dispose();
    _trackRepsCtrl.dispose();
    super.dispose();
  }

  void _startClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _selectedExerciseIds.clear();
    });
    try {
      final categories = await _workoutService.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _selectedCategory = categories.isNotEmpty ? categories.first : null;
      });
      if (_selectedCategory != null) {
        await _loadCategoryDetails(showLoader: false);
      }
    } on ApiException catch (e) {
      _showError(e.detailMessage);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshWorkoutData() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
      _selectedExerciseIds.clear();
    });
    try {
      final categories = await _workoutService.getCategories();
      if (!mounted) return;
      final previousCategoryId = _selectedCategory?.categoryId;
      setState(() {
        _categories = categories;
        if (categories.isEmpty) {
          _selectedCategory = null;
          _bodyParts = const [];
          _selectedBodyPart = null;
          _exercisesByBodyPart.clear();
          return;
        }
        _selectedCategory = categories.firstWhere(
          (item) => item.categoryId == previousCategoryId,
          orElse: () => categories.first,
        );
      });
      if (_selectedCategory != null) {
        await _loadCategoryDetails(showLoader: false);
      }
    } on ApiException catch (e) {
      _showError(e.detailMessage);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _loadCategoryDetails({bool showLoader = true}) async {
    final category = _selectedCategory;
    if (category == null) return;

    setState(() {
      _selectedExerciseIds.clear();
      if (showLoader) {
        _isLoading = true;
      }
    });

    try {
      final bodyParts =
          await _workoutService.getBodyParts(category.categoryId);
      if (!mounted) return;

      _exercisesByBodyPart.clear();
      for (final bodyPart in bodyParts) {
        final exercises =
            await _workoutService.getExercises(bodyPart.bodyPartId);
        _exercisesByBodyPart[bodyPart.bodyPartId] = exercises;
      }

      if (_currentLogId != null && _currentLogId!.isNotEmpty) {
        await _syncLogHistory(_currentLogId!);
      }

      if (!mounted) return;
      setState(() {
        _bodyParts = bodyParts;
        if (_selectedBodyPart != null &&
            !bodyParts.any(
              (part) => part.bodyPartId == _selectedBodyPart!.bodyPartId,
            )) {
          _selectedBodyPart = null;
        }
      });
    } on ApiException catch (e) {
      _showError(e.detailMessage);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted && showLoader) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _syncLogHistory(String logId) async {
    try {
      final log = await _workoutService.getLogHistory(logId);
      if (!mounted) return;
      final nextTracking = Map<String, WorkoutTrackingModel>.from(
        _trackingByExerciseId,
      );
      for (final item in log.exercises) {
        nextTracking[item.exerciseId] = WorkoutTrackingModel(
          trackingId: item.trackingId,
          logId: log.logId,
          exerciseId: item.exerciseId,
          setsCompleted: item.setsCompleted,
          repsCompleted: item.repsCompleted,
          isCompleted: item.isCompleted,
          createdOn: item.completedAt,
        );
      }
      setState(() {
        _trackingByExerciseId
          ..clear()
          ..addAll(nextTracking);
        _currentLogId = log.logId;
      });
    } on ApiException catch (e) {
      _showError(e.detailMessage);
    }
  }

  List<_ExerciseDisplayItem> get _visibleExercises {
    final items = <_ExerciseDisplayItem>[];
    final bodyParts = _selectedBodyPart == null
        ? _bodyParts
        : [_selectedBodyPart!];

    for (final bodyPart in bodyParts) {
      final exercises = _exercisesByBodyPart[bodyPart.bodyPartId] ?? const [];
      for (final exercise in exercises) {
        items.add(
          _ExerciseDisplayItem(
            exercise: exercise,
            bodyPartName: bodyPart.name,
          ),
        );
      }
    }
    return items;
  }

  double get _progressValue {
    final exercises = _allCategoryExercises;
    if (exercises.isEmpty) return 0;
    final completed = exercises.where((exercise) {
      final tracking = _trackingByExerciseId[exercise.exerciseId];
      return tracking?.isCompleted == true;
    }).length;
    return completed / exercises.length;
  }

  List<WorkoutExerciseModel> get _allCategoryExercises {
    return _exercisesByBodyPart.values.expand((list) => list).toList();
  }

  int get _progressPercent => (_progressValue * 100).round();

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.brandGreen.withValues(alpha: 0.92),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF4A1515),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
  }

  Future<void> _onCreateCategory() async {
    _categoryNameCtrl.clear();
    _categoryDescCtrl.clear();

    final submitted = await _showFormBottomSheet(
      title: 'Add Category',
      fields: [
        _FormFieldConfig(label: 'Name', controller: _categoryNameCtrl, hint: 'Upper Body Focus'),
        _FormFieldConfig(
          label: 'Description',
          controller: _categoryDescCtrl,
          hint: 'Strength training for chest, shoulders and arms',
          maxLines: 3,
        ),
      ],
      submitLabel: 'Create Category',
      onSubmit: () async {
        if (_categoryNameCtrl.text.trim().isEmpty) {
          _showError('Category name is required.');
          return false;
        }
        setState(() => _isSubmitting = true);
        try {
          final created = await _workoutService.createCategory(
            name: _categoryNameCtrl.text,
            description: _categoryDescCtrl.text,
          );
          if (!mounted) return false;
          setState(() {
            _categories = [..._categories, created];
            _selectedCategory = created;
          });
          await _loadCategoryDetails(showLoader: false);
          _showSuccess('Category "${created.name}" created.');
          return true;
        } on ApiException catch (e) {
          _showError(e.detailMessage);
          return false;
        } catch (e) {
          _showError(e.toString());
          return false;
        } finally {
          if (mounted) setState(() => _isSubmitting = false);
        }
      },
    );

    if (submitted == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _onCreateBodyPart() async {
    final category = _selectedCategory;
    if (category == null) {
      _showError('Create a category first.');
      return;
    }

    _bodyPartNameCtrl.clear();
    final submitted = await _showFormBottomSheet(
      title: 'Add Body Part',
      fields: [
        _FormFieldConfig(label: 'Name', controller: _bodyPartNameCtrl, hint: 'Shoulder'),
      ],
      submitLabel: 'Create Body Part',
      onSubmit: () async {
        if (_bodyPartNameCtrl.text.trim().isEmpty) {
          _showError('Body part name is required.');
          return false;
        }
        setState(() => _isSubmitting = true);
        try {
          final created = await _workoutService.createBodyPart(
            name: _bodyPartNameCtrl.text,
            categoryId: category.categoryId,
          );
          if (!mounted) return false;
          setState(() {
            _bodyParts = [..._bodyParts, created];
            _exercisesByBodyPart[created.bodyPartId] = const [];
            _selectedBodyPart = created;
          });
          _showSuccess('Body part "${created.name}" added.');
          return true;
        } on ApiException catch (e) {
          _showError(e.detailMessage);
          return false;
        } catch (e) {
          _showError(e.toString());
          return false;
        } finally {
          if (mounted) setState(() => _isSubmitting = false);
        }
      },
    );
    if (submitted == true && mounted) setState(() {});
  }

  Future<void> _onCreateExercise(WorkoutBodyPartModel bodyPart) async {
    _exerciseNameCtrl.clear();
    _exerciseDescCtrl.clear();
    _exerciseSetsCtrl.text = '3';
    _exerciseRepsCtrl.text = '10';

    final submitted = await _showFormBottomSheet(
      title: 'Add Exercise',
      subtitle: bodyPart.name,
      fields: [
        _FormFieldConfig(label: 'Name', controller: _exerciseNameCtrl, hint: 'Bench Press'),
        _FormFieldConfig(
          label: 'Description',
          controller: _exerciseDescCtrl,
          hint: 'Flat barbell bench press',
          maxLines: 2,
        ),
        _FormFieldConfig(
          label: 'Default Sets',
          controller: _exerciseSetsCtrl,
          hint: '3',
          keyboardType: TextInputType.number,
        ),
        _FormFieldConfig(
          label: 'Default Reps',
          controller: _exerciseRepsCtrl,
          hint: '10',
          keyboardType: TextInputType.number,
        ),
      ],
      submitLabel: 'Create Exercise',
      onSubmit: () async {
        if (_exerciseNameCtrl.text.trim().isEmpty) {
          _showError('Exercise name is required.');
          return false;
        }
        setState(() => _isSubmitting = true);
        try {
          final created = await _workoutService.createExercise(
            name: _exerciseNameCtrl.text,
            bodyPartId: bodyPart.bodyPartId,
            description: _exerciseDescCtrl.text,
            defaultSets: int.tryParse(_exerciseSetsCtrl.text.trim()) ?? 0,
            defaultReps: int.tryParse(_exerciseRepsCtrl.text.trim()) ?? 0,
          );
          if (!mounted) return false;
          setState(() {
            final current =
                _exercisesByBodyPart[bodyPart.bodyPartId] ?? const [];
            _exercisesByBodyPart[bodyPart.bodyPartId] = [...current, created];
          });
          _showSuccess('Exercise "${created.name}" added.');
          return true;
        } on ApiException catch (e) {
          _showError(e.detailMessage);
          return false;
        } catch (e) {
          _showError(e.toString());
          return false;
        } finally {
          if (mounted) setState(() => _isSubmitting = false);
        }
      },
    );

    if (submitted == true && mounted) setState(() {});
  }

  Future<void> _onTrackExercise(_ExerciseDisplayItem item) async {
    final tracking = _trackingByExerciseId[item.exercise.exerciseId];
    if (tracking?.isCompleted == true) return;

    _trackSetsCtrl.text = (tracking?.setsCompleted ?? item.exercise.defaultSets).toString();
    _trackRepsCtrl.text = tracking?.repsCompleted ??
        (item.exercise.defaultReps > 0
            ? item.exercise.defaultReps.toString()
            : '10');

    final submitted = await _showFormBottomSheet(
      title: 'Track Exercise',
      subtitle: item.exercise.name,
      fields: [
        _FormFieldConfig(
          label: 'Sets Completed',
          controller: _trackSetsCtrl,
          hint: '4',
          keyboardType: TextInputType.number,
        ),
        _FormFieldConfig(
          label: 'Reps Completed',
          controller: _trackRepsCtrl,
          hint: '8-12',
        ),
      ],
      submitLabel: 'Save Progress',
      onSubmit: () async {
        final sets = int.tryParse(_trackSetsCtrl.text.trim()) ?? 0;
        if (sets <= 0) {
          _showError('Enter valid sets completed.');
          return false;
        }
        if (_trackRepsCtrl.text.trim().isEmpty) {
          _showError('Enter reps completed.');
          return false;
        }
        setState(() => _isSubmitting = true);
        try {
          final result = await _workoutService.trackExercise(
            exerciseId: item.exercise.exerciseId,
            setsCompleted: sets,
            repsCompleted: _trackRepsCtrl.text.trim(),
          );
          if (!mounted) return false;
          setState(() {
            _trackingByExerciseId[item.exercise.exerciseId] = result;
            _currentLogId = result.logId;
          });
          _showSuccess('Progress saved for ${item.exercise.name}.');
          return true;
        } on ApiException catch (e) {
          _showError(e.detailMessage);
          return false;
        } catch (e) {
          _showError(e.toString());
          return false;
        } finally {
          if (mounted) setState(() => _isSubmitting = false);
        }
      },
    );

    if (submitted == true && mounted) setState(() {});
  }



  void _onToggleSelect(_ExerciseDisplayItem item) {
    final tracking = _trackingByExerciseId[item.exercise.exerciseId];
    if (tracking?.isCompleted == true) return;
    setState(() {
      final id = item.exercise.exerciseId;
      if (_selectedExerciseIds.contains(id)) {
        _selectedExerciseIds.remove(id);
      } else {
        _selectedExerciseIds.add(id);
      }
    });
  }

  Future<void> _onMarkSelectedCompleted() async {
    final selectedItems = _visibleExercises
        .where((item) => _selectedExerciseIds.contains(item.exercise.exerciseId))
        .toList();

    if (selectedItems.isEmpty) {
      _showError('No exercises selected.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      for (final item in selectedItems) {
        var tracking = _trackingByExerciseId[item.exercise.exerciseId];
        tracking ??= await _workoutService.trackExercise(
          exerciseId: item.exercise.exerciseId,
          setsCompleted: item.exercise.defaultSets > 0
              ? item.exercise.defaultSets
              : 1,
          repsCompleted: item.exercise.defaultReps > 0
              ? item.exercise.defaultReps.toString()
              : '1',
        );
        if (!mounted) return;
        _trackingByExerciseId[item.exercise.exerciseId] = tracking;
        _currentLogId = tracking.logId;

        final log = await _workoutService.completeExercise(tracking.trackingId);
        if (!mounted) return;
        _currentLogId = log.logId;
        _trackingByExerciseId[item.exercise.exerciseId] = WorkoutTrackingModel(
          trackingId: tracking.trackingId,
          logId: log.logId,
          exerciseId: item.exercise.exerciseId,
          setsCompleted: tracking.setsCompleted,
          repsCompleted: tracking.repsCompleted,
          isCompleted: true,
        );
      }
      
      setState(() {
        _selectedExerciseIds.removeAll(selectedItems.map((e) => e.exercise.exerciseId));
      });
      _showSuccess('Selected exercises marked as completed.');
    } on ApiException catch (e) {
      _showError(e.detailMessage);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<bool?> _showFormBottomSheet({
    required String title,
    String? subtitle,
    required List<_FormFieldConfig> fields,
    required String submitLabel,
    required Future<bool> Function() onSubmit,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final bottom = MediaQuery.viewInsetsOf(sheetContext).bottom;
        var submitting = false;

        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: StatefulBuilder(
                builder: (modalContext, setModalState) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    color: const Color(0xFF1E1E1E).withValues(alpha: 0.96),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (subtitle != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        subtitle,
                                        style: GoogleFonts.poppins(
                                          color: AppColors.textMuted,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: submitting
                                    ? null
                                    : () => Navigator.pop(sheetContext, false),
                                icon: const Icon(Icons.close, color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...fields.map(
                            (field) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _WorkoutFormField(config: field),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.payButtonStart,
                                    AppColors.payButtonEnd,
                                  ],
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: submitting
                                    ? null
                                    : () async {
                                        setModalState(() => submitting = true);
                                        final success = await onSubmit();
                                        if (!sheetContext.mounted) return;
                                        if (success) {
                                          Navigator.pop(sheetContext, true);
                                        } else {
                                          setModalState(() => submitting = false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: submitting
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        submitLabel,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: AppColors.brandGreen,
            onRefresh: _refreshWorkoutData,
            child: _isLoading
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: azantoContentPadding(context),
                    children: const [
                      SizedBox(height: 180),
                      Center(
                        child: CircularProgressIndicator(
                          color: AppColors.brandGreen,
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: azantoContentPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _WeekDateRow(now: _now),
                        const SizedBox(height: 18),
                        if (_categories.isEmpty)
                          _AddCategoryCard(onTap: _onCreateCategory)
                        else ...[
                          if (_categories.length > 1) ...[
                            _CategorySelector(
                              categories: _categories,
                              selected: _selectedCategory,
                              onSelected: (category) async {
                                setState(() {
                                  _selectedCategory = category;
                                  _selectedBodyPart = null;
                                });
                                await _loadCategoryDetails();
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                          _CategoryFocusCard(
                            category: _selectedCategory!,
                            bodyPartNames: _bodyParts.map((e) => e.name).toList(),
                            progress: _progressValue,
                            progressLabel: '$_progressPercent%',
                            onAddBodyPart: _onCreateBodyPart,
                          ),
                          const SizedBox(height: 14),
                          _BodyPartStrip(
                            bodyParts: _bodyParts,
                            selected: _selectedBodyPart,
                            onSelected: (part) {
                              setState(() {
                                _selectedBodyPart =
                                    _selectedBodyPart?.bodyPartId == part.bodyPartId
                                        ? null
                                        : part;
                              });
                            },
                            onAdd: _onCreateBodyPart,
                          ),
                        ],
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Text(
                              'EXERCISES',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Spacer(),
                            if (_bodyParts.isNotEmpty)
                              TextButton.icon(
                                onPressed: () => _onCreateExercise(
                                  _selectedBodyPart ?? _bodyParts.first,
                                ),
                                icon: const Icon(
                                  LucideIcons.plus,
                                  size: 16,
                                  color: AppColors.brandGreen,
                                ),
                                label: Text(
                                  'Add',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.brandGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_selectedCategory == null)
                          const _EmptyStateMessage(
                            message: 'Add a category to start building your workout plan.',
                          )
                        else if (_bodyParts.isEmpty)
                          _EmptyStateMessage(
                            message: 'Add body parts like Shoulder, Chest, or Triceps.',
                            actionLabel: 'Add Body Part',
                            onAction: _onCreateBodyPart,
                          )
                        else if (_visibleExercises.isEmpty)
                          _EmptyStateMessage(
                            message: 'No exercises yet for the selected body part.',
                            actionLabel: 'Add Exercise',
                            onAction: () => _onCreateExercise(
                              _selectedBodyPart ?? _bodyParts.first,
                            ),
                          )
                        else
                          ..._visibleExercises.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _ExerciseRow(
                                item: item,
                                tracking: _trackingByExerciseId[item.exercise.exerciseId],
                                isSelected: _selectedExerciseIds.contains(item.exercise.exerciseId),
                                onTap: () => _onTrackExercise(item),
                                onToggleSelect: () => _onToggleSelect(item),
                              ),
                            ),
                          ),
                        if (_visibleExercises.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _MarkCompletedButton(
                            isLoading: _isSubmitting,
                            selectedCount: _selectedExerciseIds.length,
                            onPressed: _selectedExerciseIds.isEmpty
                                ? null
                                : _onMarkSelectedCompleted,
                          ),
                        ],
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _WeekDateRow extends StatelessWidget {
  const _WeekDateRow({required this.now});

  final DateTime now;

  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(7, (index) => monday.add(Duration(days: index)));

    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final date = days[index];
          final isToday = _isSameDay(date, now);
          return _DayCard(
            label: _labels[index],
            dayNumber: '${date.day}',
            isSelected: isToday,
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.label,
    required this.dayNumber,
    required this.isSelected,
  });

  final String label;
  final String dayNumber;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? AppColors.brandGreen : Colors.white38,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isSelected ? 48 : 40,
          height: isSelected ? 56 : 52,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandGreen : const Color(0xFF515151),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppColors.brandGreen.withValues(alpha: 0.8)
                  : Colors.transparent,
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
              dayNumber,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: isSelected ? 24 : 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddCategoryCard extends StatelessWidget {
  const _AddCategoryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.brandGreen.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                LucideIcons.plus,
                color: AppColors.brandGreen.withValues(alpha: 0.9),
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                'Add Category',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Create your first workout category to get started.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<WorkoutCategoryModel> categories;
  final WorkoutCategoryModel? selected;
  final ValueChanged<WorkoutCategoryModel> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final category = categories[index];
          final isActive = category.categoryId == selected?.categoryId;
          return ChoiceChip(
            label: Text(category.name),
            selected: isActive,
            onSelected: (_) => onSelected(category),
            labelStyle: GoogleFonts.poppins(
              color: isActive ? Colors.black : Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            selectedColor: AppColors.brandGreen,
            backgroundColor: const Color(0xFF3A3A3A),
            side: BorderSide(
              color: isActive
                  ? AppColors.brandGreen
                  : Colors.white.withValues(alpha: 0.08),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryFocusCard extends StatelessWidget {
  const _CategoryFocusCard({
    required this.category,
    required this.bodyPartNames,
    required this.progress,
    required this.progressLabel,
    required this.onAddBodyPart,
  });

  final WorkoutCategoryModel category;
  final List<String> bodyPartNames;
  final double progress;
  final String progressLabel;
  final VoidCallback onAddBodyPart;

  @override
  Widget build(BuildContext context) {
    final subtitle = bodyPartNames.isEmpty
        ? 'Add body parts to this category'
        : bodyPartNames.join(' • ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 16),
      decoration: BoxDecoration(
        color: AppColors.navBarSurface,
        borderRadius: BorderRadius.circular(12),
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
                      'CURRENT FOCUS',
                      style: GoogleFonts.poppins(
                        color: AppColors.activeBadgeGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (category.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        category.description,
                        style: GoogleFonts.poppins(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.dumbbell,
                color: AppColors.brandGreen.withValues(alpha: 0.25),
                size: 42,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Progress',
                style: GoogleFonts.poppins(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                progressLabel,
                style: GoogleFonts.poppins(
                  color: AppColors.activeBadgeGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 6,
              backgroundColor: Colors.black,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.activeBadgeGreen,
              ),
            ),
          ),
          if (bodyPartNames.isEmpty) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onAddBodyPart,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Add Body Part'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.brandGreen,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BodyPartStrip extends StatelessWidget {
  const _BodyPartStrip({
    required this.bodyParts,
    required this.selected,
    required this.onSelected,
    required this.onAdd,
  });

  final List<WorkoutBodyPartModel> bodyParts;
  final WorkoutBodyPartModel? selected;
  final ValueChanged<WorkoutBodyPartModel> onSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    if (bodyParts.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: bodyParts.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          if (index == bodyParts.length) {
            return ActionChip(
              avatar: const Icon(LucideIcons.plus, size: 16, color: AppColors.brandGreen),
              label: Text(
                'Add',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              onPressed: onAdd,
              backgroundColor: const Color(0xFF3A3A3A),
              side: BorderSide(color: AppColors.brandGreen.withValues(alpha: 0.4)),
              labelStyle: GoogleFonts.poppins(color: AppColors.brandGreen),
            );
          }

          final part = bodyParts[index];
          final isActive = selected?.bodyPartId == part.bodyPartId;
          return FilterChip(
            label: Text(part.name),
            selected: isActive,
            onSelected: (_) => onSelected(part),
            showCheckmark: false,
            labelStyle: GoogleFonts.poppins(
              color: isActive ? Colors.black : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            selectedColor: AppColors.brandGreen,
            backgroundColor: const Color(0xFF4B4B4B),
          );
        },
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.item,
    required this.tracking,
    required this.isSelected,
    required this.onTap,
    required this.onToggleSelect,
  });

  final _ExerciseDisplayItem item;
  final WorkoutTrackingModel? tracking;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggleSelect;

  @override
  Widget build(BuildContext context) {
    final isCompleted = tracking?.isCompleted == true;
    final borderColor = isCompleted
        ? AppColors.activeBadgeGreen
        : (isSelected ? AppColors.brandGreen : AppColors.textMuted);

    return Material(
      color: AppColors.cardSurfaceAlt,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(color: borderColor, width: 4),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF252626),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  LucideIcons.dumbbell,
                  color: AppColors.brandGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.exercise.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.exercise.defaultSets > 0 ? item.exercise.defaultSets : tracking?.setsCompleted ?? 0} Sets • ${tracking?.repsCompleted.isNotEmpty == true ? tracking!.repsCompleted : '${item.exercise.defaultReps > 0 ? item.exercise.defaultReps : 0} Reps'}',
                      style: GoogleFonts.poppins(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      item.bodyPartName,
                      style: GoogleFonts.poppins(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onToggleSelect,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: (isCompleted || isSelected)
                        ? AppColors.brandGreen
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (isCompleted || isSelected)
                          ? AppColors.brandGreen
                          : Colors.white.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: (isCompleted || isSelected)
                      ? const Icon(Icons.check, color: Colors.black, size: 16)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarkCompletedButton extends StatelessWidget {
  const _MarkCompletedButton({
    required this.isLoading,
    required this.selectedCount,
    required this.onPressed,
  });

  final bool isLoading;
  final int selectedCount;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDisabled = isLoading || onPressed == null;
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isDisabled
                ? [const Color(0xFF333333), const Color(0xFF333333)]
                : [AppColors.payButtonStart, AppColors.payButtonEnd],
          ),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: AppColors.activeBadgeGreen.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: isDisabled ? Colors.white30 : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  selectedCount > 0
                      ? 'MARK COMPLETED ($selectedCount)'
                      : 'MARK COMPLETED',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
        ),
      ),
    );
  }
}

class _EmptyStateMessage extends StatelessWidget {
  const _EmptyStateMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: GoogleFonts.poppins(
                  color: AppColors.brandGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WorkoutFormField extends StatelessWidget {
  const _WorkoutFormField({required this.config});

  final _FormFieldConfig config;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          config.label,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: config.controller,
          maxLines: config.maxLines,
          keyboardType: config.keyboardType,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            hintText: config.hint,
            hintStyle: GoogleFonts.poppins(color: AppColors.inputHint),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExerciseDisplayItem {
  const _ExerciseDisplayItem({
    required this.exercise,
    required this.bodyPartName,
  });

  final WorkoutExerciseModel exercise;
  final String bodyPartName;
}

class _FormFieldConfig {
  const _FormFieldConfig({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
}
