import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:logging/logging.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/core/network.dart';
import 'package:photos/db/public_keys_db.dart';
import 'package:photos/events/two_factor_status_change_event.dart';
import 'package:photos/events/user_details_changed_event.dart';
import 'package:photos/models/delete_account.dart';
import 'package:photos/models/key_attributes.dart';
import 'package:photos/models/key_gen_result.dart';
import 'package:photos/models/location.dart';
import 'package:photos/models/public_key.dart';
import 'package:photos/models/sessions.dart';
import 'package:photos/models/set_keys_request.dart';
import 'package:photos/models/set_recovery_key_request.dart';
import 'package:photos/models/user_details.dart';
import 'package:photos/ui/account/login_page.dart';
import 'package:photos/ui/account/ott_verification_page.dart';
import 'package:photos/ui/account/password_entry_page.dart';
import 'package:photos/ui/account/password_reentry_page.dart';
import 'package:photos/ui/account/two_factor_authentication_page.dart';
import 'package:photos/ui/account/two_factor_recovery_page.dart';
import 'package:photos/ui/account/two_factor_setup_page.dart';
import 'package:photos/utils/crypto_util.dart';
import 'package:photos/utils/dialog_util.dart';
import 'package:photos/utils/navigation_util.dart';
import 'package:photos/utils/toast_util.dart';

class UserService {
  final _dio = Network.instance.getDio();
  final _logger = Logger((UserService).toString());
  final _config = Configuration.instance;
  ValueNotifier<String> emailValueNotifier;

  UserService._privateConstructor();
  static final UserService instance = UserService._privateConstructor();

  Future<void> init() async {
    emailValueNotifier =
        ValueNotifier<String>(Configuration.instance.getEmail());
  }

