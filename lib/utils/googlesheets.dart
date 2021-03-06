import 'package:gsheets/gsheets.dart';
import 'package:intl/intl.dart';
import 'package:qr_attendance/models/member.dart';

import 'credentials.dart';

class UserSheetsApi {
  static const _credentials = CREDENTIALS;
  static final _spreadsheetId = SPREADSHEETID;

  static final _gsheets = GSheets(_credentials);
  static Worksheet? _sheet;
  static String now = DateFormat("dd-MM-yyyy").format(DateTime.now());
  static List<String> headerRow = [];

  static Future<void> init() async {
    try {
      final spreasheet = await _gsheets.spreadsheet(_spreadsheetId);
      _sheet = await _getWorkSheet(spreasheet, title: 'Sheet1');
      await _sheet!.values.row(1).then((value) => headerRow = value);
    } catch (e) {
      throw e;
    }
  }

  static Future<void> insertValue(String data, int col, int row) async {
    await _sheet!.values.insertValue(data, column: col, row: row);
  }

  static Future<void> updateHeaders() async {
    await _sheet!.values.row(1).then((value) {
      if (!value.contains(now)) {
        headerRow = value;
      } else {
        return;
      }
    });
    await _sheet!.values.insertValue(now, column: headerRow.length + 1, row: 1);
  }

  static Future<Worksheet> _getWorkSheet(Spreadsheet spreasheet, {required String title}) async {
    try {
      return await spreasheet.addWorksheet(title);
    } catch (e) {
      return spreasheet.worksheetByTitle(title)!;
    }
  }

  static Future<List<Member>> getAll() async {
    if (_sheet == null) return <Member>[];
    final members = await _sheet!.values.map.allRows();
    return members == null ? <Member>[] : members.map(Member.fromJson).toList();
  }

  static Future<bool> update({
    required String id,
    required Map<String, dynamic> member,
  }) async {
    print(member);
    if (_sheet == null) return false;
    return _sheet!.values.map.insertRowByKey(id, member);
  }
}
