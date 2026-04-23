import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/plan_service.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/models/plan_model.dart';
import 'package:azanto/utils/backend_error_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PlanDetailsPage extends StatefulWidget {
  const PlanDetailsPage({
    super.key,
    required this.planId,
    this.initialTitle,
  });

  final String planId;
  final String? initialTitle;

  @override
  State<PlanDetailsPage> createState() => _PlanDetailsPageState();
}

class _PlanDetailsPageState extends State<PlanDetailsPage> {
  final PlanService _planService = PlanService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Plan? _plan;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _loadPlanDetails();
  }

  Future<void> _loadPlanDetails() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final plan = await _planService.getPlanDetails(planId: widget.planId);
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _syncControllers(plan);
      });
    } on ApiException catch (e) {
      await BackendErrorWidgets.handleApiException(e);
      if (!mounted) return;
      setState(() {
        _error = e.detailMessage;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _syncControllers(Plan plan) {
    _nameController.text = plan.name;
    _descriptionController.text = plan.description;
    _durationController.text = plan.durationDays.toString();
    _priceController.text = plan.price.toString();
    _isActive = plan.isActive;
  }

  Future<Plan?> _updatePlan() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final durationDays = int.tryParse(_durationController.text.trim());
    final basePrice = num.tryParse(_priceController.text.trim());

    if (name.isEmpty ||
        description.isEmpty ||
        durationDays == null ||
        basePrice == null) {
      Get.snackbar(
        'Missing info',
        'Enter valid name, description, duration and base price.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    setState(() {
      _saving = true;
    });

    try {
      final updatedPlan = await _planService.updatePlan(
        planId: widget.planId,
        name: name,
        description: description,
        durationDays: durationDays,
        basePrice: basePrice,
        isActive: _isActive,
      );
      if (!mounted) return null;
      setState(() {
        _plan = updatedPlan;
        _syncControllers(updatedPlan);
      });
      Get.snackbar(
        'Plan updated',
        'Plan details were saved successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return updatedPlan;
    } on ApiException catch (e) {
      await BackendErrorWidgets.handleApiException(e);
      if (!mounted) return null;
      Get.snackbar(
        'Update failed',
        e.detailMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } catch (e) {
      if (!mounted) return null;
      Get.snackbar(
        'Update failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back<void>(),
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        title: Text(
          widget.initialTitle?.trim().isNotEmpty == true
              ? widget.initialTitle!
              : 'Plan Details',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _PlanDetailsErrorState(
                  error: _error!,
                  onRetryTap: _loadPlanDetails,
                )
              : plan == null
                  ? _PlanDetailsErrorState(
                      error: 'Plan details not found.',
                      onRetryTap: _loadPlanDetails,
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PlanSummaryCard(plan: plan),
                          const SizedBox(height: 16),
                          _PlanSection(
                            title: 'Update Plan',
                            child: Column(
                              children: [
                                _PlanInputField(
                                  label: 'Name',
                                  controller: _nameController,
                                ),
                                const SizedBox(height: 14),
                                _PlanInputField(
                                  label: 'Description',
                                  controller: _descriptionController,
                                  maxLines: 4,
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _PlanInputField(
                                        label: 'Duration (days)',
                                        controller: _durationController,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _PlanInputField(
                                        label: 'Base Price',
                                        controller: _priceController,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Active',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Switch(
                                      value: _isActive,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: AppColors.brandGreen,
                                      onChanged: (value) {
                                        setState(() {
                                          _isActive = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _InfoRow(label: 'Plan ID', value: plan.id),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _saving
                                        ? null
                                        : () async {
                                            final updatedPlan =
                                                await _updatePlan();
                                            if (!mounted ||
                                                updatedPlan == null) {
                                              return;
                                            }
                                            Get.back(result: updatedPlan);
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.brandGreen,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: _saving
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.black,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            'Update Plan',
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}

class _PlanSummaryCard extends StatelessWidget {
  const _PlanSummaryCard({required this.plan});

  final Plan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1E28), Color(0xFF101216)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: plan.isActive
                  ? AppColors.brandGreen.withValues(alpha: 0.16)
                  : Colors.orangeAccent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              plan.isActive ? 'ACTIVE PLAN' : 'INACTIVE PLAN',
              style: GoogleFonts.poppins(
                color:
                    plan.isActive ? AppColors.brandGreen : Colors.orangeAccent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            plan.name.isEmpty ? 'Untitled Plan' : plan.name,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Rs ${plan.price.toStringAsFixed(plan.price is int ? 0 : 2)}',
            style: GoogleFonts.poppins(
              color: AppColors.brandGreen,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${plan.durationDays} days membership plan',
            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanSection extends StatelessWidget {
  const _PlanSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171A20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanInputField extends StatelessWidget {
  const _PlanInputField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: AppColors.brandGreen),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanDetailsErrorState extends StatelessWidget {
  const _PlanDetailsErrorState({
    required this.error,
    required this.onRetryTap,
  });

  final String error;
  final VoidCallback onRetryTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1E24),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: Colors.white70,
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                'Unable to load plan details',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onRetryTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.brandGreen),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
