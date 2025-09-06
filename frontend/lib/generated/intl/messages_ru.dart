// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ru';

  static String m0(visitMoreThan14Days) =>
      "${Intl.select(visitMoreThan14Days, {'true': 'Запланировать новый визит', 'false': 'Все равно отметить'})}";

  static String m1(dateString) =>
      "Был <bold>${dateString}</bold> в последний раз";

  static String m2(isListView) =>
      "${Intl.select(isListView, {'true': 'Показывать как плитки?', 'false': 'Показывать как список?'})}";

  static String m3(isDarkMode) =>
      "${Intl.select(isDarkMode, {'true': 'Светлая тема', 'false': 'Тёмная тема'})}";

  static String m4(cutOffNumber, overAllNumberOfCountries) =>
      "Показать топ ${cutOffNumber} стран из ${overAllNumberOfCountries}";

  static String m5(showYear) =>
      "${Intl.select(showYear, {'true': 'к просмотру по месяцам', 'false': 'к просмотру по годам'})}";

  static String m6(count) =>
      "${Intl.plural(count, one: 'Посещение', other: 'Посещения')}";

  static String m7(showYear) =>
      "${Intl.select(showYear, {'true': 'Месяц', 'false': 'День'})}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accept": MessageLookupByLibrary.simpleMessage("Принять"),
    "add_user_birthDay": MessageLookupByLibrary.simpleMessage(
      "Выберите дату рождения*",
    ),
    "add_user_deleteMessage": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите безвозвратно удалить пользователя?",
    ),
    "add_user_firstName": MessageLookupByLibrary.simpleMessage("Имя*"),
    "add_user_lastName": MessageLookupByLibrary.simpleMessage("Фамилия*"),
    "add_user_miscellaneous": MessageLookupByLibrary.simpleMessage("Разное"),
    "add_user_requiredFieldMissing": MessageLookupByLibrary.simpleMessage(
      "Одно из обязательных полей пустое",
    ),
    "add_user_requiredFields": MessageLookupByLibrary.simpleMessage(
      "* Обязательные поля",
    ),
    "application_name": MessageLookupByLibrary.simpleMessage(
      "Распределение одежды Straw",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Назад"),
    "barCode_scanner_error": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, отсканируйте штрихкод!",
    ),
    "barCode_scanner_success": MessageLookupByLibrary.simpleMessage(
      "Штрихкод успешно отсканирован",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "close": MessageLookupByLibrary.simpleMessage("Закрыть"),
    "confirm": MessageLookupByLibrary.simpleMessage("Подтвердить"),
    "customer_tile_addNewEntry": m0,
    "customer_tile_deleteLastEntry": MessageLookupByLibrary.simpleMessage(
      "Удалить запись",
    ),
    "customer_tile_lastVisit_never": MessageLookupByLibrary.simpleMessage(
      "Еще <bold>не был</bold>",
    ),
    "customer_tile_lastVisit_onDate": m1,
    "customer_tile_lastVisit_today": MessageLookupByLibrary.simpleMessage(
      "Был <bold>сегодня</bold>",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "language_de": MessageLookupByLibrary.simpleMessage("Немецкий"),
    "language_en": MessageLookupByLibrary.simpleMessage("Английский"),
    "language_ru": MessageLookupByLibrary.simpleMessage("Русский"),
    "main_page_add": MessageLookupByLibrary.simpleMessage("Добавить"),
    "main_page_emptyUserListText": MessageLookupByLibrary.simpleMessage(
      "Поиск по имени или сканирование кода для отображения пользователей",
    ),
    "main_page_fullScreen": MessageLookupByLibrary.simpleMessage(
      "Полноэкранный режим",
    ),
    "main_page_isListView": m2,
    "main_page_languages": MessageLookupByLibrary.simpleMessage("Языки"),
    "main_page_noUserWithUUID": MessageLookupByLibrary.simpleMessage(
      "Соответствующий пользователь не найден!",
    ),
    "main_page_scanQrCode": MessageLookupByLibrary.simpleMessage(
      "Сканировать QR-код",
    ),
    "main_page_searchUsers": MessageLookupByLibrary.simpleMessage(
      "Поиск пользователей",
    ),
    "main_page_statistic": MessageLookupByLibrary.simpleMessage("Статистика"),
    "main_page_theme": m3,
    "no": MessageLookupByLibrary.simpleMessage("Нет"),
    "print": MessageLookupByLibrary.simpleMessage("Печать"),
    "qr_code_print": MessageLookupByLibrary.simpleMessage("Печать QR-кода"),
    "qr_code_share": MessageLookupByLibrary.simpleMessage(
      "Поделиться QR-кодом",
    ),
    "stat_page_alreadyGotToday": MessageLookupByLibrary.simpleMessage(
      "Сегодня уже получил что-то",
    ),
    "stat_page_children": MessageLookupByLibrary.simpleMessage("Есть дети:"),
    "stat_page_country": MessageLookupByLibrary.simpleMessage(
      "Страна происхождения:",
    ),
    "stat_page_lastTimeTookClothes": MessageLookupByLibrary.simpleMessage(
      "Последний раз брал одежду:",
    ),
    "stat_page_miscellaneous": MessageLookupByLibrary.simpleMessage("Разное:"),
    "stat_page_removeLastVisit": MessageLookupByLibrary.simpleMessage(
      "Удалить последний\nвизит",
    ),
    "stat_page_removeLastVisitConfirmation":
        MessageLookupByLibrary.simpleMessage(
          "Вы уверены, что хотите удалить последний визит?",
        ),
    "stat_page_savedVisit": MessageLookupByLibrary.simpleMessage(
      "Визит зафиксирован!",
    ),
    "stat_page_visits": MessageLookupByLibrary.simpleMessage("Всего визитов:"),
    "statistic_page_numberOfVisits": MessageLookupByLibrary.simpleMessage(
      "Количество посещений",
    ),
    "statistic_page_show_top_countries": m4,
    "statistic_page_switchYearDisplay": m5,
    "statistic_page_visits": m6,
    "statistic_page_xAxis": m7,
    "today": MessageLookupByLibrary.simpleMessage("сегодня"),
    "yes": MessageLookupByLibrary.simpleMessage("Да"),
  };
}
