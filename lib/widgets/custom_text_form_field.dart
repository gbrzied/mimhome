import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_export.dart';

/// Custom text form field widget with consistent styling and responsive design
/// Supports various input types, validation, and theming
class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    Key? key,
    this.alignment,
    this.width,
    this.scrollPadding,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.textStyle,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.textInputType = TextInputType.text,
    this.maxLines,
    this.maxLength,
    this.hintText,
    this.hintStyle,
    this.prefix,
    this.prefixConstraints,
    this.suffix,
    this.suffixConstraints,
    this.contentPadding,
    this.borderDecoration,
    this.fillColor,
    this.filled = true,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.autovalidateMode,
    this.enabled = true,
    this.readOnly = false,
    this.labelText,
    this.labelStyle,
    this.errorStyle,
    this.floatingLabelStyle,
    this.helperText,
    this.helperStyle,
    this.errorText,
    this.onTap,
  }) : super(key: key);

  /// How the text field should be aligned horizontally
  final Alignment? alignment;

  /// The width of the text field
  final double? width;

  /// Configures padding to edges
  final EdgeInsets? scrollPadding;

  /// Controls the text being edited
  final TextEditingController? controller;

  /// Defines the keyboard focus for this widget
  final FocusNode? focusNode;

  /// Whether this text field should focus itself if nothing else is already focused
  final bool? autofocus;

  /// The style to use for the text being edited
  final TextStyle? textStyle;

  /// Whether to hide the text being edited (e.g., for passwords)
  final bool? obscureText;

  /// The type of action button to use for the keyboard
  final TextInputAction? textInputAction;

  /// The type of keyboard to use for editing the text
  final TextInputType? textInputType;

  /// The maximum number of lines to show at one time, wrapping if necessary
  final int? maxLines;

  /// The maximum number of characters to allow in the text field
  final int? maxLength;

  /// Text that suggests what sort of input the field accepts
  final String? hintText;

  /// The style to use for the hint text
  final TextStyle? hintStyle;

  /// Optional widget to place on the line before the input
  final Widget? prefix;

  /// Optional size constraints for the prefix widget
  final BoxConstraints? prefixConstraints;

  /// Optional widget to place on the line after the input
  final Widget? suffix;

  /// Optional size constraints for the suffix widget
  final BoxConstraints? suffixConstraints;

  /// The padding for the input decoration's container
  final EdgeInsetsGeometry? contentPadding;

  /// The shape of the border to draw around the decoration's container
  final InputBorder? borderDecoration;

  /// The color to fill the decoration's container with
  final Color? fillColor;

  /// Whether the decoration's container will be filled
  final bool? filled;

  /// An optional method that validates an input
  final FormFieldValidator<String>? validator;

  /// Called when the user initiates a change to the TextField's value
  final ValueChanged<String>? onChanged;

  /// Optional input validation and formatting overrides
  final List<TextInputFormatter>? inputFormatters;

  /// When to validate the input
  final AutovalidateMode? autovalidateMode;

  /// Whether the text field is enabled
  final bool? enabled;

  /// Whether the text field is read-only
  final bool? readOnly;

  /// Optional text that describes the input field
  final String? labelText;

  /// The style to use for the label text
  final TextStyle? labelStyle;

  /// The style to use for the error text
  final TextStyle? errorStyle;

  /// The style to use for the floating label text
  final TextStyle? floatingLabelStyle;

  /// Text that provides context about the field's value
  final String? helperText;

  /// The style to use for the helper text
  final TextStyle? helperStyle;

  /// Text that appears below the field when there's an error
  final String? errorText;

  /// Called when the field is tapped
  final VoidCallback? onTap;



  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: _buildTextFormFieldWidget(),
          )
        : _buildTextFormFieldWidget();
  }

  Widget _buildTextFormFieldWidget() {
    return SizedBox(
      width: width ?? double.maxFinite,
      child: Builder(
        builder: (context) => TextFormField(
        scrollPadding: scrollPadding ??
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        controller: controller,
        focusNode: focusNode,
        onTapOutside: (event) {
          if (focusNode != null) {
            focusNode?.unfocus();
          } else {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        autofocus: autofocus ?? false,
        style: textStyle ??
            TextStyleHelper.instance.body14RegularSyne.copyWith(
              color: appTheme.black_900,
              fontSize: 14.fSize,
            ),
        obscureText: obscureText ?? false,
        textInputAction: textInputAction,
        keyboardType: textInputType,
        maxLines: maxLines ?? 1,
        maxLength: maxLength,
        decoration: _buildDecoration(),
        validator: validator,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        autovalidateMode: autovalidateMode,
        onTap: onTap,
        enabled: enabled ?? true,
        readOnly: readOnly ?? false,
        ),
      ),
    );
  }

  InputDecoration _buildDecoration() {
    return InputDecoration(
      hintText: hintText ?? "",
      hintStyle: hintStyle ??
          TextStyleHelper.instance.body14RegularSyne.copyWith(
            color: appTheme.gray_600,
            fontSize: 14.fSize,
          ),
      prefixIcon: prefix,
      prefixIconConstraints: prefixConstraints ??
          BoxConstraints(
            maxHeight: 56.h,
            maxWidth: 56.h,
          ),
      suffixIcon: suffix,
      suffixIconConstraints: suffixConstraints ??
          BoxConstraints(
            maxHeight: 56.h,
            maxWidth: 56.h,
          ),
      isDense: true,
      contentPadding: contentPadding ??
          EdgeInsets.symmetric(
            horizontal: 16.h,
            vertical: 18.h,
          ),
      fillColor: fillColor ?? appTheme.whiteCustom,
      filled: filled,
      border: borderDecoration ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.h),
            borderSide: BorderSide(
              color: appTheme.gray_400,
              width: 1.h,
            ),
          ),
      enabledBorder: borderDecoration ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.h),
            borderSide: BorderSide(
              color: appTheme.gray_400,
              width: 1.h,
            ),
          ),
      focusedBorder: borderDecoration ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.h),
            borderSide: BorderSide(
              color: appTheme.cyan_900,
              width: 1.h,
            ),
          ),
      errorBorder: borderDecoration ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.h),
            borderSide: BorderSide(
              color: appTheme.redCustom,
              width: 1.h,
            ),
          ),
      focusedErrorBorder: borderDecoration ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.h),
            borderSide: BorderSide(
              color: appTheme.redCustom,
              width: 1.h,
            ),
          ),
      labelText: labelText,
      labelStyle: labelStyle ??
          TextStyleHelper.instance.body14RegularSyne.copyWith(
            color: appTheme.gray_600,
            fontSize: 14.fSize,
          ),
      errorStyle: errorStyle ??
          TextStyleHelper.instance.body12RegularManrope.copyWith(
            color: appTheme.redCustom,
            fontSize: 12.fSize,
          ),
      floatingLabelStyle: floatingLabelStyle ??
          TextStyleHelper.instance.body14RegularSyne.copyWith(
            color: appTheme.cyan_900,
            fontSize: 14.fSize,
          ),
      helperText: helperText,
      helperStyle: helperStyle ??
          TextStyleHelper.instance.body12RegularManrope.copyWith(
            color: appTheme.gray_600,
            fontSize: 12.fSize,
          ),
      errorText: errorText,
      counter: SizedBox.shrink(),
    );
  }
}
