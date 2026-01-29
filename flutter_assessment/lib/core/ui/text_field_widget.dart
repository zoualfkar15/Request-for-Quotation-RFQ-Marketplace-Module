import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled,
    this.onTap,
    this.textAlignVertical,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.onChanged,
    this.suffixIcon,
    this.prefixIcon,
    this.textFieldKey,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.hintStyle,
    this.inputBorder,
    this.focusedBorder,
    this.enabledBorder,
    this.disabledBorder,
    this.contentPadding,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final bool readOnly;
  final bool? enabled;
  final GestureTapCallback? onTap;
  final TextAlignVertical? textAlignVertical;
  final int? maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Key? textFieldKey;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final TextStyle? hintStyle;
  final InputBorder? inputBorder;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final InputBorder? disabledBorder;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: textFieldKey,
      controller: controller,
      keyboardType: keyboardType,
      textAlign: textAlign,
      textDirection: textDirection,
      textAlignVertical: textAlignVertical,
      inputFormatters: inputFormatters,
      maxLines: obscureText ? 1 : maxLines,
      minLines: obscureText ? 1 : minLines,
      enabled: enabled,
      onTap: onTap,
      readOnly: readOnly,
      obscureText: obscureText,
      onChanged: onChanged,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      onEditingComplete: () => FocusScope.of(context).unfocus(),
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: hintStyle,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        errorMaxLines: 3,
        contentPadding: contentPadding,
        border: inputBorder,
        focusedBorder: focusedBorder,
        enabledBorder: enabledBorder,
        disabledBorder: disabledBorder,
      ),
    );
  }
}


