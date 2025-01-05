import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastUtils {
  static void showSuccessToast(
    BuildContext context, {
    required String title,
    String? description,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      description: description != null
          ? Text(
              description,
              style: const TextStyle(fontSize: 14),
            )
          : null,
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: true,
      alignment: Alignment.topCenter,
    );
  }

  static void showErrorToast(
    BuildContext context, {
    required String title,
    String? description,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      description: description != null
          ? Text(
              description,
              style: const TextStyle(fontSize: 14),
            )
          : null,
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: true,
      alignment: Alignment.topCenter,
    );
  }

  static void showWarningToast(
    BuildContext context, {
    required String title,
    String? description,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      description: description != null
          ? Text(
              description,
              style: const TextStyle(fontSize: 14),
            )
          : null,
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: true,
      alignment: Alignment.topCenter,
    );
  }
}
