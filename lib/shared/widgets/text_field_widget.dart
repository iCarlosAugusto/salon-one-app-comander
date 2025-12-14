import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/constants/app_constants.dart';

/// A reusable text field widget with integrated label, validation support,
/// and responsive design for both mobile and desktop platforms.
///
/// This widget wraps `ShadInput` and provides:
/// - Optional label with required indicator
/// - Form validation with error message display
/// - Responsive spacing adjustments
/// - Customizable styling and input behavior
class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({
    super.key,
    this.controller,
    this.label,
    this.placeholder,
    this.errorText,
    this.isRequired = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofocus = false,
    this.focusNode,
    this.validator,
    this.autovalidateMode,
    this.initialValue,
  });

  /// The text editing controller for the input field.
  final TextEditingController? controller;

  /// Optional label displayed above the input field.
  /// When null, no label is shown.
  final String? label;

  /// Placeholder text displayed when the input is empty.
  final String? placeholder;

  /// Error message to display below the input.
  /// When not null, the field shows an error state.
  final String? errorText;

  /// Whether the field is required.
  /// When true, displays a red asterisk next to the label.
  final bool isRequired;

  /// The type of keyboard to use for editing the text.
  final TextInputType? keyboardType;

  /// The action button to use for the keyboard.
  final TextInputAction? textInputAction;

  /// Optional input formatters to restrict or format input.
  final List<TextInputFormatter>? inputFormatters;

  /// Called when the text value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the text.
  final ValueChanged<String>? onSubmitted;

  /// Whether to hide the text being edited.
  final bool obscureText;

  /// Whether the text field is enabled for editing.
  final bool enabled;

  /// Whether the text field is read-only.
  final bool readOnly;

  /// The maximum number of lines for the text field.
  final int maxLines;

  /// The minimum number of lines for the text field.
  final int? minLines;

  /// The maximum length of the text.
  final int? maxLength;

  /// Whether the text field should focus automatically.
  final bool autofocus;

  /// An optional focus node to use.
  final FocusNode? focusNode;

  /// Optional validator function for form validation.
  final FormFieldValidator<String>? validator;

  /// When to validate the form field automatically.
  final AutovalidateMode? autovalidateMode;

  /// The initial value for the text field.
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    // If validator is provided, wrap in FormField for form integration
    if (validator != null) {
      return FormField<String>(
        validator: validator,
        initialValue: controller?.text ?? initialValue ?? '',
        autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
        builder: (FormFieldState<String> field) {
          // Combine external error with form validation error
          final displayError = errorText ?? field.errorText;

          return _buildFieldContent(
            context,
            displayError,
            onFieldChanged: (value) {
              field.didChange(value);
              onChanged?.call(value);
            },
          );
        },
      );
    }

    // Without validator, just build the content directly
    return _buildFieldContent(context, errorText);
  }

  /// Builds the complete field content with label, input, and error.
  Widget _buildFieldContent(
    BuildContext context,
    String? displayError, {
    ValueChanged<String>? onFieldChanged,
  }) {
    final theme = ShadTheme.of(context);
    final isDesktop =
        MediaQuery.of(context).size.width > AppConstants.mobileBreakpoint;
    final hasError = displayError != null && displayError.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label section
        if (label != null) ...[
          _buildLabel(context),
          SizedBox(
            height: isDesktop ? AppConstants.spacingSm : AppConstants.spacingXs,
          ),
        ],

        // Input field
        _buildInput(context, hasError, onFieldChanged),

        // Error message
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            displayError,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.destructive,
            ),
          ),
        ],
      ],
    );
  }

  /// Builds the label row with optional required indicator.
  Widget _buildLabel(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Row(
      children: [
        Text(
          label!,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.foreground,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: TextStyle(
              color: theme.colorScheme.destructive,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  /// Builds the ShadInput widget with all configurations.
  Widget _buildInput(
    BuildContext context,
    bool hasError,
    ValueChanged<String>? onFieldChanged,
  ) {
    final theme = ShadTheme.of(context);

    return ShadInput(
      controller: controller,
      placeholder: placeholder != null ? Text(placeholder!) : null,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onFieldChanged ?? onChanged,
      onSubmitted: onSubmitted,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      focusNode: focusNode,
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: minLines,
      initialValue: initialValue,
      decoration: ShadDecoration(
        border: ShadBorder.all(
          color: hasError ? theme.colorScheme.destructive : null,
          width: hasError ? 1.5 : null,
        ),
      ),
    );
  }
}

/// Extension to simplify creating common text field variants.
extension TextFieldWidgetVariants on TextFieldWidget {
  /// Creates an email text field with appropriate keyboard type.
  static TextFieldWidget email({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? placeholder,
    String? errorText,
    bool isRequired = false,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool enabled = true,
    bool autofocus = false,
    FocusNode? focusNode,
  }) {
    return TextFieldWidget(
      key: key,
      controller: controller,
      label: label,
      placeholder: placeholder ?? 'Enter email address',
      errorText: errorText,
      isRequired: isRequired,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      autofocus: autofocus,
      focusNode: focusNode,
    );
  }

  /// Creates a phone text field with appropriate keyboard type.
  static TextFieldWidget phone({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? placeholder,
    String? errorText,
    bool isRequired = false,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool enabled = true,
    bool autofocus = false,
    FocusNode? focusNode,
  }) {
    return TextFieldWidget(
      key: key,
      controller: controller,
      label: label,
      placeholder: placeholder ?? 'Enter phone number',
      errorText: errorText,
      isRequired: isRequired,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      autofocus: autofocus,
      focusNode: focusNode,
    );
  }

  /// Creates a password text field with obscured text.
  static TextFieldWidget password({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? placeholder,
    String? errorText,
    bool isRequired = false,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool enabled = true,
    bool autofocus = false,
    FocusNode? focusNode,
  }) {
    return TextFieldWidget(
      key: key,
      controller: controller,
      label: label,
      placeholder: placeholder ?? 'Enter password',
      errorText: errorText,
      isRequired: isRequired,
      obscureText: true,
      textInputAction: TextInputAction.done,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      autofocus: autofocus,
      focusNode: focusNode,
    );
  }

  /// Creates a multiline text area.
  static TextFieldWidget textArea({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? placeholder,
    String? errorText,
    bool isRequired = false,
    ValueChanged<String>? onChanged,
    bool enabled = true,
    bool autofocus = false,
    FocusNode? focusNode,
    int maxLines = 4,
    int? minLines,
    int? maxLength,
  }) {
    return TextFieldWidget(
      key: key,
      controller: controller,
      label: label,
      placeholder: placeholder,
      errorText: errorText,
      isRequired: isRequired,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      onChanged: onChanged,
      enabled: enabled,
      autofocus: autofocus,
      focusNode: focusNode,
      maxLines: maxLines,
      minLines: minLines ?? 3,
      maxLength: maxLength,
    );
  }
}
