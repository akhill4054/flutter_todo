import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConfirmDialog {
  BuildContext context;

  String title = 'Are you sure, you wanna do this?';
  String positiveLabel = 'Yes please';
  String negativeLabel = 'No, thanks';

  ConfirmDialog(this.context,
      {String title, String negativeLabel, String positiveLabel}) {
    if (title != null) this.title = title;
    if (negativeLabel != null) this.negativeLabel = negativeLabel;
    if (positiveLabel != null) this.positiveLabel = positiveLabel;
  }

  static Future<bool> pop(BuildContext context) async {
    return await ConfirmDialog(context).show();
  }

  Future<bool> show() async {
    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            actions: [
              FlatButton(
                child: Text(positiveLabel),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              FlatButton(
                child: Text(negativeLabel),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        });
  }
}
