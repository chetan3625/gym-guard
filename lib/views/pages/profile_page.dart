import 'package:azanto/controllers/profile_controller.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Obx(() {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 14, 16, 118 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BackChip(onTap: onBack),
            const SizedBox(height: 14),
            Text(
              'Profile',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Manage your personal details',
              style: GoogleFonts.inter(
                color: const Color(0xFFB5B8C0),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            _AvatarCard(controller: controller),
            const SizedBox(height: 14),
            _ProfileFormCard(controller: controller),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF6CE800), Color(0xFF4AAE05)],
                  ),
                ),
                child: TextButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.onSaveProfileTap,
                  child: controller.isSaving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save Profile',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final firstName = controller.firstNameController.text.trim();
    final fallbackInitial =
        firstName.isNotEmpty ? firstName.substring(0, 1).toUpperCase() : 'U';

    Widget avatarChild;

    if (controller.isLoading.value && controller.avatarBytes.value == null) {
      avatarChild = const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.brandGreen,
          ),
        ),
      );
    } else if (controller.avatarBytes.value != null) {
      avatarChild = ClipOval(
        child: Image.memory(
          controller.avatarBytes.value!,
          fit: BoxFit.cover,
          width: 92,
          height: 92,
        ),
      );
    } else if (controller.avatarUrl.value.isNotEmpty) {
      avatarChild = ClipOval(
        child: Image.network(
          controller.avatarUrl.value,
          fit: BoxFit.cover,
          width: 92,
          height: 92,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.brandGreen,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (_, error, stackTrace) =>
              _AvatarFallback(initial: fallbackInitial),
        ),
      );
    } else {
      avatarChild = _AvatarFallback(initial: fallbackInitial);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.brandGreen.withValues(alpha: 0.45),
              ),
            ),
            child: avatarChild,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Photo',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Upload a clear profile image',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFAEB1B9),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: controller.isUploadingAvatar.value
                        ? null
                        : controller.onUploadAvatarTap,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.brandGreen.withValues(alpha: 0.75),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: controller.isUploadingAvatar.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Upload Avatar',
                            style: GoogleFonts.inter(
                              color: AppColors.brandGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF272A30),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.montserrat(
          color: AppColors.brandGreen,
          fontSize: 34,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProfileFormCard extends StatelessWidget {
  const _ProfileFormCard({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: _cardDecoration(),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.brandGreen,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.profileError.value.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A2328),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF8A303A)),
                ),
                child: Text(
                  controller.profileError.value,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFFD3D8),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'First Name',
                    controller: controller.firstNameController,
                    hint: 'Rajesh',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LabeledField(
                    label: 'Last Name',
                    controller: controller.lastNameController,
                    hint: 'Kumar',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _LabeledField(
              label: 'Quote',
              controller: controller.quoteController,
              hint: 'Stay consistent and trust the process.',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _GenderField(controller: controller)),
                const SizedBox(width: 10),
                Expanded(child: _DobField(controller: controller)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'Height',
                    controller: controller.heightController,
                    hint: '170',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LabeledField(
                    label: 'Weight',
                    controller: controller.weightController,
                    hint: '70',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _LabeledField(
              label: 'Phone',
              controller: controller.phoneController,
              hint: '9876543210',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            _LabeledField(
              label: 'Email',
              controller: controller.emailController,
              hint: 'example@mail.com',
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        );
      }),
    );
  }
}

class _GenderField extends StatelessWidget {
  const _GenderField({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFE1E3E8),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF9297A1)),
          ),
          child: Obx(
            () => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedGender.value,
                hint: Text(
                  'Select',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF8E939E),
                    fontSize: 13,
                  ),
                ),
                dropdownColor: const Color(0xFF3A3C40),
                borderRadius: BorderRadius.circular(12),
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFFB4B8C0),
                ),
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                items: const ['male', 'female', 'other']
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value.substring(0, 1).toUpperCase() +
                              value.substring(1),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  controller.selectedGender.value = value;
                  controller.genderController.text = value;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DobField extends StatelessWidget {
  const _DobField({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DOB',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFE1E3E8),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => controller.onSelectDobTap(context),
          child: AbsorbPointer(
            child: TextField(
              controller: controller.dobController,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'YYYY-MM-DD',
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFF8E939E),
                  fontSize: 13,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                suffixIcon: const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Color(0xFFB4B8C0),
                ),
                border: _outlineInputBorder(),
                enabledBorder: _outlineInputBorder(),
                focusedBorder: _outlineInputBorder(
                  color: AppColors.brandGreen.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFE1E3E8),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF8E939E),
              fontSize: 13,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: _outlineInputBorder(),
            enabledBorder: _outlineInputBorder(),
            focusedBorder: _outlineInputBorder(
              color: AppColors.brandGreen.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}

class _BackChip extends StatelessWidget {
  const _BackChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        width: 86,
        decoration: BoxDecoration(
          color: const Color(0xFF3E4045),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF979CA5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chevron_left_rounded,
              size: 18,
              color: Color(0xFFC7CBD2),
            ),
            Text(
              'Back',
              style: GoogleFonts.inter(
                color: const Color(0xFFE4E6EA),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: const Color(0xFF3A3C40),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0xFF787B84)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: 14,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

OutlineInputBorder _outlineInputBorder({
  Color color = const Color(0xFF9297A1),
}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color),
  );
}
