import 'package:dio/dio.dart';
import '../config/config.dart';

class TerraApi {
  static final Dio _dio = Dio();

  static String _baseUrl(String path) => '${AppConfig.apiBaseUrl}/api/$path';

  static Future<Map<String, dynamic>> getTerrariums({int page = 1}) async {
    final response = await _dio.get(
      _baseUrl('Terrarium/get-all'),
      queryParameters: {
        'IncludeProperties': 'TerrariumImages',
      },
    );
    return response.data;
  }

  static String _withQueryParams(String path,
      {int? page,
      int? pageSize,
      String? name,
      String? userId,
      int? environmentId,
      int? shapeId,
      int? tankMethodId,
      String? includeProperties}) {
    String url = _baseUrl(path);
    bool hasParams = false;
    if (page != null ||
        pageSize != null ||
        name != null ||
        userId != null ||
        environmentId != null ||
        shapeId != null ||
        tankMethodId != null ||
        includeProperties != null) {
      url += '?';
      if (page != null) {
        url += 'page=$page';
        hasParams = true;
      }
      if (pageSize != null) {
        url += '${hasParams ? '&' : ''}pageSize=$pageSize';
        hasParams = true;
      }
      if (name != null) {
        url += '${hasParams ? '&' : ''}name=$name';
        hasParams = true;
      }
      if (userId != null) {
        url += '${hasParams ? '&' : ''}userId=$userId';
        hasParams = true;
      }
      if (environmentId != null) {
        url += '${hasParams ? '&' : ''}environmentId=$environmentId';
        hasParams = true;
      }
      if (shapeId != null) {
        url += '${hasParams ? '&' : ''}shapeId=$shapeId';
        hasParams = true;
      }
      if (tankMethodId != null) {
        url += '${hasParams ? '&' : ''}tankMethodId=$tankMethodId';
        hasParams = true;
      }
      if (includeProperties != null) {
        url += '${hasParams ? '&' : ''}IncludeProperties=$includeProperties';
        hasParams = true;
      }
    }
    return url;
  }

  static String getAllAccessories() => _baseUrl('Accessory/get-all');
  static String getAccessoryByName(String name) =>
      _baseUrl('Accessory/get-by-name/$name');
  static String filterAccessories() => _baseUrl('Accessory/filter');
  static String getAccessoryById(String id) => _baseUrl('Accessory/get-$id');
  static String addAccessory() => _baseUrl('Accessory/add-accessory');
  static String updateAccessory(String id) =>
      _baseUrl('Accessory/update-accessory-$id');
  static String deleteAccessory(String id) =>
      _baseUrl('Accessory/delete-accessory-$id');

  static String getAllAccessoryImages() => _baseUrl('AccessoryImage');
  static String getAccessoryImageById(String id) =>
      _baseUrl('AccessoryImage/$id');
  static String updateAccessoryImage(String id) =>
      _baseUrl('AccessoryImage/$id');
  static String deleteAccessoryImage(String id) =>
      _baseUrl('AccessoryImage/$id');
  static String getAccessoryImagesByAccessoryId(String accessoryId) =>
      _baseUrl('AccessoryImage/accessoryId/$accessoryId');
  static String uploadAccessoryImage() => _baseUrl('AccessoryImage/upload');

  static String createAccount() => _baseUrl('Accounts');
  static String getAllAccounts() => _baseUrl('Accounts');
  static String getAccountsByRole(String role) =>
      _baseUrl('Accounts/role/$role');
  static String updateAccountStatus(String userId) =>
      _baseUrl('Accounts/status/$userId');
  static String getAccountById(String id) => _baseUrl('Accounts/$id');
  static String updateAccount(String id) => _baseUrl('Accounts/$id');
  static String deleteAccount(String id) => _baseUrl('Accounts/$id');

  static String getAllAddresses() => _baseUrl('Address/get-all');
  static String getAddressById(String id) => _baseUrl('Address/get-$id');
  static String getAddressByUserId(String userId) =>
      _baseUrl('Address/get-by-user-id-$userId');
  static String addAddress() => _baseUrl('Address/add-address');
  static String updateAddress(String id) =>
      _baseUrl('Address/update-address-$id');
  static String deleteAddress(String id) => _baseUrl('Address/$id');

