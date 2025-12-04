import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token
  static Future<void> saveToken(String token) async {
    await _prefs?.setString(AppConstants.tokenKey, token);
  }

  static String? getToken() {
    return _prefs?.getString(AppConstants.tokenKey);
  }

  static Future<void> removeToken() async {
    await _prefs?.remove(AppConstants.tokenKey);
  }

  // User data
  static Future<void> saveUserData(String userData) async {
    await _prefs?.setString(AppConstants.userKey, userData);
  }

  static String? getUserData() {
    return _prefs?.getString(AppConstants.userKey);
  }

  static Future<void> removeUserData() async {
    await _prefs?.remove(AppConstants.userKey);
  }

  // Current company
  static Future<void> saveCurrentCompany(int companyId) async {
    await _prefs?.setInt(AppConstants.companyKey, companyId);
  }

  static int? getCurrentCompany() {
    return _prefs?.getInt(AppConstants.companyKey);
  }

  static Future<void> removeCurrentCompany() async {
    await _prefs?.remove(AppConstants.companyKey);
  }

  // Clear all
  static Future<void> clearAll() async {
    await removeToken();
    await removeUserData();
    await removeCurrentCompany();
  }
}

