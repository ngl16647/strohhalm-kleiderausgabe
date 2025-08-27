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
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
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
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Accept`
  String get accept {
    return Intl.message('Accept', name: 'accept', desc: '', args: []);
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Strohhalm Clothing Distribution`
  String get application_name {
    return Intl.message(
      'Strohhalm Clothing Distribution',
      name: 'application_name',
      desc: '',
      args: [],
    );
  }

  /// `German`
  String get language_de {
    return Intl.message('German', name: 'language_de', desc: '', args: []);
  }

  /// `English`
  String get language_en {
    return Intl.message('English', name: 'language_en', desc: '', args: []);
  }

  /// `Russian`
  String get language_ru {
    return Intl.message('Russian', name: 'language_ru', desc: '', args: []);
  }

  /// `* Required fields`
  String get add_user_requiredFields {
    return Intl.message(
      '* Required fields',
      name: 'add_user_requiredFields',
      desc: '',
      args: [],
    );
  }

  /// `First name*`
  String get add_user_firstName {
    return Intl.message(
      'First name*',
      name: 'add_user_firstName',
      desc: '',
      args: [],
    );
  }

  /// `Last name*`
  String get add_user_lastName {
    return Intl.message(
      'Last name*',
      name: 'add_user_lastName',
      desc: '',
      args: [],
    );
  }

  /// `Select birth date*`
  String get add_user_birthDay {
    return Intl.message(
      'Select birth date*',
      name: 'add_user_birthDay',
      desc: '',
      args: [],
    );
  }

  /// `Miscellaneous`
  String get add_user_miscellaneous {
    return Intl.message(
      'Miscellaneous',
      name: 'add_user_miscellaneous',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to permanently delete this user?`
  String get add_user_deleteMessage {
    return Intl.message(
      'Are you sure you want to permanently delete this user?',
      name: 'add_user_deleteMessage',
      desc: '',
      args: [],
    );
  }

  /// `One of the required fields is empty`
  String get add_user_requiredFieldMissing {
    return Intl.message(
      'One of the required fields is empty',
      name: 'add_user_requiredFieldMissing',
      desc: '',
      args: [],
    );
  }

  /// `Please scan a barcode`
  String get barCode_scanner_error {
    return Intl.message(
      'Please scan a barcode',
      name: 'barCode_scanner_error',
      desc: '',
      args: [],
    );
  }

  /// `Barcode scanned successfully`
  String get barCode_scanner_success {
    return Intl.message(
      'Barcode scanned successfully',
      name: 'barCode_scanner_success',
      desc: '',
      args: [],
    );
  }

  /// `Print QR Code`
  String get qr_code_print {
    return Intl.message(
      'Print QR Code',
      name: 'qr_code_print',
      desc: '',
      args: [],
    );
  }

  /// `Share QR Code`
  String get qr_code_share {
    return Intl.message(
      'Share QR Code',
      name: 'qr_code_share',
      desc: '',
      args: [],
    );
  }

  /// `Print`
  String get print {
    return Intl.message('Print', name: 'print', desc: '', args: []);
  }

  /// `Was `
  String get customer_tile_lastVisit_1 {
    return Intl.message(
      'Was ',
      name: 'customer_tile_lastVisit_1',
      desc: '',
      args: [],
    );
  }

  /// `here today`
  String get customer_tile_lastVisit_2 {
    return Intl.message(
      'here today',
      name: 'customer_tile_lastVisit_2',
      desc: '',
      args: [],
    );
  }

  /// `here on the`
  String get customer_tile_lastVisit_3 {
    return Intl.message(
      'here on the',
      name: 'customer_tile_lastVisit_3',
      desc: '',
      args: [],
    );
  }

  /// `never here`
  String get customer_tile_lastVisit_4 {
    return Intl.message(
      'never here',
      name: 'customer_tile_lastVisit_4',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get customer_tile_lastVisit_5 {
    return Intl.message(
      '',
      name: 'customer_tile_lastVisit_5',
      desc: '',
      args: [],
    );
  }

  /// `Delete entry`
  String get customer_tile_deleteLastEntry {
    return Intl.message(
      'Delete entry',
      name: 'customer_tile_deleteLastEntry',
      desc: '',
      args: [],
    );
  }

  /// `{visitMoreThan14Days, select, true{Add new visit} false{Add Visit anyway}}`
  String customer_tile_addNewEntry(Object visitMoreThan14Days) {
    return Intl.select(
      visitMoreThan14Days,
      {'true': 'Add new visit', 'false': 'Add Visit anyway'},
      name: 'customer_tile_addNewEntry',
      desc: '',
      args: [visitMoreThan14Days],
    );
  }

  /// `Languages`
  String get main_page_languages {
    return Intl.message(
      'Languages',
      name: 'main_page_languages',
      desc: '',
      args: [],
    );
  }

  /// `Search users`
  String get main_page_searchUsers {
    return Intl.message(
      'Search users',
      name: 'main_page_searchUsers',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get main_page_add {
    return Intl.message('Add', name: 'main_page_add', desc: '', args: []);
  }

  /// `{isListView, select, true{Show as tiles?} false{Show as list?}}`
  String main_page_isListView(Object isListView) {
    return Intl.select(
      isListView,
      {'true': 'Show as tiles?', 'false': 'Show as list?'},
      name: 'main_page_isListView',
      desc: '',
      args: [isListView],
    );
  }

  /// `Statistics`
  String get main_page_statistic {
    return Intl.message(
      'Statistics',
      name: 'main_page_statistic',
      desc: '',
      args: [],
    );
  }

  /// `Search by name or scan a code to display users`
  String get main_page_emptyUserListText {
    return Intl.message(
      'Search by name or scan a code to display users',
      name: 'main_page_emptyUserListText',
      desc: '',
      args: [],
    );
  }

  /// `No matching user found!`
  String get main_page_noUserWithUUID {
    return Intl.message(
      'No matching user found!',
      name: 'main_page_noUserWithUUID',
      desc: '',
      args: [],
    );
  }

  /// `Scan QR Code`
  String get main_page_scanQrCode {
    return Intl.message(
      'Scan QR Code',
      name: 'main_page_scanQrCode',
      desc: '',
      args: [],
    );
  }

  /// `Country of origin:`
  String get stat_page_country {
    return Intl.message(
      'Country of origin:',
      name: 'stat_page_country',
      desc: '',
      args: [],
    );
  }

  /// `Has children:`
  String get stat_page_children {
    return Intl.message(
      'Has children:',
      name: 'stat_page_children',
      desc: '',
      args: [],
    );
  }

  /// `Total visits:`
  String get stat_page_visits {
    return Intl.message(
      'Total visits:',
      name: 'stat_page_visits',
      desc: '',
      args: [],
    );
  }

  /// `Miscellaneous:`
  String get stat_page_miscellaneous {
    return Intl.message(
      'Miscellaneous:',
      name: 'stat_page_miscellaneous',
      desc: '',
      args: [],
    );
  }

  /// `Already received something today`
  String get stat_page_alreadyGotToday {
    return Intl.message(
      'Already received something today',
      name: 'stat_page_alreadyGotToday',
      desc: '',
      args: [],
    );
  }

  /// `Visit recorded!`
  String get stat_page_savedVisit {
    return Intl.message(
      'Visit recorded!',
      name: 'stat_page_savedVisit',
      desc: '',
      args: [],
    );
  }

  /// `Delete last\nvisit`
  String get stat_page_removeLastVisit {
    return Intl.message(
      'Delete last\nvisit',
      name: 'stat_page_removeLastVisit',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete the last visit?`
  String get stat_page_removeLastVisitConfirmation {
    return Intl.message(
      'Are you sure you want to delete the last visit?',
      name: 'stat_page_removeLastVisitConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Last time clothes borrowed:`
  String get stat_page_lastTimeTookClothes {
    return Intl.message(
      'Last time clothes borrowed:',
      name: 'stat_page_lastTimeTookClothes',
      desc: '',
      args: [],
    );
  }

  /// `Day of the month`
  String get statistic_page_dayOfMonth {
    return Intl.message(
      'Day of the month',
      name: 'statistic_page_dayOfMonth',
      desc: '',
      args: [],
    );
  }

  /// `Number of visits`
  String get statistic_page_numberOfVisits {
    return Intl.message(
      'Number of visits',
      name: 'statistic_page_numberOfVisits',
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
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'ru'),
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
