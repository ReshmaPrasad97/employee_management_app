import 'package:hive/hive.dart';
import '../models/employee.dart';

class EmployeeLocalService {
  static const String boxName = 'employees';

  Future<Box<Employee>> _openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<Employee>(boxName);
    }

    return await Hive.openBox<Employee>(boxName);
  }

  Future<List<Employee>> getEmployees() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<void> saveEmployees(List<Employee> employees) async {
    final box = await _openBox();

    await box.clear();

    for (final employee in employees) {
      if (employee.id != null) {
        await box.put(employee.id, employee);
      } else {
        await box.add(employee);
      }
    }
  }

  Future<void> saveEmployee(Employee employee) async {
    final box = await _openBox();

    if (employee.id != null) {
      await box.put(employee.id, employee);
    } else {
      await box.add(employee);
    }
  }

  Future<void> deleteEmployee(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  Future<void> clearEmployees() async {
    final box = await _openBox();
    await box.clear();
  }
  Future<void> printEmployees() async {
    final box = await _openBox();

    print('===== HIVE EMPLOYEES =====');
    print('Number of employees: ${box.length}');

    for (final employee in box.values) {
      print(
        'ID: ${employee.id}, '
            'Name: ${employee.name}, '
            'Email: ${employee.email}, '
            'Phone: ${employee.phone}, '
            'Department: ${employee.department}, '
            'Salary: ${employee.salary}',
      );
    }

    print('==========================');
  }
}