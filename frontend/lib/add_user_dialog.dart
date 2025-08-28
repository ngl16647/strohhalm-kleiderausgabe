import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:strohhalm_app/main.dart';
import 'package:strohhalm_app/user.dart';
import 'package:strohhalm_app/utilities.dart';
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
  bool _hasChild = false;
  DateTime? _selectedDate;
  Country _selectedCountry = Country.worldWide;

  @override
  void initState() {
    if(widget.user != null){
      _firstNameController.text = widget.user!.firstName;
      _lastNameController.text = widget.user!.lastName;
      _miscellaneousController.text = widget.user!.miscellaneous ?? "";

      _selectedDate = DateTime.fromMillisecondsSinceEpoch(widget.user!.birthDay);
      _hasChild = widget.user!.hasChild;
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
                //Row(
                //  children: [
                //    Checkbox(
                //      value: hasChild,
                //      onChanged: (ev) {
                //        setState(() {
                //          hasChild = ev!;
                //        });
                //      },
                //    ),
                //    const Text("Has children"),
                //  ],
                //),
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
                      if(widget.user != null){
                        User user = widget.user!.copyWith(
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            birthDay: _selectedDate!.millisecondsSinceEpoch,
                            birthCountry: _selectedCountry.countryCode,
                            hasChild: _hasChild,
                            miscellaneous: _miscellaneousController.text
                        );
                        await DatabaseHelper().updateUser(user);
                        if(context.mounted) navigatorKey.currentState?.pop([user, false]);
                      } else {
                        User? user = await DatabaseHelper().addUser(
                            _firstNameController.text,
                            _lastNameController.text,
                            _selectedDate!.millisecondsSinceEpoch,
                            _selectedCountry.countryCode,
                            _hasChild,
                            _miscellaneousController.text
                        );
                        if(context.mounted) navigatorKey.currentState?.pop([user, false]);
                        }
                      },
                    child: Text(S.of(context).confirm),
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