// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Enter your email address`
  String get enterYourEmailAddress {
    return Intl.message(
      'Enter your email address',
      name: 'enterYourEmailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Welcome back!`
  String get accountWelcomeBack {
    return Intl.message(
      'Welcome back!',
      name: 'accountWelcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get verify {
    return Intl.message(
      'Verify',
      name: 'verify',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email address`
  String get invalidEmailAddress {
    return Intl.message(
      'Invalid email address',
      name: 'invalidEmailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address.`
  String get enterValidEmail {
    return Intl.message(
      'Please enter a valid email address.',
      name: 'enterValidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Delete account`
  String get deleteAccount {
    return Intl.message(
      'Delete account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `What is the main reason you are deleting your account?`
  String get askDeleteReason {
    return Intl.message(
      'What is the main reason you are deleting your account?',
      name: 'askDeleteReason',
      desc: '',
      args: [],
    );
  }

  /// `We are sorry to see you go. Please share your feedback to help us improve.`
  String get deleteAccountFeedbackPrompt {
    return Intl.message(
      'We are sorry to see you go. Please share your feedback to help us improve.',
      name: 'deleteAccountFeedbackPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get feedback {
    return Intl.message(
      'Feedback',
      name: 'feedback',
      desc: '',
      args: [],
    );
  }

  /// `Kindly help us with this information`
  String get kindlyHelpUsWithThisInformation {
    return Intl.message(
      'Kindly help us with this information',
      name: 'kindlyHelpUsWithThisInformation',
      desc: '',
      args: [],
    );
  }

  /// `Yes, I want to permanently delete this account and all its data.`
  String get confirmDeletePrompt {
    return Intl.message(
      'Yes, I want to permanently delete this account and all its data.',
      name: 'confirmDeletePrompt',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Account Deletion`
  String get confirmAccountDeletion {
    return Intl.message(
      'Confirm Account Deletion',
      name: 'confirmAccountDeletion',
      desc: '',
      args: [],
    );
  }

  /// `You are about to permanently delete your account and all its data.\nThis action is irreversible.`
  String get deleteConfirmDialogBody {
    return Intl.message(
      'You are about to permanently delete your account and all its data.\nThis action is irreversible.',
      name: 'deleteConfirmDialogBody',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account Permanently`
  String get deleteAccountPermanentlyButton {
    return Intl.message(
      'Delete Account Permanently',
      name: 'deleteAccountPermanentlyButton',
      desc: '',
      args: [],
    );
  }

  /// `Your account has been deleted`
  String get yourAccountHasBeenDeleted {
    return Intl.message(
      'Your account has been deleted',
      name: 'yourAccountHasBeenDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Select reason`
  String get selectReason {
    return Intl.message(
      'Select reason',
      name: 'selectReason',
      desc: '',
      args: [],
    );
  }

  /// `It’s missing a key feature that I need`
  String get deleteReason1 {
    return Intl.message(
      'It’s missing a key feature that I need',
      name: 'deleteReason1',
      desc: '',
      args: [],
    );
  }

  /// `The app or a certain feature does not \nbehave as I think it should`
  String get deleteReason2 {
    return Intl.message(
      'The app or a certain feature does not \nbehave as I think it should',
      name: 'deleteReason2',
      desc: '',
      args: [],
    );
  }

  /// `I found another service that I like better`
  String get deleteReason3 {
    return Intl.message(
      'I found another service that I like better',
      name: 'deleteReason3',
      desc: '',
      args: [],
    );
  }

  /// `My reason isn’t listed`
  String get deleteReason4 {
    return Intl.message(
      'My reason isn’t listed',
      name: 'deleteReason4',
      desc: '',
      args: [],
    );
  }

  /// `Send email`
  String get sendEmail {
    return Intl.message(
      'Send email',
      name: 'sendEmail',
      desc: '',
      args: [],
    );
  }

  /// `Your request will be processed within 72 hours.`
  String get deleteRequestSLAText {
    return Intl.message(
      'Your request will be processed within 72 hours.',
      name: 'deleteRequestSLAText',
      desc: '',
      args: [],
    );
  }

  /// `Please send an email to <warning>account-deletion@ente.io</warning> from your registered email address.`
  String get deleteEmailRequest {
    return Intl.message(
      'Please send an email to <warning>account-deletion@ente.io</warning> from your registered email address.',
      name: 'deleteEmailRequest',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message(
      'Ok',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Create account`
  String get createAccount {
    return Intl.message(
      'Create account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Create new account`
  String get createNewAccount {
    return Intl.message(
      'Create new account',
      name: 'createNewAccount',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Confirm password`
  String get confirmPassword {
    return Intl.message(
      'Confirm password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Active sessions`
  String get activeSessions {
    return Intl.message(
      'Active sessions',
      name: 'activeSessions',
      desc: '',
      args: [],
    );
  }

  /// `Oops`
  String get oops {
    return Intl.message(
      'Oops',
      name: 'oops',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong, please try again`
  String get somethingWentWrongPleaseTryAgain {
    return Intl.message(
      'Something went wrong, please try again',
      name: 'somethingWentWrongPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `This will log you out of this device!`
  String get thisWillLogYouOutOfThisDevice {
    return Intl.message(
      'This will log you out of this device!',
      name: 'thisWillLogYouOutOfThisDevice',
      desc: '',
      args: [],
    );
  }

  /// `This will log you out of the following device:`
  String get thisWillLogYouOutOfTheFollowingDevice {
    return Intl.message(
      'This will log you out of the following device:',
      name: 'thisWillLogYouOutOfTheFollowingDevice',
      desc: '',
      args: [],
    );
  }

  /// `Terminate session?`
  String get terminateSession {
    return Intl.message(
      'Terminate session?',
      name: 'terminateSession',
      desc: '',
      args: [],
    );
  }

  /// `Terminate`
  String get terminate {
    return Intl.message(
      'Terminate',
      name: 'terminate',
      desc: '',
      args: [],
    );
  }

  /// `This device`
  String get thisDevice {
    return Intl.message(
      'This device',
      name: 'thisDevice',
      desc: '',
      args: [],
    );
  }

  /// `Recover`
  String get recoverButton {
    return Intl.message(
      'Recover',
      name: 'recoverButton',
      desc: '',
      args: [],
    );
  }

  /// `Recovery successful!`
  String get recoverySuccessful {
    return Intl.message(
      'Recovery successful!',
      name: 'recoverySuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Decrypting...`
  String get decrypting {
    return Intl.message(
      'Decrypting...',
      name: 'decrypting',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect recovery key`
  String get incorrectRecoveryKeyTitle {
    return Intl.message(
      'Incorrect recovery key',
      name: 'incorrectRecoveryKeyTitle',
      desc: '',
      args: [],
    );
  }

  /// `The recovery key you entered is incorrect`
  String get incorrectRecoveryKeyBody {
    return Intl.message(
      'The recovery key you entered is incorrect',
      name: 'incorrectRecoveryKeyBody',
      desc: '',
      args: [],
    );
  }

  /// `Forgot password`
  String get forgotPassword {
    return Intl.message(
      'Forgot password',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter your recovery key`
  String get enterYourRecoveryKey {
    return Intl.message(
      'Enter your recovery key',
      name: 'enterYourRecoveryKey',
      desc: '',
      args: [],
    );
  }

  /// `No recovery key?`
  String get noRecoveryKey {
    return Intl.message(
      'No recovery key?',
      name: 'noRecoveryKey',
      desc: '',
      args: [],
    );
  }

  /// `Sorry`
  String get sorry {
    return Intl.message(
      'Sorry',
      name: 'sorry',
      desc: '',
      args: [],
    );
  }

  /// `Due to the nature of our end-to-end encryption protocol, your data cannot be decrypted without your password or recovery key`
  String get noRecoveryKeyNoDecryption {
    return Intl.message(
      'Due to the nature of our end-to-end encryption protocol, your data cannot be decrypted without your password or recovery key',
      name: 'noRecoveryKeyNoDecryption',
      desc: '',
      args: [],
    );
  }

  /// `Verify email`
  String get verifyEmail {
    return Intl.message(
      'Verify email',
      name: 'verifyEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please check your inbox (and spam) to complete verification`
  String get checkInboxAndSpamFolder {
    return Intl.message(
      'Please check your inbox (and spam) to complete verification',
      name: 'checkInboxAndSpamFolder',
      desc: '',
      args: [],
    );
  }

  /// `Tap to enter code`
  String get tapToEnterCode {
    return Intl.message(
      'Tap to enter code',
      name: 'tapToEnterCode',
      desc: '',
      args: [],
    );
  }

  /// `Resend email`
  String get resendEmail {
    return Intl.message(
      'Resend email',
      name: 'resendEmail',
      desc: '',
      args: [],
    );
  }

  /// `We've sent a mail to`
  String get weveSentAMailTo {
    return Intl.message(
      'We\'ve sent a mail to',
      name: 'weveSentAMailTo',
      desc: '',
      args: [],
    );
  }

  /// `Set password`
  String get setPasswordTitle {
    return Intl.message(
      'Set password',
      name: 'setPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Change password`
  String get changePasswordTitle {
    return Intl.message(
      'Change password',
      name: 'changePasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Reset password`
  String get resetPasswordTitle {
    return Intl.message(
      'Reset password',
      name: 'resetPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Encryption keys`
  String get encryptionKeys {
    return Intl.message(
      'Encryption keys',
      name: 'encryptionKeys',
      desc: '',
      args: [],
    );
  }

  /// `We don't store this password, so if you forget, <underline>we cannot decrypt your data</underline>`
  String get passwordWarning {
    return Intl.message(
      'We don\'t store this password, so if you forget, <underline>we cannot decrypt your data</underline>',
      name: 'passwordWarning',
      desc: '',
      args: [],
    );
  }

  /// `Enter a password we can use to encrypt your data`
  String get enterPasswordToEncrypt {
    return Intl.message(
      'Enter a password we can use to encrypt your data',
      name: 'enterPasswordToEncrypt',
      desc: '',
      args: [],
    );
  }

  /// `Enter a new password we can use to encrypt your data`
  String get enterNewPasswordToEncrypt {
    return Intl.message(
      'Enter a new password we can use to encrypt your data',
      name: 'enterNewPasswordToEncrypt',
      desc: '',
      args: [],
    );
  }

  /// `Weak`
  String get weakStrength {
    return Intl.message(
      'Weak',
      name: 'weakStrength',
      desc: '',
      args: [],
    );
  }

  /// `Strong`
  String get strongStrength {
    return Intl.message(
      'Strong',
      name: 'strongStrength',
      desc: '',
      args: [],
    );
  }

  /// `Moderate`
  String get moderateStrength {
    return Intl.message(
      'Moderate',
      name: 'moderateStrength',
      desc: '',
      args: [],
    );
  }

  /// `Password strength: {passwordStrengthValue}`
  String passwordStrength(String passwordStrengthValue) {
    return Intl.message(
      'Password strength: $passwordStrengthValue',
      name: 'passwordStrength',
      desc: 'Text to indicate the password strength',
      args: [passwordStrengthValue],
    );
  }

  /// `Password changed successfully`
  String get passwordChangedSuccessfully {
    return Intl.message(
      'Password changed successfully',
      name: 'passwordChangedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Generating encryption keys...`
  String get generatingEncryptionKeys {
    return Intl.message(
      'Generating encryption keys...',
      name: 'generatingEncryptionKeys',
      desc: '',
      args: [],
    );
  }

  /// `Please wait...`
  String get pleaseWait {
    return Intl.message(
      'Please wait...',
      name: 'pleaseWait',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continueLabel {
    return Intl.message(
      'Continue',
      name: 'continueLabel',
      desc: '',
      args: [],
    );
  }

  /// `Insecure device`
  String get insecureDevice {
    return Intl.message(
      'Insecure device',
      name: 'insecureDevice',
      desc: '',
      args: [],
    );
  }

  /// `Sorry, we could not generate secure keys on this device.\n\nplease sign up from a different device.`
  String get sorryWeCouldNotGenerateSecureKeysOnThisDevicennplease {
    return Intl.message(
      'Sorry, we could not generate secure keys on this device.\n\nplease sign up from a different device.',
      name: 'sorryWeCouldNotGenerateSecureKeysOnThisDevicennplease',
      desc: '',
      args: [],
    );
  }

  /// `How it works`
  String get howItWorks {
    return Intl.message(
      'How it works',
      name: 'howItWorks',
      desc: '',
      args: [],
    );
  }

  /// `Encryption`
  String get encryption {
    return Intl.message(
      'Encryption',
      name: 'encryption',
      desc: '',
      args: [],
    );
  }

  /// `I understand that if I lose my password, I may lose my data since my data is <underline>end-to-end encrypted</underline>.`
  String get ackPasswordLostWarning {
    return Intl.message(
      'I understand that if I lose my password, I may lose my data since my data is <underline>end-to-end encrypted</underline>.',
      name: 'ackPasswordLostWarning',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicyTitle {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Terms`
  String get termsOfServicesTitle {
    return Intl.message(
      'Terms',
      name: 'termsOfServicesTitle',
      desc: '',
      args: [],
    );
  }

  /// `I agree to the <u-terms>terms of service</u-terms> and <u-policy>privacy policy</u-policy>`
  String get signUpTerms {
    return Intl.message(
      'I agree to the <u-terms>terms of service</u-terms> and <u-policy>privacy policy</u-policy>',
      name: 'signUpTerms',
      desc: '',
      args: [],
    );
  }

  /// `Log in`
  String get logInLabel {
    return Intl.message(
      'Log in',
      name: 'logInLabel',
      desc: '',
      args: [],
    );
  }

  /// `By clicking log in, I agree to the <u-terms>terms of service</u-terms> and <u-policy>privacy policy</u-policy>`
  String get loginTerms {
    return Intl.message(
      'By clicking log in, I agree to the <u-terms>terms of service</u-terms> and <u-policy>privacy policy</u-policy>',
      name: 'loginTerms',
      desc: '',
      args: [],
    );
  }

  /// `Change email`
  String get changeEmail {
    return Intl.message(
      'Change email',
      name: 'changeEmail',
      desc: '',
      args: [],
    );
  }

  /// `Enter your password`
  String get enterYourPassword {
    return Intl.message(
      'Enter your password',
      name: 'enterYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Welcome back!`
  String get welcomeBack {
    return Intl.message(
      'Welcome back!',
      name: 'welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `Contact support`
  String get contactSupport {
    return Intl.message(
      'Contact support',
      name: 'contactSupport',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect password`
  String get incorrectPasswordTitle {
    return Intl.message(
      'Incorrect password',
      name: 'incorrectPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Please try again`
  String get pleaseTryAgain {
    return Intl.message(
      'Please try again',
      name: 'pleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Recreate password`
  String get recreatePasswordTitle {
    return Intl.message(
      'Recreate password',
      name: 'recreatePasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Use recovery key`
  String get useRecoveryKey {
    return Intl.message(
      'Use recovery key',
      name: 'useRecoveryKey',
      desc: '',
      args: [],
    );
  }

  /// `The current device is not powerful enough to verify your password, but we can regenerate in a way that works with all devices.\n\nPlease login using your recovery key and regenerate your password (you can use the same one again if you wish).`
  String get recreatePasswordBody {
    return Intl.message(
      'The current device is not powerful enough to verify your password, but we can regenerate in a way that works with all devices.\n\nPlease login using your recovery key and regenerate your password (you can use the same one again if you wish).',
      name: 'recreatePasswordBody',
      desc: '',
      args: [],
    );
  }

  /// `Verify password`
  String get verifyPassword {
    return Intl.message(
      'Verify password',
      name: 'verifyPassword',
      desc: '',
      args: [],
    );
  }

  /// `Recovery key`
  String get recoveryKey {
    return Intl.message(
      'Recovery key',
      name: 'recoveryKey',
      desc: '',
      args: [],
    );
  }

  /// `If you forget your password, the only way you can recover your data is with this key.`
  String get recoveryKeyOnForgotPassword {
    return Intl.message(
      'If you forget your password, the only way you can recover your data is with this key.',
      name: 'recoveryKeyOnForgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `We don't store this key, please save this 24 word key in a safe place.`
  String get recoveryKeySaveDescription {
    return Intl.message(
      'We don\'t store this key, please save this 24 word key in a safe place.',
      name: 'recoveryKeySaveDescription',
      desc: '',
      args: [],
    );
  }

  /// `Do this later`
  String get doThisLater {
    return Intl.message(
      'Do this later',
      name: 'doThisLater',
      desc: '',
      args: [],
    );
  }

  /// `Save key`
  String get saveKey {
    return Intl.message(
      'Save key',
      name: 'saveKey',
      desc: '',
      args: [],
    );
  }

  /// `Recovery key copied to clipboard`
  String get recoveryKeyCopiedToClipboard {
    return Intl.message(
      'Recovery key copied to clipboard',
      name: 'recoveryKeyCopiedToClipboard',
      desc: '',
      args: [],
    );
  }

  /// `Recover account`
  String get recoverAccount {
    return Intl.message(
      'Recover account',
      name: 'recoverAccount',
      desc: '',
      args: [],
    );
  }

  /// `Recover`
  String get recover {
    return Intl.message(
      'Recover',
      name: 'recover',
      desc: '',
      args: [],
    );
  }

  /// `Please drop an email to {supportEmail} from your registered email address`
  String dropSupportEmail(String supportEmail) {
    return Intl.message(
      'Please drop an email to $supportEmail from your registered email address',
      name: 'dropSupportEmail',
      desc: '',
      args: [supportEmail],
    );
  }

  /// `Two-factor setup`
  String get twofactorSetup {
    return Intl.message(
      'Two-factor setup',
      name: 'twofactorSetup',
      desc: '',
      args: [],
    );
  }

  /// `Enter code`
  String get enterCode {
    return Intl.message(
      'Enter code',
      name: 'enterCode',
      desc: '',
      args: [],
    );
  }

  /// `Scan code`
  String get scanCode {
    return Intl.message(
      'Scan code',
      name: 'scanCode',
      desc: '',
      args: [],
    );
  }

  /// `Code copied to clipboard`
  String get codeCopiedToClipboard {
    return Intl.message(
      'Code copied to clipboard',
      name: 'codeCopiedToClipboard',
      desc: '',
      args: [],
    );
  }

  /// `Copy-paste this code\nto your authenticator app`
  String get copypasteThisCodentoYourAuthenticatorApp {
    return Intl.message(
      'Copy-paste this code\nto your authenticator app',
      name: 'copypasteThisCodentoYourAuthenticatorApp',
      desc: '',
      args: [],
    );
  }

  /// `tap to copy`
  String get tapToCopy {
    return Intl.message(
      'tap to copy',
      name: 'tapToCopy',
      desc: '',
      args: [],
    );
  }

  /// `Scan this barcode with\nyour authenticator app`
  String get scanThisBarcodeWithnyourAuthenticatorApp {
    return Intl.message(
      'Scan this barcode with\nyour authenticator app',
      name: 'scanThisBarcodeWithnyourAuthenticatorApp',
      desc: '',
      args: [],
    );
  }

  /// `Enter the 6-digit code from\nyour authenticator app`
  String get enterThe6digitCodeFromnyourAuthenticatorApp {
    return Intl.message(
      'Enter the 6-digit code from\nyour authenticator app',
      name: 'enterThe6digitCodeFromnyourAuthenticatorApp',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Setup complete`
  String get setupComplete {
    return Intl.message(
      'Setup complete',
      name: 'setupComplete',
      desc: '',
      args: [],
    );
  }

  /// `Save your recovery key if you haven't already`
  String get saveYourRecoveryKeyIfYouHaventAlready {
    return Intl.message(
      'Save your recovery key if you haven\'t already',
      name: 'saveYourRecoveryKeyIfYouHaventAlready',
      desc: '',
      args: [],
    );
  }

  /// `This can be used to recover your account if you lose your second factor`
  String get thisCanBeUsedToRecoverYourAccountIfYou {
    return Intl.message(
      'This can be used to recover your account if you lose your second factor',
      name: 'thisCanBeUsedToRecoverYourAccountIfYou',
      desc: '',
      args: [],
    );
  }

  /// `Two-factor authentication`
  String get twofactorAuthenticationPageTitle {
    return Intl.message(
      'Two-factor authentication',
      name: 'twofactorAuthenticationPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Lost device?`
  String get lostDevice {
    return Intl.message(
      'Lost device?',
      name: 'lostDevice',
      desc: '',
      args: [],
    );
  }

  /// `Verifying recovery key...`
  String get verifyingRecoveryKey {
    return Intl.message(
      'Verifying recovery key...',
      name: 'verifyingRecoveryKey',
      desc: '',
      args: [],
    );
  }

  /// `Recovery key verified`
  String get recoveryKeyVerified {
    return Intl.message(
      'Recovery key verified',
      name: 'recoveryKeyVerified',
      desc: '',
      args: [],
    );
  }

  /// `Great! Your recovery key is valid. Thank you for verifying.\n\nPlease remember to keep your recovery key safely backed up.`
  String get recoveryKeySuccessBody {
    return Intl.message(
      'Great! Your recovery key is valid. Thank you for verifying.\n\nPlease remember to keep your recovery key safely backed up.',
      name: 'recoveryKeySuccessBody',
      desc: '',
      args: [],
    );
  }

  /// `The recovery key you entered is not valid. Please make sure it contains 24 words, and check the spelling of each.\n\nIf you entered an older recovery code, make sure it is 64 characters long, and check each of them.`
  String get invalidRecoveryKey {
    return Intl.message(
      'The recovery key you entered is not valid. Please make sure it contains 24 words, and check the spelling of each.\n\nIf you entered an older recovery code, make sure it is 64 characters long, and check each of them.',
      name: 'invalidRecoveryKey',
      desc: '',
      args: [],
    );
  }

  /// `Invalid key`
  String get invalidKey {
    return Intl.message(
      'Invalid key',
      name: 'invalidKey',
      desc: '',
      args: [],
    );
  }

  /// `Try again`
  String get tryAgain {
    return Intl.message(
      'Try again',
      name: 'tryAgain',
      desc: '',
      args: [],
    );
  }

  /// `View recovery key`
  String get viewRecoveryKey {
    return Intl.message(
      'View recovery key',
      name: 'viewRecoveryKey',
      desc: '',
      args: [],
    );
  }

  /// `Confirm recovery key`
  String get confirmRecoveryKey {
    return Intl.message(
      'Confirm recovery key',
      name: 'confirmRecoveryKey',
      desc: '',
      args: [],
    );
  }

  /// `Your recovery key is the only way to recover your photos if you forget your password. You can find your recovery key in Settings > Account.\n\nPlease enter your recovery key here to verify that you have saved it correctly.`
  String get recoveryKeyVerifyReason {
    return Intl.message(
      'Your recovery key is the only way to recover your photos if you forget your password. You can find your recovery key in Settings > Account.\n\nPlease enter your recovery key here to verify that you have saved it correctly.',
      name: 'recoveryKeyVerifyReason',
      desc: '',
      args: [],
    );
  }

  /// `Confirm your recovery key`
  String get confirmYourRecoveryKey {
    return Intl.message(
      'Confirm your recovery key',
      name: 'confirmYourRecoveryKey',
      desc: '',
      args: [],
    );
  }

  /// `Add viewer`
  String get addViewer {
    return Intl.message(
      'Add viewer',
      name: 'addViewer',
      desc: '',
      args: [],
    );
  }

  /// `Add collaborator`
  String get addCollaborator {
    return Intl.message(
      'Add collaborator',
      name: 'addCollaborator',
      desc: '',
      args: [],
    );
  }

  /// `Add a new email`
  String get addANewEmail {
    return Intl.message(
      'Add a new email',
      name: 'addANewEmail',
      desc: '',
      args: [],
    );
  }

  /// `Or pick an existing one`
  String get orPickAnExistingOne {
    return Intl.message(
      'Or pick an existing one',
      name: 'orPickAnExistingOne',
      desc: '',
      args: [],
    );
  }

  /// `Collaborators can add photos and videos to the shared album.`
  String get collaboratorsCanAddPhotosAndVideosToTheSharedAlbum {
    return Intl.message(
      'Collaborators can add photos and videos to the shared album.',
      name: 'collaboratorsCanAddPhotosAndVideosToTheSharedAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Enter email`
  String get enterEmail {
    return Intl.message(
      'Enter email',
      name: 'enterEmail',
      desc: '',
      args: [],
    );
  }

  /// `Owner`
  String get albumOwner {
    return Intl.message(
      'Owner',
      name: 'albumOwner',
      desc: 'Role of the album owner',
      args: [],
    );
  }

  /// `You`
  String get you {
    return Intl.message(
      'You',
      name: 'you',
      desc: '',
      args: [],
    );
  }

  /// `Collaborator`
  String get collaborator {
    return Intl.message(
      'Collaborator',
      name: 'collaborator',
      desc: '',
      args: [],
    );
  }

  /// `Add more`
  String get addMore {
    return Intl.message(
      'Add more',
      name: 'addMore',
      desc: 'Button text to add more collaborators/viewers',
      args: [],
    );
  }

  /// `Viewer`
  String get viewer {
    return Intl.message(
      'Viewer',
      name: 'viewer',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message(
      'Remove',
      name: 'remove',
      desc: '',
      args: [],
    );
  }

  /// `Remove participant`
  String get removeParticipant {
    return Intl.message(
      'Remove participant',
      name: 'removeParticipant',
      desc: 'menuSectionTitle for removing a participant',
      args: [],
    );
  }

  /// `Manage`
  String get manage {
    return Intl.message(
      'Manage',
      name: 'manage',
      desc: '',
      args: [],
    );
  }

  /// `Added as`
  String get addedAs {
    return Intl.message(
      'Added as',
      name: 'addedAs',
      desc: '',
      args: [],
    );
  }

  /// `Change permissions?`
  String get changePermissions {
    return Intl.message(
      'Change permissions?',
      name: 'changePermissions',
      desc: '',
      args: [],
    );
  }

  /// `Yes, convert to viewer`
  String get yesConvertToViewer {
    return Intl.message(
      'Yes, convert to viewer',
      name: 'yesConvertToViewer',
      desc: '',
      args: [],
    );
  }

  /// `{user} will not be able to add more photos to this album\n\nThey will still be able to remove existing photos added by them`
  String cannotAddMorePhotosAfterBecomingViewer(Object user) {
    return Intl.message(
      '$user will not be able to add more photos to this album\n\nThey will still be able to remove existing photos added by them',
      name: 'cannotAddMorePhotosAfterBecomingViewer',
      desc: '',
      args: [user],
    );
  }

  /// `Allow adding photos`
  String get allowAddingPhotos {
    return Intl.message(
      'Allow adding photos',
      name: 'allowAddingPhotos',
      desc: 'Switch button to enable uploading photos to a public link',
      args: [],
    );
  }

  /// `Allow people with the link to also add photos to the shared album.`
  String get allowAddPhotosDescription {
    return Intl.message(
      'Allow people with the link to also add photos to the shared album.',
      name: 'allowAddPhotosDescription',
      desc: '',
      args: [],
    );
  }

  /// `Password lock`
  String get passwordLock {
    return Intl.message(
      'Password lock',
      name: 'passwordLock',
      desc: '',
      args: [],
    );
  }

  /// `Please note`
  String get disableDownloadWarningTitle {
    return Intl.message(
      'Please note',
      name: 'disableDownloadWarningTitle',
      desc: '',
      args: [],
    );
  }

  /// `Viewers can still take screenshots or save a copy of your photos using external tools`
  String get disableDownloadWarningBody {
    return Intl.message(
      'Viewers can still take screenshots or save a copy of your photos using external tools',
      name: 'disableDownloadWarningBody',
      desc: '',
      args: [],
    );
  }

  /// `Allow downloads`
  String get allowDownloads {
    return Intl.message(
      'Allow downloads',
      name: 'allowDownloads',
      desc: '',
      args: [],
    );
  }

  /// `Device limit`
  String get linkDeviceLimit {
    return Intl.message(
      'Device limit',
      name: 'linkDeviceLimit',
      desc: '',
      args: [],
    );
  }

  /// `Link expiry`
  String get linkExpiry {
    return Intl.message(
      'Link expiry',
      name: 'linkExpiry',
      desc: '',
      args: [],
    );
  }

  /// `Expired`
  String get linkExpired {
    return Intl.message(
      'Expired',
      name: 'linkExpired',
      desc: '',
      args: [],
    );
  }

  /// `Enabled`
  String get linkEnabled {
    return Intl.message(
      'Enabled',
      name: 'linkEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Never`
  String get linkNeverExpires {
    return Intl.message(
      'Never',
      name: 'linkNeverExpires',
      desc: '',
      args: [],
    );
  }

  /// `This link has expired. Please select a new expiry time or disable link expiry.`
  String get expiredLinkInfo {
    return Intl.message(
      'This link has expired. Please select a new expiry time or disable link expiry.',
      name: 'expiredLinkInfo',
      desc: '',
      args: [],
    );
  }

  /// `Set a password`
  String get setAPassword {
    return Intl.message(
      'Set a password',
      name: 'setAPassword',
      desc: '',
      args: [],
    );
  }

  /// `Lock`
  String get lockButtonLabel {
    return Intl.message(
      'Lock',
      name: 'lockButtonLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter password`
  String get enterPassword {
    return Intl.message(
      'Enter password',
      name: 'enterPassword',
      desc: '',
      args: [],
    );
  }

  /// `Remove link`
  String get removeLink {
    return Intl.message(
      'Remove link',
      name: 'removeLink',
      desc: '',
      args: [],
    );
  }

  /// `Manage link`
  String get manageLink {
    return Intl.message(
      'Manage link',
      name: 'manageLink',
      desc: '',
      args: [],
    );
  }

  /// `Link will expire on {expiryTime}`
  String linkExpiresOn(Object expiryTime) {
    return Intl.message(
      'Link will expire on $expiryTime',
      name: 'linkExpiresOn',
      desc: '',
      args: [expiryTime],
    );
  }

  /// `Album updated`
  String get albumUpdated {
    return Intl.message(
      'Album updated',
      name: 'albumUpdated',
      desc: '',
      args: [],
    );
  }

  /// `When set to the maximum ({maxValue}), the device limit will be relaxed to allow for temporary spikes of large number of viewers.`
  String maxDeviceLimitSpikeHandling(int maxValue) {
    return Intl.message(
      'When set to the maximum ($maxValue), the device limit will be relaxed to allow for temporary spikes of large number of viewers.',
      name: 'maxDeviceLimitSpikeHandling',
      desc: '',
      args: [maxValue],
    );
  }

  /// `Never`
  String get never {
    return Intl.message(
      'Never',
      name: 'never',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get custom {
    return Intl.message(
      'Custom',
      name: 'custom',
      desc: 'Label for setting custom value for link expiry',
      args: [],
    );
  }

  /// `After 1 hour`
  String get after1Hour {
    return Intl.message(
      'After 1 hour',
      name: 'after1Hour',
      desc: '',
      args: [],
    );
  }

  /// `After 1 day`
  String get after1Day {
    return Intl.message(
      'After 1 day',
      name: 'after1Day',
      desc: '',
      args: [],
    );
  }

  /// `After 1 week`
  String get after1Week {
    return Intl.message(
      'After 1 week',
      name: 'after1Week',
      desc: '',
      args: [],
    );
  }

  /// `After 1 month`
  String get after1Month {
    return Intl.message(
      'After 1 month',
      name: 'after1Month',
      desc: '',
      args: [],
    );
  }

  /// `After 1 year`
  String get after1Year {
    return Intl.message(
      'After 1 year',
      name: 'after1Year',
      desc: '',
      args: [],
    );
  }

  /// `Manage`
  String get manageParticipants {
    return Intl.message(
      'Manage',
      name: 'manageParticipants',
      desc: '',
      args: [],
    );
  }

  /// `Create a link to allow people to add and view photos in your shared album without needing an ente app or account. Great for collecting event photos.`
  String get collabLinkSectionDescription {
    return Intl.message(
      'Create a link to allow people to add and view photos in your shared album without needing an ente app or account. Great for collecting event photos.',
      name: 'collabLinkSectionDescription',
      desc: '',
      args: [],
    );
  }

  /// `Collect photos`
  String get collectPhotos {
    return Intl.message(
      'Collect photos',
      name: 'collectPhotos',
      desc: '',
      args: [],
    );
  }

  /// `Collaborative link`
  String get collaborativeLink {
    return Intl.message(
      'Collaborative link',
      name: 'collaborativeLink',
      desc: '',
      args: [],
    );
  }

  /// `Share with non-ente users`
  String get shareWithNonenteUsers {
    return Intl.message(
      'Share with non-ente users',
      name: 'shareWithNonenteUsers',
      desc: '',
      args: [],
    );
  }

  /// `Create public link`
  String get createPublicLink {
    return Intl.message(
      'Create public link',
      name: 'createPublicLink',
      desc: '',
      args: [],
    );
  }

  /// `Send link`
  String get sendLink {
    return Intl.message(
      'Send link',
      name: 'sendLink',
      desc: '',
      args: [],
    );
  }

  /// `Copy link`
  String get copyLink {
    return Intl.message(
      'Copy link',
      name: 'copyLink',
      desc: '',
      args: [],
    );
  }

  /// `Link has expired`
  String get linkHasExpired {
    return Intl.message(
      'Link has expired',
      name: 'linkHasExpired',
      desc: '',
      args: [],
    );
  }

  /// `Public link enabled`
  String get publicLinkEnabled {
    return Intl.message(
      'Public link enabled',
      name: 'publicLinkEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Share a link`
  String get shareALink {
    return Intl.message(
      'Share a link',
      name: 'shareALink',
      desc: '',
      args: [],
    );
  }

  /// `Create shared and collaborative albums with other ente users, including users on free plans.`
  String get sharedAlbumSectionDescription {
    return Intl.message(
      'Create shared and collaborative albums with other ente users, including users on free plans.',
      name: 'sharedAlbumSectionDescription',
      desc: '',
      args: [],
    );
  }

  /// `{numberOfPeople, plural, =0 {Share with specific people} =1 {Shared with 1 person} other {Shared with {numberOfPeople} people}}`
  String shareWithPeopleSectionTitle(int numberOfPeople) {
    return Intl.plural(
      numberOfPeople,
      zero: 'Share with specific people',
      one: 'Shared with 1 person',
      other: 'Shared with $numberOfPeople people',
      name: 'shareWithPeopleSectionTitle',
      desc: '',
      args: [numberOfPeople],
    );
  }

  /// `This is your Verification ID`
  String get thisIsYourVerificationId {
    return Intl.message(
      'This is your Verification ID',
      name: 'thisIsYourVerificationId',
      desc: '',
      args: [],
    );
  }

  /// `Someone sharing albums with you should see the same ID on their device.`
  String get someoneSharingAlbumsWithYouShouldSeeTheSameId {
    return Intl.message(
      'Someone sharing albums with you should see the same ID on their device.',
      name: 'someoneSharingAlbumsWithYouShouldSeeTheSameId',
      desc: '',
      args: [],
    );
  }

  /// `Please ask them to long-press their email address on the settings screen, and verify that the IDs on both devices match.`
  String get howToViewShareeVerificationID {
    return Intl.message(
      'Please ask them to long-press their email address on the settings screen, and verify that the IDs on both devices match.',
      name: 'howToViewShareeVerificationID',
      desc: '',
      args: [],
    );
  }

  /// `This is {email}'s Verification ID`
  String thisIsPersonVerificationId(String email) {
    return Intl.message(
      'This is $email\'s Verification ID',
      name: 'thisIsPersonVerificationId',
      desc: '',
      args: [email],
    );
  }

  /// `Verification ID`
  String get verificationId {
    return Intl.message(
      'Verification ID',
      name: 'verificationId',
      desc: '',
      args: [],
    );
  }

  /// `Verify {email}`
  String verifyEmailID(Object email) {
    return Intl.message(
      'Verify $email',
      name: 'verifyEmailID',
      desc: '',
      args: [email],
    );
  }

  /// `{email} does not have an ente account.\n\nSend them an invite to share photos.`
  String emailNoEnteAccount(Object email) {
    return Intl.message(
      '$email does not have an ente account.\n\nSend them an invite to share photos.',
      name: 'emailNoEnteAccount',
      desc: '',
      args: [email],
    );
  }

  /// `Here's my verification ID: {verificationID} for ente.io.`
  String shareMyVerificationID(Object verificationID) {
    return Intl.message(
      'Here\'s my verification ID: $verificationID for ente.io.',
      name: 'shareMyVerificationID',
      desc: '',
      args: [verificationID],
    );
  }

  /// `Hey, can you confirm that this is your ente.io verification ID: {verificationID}`
  String shareTextConfirmOthersVerificationID(Object verificationID) {
    return Intl.message(
      'Hey, can you confirm that this is your ente.io verification ID: $verificationID',
      name: 'shareTextConfirmOthersVerificationID',
      desc: '',
      args: [verificationID],
    );
  }

  /// `Something went wrong`
  String get somethingWentWrong {
    return Intl.message(
      'Something went wrong',
      name: 'somethingWentWrong',
      desc: '',
      args: [],
    );
  }

  /// `Send invite`
  String get sendInvite {
    return Intl.message(
      'Send invite',
      name: 'sendInvite',
      desc: '',
      args: [],
    );
  }

  /// `Download ente so we can easily share original quality photos and videos\n\nhttps://ente.io/#download`
  String get shareTextRecommendUsingEnte {
    return Intl.message(
      'Download ente so we can easily share original quality photos and videos\n\nhttps://ente.io/#download',
      name: 'shareTextRecommendUsingEnte',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message(
      'Done',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `Apply code`
  String get applyCodeTitle {
    return Intl.message(
      'Apply code',
      name: 'applyCodeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter the code provided by your friend to claim free storage for both of you`
  String get enterCodeDescription {
    return Intl.message(
      'Enter the code provided by your friend to claim free storage for both of you',
      name: 'enterCodeDescription',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get apply {
    return Intl.message(
      'Apply',
      name: 'apply',
      desc: '',
      args: [],
    );
  }

  /// `Failed to apply code`
  String get failedToApplyCode {
    return Intl.message(
      'Failed to apply code',
      name: 'failedToApplyCode',
      desc: '',
      args: [],
    );
  }

  /// `Enter referral code`
  String get enterReferralCode {
    return Intl.message(
      'Enter referral code',
      name: 'enterReferralCode',
      desc: '',
      args: [],
    );
  }

  /// `Code applied`
  String get codeAppliedPageTitle {
    return Intl.message(
      'Code applied',
      name: 'codeAppliedPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `{storageAmountInGB} GB`
  String storageInGB(Object storageAmountInGB) {
    return Intl.message(
      '$storageAmountInGB GB',
      name: 'storageInGB',
      desc: '',
      args: [storageAmountInGB],
    );
  }

  /// `Claimed`
  String get claimed {
    return Intl.message(
      'Claimed',
      name: 'claimed',
      desc: 'Used to indicate storage claimed, like 10GB Claimed',
      args: [],
    );
  }

  /// `Details`
  String get details {
    return Intl.message(
      'Details',
      name: 'details',
      desc: '',
      args: [],
    );
  }

  /// `Claim more!`
  String get claimMore {
    return Intl.message(
      'Claim more!',
      name: 'claimMore',
      desc: '',
      args: [],
    );
  }

  /// `They also get {storageAmountInGB} GB`
  String theyAlsoGetXGb(Object storageAmountInGB) {
    return Intl.message(
      'They also get $storageAmountInGB GB',
      name: 'theyAlsoGetXGb',
      desc: '',
      args: [storageAmountInGB],
    );
  }

  /// `{storageAmountInGB} GB each time someone signs up for a paid plan and applies your code`
  String freeStorageOnReferralSuccess(Object storageAmountInGB) {
    return Intl.message(
      '$storageAmountInGB GB each time someone signs up for a paid plan and applies your code',
      name: 'freeStorageOnReferralSuccess',
      desc: '',
      args: [storageAmountInGB],
    );
  }

  /// `ente referral code: {referralCode} \n\nApply it in Settings → General → Referrals to get {referralStorageInGB} GB free after you signup for a paid plan\n\nhttps://ente.io`
  String shareTextReferralCode(
      Object referralCode, Object referralStorageInGB) {
    return Intl.message(
      'ente referral code: $referralCode \n\nApply it in Settings → General → Referrals to get $referralStorageInGB GB free after you signup for a paid plan\n\nhttps://ente.io',
      name: 'shareTextReferralCode',
      desc: '',
      args: [referralCode, referralStorageInGB],
    );
  }

  /// `Claim free storage`
  String get claimFreeStorage {
    return Intl.message(
      'Claim free storage',
      name: 'claimFreeStorage',
      desc: '',
      args: [],
    );
  }

  /// `Invite your friends`
  String get inviteYourFriends {
    return Intl.message(
      'Invite your friends',
      name: 'inviteYourFriends',
      desc: '',
      args: [],
    );
  }

  /// `Unable to fetch referral details. Please try again later.`
  String get failedToFetchReferralDetails {
    return Intl.message(
      'Unable to fetch referral details. Please try again later.',
      name: 'failedToFetchReferralDetails',
      desc: '',
      args: [],
    );
  }

  /// `1. Give this code to your friends`
  String get referralStep1 {
    return Intl.message(
      '1. Give this code to your friends',
      name: 'referralStep1',
      desc: '',
      args: [],
    );
  }

  /// `2. They sign up for a paid plan`
  String get referralStep2 {
    return Intl.message(
      '2. They sign up for a paid plan',
      name: 'referralStep2',
      desc: '',
      args: [],
    );
  }

  /// `3. Both of you get {storageInGB} GB* free`
  String referralStep3(Object storageInGB) {
    return Intl.message(
      '3. Both of you get $storageInGB GB* free',
      name: 'referralStep3',
      desc: '',
      args: [storageInGB],
    );
  }

  /// `Referrals are currently paused`
  String get referralsAreCurrentlyPaused {
    return Intl.message(
      'Referrals are currently paused',
      name: 'referralsAreCurrentlyPaused',
      desc: '',
      args: [],
    );
  }

  /// `* You can at max double your storage`
  String get youCanAtMaxDoubleYourStorage {
    return Intl.message(
      '* You can at max double your storage',
      name: 'youCanAtMaxDoubleYourStorage',
      desc: '',
      args: [],
    );
  }

  /// `{isFamilyMember, select, true {Your family has claimed {storageAmountInGb} Gb so far} false {You have claimed {storageAmountInGb} Gb so far} other {You have claimed {storageAmountInGb} Gb so far!}}`
  String claimedStorageSoFar(String isFamilyMember, int storageAmountInGb) {
    return Intl.select(
      isFamilyMember,
      {
        'true': 'Your family has claimed $storageAmountInGb Gb so far',
        'false': 'You have claimed $storageAmountInGb Gb so far',
        'other': 'You have claimed $storageAmountInGb Gb so far!',
      },
      name: 'claimedStorageSoFar',
      desc: '',
      args: [isFamilyMember, storageAmountInGb],
    );
  }

  /// `FAQ`
  String get faq {
    return Intl.message(
      'FAQ',
      name: 'faq',
      desc: '',
      args: [],
    );
  }

  /// `Oops, something went wrong`
  String get oopsSomethingWentWrong {
    return Intl.message(
      'Oops, something went wrong',
      name: 'oopsSomethingWentWrong',
      desc: '',
      args: [],
    );
  }

  /// `People using your code`
  String get peopleUsingYourCode {
    return Intl.message(
      'People using your code',
      name: 'peopleUsingYourCode',
      desc: '',
      args: [],
    );
  }

  /// `eligible`
  String get eligible {
    return Intl.message(
      'eligible',
      name: 'eligible',
      desc: '',
      args: [],
    );
  }

  /// `total`
  String get total {
    return Intl.message(
      'total',
      name: 'total',
      desc: '',
      args: [],
    );
  }

  /// `Code used by you`
  String get codeUsedByYou {
    return Intl.message(
      'Code used by you',
      name: 'codeUsedByYou',
      desc: '',
      args: [],
    );
  }

  /// `Free storage claimed`
  String get freeStorageClaimed {
    return Intl.message(
      'Free storage claimed',
      name: 'freeStorageClaimed',
      desc: '',
      args: [],
    );
  }

  /// `Free storage usable`
  String get freeStorageUsable {
    return Intl.message(
      'Free storage usable',
      name: 'freeStorageUsable',
      desc: '',
      args: [],
    );
  }

  /// `Usable storage is limited by your current plan. Excess claimed storage will automatically become usable when you upgrade your plan.`
  String get usableReferralStorageInfo {
    return Intl.message(
      'Usable storage is limited by your current plan. Excess claimed storage will automatically become usable when you upgrade your plan.',
      name: 'usableReferralStorageInfo',
      desc: '',
      args: [],
    );
  }

  /// `Remove from album?`
  String get removeFromAlbumTitle {
    return Intl.message(
      'Remove from album?',
      name: 'removeFromAlbumTitle',
      desc: '',
      args: [],
    );
  }

  /// `Remove from album`
  String get removeFromAlbum {
    return Intl.message(
      'Remove from album',
      name: 'removeFromAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Selected items will be removed from this album`
  String get itemsWillBeRemovedFromAlbum {
    return Intl.message(
      'Selected items will be removed from this album',
      name: 'itemsWillBeRemovedFromAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Some of the items you are removing were added by other people, and you will lose access to them`
  String get removeShareItemsWarning {
    return Intl.message(
      'Some of the items you are removing were added by other people, and you will lose access to them',
      name: 'removeShareItemsWarning',
      desc: '',
      args: [],
    );
  }

  /// `Adding to favorites...`
  String get addingToFavorites {
    return Intl.message(
      'Adding to favorites...',
      name: 'addingToFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Removing from favorites...`
  String get removingFromFavorites {
    return Intl.message(
      'Removing from favorites...',
      name: 'removingFromFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Sorry, could not add to favorites!`
  String get sorryCouldNotAddToFavorites {
    return Intl.message(
      'Sorry, could not add to favorites!',
      name: 'sorryCouldNotAddToFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Sorry, could not remove from favorites!`
  String get sorryCouldNotRemoveFromFavorites {
    return Intl.message(
      'Sorry, could not remove from favorites!',
      name: 'sorryCouldNotRemoveFromFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Looks like your subscription has expired. Please subscribe to enable sharing.`
  String get subscribeToEnableSharing {
    return Intl.message(
      'Looks like your subscription has expired. Please subscribe to enable sharing.',
      name: 'subscribeToEnableSharing',
      desc: '',
      args: [],
    );
  }

  /// `Subscribe`
  String get subscribe {
    return Intl.message(
      'Subscribe',
      name: 'subscribe',
      desc: '',
      args: [],
    );
  }

  /// `Can only remove files owned by you`
  String get canOnlyRemoveFilesOwnedByYou {
    return Intl.message(
      'Can only remove files owned by you',
      name: 'canOnlyRemoveFilesOwnedByYou',
      desc: '',
      args: [],
    );
  }

  /// `Delete shared album?`
  String get deleteSharedAlbum {
    return Intl.message(
      'Delete shared album?',
      name: 'deleteSharedAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Delete album`
  String get deleteAlbum {
    return Intl.message(
      'Delete album',
      name: 'deleteAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Also delete the photos (and videos) present in this album from <bold>all</bold> other albums they are part of?`
  String get deleteAlbumDialog {
    return Intl.message(
      'Also delete the photos (and videos) present in this album from <bold>all</bold> other albums they are part of?',
      name: 'deleteAlbumDialog',
      desc: '',
      args: [],
    );
  }

  /// `The album will be deleted for everyone\n\nYou will lose access to shared photos in this album that are owned by others`
  String get deleteSharedAlbumDialogBody {
    return Intl.message(
      'The album will be deleted for everyone\n\nYou will lose access to shared photos in this album that are owned by others',
      name: 'deleteSharedAlbumDialogBody',
      desc: '',
      args: [],
    );
  }

  /// `Yes, remove`
  String get yesRemove {
    return Intl.message(
      'Yes, remove',
      name: 'yesRemove',
      desc: '',
      args: [],
    );
  }

  /// `Creating link...`
  String get creatingLink {
    return Intl.message(
      'Creating link...',
      name: 'creatingLink',
      desc: '',
      args: [],
    );
  }

  /// `Remove?`
  String get removeWithQuestionMark {
    return Intl.message(
      'Remove?',
      name: 'removeWithQuestionMark',
      desc: '',
      args: [],
    );
  }

  /// `{userEmail} will be removed from this shared album\n\nAny photos added by them will also be removed from the album`
  String removeParticipantBody(Object userEmail) {
    return Intl.message(
      '$userEmail will be removed from this shared album\n\nAny photos added by them will also be removed from the album',
      name: 'removeParticipantBody',
      desc: '',
      args: [userEmail],
    );
  }

  /// `Keep Photos`
  String get keepPhotos {
    return Intl.message(
      'Keep Photos',
      name: 'keepPhotos',
      desc: '',
      args: [],
    );
  }

  /// `Delete photos`
  String get deletePhotos {
    return Intl.message(
      'Delete photos',
      name: 'deletePhotos',
      desc: '',
      args: [],
    );
  }

  /// `Invite to ente`
  String get inviteToEnte {
    return Intl.message(
      'Invite to ente',
      name: 'inviteToEnte',
      desc: '',
      args: [],
    );
  }

  /// `Remove public link`
  String get removePublicLink {
    return Intl.message(
      'Remove public link',
      name: 'removePublicLink',
      desc: '',
      args: [],
    );
  }

  /// `This will remove the public link for accessing "{albumName}".`
  String disableLinkMessage(Object albumName) {
    return Intl.message(
      'This will remove the public link for accessing "$albumName".',
      name: 'disableLinkMessage',
      desc: '',
      args: [albumName],
    );
  }

  /// `Sharing...`
  String get sharing {
    return Intl.message(
      'Sharing...',
      name: 'sharing',
      desc: '',
      args: [],
    );
  }

  /// `You cannot share with yourself`
  String get youCannotShareWithYourself {
    return Intl.message(
      'You cannot share with yourself',
      name: 'youCannotShareWithYourself',
      desc: '',
      args: [],
    );
  }

  /// `Archive`
  String get archive {
    return Intl.message(
      'Archive',
      name: 'archive',
      desc: '',
      args: [],
    );
  }

  /// `Long press to select photos and click + to create an album`
  String get createAlbumActionHint {
    return Intl.message(
      'Long press to select photos and click + to create an album',
      name: 'createAlbumActionHint',
      desc: '',
      args: [],
    );
  }

  /// `Importing....`
  String get importing {
    return Intl.message(
      'Importing....',
      name: 'importing',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load albums`
  String get failedToLoadAlbums {
    return Intl.message(
      'Failed to load albums',
      name: 'failedToLoadAlbums',
      desc: '',
      args: [],
    );
  }

  /// `Hidden`
  String get hidden {
    return Intl.message(
      'Hidden',
      name: 'hidden',
      desc: '',
      args: [],
    );
  }

  /// `Please authenticate to view your hidden files`
  String get authToViewYourHiddenFiles {
    return Intl.message(
      'Please authenticate to view your hidden files',
      name: 'authToViewYourHiddenFiles',
      desc: '',
      args: [],
    );
  }

  /// `Trash`
  String get trash {
    return Intl.message(
      'Trash',
      name: 'trash',
      desc: '',
      args: [],
    );
  }

  /// `Uncategorized`
  String get uncategorized {
    return Intl.message(
      'Uncategorized',
      name: 'uncategorized',
      desc: '',
      args: [],
    );
  }

  /// `video`
  String get videoSmallCase {
    return Intl.message(
      'video',
      name: 'videoSmallCase',
      desc: '',
      args: [],
    );
  }

  /// `photo`
  String get photoSmallCase {
    return Intl.message(
      'photo',
      name: 'photoSmallCase',
      desc: '',
      args: [],
    );
  }

  /// `It will be deleted from all albums.`
  String get singleFileDeleteHighlight {
    return Intl.message(
      'It will be deleted from all albums.',
      name: 'singleFileDeleteHighlight',
      desc: '',
      args: [],
    );
  }

  /// `This {fileType} is in both ente and your device.`
  String singleFileInBothLocalAndRemote(Object fileType) {
    return Intl.message(
      'This $fileType is in both ente and your device.',
      name: 'singleFileInBothLocalAndRemote',
      desc: '',
      args: [fileType],
    );
  }

  /// `This {fileType} will be deleted from ente.`
  String singleFileInRemoteOnly(Object fileType) {
    return Intl.message(
      'This $fileType will be deleted from ente.',
      name: 'singleFileInRemoteOnly',
      desc: '',
      args: [fileType],
    );
  }

  /// `This {fileType} will be deleted from your device.`
  String singleFileDeleteFromDevice(Object fileType) {
    return Intl.message(
      'This $fileType will be deleted from your device.',
      name: 'singleFileDeleteFromDevice',
      desc: '',
      args: [fileType],
    );
  }

  /// `Delete from ente`
  String get deleteFromEnte {
    return Intl.message(
      'Delete from ente',
      name: 'deleteFromEnte',
      desc: '',
      args: [],
    );
  }

  /// `Yes, delete`
  String get yesDelete {
    return Intl.message(
      'Yes, delete',
      name: 'yesDelete',
      desc: '',
      args: [],
    );
  }

  /// `Moved to trash`
  String get movedToTrash {
    return Intl.message(
      'Moved to trash',
      name: 'movedToTrash',
      desc: '',
      args: [],
    );
  }

  /// `Delete from device`
  String get deleteFromDevice {
    return Intl.message(
      'Delete from device',
      name: 'deleteFromDevice',
      desc: '',
      args: [],
    );
  }

  /// `Delete from both`
  String get deleteFromBoth {
    return Intl.message(
      'Delete from both',
      name: 'deleteFromBoth',
      desc: '',
      args: [],
    );
  }

  /// `New album`
  String get newAlbum {
    return Intl.message(
      'New album',
      name: 'newAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Albums`
  String get albums {
    return Intl.message(
      'Albums',
      name: 'albums',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, zero{no memories} one{{count} memory} other{{count} memories}}`
  String memoryCount(int count) {
    return Intl.plural(
      count,
      zero: 'no memories',
      one: '$count memory',
      other: '$count memories',
      name: 'memoryCount',
      desc: 'The text to display the number of memories',
      args: [count],
    );
  }

  /// `{count} selected`
  String selectedPhotos(int count) {
    return Intl.message(
      '$count selected',
      name: 'selectedPhotos',
      desc: 'Display the number of selected photos',
      args: [count],
    );
  }

  /// `{count} selected ({yourCount} yours)`
  String selectedPhotosWithYours(int count, int yourCount) {
    return Intl.message(
      '$count selected ($yourCount yours)',
      name: 'selectedPhotosWithYours',
      desc:
          'Display the number of selected photos, including the number of selected photos owned by the user',
      args: [count, yourCount],
    );
  }

  /// `Advanced`
  String get advancedSettings {
    return Intl.message(
      'Advanced',
      name: 'advancedSettings',
      desc: 'The text to display in the advanced settings section',
      args: [],
    );
  }

  /// `Photo grid size`
  String get photoGridSize {
    return Intl.message(
      'Photo grid size',
      name: 'photoGridSize',
      desc: '',
      args: [],
    );
  }

  /// `Manage device storage`
  String get manageDeviceStorage {
    return Intl.message(
      'Manage device storage',
      name: 'manageDeviceStorage',
      desc: '',
      args: [],
    );
  }

  /// `Select folders for backup`
  String get selectFoldersForBackup {
    return Intl.message(
      'Select folders for backup',
      name: 'selectFoldersForBackup',
      desc: '',
      args: [],
    );
  }

  /// `Selected folders will be encrypted and backed up`
  String get selectedFoldersWillBeEncryptedAndBackedUp {
    return Intl.message(
      'Selected folders will be encrypted and backed up',
      name: 'selectedFoldersWillBeEncryptedAndBackedUp',
      desc: '',
      args: [],
    );
  }

  /// `Unselect all`
  String get unselectAll {
    return Intl.message(
      'Unselect all',
      name: 'unselectAll',
      desc: '',
      args: [],
    );
  }

  /// `Select all`
  String get selectAll {
    return Intl.message(
      'Select all',
      name: 'selectAll',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get skip {
    return Intl.message(
      'Skip',
      name: 'skip',
      desc: '',
      args: [],
    );
  }

  /// `Updating folder selection...`
  String get updatingFolderSelection {
    return Intl.message(
      'Updating folder selection...',
      name: 'updatingFolderSelection',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{{count} item} other{{count} items}}`
  String itemCount(num count) {
    return Intl.plural(
      count,
      one: '$count item',
      other: '$count items',
      name: 'itemCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{{count} year ago} other{{count} years ago}}`
  String yearsAgo(num count) {
    return Intl.plural(
      count,
      one: '$count year ago',
      other: '$count years ago',
      name: 'yearsAgo',
      desc: '',
      args: [count],
    );
  }

  /// `Backup settings`
  String get backupSettings {
    return Intl.message(
      'Backup settings',
      name: 'backupSettings',
      desc: '',
      args: [],
    );
  }

  /// `Backup over mobile data`
  String get backupOverMobileData {
    return Intl.message(
      'Backup over mobile data',
      name: 'backupOverMobileData',
      desc: '',
      args: [],
    );
  }

  /// `Backup videos`
  String get backupVideos {
    return Intl.message(
      'Backup videos',
      name: 'backupVideos',
      desc: '',
      args: [],
    );
  }

  /// `Disable auto lock`
  String get disableAutoLock {
    return Intl.message(
      'Disable auto lock',
      name: 'disableAutoLock',
      desc: '',
      args: [],
    );
  }

  /// `Disable the device screen lock when ente is in the foreground and there is a backup in progress. This is normally not needed, but may help big uploads and initial imports of large libraries complete faster.`
  String get deviceLockExplanation {
    return Intl.message(
      'Disable the device screen lock when ente is in the foreground and there is a backup in progress. This is normally not needed, but may help big uploads and initial imports of large libraries complete faster.',
      name: 'deviceLockExplanation',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `We are open source!`
  String get weAreOpenSource {
    return Intl.message(
      'We are open source!',
      name: 'weAreOpenSource',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get privacy {
    return Intl.message(
      'Privacy',
      name: 'privacy',
      desc: '',
      args: [],
    );
  }

  /// `Terms`
  String get terms {
    return Intl.message(
      'Terms',
      name: 'terms',
      desc: '',
      args: [],
    );
  }

  /// `Check for updates`
  String get checkForUpdates {
    return Intl.message(
      'Check for updates',
      name: 'checkForUpdates',
      desc: '',
      args: [],
    );
  }

  /// `Checking...`
  String get checking {
    return Intl.message(
      'Checking...',
      name: 'checking',
      desc: '',
      args: [],
    );
  }

  /// `You are on the latest version`
  String get youAreOnTheLatestVersion {
    return Intl.message(
      'You are on the latest version',
      name: 'youAreOnTheLatestVersion',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get account {
    return Intl.message(
      'Account',
      name: 'account',
      desc: '',
      args: [],
    );
  }

  /// `Manage subscription`
  String get manageSubscription {
    return Intl.message(
      'Manage subscription',
      name: 'manageSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Please authenticate to change your email`
  String get authToChangeYourEmail {
    return Intl.message(
      'Please authenticate to change your email',
      name: 'authToChangeYourEmail',
      desc: '',
      args: [],
    );
  }

  /// `Change password`
  String get changePassword {
    return Intl.message(
      'Change password',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `Please authenticate to change your password`
  String get authToChangeYourPassword {
    return Intl.message(
      'Please authenticate to change your password',
      name: 'authToChangeYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Export your data`
  String get exportYourData {
    return Intl.message(
      'Export your data',
      name: 'exportYourData',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Please authenticate to initiate account deletion`
  String get authToInitiateAccountDeletion {
    return Intl.message(
      'Please authenticate to initiate account deletion',
      name: 'authToInitiateAccountDeletion',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout?`
  String get areYouSureYouWantToLogout {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'areYouSureYouWantToLogout',
      desc: '',
      args: [],
    );
  }

  /// `Yes, logout`
  String get yesLogout {
    return Intl.message(
      'Yes, logout',
      name: 'yesLogout',
      desc: '',
      args: [],
    );
  }

  /// `A new version of ente is available.`
  String get aNewVersionOfEnteIsAvailable {
    return Intl.message(
      'A new version of ente is available.',
      name: 'aNewVersionOfEnteIsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  /// `Install manually`
  String get installManually {
    return Intl.message(
      'Install manually',
      name: 'installManually',
      desc: '',
      args: [],
    );
  }

  /// `Critical update available`
  String get criticalUpdateAvailable {
    return Intl.message(
      'Critical update available',
      name: 'criticalUpdateAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Update available`
  String get updateAvailable {
    return Intl.message(
      'Update available',
      name: 'updateAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Downloading...`
  String get downloading {
    return Intl.message(
      'Downloading...',
      name: 'downloading',
      desc: '',
      args: [],
    );
  }

  /// `The download could not be completed`
  String get theDownloadCouldNotBeCompleted {
    return Intl.message(
      'The download could not be completed',
      name: 'theDownloadCouldNotBeCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `Backed up folders`
  String get backedUpFolders {
    return Intl.message(
      'Backed up folders',
      name: 'backedUpFolders',
      desc: '',
      args: [],
    );
  }

  /// `Backup`
  String get backup {
    return Intl.message(
      'Backup',
      name: 'backup',
      desc: '',
      args: [],
    );
  }

  /// `Free up device space`
  String get freeUpDeviceSpace {
    return Intl.message(
      'Free up device space',
      name: 'freeUpDeviceSpace',
      desc: '',
      args: [],
    );
  }

  /// `✨ All clear`
  String get allClear {
    return Intl.message(
      '✨ All clear',
      name: 'allClear',
      desc: '',
      args: [],
    );
  }

  /// `You've no files on this device that can be deleted`
  String get noDeviceThatCanBeDeleted {
    return Intl.message(
      'You\'ve no files on this device that can be deleted',
      name: 'noDeviceThatCanBeDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Remove duplicates`
  String get removeDuplicates {
    return Intl.message(
      'Remove duplicates',
      name: 'removeDuplicates',
      desc: '',
      args: [],
    );
  }

  /// `✨ No duplicates`
  String get noDuplicates {
    return Intl.message(
      '✨ No duplicates',
      name: 'noDuplicates',
      desc: '',
      args: [],
    );
  }

  /// `You've no duplicate files that can be cleared`
  String get youveNoDuplicateFilesThatCanBeCleared {
    return Intl.message(
      'You\'ve no duplicate files that can be cleared',
      name: 'youveNoDuplicateFilesThatCanBeCleared',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get success {
    return Intl.message(
      'Success',
      name: 'success',
      desc: '',
      args: [],
    );
  }

  /// `Rate us`
  String get rateUs {
    return Intl.message(
      'Rate us',
      name: 'rateUs',
      desc: '',
      args: [],
    );
  }

  /// `Also empty "Recently Deleted" from "Settings" -> "Storage" to claim the freed space`
  String get remindToEmptyDeviceTrash {
    return Intl.message(
      'Also empty "Recently Deleted" from "Settings" -> "Storage" to claim the freed space',
      name: 'remindToEmptyDeviceTrash',
      desc: '',
      args: [],
    );
  }

  /// `You have successfully freed up {storageSaved}!`
  String youHaveSuccessfullyFreedUp(String storageSaved) {
    return Intl.message(
      'You have successfully freed up $storageSaved!',
      name: 'youHaveSuccessfullyFreedUp',
      desc:
          'The text to display when the user has successfully freed up storage',
      args: [storageSaved],
    );
  }

  /// `Also empty your "Trash" to claim the freed up space`
  String get remindToEmptyEnteTrash {
    return Intl.message(
      'Also empty your "Trash" to claim the freed up space',
      name: 'remindToEmptyEnteTrash',
      desc: '',
      args: [],
    );
  }

  /// `✨ Success`
  String get sparkleSuccess {
    return Intl.message(
      '✨ Success',
      name: 'sparkleSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Your have cleaned up {count, plural, one{{count} duplicate file} other{{count} duplicate files}}, saving ({storageSaved}!)`
  String duplicateFileCountWithStorageSaved(int count, String storageSaved) {
    return Intl.message(
      'Your have cleaned up ${Intl.plural(count, one: '$count duplicate file', other: '$count duplicate files')}, saving ($storageSaved!)',
      name: 'duplicateFileCountWithStorageSaved',
      desc:
          'The text to display when the user has successfully cleaned up duplicate files',
      args: [count, storageSaved],
    );
  }

  /// `Family plans`
  String get familyPlans {
    return Intl.message(
      'Family plans',
      name: 'familyPlans',
      desc: '',
      args: [],
    );
  }

  /// `Referrals`
  String get referrals {
    return Intl.message(
      'Referrals',
      name: 'referrals',
      desc: '',
      args: [],
    );
  }

  /// `Advanced`
  String get advanced {
    return Intl.message(
      'Advanced',
      name: 'advanced',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get general {
    return Intl.message(
      'General',
      name: 'general',
      desc: '',
      args: [],
    );
  }

  /// `Security`
  String get security {
    return Intl.message(
      'Security',
      name: 'security',
      desc: '',
      args: [],
    );
  }

  /// `Please authenticate to view your recovery key`
  String get authToViewYourRecoveryKey {
    return Intl.message(
      'Please authenticate to view your recovery key',
      name: 'authToViewYourRecoveryKey',
      desc: '',
      args: [],
    );
  }

  /// `Two-factor`
  String get twofactor {
    return Intl.message(
      'Two-factor',
      name: 'twofactor',
      desc: '',
      args: [],
    );
  }

  /// `Please authenticate to configure two-factor authentication`
  String get authToConfigureTwofactorAuthentication {
    return Intl.message(
      'Please authenticate to configure two-factor authentication',
      name: 'authToConfigureTwofactorAuthentication',
      desc: '',
      args: [],
    );
  }

  /// `Lockscreen`
  String get lockscreen {
    return Intl.message(
      'Lockscreen',
      name: 'lockscreen',
      desc: '',
      args: [],
    );
  }

  /// `Please authenticate to change lockscreen setting`
  String get authToChangeLockscreenSetting {
    return Intl.message(
      'Please authenticate to change lockscreen setting',
      name: 'authToChangeLockscreenSetting',
      desc: '',
      args: [],
    );
  }

  /// `To enable lockscreen, please setup device passcode or screen lock in your system settings.`
  String get lockScreenEnablePreSteps {
    return Intl.message(
      'To enable lockscreen, please setup device passcode or screen lock in your system settings.',
      name: 'lockScreenEnablePreSteps',
      desc: '',
      args: [],
    );
  }

  /// `View active sessions`
  String get viewActiveSessions {
    return Intl.message(
      'View active sessions',
      name: 'viewActiveSessions',
      desc: '',
      args: [],
    );
  }

  /// `Please authenticate to view your active sessions`
  String get authToViewYourActiveSessions {
    return Intl.message(
      'Please authenticate to view your active sessions',
      name: 'authToViewYourActiveSessions',
      desc: '',
      args: [],
    );
  }

  /// `Disable two-factor`
  String get disableTwofactor {
    return Intl.message(
      'Disable two-factor',
      name: 'disableTwofactor',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to disable two-factor authentication?`
  String get confirm2FADisable {
    return Intl.message(
      'Are you sure you want to disable two-factor authentication?',
      name: 'confirm2FADisable',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `Social`
  String get social {
    return Intl.message(
      'Social',
      name: 'social',
      desc: '',
      args: [],
    );
  }

  /// `Rate us on {storeName}`
  String rateUsOnStore(Object storeName) {
    return Intl.message(
      'Rate us on $storeName',
      name: 'rateUsOnStore',
      desc: '',
      args: [storeName],
    );
  }

  /// `Blog`
  String get blog {
    return Intl.message(
      'Blog',
      name: 'blog',
      desc: '',
      args: [],
    );
  }

  /// `Merchandise`
  String get merchandise {
    return Intl.message(
      'Merchandise',
      name: 'merchandise',
      desc: '',
      args: [],
    );
  }

  /// `Twitter`
  String get twitter {
    return Intl.message(
      'Twitter',
      name: 'twitter',
      desc: '',
      args: [],
    );
  }

  /// `Mastodon`
  String get mastodon {
    return Intl.message(
      'Mastodon',
      name: 'mastodon',
      desc: '',
      args: [],
    );
  }

  /// `Matrix`
  String get matrix {
    return Intl.message(
      'Matrix',
      name: 'matrix',
      desc: '',
      args: [],
    );
  }

  /// `Discord`
  String get discord {
    return Intl.message(
      'Discord',
      name: 'discord',
      desc: '',
      args: [],
    );
  }

  /// `Reddit`
  String get reddit {
    return Intl.message(
      'Reddit',
      name: 'reddit',
      desc: '',
      args: [],
    );
  }

  /// `Your storage details could not be fetched`
  String get yourStorageDetailsCouldNotBeFetched {
    return Intl.message(
      'Your storage details could not be fetched',
      name: 'yourStorageDetailsCouldNotBeFetched',
      desc: '',
      args: [],
    );
  }

  /// `Report a bug`
  String get reportABug {
    return Intl.message(
      'Report a bug',
      name: 'reportABug',
      desc: '',
      args: [],
    );
  }

  /// `Report bug`
  String get reportBug {
    return Intl.message(
      'Report bug',
      name: 'reportBug',
      desc: '',
      args: [],
    );
  }

  /// `Suggest features`
  String get suggestFeatures {
    return Intl.message(
      'Suggest features',
      name: 'suggestFeatures',
      desc: '',
      args: [],
    );
  }

  /// `Support`
  String get support {
    return Intl.message(
      'Support',
      name: 'support',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get lightTheme {
    return Intl.message(
      'Light',
      name: 'lightTheme',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get darkTheme {
    return Intl.message(
      'Dark',
      name: 'darkTheme',
      desc: '',
      args: [],
    );
  }

  /// `System`
  String get systemTheme {
    return Intl.message(
      'System',
      name: 'systemTheme',
      desc: '',
      args: [],
    );
  }

  /// `Free trial`
  String get freeTrial {
    return Intl.message(
      'Free trial',
      name: 'freeTrial',
      desc: '',
      args: [],
    );
  }

  /// `Select your plan`
  String get selectYourPlan {
    return Intl.message(
      'Select your plan',
      name: 'selectYourPlan',
      desc: '',
      args: [],
    );
  }

  /// `ente preserves your memories, so they're always available to you, even if you lose your device.`
  String get enteSubscriptionPitch {
    return Intl.message(
      'ente preserves your memories, so they\'re always available to you, even if you lose your device.',
      name: 'enteSubscriptionPitch',
      desc: '',
      args: [],
    );
  }

  /// `Your family can be added to your plan as well.`
  String get enteSubscriptionShareWithFamily {
    return Intl.message(
      'Your family can be added to your plan as well.',
      name: 'enteSubscriptionShareWithFamily',
      desc: '',
      args: [],
    );
  }

  /// `Current usage is `
  String get currentUsageIs {
    return Intl.message(
      'Current usage is ',
      name: 'currentUsageIs',
      desc: 'This text is followed by storage usaged',
      args: [],
    );
  }

  /// `FAQs`
  String get faqs {
    return Intl.message(
      'FAQs',
      name: 'faqs',
      desc: '',
      args: [],
    );
  }

  /// `Renews on {endDate}`
  String renewsOn(Object endDate) {
    return Intl.message(
      'Renews on $endDate',
      name: 'renewsOn',
      desc: '',
      args: [endDate],
    );
  }

  /// `Free trial valid till {endDate}`
  String freeTrialValidTill(Object endDate) {
    return Intl.message(
      'Free trial valid till $endDate',
      name: 'freeTrialValidTill',
      desc: '',
      args: [endDate],
    );
  }

  /// `Your subscription will be cancelled on {endDate}`
  String subWillBeCancelledOn(Object endDate) {
    return Intl.message(
      'Your subscription will be cancelled on $endDate',
      name: 'subWillBeCancelledOn',
      desc: '',
      args: [endDate],
    );
  }

  /// `Subscription`
  String get subscription {
    return Intl.message(
      'Subscription',
      name: 'subscription',
      desc: '',
      args: [],
    );
  }

  /// `Payment details`
  String get paymentDetails {
    return Intl.message(
      'Payment details',
      name: 'paymentDetails',
      desc: '',
      args: [],
    );
  }

  /// `Manage Family`
  String get manageFamily {
    return Intl.message(
      'Manage Family',
      name: 'manageFamily',
      desc: '',
      args: [],
    );
  }

  /// `Please contact us at support@ente.io to manage your {provider} subscription.`
  String contactToManageSubscription(Object provider) {
    return Intl.message(
      'Please contact us at support@ente.io to manage your $provider subscription.',
      name: 'contactToManageSubscription',
      desc: '',
      args: [provider],
    );
  }

  /// `Renew subscription`
  String get renewSubscription {
    return Intl.message(
      'Renew subscription',
      name: 'renewSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Cancel subscription`
  String get cancelSubscription {
    return Intl.message(
      'Cancel subscription',
      name: 'cancelSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to renew?`
  String get areYouSureYouWantToRenew {
    return Intl.message(
      'Are you sure you want to renew?',
      name: 'areYouSureYouWantToRenew',
      desc: '',
      args: [],
    );
  }

  /// `Yes, Renew`
  String get yesRenew {
    return Intl.message(
      'Yes, Renew',
      name: 'yesRenew',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel?`
  String get areYouSureYouWantToCancel {
    return Intl.message(
      'Are you sure you want to cancel?',
      name: 'areYouSureYouWantToCancel',
      desc: '',
      args: [],
    );
  }

  /// `Yes, cancel`
  String get yesCancel {
    return Intl.message(
      'Yes, cancel',
      name: 'yesCancel',
      desc: '',
      args: [],
    );
  }

  /// `Failed to renew`
  String get failedToRenew {
    return Intl.message(
      'Failed to renew',
      name: 'failedToRenew',
      desc: '',
      args: [],
    );
  }

  /// `Failed to cancel`
  String get failedToCancel {
    return Intl.message(
      'Failed to cancel',
      name: 'failedToCancel',
      desc: '',
      args: [],
    );
  }

  /// `2 months free on yearly plans`
  String get twoMonthsFreeOnYearlyPlans {
    return Intl.message(
      '2 months free on yearly plans',
      name: 'twoMonthsFreeOnYearlyPlans',
      desc: '',
      args: [],
    );
  }

  /// `Monthly`
  String get monthly {
    return Intl.message(
      'Monthly',
      name: 'monthly',
      desc: 'The text to display for monthly plans',
      args: [],
    );
  }

  /// `Yearly`
  String get yearly {
    return Intl.message(
      'Yearly',
      name: 'yearly',
      desc: 'The text to display for yearly plans',
      args: [],
    );
  }

  /// `Confirm plan change`
  String get confirmPlanChange {
    return Intl.message(
      'Confirm plan change',
      name: 'confirmPlanChange',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to change your plan?`
  String get areYouSureYouWantToChangeYourPlan {
    return Intl.message(
      'Are you sure you want to change your plan?',
      name: 'areYouSureYouWantToChangeYourPlan',
      desc: '',
      args: [],
    );
  }

  /// `You cannot downgrade to this plan`
  String get youCannotDowngradeToThisPlan {
    return Intl.message(
      'You cannot downgrade to this plan',
      name: 'youCannotDowngradeToThisPlan',
      desc: '',
      args: [],
    );
  }

  /// `Please cancel your existing subscription from {paymentProvider} first`
  String cancelOtherSubscription(String paymentProvider) {
    return Intl.message(
      'Please cancel your existing subscription from $paymentProvider first',
      name: 'cancelOtherSubscription',
      desc:
          'The text to display when the user has an existing subscription from a different payment provider',
      args: [paymentProvider],
    );
  }

  /// `Optional, as short as you like...`
  String get optionalAsShortAsYouLike {
    return Intl.message(
      'Optional, as short as you like...',
      name: 'optionalAsShortAsYouLike',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message(
      'Send',
      name: 'send',
      desc: '',
      args: [],
    );
  }

  /// `Your subscription was cancelled. Would you like to share the reason?`
  String get askCancelReason {
    return Intl.message(
      'Your subscription was cancelled. Would you like to share the reason?',
      name: 'askCancelReason',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for subscribing!`
  String get thankYouForSubscribing {
    return Intl.message(
      'Thank you for subscribing!',
      name: 'thankYouForSubscribing',
      desc: '',
      args: [],
    );
  }

  /// `Your purchase was successful`
  String get yourPurchaseWasSuccessful {
    return Intl.message(
      'Your purchase was successful',
      name: 'yourPurchaseWasSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Your plan was successfully upgraded`
  String get yourPlanWasSuccessfullyUpgraded {
    return Intl.message(
      'Your plan was successfully upgraded',
      name: 'yourPlanWasSuccessfullyUpgraded',
      desc: '',
      args: [],
    );
  }

  /// `Your plan was successfully downgraded`
  String get yourPlanWasSuccessfullyDowngraded {
    return Intl.message(
      'Your plan was successfully downgraded',
      name: 'yourPlanWasSuccessfullyDowngraded',
      desc: '',
      args: [],
    );
  }

  /// `Your subscription was updated successfully`
  String get yourSubscriptionWasUpdatedSuccessfully {
    return Intl.message(
      'Your subscription was updated successfully',
      name: 'yourSubscriptionWasUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Google Play ID`
  String get googlePlayId {
    return Intl.message(
      'Google Play ID',
      name: 'googlePlayId',
      desc: '',
      args: [],
    );
  }

  /// `Apple ID`
  String get appleId {
    return Intl.message(
      'Apple ID',
      name: 'appleId',
      desc: '',
      args: [],
    );
  }

  /// `PlayStore subscription`
  String get playstoreSubscription {
    return Intl.message(
      'PlayStore subscription',
      name: 'playstoreSubscription',
      desc: '',
      args: [],
    );
  }

  /// `AppStore subscription`
  String get appstoreSubscription {
    return Intl.message(
      'AppStore subscription',
      name: 'appstoreSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Your {id} is already linked to another ente account.\nIf you would like to use your {id} with this account, please contact our support''`
  String subAlreadyLinkedErrMessage(Object id) {
    return Intl.message(
      'Your $id is already linked to another ente account.\nIf you would like to use your $id with this account, please contact our support\'\'',
      name: 'subAlreadyLinkedErrMessage',
      desc: '',
      args: [id],
    );
  }

  /// `Please visit web.ente.io to manage your subscription`
  String get visitWebToManage {
    return Intl.message(
      'Please visit web.ente.io to manage your subscription',
      name: 'visitWebToManage',
      desc: '',
      args: [],
    );
  }

  /// `Could not update subscription`
  String get couldNotUpdateSubscription {
    return Intl.message(
      'Could not update subscription',
      name: 'couldNotUpdateSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Please contact support@ente.io and we will be happy to help!`
  String get pleaseContactSupportAndWeWillBeHappyToHelp {
    return Intl.message(
      'Please contact support@ente.io and we will be happy to help!',
      name: 'pleaseContactSupportAndWeWillBeHappyToHelp',
      desc: '',
      args: [],
    );
  }

  /// `Payment failed`
  String get paymentFailed {
    return Intl.message(
      'Payment failed',
      name: 'paymentFailed',
      desc: '',
      args: [],
    );
  }

  /// `Please talk to {providerName} support if you were charged`
  String paymentFailedTalkToProvider(String providerName) {
    return Intl.message(
      'Please talk to $providerName support if you were charged',
      name: 'paymentFailedTalkToProvider',
      desc: 'The text to display when the payment failed',
      args: [providerName],
    );
  }

  /// `Continue on free trial`
  String get continueOnFreeTrial {
    return Intl.message(
      'Continue on free trial',
      name: 'continueOnFreeTrial',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to exit?`
  String get areYouSureYouWantToExit {
    return Intl.message(
      'Are you sure you want to exit?',
      name: 'areYouSureYouWantToExit',
      desc: '',
      args: [],
    );
  }

  /// `Thank you`
  String get thankYou {
    return Intl.message(
      'Thank you',
      name: 'thankYou',
      desc: '',
      args: [],
    );
  }

  /// `Failed to verify payment status`
  String get failedToVerifyPaymentStatus {
    return Intl.message(
      'Failed to verify payment status',
      name: 'failedToVerifyPaymentStatus',
      desc: '',
      args: [],
    );
  }

  /// `Please wait for sometime before retrying`
  String get pleaseWaitForSometimeBeforeRetrying {
    return Intl.message(
      'Please wait for sometime before retrying',
      name: 'pleaseWaitForSometimeBeforeRetrying',
      desc: '',
      args: [],
    );
  }

  /// `Unfortunately your payment failed due to {reason}`
  String paymentFailedWithReason(Object reason) {
    return Intl.message(
      'Unfortunately your payment failed due to $reason',
      name: 'paymentFailedWithReason',
      desc: '',
      args: [reason],
    );
  }

  /// `You are on a family plan!`
  String get youAreOnAFamilyPlan {
    return Intl.message(
      'You are on a family plan!',
      name: 'youAreOnAFamilyPlan',
      desc: '',
      args: [],
    );
  }

  /// `Please contact <green>{familyAdminEmail}</green> to manage your subscription`
  String contactFamilyAdmin(Object familyAdminEmail) {
    return Intl.message(
      'Please contact <green>$familyAdminEmail</green> to manage your subscription',
      name: 'contactFamilyAdmin',
      desc: '',
      args: [familyAdminEmail],
    );
  }

  /// `Leave family`
  String get leaveFamily {
    return Intl.message(
      'Leave family',
      name: 'leaveFamily',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure that you want to leave the family plan?`
  String get areYouSureThatYouWantToLeaveTheFamily {
    return Intl.message(
      'Are you sure that you want to leave the family plan?',
      name: 'areYouSureThatYouWantToLeaveTheFamily',
      desc: '',
      args: [],
    );
  }

  /// `Leave`
  String get leave {
    return Intl.message(
      'Leave',
      name: 'leave',
      desc: '',
      args: [],
    );
  }

  /// `Rate the app`
  String get rateTheApp {
    return Intl.message(
      'Rate the app',
      name: 'rateTheApp',
      desc: '',
      args: [],
    );
  }

  /// `Start backup`
  String get startBackup {
    return Intl.message(
      'Start backup',
      name: 'startBackup',
      desc: '',
      args: [],
    );
  }

  /// `No photos are being backed up right now`
  String get noPhotosAreBeingBackedUpRightNow {
    return Intl.message(
      'No photos are being backed up right now',
      name: 'noPhotosAreBeingBackedUpRightNow',
      desc: '',
      args: [],
    );
  }

  /// `Preserve more`
  String get preserveMore {
    return Intl.message(
      'Preserve more',
      name: 'preserveMore',
      desc: '',
      args: [],
    );
  }

  /// `Existing user`
  String get existingUser {
    return Intl.message(
      'Existing user',
      name: 'existingUser',
      desc: '',
      args: [],
    );
  }

  /// `Private backups`
  String get privateBackups {
    return Intl.message(
      'Private backups',
      name: 'privateBackups',
      desc: '',
      args: [],
    );
  }

  /// `for your memories`
  String get forYourMemories {
    return Intl.message(
      'for your memories',
      name: 'forYourMemories',
      desc: '',
      args: [],
    );
  }

  /// `End-to-end encrypted by default`
  String get endtoendEncryptedByDefault {
    return Intl.message(
      'End-to-end encrypted by default',
      name: 'endtoendEncryptedByDefault',
      desc: '',
      args: [],
    );
  }

  /// `Safely stored`
  String get safelyStored {
    return Intl.message(
      'Safely stored',
      name: 'safelyStored',
      desc: '',
      args: [],
    );
  }

  /// `at a fallout shelter`
  String get atAFalloutShelter {
    return Intl.message(
      'at a fallout shelter',
      name: 'atAFalloutShelter',
      desc: '',
      args: [],
    );
  }

  /// `Designed to outlive`
  String get designedToOutlive {
    return Intl.message(
      'Designed to outlive',
      name: 'designedToOutlive',
      desc: '',
      args: [],
    );
  }

  /// `Available`
  String get available {
    return Intl.message(
      'Available',
      name: 'available',
      desc: '',
      args: [],
    );
  }

  /// `everywhere`
  String get everywhere {
    return Intl.message(
      'everywhere',
      name: 'everywhere',
      desc: '',
      args: [],
    );
  }

  /// `Android, iOS, Web, Desktop`
  String get androidIosWebDesktop {
    return Intl.message(
      'Android, iOS, Web, Desktop',
      name: 'androidIosWebDesktop',
      desc: '',
      args: [],
    );
  }

  /// `Mobile, Web, Desktop`
  String get mobileWebDesktop {
    return Intl.message(
      'Mobile, Web, Desktop',
      name: 'mobileWebDesktop',
      desc: '',
      args: [],
    );
  }

  /// `New to ente`
  String get newToEnte {
    return Intl.message(
      'New to ente',
      name: 'newToEnte',
      desc: '',
      args: [],
    );
  }

  /// `Please login again`
  String get pleaseLoginAgain {
    return Intl.message(
      'Please login again',
      name: 'pleaseLoginAgain',
      desc: '',
      args: [],
    );
  }

  /// `The developer account we use to publish ente on App Store has changed. Because of this, you will need to login again.\n\nOur apologies for the inconvenience, but this was unavoidable.`
  String get devAccountChanged {
    return Intl.message(
      'The developer account we use to publish ente on App Store has changed. Because of this, you will need to login again.\n\nOur apologies for the inconvenience, but this was unavoidable.',
      name: 'devAccountChanged',
      desc: '',
      args: [],
    );
  }

  /// `Your subscription has expired`
  String get yourSubscriptionHasExpired {
    return Intl.message(
      'Your subscription has expired',
      name: 'yourSubscriptionHasExpired',
      desc: '',
      args: [],
    );
  }

  /// `Storage limit exceeded`
  String get storageLimitExceeded {
    return Intl.message(
      'Storage limit exceeded',
      name: 'storageLimitExceeded',
      desc: '',
      args: [],
    );
  }

  /// `Upgrade`
  String get upgrade {
    return Intl.message(
      'Upgrade',
      name: 'upgrade',
      desc: '',
      args: [],
    );
  }

  /// `Raise ticket`
  String get raiseTicket {
    return Intl.message(
      'Raise ticket',
      name: 'raiseTicket',
      desc: '',
      args: [],
    );
  }

  /// `Backup failed`
  String get backupFailed {
    return Intl.message(
      'Backup failed',
      name: 'backupFailed',
      desc: '',
      args: [],
    );
  }

  /// `We could not backup your data.\nWe will retry later.`
  String get couldNotBackUpTryLater {
    return Intl.message(
      'We could not backup your data.\nWe will retry later.',
      name: 'couldNotBackUpTryLater',
      desc: '',
      args: [],
    );
  }

  /// `ente can encrypt and preserve files only if you grant access to them`
  String get enteCanEncryptAndPreserveFilesOnlyIfYouGrant {
    return Intl.message(
      'ente can encrypt and preserve files only if you grant access to them',
      name: 'enteCanEncryptAndPreserveFilesOnlyIfYouGrant',
      desc: '',
      args: [],
    );
  }

  /// `Please grant permissions`
  String get pleaseGrantPermissions {
    return Intl.message(
      'Please grant permissions',
      name: 'pleaseGrantPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Grant permission`
  String get grantPermission {
    return Intl.message(
      'Grant permission',
      name: 'grantPermission',
      desc: '',
      args: [],
    );
  }

  /// `Private sharing`
  String get privateSharing {
    return Intl.message(
      'Private sharing',
      name: 'privateSharing',
      desc: '',
      args: [],
    );
  }

  /// `Share only with the people you want`
  String get shareOnlyWithThePeopleYouWant {
    return Intl.message(
      'Share only with the people you want',
      name: 'shareOnlyWithThePeopleYouWant',
      desc: '',
      args: [],
    );
  }

  /// `Use public links for people not on ente`
  String get usePublicLinksForPeopleNotOnEnte {
    return Intl.message(
      'Use public links for people not on ente',
      name: 'usePublicLinksForPeopleNotOnEnte',
      desc: '',
      args: [],
    );
  }

  /// `Allow people to add photos`
  String get allowPeopleToAddPhotos {
    return Intl.message(
      'Allow people to add photos',
      name: 'allowPeopleToAddPhotos',
      desc: '',
      args: [],
    );
  }

  /// `Share an album now`
  String get shareAnAlbumNow {
    return Intl.message(
      'Share an album now',
      name: 'shareAnAlbumNow',
      desc: '',
      args: [],
    );
  }

  /// `Collect event photos`
  String get collectEventPhotos {
    return Intl.message(
      'Collect event photos',
      name: 'collectEventPhotos',
      desc: '',
      args: [],
    );
  }

  /// `Session expired`
  String get sessionExpired {
    return Intl.message(
      'Session expired',
      name: 'sessionExpired',
      desc: '',
      args: [],
    );
  }

  /// `Logging out...`
  String get loggingOut {
    return Intl.message(
      'Logging out...',
      name: 'loggingOut',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Newest`
  String get newest {
    return Intl.message(
      'Newest',
      name: 'newest',
      desc: '',
      args: [],
    );
  }

  /// `Last updated`
  String get lastUpdated {
    return Intl.message(
      'Last updated',
      name: 'lastUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Delete empty albums`
  String get deleteEmptyAlbums {
    return Intl.message(
      'Delete empty albums',
      name: 'deleteEmptyAlbums',
      desc: '',
      args: [],
    );
  }

  /// `Delete empty albums?`
  String get deleteEmptyAlbumsWithQuestionMark {
    return Intl.message(
      'Delete empty albums?',
      name: 'deleteEmptyAlbumsWithQuestionMark',
      desc: '',
      args: [],
    );
  }

  /// `This will delete all empty albums. This is useful when you want to reduce the clutter in your album list.`
  String get deleteAlbumsDialogBody {
    return Intl.message(
      'This will delete all empty albums. This is useful when you want to reduce the clutter in your album list.',
      name: 'deleteAlbumsDialogBody',
      desc: '',
      args: [],
    );
  }

  /// `Deleting {currentlyDeleting} / {totalCount}`
  String deleteProgress(Object currentlyDeleting, Object totalCount) {
    return Intl.message(
      'Deleting $currentlyDeleting / $totalCount',
      name: 'deleteProgress',
      desc: '',
      args: [currentlyDeleting, totalCount],
    );
  }

  /// `Permanently delete`
  String get permanentlyDelete {
    return Intl.message(
      'Permanently delete',
      name: 'permanentlyDelete',
      desc: '',
      args: [],
    );
  }

  /// `Can only create link for files owned by you`
  String get canOnlyCreateLinkForFilesOwnedByYou {
    return Intl.message(
      'Can only create link for files owned by you',
      name: 'canOnlyCreateLinkForFilesOwnedByYou',
      desc: '',
      args: [],
    );
  }

  /// `Public link created`
  String get publicLinkCreated {
    return Intl.message(
      'Public link created',
      name: 'publicLinkCreated',
      desc: '',
      args: [],
    );
  }

  /// `You can manage your links in the share tab.`
  String get youCanManageYourLinksInTheShareTab {
    return Intl.message(
      'You can manage your links in the share tab.',
      name: 'youCanManageYourLinksInTheShareTab',
      desc: '',
      args: [],
    );
  }

  /// `Link copied to clipboard`
  String get linkCopiedToClipboard {
    return Intl.message(
      'Link copied to clipboard',
      name: 'linkCopiedToClipboard',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get restore {
    return Intl.message(
      'Restore',
      name: 'restore',
      desc:
          'Display text for an action which triggers a restore of item from trash',
      args: [],
    );
  }

  /// `Move to album`
  String get moveToAlbum {
    return Intl.message(
      'Move to album',
      name: 'moveToAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Unhide`
  String get unhide {
    return Intl.message(
      'Unhide',
      name: 'unhide',
      desc: '',
      args: [],
    );
  }

  /// `Unarchive`
  String get unarchive {
    return Intl.message(
      'Unarchive',
      name: 'unarchive',
      desc: '',
      args: [],
    );
  }

  /// `Favorite`
  String get favorite {
    return Intl.message(
      'Favorite',
      name: 'favorite',
      desc: '',
      args: [],
    );
  }

  /// `Remove from favorite`
  String get removeFromFavorite {
    return Intl.message(
      'Remove from favorite',
      name: 'removeFromFavorite',
      desc: '',
      args: [],
    );
  }

  /// `Share link`
  String get shareLink {
    return Intl.message(
      'Share link',
      name: 'shareLink',
      desc: '',
      args: [],
    );
  }

  /// `Add to ente`
  String get addToEnte {
    return Intl.message(
      'Add to ente',
      name: 'addToEnte',
      desc: '',
      args: [],
    );
  }

  /// `Add to album`
  String get addToAlbum {
    return Intl.message(
      'Add to album',
      name: 'addToAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Hide`
  String get hide {
    return Intl.message(
      'Hide',
      name: 'hide',
      desc: '',
      args: [],
    );
  }

  /// `{count} selected`
  String itemSelectedCount(int count) {
    return Intl.message(
      '$count selected',
      name: 'itemSelectedCount',
      desc: 'Text to indicate number of items selected',
      args: [count],
    );
  }

  /// `Share`
  String get share {
    return Intl.message(
      'Share',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  /// `Unhide to album`
  String get unhideToAlbum {
    return Intl.message(
      'Unhide to album',
      name: 'unhideToAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Restore to album`
  String get restoreToAlbum {
    return Intl.message(
      'Restore to album',
      name: 'restoreToAlbum',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one {Move item} other {Move items}}`
  String moveItem(num count) {
    return Intl.plural(
      count,
      one: 'Move item',
      other: 'Move items',
      name: 'moveItem',
      desc: 'Page title while moving one or more items to an album',
      args: [count],
    );
  }

  /// `{count, plural, one {Add item} other {Add items}}`
  String addItem(num count) {
    return Intl.plural(
      count,
      one: 'Add item',
      other: 'Add items',
      name: 'addItem',
      desc: 'Page title while adding one or more items to album',
      args: [count],
    );
  }

  /// `Create or select album`
  String get createOrSelectAlbum {
    return Intl.message(
      'Create or select album',
      name: 'createOrSelectAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Select album`
  String get selectAlbum {
    return Intl.message(
      'Select album',
      name: 'selectAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Album name`
  String get searchByAlbumNameHint {
    return Intl.message(
      'Album name',
      name: 'searchByAlbumNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Album title`
  String get albumTitle {
    return Intl.message(
      'Album title',
      name: 'albumTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter album name`
  String get enterAlbumName {
    return Intl.message(
      'Enter album name',
      name: 'enterAlbumName',
      desc: '',
      args: [],
    );
  }

  /// `Restoring files...`
  String get restoringFiles {
    return Intl.message(
      'Restoring files...',
      name: 'restoringFiles',
      desc: '',
      args: [],
    );
  }

  /// `Moving files to album...`
  String get movingFilesToAlbum {
    return Intl.message(
      'Moving files to album...',
      name: 'movingFilesToAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Unhiding files to album`
  String get unhidingFilesToAlbum {
    return Intl.message(
      'Unhiding files to album',
      name: 'unhidingFilesToAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Can not upload to albums owned by others`
  String get canNotUploadToAlbumsOwnedByOthers {
    return Intl.message(
      'Can not upload to albums owned by others',
      name: 'canNotUploadToAlbumsOwnedByOthers',
      desc: '',
      args: [],
    );
  }

  /// `Uploading files to album...`
  String get uploadingFilesToAlbum {
    return Intl.message(
      'Uploading files to album...',
      name: 'uploadingFilesToAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Added successfully to  {albumName}`
  String addedSuccessfullyTo(Object albumName) {
    return Intl.message(
      'Added successfully to  $albumName',
      name: 'addedSuccessfullyTo',
      desc: '',
      args: [albumName],
    );
  }

  /// `Moved successfully to {albumName}`
  String movedSuccessfullyTo(Object albumName) {
    return Intl.message(
      'Moved successfully to $albumName',
      name: 'movedSuccessfullyTo',
      desc: '',
      args: [albumName],
    );
  }

  /// `This album already has a collaborative link`
  String get thisAlbumAlreadyHDACollaborativeLink {
    return Intl.message(
      'This album already has a collaborative link',
      name: 'thisAlbumAlreadyHDACollaborativeLink',
      desc: '',
      args: [],
    );
  }

  /// `Collaborative link created for {albumName}`
  String collaborativeLinkCreatedFor(Object albumName) {
    return Intl.message(
      'Collaborative link created for $albumName',
      name: 'collaborativeLinkCreatedFor',
      desc: '',
      args: [albumName],
    );
  }

  /// `Ask your loved ones to share`
  String get askYourLovedOnesToShare {
    return Intl.message(
      'Ask your loved ones to share',
      name: 'askYourLovedOnesToShare',
      desc: '',
      args: [],
    );
  }

  /// `Invite`
  String get invite {
    return Intl.message(
      'Invite',
      name: 'invite',
      desc: '',
      args: [],
    );
  }

  /// `Share your first album`
  String get shareYourFirstAlbum {
    return Intl.message(
      'Share your first album',
      name: 'shareYourFirstAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Shared with {emailIDs}`
  String sharedWith(Object emailIDs) {
    return Intl.message(
      'Shared with $emailIDs',
      name: 'sharedWith',
      desc: '',
      args: [emailIDs],
    );
  }

  /// `Shared with me`
  String get sharedWithMe {
    return Intl.message(
      'Shared with me',
      name: 'sharedWithMe',
      desc: '',
      args: [],
    );
  }

  /// `Shared by me`
  String get sharedByMe {
    return Intl.message(
      'Shared by me',
      name: 'sharedByMe',
      desc: '',
      args: [],
    );
  }

  /// `Double your storage`
  String get doubleYourStorage {
    return Intl.message(
      'Double your storage',
      name: 'doubleYourStorage',
      desc: '',
      args: [],
    );
  }

  /// `Refer friends and 2x your plan`
  String get referFriendsAnd2xYourPlan {
    return Intl.message(
      'Refer friends and 2x your plan',
      name: 'referFriendsAnd2xYourPlan',
      desc: '',
      args: [],
    );
  }

  /// `Open an album and tap the share button on the top right to share.`
  String get shareAlbumHint {
    return Intl.message(
      'Open an album and tap the share button on the top right to share.',
      name: 'shareAlbumHint',
      desc: '',
      args: [],
    );
  }

  /// `Items show the number of days remaining before permanent deletion`
  String get itemsShowTheNumberOfDaysRemainingBeforePermanentDeletion {
    return Intl.message(
      'Items show the number of days remaining before permanent deletion',
      name: 'itemsShowTheNumberOfDaysRemainingBeforePermanentDeletion',
      desc: '',
      args: [],
    );
  }

  /// `Delete All`
  String get deleteAll {
    return Intl.message(
      'Delete All',
      name: 'deleteAll',
      desc: '',
      args: [],
    );
  }

  /// `Rename album`
  String get renameAlbum {
    return Intl.message(
      'Rename album',
      name: 'renameAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Rename`
  String get rename {
    return Intl.message(
      'Rename',
      name: 'rename',
      desc: '',
      args: [],
    );
  }

  /// `Leave shared album?`
  String get leaveSharedAlbum {
    return Intl.message(
      'Leave shared album?',
      name: 'leaveSharedAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Leave album`
  String get leaveAlbum {
    return Intl.message(
      'Leave album',
      name: 'leaveAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Photos added by you will be removed from the album`
  String get photosAddedByYouWillBeRemovedFromTheAlbum {
    return Intl.message(
      'Photos added by you will be removed from the album',
      name: 'photosAddedByYouWillBeRemovedFromTheAlbum',
      desc: '',
      args: [],
    );
  }

  /// `You've no files in this album that can be deleted`
  String get youveNoFilesInThisAlbumThatCanBeDeleted {
    return Intl.message(
      'You\'ve no files in this album that can be deleted',
      name: 'youveNoFilesInThisAlbumThatCanBeDeleted',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any archived items.`
  String get youDontHaveAnyArchivedItems {
    return Intl.message(
      'You don\'t have any archived items.',
      name: 'youDontHaveAnyArchivedItems',
      desc: '',
      args: [],
    );
  }

  /// `Some files in this album are ignored from upload because they had previously been deleted from ente.`
  String get ignoredFolderUploadReason {
    return Intl.message(
      'Some files in this album are ignored from upload because they had previously been deleted from ente.',
      name: 'ignoredFolderUploadReason',
      desc: '',
      args: [],
    );
  }

  /// `Reset ignored files`
  String get resetIgnoredFiles {
    return Intl.message(
      'Reset ignored files',
      name: 'resetIgnoredFiles',
      desc: '',
      args: [],
    );
  }

  /// `Files added to this device album will automatically get uploaded to ente.`
  String get deviceFilesAutoUploading {
    return Intl.message(
      'Files added to this device album will automatically get uploaded to ente.',
      name: 'deviceFilesAutoUploading',
      desc: '',
      args: [],
    );
  }

  /// `Turn on backup to automatically upload files added to this device folder to ente.`
  String get turnOnBackupForAutoUpload {
    return Intl.message(
      'Turn on backup to automatically upload files added to this device folder to ente.',
      name: 'turnOnBackupForAutoUpload',
      desc: '',
      args: [],
    );
  }

  /// `No hidden photos or videos`
  String get noHiddenPhotosOrVideos {
    return Intl.message(
      'No hidden photos or videos',
      name: 'noHiddenPhotosOrVideos',
      desc: '',
      args: [],
    );
  }

  /// `To hide a photo or video`
  String get toHideAPhotoOrVideo {
    return Intl.message(
      'To hide a photo or video',
      name: 'toHideAPhotoOrVideo',
      desc: '',
      args: [],
    );
  }

  /// `• Open the item`
  String get openTheItem {
    return Intl.message(
      '• Open the item',
      name: 'openTheItem',
      desc: '',
      args: [],
    );
  }

  /// `• Click on the overflow menu`
  String get clickOnTheOverflowMenu {
    return Intl.message(
      '• Click on the overflow menu',
      name: 'clickOnTheOverflowMenu',
      desc: '',
      args: [],
    );
  }

  /// `• Click`
  String get click {
    return Intl.message(
      '• Click',
      name: 'click',
      desc: '',
      args: [],
    );
  }

  /// `Nothing to see here! 👀`
  String get nothingToSeeHere {
    return Intl.message(
      'Nothing to see here! 👀',
      name: 'nothingToSeeHere',
      desc: '',
      args: [],
    );
  }

  /// `Unarchive album`
  String get unarchiveAlbum {
    return Intl.message(
      'Unarchive album',
      name: 'unarchiveAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Archive album`
  String get archiveAlbum {
    return Intl.message(
      'Archive album',
      name: 'archiveAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Calculating...`
  String get calculating {
    return Intl.message(
      'Calculating...',
      name: 'calculating',
      desc: '',
      args: [],
    );
  }

  /// `Please wait, deleting album`
  String get pleaseWaitDeletingAlbum {
    return Intl.message(
      'Please wait, deleting album',
      name: 'pleaseWaitDeletingAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Albums, months, days, years, ...`
  String get searchHintText {
    return Intl.message(
      'Albums, months, days, years, ...',
      name: 'searchHintText',
      desc: '',
      args: [],
    );
  }

  /// `• Album names (e.g. "Camera")\n• Types of files (e.g. "Videos", ".gif")\n• Years and months (e.g. "2022", "January")\n• Holidays (e.g. "Christmas")\n• Photo descriptions (e.g. “#fun”)`
  String get searchByExamples {
    return Intl.message(
      '• Album names (e.g. "Camera")\n• Types of files (e.g. "Videos", ".gif")\n• Years and months (e.g. "2022", "January")\n• Holidays (e.g. "Christmas")\n• Photo descriptions (e.g. “#fun”)',
      name: 'searchByExamples',
      desc: '',
      args: [],
    );
  }

  /// `You can try searching for a different query.`
  String get youCanTrySearchingForADifferentQuery {
    return Intl.message(
      'You can try searching for a different query.',
      name: 'youCanTrySearchingForADifferentQuery',
      desc: '',
      args: [],
    );
  }

  /// `No results found`
  String get noResultsFound {
    return Intl.message(
      'No results found',
      name: 'noResultsFound',
      desc: '',
      args: [],
    );
  }

  /// `Added by {emailOrName}`
  String addedBy(Object emailOrName) {
    return Intl.message(
      'Added by $emailOrName',
      name: 'addedBy',
      desc: '',
      args: [emailOrName],
    );
  }

  /// `Loading EXIF data...`
  String get loadingExifData {
    return Intl.message(
      'Loading EXIF data...',
      name: 'loadingExifData',
      desc: '',
      args: [],
    );
  }

  /// `View all EXIF data`
  String get viewAllExifData {
    return Intl.message(
      'View all EXIF data',
      name: 'viewAllExifData',
      desc: '',
      args: [],
    );
  }

  /// `No EXIF data`
  String get noExifData {
    return Intl.message(
      'No EXIF data',
      name: 'noExifData',
      desc: '',
      args: [],
    );
  }

  /// `This image has no exif data`
  String get thisImageHasNoExifData {
    return Intl.message(
      'This image has no exif data',
      name: 'thisImageHasNoExifData',
      desc: '',
      args: [],
    );
  }

  /// `EXIF`
  String get exif {
    return Intl.message(
      'EXIF',
      name: 'exif',
      desc: '',
      args: [],
    );
  }

  /// `No results`
  String get noResults {
    return Intl.message(
      'No results',
      name: 'noResults',
      desc: '',
      args: [],
    );
  }

  /// `We don't support editing photos and albums that you don't own yet`
  String get weDontSupportEditingPhotosAndAlbumsThatYouDont {
    return Intl.message(
      'We don\'t support editing photos and albums that you don\'t own yet',
      name: 'weDontSupportEditingPhotosAndAlbumsThatYouDont',
      desc: '',
      args: [],
    );
  }

  /// `Failed to fetch original for edit`
  String get failedToFetchOriginalForEdit {
    return Intl.message(
      'Failed to fetch original for edit',
      name: 'failedToFetchOriginalForEdit',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Set as`
  String get setAs {
    return Intl.message(
      'Set as',
      name: 'setAs',
      desc: '',
      args: [],
    );
  }

  /// `File saved to gallery`
  String get fileSavedToGallery {
    return Intl.message(
      'File saved to gallery',
      name: 'fileSavedToGallery',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message(
      'Download',
      name: 'download',
      desc: '',
      args: [],
    );
  }

  /// `Press and hold to play video`
  String get pressAndHoldToPlayVideo {
    return Intl.message(
      'Press and hold to play video',
      name: 'pressAndHoldToPlayVideo',
      desc: '',
      args: [],
    );
  }

  /// `Download failed`
  String get downloadFailed {
    return Intl.message(
      'Download failed',
      name: 'downloadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Deduplicate Files`
  String get deduplicateFiles {
    return Intl.message(
      'Deduplicate Files',
      name: 'deduplicateFiles',
      desc: '',
      args: [],
    );
  }

  /// `Deselect all`
  String get deselectAll {
    return Intl.message(
      'Deselect all',
      name: 'deselectAll',
      desc: '',
      args: [],
    );
  }

  /// `Please review and delete the items you believe are duplicates.`
  String get reviewDeduplicateItems {
    return Intl.message(
      'Please review and delete the items you believe are duplicates.',
      name: 'reviewDeduplicateItems',
      desc: '',
      args: [],
    );
  }

  /// `Club by capture time`
  String get clubByCaptureTime {
    return Intl.message(
      'Club by capture time',
      name: 'clubByCaptureTime',
      desc: '',
      args: [],
    );
  }

  /// `Count`
  String get count {
    return Intl.message(
      'Count',
      name: 'count',
      desc: '',
      args: [],
    );
  }

  /// `Total size`
  String get totalSize {
    return Intl.message(
      'Total size',
      name: 'totalSize',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get time {
    return Intl.message(
      'Time',
      name: 'time',
      desc: '',
      args: [],
    );
  }

  /// `Long-press on an item to view in full-screen`
  String get longpressOnAnItemToViewInFullscreen {
    return Intl.message(
      'Long-press on an item to view in full-screen',
      name: 'longpressOnAnItemToViewInFullscreen',
      desc: '',
      args: [],
    );
  }

  /// `Decrypting video...`
  String get decryptingVideo {
    return Intl.message(
      'Decrypting video...',
      name: 'decryptingVideo',
      desc: '',
      args: [],
    );
  }

  /// `Please authenticate to view your memories`
  String get authToViewYourMemories {
    return Intl.message(
      'Please authenticate to view your memories',
      name: 'authToViewYourMemories',
      desc: '',
      args: [],
    );
  }

  /// `Unlock`
  String get unlock {
    return Intl.message(
      'Unlock',
      name: 'unlock',
      desc: '',
      args: [],
    );
  }

  /// `Free up space`
  String get freeUpSpace {
    return Intl.message(
      'Free up space',
      name: 'freeUpSpace',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one {It can be deleted from the device to free up {formattedSize}} other {They can be deleted from the device to free up {formattedSize}}}`
  String freeUpSpaceSaving(num count, Object formattedSize) {
    return Intl.plural(
      count,
      one: 'It can be deleted from the device to free up $formattedSize',
      other: 'They can be deleted from the device to free up $formattedSize',
      name: 'freeUpSpaceSaving',
      desc:
          'Text to tell user how much space they can free up by deleting items from the device',
      args: [count, formattedSize],
    );
  }

  /// `{count, plural, one {1 file} other {{formattedNumber} files}} in this album has been backed up safely`
  String filesBackedUpInAlbum(int count, String formattedNumber) {
    return Intl.message(
      '${Intl.plural(count, one: '1 file', other: '$formattedNumber files')} in this album has been backed up safely',
      name: 'filesBackedUpInAlbum',
      desc: 'Text to tell user how many files have been backed up in the album',
      args: [count, formattedNumber],
    );
  }

  /// `{count, plural, one {1 file} other {{formattedNumber} files}} on this device have been backed up safely`
  String filesBackedUpFromDevice(int count, String formattedNumber) {
    return Intl.message(
      '${Intl.plural(count, one: '1 file', other: '$formattedNumber files')} on this device have been backed up safely',
      name: 'filesBackedUpFromDevice',
      desc:
          'Text to tell user how many files have been backed up from this device',
      args: [count, formattedNumber],
    );
  }

  /// `You can still access {count, plural, one {it} other {them}} on ente as long as you have an active subscription`
  String freeUpAccessPostDelete(int count) {
    return Intl.message(
      'You can still access ${Intl.plural(count, one: 'it', other: 'them')} on ente as long as you have an active subscription',
      name: 'freeUpAccessPostDelete',
      desc: '',
      args: [count],
    );
  }

  /// `Free up {sizeInMBorGB}`
  String freeUpAmount(Object sizeInMBorGB) {
    return Intl.message(
      'Free up $sizeInMBorGB',
      name: 'freeUpAmount',
      desc: '',
      args: [sizeInMBorGB],
    );
  }

  /// `This email is already in use`
  String get thisEmailIsAlreadyInUse {
    return Intl.message(
      'This email is already in use',
      name: 'thisEmailIsAlreadyInUse',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect code`
  String get incorrectCode {
    return Intl.message(
      'Incorrect code',
      name: 'incorrectCode',
      desc: '',
      args: [],
    );
  }

  /// `Authentication failed, please try again`
  String get authenticationFailedPleaseTryAgain {
    return Intl.message(
      'Authentication failed, please try again',
      name: 'authenticationFailedPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Verification failed, please try again`
  String get verificationFailedPleaseTryAgain {
    return Intl.message(
      'Verification failed, please try again',
      name: 'verificationFailedPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Authenticating...`
  String get authenticating {
    return Intl.message(
      'Authenticating...',
      name: 'authenticating',
      desc: '',
      args: [],
    );
  }

  /// `Authentication successful!`
  String get authenticationSuccessful {
    return Intl.message(
      'Authentication successful!',
      name: 'authenticationSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect recovery key`
  String get incorrectRecoveryKey {
    return Intl.message(
      'Incorrect recovery key',
      name: 'incorrectRecoveryKey',
      desc: '',
      args: [],
    );
  }

  /// `The recovery key you entered is incorrect`
  String get theRecoveryKeyYouEnteredIsIncorrect {
    return Intl.message(
      'The recovery key you entered is incorrect',
      name: 'theRecoveryKeyYouEnteredIsIncorrect',
      desc: '',
      args: [],
    );
  }

  /// `Two-factor authentication successfully reset`
  String get twofactorAuthenticationSuccessfullyReset {
    return Intl.message(
      'Two-factor authentication successfully reset',
      name: 'twofactorAuthenticationSuccessfullyReset',
      desc: '',
      args: [],
    );
  }

  /// `Please verify the code you have entered`
  String get pleaseVerifyTheCodeYouHaveEntered {
    return Intl.message(
      'Please verify the code you have entered',
      name: 'pleaseVerifyTheCodeYouHaveEntered',
      desc: '',
      args: [],
    );
  }

  /// `Please contact support if the problem persists`
  String get pleaseContactSupportIfTheProblemPersists {
    return Intl.message(
      'Please contact support if the problem persists',
      name: 'pleaseContactSupportIfTheProblemPersists',
      desc: '',
      args: [],
    );
  }

  /// `Two-factor authentication has been disabled`
  String get twofactorAuthenticationHasBeenDisabled {
    return Intl.message(
      'Two-factor authentication has been disabled',
      name: 'twofactorAuthenticationHasBeenDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Sorry, the code you've entered is incorrect`
  String get sorryTheCodeYouveEnteredIsIncorrect {
    return Intl.message(
      'Sorry, the code you\'ve entered is incorrect',
      name: 'sorryTheCodeYouveEnteredIsIncorrect',
      desc: '',
      args: [],
    );
  }

  /// `Your verification code has expired`
  String get yourVerificationCodeHasExpired {
    return Intl.message(
      'Your verification code has expired',
      name: 'yourVerificationCodeHasExpired',
      desc: '',
      args: [],
    );
  }

  /// `Email changed to {newEmail}`
  String emailChangedTo(Object newEmail) {
    return Intl.message(
      'Email changed to $newEmail',
      name: 'emailChangedTo',
      desc: '',
      args: [newEmail],
    );
  }

  /// `Verifying...`
  String get verifying {
    return Intl.message(
      'Verifying...',
      name: 'verifying',
      desc: '',
      args: [],
    );
  }

  /// `Disabling two-factor authentication...`
  String get disablingTwofactorAuthentication {
    return Intl.message(
      'Disabling two-factor authentication...',
      name: 'disablingTwofactorAuthentication',
      desc: '',
      args: [],
    );
  }

  /// `All memories preserved`
  String get allMemoriesPreserved {
    return Intl.message(
      'All memories preserved',
      name: 'allMemoriesPreserved',
      desc: '',
      args: [],
    );
  }

  /// `Loading gallery...`
  String get loadingGallery {
    return Intl.message(
      'Loading gallery...',
      name: 'loadingGallery',
      desc: '',
      args: [],
    );
  }

  /// `Syncing...`
  String get syncing {
    return Intl.message(
      'Syncing...',
      name: 'syncing',
      desc: '',
      args: [],
    );
  }

  /// `Encrypting backup...`
  String get encryptingBackup {
    return Intl.message(
      'Encrypting backup...',
      name: 'encryptingBackup',
      desc: '',
      args: [],
    );
  }

  /// `Sync stopped`
  String get syncStopped {
    return Intl.message(
      'Sync stopped',
      name: 'syncStopped',
      desc: '',
      args: [],
    );
  }

  /// `{completed}/{total} memories preserved`
  String syncProgress(int completed, int total) {
    return Intl.message(
      '$completed/$total memories preserved',
      name: 'syncProgress',
      desc: 'Text to tell user how many memories have been preserved',
      args: [completed, total],
    );
  }

  /// `Archiving...`
  String get archiving {
    return Intl.message(
      'Archiving...',
      name: 'archiving',
      desc: '',
      args: [],
    );
  }

  /// `Unarchiving...`
  String get unarchiving {
    return Intl.message(
      'Unarchiving...',
      name: 'unarchiving',
      desc: '',
      args: [],
    );
  }

  /// `Successfully archived`
  String get successfullyArchived {
    return Intl.message(
      'Successfully archived',
      name: 'successfullyArchived',
      desc: '',
      args: [],
    );
  }

  /// `Successfully unarchived`
  String get successfullyUnarchived {
    return Intl.message(
      'Successfully unarchived',
      name: 'successfullyUnarchived',
      desc: '',
      args: [],
    );
  }

  /// `Rename file`
  String get renameFile {
    return Intl.message(
      'Rename file',
      name: 'renameFile',
      desc: '',
      args: [],
    );
  }

  /// `Enter file name`
  String get enterFileName {
    return Intl.message(
      'Enter file name',
      name: 'enterFileName',
      desc: '',
      args: [],
    );
  }

  /// `Files deleted`
  String get filesDeleted {
    return Intl.message(
      'Files deleted',
      name: 'filesDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Selected files are not on ente`
  String get selectedFilesAreNotOnEnte {
    return Intl.message(
      'Selected files are not on ente',
      name: 'selectedFilesAreNotOnEnte',
      desc: '',
      args: [],
    );
  }

  /// `This action cannot be undone`
  String get thisActionCannotBeUndone {
    return Intl.message(
      'This action cannot be undone',
      name: 'thisActionCannotBeUndone',
      desc: '',
      args: [],
    );
  }

  /// `Empty trash?`
  String get emptyTrash {
    return Intl.message(
      'Empty trash?',
      name: 'emptyTrash',
      desc: '',
      args: [],
    );
  }

  /// `All items in trash will be permanently deleted\n\nThis action cannot be undone`
  String get permDeleteWarning {
    return Intl.message(
      'All items in trash will be permanently deleted\n\nThis action cannot be undone',
      name: 'permDeleteWarning',
      desc: '',
      args: [],
    );
  }

  /// `Empty`
  String get empty {
    return Intl.message(
      'Empty',
      name: 'empty',
      desc: '',
      args: [],
    );
  }

  /// `Could not free up space`
  String get couldNotFreeUpSpace {
    return Intl.message(
      'Could not free up space',
      name: 'couldNotFreeUpSpace',
      desc: '',
      args: [],
    );
  }

  /// `Permanently delete from device?`
  String get permanentlyDeleteFromDevice {
    return Intl.message(
      'Permanently delete from device?',
      name: 'permanentlyDeleteFromDevice',
      desc: '',
      args: [],
    );
  }

  /// `Some of the files you are trying to delete are only available on your device and cannot be recovered if deleted`
  String get someOfTheFilesYouAreTryingToDeleteAre {
    return Intl.message(
      'Some of the files you are trying to delete are only available on your device and cannot be recovered if deleted',
      name: 'someOfTheFilesYouAreTryingToDeleteAre',
      desc: '',
      args: [],
    );
  }

  /// `They will be deleted from all albums.`
  String get theyWillBeDeletedFromAllAlbums {
    return Intl.message(
      'They will be deleted from all albums.',
      name: 'theyWillBeDeletedFromAllAlbums',
      desc: '',
      args: [],
    );
  }

  /// `Some items are in both ente and your device.`
  String get someItemsAreInBothEnteAndYourDevice {
    return Intl.message(
      'Some items are in both ente and your device.',
      name: 'someItemsAreInBothEnteAndYourDevice',
      desc: '',
      args: [],
    );
  }

  /// `Selected items will be deleted from all albums and moved to trash.`
  String get selectedItemsWillBeDeletedFromAllAlbumsAndMoved {
    return Intl.message(
      'Selected items will be deleted from all albums and moved to trash.',
      name: 'selectedItemsWillBeDeletedFromAllAlbumsAndMoved',
      desc: '',
      args: [],
    );
  }

  /// `These items will be deleted from your device.`
  String get theseItemsWillBeDeletedFromYourDevice {
    return Intl.message(
      'These items will be deleted from your device.',
      name: 'theseItemsWillBeDeletedFromYourDevice',
      desc: '',
      args: [],
    );
  }

  /// `It looks like something went wrong. Please retry after some time. If the error persists, please contact our support team.`
  String get itLooksLikeSomethingWentWrongPleaseRetryAfterSome {
    return Intl.message(
      'It looks like something went wrong. Please retry after some time. If the error persists, please contact our support team.',
      name: 'itLooksLikeSomethingWentWrongPleaseRetryAfterSome',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `It looks like something went wrong. Please retry after some time. If the error persists, please contact our support team.`
  String get tempErrorContactSupportIfPersists {
    return Intl.message(
      'It looks like something went wrong. Please retry after some time. If the error persists, please contact our support team.',
      name: 'tempErrorContactSupportIfPersists',
      desc: '',
      args: [],
    );
  }

  /// `Cached data`
  String get cachedData {
    return Intl.message(
      'Cached data',
      name: 'cachedData',
      desc: '',
      args: [],
    );
  }

  /// `Clear caches`
  String get clearCaches {
    return Intl.message(
      'Clear caches',
      name: 'clearCaches',
      desc: '',
      args: [],
    );
  }

  /// `Remote images`
  String get remoteImages {
    return Intl.message(
      'Remote images',
      name: 'remoteImages',
      desc: '',
      args: [],
    );
  }

  /// `Remote videos`
  String get remoteVideos {
    return Intl.message(
      'Remote videos',
      name: 'remoteVideos',
      desc: '',
      args: [],
    );
  }

  /// `Remote thumbnails`
  String get remoteThumbnails {
    return Intl.message(
      'Remote thumbnails',
      name: 'remoteThumbnails',
      desc: '',
      args: [],
    );
  }

  /// `Pending sync`
  String get pendingSync {
    return Intl.message(
      'Pending sync',
      name: 'pendingSync',
      desc: '',
      args: [],
    );
  }

  /// `Local gallery`
  String get localGallery {
    return Intl.message(
      'Local gallery',
      name: 'localGallery',
      desc: '',
      args: [],
    );
  }

  /// `Today's logs`
  String get todaysLogs {
    return Intl.message(
      'Today\'s logs',
      name: 'todaysLogs',
      desc: '',
      args: [],
    );
  }

  /// `View logs`
  String get viewLogs {
    return Intl.message(
      'View logs',
      name: 'viewLogs',
      desc: '',
      args: [],
    );
  }

  /// `This will send across logs to help us debug your issue. Please note that file names will be included to help track issues with specific files.`
  String get logsDialogBody {
    return Intl.message(
      'This will send across logs to help us debug your issue. Please note that file names will be included to help track issues with specific files.',
      name: 'logsDialogBody',
      desc: '',
      args: [],
    );
  }

  /// `Preparing logs...`
  String get preparingLogs {
    return Intl.message(
      'Preparing logs...',
      name: 'preparingLogs',
      desc: '',
      args: [],
    );
  }

  /// `Email your logs`
  String get emailYourLogs {
    return Intl.message(
      'Email your logs',
      name: 'emailYourLogs',
      desc: '',
      args: [],
    );
  }

  /// `Please send the logs to \n{toEmail}`
  String pleaseSendTheLogsTo(Object toEmail) {
    return Intl.message(
      'Please send the logs to \n$toEmail',
      name: 'pleaseSendTheLogsTo',
      desc: '',
      args: [toEmail],
    );
  }

  /// `Copy email address`
  String get copyEmailAddress {
    return Intl.message(
      'Copy email address',
      name: 'copyEmailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Export logs`
  String get exportLogs {
    return Intl.message(
      'Export logs',
      name: 'exportLogs',
      desc: '',
      args: [],
    );
  }

  /// `Please email us at {toEmail}`
  String pleaseEmailUsAt(Object toEmail) {
    return Intl.message(
      'Please email us at $toEmail',
      name: 'pleaseEmailUsAt',
      desc: '',
      args: [toEmail],
    );
  }

  /// `Dismiss`
  String get dismiss {
    return Intl.message(
      'Dismiss',
      name: 'dismiss',
      desc: '',
      args: [],
    );
  }

  /// `Did you know?`
  String get didYouKnow {
    return Intl.message(
      'Did you know?',
      name: 'didYouKnow',
      desc: '',
      args: [],
    );
  }

  /// `Loading your photos...`
  String get loadingMessage {
    return Intl.message(
      'Loading your photos...',
      name: 'loadingMessage',
      desc: '',
      args: [],
    );
  }

  /// `You can share your subscription with your family`
  String get loadMessage1 {
    return Intl.message(
      'You can share your subscription with your family',
      name: 'loadMessage1',
      desc: '',
      args: [],
    );
  }

  /// `We have preserved over 10 million memories so far`
  String get loadMessage2 {
    return Intl.message(
      'We have preserved over 10 million memories so far',
      name: 'loadMessage2',
      desc: '',
      args: [],
    );
  }

  /// `We keep 3 copies of your data, one in an underground fallout shelter`
  String get loadMessage3 {
    return Intl.message(
      'We keep 3 copies of your data, one in an underground fallout shelter',
      name: 'loadMessage3',
      desc: '',
      args: [],
    );
  }

  /// `All our apps are open source`
  String get loadMessage4 {
    return Intl.message(
      'All our apps are open source',
      name: 'loadMessage4',
      desc: '',
      args: [],
    );
  }

  /// `Our source code and cryptography have been externally audited`
  String get loadMessage5 {
    return Intl.message(
      'Our source code and cryptography have been externally audited',
      name: 'loadMessage5',
      desc: '',
      args: [],
    );
  }

  /// `You can share links to your albums with your loved ones`
  String get loadMessage6 {
    return Intl.message(
      'You can share links to your albums with your loved ones',
      name: 'loadMessage6',
      desc: '',
      args: [],
    );
  }

  /// `Our mobile apps run in the background to encrypt and backup any new photos you click`
  String get loadMessage7 {
    return Intl.message(
      'Our mobile apps run in the background to encrypt and backup any new photos you click',
      name: 'loadMessage7',
      desc: '',
      args: [],
    );
  }

  /// `web.ente.io has a slick uploader`
  String get loadMessage8 {
    return Intl.message(
      'web.ente.io has a slick uploader',
      name: 'loadMessage8',
      desc: '',
      args: [],
    );
  }

  /// `We use Xchacha20Poly1305 to safely encrypt your data`
  String get loadMessage9 {
    return Intl.message(
      'We use Xchacha20Poly1305 to safely encrypt your data',
      name: 'loadMessage9',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Select Language`
  String get selectLanguage {
    return Intl.message(
      'Select Language',
      name: 'selectLanguage',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'cs'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'it'),
      Locale.fromSubtags(languageCode: 'ko'),
      Locale.fromSubtags(languageCode: 'nl'),
      Locale.fromSubtags(languageCode: 'pl'),
      Locale.fromSubtags(languageCode: 'pt'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}