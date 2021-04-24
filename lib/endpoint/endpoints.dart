class Endpoints {
  static const urlHost = 'http://toks.herokuapp.com';

  static const registerNewUser = '/api/user/signup';

  final String deleteUserProfile = '/api/user/delete-profile';

  final String disableUserProfile = '/api/user/disable-profile';

  final String editUserProfile = '/api/user/edit-profile';

  final String enableUserProfile = 'api/user/enable-profile/{user-id}';

  final String forgotPassword = '/api/user/forgot-password';

  final String getAllUsersByRole = '/api/user/get-all-profiles-np/{role}';

  final String getAllPaginatedUsersByRole =
      '/api/user/get-all-profiles/{role}/{pageNo}/{pageSize}';

  final String getCurrentUserWithToken = '/api/user/get-current-user-details';

  final String getUserByID = '/api/user/get-profile/{userId}';

   static const loginToPlatform = '/api/user/login';
}
