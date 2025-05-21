import 'package:flutter/material.dart';

/// Helper class to fix layout overflow issues throughout the app
class LayoutHelpers {
  /// Wraps a column in a scrollable container if needed
  /// This prevents the RenderFlex overflow errors we're seeing in the logs
  static Widget safeColumn({
    required List<Widget> children,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    bool makeScrollable = true,
  }) {
    final column = Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
    
    // If not scrollable, just return the column
    if (!makeScrollable) {
      return column;
    }
    
    // Make it scrollable to prevent overflow
    return SingleChildScrollView(
      child: column,
    );
  }
  
  /// A version of Expanded that won't cause overflow issues
  static Widget safeExpanded({
    required Widget child,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: child,
    );
  }
  
  /// Makes sure text won't overflow its container
  static Widget safeText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    int? maxLines,
  }) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}