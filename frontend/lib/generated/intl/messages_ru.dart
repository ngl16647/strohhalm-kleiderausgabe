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

  static String m2(visitMoreThan14Days) =>
      "${Intl.select(visitMoreThan14Days, {'true': 'Запланировать новый визит', 'false': 'Все равно отметить'})}";

  static String m3(dateString) =>
      "Был <bold>${dateString}</bold> в последний раз";

  static String m7(isListView) =>
      "${Intl.select(isListView, {'true': 'Показывать как плитки?', 'false': 'Показывать как список?'})}";

  static String m8(useServer) => "Поиск пользователей";

  static String m9(useServer) => "Статистика";

  static String m10(isDarkMode) =>
      "${Intl.select(isDarkMode, {'true': 'Светлая тема', 'false': 'Тёмная тема'})}";

  static String m11(cutOffNumber, overAllNumberOfCountries) =>
      "Показать топ ${cutOffNumber} стран из ${overAllNumberOfCountries}";

  static String m12(showYear) =>
      "${Intl.select(showYear, {'true': 'к просмотру по месяцам', 'false': 'к просмотру по годам'})}";

  static String m13(count) =>
      "${Intl.plural(count, one: 'Посещение', other: 'Посещения')}";

  static String m15(showYear) =>
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
    "banner_designer_bannerDesignerSubTitle":
        MessageLookupByLibrary.simpleMessage("Конструктор"),
    "banner_designer_bannerDesignerTitle": MessageLookupByLibrary.simpleMessage(
      "Конструктор баннера",
    ),
    "banner_designer_bannerImageSubTitle": MessageLookupByLibrary.simpleMessage(
      "Изображение",
    ),
    "banner_designer_bannerImageTitle": MessageLookupByLibrary.simpleMessage(
      "Изображение баннера",
    ),
    "banner_designer_delete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "banner_designer_existing": MessageLookupByLibrary.simpleMessage(
      "Существующее",
    ),
    "banner_designer_new": MessageLookupByLibrary.simpleMessage("Новое"),
    "banner_designer_noImage": MessageLookupByLibrary.simpleMessage(
      "Изображение не выбрано",
    ),
    "banner_designer_pick": MessageLookupByLibrary.simpleMessage("Выбрать"),
    "banner_designer_picked": MessageLookupByLibrary.simpleMessage(
      "Только что выбрано!",
    ),
    "banner_designer_titleText": MessageLookupByLibrary.simpleMessage(
      "Заголовок",
    ),
    "banner_designer_uploadImage": MessageLookupByLibrary.simpleMessage(
      "Загрузить изображение",
    ),
    "banner_designer_wrongAspectRatio": MessageLookupByLibrary.simpleMessage(
      "Соотношение сторон изображения слишком маленькое!\nОно должно быть не менее 6:1",
    ),
    "barCode_scanner_error": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, отсканируйте штрихкод!",
    ),
    "barCode_scanner_success": MessageLookupByLibrary.simpleMessage(
      "Штрихкод успешно отсканирован",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "close": MessageLookupByLibrary.simpleMessage("Закрыть"),
    "confirm": MessageLookupByLibrary.simpleMessage("Подтвердить"),
    "customer_tile_addNewEntry": m2,
    "customer_tile_deleteLastEntry": MessageLookupByLibrary.simpleMessage(
      "Удалить запись",
    ),
    "customer_tile_lastVisit_never": MessageLookupByLibrary.simpleMessage(
      "Еще <bold>не был</bold>",
    ),
    "customer_tile_lastVisit_onDate": m3,
    "customer_tile_lastVisit_today": MessageLookupByLibrary.simpleMessage(
      "Был <bold>сегодня</bold>",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "deletion_failed": MessageLookupByLibrary.simpleMessage(
      "Удаление не удалось",
    ),
    "deletion_success": MessageLookupByLibrary.simpleMessage(
      "Удаление успешно",
    ),
    "fail": MessageLookupByLibrary.simpleMessage("Ошибка"),
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
    "main_page_isListView": m7,
    "main_page_languages": MessageLookupByLibrary.simpleMessage("Языки"),
    "main_page_noUserWithUUID": MessageLookupByLibrary.simpleMessage(
      "Соответствующий пользователь не найден!",
    ),
    "main_page_scanQrCode": MessageLookupByLibrary.simpleMessage(
      "Сканировать QR-код",
    ),
    "main_page_searchUsers": m8,
    "main_page_statistic": m9,
    "main_page_theme": m10,
    "no": MessageLookupByLibrary.simpleMessage("Нет"),
    "number_fail": MessageLookupByLibrary.simpleMessage(
      "Неверное число!\nПожалуйста, введите правильное число",
    ),
    "print": MessageLookupByLibrary.simpleMessage("Печать"),
    "qr_code_print": MessageLookupByLibrary.simpleMessage("Печать QR-кода"),
    "qr_code_share": MessageLookupByLibrary.simpleMessage(
      "Поделиться QR-кодом",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "settings_banner_desc": MessageLookupByLibrary.simpleMessage(
      "Изображение, отображаемое в верхней части страницы.\nТакже используется как заголовок для печати",
    ),
    "settings_banner_title": MessageLookupByLibrary.simpleMessage(
      "Баннер / Изображение",
    ),
    "settings_color_desc": MessageLookupByLibrary.simpleMessage(
      "Акцентный цвет приложения",
    ),
    "settings_color_title": MessageLookupByLibrary.simpleMessage("Цвет"),
    "settings_pick_Color": MessageLookupByLibrary.simpleMessage("Выбрать цвет"),
    "settings_server_desc": MessageLookupByLibrary.simpleMessage(
      "Если используется сервер, здесь можно ввести URL и пароль",
    ),
    "settings_server_switch": MessageLookupByLibrary.simpleMessage(
      "Использовать сервер?",
    ),
    "settings_server_title": MessageLookupByLibrary.simpleMessage(
      "Настройки сервера",
    ),
    "settings_server_tokenHint": MessageLookupByLibrary.simpleMessage("Пароль"),
    "settings_server_urlHint": MessageLookupByLibrary.simpleMessage(
      "URL / IP сервера",
    ),
    "settings_themeMode_Title": MessageLookupByLibrary.simpleMessage("Тема"),
    "settings_themeMode_desc": MessageLookupByLibrary.simpleMessage(
      "Светлая или тёмная тема",
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
    "statistic_page_show_top_countries": m11,
    "statistic_page_switchYearDisplay": m12,
    "statistic_page_visits": m13,
    "statistic_page_xAxis": m15,
    "success": MessageLookupByLibrary.simpleMessage("Успех"),
    "today": MessageLookupByLibrary.simpleMessage("сегодня"),
    "update_failed": MessageLookupByLibrary.simpleMessage(
      "Обновление не удалось",
    ),
    "update_success": MessageLookupByLibrary.simpleMessage(
      "Обновление успешно",
    ),
    "uuId_fail_keyboard": MessageLookupByLibrary.simpleMessage(
      "Ошибка проверки UUID!\nУбедитесь, что язык клавиатуры (Левый Alt + Левый Shift) совпадает с языком сканера штрих-кодов!",
    ),
    "yes": MessageLookupByLibrary.simpleMessage("Да"),
  };
}
