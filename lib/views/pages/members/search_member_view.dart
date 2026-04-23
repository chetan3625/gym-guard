
import 'package:azanto/controllers/search_member_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SearchMemberView extends GetView<SearchMemberController> {
  const SearchMemberView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Member')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              TextFormField(
                controller: controller.phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter 10-digit phone number',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                maxLength: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (value.length < 10) {
                    return 'Enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Obx(() {
                return controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: controller.searchMember,
                        child: const Text('Search'),
                      );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
