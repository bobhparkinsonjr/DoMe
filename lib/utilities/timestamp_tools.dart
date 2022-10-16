import 'package:cloud_firestore/cloud_firestore.dart';

import '../devtools/logger.dart';

///////////////////////////////////////////////////////////////////////////////////////////////////

class TimestampTools {
  static DateTime convertTimestampUTC(Timestamp sourceUTC) {
    return DateTime.fromMicrosecondsSinceEpoch(sourceUTC.microsecondsSinceEpoch, isUtc: true);
  }

  static Timestamp convertDateTimeUTC(DateTime sourceUTC) {
    return Timestamp.fromDate(sourceUTC);
  }

  static void unitTest() {
    DateTime dt = DateTime.now().toUtc();

    Timestamp ts = convertDateTimeUTC(dt);
    DateTime dt2 = convertTimestampUTC(ts);

    Logger.print('TimestampTools unit test | dt: \'${dt.toString()}\' | dt2: \'${dt2.toString()}\'');
  }
}
