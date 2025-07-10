import 'package:flutter/material.dart';
import 'package:simple_crm_flutter/core/theme/app_colors.dart';
import 'package:simple_crm_flutter/core/theme/app_text_styles.dart';

/// Custom text field widget with consistent styling
class CustomTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final VoidCallback? onTap;
  final bool readOnly;
  final String? initialValue;
  final Function(String)? onChanged;
  
  const CustomTextField({
    Key? key,
    required this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.onTap,
    this.readOnly = false,
    this.initialValue,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          onTap: onTap,
          readOnly: readOnly,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            filled: true,
            fillColor: enabled ? AppColors.surfaceVariant : AppColors.divider,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom dropdown field widget
class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String? Function(T?)? validator;
  final Function(T?)? onChanged;
  final String? hintText;
  final bool enabled;
  
  const CustomDropdownField({
    Key? key,
    required this.label,
    this.value,
    required this.items,
    this.validator,
    this.onChanged,
    this.hintText,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          validator: validator,
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            filled: true,
            fillColor: enabled ? AppColors.surfaceVariant : AppColors.divider,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom date picker field
class CustomDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final String? Function(DateTime?)? validator;
  final Function(DateTime?)? onChanged;
  final String? hintText;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;
  
  const CustomDateField({
    Key? key,
    required this.label,
    this.value,
    this.validator,
    this.onChanged,
    this.hintText,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: TextEditingController(
            text: value != null
                ? '${value!.day}/${value!.month}/${value!.year}'
                : '',
          ),
          validator: (val) => validator?.call(value),
          readOnly: true,
          enabled: enabled,
          onTap: enabled ? () => _selectDate(context) : null,
          decoration: InputDecoration(
            hintText: hintText ?? 'Select date',
            suffixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            filled: true,
            fillColor: enabled ? AppColors.surfaceVariant : AppColors.divider,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
    );
    if (picked != null && picked != value) {
      onChanged?.call(picked);
    }
  }
}

/// Custom switch field
class CustomSwitchField extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final Function(bool)? onChanged;
  final bool enabled;
  
  const CustomSwitchField({
    Key? key,
    required this.label,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        label,
        style: AppTextStyles.bodyMedium,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.bodySmall,
            )
          : null,
      value: value,
      onChanged: enabled ? onChanged : null,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }
}