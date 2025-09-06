import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:strohhalm_app/http_helper.dart';
import 'package:strohhalm_app/main.dart';
import 'package:strohhalm_app/user.dart';
import 'package:strohhalm_app/utilities.dart';
import 'package:uuid/uuid.dart';
import 'database_helper.dart';
import 'generated/l10n.dart';

class AddUserDialog extends StatefulWidget {
  final User? user;

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

  @override
  void initState() {
    if(widget.user != null){
      _firstNameController.text = widget.user!.firstName;
      _lastNameController.text = widget.user!.lastName;
      _miscellaneousController.text = widget.user!.miscellaneous ?? "";

      _selectedDate = widget.user!.birthDay;
      _selectedCountry = Country.tryParse(widget.user!.birthCountry) ?? Country.worldWide;
    }
    super.initState();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 31)),
      initialDate: _selectedDate ?? DateTime.now(),
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
                        const Icon(Icons.calendar_today),
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
                  bool? result = await Utilities().dialogConfirmation(context, S.of(context).add_user_deleteMessage);
                  if(result != null){
                    navigatorKey.currentState?.pop([widget.user, true]);
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(S.of(context).add_user_requiredFieldMissing))
                        );
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
                            birthCountry: _selectedCountry.countryCode,
                            miscellaneous: _miscellaneousController.text
                        );
                        var result = await HttpHelper().updateCustomer(
                            id: user.id,
                            uuid: user.uuId,
                            firstName: user.firstName,
                            lastName: user.lastName,
                            birthday: user.birthDay,
                            countryCode: user.birthCountry,
                            notes: user.miscellaneous
                        );
                        if(result == null) {
                          print("Online update failed $result" );
                        }
                        await DatabaseHelper().updateUser(user, result != null);
                        if(context.mounted) navigatorKey.currentState?.pop([user, false]);
                      } else {
                        final uuId = const Uuid().v4(); //v3 would allow hashing of name, birthday => Autodetect collisions, v4 is most used and random
                        int? id = await HttpHelper().addCustomer(
                            uuId: uuId,
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            birthday: _selectedDate!,
                            countryCode:  _selectedCountry.countryCode,
                            notes: _miscellaneousController.text
                        );
                        print(id);
                        User? user = await DatabaseHelper().addUser(
                            id: id, //If null a negative Id is created in addUser
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
                        if(context.mounted) navigatorKey.currentState?.pop([user, false]);
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