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

  /// `Today`
  String get today {
    return Intl.message('Today', name: 'today', desc: '', args: []);
  }

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Success`
  String get success {
    return Intl.message('Success', name: 'success', desc: '', args: []);
  }

  /// `Failure`
  String get fail {
    return Intl.message('Failure', name: 'fail', desc: '', args: []);
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

  /// `Are you sure you want to permanently delete this person?`
  String get add_user_deleteMessage {
    return Intl.message(
      'Are you sure you want to permanently delete this person?',
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

  /// `Never <bold>visited</bold>`
  String get customer_tile_lastVisit_never {
    return Intl.message(
      'Never <bold>visited</bold>',
      name: 'customer_tile_lastVisit_never',
      desc: '',
      args: [],
    );
  }

  /// `Visited <bold>today</bold>`
  String get customer_tile_lastVisit_today {
    return Intl.message(
      'Visited <bold>today</bold>',
      name: 'customer_tile_lastVisit_today',
      desc: '',
      args: [],
    );
  }

  /// `Last visited on <bold>{dateString}</bold>`
  String customer_tile_lastVisit_onDate(Object dateString) {
    return Intl.message(
      'Last visited on <bold>$dateString</bold>',
      name: 'customer_tile_lastVisit_onDate',
      desc: '',
      args: [dateString],
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

  /// `Search persons`
  String get main_page_searchUsers {
    return Intl.message(
      'Search persons',
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

  /// `Search by name or scan a code to display persons`
  String get main_page_emptyUserListText {
    return Intl.message(
      'Search by name or scan a code to display persons',
      name: 'main_page_emptyUserListText',
      desc: '',
      args: [],
    );
  }

  /// `No matching person found!`
  String get main_page_noUserWithUUID {
    return Intl.message(
      'No matching person found!',
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

  /// `{isDarkMode, select, true{Light Theme} false{Dark Theme}}`
  String main_page_theme(Object isDarkMode) {
    return Intl.select(
      isDarkMode,
      {'true': 'Light Theme', 'false': 'Dark Theme'},
      name: 'main_page_theme',
      desc: '',
      args: [isDarkMode],
    );
  }

  /// `Fullscreen`
  String get main_page_fullScreen {
    return Intl.message(
      'Fullscreen',
      name: 'main_page_fullScreen',
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

  /// `Visits:`
  String get stat_page_visits {
    return Intl.message(
      'Visits:',
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

  /// `{showYear, select, true{Month} false{Day}}`
  String statistic_page_xAxis(Object showYear) {
    return Intl.select(
      showYear,
      {'true': 'Month', 'false': 'Day'},
      name: 'statistic_page_xAxis',
      desc: '',
      args: [showYear],
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

  /// `{count, plural, one{Visit} other{Visits}}`
  String statistic_page_visits(num count) {
    return Intl.plural(
      count,
      one: 'Visit',
      other: 'Visits',
      name: 'statistic_page_visits',
      desc: '',
      args: [count],
    );
  }

  /// `{showYear, select, true{To month view} false{To year view}}`
  String statistic_page_switchYearDisplay(Object showYear) {
    return Intl.select(
      showYear,
      {'true': 'To month view', 'false': 'To year view'},
      name: 'statistic_page_switchYearDisplay',
      desc: '',
      args: [showYear],
    );
  }

  /// `Show top {cutOffNumber} countries of {overAllNumberOfCountries}`
  String statistic_page_show_top_countries(
    Object cutOffNumber,
    Object overAllNumberOfCountries,
  ) {
    return Intl.message(
      'Show top $cutOffNumber countries of $overAllNumberOfCountries',
      name: 'statistic_page_show_top_countries',
      desc: '',
      args: [cutOffNumber, overAllNumberOfCountries],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Theme`
  String get settings_themeMode_Title {
    return Intl.message(
      'Theme',
      name: 'settings_themeMode_Title',
      desc: '',
      args: [],
    );
  }

  /// `Light or Dark mode`
  String get settings_themeMode_desc {
    return Intl.message(
      'Light or Dark mode',
      name: 'settings_themeMode_desc',
      desc: '',
      args: [],
    );
  }

  /// `Banner / Image`
  String get settings_banner_title {
    return Intl.message(
      'Banner / Image',
      name: 'settings_banner_title',
      desc: '',
      args: [],
    );
  }

  /// `Image displayed at the top of the page.\nAlso used as header for printing`
  String get settings_banner_desc {
    return Intl.message(
      'Image displayed at the top of the page.\\nAlso used as header for printing',
      name: 'settings_banner_desc',
      desc: '',
      args: [],
    );
  }

  /// `Pick color`
  String get settings_pick_Color {
    return Intl.message(
      'Pick color',
      name: 'settings_pick_Color',
      desc: '',
      args: [],
    );
  }

  /// `Color`
  String get settings_color_title {
    return Intl.message(
      'Color',
      name: 'settings_color_title',
      desc: '',
      args: [],
    );
  }

  /// `Accent color for the application`
  String get settings_color_desc {
    return Intl.message(
      'Accent color for the application',
      name: 'settings_color_desc',
      desc: '',
      args: [],
    );
  }

  /// `Server Settings`
  String get settings_server_title {
    return Intl.message(
      'Server Settings',
      name: 'settings_server_title',
      desc: '',
      args: [],
    );
  }

  /// `If a server is to be used, URL and password can be entered here`
  String get settings_server_desc {
    return Intl.message(
      'If a server is to be used, URL and password can be entered here',
      name: 'settings_server_desc',
      desc: '',
      args: [],
    );
  }

  /// `Use server?`
  String get settings_server_switch {
    return Intl.message(
      'Use server?',
      name: 'settings_server_switch',
      desc: '',
      args: [],
    );
  }

  /// `Server URL / IP`
  String get settings_server_urlHint {
    return Intl.message(
      'Server URL / IP',
      name: 'settings_server_urlHint',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get settings_server_tokenHint {
    return Intl.message(
      'Password',
      name: 'settings_server_tokenHint',
      desc: '',
      args: [],
    );
  }

  /// `The image's aspect ratio is too small!\nIt should be at least 6:1`
  String get banner_designer_wrongAspectRatio {
    return Intl.message(
      'The image\'s aspect ratio is too small!\nIt should be at least 6:1',
      name: 'banner_designer_wrongAspectRatio',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get banner_designer_pick {
    return Intl.message(
      'Select',
      name: 'banner_designer_pick',
      desc: '',
      args: [],
    );
  }

  /// `Just selected!`
  String get banner_designer_picked {
    return Intl.message(
      'Just selected!',
      name: 'banner_designer_picked',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get banner_designer_delete {
    return Intl.message(
      'Delete',
      name: 'banner_designer_delete',
      desc: '',
      args: [],
    );
  }

  /// `New`
  String get banner_designer_new {
    return Intl.message('New', name: 'banner_designer_new', desc: '', args: []);
  }

  /// `Existing`
  String get banner_designer_existing {
    return Intl.message(
      'Existing',
      name: 'banner_designer_existing',
      desc: '',
      args: [],
    );
  }

  /// `Image`
  String get banner_designer_bannerImageSubTitle {
    return Intl.message(
      'Image',
      name: 'banner_designer_bannerImageSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `Designer`
  String get banner_designer_bannerDesignerSubTitle {
    return Intl.message(
      'Designer',
      name: 'banner_designer_bannerDesignerSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `Banner Image`
  String get banner_designer_bannerImageTitle {
    return Intl.message(
      'Banner Image',
      name: 'banner_designer_bannerImageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Banner Designer`
  String get banner_designer_bannerDesignerTitle {
    return Intl.message(
      'Banner Designer',
      name: 'banner_designer_bannerDesignerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get banner_designer_titleText {
    return Intl.message(
      'Title',
      name: 'banner_designer_titleText',
      desc: '',
      args: [],
    );
  }

  /// `No image selected`
  String get banner_designer_noImage {
    return Intl.message(
      'No image selected',
      name: 'banner_designer_noImage',
      desc: '',
      args: [],
    );
  }

  /// `Upload image`
  String get banner_designer_uploadImage {
    return Intl.message(
      'Upload image',
      name: 'banner_designer_uploadImage',
      desc: '',
      args: [],
    );
  }

  /// `inactive Visitors`
  String get deletion_request_page_title {
    return Intl.message(
      'inactive Visitors',
      name: 'deletion_request_page_title',
      desc: '',
      args: [],
    );
  }

  /// `Last Visit:`
  String get deletion_request_page_lastVisit {
    return Intl.message(
      'Last Visit:',
      name: 'deletion_request_page_lastVisit',
      desc: '',
      args: [],
    );
  }

  /// `reset Visitor`
  String get deletion_request_page_resetUser {
    return Intl.message(
      'reset Visitor',
      name: 'deletion_request_page_resetUser',
      desc: '',
      args: [],
    );
  }

  /// `delete Visitor`
  String get deletion_request_page_delete {
    return Intl.message(
      'delete Visitor',
      name: 'deletion_request_page_delete',
      desc: '',
      args: [],
    );
  }

  /// `Delete All`
  String get deletion_request_page_deleteAll {
    return Intl.message(
      'Delete All',
      name: 'deletion_request_page_deleteAll',
      desc: '',
      args: [],
    );
  }

  /// `Delete All old Customers at once`
  String get deletion_request_page_deleteAllDesc {
    return Intl.message(
      'Delete All old Customers at once',
      name: 'deletion_request_page_deleteAllDesc',
      desc: '',
      args: [],
    );
  }

  /// `Deletion failed`
  String get deletion_failed {
    return Intl.message(
      'Deletion failed',
      name: 'deletion_failed',
      desc: '',
      args: [],
    );
  }

  /// `Deletion successful`
  String get deletion_success {
    return Intl.message(
      'Deletion successful',
      name: 'deletion_success',
      desc: '',
      args: [],
    );
  }

  /// `Adding failed`
  String get add_failed {
    return Intl.message(
      'Adding failed',
      name: 'add_failed',
      desc: '',
      args: [],
    );
  }

  /// `Adding successful`
  String get add_success {
    return Intl.message(
      'Adding successful',
      name: 'add_success',
      desc: '',
      args: [],
    );
  }

  /// `Update failed`
  String get update_failed {
    return Intl.message(
      'Update failed',
      name: 'update_failed',
      desc: '',
      args: [],
    );
  }

  /// `Update successful`
  String get update_success {
    return Intl.message(
      'Update successful',
      name: 'update_success',
      desc: '',
      args: [],
    );
  }

  /// `Invalid number!\nPlease enter a correct number`
  String get number_fail {
    return Intl.message(
      'Invalid number!\nPlease enter a correct number',
      name: 'number_fail',
      desc: '',
      args: [],
    );
  }

  /// `Failed UuId Check!\nMake sure your Keyboard-Language (Left-Alt + Left-Shift) is the same as the Barcode-Scanner!`
  String get uuId_fail_keyboard {
    return Intl.message(
      'Failed UuId Check!\nMake sure your Keyboard-Language (Left-Alt + Left-Shift) is the same as the Barcode-Scanner!',
      name: 'uuId_fail_keyboard',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =1{Visit} other{Visits}}`
  String visit_plural(num count) {
    return Intl.plural(
      count,
      one: 'Visit',
      other: 'Visits',
      name: 'visit_plural',
      desc: '',
      args: [count],
    );
  }

  /// `{visitorCount, plural, =1{# Visitor} other{# Visitors}}\nhave {visitCount} {visitCount, plural, =1{Visit} other{Visits}}`
  String statistic_page_visitsPerVisitor(num visitorCount, num visitCount) {
    return Intl.message(
      '${Intl.plural(visitorCount, one: '# Visitor', other: '# Visitors')}\nhave $visitCount ${Intl.plural(visitCount, one: 'Visit', other: 'Visits')}',
      name: 'statistic_page_visitsPerVisitor',
      desc: '',
      args: [visitorCount, visitCount],
    );
  }

  /// `Besucher\nhaben`
  String get statistic_page_visitDesc {
    return Intl.message(
      'Besucher\nhaben',
      name: 'statistic_page_visitDesc',
      desc: '',
      args: [],
    );
  }

  /// `Besucher pro Besuch-Anzahl`
  String get statistic_page_visitsPerPerson {
    return Intl.message(
      'Besucher pro Besuch-Anzahl',
      name: 'statistic_page_visitsPerPerson',
      desc: '',
      args: [],
    );
  }

  /// `Anzahl von Besuchern`
  String get statistic_page_visitsPerPerson_Persons {
    return Intl.message(
      'Anzahl von Besuchern',
      name: 'statistic_page_visitsPerPerson_Persons',
      desc: '',
      args: [],
    );
  }

  /// `Anzahl von Besuchern`
  String get statistic_page_visitsPerPerson_Visits {
    return Intl.message(
      'Anzahl von Besuchern',
      name: 'statistic_page_visitsPerPerson_Visits',
      desc: '',
      args: [],
    );
  }

  /// `Keine Daten oder Internetverbindung.\nSobald wieder Internet verfügbar ist werden die Daten automatisch geladen!`
  String get statistic_page_noData {
    return Intl.message(
      'Keine Daten oder Internetverbindung.\nSobald wieder Internet verfügbar ist werden die Daten automatisch geladen!',
      name: 'statistic_page_noData',
      desc: '',
      args: [],
    );
  }

  /// `User with same Data already existed!`
  String get same_user_exists {
    return Intl.message(
      'User with same Data already existed!',
      name: 'same_user_exists',
      desc: '',
      args: [],
    );
  }

  /// `Keine Verbindung zum Internet`
  String get no_internet {
    return Intl.message(
      'Keine Verbindung zum Internet',
      name: 'no_internet',
      desc: '',
      args: [],
    );
  }

  /// `Keine Verbindung zum Server`
  String get no_server {
    return Intl.message(
      'Keine Verbindung zum Server',
      name: 'no_server',
      desc: '',
      args: [],
    );
  }

  /// `Verbindung wieder hergestellt!`
  String get reconnected {
    return Intl.message(
      'Verbindung wieder hergestellt!',
      name: 'reconnected',
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
