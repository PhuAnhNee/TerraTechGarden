import '../config/config.dart';

class TerraApi {
  static String _baseUrl(String path) => '${AppConfig.apiBaseUrl}/api/$path';

  // Accessory APIs
  static String getAllAccessories() => _baseUrl('Accessory/get-all');
  static String getAccessoryDetails() => _baseUrl('Accessory/get-details');
  static String getAccessoryById(String id) => _baseUrl('Accessory/get-$id');
  static String addAccessory() => _baseUrl('Accessory/add-accessory');
  static String updateAccessory(String id) =>
      _baseUrl('Accessory/update-accessory$id');
  static String deleteAccessory(String id) =>
      _baseUrl('Accessory/delete-accessory$id');

  // Accounts APIs
  static String createAccount() => _baseUrl('Accounts');
  static String getAllAccounts() => _baseUrl('Accounts');
  static String getAccountById(String id) => _baseUrl('Accounts/$id');
  static String updateAccount(String id) => _baseUrl('Accounts/$id');
  static String deleteAccount(String id) => _baseUrl('Accounts/$id');

  // Blog APIs
  static String getAllBlogs() => _baseUrl('Blog/get-all');
  static String getBlogById(String id) => _baseUrl('Blog/get-$id');
  static String addBlog() => _baseUrl('Blog/add-blog');
  static String updateBlog(String id) => _baseUrl('Blog/update-blog-$id');
  static String deleteBlog(String id) => _baseUrl('Blog/delete-blog-$id');

  // BlogCategory APIs
  static String getAllBlogCategories() => _baseUrl('BlogCategory/get-all');
  static String getBlogCategoryById(String id) =>
      _baseUrl('BlogCategory/get-$id');
  static String addBlogCategory() => _baseUrl('BlogCategory/add-blogCategory');
  static String updateBlogCategory(String id) =>
      _baseUrl('BlogCategory/update-blogCategory-$id');
  static String deleteBlogCategory(String id) =>
      _baseUrl('BlogCategory/delete-blogCategory-$id');

  // Category APIs
  static String getAllCategories() => _baseUrl('Category');
  static String createCategory() => _baseUrl('Category');
  static String getCategoryById(String id) => _baseUrl('Category/$id');
  static String updateCategory(String id) => _baseUrl('Category/$id');
  static String deleteCategory(String id) => _baseUrl('Category/$id');

  // Membership APIs
  static String createMembership() => _baseUrl('Membership/create');
  static String getMembershipById(String id) => _baseUrl('Membership/$id');
  static String updateMembership(String id) => _baseUrl('Membership/$id');
  static String deleteMembership(String id) => _baseUrl('Membership/$id');
  static String getMembershipByUserId(String userId) =>
      _baseUrl('Membership/user/$userId');

  // Role APIs
  static String getAllRoles() => _baseUrl('Role/get-all');
  static String getRoleById(String id) => _baseUrl('Role/get-$id');
  static String createRole() => _baseUrl('Role');
  static String updateRole(String id) => _baseUrl('Role/$id');
  static String deleteRole(String id) => _baseUrl('Role/$id');

  // Terrarium APIs
  static String getAllTerrariums() => _baseUrl('Terrarium/get-all');
  static String getTerrariumDetails() => _baseUrl('Terrarium/get-details');
  static String getTerrariumById(String id) => _baseUrl('Terrarium/get-$id');
  static String addTerrarium() => _baseUrl('Terrarium/add-terrarium');
  static String updateTerrarium(String id) =>
      _baseUrl('Terrarium/update-terrarium$id');
  static String deleteTerrarium(String id) =>
      _baseUrl('Terrarium/delete-terraium$id');

  // Users APIs
  static String registerUser() => _baseUrl('Users/register');
  static String verifyOtp() => _baseUrl('Users/verify-otp');
  static String login() => _baseUrl('Users/login');
  static String refreshToken() => _baseUrl('Users/refresh-token');
  static String forgotPassword() => _baseUrl('Users/forgot-password');
  static String resetPassword() => _baseUrl('Users/reset-password');
  static String loginGoogle() => _baseUrl('Users/login-google');
  static String getUserProfile() => _baseUrl('Users/profile');
  static String getAdminData() => _baseUrl('Users/admin-data');
  static String getManageData() => _baseUrl('Users/manage-data');
  static String getStaffData() => _baseUrl('Users/staff-data');
}
