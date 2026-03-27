import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_management_app/services/role_service.dart';

void main() {
  group('RoleService', () {
    late RoleService roleService;

    setUp(() {
      roleService = RoleService();
    });

    test('singleton returns same instance', () {
      final instance1 = RoleService();
      final instance2 = RoleService();

      expect(identical(instance1, instance2), true);
    });

    test('default role is staff', () {
      expect(roleService.currentRole, UserRole.staff);
    });

    group('Admin permissions', () {
      setUp(() async {
        await roleService.setUserRole(UserRole.admin);
      });

      test('admin can delete products', () {
        expect(roleService.canDeleteProduct(), true);
      });

      test('admin can edit products', () {
        expect(roleService.canEditProduct(), true);
      });

      test('admin can delete transactions', () {
        expect(roleService.canDeleteTransaction(), true);
      });

      test('admin can view financial reports', () {
        expect(roleService.canViewFinancialReports(), true);
      });

      test('admin can manage users', () {
        expect(roleService.canManageUsers(), true);
      });

      test('admin can bulk delete', () {
        expect(roleService.canBulkDelete(), true);
      });
    });

    group('Manager permissions', () {
      setUp(() async {
        await roleService.setUserRole(UserRole.manager);
      });

      test('manager cannot delete products', () {
        expect(roleService.canDeleteProduct(), false);
      });

      test('manager can edit products', () {
        expect(roleService.canEditProduct(), true);
      });

      test('manager cannot delete transactions', () {
        expect(roleService.canDeleteTransaction(), false);
      });

      test('manager can view financial reports', () {
        expect(roleService.canViewFinancialReports(), true);
      });

      test('manager cannot manage users', () {
        expect(roleService.canManageUsers(), false);
      });

      test('manager cannot bulk delete', () {
        expect(roleService.canBulkDelete(), false);
      });

      test('manager can export reports', () {
        expect(roleService.canExportReports(), true);
      });
    });

    group('Staff permissions', () {
      setUp(() async {
        await roleService.setUserRole(UserRole.staff);
      });

      test('staff cannot delete products', () {
        expect(roleService.canDeleteProduct(), false);
      });

      test('staff cannot edit products', () {
        expect(roleService.canEditProduct(), false);
      });

      test('staff cannot delete transactions', () {
        expect(roleService.canDeleteTransaction(), false);
      });

      test('staff cannot view financial reports', () {
        expect(roleService.canViewFinancialReports(), false);
      });

      test('staff cannot manage users', () {
        expect(roleService.canManageUsers(), false);
      });

      test('staff cannot bulk delete', () {
        expect(roleService.canBulkDelete(), false);
      });

      test('staff cannot export reports', () {
        expect(roleService.canExportReports(), false);
      });

      test('staff has view_products permission', () {
        expect(roleService.hasPermission(Permission.viewProducts), true);
      });

      test('staff has create_product permission', () {
        expect(roleService.hasPermission(Permission.createProduct), true);
      });

      test('staff has view_transactions permission', () {
        expect(roleService.hasPermission(Permission.viewTransactions), true);
      });
    });

    group('Role metadata', () {
      test('getRoleName returns correct name for admin', () {
        expect(roleService.getRoleName(UserRole.admin), 'Administrator');
      });

      test('getRoleName returns correct name for manager', () {
        expect(roleService.getRoleName(UserRole.manager), 'Manager');
      });

      test('getRoleName returns correct name for staff', () {
        expect(roleService.getRoleName(UserRole.staff), 'Staff');
      });

      test('getRoleDescription returns non-empty string', () {
        expect(roleService.getRoleDescription(UserRole.admin).isNotEmpty, true);
        expect(roleService.getRoleDescription(UserRole.manager).isNotEmpty, true);
        expect(roleService.getRoleDescription(UserRole.staff).isNotEmpty, true);
      });
    });

    group('Permission helper', () {
      test('hasPermission returns false for unknown permission', () {
        expect(roleService.hasPermission('unknown_permission'), false);
      });

      test('getPermissionsForRole returns list', () {
        final adminPermissions = roleService.getPermissionsForRole(UserRole.admin);
        final staffPermissions = roleService.getPermissionsForRole(UserRole.staff);

        expect(adminPermissions.length > staffPermissions.length, true);
      });
    });
  });
}
