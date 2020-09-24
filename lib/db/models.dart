import 'package:intl/intl.dart';

class TodoItem {
  int id;
  String text;
  String createdAt;
  bool status;

  TodoItem({this.id, this.text = ''}) {
    status = false;
    createdAt = DateTime.now().toString();
  }

  TodoItem.get({this.id, this.text, this.createdAt, this.status});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt,
      'status': status,
    };
  }

  String formattedCreatedAt() {
    DateTime now = DateTime.now();
    DateTime dateTime = DateTime.parse(createdAt);

    String format = 'dd MMM yyyy';

    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) format = 'hh:mm a';

    return DateFormat(format).format(dateTime);
  }
}
