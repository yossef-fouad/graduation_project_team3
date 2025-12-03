import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerPhoneController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  var isLoading = false.obs;

  Future<void> submit(Function(String) onSubmit) async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        await onSubmit(phoneController.text.trim());
      } catch (e) {
        // Error is typically handled by the callback, but we ensure loading is reset
        rethrow;
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
