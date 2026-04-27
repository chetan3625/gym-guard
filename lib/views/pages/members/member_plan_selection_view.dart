
import 'package:azanto/controllers/member_plan_selection_controller.dart';
import 'package:azanto/utils/member_search_mapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberPlanSelectionView extends GetView<MemberPlanSelectionController> {
  const MemberPlanSelectionView({super.key});

  String _getMemberName() {
    return MemberSearchMapper.resolveMemberName(controller.searchedUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select a Plan for ${_getMemberName()}')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.plans.isEmpty) {
          return const Center(child: Text('No plans available.'));
        }
        return ListView.builder(
          itemCount: controller.plans.length,
          itemBuilder: (context, index) {
            final plan = controller.plans[index];
            return ListTile(
              title: Text(plan.name),
              subtitle: Text('\$${plan.price.toStringAsFixed(2)} for ${plan.durationDays} days'),
              onTap: () => controller.onPlanSelected(plan),
            );
          },
        );
      }),
    );
  }
}
