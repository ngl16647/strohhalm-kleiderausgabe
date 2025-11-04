import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:strohhalm_app/app_settings.dart';
import 'package:strohhalm_app/check_connection.dart';
import 'package:strohhalm_app/http_helper.dart';
import 'package:strohhalm_app/main.dart';
import 'package:strohhalm_app/user_and_visit.dart';
import 'package:strohhalm_app/utilities.dart';
import 'package:uuid/uuid.dart';
import 'database_helper.dart';
import 'dialog_helper.dart';
import 'generated/l10n.dart';


///Return type for the user-update/create dialog
class AddUserReturn{
  final User user;
  final bool deleted;

  const AddUserReturn({
    required this.user,
    required this.deleted
  });
}

///Add/update-user dialog
class AddUserDialog extends StatefulWidget {
  final User? user;

  static Future<dynamic> showAddUpdateUserDialog({
    required BuildContext context,
    User? user
  }) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddUserDialog(user: user);
      }
    );
  }

  const AddUserDialog({
    super.key,
    this.user,
  });

  @override
  State<AddUserDialog> createState() => AddUserDialogState();
}

class AddUserDialogState extends State<AddUserDialog> {
  final _firstNameController = TextEditingController();
  bool _firstNameError = false;
  final _lastNameController = TextEditingController();
  bool _lastNameError = false;
  final _dateController = TextEditingController();
  bool _dateError = false;
  final _noteController = TextEditingController();
  DateTime? _selectedDate;
  Country? _selectedCountry;
  ///if set to true, shows loadingCircle
  bool uploading = false;
  ///offline or online-mode
  bool _useServer = false;

  @override
  void initState() {
    super.initState();
    _useServer = AppSettingsManager.instance.settings.useServer ?? false;
    if(widget.user != null){
      _firstNameController.text = widget.user!.firstName;
      _lastNameController.text = widget.user!.lastName;
      _noteController.text = widget.user!.notes ?? "";
      _selectedDate = widget.user!.birthDay;
      _dateController.text = _selectedDate != null
          ? DateFormat("dd.MM.yyyy").format(_selectedDate!)
          : "";
      _selectedCountry = Country.tryParse(widget.user!.country);
      checkIntegrity();
    }
  }

