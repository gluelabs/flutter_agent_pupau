import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

/// Represents a selectable item in a context menu.
///
/// This class is used to define individual items that can be displayed within
/// a context menu.
///
/// #### Parameters:
/// - [label] - The title of the context menu item
/// - [icon] - The icon of the context menu item.
/// - [constraints] - The height of the context menu item.
/// - [focusNode] - The focus node of the context menu item.
/// - [value] - The value associated with the context menu item.
/// - [items] - The list of subitems associated with the context menu item.
/// - [onSelected] - The callback that is triggered when the context menu item
///   is selected. If the item has subitems, it toggles the visibility of the
///   submenu. If not, it pops the current context menu and returns the
///   associated value.
/// - [constraints] - The constraints of the context menu item.
///
/// see:
/// - [ContextMenuEntry]
/// - [MenuHeader]
/// - [MenuDivider]
///
final class MyMenuItem<T> extends ContextMenuItem<T> {
  final String label;
  final IconData? icon;
  final BoxConstraints? constraints;
  final bool flipIcon;

  const MyMenuItem({
    required this.label,
    this.icon,
    super.value,
    super.onSelected,
    this.constraints,
    this.flipIcon = false,
  });

  const MyMenuItem.submenu({
    required this.label,
    required List<ContextMenuEntry<T>> items,
    this.icon,
    super.onSelected,
    this.constraints,
    this.flipIcon = false,
  }) : super.submenu(items: items);

  @override
  Widget builder(BuildContext context, ContextMenuState menuState,
      [FocusNode? focusNode]) {
    TextStyle textStyle = TextStyle(
        height: 1.0,
        color: context.theme.textTheme.bodyMedium?.color ?? Colors.white);

    return ConstrainedBox(
      constraints: constraints ?? const BoxConstraints.expand(height: 32.0),
      child: Material(
        borderRadius: BorderRadius.circular(4.0),
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        child: InkWell(
          onTap: () => handleItemSelection(context),
          canRequestFocus: false,
          child: DefaultTextStyle(
            style: textStyle,
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 32.0,
                  child: RotatedBox(
                    quarterTurns: flipIcon ? 2 : 0,
                    child: Icon(
                      icon,
                      size: 16.0,
                      color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 4.0),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue),
                  ),
                ),
                const SizedBox(width: 8.0),
                SizedBox.square(
                  dimension: 32.0,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Icon(isSubmenuItem ? Symbols.arrow_right : null,
                        size: 16.0),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