  Future<void> sendOtt(
    BuildContext context,
    String email, {
    bool isChangeEmail = false,
    bool isCreateAccountScreen = false,
  }) async {
    final dialog = createProgressDialog(context, "Please wait...");
    await dialog.show();
    try {
      final response = await _dio.post(
        _config.getHttpEndpoint() + "/users/ott",
        data: {"email": email, "purpose": isChangeEmail ? "change" : ""},
      );
      await dialog.hide();
      if (response != null && response.statusCode == 200) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return OTTVerificationPage(
                email,
                isChangeEmail: isChangeEmail,
                isCreateAccountScreen: isCreateAccountScreen,
              );
            },
          ),
        );
        return;
      }
      showGenericErrorDialog(context);
    } on DioError catch (e) {
      await dialog.hide();
      _logger.info(e);
      if (e.response != null && e.response.statusCode == 403) {
        showErrorDialog(context, "Oops", "This email is already in use");
      } else {
        showGenericErrorDialog(context);
      }
    } catch (e) {
      await dialog.hide();
      _logger.severe(e);
      showGenericErrorDialog(context);
    }
  }

  Future<String> getPublicKey(String email) async {
    try {
      final response = await _dio.get(
        _config.getHttpEndpoint() + "/users/public-key",
        queryParameters: {"email": email},
        options: Options(
          headers: {
            "X-Auth-Token": _config.getToken(),
          },
        ),
      );
      final publicKey = response.data["publicKey"];
      await PublicKeysDB.instance.setKey(PublicKey(email, publicKey));
      return publicKey;
    } on DioError catch (e) {
      _logger.info(e);
      return null;
    }
  }

  Future<UserDetails> getUserDetailsV2({bool memoryCount = true}) async {
    try {
      final response = await _dio.get(
        _config.getHttpEndpoint() +
            "/users/details/v2?memoryCount=$memoryCount",
        queryParameters: {
          "memoryCount": memoryCount,
        },
        options: Options(
          headers: {
            "X-Auth-Token": _config.getToken(),
          },
        ),
      );
      return UserDetails.fromMap(response.data);
    } on DioError catch (e) {
      _logger.info(e);
      rethrow;
    }
  }

  Future<Sessions> getActiveSessions() async {
    try {
      final response = await _dio.get(
        _config.getHttpEndpoint() + "/users/sessions",
        options: Options(
          headers: {
            "X-Auth-Token": _config.getToken(),
          },
        ),
      );
      return Sessions.fromMap(response.data);
    } on DioError catch (e) {
      _logger.info(e);
      rethrow;
    }
  }

  Future<void> terminateSession(String token) async {
    try {
      await _dio.delete(
        _config.getHttpEndpoint() + "/users/session",
        options: Options(
          headers: {
            "X-Auth-Token": _config.getToken(),
          },
        ),
        queryParameters: {
          "token": token,
        },
      );
    } on DioError catch (e) {
      _logger.info(e);
      rethrow;
    }
  }

  Future<void> leaveFamilyPlan() async {
    try {
      await _dio.delete(
        _config.getHttpEndpoint() + "/family/leave",
        options: Options(
          headers: {
            "X-Auth-Token": _config.getToken(),
          },
        ),
      );
    } on DioError catch (e) {
      _logger.warning('failed to leave family plan', e);
      rethrow;
    }
  }

  Future<void> logout(BuildContext context) async {
    final dialog = createProgressDialog(context, "Logging out...");
    await dialog.show();
    try {
      final response = await _dio.post(
        _config.getHttpEndpoint() + "/users/logout",
        options: Options(
          headers: {
            "X-Auth-Token": _config.getToken(),
          },
        ),
      );
      if (response != null && response.statusCode == 200) {
        await Configuration.instance.logout();
        await dialog.hide();
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        throw Exception("Log out action failed");
      }
    } catch (e) {
      _logger.severe(e);
      await dialog.hide();
      showGenericErrorDialog(context);
    }
  }

  Future<DeleteChallengeResponse> getDeleteChallenge(
    BuildContext context,
  ) async {
    final dialog = createProgressDialog(context, "Please wait...");
    await dialog.show();
    try {
      final response = await _dio.get(
        _config.getHttpEndpoint() + "/users/delete-challenge",
        options: Options(
          headers: {
            "X-Auth-Token": _config.getToken(),
          },
        ),
      );
      if (response != null && response.statusCode == 200) {
        // clear data
        await dialog.hide();
        return DeleteChallengeResponse(
          allowDelete: response.data["allowDelete"] as bool,
          encryptedChallenge: response.data["encryptedChallenge"],
        );
      } else {
        throw Exception("delete action failed");
      }
    } catch (e) {
      _logger.severe(e);
      await dialog.hide();
      await showGenericErrorDialog(context);
      return null;
    }
  }

  Future<void> deleteAccount(
    BuildContext context,
    String challengeResponse,
  ) async {
    final dialog = createProgressDialog(context, "Deleting account...");
    await dialog.show();
    try {
      final response = await _dio.delete(
        _config.getHttpEndpoint() + "/users/delete",
        data: {
          "challenge": challengeResponse,
        },
        options: Options(
          headers: {
            "X-Auth-Token": _config.getToken(),
          },
        ),
      );
      if (response != null && response.statusCode == 200) {
        // clear data
        await Configuration.instance.logout();
        await dialog.hide();
        showToast(
          context,
          "We have deleted your account and scheduled your uploaded data "
          "for deletion.",
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        throw Exception("delete action failed");
      }
    } catch (e) {
      _logger.severe(e);
      await dialog.hide();
      showGenericErrorDialog(context);
    }
  }

  Future<void> verifyEmail(BuildContext context, String ott) async {
    final dialog = createProgressDialog(context, "Please wait...");
    await dialog.show();
    try {
      final response = await _dio.post(
        _config.getHttpEndpoint() + "/users/verify-email",
        data: {
          "email": _config.getEmail(),
          "ott": ott,
        },
      );
      await dialog.hide();
      if (response != null && response.statusCode == 200) {
        Widget page;
        final String twoFASessionID = response.data["twoFactorSessionID"];
        if (twoFASessionID != null && twoFASessionID.isNotEmpty) {
          page = TwoFactorAuthenticationPage(twoFASessionID);
        } else {
          await _saveConfiguration(response);
          if (Configuration.instance.getEncryptedToken() != null) {
            page = const PasswordReentryPage();
          } else {
            page = const PasswordEntryPage();
          }
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return page;
            },
          ),
          (route) => route.isFirst,
        );
      } else {
        // should never reach here
        throw Exception("unexpected response during email verification");
      }
    } on DioError catch (e) {
      _logger.info(e);
      await dialog.hide();
      if (e.response != null && e.response.statusCode == 410) {
        await showErrorDialog(
          context,
          "Oops",
          "Your verification code has expired",
        );
        Navigator.of(context).pop();
      } else {
        showErrorDialog(
          context,
          "Incorrect code",
          "Sorry, the code you've entered is incorrect",
        );
      }
    } catch (e) {
      await dialog.hide();
      _logger.severe(e);
      showErrorDialog(context, "Oops", "Verification failed, please try again");
    }
  }

  Future<void> setEmail(String email) async {
    await _config.setEmail(email);
    emailValueNotifier.value = email ?? "";
  }

  Future<void> changeEmail(
    BuildContext context,
    String email,
    String ott,
  ) async {
    final dialog = createProgressDialog(context, "Please wait...");
    await dialog.show();
    try {
      final response = await _dio.post(
        _config.getHttpEndpoint() + "/users/change-email",
        data: {
          "email": email,
          "ott": ott,
        },
        options: Options(
          headers: {
            "X-Auth-Token": _config.getToken(),
          },
        ),
      );
      await dialog.hide();
      if (response != null && response.statusCode == 200) {
        showToast(context, "Email changed to " + email);
        await setEmail(email);
        Navigator.of(context).popUntil((route) => route.isFirst);
        Bus.instance.fire(UserDetailsChangedEvent());
        return;
      }
      showErrorDialog(context, "Oops", "Verification failed, please try again");
    } on DioError catch (e) {
      await dialog.hide();
      if (e.response != null && e.response.statusCode == 403) {
        showErrorDialog(context, "Oops", "This email is already in use");
      } else {
        showErrorDialog(
          context,
          "Incorrect code",
          "Authentication failed, please try again",
        );
      }
    } catch (e) {
      await dialog.hide();
      _logger.severe(e);
      showErrorDialog(context, "Oops", "Verification failed, please try again");
    }
  }

  Future<void> setAttributes(KeyGenResult result) async {
    try {
      final name = _config.getName();
      await _dio.put(
        _config.getHttpEndpoint() + "/users/attributes",
        data: {
          "name": name,
          "keyAttributes": result.keyAttributes.toMap(),
        },
        options: Options(
          headers: {
            "X-Auth-Token": _config.getToken(),
          },
        ),
      );
      await _config.setKey(result.privateKeyAttributes.key);
      await _config.setSecretKey(result.privateKeyAttributes.secretKey);
      await _config.setKeyAttributes(result.keyAttributes);
    } catch (e) {
      _logger.severe(e);
      rethrow;
    }
  }

  Future<void> updateKeyAttributes(KeyAttributes keyAttributes) async {
    try {
      final setKeyRequest = SetKeysRequest(
        kekSalt: keyAttributes.kekSalt,
        encryptedKey: keyAttributes.encryptedKey,
        keyDecryptionNonce: keyAttributes.keyDecryptionNonce,
        memLimit: keyAttributes.memLimit,
        opsLimit: keyAttributes.opsLimit,
      );
      await _dio.put(
        _config.getHttpEndpoint() + "/users/keys",
        data: setKeyRequest.toMap(),
        options: Options(
          headers: {
            "X-Auth-Token": _config.getToken(),
          },
        ),
      );
      await _config.setKeyAttributes(keyAttributes);
    } catch (e) {
      _logger.severe(e);
      rethrow;
    }
  }

  Future<void> setRecoveryKey(KeyAttributes keyAttributes) async {
    try {
      final setRecoveryKeyRequest = SetRecoveryKeyRequest(
        keyAttributes.masterKeyEncryptedWithRecoveryKey,
        keyAttributes.masterKeyDecryptionNonce,
        keyAttributes.recoveryKeyEncryptedWithMasterKey,
        keyAttributes.recoveryKeyDecryptionNonce,
      );
      await _dio.put(
        _config.getHttpEndpoint() + "/users/recovery-key",
        data: setRecoveryKeyRequest.toMap(),
        options: Options(
          headers: {
            "X-Auth-Token": _config.getToken(),
          },
        ),
      );
      await _config.setKeyAttributes(keyAttributes);
    } catch (e) {
      _logger.severe(e);
      rethrow;
    }
  }

  Future<void> verifyTwoFactor(
    BuildContext context,
    String sessionID,
    String code,
  ) async {
    final dialog = createProgressDialog(context, "Authenticating...");
    await dialog.show();
    try {
      final response = await _dio.post(
        _config.getHttpEndpoint() + "/users/two-factor/verify",
        data: {
          "sessionID": sessionID,
          "code": code,
        },
      );
      await dialog.hide();
      if (response != null && response.statusCode == 200) {
        showToast(context, "Authentication successful!");
        await _saveConfiguration(response);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return const PasswordReentryPage();
            },
          ),
          (route) => route.isFirst,
        );
      }
    } on DioError catch (e) {
      await dialog.hide();
      _logger.severe(e);
      if (e.response != null && e.response.statusCode == 404) {
        showToast(context, "Session expired");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return const LoginPage();
            },
          ),
          (route) => route.isFirst,
        );
      } else {
        showErrorDialog(
          context,
          "Incorrect code",
          "Authentication failed, please try again",
        );
      }
    } catch (e) {
      await dialog.hide();
      _logger.severe(e);
      showErrorDialog(
        context,
        "Oops",
        "Authentication failed, please try again",
      );
    }
  }

  Future<void> recoverTwoFactor(BuildContext context, String sessionID) async {
    final dialog = createProgressDialog(context, "Please wait...");
    await dialog.show();
    try {
      final response = await _dio.get(
        _config.getHttpEndpoint() + "/users/two-factor/recover",
        queryParameters: {
          "sessionID": sessionID,
        },
      );
      if (response != null && response.statusCode == 200) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return TwoFactorRecoveryPage(
                sessionID,
                response.data["encryptedSecret"],
                response.data["secretDecryptionNonce"],
              );
            },
          ),
          (route) => route.isFirst,
        );
      }
    } on DioError catch (e) {
      _logger.severe(e);
      if (e.response != null && e.response.statusCode == 404) {
        showToast(context, "Session expired");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return const LoginPage();
            },
          ),
          (route) => route.isFirst,
        );
      } else {
        showErrorDialog(
          context,
          "Oops",
          "Something went wrong, please try again",
        );
      }
    } catch (e) {
      _logger.severe(e);
      showErrorDialog(
        context,
        "Oops",
        "Something went wrong, please try again",
      );
    } finally {
      await dialog.hide();
    }
  }

  Future<void> removeTwoFactor(
    BuildContext context,
    String sessionID,
    String recoveryKey,
    String encryptedSecret,
    String secretDecryptionNonce,
  ) async {
    final dialog = createProgressDialog(context, "Please wait...");
    await dialog.show();
    String secret;
    try {
      secret = Sodium.bin2base64(
        await CryptoUtil.decrypt(
          Sodium.base642bin(encryptedSecret),
          Sodium.hex2bin(recoveryKey.trim()),
          Sodium.base642bin(secretDecryptionNonce),
        ),
      );
    } catch (e) {
      await dialog.hide();
      showErrorDialog(
        context,
        "Incorrect recovery key",
        "The recovery key you entered is incorrect",
      );
      return;
    }
    try {
      final response = await _dio.post(
        _config.getHttpEndpoint() + "/users/two-factor/remove",
        data: {
          "sessionID": sessionID,
          "secret": secret,
        },
      );
      if (response != null && response.statusCode == 200) {
        showShortToast(context, "Two-factor authentication successfully reset");
        await _saveConfiguration(response);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return const PasswordReentryPage();
            },
          ),
          (route) => route.isFirst,
        );
      }
    } on DioError catch (e) {
      _logger.severe(e);
      if (e.response != null && e.response.statusCode == 404) {
        showToast(context, "Session expired");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return const LoginPage();
            },
          ),
          (route) => route.isFirst,
        );
      } else {
        showErrorDialog(
          context,
          "Oops",
          "Something went wrong, please try again",
        );
      }
    } catch (e) {
      _logger.severe(e);
      showErrorDialog(
        context,
        "Oops",
        "Something went wrong, please try again",
      );
    } finally {
      await dialog.hide();
    }
  }

  Future<void> setupTwoFactor(BuildContext context) async {
    final dialog = createProgressDialog(context, "Please wait...");
    await dialog.show();
    try {
      final response = await _dio.post(
        _config.getHttpEndpoint() + "/users/two-factor/setup",
        options: Options(
          headers: {
            "X-Auth-Token": _config.getToken(),
          },
        ),
      );
      await dialog.hide();
      routeToPage(
        context,
        TwoFactorSetupPage(
          response.data["secretCode"],
          response.data["qrCode"],
        ),
      );
    } catch (e) {
      await dialog.hide();
      _logger.severe("Failed to setup tfa", e);
      rethrow;
    }
  }

  Future<bool> enableTwoFactor(
    BuildContext context,
    String secret,
    String code,
  ) async {
    Uint8List recoveryKey;
    try {
      recoveryKey = await getOrCreateRecoveryKey(context);
    } catch (e) {
      showGenericErrorDialog(context);
      return false;
    }
    final dialog = createProgressDialog(context, "Verifying...");
    await dialog.show();
    final encryptionResult =
        CryptoUtil.encryptSync(Sodium.base642bin(secret), recoveryKey);
    try {
      await _dio.post(
        _config.getHttpEndpoint() + "/users/two-factor/enable",
        data: {
          "code": code,
          "encryptedTwoFactorSecret":
              Sodium.bin2base64(encryptionResult.encryptedData),
          "twoFactorSecretDecryptionNonce":
              Sodium.bin2base64(encryptionResult.nonce),
        },
        options: Options(
          headers: {
            "X-Auth-Token": _config.getToken(),
          },
        ),
      );
      await dialog.hide();
      Navigator.pop(context);
      Bus.instance.fire(TwoFactorStatusChangeEvent(true));
      return true;
    } catch (e, s) {
      await dialog.hide();
      _logger.severe(e, s);
      if (e is DioError) {
        if (e.response != null && e.response.statusCode == 401) {
          showErrorDialog(
            context,
            "Incorrect code",
            "Please verify the code you have entered",
          );
          return false;
        }
      }
      showErrorDialog(
        context,
        "Something went wrong",
        "Please contact support if the problem persists",
      );
    }
    return false;
  }

  Future<void> disableTwoFactor(BuildContext context) async {
    final dialog =
        createProgressDialog(context, "Disabling two-factor authentication...");
    await dialog.show();
    try {
      await _dio.post(
        _config.getHttpEndpoint() + "/users/two-factor/disable",
        options: Options(
          headers: {
            "X-Auth-Token": _config.getToken(),
          },
        ),
      );
      Bus.instance.fire(TwoFactorStatusChangeEvent(false));
      await dialog.hide();
      showToast(context, "Two-factor authentication has been disabled");
    } catch (e) {
      await dialog.hide();
      _logger.severe("Failed to disabled 2FA", e);
      showErrorDialog(
        context,
        "Something went wrong",
        "Please contact support if the problem persists",
      );
    }
  }

  Future<bool> fetchTwoFactorStatus() async {
    try {
      final response = await _dio.get(
        _config.getHttpEndpoint() + "/users/two-factor/status",
        options: Options(
          headers: {
            "X-Auth-Token": _config.getToken(),
          },
        ),
      );
      return response.data["status"];
    } catch (e) {
      _logger.severe("Failed to fetch 2FA status", e);
      rethrow;
    }
  }

  Future<Uint8List> getOrCreateRecoveryKey(BuildContext context) async {
    final encryptedRecoveryKey =
        _config.getKeyAttributes().recoveryKeyEncryptedWithMasterKey;
    if (encryptedRecoveryKey == null || encryptedRecoveryKey.isEmpty) {
      final dialog = createProgressDialog(context, "Please wait...");
      await dialog.show();
      try {
        final keyAttributes = await _config.createNewRecoveryKey();
        await setRecoveryKey(keyAttributes);
        await dialog.hide();
      } catch (e, s) {
        await dialog.hide();
        _logger.severe(e, s);
        rethrow;
      }
    }
    final recoveryKey = _config.getRecoveryKey();
    return recoveryKey;
  }

  Future<String> getPaymentToken() async {
    try {
      var response = await _dio.get(
        "${_config.getHttpEndpoint()}/users/payment-token",
        options: Options(
          headers: {
            "X-Auth-Token": _config.getToken(),
          },
        ),
      );
      if (response != null && response.statusCode == 200) {
        return response.data["paymentToken"];
      } else {
        throw Exception("non 200 ok response");
      }
    } catch (e) {
      _logger.severe("Failed to get payment token", e);
      return null;
    }
  }

  Future<String> getFamiliesToken() async {
    try {
      var response = await _dio.get(
        "${_config.getHttpEndpoint()}/users/families-token",
        options: Options(
          headers: {
            "X-Auth-Token": _config.getToken(),
          },
        ),
      );
      if (response != null && response.statusCode == 200) {
        return response.data["familiesToken"];
      } else {
        throw Exception("non 200 ok response");
      }
    } catch (e, s) {
      _logger.severe("failed to fetch families token", e, s);
      rethrow;
    }
  }

  Future<void> _saveConfiguration(Response response) async {
    await Configuration.instance.setUserID(response.data["id"]);
    if (response.data["encryptedToken"] != null) {
      await Configuration.instance
          .setEncryptedToken(response.data["encryptedToken"]);
      await Configuration.instance.setKeyAttributes(
        KeyAttributes.fromMap(response.data["keyAttributes"]),
      );
    } else {
      await Configuration.instance.setToken(response.data["token"]);
    }
  }

  Future<dynamic> getLocationSerachData(String query) async {
    try {
      final response = await _dio.get(
        _config.getHttpEndpoint() + "/search/location",
        queryParameters: {"query": query, "limit": 4},
        options: Options(
          headers: {"X-Auth-Token": _config.getToken()},
        ),
      );

      List<dynamic> finalResult = response.data['results'] ?? [];

      for (dynamic result in finalResult) {
        result.update(
          'bbox',
          (value) => {
            /*bbox in response is of order (0-lng,1-lat,2-lng,3-lat) and southwest
           coordinate is (0,1)(lng,lat) and northeast is (2,3)(lng,lat)
           for location(), the order is location(lat,lng) */
            "southWestCoordinates": Location(value[1], value[0]),
            "northEastCoordinates": Location(value[3], value[2])
          },
        );
      }
      return finalResult;
    } on DioError catch (e) {
      _logger.info(e);
      rethrow;
    }
  }
}