  ///Checks if the country can be parsed and opens the countryList if not
  void checkIntegrity(){
    if(_selectedCountry != null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(context.mounted){
        await DialogHelper.dialogConfirmation(
          context: context,
          message: S.of(context).countryErrorMessage,
          acceptString: S.of(context).countryErrorButton,
          hasChoice: false,
          textSize: 16,
        );
        pickCountry();
      }
    });

  }

  ///opens the countryPicker-Dialog
  void pickCountry(){
    showCountryPicker(
      context: context,
      showSearch: true,
      searchAutofocus: true,
      showWorldWide: true,
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
      },
    );
  }

  ///Opens the Date-Dialog
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      initialDatePickerMode: DatePickerMode.year,

      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 31)),
      initialDate: _selectedDate ?? DateTime(1995),
      initialEntryMode: DatePickerEntryMode.calendar,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat("dd.MM.yyyy").format(_selectedDate!);
      });
    }
  }

  bool checkDate(String date){
    final regExMatch = RegExp(r"^\d{1,2}\.\d{1,2}\.\d{2,4}$");
    if(regExMatch.hasMatch(date)){
      List<String> parts = date.split(".");
      if(parts.length > 2 && parts[2].isNotEmpty){
        int year = int.parse(parts[2]);
        //Ridiculous future proof
        if(year < 100){
          if(year < int.parse(DateTime.now().year.toString().substring(2))){
            int yearPrefix = int.parse(DateTime.now().year.toString().substring(0,2));
            year = int.parse("$yearPrefix$year");
          } else{
            int yearPrefix = int.parse(DateTime.now().year.toString().substring(0,2))-1;
            year = int.parse("$yearPrefix$year");
          }
        }


        int month = int.parse(parts[1]);
        int day = int.parse(parts[0]);

        if(    year < DateTime.now().subtract(Duration(days: (365*110))).year
            || year > DateTime.now().year
            || (month > 12 || month < 1)
            || (day > 31 || day < 1)
        ){
          setState(() {_dateError = true;});
            return false;
        }

        _selectedDate = DateTime(year, month, day);
        setState(() {_dateError = false;});
        return true;
      } else {
        setState(() {
          _dateError = true;
        });
        return false;
      }
    } else {
      setState(() {
        _dateError = true;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).listTileTheme.tileColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(S.of(context).add_user_requiredFields, style: TextStyle(color: Theme.of(context).textTheme.titleSmall!.color?.withAlpha(100)), textAlign: TextAlign.start,),
                ),
                TextField(
                  onChanged: (ev) => setState(() => _firstNameError = false),
                  decoration: InputDecoration(
                    errorText: _firstNameError ? S.of(context).addUser_nameError : null,
                    labelText: S.of(context).add_user_firstName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  controller: _firstNameController,
                ),
                TextField(
                  onChanged: (ev) => setState(() => _lastNameError = false),
                  decoration: InputDecoration(
                    errorText: _lastNameError ? S.of(context).addUser_nameError : null,
                    labelText:  S.of(context).add_user_lastName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  controller: _lastNameController,
                ),
                Stack(
                    children: [
                      TextField(
                          onChanged: (ev){setState(() {
                            _dateController;
                          });},
                          onSubmitted: checkDate,
                          onTapOutside: (ev){
                            FocusScope.of(context).unfocus();
                            if(_dateController.text.isNotEmpty) checkDate(_dateController.text);
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                          ],
                          controller: _dateController,
                          decoration: InputDecoration(
                            errorText: _dateError ? S.of(context).addUser_dateError : null,
                            labelText: S.of(context).add_user_birthDay, //+ (_dateController.text.isNotEmpty ? " Bsp-Format: (01.01.1970 oder 1.1.70)" : ""),
                            hintText: S.of(context).addUser_dateExample,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium!.color?.withAlpha(150),
                          ),
                      ),
                      Positioned(
                          right: 0,
                          top: 0,
                          bottom: _dateError ? 18 : 0,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _pickDate,
                            child: Row(
                              spacing: 5,
                              children: [
                                SizedBox(width: 10,),
                                Text(S.of(context).addUser_openDatePicker),
                                Icon( Icons.calendar_today),
                                SizedBox(width: 10)
                              ],
                            ),
                          )
                      ),
                    ],
                ),
                InkWell(
                  onTap: pickCountry,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.user == null && _selectedCountry == null
                              ? S.of(context).addUser_selectCountry
                              : _selectedCountry != null
                                ? Utilities.getLocalizedCountryNameFromCode(context, _selectedCountry!.countryCode)
                                : widget.user!.country,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium!.color?.withAlpha(150),
                          ),
                        ),
                        Icon(Icons.public),
                      ],
                    ),
                  ),
                ),
                TextField(
                  minLines: 1,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: S.of(context).add_user_miscellaneous,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  controller: _noteController,
                ),
              ],
            ),
            SizedBox(height: 20),
            if(widget.user != null) ElevatedButton.icon(
                onPressed: () async {
                  bool? result = await DialogHelper.dialogConfirmation(
                      context: context,
                      message: S.of(context).add_user_deleteMessage,
                      hasChoice:  true);
                  if(result != null){
                    navigatorKey.currentState?.pop(AddUserReturn(user: widget.user!, deleted: true));
                  }
                },
                label: Text(S.of(context).delete),
              icon: Icon(Icons.delete),
              style: TextButton.styleFrom(
                minimumSize: Size(double.infinity, 40),
                backgroundColor: Colors.redAccent.shade100.withAlpha(200)
              ),
            ),
            if(widget.user != null) SizedBox(height: 15,),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppSettingsManager.instance.settings.darkMode ?? false ?  Colors.grey.shade700 :  Colors.grey.shade300
                    ),
                    onPressed: () => Navigator.of(context).pop(null),
                    child: Text(S.of(context).cancel),
                  ),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await saveChange(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppSettingsManager.instance.settings.selectedColor!.withAlpha(150)
                    ),
                    child: uploading ? SizedBox(
                      height: 24, //must be smaller than 40 to look good
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ) : Text(widget.user != null ? S.of(context).update : S.of(context).confirm),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> saveChange(BuildContext context) async {
    _firstNameController.text = _firstNameController.text.trim();
    _lastNameController.text = _lastNameController.text.trim();
    if(_firstNameController.text.isEmpty || _lastNameController.text.isEmpty || _dateController.text.isEmpty){
      setState(() {
        if(_firstNameController.text.isEmpty) _firstNameError = true;
        if(_lastNameController.text.isEmpty) _lastNameError = true;
      });
      Utilities.showToast(context: context, title: S.of(context).fail, description: S.of(context).add_user_requiredFieldMissing, isError: true);
      return;
    }
    if(!checkDate(_dateController.text)){
      Utilities.showToast(context: context, title: S.of(context).fail, description: S.of(context).addUser_dateError, isError: true);
      return;
    }
    setState(() {
      uploading = true;
    });
    if(widget.user != null){
      User user = widget.user!.copyWith(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          birthDay: _selectedDate!,
          //If new User use WW or selected country
          //If updating:
          //   If no country selected and existing country isNotEmpty => take existing country
          //   If no country selected and existing country isEmpty => set to worldwide
          country: widget.user!.country.isNotEmpty && _selectedCountry == null
              ? widget.user!.country
              :  _selectedCountry == null
              ? Country.worldWide.countryCode
              :_selectedCountry!.countryCode,
          notes: _noteController.text,
          lastVisit: widget.user!.lastVisit
      );
      if(widget.user!.equals(user)){
        Navigator.of(context).pop(null);
        return;
      }
      bool justChangedNotes = widget.user!.equalsExceptNotes(user);
      bool? result;
      _useServer
          ? result = await HttpHelper().updateCustomer(user)
          : result = await DatabaseHelper().updateUser(user, !justChangedNotes);

      if(context.mounted) {
        Utilities.showToast(
            context: context,
            title: result == null || !result
                ? S.of(context).fail
                : S.of(context).success,
            description: result == null
                ? S.of(context).update_failed
                : !result
                ? S.of(context).same_user_exists
                : S.of(context).update_success,
            isError: result == null || !result
        );
      }
      setState(() {
        uploading = false;
      });
      if(context.mounted && result != null && result) navigatorKey.currentState?.pop(AddUserReturn(user: user, deleted: false));
    } else {
      final uuId = const Uuid().v4(); //v3 would allow hashing of name, birthday => Autodetect collisions, v4 is most used and random
      User userWithoutValidId = User(
          id: -1,
          uuId: uuId,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          birthDay: _selectedDate!,
          country: _selectedCountry == null ? Country.worldWide.countryCode : _selectedCountry!.countryCode,
          notes: _noteController.text,
          lastVisit: null);

      int? id;
      bool existed = false;
      if(_useServer){
        id = await HttpHelper().addCustomer(
            user: userWithoutValidId
        );
      } else {
        AddUpdateUserReturnType? result = await DatabaseHelper().addUser(
            user: userWithoutValidId
        );
        if(result != null && !result.existed){
          id = result.id;
        }
        if(result != null && result.existed){
          existed = true;
        }
      }

      User? userWithId;
      if(id != null && id != -1){
        userWithId = userWithoutValidId.copyWith(newId: id);
      }

      setState(() => uploading = false);
      if(context.mounted){
        Utilities.showToast(
          context: context,
          title: id == null || id == -1
              ? S.of(context).fail
              : S.of(context).success,
          description: id == null && !existed
              ? S.of(context).add_failed
              : existed
              ? S.of(context).same_user_exists
              : S.of(context).add_success,
          isError: id == null || id == -1,
        );
      }
      if((id == null || id == -1) && _useServer && context.mounted) context.read<ConnectionProvider>().periodicCheckConnection();
      if(context.mounted && userWithId != null) navigatorKey.currentState?.pop(AddUserReturn(user: userWithId, deleted: false));
    }
  }
}