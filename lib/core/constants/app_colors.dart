import 'package:flutter/material.dart';

/// App color palette following shadcn design principles
class AppColors {
  AppColors._();

  // Primary colors (Amber/Gold theme for barbershop)
  static const Color primary = Color(0xFFD97706);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  // Secondary colors
  static const Color secondary = Color(0xFF1E293B);
  static const Color secondaryForeground = Color(0xFFF8FAFC);

  // Accent colors
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentForeground = Color(0xFF1E293B);

  // Background colors
  static const Color background = Color(0xFF0F172A);
  static const Color foreground = Color(0xFFF8FAFC);

  // Card colors
  static const Color card = Color(0xFF1E293B);
  static const Color cardForeground = Color(0xFFF8FAFC);

  // Muted colors
  static const Color muted = Color(0xFF334155);
  static const Color mutedForeground = Color(0xFF94A3B8);

  // Border colors
  static const Color border = Color(0xFF334155);
  static const Color input = Color(0xFF334155);
  static const Color ring = Color(0xFFD97706);

  // Status colors
  static const Color success = Color(0xFF22C55E);
  static const Color successForeground = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningForeground = Color(0xFF1E293B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorForeground = Color(0xFFFFFFFF);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoForeground = Color(0xFFFFFFFF);

  // Appointment status colors
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusConfirmed = Color(0xFF3B82F6);
  static const Color statusInProgress = Color(0xFF8B5CF6);
  static const Color statusCompleted = Color(0xFF22C55E);
  static const Color statusCancelled = Color(0xFFEF4444);
  static const Color statusNoShow = Color(0xFF6B7280);

  // Light theme colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightForeground = Color(0xFF0F172A);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardForeground = Color(0xFF0F172A);
  static const Color lightMuted = Color(0xFFF1F5F9);
  static const Color lightMutedForeground = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);
}
