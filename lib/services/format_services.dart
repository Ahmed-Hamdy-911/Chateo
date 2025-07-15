import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class FormatServices {
  // Format a DateTime to a readable date string

  String formatDateFromDateTimeType(DateTime dateTime) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy'); // E.g., "11/11/2024"
    return formatter.format(dateTime);
  }

  // Format a Timestamp to a readable date string
  String formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat.yMMMd().format(date); // E.g., "Nov 11, 2023"
  }

  // Format a Timestamp to a readable time string
  String formatTime(Timestamp timestamp) {
    DateTime time = timestamp.toDate();
    return DateFormat.jm().format(time); // E.g., "5:30 PM"
  }

  // Combine date and time into one format
  String formatDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yMMMd')
        .add_jm()
        .format(dateTime); // E.g., "Nov 11, 2024 5:30 PM"
  }

  // Return initials of a name
  String? returnFirstAndLastInitials({String? name}) {
    if (name == null || name.isEmpty) return null;
    List<String> nameParts = name.trim().split(" ");
    if (nameParts.length > 1) {
      return "${nameParts.first[0]}${nameParts.last[0]}";
    } else {
      return "${nameParts.first[0]}${nameParts.first.length > 1 ? nameParts.first[1] : ''}";
    }
  }
}
