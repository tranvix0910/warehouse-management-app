import 'package:flutter/material.dart';

enum ConfirmationLevel {
  normal,
  important,
  critical,
}

class ConfirmationService {
  static Future<bool> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    ConfirmationLevel level = ConfirmationLevel.normal,
    IconData? icon,
    bool requireTyping = false,
    String? typeToConfirmText,
  }) async {
    Color levelColor;
    IconData levelIcon;
    
    switch (level) {
      case ConfirmationLevel.critical:
        levelColor = const Color(0xFFEF4444);
        levelIcon = Icons.warning_amber_rounded;
        break;
      case ConfirmationLevel.important:
        levelColor = const Color(0xFFF59E0B);
        levelIcon = Icons.info_outline;
        break;
      case ConfirmationLevel.normal:
      default:
        levelColor = const Color(0xFF3B82F6);
        levelIcon = Icons.help_outline;
    }

    if (requireTyping && typeToConfirmText != null) {
      return await _showTypingConfirmation(
        context: context,
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        levelColor: levelColor,
        icon: icon ?? levelIcon,
        typeToConfirmText: typeToConfirmText,
      );
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: levelColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon ?? levelIcon, color: levelColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            if (level == ConfirmationLevel.critical) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: levelColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: levelColor, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'This action cannot be undone',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: levelColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(confirmText, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  static Future<bool> _showTypingConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    required Color levelColor,
    required IconData icon,
    required String typeToConfirmText,
  }) async {
    final textController = TextEditingController();
    bool isValid = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: levelColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: levelColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type "$typeToConfirmText" to confirm:',
                      style: TextStyle(
                        color: levelColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: textController,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          isValid = value == typeToConfirmText;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: typeToConfirmText,
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                cancelText,
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
            ElevatedButton(
              onPressed: isValid ? () => Navigator.pop(context, true) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: levelColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: levelColor.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(confirmText, style: const TextStyle(fontSize: 15)),
            ),
          ],
        ),
      ),
    );

    return result ?? false;
  }

  static Future<bool> confirmDelete({
    required BuildContext context,
    required String itemName,
    String? itemType,
    bool requireTyping = false,
  }) async {
    return showConfirmation(
      context: context,
      title: 'Delete ${itemType ?? 'Item'}',
      message: 'Are you sure you want to delete "$itemName"?',
      confirmText: 'Delete',
      level: ConfirmationLevel.critical,
      icon: Icons.delete_forever,
      requireTyping: requireTyping,
      typeToConfirmText: requireTyping ? 'DELETE' : null,
    );
  }

  static Future<bool> confirmBulkDelete({
    required BuildContext context,
    required int count,
    String? itemType,
  }) async {
    return showConfirmation(
      context: context,
      title: 'Delete $count ${itemType ?? 'Items'}',
      message: 'Are you sure you want to delete $count ${itemType?.toLowerCase() ?? 'items'}? This action cannot be undone.',
      confirmText: 'Delete All',
      level: ConfirmationLevel.critical,
      icon: Icons.delete_sweep,
      requireTyping: true,
      typeToConfirmText: 'DELETE ALL',
    );
  }

  static Future<bool> confirmLargeTransaction({
    required BuildContext context,
    required String type,
    required int quantity,
    required String partyName,
  }) async {
    final isStockOut = type == 'stock_out';
    
    return showConfirmation(
      context: context,
      title: 'Confirm Large ${isStockOut ? 'Stock Out' : 'Stock In'}',
      message: 'You are about to ${isStockOut ? 'ship' : 'receive'} $quantity items ${isStockOut ? 'to' : 'from'} $partyName. Do you want to proceed?',
      confirmText: 'Confirm Transaction',
      level: ConfirmationLevel.important,
      icon: isStockOut ? Icons.outbox : Icons.inbox,
    );
  }

  static Future<bool> confirmLogout(BuildContext context) async {
    return showConfirmation(
      context: context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out of your account?',
      confirmText: 'Sign Out',
      level: ConfirmationLevel.normal,
      icon: Icons.logout,
    );
  }

  static Future<bool> confirmDataClear(BuildContext context) async {
    return showConfirmation(
      context: context,
      title: 'Clear All Data',
      message: 'This will delete all local data including cached products, transactions, and settings.',
      confirmText: 'Clear Data',
      level: ConfirmationLevel.critical,
      icon: Icons.cleaning_services,
      requireTyping: true,
      typeToConfirmText: 'CLEAR ALL',
    );
  }

  static Future<bool> confirmAccountDelete(BuildContext context) async {
    return showConfirmation(
      context: context,
      title: 'Delete Account',
      message: 'This will permanently delete your account and all associated data. This action cannot be reversed.',
      confirmText: 'Delete Account',
      level: ConfirmationLevel.critical,
      icon: Icons.person_remove,
      requireTyping: true,
      typeToConfirmText: 'DELETE MY ACCOUNT',
    );
  }
}

class ConfirmationButton extends StatelessWidget {
  final String text;
  final VoidCallback onConfirmed;
  final String confirmTitle;
  final String confirmMessage;
  final ConfirmationLevel level;
  final ButtonStyle? style;
  final Widget? icon;
  final bool requireTyping;
  final String? typeToConfirmText;

  const ConfirmationButton({
    super.key,
    required this.text,
    required this.onConfirmed,
    required this.confirmTitle,
    required this.confirmMessage,
    this.level = ConfirmationLevel.normal,
    this.style,
    this.icon,
    this.requireTyping = false,
    this.typeToConfirmText,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final confirmed = await ConfirmationService.showConfirmation(
          context: context,
          title: confirmTitle,
          message: confirmMessage,
          level: level,
          requireTyping: requireTyping,
          typeToConfirmText: typeToConfirmText,
        );
        
        if (confirmed) {
          onConfirmed();
        }
      },
      icon: icon ?? const SizedBox.shrink(),
      label: Text(text),
      style: style,
    );
  }
}
