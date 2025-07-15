import '../config/config.dart';

class TerraApi {
  static String _baseUrl(String path) => '${AppConfig.apiBaseUrl}/api/$path';

  // Accessory APIs
  static String getAllAccessories() => _baseUrl('Accessory/get-all');
  static String getAccessoryById(String id) => _baseUrl('Accessory/get-$id');
  static String addAccessory() => _baseUrl('Accessory/add-accessory');
  static String updateAccessory(String id) =>
      _baseUrl('Accessory/update-accessory-$id');
  static String deleteAccessory(String id) =>
      _baseUrl('Accessory/delete-accessory-$id');

  // Accounts APIs
  static String createAccount() => _baseUrl('Accounts');
  static String getAllAccounts() => _baseUrl('Accounts');
  static String getAccountsByRole(String role) =>
      _baseUrl('Accounts/role/$role');
  static String updateAccountStatus(String userId) =>
      _baseUrl('Accounts/status/$userId');
  static String getAccountById(String id) => _baseUrl('Accounts/$id');
  static String updateAccount(String id) => _baseUrl('Accounts/$id');
  static String deleteAccount(String id) => _baseUrl('Accounts/$id');

  // Address APIs
  static String getAllAddresses() => _baseUrl('Address/get-all');
  static String getAddressById(String id) => _baseUrl('Address/get-$id');
  static String addAddress() => _baseUrl('Address/add-address');
  static String updateAddress(String id) =>
      _baseUrl('Address/update-address-$id');
  static String deleteAddress(String id) => _baseUrl('Address/$id');

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

  // Environment APIs
  static String getAllEnvironments() => _baseUrl('Environment');
  static String createEnvironment() => _baseUrl('Environment');
  static String getEnvironmentById(String id) => _baseUrl('Environment/$id');
  static String updateEnvironment(String id) => _baseUrl('Environment/$id');
  static String deleteEnvironment(String id) => _baseUrl('Environment/$id');

  // Firebase APIs
  static String saveFcmToken() => _baseUrl('Firebase/save-fcmtoken');
  static String deleteFcmToken(String userId, String fcmToken) =>
      _baseUrl('Firebase/$userId/$fcmToken');

  // Membership APIs
  static String createMembership() => _baseUrl('Membership/create');
  static String getAllMemberships() => _baseUrl('Membership/all');
  static String getMembershipById(String id) => _baseUrl('Membership/$id');
  static String updateMembership(String id) => _baseUrl('Membership/$id');
  static String deleteMembership(String id) => _baseUrl('Membership/$id');
  static String getMembershipByUserId(String userId) =>
      _baseUrl('Membership/user/$userId');
  static String updateMembershipExpired() =>
      _baseUrl('Membership/update-expired');
  static String updateMembershipExpiredByUserId(String userId) =>
      _baseUrl('Membership/user/$userId/update-expired');
  static String isMembershipExpired(String id) =>
      _baseUrl('Membership/$id/is-expired');

  // Notification APIs
  static String createNotification() => _baseUrl('Notification/create');
  static String getAllNotifications() => _baseUrl('Notification/get-all');
  static String getNotificationById(String id) =>
      _baseUrl('Notification/get/$id');
  static String getNotificationsByUserId(String userId) =>
      _baseUrl('Notification/get-by-user/$userId');
  static String markNotificationAsRead(String id) =>
      _baseUrl('Notification/mark-as-read/$id');
  static String deleteNotification(String id) =>
      _baseUrl('Notification/delete/$id');

  // Personalize APIs
  static String getAllPersonalizations() => _baseUrl('Personalize/get-all');
  static String getPersonalizationById(String id) =>
      _baseUrl('Personalize/get-$id');
  static String addPersonalization() => _baseUrl('Personalize/add-personalize');
  static String updatePersonalization(String id) =>
      _baseUrl('Personalize/update-$id');
  static String deletePersonalization(String id) =>
      _baseUrl('Personalize/delete-$id');

  // Role APIs
  static String getAllRoles() => _baseUrl('Role/get-all');
  static String getRoleById(String id) => _baseUrl('Role/get-$id');
  static String createRole() => _baseUrl('Role');
  static String updateRole(String id) => _baseUrl('Role/$id');
  static String deleteRole(String id) => _baseUrl('Role/$id');

  // Shape APIs
  static String getAllShapes() => _baseUrl('Shape/get-all');
  static String getShapeById(String id) => _baseUrl('Shape/get-$id');
  static String addShape() => _baseUrl('Shape/add-shape');
  static String updateShape(String id) => _baseUrl('Shape/update-shape-$id');
  static String deleteShape(String id) => _baseUrl('Shape/delete-shape-$id');

  // TankMethod APIs
  static String getAllTankMethods() => _baseUrl('TankMethod');
  static String createTankMethod() => _baseUrl('TankMethod');
  static String getTankMethodById(String id) => _baseUrl('TankMethod/$id');
  static String updateTankMethod(String id) => _baseUrl('TankMethod/$id');
  static String deleteTankMethod(String id) => _baseUrl('TankMethod/$id');

  // Terrarium APIs
  static String getAllTerrariums() => _baseUrl('Terrarium/get-all');
  static String getTerrariumById(String id) => _baseUrl('Terrarium/get-$id');
  static String addTerrarium() => _baseUrl('Terrarium/add-terrarium');
  static String updateTerrarium(String id) =>
      _baseUrl('Terrarium/update-terrarium-$id');
  static String deleteTerrarium(String id) =>
      _baseUrl('Terrarium/delete-terrarium-$id');

  // TerrariumImage APIs
  static String getAllTerrariumImages() => _baseUrl('TerrariumImage/get-all');
  static String getTerrariumImageById(String id) =>
      _baseUrl('TerrariumImage/get-$id');
  static String addTerrariumImage() =>
      _baseUrl('TerrariumImage/add-terrariumImage');
  static String updateTerrariumImage(String id) =>
      _baseUrl('TerrariumImage/update-terrariumImage-$id');
  static String deleteTerrariumImage(String id) =>
      _baseUrl('TerrariumImage/delete-terrariumImage-$id');

  // TerrariumVariant APIs
  static String getAllTerrariumVariants() =>
      _baseUrl('TerrariumVariant/get-all-terrariumVariant');
  static String getTerrariumVariantById(String id) =>
      _baseUrl('TerrariumVariant/get-terrariumVariant-$id');
  static String createTerrariumVariant() =>
      _baseUrl('TerrariumVariant/create-terrariumVariant');
  static String updateTerrariumVariant(String id) =>
      _baseUrl('TerrariumVariant/update-terrariumVariant-$id');
  static String deleteTerrariumVariant(String id) =>
      _baseUrl('TerrariumVariant/delete-terrariumVariant-$id');

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

  // Voucher APIs
  static String validateVoucher(String code) =>
      _baseUrl('Voucher/validate/$code');
  static String getVoucherByCode(String code) => _baseUrl('Voucher/$code');
  static String createVoucher() => _baseUrl('Voucher');
  static String updateVoucher(String id) => _baseUrl('Voucher/$id');
  static String deleteVoucher(String id) => _baseUrl('Voucher/$id');
}
