import 'package:isar/isar.dart';
import 'package:test/test.dart';

import '../util/common.dart';
import '../util/sync_async_helper.dart';

part 'add_remove_index_test.g.dart';

@Collection()
@Name('Col')
class Col1 {
  int? id;

  String? value;

  Col1(this.id, this.value);

  @override
  operator ==(other) => other is Col1 && id == other.id && value == other.value;
}

@Collection()
@Name('Col')
class Col2 {
  int? id;

  @Index(unique: true)
  String? value;

  Col2(this.id, this.value);

  @override
  operator ==(other) => other is Col2 && id == other.id && value == other.value;
}

void main() {
  testSyncAsync(tests);
}

void tests() {
  isarTest('Add remove index', () async {
    final isar1 = await openTempIsar([Col1Schema]);
    await isar1.tWriteTxn(() {
      return isar1.col1s.tPutAll([Col1(1, 'a'), Col1(2, 'b')]);
    });
    expect(await isar1.close(), true);

    final isar2 = await openTempIsar([Col2Schema], name: isar1.name);
    await qEqual(isar2.col2s.where().tFindAll(), [Col2(1, 'a'), Col2(2, 'b')]);
    expect(await isar2.col2s.getByValue('a'), Col2(1, 'a'));
    await isar2.tWriteTxn(() {
      return isar2.col2s.tPutAll([Col2(1, 'c'), Col2(3, 'd')]);
    });
    expect(await isar2.close(), true);

    final isar3 = await openTempIsar([Col1Schema], name: isar1.name);
    await qEqual(isar3.col1s.where().tFindAll(), [
      Col1(1, 'c'),
      Col1(2, 'b'),
      Col1(3, 'd'),
    ]);
    expect(await isar3.close(), true);
  });
}
