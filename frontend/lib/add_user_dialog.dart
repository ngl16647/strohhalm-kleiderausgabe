import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:strohhalm_app/app_settings.dart';
import 'package:strohhalm_app/http_helper.dart';
import 'package:strohhalm_app/main.dart';
import 'package:strohhalm_app/user.dart';
import 'package:strohhalm_app/utilities.dart';
import 'package:uuid/uuid.dart';
import 'database_helper.dart';
import 'dialog_helper.dart';
import 'generated/l10n.dart';

class AddUserReturn{
  final User user;
  final bool deleted;

  const AddUserReturn({
    required this.user,
    required this.deleted
  });
}

class AddUserDialog extends StatefulWidget {
  final User? user;

  static Future<dynamic> showAddUpdateUserDialog(BuildContext context, User? user) async {
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
  final _lastNameController = TextEditingController();
  final _miscellaneousController = TextEditingController();
  DateTime? _selectedDate;
  Country _selectedCountry = Country.worldWide;
  bool uploading = false;
  bool _useServer = false;

  @override
  void initState() {
    _useServer = AppSettingsManager.instance.settings.useServer ?? false;
    if(widget.user != null){
      _firstNameController.text = widget.user!.firstName;
      _lastNameController.text = widget.user!.lastName;
      _miscellaneousController.text = widget.user!.notes ?? "";

      _selectedDate = widget.user!.birthDay;
      _selectedCountry = Country.tryParse(widget.user!.country) ?? Country.worldWide;
    }
    super.initState();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 31)),
      initialDate: _selectedDate ?? DateTime(1995),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
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
                  decoration: InputDecoration(
                    hintText: S.of(context).add_user_firstName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  controller: _firstNameController,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: S.of(context).add_user_lastName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  controller: _lastNameController,
                ),
                InkWell(
                  onTap: _pickDate,
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
                          _selectedDate != null
                              ? DateFormat("dd.MM.yyyy").format(_selectedDate!)
                              : S.of(context).add_user_birthDay,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium!.color?.withAlpha(150),
                          ),
                        ),
                        Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    showCountryPicker(
                      context: context,
                      showSearch: true,
                      showWorldWide: true,
                      onSelect: (Country country) {
                        setState(() {
                          _selectedCountry = country;
                        });
                      },
                    );
                  },
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
                        CountryLocalizations.of(context)?.countryName(countryCode: _selectedCountry.countryCode) ?? _selectedCountry.name,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium!.color?.withAlpha(150),
                          ),
                        ),
                        Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: S.of(context).add_user_miscellaneous,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  controller: _miscellaneousController,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if(widget.user != null) TextButton.icon(
                onPressed: () async {
                  bool? result = await DialogHelper.dialogConfirmation(context, S.of(context).add_user_deleteMessage, true);
                  if(result != null){
                    navigatorKey.currentState?.pop(AddUserReturn(user: widget.user!, deleted: true));
                  }
                },
                label: Text(S.of(context).delete),
              icon: Icon(Icons.delete),
              style: TextButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.redAccent.withAlpha(100)
              ),
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: Text(S.of(context).cancel),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      if(_firstNameController.text.isEmpty || _lastNameController.text.isEmpty || _selectedDate == null){
                        Utilities.showToast(context: context, title: S.of(context).fail, description: S.of(context).add_user_requiredFieldMissing, isError: true);
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
                            country: _selectedCountry.countryCode,
                            notes: _miscellaneousController.text,
                            lastVisit: widget.user!.lastVisit
                        );
                        _useServer //TODO: Add failed return
                            ? await HttpHelper().updateCustomer(user: user)
                            : await DatabaseHelper().updateUser(user);

                        if(context.mounted) {
                          Utilities.showToast(
                              context: context,
                              title:  S.of(context).success,
                              description: S.of(context).update_success
                          );
                        }

                        if(context.mounted) navigatorKey.currentState?.pop(AddUserReturn(user: user, deleted: false));
                      } else {
                        final uuId = const Uuid().v4(); //v3 would allow hashing of name, birthday => Autodetect collisions, v4 is most used and random
                        User? user;
                        _useServer
                            ? user = await HttpHelper().addCustomer(
                                uuId: uuId,
                                firstName: _firstNameController.text,
                                lastName: _lastNameController.text,
                                birthday: _selectedDate!,
                                countryCode:  _selectedCountry.countryCode,
                                notes: _miscellaneousController.text
                              )
                            : user = await DatabaseHelper().addUser(
                                  uuId: uuId,
                                  firstName: _firstNameController.text,
                                  lastName: _lastNameController.text,
                                  birthDay: _selectedDate!,
                                  birthCountry: _selectedCountry.countryCode,
                                  notes: _miscellaneousController.text
                              );
                        setState(() {
                          uploading = false;
                        });
                        if(context.mounted){
                          Utilities.showToast(
                              context: context,
                              title: user != null ? S.of(context).success : S.of(context).fail,
                              description:  user != null ? S.of(context).add_success : S.of(context).add_failed,
                              isError: user == null,
                          );
                        }

                        if(context.mounted && user != null) navigatorKey.currentState?.pop(AddUserReturn(user: user, deleted: false));
                        }
                      },
                    child: uploading ? SizedBox(
                      height: 24, // kleiner als 40
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ) :Text(widget.user != null ? S.of(context).update : S.of(context).confirm),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}