import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class CustomInputField extends StatelessWidget {
  const CustomInputField(
      {super.key,
      this.hint,
      this.label,
      required this.textController,
      this.validator,
      this.enabled = true,
      this.readOnly = false,
      required this.onChange,
      this.focusNode,
      this.maxlines = 1,
      this.suffixIcon,
      this.obscureText = false,
      this.onObscurePress,
      this.topPadding = 18,
      this.inputFormatters,
      this.forceDarkMode = false,
      this.textCapitalization = TextCapitalization.sentences,
      this.autofillHints});

  final String? hint;
  final String? label;
  final TextEditingController textController;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool readOnly;
  final Function(String text) onChange;
  final FocusNode? focusNode;
  final int maxlines;
  final Widget? suffixIcon;
  final bool obscureText;
  final Function()? onObscurePress;
  final double topPadding;
  final List<TextInputFormatter>? inputFormatters;
  final bool forceDarkMode;
  final TextCapitalization textCapitalization;
  final List<String>? autofillHints;

  @override
  Widget build(BuildContext context) {

  
    bool isTablet = DeviceService.isTablet;
    TextStyle textStyle = TextStyle(
        fontSize: isTablet ? 16 : 14,
        fontWeight: FontWeight.w500,
        color: forceDarkMode
            ? MyStyles.pupauTheme(false).darkBlue
            : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue);
    return Opacity(
      opacity: enabled || readOnly ? 1 : 0.3,
      child: AbsorbPointer(
        absorbing: !enabled || readOnly,
        child: SizedBox(
          width: isTablet ? DeviceService.width * 0.7 : DeviceService.width,
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Padding(
              padding: const EdgeInsets.only(top: 7.5),
              child: TextFormField(
                  controller: textController,
                  focusNode: focusNode,
                  validator: validator,
                  inputFormatters: inputFormatters,
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  textCapitalization: textCapitalization,
                  maxLines: maxlines,
                  style: textStyle,
                  onChanged: onChange,
                  autofillHints: autofillHints,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    labelText: label,
                    hintText: hint,
                    hintStyle: textStyle.copyWith(
                        inherit: true,
                        color: Get.isDarkMode || forceDarkMode
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.4)),
                    labelStyle: textStyle.copyWith(
                        inherit: true,
                        color: Get.isDarkMode || forceDarkMode
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.black.withValues(alpha: 0.6)),
                    errorStyle: textStyle,
                    errorMaxLines: 3,
                    floatingLabelStyle: textStyle,
                    alignLabelWithHint: maxlines > 1 ? true : false,
                    border: InputBorder.none,
                    focusedErrorBorder: StyleService.focusBorder(),
                    enabledBorder: StyleService.border(),
                    focusedBorder: StyleService.focusBorder(),
                    errorBorder: StyleService.border(),
                    filled: true,
                    fillColor: forceDarkMode
                        ? MyStyles.pupauTheme(false).white
                        : MyStyles.pupauTheme(!Get.isDarkMode).white,
                    contentPadding: const EdgeInsets.all(12),
                    suffixIcon: suffixIcon ??
                        (onObscurePress != null
                            ? IconButton(
                                icon: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Icon(
                                    color: forceDarkMode
                                        ? MyStyles.pupauTheme(false).darkBlue
                                        : MyStyles.pupauTheme(!Get.isDarkMode)
                                            .darkBlue,
                                    obscureText
                                        ? Symbols.visibility
                                        : Symbols.visibility_off,
                                    size: isTablet ? 28 : 24,
                                  ),
                                ),
                                onPressed: onObscurePress,
                              )
                            : null),
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
