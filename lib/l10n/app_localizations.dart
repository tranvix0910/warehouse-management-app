import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('vi', 'VN'),
  ];

  static const Map<String, String> _englishValues = {
    // General
    'app_name': 'Warehouse Management',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'add': 'Add',
    'search': 'Search',
    'filter': 'Filter',
    'clear': 'Clear',
    'confirm': 'Confirm',
    'retry': 'Retry',
    'close': 'Close',
    'yes': 'Yes',
    'no': 'No',
    'ok': 'OK',
    
    // Navigation
    'nav_dashboard': 'Dashboard',
    'nav_items': 'Items',
    'nav_transactions': 'Transactions',
    'nav_reports': 'Reports',
    'nav_settings': 'Settings',
    
    // Dashboard
    'dashboard_title': 'Dashboard',
    'dashboard_welcome': 'Welcome back',
    'dashboard_total_items': 'Total Items',
    'dashboard_low_stock': 'Low Stock',
    'dashboard_out_of_stock': 'Out of Stock',
    'dashboard_recent_transactions': 'Recent Transactions',
    'dashboard_stock_in': 'Stock In',
    'dashboard_stock_out': 'Stock Out',
    'dashboard_top_items': 'Top Items',
    
    // Items
    'items_title': 'Items',
    'items_add_new': 'Add Item',
    'items_search_hint': 'Search items...',
    'items_empty': 'No items found',
    'items_category': 'Category',
    'items_quantity': 'Quantity',
    'items_cost': 'Cost',
    'items_price': 'Price',
    'items_sku': 'SKU',
    'items_name': 'Item Name',
    'items_details': 'Item Details',
    'items_attributes': 'Attributes',
    'items_delete_confirm': 'Are you sure you want to delete this item?',
    'items_deleted': 'Item deleted successfully',
    'items_created': 'Item created successfully',
    'items_updated': 'Item updated successfully',
    
    // Transactions
    'transactions_title': 'Transactions',
    'transactions_new': 'New Transaction',
    'transactions_history': 'Transaction History',
    'transactions_stock_in': 'Stock In',
    'transactions_stock_out': 'Stock Out',
    'transactions_date': 'Date',
    'transactions_supplier': 'Supplier',
    'transactions_customer': 'Customer',
    'transactions_notes': 'Notes',
    'transactions_items': 'Items',
    'transactions_total_quantity': 'Total Quantity',
    'transactions_empty': 'No transactions found',
    'transactions_created': 'Transaction created successfully',
    
    // Reports
    'reports_title': 'Reports',
    'reports_analytics': 'Analytics Dashboard',
    'reports_old_stock': 'Old Stock',
    'reports_low_stock': 'Low Stock',
    'reports_out_of_stock': 'Out of Stock',
    'reports_export_csv': 'Export to CSV',
    'reports_export_pdf': 'Export to PDF',
    'reports_date_range': 'Date Range',
    'reports_exported': 'Report exported successfully',
    
    // Settings
    'settings_title': 'Settings',
    'settings_profile': 'Profile',
    'settings_team': 'Team',
    'settings_theme': 'Theme',
    'settings_theme_light': 'Light',
    'settings_theme_dark': 'Dark',
    'settings_theme_system': 'System',
    'settings_language': 'Language',
    'settings_notifications': 'Notifications',
    'settings_push_notifications': 'Push Notifications',
    'settings_low_stock_alert': 'Low Stock Alert',
    'settings_min_quantity': 'Minimum Quantity',
    'settings_about': 'About',
    'settings_privacy': 'Privacy Policy',
    'settings_logout': 'Sign Out',
    'settings_delete_account': 'Delete Account',
    
    // Auth
    'auth_signin': 'Sign In',
    'auth_signup': 'Sign Up',
    'auth_email': 'Email',
    'auth_password': 'Password',
    'auth_confirm_password': 'Confirm Password',
    'auth_username': 'Username',
    'auth_forgot_password': 'Forgot Password?',
    'auth_no_account': "Don't have an account?",
    'auth_have_account': 'Already have an account?',
    'auth_logout_confirm': 'Are you sure you want to sign out?',
    
    // Profile
    'profile_title': 'Profile',
    'profile_edit': 'Edit Profile',
    'profile_change_password': 'Change Password',
    'profile_current_password': 'Current Password',
    'profile_new_password': 'New Password',
    'profile_phone': 'Phone',
    'profile_address': 'Address',
    
    // Errors
    'error_network': 'Network error. Please check your connection.',
    'error_server': 'Server error. Please try again later.',
    'error_unknown': 'An unknown error occurred.',
    'error_required_field': 'This field is required',
    'error_invalid_email': 'Please enter a valid email',
    'error_password_short': 'Password must be at least 8 characters',
    'error_passwords_not_match': 'Passwords do not match',
    
    // Batch Operations
    'batch_select_all': 'Select All',
    'batch_deselect_all': 'Deselect All',
    'batch_delete_selected': 'Delete Selected',
    'batch_update_price': 'Update Price',
    'batch_import': 'Import from File',
    'batch_export': 'Export to File',
    'batch_items_selected': 'items selected',
    
    // Activity Log
    'activity_log': 'Activity Log',
    'activity_created': 'Created',
    'activity_updated': 'Updated',
    'activity_deleted': 'Deleted',
    'activity_stock_in': 'Stock In',
    'activity_stock_out': 'Stock Out',
    'activity_by': 'by',
    'activity_at': 'at',
  };

  static const Map<String, String> _vietnameseValues = {
    // General
    'app_name': 'Quản Lý Kho',
    'loading': 'Đang tải...',
    'error': 'Lỗi',
    'success': 'Thành công',
    'cancel': 'Hủy',
    'save': 'Lưu',
    'delete': 'Xóa',
    'edit': 'Sửa',
    'add': 'Thêm',
    'search': 'Tìm kiếm',
    'filter': 'Lọc',
    'clear': 'Xóa',
    'confirm': 'Xác nhận',
    'retry': 'Thử lại',
    'close': 'Đóng',
    'yes': 'Có',
    'no': 'Không',
    'ok': 'OK',
    
    // Navigation
    'nav_dashboard': 'Tổng quan',
    'nav_items': 'Sản phẩm',
    'nav_transactions': 'Giao dịch',
    'nav_reports': 'Báo cáo',
    'nav_settings': 'Cài đặt',
    
    // Dashboard
    'dashboard_title': 'Tổng quan',
    'dashboard_welcome': 'Chào mừng trở lại',
    'dashboard_total_items': 'Tổng sản phẩm',
    'dashboard_low_stock': 'Sắp hết hàng',
    'dashboard_out_of_stock': 'Hết hàng',
    'dashboard_recent_transactions': 'Giao dịch gần đây',
    'dashboard_stock_in': 'Nhập kho',
    'dashboard_stock_out': 'Xuất kho',
    'dashboard_top_items': 'Sản phẩm hàng đầu',
    
    // Items
    'items_title': 'Sản phẩm',
    'items_add_new': 'Thêm sản phẩm',
    'items_search_hint': 'Tìm sản phẩm...',
    'items_empty': 'Không tìm thấy sản phẩm',
    'items_category': 'Danh mục',
    'items_quantity': 'Số lượng',
    'items_cost': 'Giá vốn',
    'items_price': 'Giá bán',
    'items_sku': 'Mã SKU',
    'items_name': 'Tên sản phẩm',
    'items_details': 'Chi tiết sản phẩm',
    'items_attributes': 'Thuộc tính',
    'items_delete_confirm': 'Bạn có chắc muốn xóa sản phẩm này?',
    'items_deleted': 'Đã xóa sản phẩm',
    'items_created': 'Đã tạo sản phẩm',
    'items_updated': 'Đã cập nhật sản phẩm',
    
    // Transactions
    'transactions_title': 'Giao dịch',
    'transactions_new': 'Giao dịch mới',
    'transactions_history': 'Lịch sử giao dịch',
    'transactions_stock_in': 'Nhập kho',
    'transactions_stock_out': 'Xuất kho',
    'transactions_date': 'Ngày',
    'transactions_supplier': 'Nhà cung cấp',
    'transactions_customer': 'Khách hàng',
    'transactions_notes': 'Ghi chú',
    'transactions_items': 'Sản phẩm',
    'transactions_total_quantity': 'Tổng số lượng',
    'transactions_empty': 'Không có giao dịch',
    'transactions_created': 'Đã tạo giao dịch',
    
    // Reports
    'reports_title': 'Báo cáo',
    'reports_analytics': 'Bảng điều khiển phân tích',
    'reports_old_stock': 'Tồn kho lâu',
    'reports_low_stock': 'Sắp hết hàng',
    'reports_out_of_stock': 'Hết hàng',
    'reports_export_csv': 'Xuất CSV',
    'reports_export_pdf': 'Xuất PDF',
    'reports_date_range': 'Khoảng thời gian',
    'reports_exported': 'Đã xuất báo cáo',
    
    // Settings
    'settings_title': 'Cài đặt',
    'settings_profile': 'Hồ sơ',
    'settings_team': 'Nhóm',
    'settings_theme': 'Giao diện',
    'settings_theme_light': 'Sáng',
    'settings_theme_dark': 'Tối',
    'settings_theme_system': 'Hệ thống',
    'settings_language': 'Ngôn ngữ',
    'settings_notifications': 'Thông báo',
    'settings_push_notifications': 'Thông báo đẩy',
    'settings_low_stock_alert': 'Cảnh báo hết hàng',
    'settings_min_quantity': 'Số lượng tối thiểu',
    'settings_about': 'Giới thiệu',
    'settings_privacy': 'Chính sách bảo mật',
    'settings_logout': 'Đăng xuất',
    'settings_delete_account': 'Xóa tài khoản',
    
    // Auth
    'auth_signin': 'Đăng nhập',
    'auth_signup': 'Đăng ký',
    'auth_email': 'Email',
    'auth_password': 'Mật khẩu',
    'auth_confirm_password': 'Xác nhận mật khẩu',
    'auth_username': 'Tên người dùng',
    'auth_forgot_password': 'Quên mật khẩu?',
    'auth_no_account': 'Chưa có tài khoản?',
    'auth_have_account': 'Đã có tài khoản?',
    'auth_logout_confirm': 'Bạn có chắc muốn đăng xuất?',
    
    // Profile
    'profile_title': 'Hồ sơ',
    'profile_edit': 'Chỉnh sửa hồ sơ',
    'profile_change_password': 'Đổi mật khẩu',
    'profile_current_password': 'Mật khẩu hiện tại',
    'profile_new_password': 'Mật khẩu mới',
    'profile_phone': 'Số điện thoại',
    'profile_address': 'Địa chỉ',
    
    // Errors
    'error_network': 'Lỗi mạng. Vui lòng kiểm tra kết nối.',
    'error_server': 'Lỗi máy chủ. Vui lòng thử lại sau.',
    'error_unknown': 'Đã xảy ra lỗi không xác định.',
    'error_required_field': 'Trường này là bắt buộc',
    'error_invalid_email': 'Vui lòng nhập email hợp lệ',
    'error_password_short': 'Mật khẩu phải có ít nhất 8 ký tự',
    'error_passwords_not_match': 'Mật khẩu không khớp',
    
    // Batch Operations
    'batch_select_all': 'Chọn tất cả',
    'batch_deselect_all': 'Bỏ chọn tất cả',
    'batch_delete_selected': 'Xóa đã chọn',
    'batch_update_price': 'Cập nhật giá',
    'batch_import': 'Nhập từ file',
    'batch_export': 'Xuất ra file',
    'batch_items_selected': 'sản phẩm đã chọn',
    
    // Activity Log
    'activity_log': 'Nhật ký hoạt động',
    'activity_created': 'Đã tạo',
    'activity_updated': 'Đã cập nhật',
    'activity_deleted': 'Đã xóa',
    'activity_stock_in': 'Nhập kho',
    'activity_stock_out': 'Xuất kho',
    'activity_by': 'bởi',
    'activity_at': 'lúc',
  };

  String translate(String key) {
    Map<String, String> localizedValues;
    
    if (locale.languageCode == 'vi') {
      localizedValues = _vietnameseValues;
    } else {
      localizedValues = _englishValues;
    }
    
    return localizedValues[key] ?? key;
  }

  String get appName => translate('app_name');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get add => translate('add');
  String get search => translate('search');
  String get confirm => translate('confirm');
  
  // Navigation
  String get navDashboard => translate('nav_dashboard');
  String get navItems => translate('nav_items');
  String get navTransactions => translate('nav_transactions');
  String get navReports => translate('nav_reports');
  String get navSettings => translate('nav_settings');
  
  // Dashboard
  String get dashboardTitle => translate('dashboard_title');
  String get dashboardWelcome => translate('dashboard_welcome');
  String get dashboardTotalItems => translate('dashboard_total_items');
  String get dashboardLowStock => translate('dashboard_low_stock');
  String get dashboardOutOfStock => translate('dashboard_out_of_stock');
  
  // Settings
  String get settingsTitle => translate('settings_title');
  String get settingsTheme => translate('settings_theme');
  String get settingsThemeLight => translate('settings_theme_light');
  String get settingsThemeDark => translate('settings_theme_dark');
  String get settingsLanguage => translate('settings_language');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'vi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class LocaleState {
  final Locale locale;
  final List<Locale> supportedLocales;

  LocaleState({
    required this.locale,
    this.supportedLocales = const [
      Locale('en', 'US'),
      Locale('vi', 'VN'),
    ],
  });

  String get languageName {
    switch (locale.languageCode) {
      case 'vi':
        return 'Tiếng Việt';
      case 'en':
      default:
        return 'English';
    }
  }

  LocaleState copyWith({Locale? locale}) {
    return LocaleState(
      locale: locale ?? this.locale,
      supportedLocales: supportedLocales,
    );
  }
}

class LocaleNotifier extends StateNotifier<LocaleState> {
  LocaleNotifier() : super(LocaleState(locale: const Locale('en', 'US'))) {
    _loadLocale();
  }

  static const String _localeKey = 'app_locale';

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey) ?? 'en';
    final countryCode = languageCode == 'vi' ? 'VN' : 'US';
    state = state.copyWith(locale: Locale(languageCode, countryCode));
  }

  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  void toggleLocale() {
    final newLocale = state.locale.languageCode == 'en'
        ? const Locale('vi', 'VN')
        : const Locale('en', 'US');
    setLocale(newLocale);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, LocaleState>((ref) {
  return LocaleNotifier();
});
