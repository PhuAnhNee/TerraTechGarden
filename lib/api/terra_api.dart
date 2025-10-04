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

  static Future<Map<String, dynamic>> getAccessories({int page = 1}) async {
    final response = await _dio.get(
      _baseUrl('Accessory/get-all'),
      queryParameters: {
        'IncludeProperties': 'AccessoryImages',
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

  // Accessory
  static String getAllAccessories() => _baseUrl('Accessory/get-all');
  static String getAccessoryByName(String name) =>
      _baseUrl('Accessory/get-by-name/$name');
  static String filterAccessoriesByCategory(String categoryId) =>
      _baseUrl('Accessory/filter-by-category/$categoryId');
  static String getAccessoryById(String id) => _baseUrl('Accessory/get/$id');
  static String addAccessory() => _baseUrl('Accessory/add-accessory');
  static String updateAccessory(String id) =>
      _baseUrl('Accessory/update-accessory/$id');
  static String deleteAccessory(String id) =>
      _baseUrl('Accessory/delete-accessory/$id');

  // AccessoryImage
  static String getAllAccessoryImages() => _baseUrl('AccessoryImage/get-all');
  static String getAccessoryImageById(String id) =>
      _baseUrl('AccessoryImage/get-by/$id');
  static String getAccessoryImagesByAccessoryId(String accessoryId) =>
      _baseUrl('AccessoryImage/get-accessoryId/$accessoryId');
  static String addAccessoryImage() =>
      _baseUrl('AccessoryImage/add-accessoryimage');
  static String updateAccessoryImage(String id) =>
      _baseUrl('AccessoryImage/update-accessoryimage/$id');
  static String deleteAccessoryImage(String id) =>
      _baseUrl('AccessoryImage/delete-accessoryimage/$id');

  // Accounts
  static String createAccount() => _baseUrl('Accounts');
  static String getAllAccounts() => _baseUrl('Accounts/get-all');
  static String getAccountsByRole(String role) =>
      _baseUrl('Accounts/role/$role');
  static String updateAccountStatus(String userId) =>
      _baseUrl('Accounts/status/$userId');
  static String getAccountById(String id) => _baseUrl('Accounts/$id');
  static String updateAccount(String id) => _baseUrl('Accounts/$id');
  static String deleteAccount(String id) => _baseUrl('Accounts/$id');

  // Address
  static String getAllAddresses() => _baseUrl('Address/get-all');
  static String getAddressById(String id) => _baseUrl('Address/get/$id');
  // Fixed method name (was getAddress in ship_bloc.dart but didn't exist)
  static String getAddress(int id) => _baseUrl('Address/get/$id');
  static String getAllAddressesByUserId(String userId) =>
      _baseUrl('Address/getall-by-user-id/$userId');
  static String addAddress() => _baseUrl('Address/add-address');
  static String updateAddress(String id) => _baseUrl(
      'Address/uodate-adrress/$id'); // Note: keeping original typo from API spec
  static String deleteAddress(String id) =>
      _baseUrl('Address/delete-address/$id');

  // AI
  static String autoGenerateAI() => _baseUrl('AI/auto-generate');

  // Blog
  static String getAllBlogs() => _baseUrl('Blog/get-all');
  static String getBlogById(String id) => _baseUrl('Blog/get/$id');
  static String addBlog() => _baseUrl('Blog/add-blog');
  static String updateBlog(String id) => _baseUrl('Blog/update-blog/$id');
  static String deleteBlog(String id) => _baseUrl('Blog/delete-blog/$id');

  // BlogCategory
  static String getAllBlogCategories() => _baseUrl('BlogCategory/get-all');
  static String getBlogCategoryById(String id) =>
      _baseUrl('BlogCategory/get/$id');
  static String addBlogCategory() => _baseUrl('BlogCategory/add-blogCategory');
  static String updateBlogCategory(String id) =>
      _baseUrl('BlogCategory/update-blogCategory/$id');
  static String deleteBlogCategory(String id) =>
      _baseUrl('BlogCategory/delete-blogCategory/$id');

  // Cart
  static String getCart() => _baseUrl('Cart/get-all');
  static String addMultipleCartItems() => _baseUrl('Cart/add-item');
  static String updateCartItem(String itemId) =>
      _baseUrl('Cart/update-items/$itemId');
  static String deleteCartItem(String itemId) =>
      _baseUrl('Cart/delete-items/$itemId');
  static String deleteAllCartItems() => _baseUrl('Cart/delete-all-items');
  static String checkoutCart() => _baseUrl('Cart/checkout-cart');

  // Category
  static String getAllCategories() => _baseUrl('Category/get-all');
  static String getCategoryById(String id) => _baseUrl('Category/get/$id');
  static String createCategory() => _baseUrl('Category/add-category');
  static String updateCategory(String id) =>
      _baseUrl('Category/update-category/$id');
  static String deleteCategory(String id) =>
      _baseUrl('Category/delete-category/$id');

  // Chat
  static String getAvailableUsers() => _baseUrl('Chat/available-users');
  static String createChat() => _baseUrl('Chat/create');
  static String getMyChats() => _baseUrl('Chat/my-chats');
  static String getChatMessages(String chatId) =>
      _baseUrl('Chat/$chatId/messages');
  static String sendMessage() => _baseUrl('Chat/send-message');
  static String markChatAsRead(String chatId) =>
      _baseUrl('Chat/$chatId/mark-read');
  static String debugUserInfo() => _baseUrl('Chat/debug/user-info');

  // Environment
  static String getAllEnvironments() => _baseUrl('Environment/get-all');
  static String getEnvironmentById(String id) =>
      _baseUrl('Environment/get/$id');
  static String createEnvironment() => _baseUrl('Environment/add-environment');
  static String updateEnvironment(String id) =>
      _baseUrl('Environment/update-environment/$id');
  static String deleteEnvironment(String id) =>
      _baseUrl('Environment/delete-environment/$id');

  // Favorite
  static String createFavorite() => _baseUrl('Favorite');
  static String getAllFavorites() => _baseUrl('Favorite');
  static String deleteFavoriteByProduct() => _baseUrl('Favorite/by-product');
  static String deleteFavorite(String favoriteId) =>
      _baseUrl('Favorite/$favoriteId');

  // Feedback
  static String createFeedback() => _baseUrl('Feedback');
  static String getAllFeedback() => _baseUrl('Feedback');
  static String getFeedbackByTerrariumId(String terrariumId) =>
      _baseUrl('Feedback/terrarium/$terrariumId');
  static String getFeedbackByOrderItemId(String orderItemId) =>
      _baseUrl('Feedback/order/$orderItemId');
  static String updateFeedback(String id) => _baseUrl('Feedback/$id');
  static String deleteFeedback(String id) => _baseUrl('Feedback/$id');

  // FeedbackImage
  static String getAllFeedbackImages() => _baseUrl('FeedbackImage/get-all');
  static String getFeedbackImageById(String id) =>
      _baseUrl('FeedbackImage/get/$id');
  static String getFeedbackImagesByFeedbackId(String feedbackId) =>
      _baseUrl('FeedbackImage/get-by-feedbackId/$feedbackId');
  static String addFeedbackImage() => _baseUrl('FeedbackImage/add-image');
  static String updateFeedbackImage(String id) =>
      _baseUrl('FeedbackImage/update-image/$id');
  static String deleteFeedbackImage(String id) =>
      _baseUrl('FeedbackImage/delete-image/$id');

  // Firebase
  static String saveFcmToken() => _baseUrl('Firebase/save-fcmtoken');
  static String deleteFcmToken(String userId, String fcmToken) =>
      _baseUrl('Firebase/$userId/$fcmToken');

  // Membership
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

  // MembershipPackage
  static String getAllMembershipPackages() => _baseUrl('MembershipPackage');
  static String getMembershipPackageById(String id) =>
      _baseUrl('MembershipPackage/$id');
  static String updateMembershipPackage(String id) =>
      _baseUrl('MembershipPackage/$id');
  static String deleteMembershipPackage(String id) =>
      _baseUrl('MembershipPackage/$id');
  static String createMembershipPackage() =>
      _baseUrl('MembershipPackage/create');
  static String createMembershipForUser() =>
      _baseUrl('MembershipPackage/createmembershipforuser');

  // Notification
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

  // Order
  static String getAllOrdersByUserId(String userId) =>
      _baseUrl('Order/get-all-by-userid/$userId');
  static String getAllOrders() => _baseUrl('Order');
  static String createOrder() => _baseUrl('Order');
  static String getOrder(int id) => _baseUrl('Order/$id');
  static String getOrderById(int orderId) => _baseUrl('Order/$orderId');
  static String deleteOrder(String id) => _baseUrl('Order/$id');
  static String getOrdersByUserId(String id) =>
      _baseUrl('Order/getbyuserid/$id');
  static String updateOrderStatus(String id) => _baseUrl('Order/$id/status');
  static String checkoutOrder(String id) => _baseUrl('Order/$id/checkout');
  static String getOrdersByUser(String userId) =>
      _baseUrl('Order/user/$userId');
  static String getOrderTransport(String id) => _baseUrl('Order/$id/Transport');
  static String requestOrderRefund(String id) => _baseUrl('Order/$id/Refund');
  static String updateOrderRefund(String id) => _baseUrl('Order/Refund/$id');

  // OrderItem
  static String getAllOrderItems() => _baseUrl('OrderItem/get-all');
  static String getOrderItemById(String id) => _baseUrl('OrderItem/$id');
  static String updateOrderItem(String id) => _baseUrl('OrderItem/$id');
  static String deleteOrderItem(String id) => _baseUrl('OrderItem/$id');
  static String getOrderItemsByOrderId(String orderId) =>
      _baseUrl('OrderItem/get-by-order/$orderId');
  static String createOrderItem() => _baseUrl('OrderItem');

  // Payment
  static String payOsPayment() => _baseUrl('Payment/pay-os');
  static String payOsCallback() => _baseUrl('Payment/pay-os/callback');
  static String vnPayPayment() => _baseUrl('Payment/vn-pay');
  static String vnPayCallback() => _baseUrl('Payment/vn-pay/callback');
  static String createMomoPayment() => _baseUrl('Payment/momo/create');
  static String momoCallback() => _baseUrl('Payment/momo/callback');
  static String momoIpn() => _baseUrl('Payment/momo/ipn');

  // Personalize
  static String getAllPersonalizations() => _baseUrl('Personalize/get-all');
  static String getPersonalizationById(String id) =>
      _baseUrl('Personalize/get-by/$id');
  static String getPersonalizationByUserId(String userId) =>
      _baseUrl('Personalize/get-by-userId/$userId');
  static String addPersonalization() => _baseUrl('Personalize/add-personalize');
  static String updatePersonalization(String id) =>
      _baseUrl('Personalize/update-personalize/$id');
  static String deletePersonalization(String id) =>
      _baseUrl('Personalize/delete-personalize/$id');

  // Profile
  static String getMyProfile() => _baseUrl('Profile/me');
  static String updateMyProfile() => _baseUrl('Profile/me');
  static String uploadProfileAvatar() => _baseUrl('Profile/me/avatar');
  static String uploadProfileBackground() => _baseUrl('Profile/me/background');
  static String getAllProfiles() => _baseUrl('Profile/all');
  static String getProfileByUserId(String userId) =>
      _baseUrl('Profile/$userId');

  // Role
  static String getAllRoles() => _baseUrl('Role/get-all');
  static String getRoleById(String id) => _baseUrl('Role/get/$id');
  static String createRole() => _baseUrl('Role/add-role');
  static String updateRole(String id) => _baseUrl('Role/update-role/$id');
  static String deleteRole(String id) => _baseUrl('Role/delete-role/$id');

  // Shape
  static String getAllShapes() => _baseUrl('Shape/get-all');
  static String getShapeById(String id) => _baseUrl('Shape/get/$id');
  static String addShape() => _baseUrl('Shape/add-shape');
  static String updateShape(String id) => _baseUrl('Shape/update-shape/$id');
  static String deleteShape(String id) => _baseUrl('Shape/delete-shape/$id');

  // TankMethod
  static String getAllTankMethods() => _baseUrl('TankMethod/get-all');
  static String getTankMethodById(String id) => _baseUrl('TankMethod/get/$id');
  static String createTankMethod() => _baseUrl('TankMethod/add-tankmethod');
  static String updateTankMethod(String id) =>
      _baseUrl('TankMethod/update-tankmethod/$id');
  static String deleteTankMethod(String id) =>
      _baseUrl('TankMethod/delete-tankmethod/$id');

  // Terrarium
  static String getAllTerrariums() => _baseUrl('Terrarium/get-all');
  static String filterTerrariums({
    int? environmentId,
    int? shapeId,
    int? tankMethodId,
    int? page,
    int? pageSize,
    String? includeProperties,
  }) =>
      _withQueryParams('Terrarium/filter',
          environmentId: environmentId,
          shapeId: shapeId,
          tankMethodId: tankMethodId,
          page: page,
          pageSize: pageSize,
          includeProperties: includeProperties);
  static String getTerrariumByName(String name) =>
      _baseUrl('Terrarium/get-by-terrariumname/$name');
  static String getTerrariumById(String id) => _baseUrl('Terrarium/get/$id');
  static String addTerrarium() => _baseUrl('Terrarium/add-terrarium');
  static String updateTerrarium(String id) =>
      _baseUrl('Terrarium/update-terrarium/$id');
  static String deleteTerrarium(String id) => _baseUrl(
      'Terrarium/delete-terraium/$id'); // Note: keeping original typo from API spec

  // TerrariumImage
  static String getAllTerrariumImages() => _baseUrl('TerrariumImage/get-all');
  static String getTerrariumImageById(String id) =>
      _baseUrl('TerrariumImage/get/$id');
  static String getTerrariumImagesByTerrariumId(String terrariumId) =>
      _baseUrl('TerrariumImage/get-by-terrariumId/$terrariumId');
  static String uploadTerrariumImage() => _baseUrl('TerrariumImage/upload');
  static String updateTerrariumImage(String id) =>
      _baseUrl('TerrariumImage/update-terrariumImage/$id');
  static String deleteTerrariumImage(String id) =>
      _baseUrl('TerrariumImage/delete-terrariumImage/$id');

  // TerrariumVariant
  static String getAllTerrariumVariants() =>
      _baseUrl('TerrariumVariant/get-all-terrariumVariant');
  static String getTerrariumVariantById(String id) =>
      _baseUrl('TerrariumVariant/get-terrariumVariant/$id');
  static String getTerrariumVariants(String id) =>
      _baseUrl('TerrariumVariant/get-VariantByTerrarium/$id');
  static String createTerrariumVariant() =>
      _baseUrl('TerrariumVariant/create-terrariumVariant');
  static String updateTerrariumVariant(String id) =>
      _baseUrl('TerrariumVariant/update-terrariumVariant/$id');
  static String deleteTerrariumVariant(String id) =>
      _baseUrl('TerrariumVariant/delete-terrariumVariant/$id');

  // Transport
  static String getAllTransports() => _baseUrl('Transport');
  static String createTransport() => _baseUrl('Transport');
  // Fixed method name (was getTransports in ship_bloc.dart but didn't exist)
  static String getTransports() => _baseUrl('Transport');
  static String getTransport(String transportId) =>
      _baseUrl('Transport/$transportId');
  static String updateTransport(String transportId) =>
      _baseUrl('Transport/$transportId');
  static String deleteTransport(String transportId) =>
      _baseUrl('Transport/$transportId');

  // Users
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

  // Voucher
  static String getAllVouchers() => _baseUrl('Voucher');
  static String createVoucher() => _baseUrl('Voucher');
  static String getVoucherByCode(String code) =>
      _baseUrl('Voucher/get-by-code/$code');
  static String updateVoucher(String id) =>
      _baseUrl('Voucher/update-voucher/$id');
  static String deleteVoucher(String id) =>
      _baseUrl('Voucher/delete-voucher/$id');
  static String validateVoucher(String code) =>
      _baseUrl('Voucher/validate/$code');
  static String consumeVoucher(String code) =>
      _baseUrl('Voucher/$code/consume');

  // Wallet
  static String depositWallet() => _baseUrl('Wallet/deposit');
  static String payWallet() => _baseUrl('Wallet/pay');
  static String refundWallet() => _baseUrl('Wallet/refund');
  static String getWalletBalance() => _baseUrl('Wallet/balance');
}