  static String getAllBlogs() => _baseUrl('Blog/get-all');
  static String getBlogById(String id) => _baseUrl('Blog/get-$id');
  static String addBlog() => _baseUrl('Blog/add-blog');
  static String updateBlog(String id) => _baseUrl('Blog/update-blog-$id');
  static String deleteBlog(String id) => _baseUrl('Blog/delete-blog-$id');

  static String getAllBlogCategories() => _baseUrl('BlogCategory/get-all');
  static String getBlogCategoryById(String id) =>
      _baseUrl('BlogCategory/get-$id');
  static String addBlogCategory() => _baseUrl('BlogCategory/add-blogCategory');
  static String updateBlogCategory(String id) =>
      _baseUrl('BlogCategory/update-blogCategory-$id');
  static String deleteBlogCategory(String id) =>
      _baseUrl('BlogCategory/delete-blogCategory-$id');

  static String getCart() => _baseUrl('Cart');
  static String deleteCart() => _baseUrl('Cart');
  static String addMultipleCartItems() => _baseUrl('Cart/items/multiple');
  static String updateCartItem(String cartItemId) =>
      _baseUrl('Cart/items/$cartItemId');
  static String deleteCartItem(String itemId) => _baseUrl('Cart/items/$itemId');
  static String checkoutCart() => _baseUrl('Cart/checkout');

  static String getAllCategories() => _baseUrl('Category');
  static String createCategory() => _baseUrl('Category');
  static String getCategoryById(String id) => _baseUrl('Category/$id');
  static String updateCategory(String id) => _baseUrl('Category/$id');
  static String deleteCategory(String id) => _baseUrl('Category/$id');

  static String getAllEnvironments() => _baseUrl('Environment/get-all');
  static String createEnvironment() => _baseUrl('Environment');
  static String getEnvironmentById(String id) => _baseUrl('Environment/$id');
  static String updateEnvironment(String id) => _baseUrl('Environment/$id');
  static String deleteEnvironment(String id) => _baseUrl('Environment/$id');

  static String createFeedback() => _baseUrl('Feedback');
  static String getFeedbackByOrderItemId(String orderItemId) =>
      _baseUrl('Feedback/$orderItemId');

  static String saveFcmToken() => _baseUrl('Firebase/save-fcmtoken');

  static String purchaseMembership() => _baseUrl('Membership/purchase');
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

  static String getAllMembershipPackages() => _baseUrl('MembershipPackage');
  static String getMembershipPackageById(String id) =>
      _baseUrl('MembershipPackage/$id');
  static String updateMembershipPackage(String id) =>
      _baseUrl('MembershipPackage/$id');
  static String deleteMembershipPackage(String id) =>
      _baseUrl('MembershipPackage/$id');
  static String createMembershipPackage() =>
      _baseUrl('MembershipPackage/create');

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

  static String getAllOrders() => _baseUrl('Order');
  static String createOrder() => _baseUrl('Order');
  static String getOrderById(String id) => _baseUrl('Order/$id');
  static String deleteOrder(String id) => _baseUrl('Order/$id');
  static String updateOrderStatus(String id) => _baseUrl('Order/$id/status');
  static String checkoutOrder(String id) => _baseUrl('Order/$id/checkout');

  static String getAllOrderItems() => _baseUrl('OrderItem');
  static String createOrderItem() => _baseUrl('OrderItem');
  static String getOrderItemById(String id) => _baseUrl('OrderItem/$id');
  static String updateOrderItem(String id) => _baseUrl('OrderItem/$id');
  static String deleteOrderItem(String id) => _baseUrl('OrderItem/$id');
  static String getOrderItemsByOrderId(String orderId) =>
      _baseUrl('OrderItem/by-order/$orderId');

  static String payOsCallback() => _baseUrl('Payment/pay-os/callback');
  static String payOsPayment() => _baseUrl('Payment/pay-os');
  static String vnPayCallback() => _baseUrl('Payment/vn-pay/callback');
  static String vnPayPayment() => _baseUrl('Payment/vn-pay');

