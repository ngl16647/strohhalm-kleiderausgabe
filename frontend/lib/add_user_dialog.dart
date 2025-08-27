import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:strohhalm_app/main.dart';
import 'package:strohhalm_app/user.dart';
import 'package:strohhalm_app/utilities.dart';
import 'database_helper.dart';

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
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final miscellaneousController = TextEditingController();
  bool hasChild = false;
  DateTime? selectedDate;
  Country selectedCountry = Country.worldWide;

  @override
  void initState() {
    if(widget.user != null){
      firstNameController.text = widget.user!.firstName;
      lastNameController.text = widget.user!.lastName;
      miscellaneousController.text = widget.user!.miscellaneous ?? "";

      selectedDate = DateTime.fromMillisecondsSinceEpoch(widget.user!.birthDay);
      hasChild = widget.user!.hasChild;
      selectedCountry = Country.tryParse(widget.user!.birthCountry) ?? Country.worldWide;
    }
    super.initState();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 31)),
      initialDate: selectedDate ?? DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).listTileTheme.tileColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text("* required Fields", style: TextStyle(color: Theme.of(context).textTheme.titleSmall!.color?.withAlpha(100)), textAlign: TextAlign.start,),
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: "First Name*",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  controller: firstNameController,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Last Name*",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  controller: lastNameController,
                ),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDate != null
                              ? DateFormat("dd.MM.yyyy").format(selectedDate!)
                              : "Geburtsdatum wählen*",
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
                          selectedCountry = country;

                        });
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedCountry.name,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium!.color?.withAlpha(150),
                          ),
                        ),
                        const Icon(Icons.calendar_today),
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
                    hintText: "Sonstiges",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  controller: miscellaneousController,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if(widget.user != null) TextButton.icon(
                onPressed: () async {
                  bool? result = await Utilities().dialogConfirmation(context, "Bist du Sicher, dass du den Benutzer unwiderruflich löschen willst?");
                  if(result != null){
                    navigatorKey.currentState?.pop([widget.user, true]);
                  }
                },
                label: Text("Delete"),
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
                    child: const Text("Cancel"),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      if(firstNameController.text.isEmpty || lastNameController.text.isEmpty || selectedDate == null){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("One of the required Fields wasn't filled out"))
                        );
                        return;
                      }
                      if(widget.user != null){
                        User user = widget.user!.copyWith(
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            birthDay: selectedDate!.millisecondsSinceEpoch,
                            birthCountry: selectedCountry.countryCode,
                            hasChild: hasChild,
                            miscellaneous: miscellaneousController.text
                        );
                        await DatabaseHelper().updateUser(user);
                        if(context.mounted) navigatorKey.currentState?.pop([user, false]);
                      } else {
                        User? user = await DatabaseHelper().addUser(
                            firstNameController.text,
                            lastNameController.text,
                            selectedDate!.millisecondsSinceEpoch,
                            selectedCountry.countryCode,
                            hasChild,
                            miscellaneousController.text
                        );
                        if(context.mounted) navigatorKey.currentState?.pop([user, false]);
                        }
                      },
                    child: const Text("Confirm"),
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