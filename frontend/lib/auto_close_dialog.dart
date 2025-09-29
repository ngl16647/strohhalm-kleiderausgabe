import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'generated/l10n.dart';

class AutoCloseDialog extends StatefulWidget {
  final int? durationInSeconds;
  final Widget child;

  const AutoCloseDialog({
    super.key,
    this.durationInSeconds,
    required this.child
  });

  Future<void> showAutoCloseDialog(BuildContext context)async{
    await showDialog(
        context: context,
        builder: (context){
          return AutoCloseDialog(durationInSeconds: durationInSeconds, child: child);
        });
  }

  @override
  AutoCloseDialogState createState() => AutoCloseDialogState();
}

class AutoCloseDialogState extends State<AutoCloseDialog> {
  int secondsLeft = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if(widget.durationInSeconds != null){
      secondsLeft = widget.durationInSeconds ?? 10;

      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() {
          secondsLeft--;
        });

        if (secondsLeft <= 0) {
          t.cancel();
          Navigator.of(context, rootNavigator: true).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height*0.5,
          maxWidth: MediaQuery.of(context).size.height*0.7
      ),
      child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if(widget.durationInSeconds != null) Text(S.of(context).closesIn(secondsLeft)),
                    IconButton(
                        onPressed: Navigator.of(context).pop,
                        icon: Icon(Icons.close)
                    )
                  ],
                ),
              ),
            ),
            Center(
              child: widget.child,
            ),
          ],
        ),
    ).animate().scale(
        begin: Offset(0, 0),
        end: Offset(1, 1),
        duration: 300.ms,
        curve: Curves.bounceInOut);
  }
}