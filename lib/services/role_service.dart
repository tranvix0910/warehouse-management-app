import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/token_storage.dart';

enum UserRole {
  admin,
  manager,
  staff,
}

class Permission {
  static const String viewProducts = 'view_products';
  static const String createProduct = 'create_product';
  static const String editProduct = 'edit_product';
  static const String deleteProduct = 'delete_product';
  
  static const String viewTransactions = 'view_transactions';
  static const String createTransaction = 'create_transaction';
  static const String editTransaction = 'edit_transaction';
  static const String deleteTransaction = 'delete_transaction';
  
  static const String viewReports = 'view_reports';
  static const String exportReports = 'export_reports';
  static const String viewFinancialReports = 'view_financial_reports';
  
  static const String viewCustomers = 'view_customers';
  static const String manageCustomers = 'manage_customers';
  
  static const String viewSuppliers = 'view_suppliers';
  static const String manageSuppliers = 'manage_suppliers';
  
  static const String manageSettings = 'manage_settings';
  static const String manageTeam = 'manage_team';
  static const String manageUsers = 'manage_users';
  
  static const String bulkDelete = 'bulk_delete';
  static const String bulkExport = 'bulk_export';
}

class RoleService {
  static final RoleService _instance = RoleService._internal();
  factory RoleService() => _instance;
  RoleService._internal();

  UserRole _currentRole = UserRole.staff;
  
  UserRole get currentRole => _currentRole;

  static const Map<UserRole, List<String>> _rolePermissions = {
    UserRole.admin: [
      Permission.viewProducts,
      Permission.createProduct,
      Permission.editProduct,
      Permission.deleteProduct,
      Permission.viewTransactions,
      Permission.createTransaction,
      Permission.editTransaction,
      Permission.deleteTransaction,
      Permission.viewReports,
      Permission.exportReports,
      Permission.viewFinancialReports,
      Permission.viewCustomers,
      Permission.manageCustomers,
      Permission.viewSuppliers,
      Permission.manageSuppliers,
      Permission.manageSettings,
      Permission.manageTeam,
      Permission.manageUsers,
      Permission.bulkDelete,
      Permission.bulkExport,
    ],
    UserRole.manager: [
      Permission.viewProducts,
      Permission.createProduct,
      Permission.editProduct,
      Permission.viewTransactions,
      Permission.createTransaction,
      Permission.editTransaction,
      Permission.viewReports,
      Permission.exportReports,
      Permission.viewFinancialReports,
      Permission.viewCustomers,
      Permission.manageCustomers,
      Permission.viewSuppliers,
      Permission.manageSuppliers,
      Permission.manageSettings,
      Permission.bulkExport,
    ],
    UserRole.staff: [
      Permission.viewProducts,
      Permission.createProduct,
      Permission.viewTransactions,
      Permission.createTransaction,
      Permission.viewReports,
      Permission.viewCustomers,
      Permission.viewSuppliers,
    ],
  };

  static const Map<UserRole, String> roleNames = {
    UserRole.admin: 'Administrator',
    UserRole.manager: 'Manager',
    UserRole.staff: 'Staff',
  };

  static const Map<UserRole, String> roleDescriptions = {
    UserRole.admin: 'Full access to all features including user management',
    UserRole.manager: 'Can manage inventory, transactions, and view reports',
    UserRole.staff: 'Can view and create basic inventory items and transactions',
  };

  static const Map<UserRole, Color> roleColors = {
    UserRole.admin: Color(0xFFEF4444),
    UserRole.manager: Color(0xFF3B82F6),
    UserRole.staff: Color(0xFF10B981),
  };

  static const Map<UserRole, IconData> roleIcons = {
    UserRole.admin: Icons.admin_panel_settings,
    UserRole.manager: Icons.manage_accounts,
    UserRole.staff: Icons.person,
  };

  Future<void> loadUserRole() async {
    final user = await TokenStorage.getUser();
    if (user != null && user['role'] != null) {
      _currentRole = _parseRole(user['role']);
    }
    
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString('user_role');
    if (savedRole != null) {
      _currentRole = _parseRole(savedRole);
    }
  }

  Future<void> setUserRole(UserRole role) async {
    _currentRole = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role.name);
  }

  UserRole _parseRole(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      case 'staff':
      default:
        return UserRole.staff;
    }
  }

  bool hasPermission(String permission) {
    final permissions = _rolePermissions[_currentRole] ?? [];
    return permissions.contains(permission);
  }

  bool canDeleteProduct() => hasPermission(Permission.deleteProduct);
  bool canEditProduct() => hasPermission(Permission.editProduct);
  bool canDeleteTransaction() => hasPermission(Permission.deleteTransaction);
  bool canEditTransaction() => hasPermission(Permission.editTransaction);
  bool canViewFinancialReports() => hasPermission(Permission.viewFinancialReports);
  bool canExportReports() => hasPermission(Permission.exportReports);
  bool canManageUsers() => hasPermission(Permission.manageUsers);
  bool canManageSettings() => hasPermission(Permission.manageSettings);
  bool canBulkDelete() => hasPermission(Permission.bulkDelete);

  List<String> getPermissionsForRole(UserRole role) {
    return _rolePermissions[role] ?? [];
  }

  String getRoleName(UserRole role) => roleNames[role] ?? 'Unknown';
  String getRoleDescription(UserRole role) => roleDescriptions[role] ?? '';
  Color getRoleColor(UserRole role) => roleColors[role] ?? Colors.grey;
  IconData getRoleIcon(UserRole role) => roleIcons[role] ?? Icons.person;
}

class RoleGuard extends StatelessWidget {
  final String permission;
  final Widget child;
  final Widget? fallback;
  final bool showDisabled;

  const RoleGuard({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
    this.showDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasPermission = RoleService().hasPermission(permission);
    
    if (hasPermission) {
      return child;
    }
    
    if (fallback != null) {
      return fallback!;
    }
    
    if (showDisabled) {
      return Opacity(
        opacity: 0.5,
        child: IgnorePointer(child: child),
      );
    }
    
    return const SizedBox.shrink();
  }
}

class RoleAwareButton extends StatelessWidget {
  final String permission;
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;
  final String? disabledMessage;

  const RoleAwareButton({
    super.key,
    required this.permission,
    required this.onPressed,
    required this.child,
    this.style,
    this.disabledMessage,
  });

  @override
  Widget build(BuildContext context) {
    final hasPermission = RoleService().hasPermission(permission);
    
    return ElevatedButton(
      onPressed: hasPermission 
          ? onPressed 
          : disabledMessage != null 
              ? () => _showNoPermissionDialog(context)
              : null,
      style: style,
      child: child,
    );
  }

  void _showNoPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.orange),
            SizedBox(width: 12),
            Text('Permission Required', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          disabledMessage ?? 'You do not have permission to perform this action.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