  static String getAllPersonalizations() => _baseUrl('Personalize/get-all');
  static String getPersonalizationById(String id) =>
      _baseUrl('Personalize/get-$id');
  static String addPersonalization() => _baseUrl('Personalize/add-personalize');
  static String updatePersonalization(String id) =>
      _baseUrl('Personalize/update-$id');
  static String deletePersonalization(String id) =>
      _baseUrl('Personalize/delete-$id');

  static String getAllRoles() => _baseUrl('Role/get-all');
  static String getRoleById(String id) => _baseUrl('Role/get-$id');
  static String createRole() => _baseUrl('Role');
  static String updateRole(String id) => _baseUrl('Role/$id');
  static String deleteRole(String id) => _baseUrl('Role/$id');

  static String getAllShapes() => _baseUrl('Shape/get-all');
  static String getShapeById(String id) => _baseUrl('Shape/get-$id');
  static String addShape() => _baseUrl('Shape/add-shape');
  static String updateShape(String id) => _baseUrl('Shape/update-shape-$id');
  static String deleteShape(String id) => _baseUrl('Shape/delete-shape-$id');

  static String getAllTankMethods() => _baseUrl('TankMethod/get-all');
  static String createTankMethod() => _baseUrl('TankMethod');
  static String getTankMethodById(String id) => _baseUrl('TankMethod/$id');
  static String updateTankMethod(String id) => _baseUrl('TankMethod/$id');
  static String deleteTankMethod(String id) => _baseUrl('TankMethod/$id');

  static String getAllTerrariums() => _baseUrl('Terrarium/get-all');
  static String filterTerrariums(
          {int? environmentId,
          int? shapeId,
          int? tankMethodId,
          int? page,
          int? pageSize,
          String? includeProperties}) =>
      _withQueryParams('Terrarium/filter',
          environmentId: environmentId,
          shapeId: shapeId,
          tankMethodId: tankMethodId,
          page: page,
          pageSize: pageSize,
          includeProperties: includeProperties);
  static String getTerrariumByName(String name) =>
      _baseUrl('Terrarium/get-by-name/$name');
  static String getTerrariumById(String id) => _baseUrl('Terrarium/get-$id');
  static String getTerrariumSuggestions(String userId) =>
      _baseUrl('Terrarium/get-suggestions/$userId');
  static String addTerrarium() => _baseUrl('Terrarium/add-terrarium');
  static String updateTerrarium(String id) =>
      _baseUrl('Terrarium/update-terrarium-$id');
  static String deleteTerrarium(String id) =>
      _baseUrl('Terrarium/delete-terrarium-$id');

  static String getAllTerrariumImages() => _baseUrl('TerrariumImage/get-all');
  static String getTerrariumImageById(String id) =>
      _baseUrl('TerrariumImage/get-$id');
  static String getTerrariumImagesByTerrariumId(String terrariumId) =>
      _baseUrl('TerrariumImage/terrariumId/$terrariumId');
  static String uploadTerrariumImage() => _baseUrl('TerrariumImage/upload');
  static String updateTerrariumImage(String id) =>
      _baseUrl('TerrariumImage/update-terrariumImage-$id');
  static String deleteTerrariumImage(String id) =>
      _baseUrl('TerrariumImage/delete-terrariumImage-$id');

  static String getAllTerrariumVariants() =>
      _baseUrl('TerrariumVariant/get-all-terrariumVariant');
  static String getTerrariumVariantById(String id) =>
      _baseUrl('TerrariumVariant/get-terrariumVariant-$id');
  static String getVariantByTerrariumId(String id) =>
      _baseUrl('TerrariumVariant/get-VariantByTerrarium-$id');
  static String createTerrariumVariant() =>
      _baseUrl('TerrariumVariant/create-terrariumVariant');
  static String updateTerrariumVariant(String id) =>
      _baseUrl('TerrariumVariant/update-terrariumVariant-$id');
  static String deleteTerrariumVariant(String id) =>
      _baseUrl('TerrariumVariant/delete-terrariumVariant-$id');

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

  static String validateVoucher(String code) =>
      _baseUrl('Voucher/validate/$code');
  static String getVoucherByCode(String code) => _baseUrl('Voucher/$code');
  static String createVoucher() => _baseUrl('Voucher');
  static String updateVoucher(String id) => _baseUrl('Voucher/$id');
  static String deleteVoucher(String id) => _baseUrl('Voucher/$id');
}
