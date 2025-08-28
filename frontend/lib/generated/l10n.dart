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
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `German`
  String get language_de {
    return Intl.message('German', name: 'language_de', desc: '', args: []);
  }

  /// `English`
  String get language_en {
    return Intl.message('English', name: 'language_en', desc: '', args: []);
  }

  /// `Fullscreen`
  String get fullscreen {
    return Intl.message('Fullscreen', name: 'fullscreen', desc: '', args: []);
  }

  /// `Mode`
  String get theme {
    return Intl.message('Mode', name: 'theme', desc: '', args: []);
  }

  /// `Search recipients`
  String get search_hint {
    return Intl.message(
      'Search recipients',
      name: 'search_hint',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add_user {
    return Intl.message('Add', name: 'add_user', desc: '', args: []);
  }

  /// `One of the required fields wasn't filled out`
  String get required_fields {
    return Intl.message(
      'One of the required fields wasn\'t filled out',
      name: 'required_fields',
      desc: '',
      args: [],
    );
  }

  /// `First name*`
  String get firt_name {
    return Intl.message('First name*', name: 'firt_name', desc: '', args: []);
  }

  /// `Last name*`
  String get last_name {
    return Intl.message('Last name*', name: 'last_name', desc: '', args: []);
  }

  /// `Date of birth*`
  String get birthdate {
    return Intl.message(
      'Date of birth*',
      name: 'birthdate',
      desc: '',
      args: [],
    );
  }

  /// `Nationality`
  String get country {
    return Intl.message('Nationality', name: 'country', desc: '', args: []);
  }

  /// `Other`
  String get other {
    return Intl.message('Other', name: 'other', desc: '', args: []);
  }

  /// `Cancel`
  String get dialog_cancel {
    return Intl.message('Cancel', name: 'dialog_cancel', desc: '', args: []);
  }

  /// `Confirm`
  String get dialog_confirm_button {
    return Intl.message(
      'Confirm',
      name: 'dialog_confirm_button',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get dialog_delete_button {
    return Intl.message(
      'Delete',
      name: 'dialog_delete_button',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this recipient?`
  String get delete_confirm {
    return Intl.message(
      'Are you sure you want to delete this recipient?',
      name: 'delete_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Tile view`
  String get tiles {
    return Intl.message('Tile view', name: 'tiles', desc: '', args: []);
  }

  /// `Was `
  String get was {
    return Intl.message('Was ', name: 'was', desc: '', args: []);
  }

  /// `today`
  String get today {
    return Intl.message('today', name: 'today', desc: '', args: []);
  }

  /// `last time `
  String get last_time {
    return Intl.message('last time ', name: 'last_time', desc: '', args: []);
  }

  /// `never`
  String get never {
    return Intl.message('never', name: 'never', desc: '', args: []);
  }

  /// ` there`
  String get there {
    return Intl.message(' there', name: 'there', desc: '', args: []);
  }

  /// `delete note`
  String get delete_note {
    return Intl.message('delete note', name: 'delete_note', desc: '', args: []);
  }

  /// `Mark new visit`
  String get mark_new_visit {
    return Intl.message(
      'Mark new visit',
      name: 'mark_new_visit',
      desc: '',
      args: [],
    );
  }

  /// `Still note`
  String get still_note {
    return Intl.message('Still note', name: 'still_note', desc: '', args: []);
  }

  /// `List view`
  String get list {
    return Intl.message('List view', name: 'list', desc: '', args: []);
  }

  /// `Statistics`
  String get statistics {
    return Intl.message('Statistics', name: 'statistics', desc: '', args: []);
  }

  /// ` Visits`
  String get visits {
    return Intl.message(' Visits', name: 'visits', desc: '', args: []);
  }

  /// `Day of month`
  String get day_of_month {
    return Intl.message(
      'Day of month',
      name: 'day_of_month',
      desc: '',
      args: [],
    );
  }

  /// `Number of visits`
  String get visit_counts {
    return Intl.message(
      'Number of visits',
      name: 'visit_counts',
      desc: '',
      args: [],
    );
  }

  /// `Enter a name or scan a barcode`
  String get no_items_text {
    return Intl.message(
      'Enter a name or scan a barcode',
      name: 'no_items_text',
      desc: '',
      args: [],
    );
  }

  /// `Scan barcode`
  String get scan_code {
    return Intl.message('Scan barcode', name: 'scan_code', desc: '', args: []);
  }

  /// `Print BarCode`
  String get print_code {
    return Intl.message(
      'Print BarCode',
      name: 'print_code',
      desc: '',
      args: [],
    );
  }

  /// `Print`
  String get print {
    return Intl.message('Print', name: 'print', desc: '', args: []);
  }

  /// `Share`
  String get share {
    return Intl.message('Share', name: 'share', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
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
