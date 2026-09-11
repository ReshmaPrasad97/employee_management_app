import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models/employee.dart';
import 'package:untitled/services/employee_service.dart';
import 'package:untitled/services/employee_local_service.dart';

final employeeServiceProvider = Provider<EmployeeService>((ref) {
  return EmployeeService();
});

final employeeLocalServiceProvider = Provider<EmployeeLocalService>((ref) {
  return EmployeeLocalService();
});

final employeesProvider =
AsyncNotifierProvider<EmployeesNotifier, List<Employee>>(
  EmployeesNotifier.new,
);

class EmployeesNotifier extends AsyncNotifier<List<Employee>> {
  @override
  Future<List<Employee>> build() async {
    final apiService = ref.read(employeeServiceProvider);
    final localService = ref.read(employeeLocalServiceProvider);

    try {
      final employees = await apiService.getEmployee();

      // Cache API data locally
      await localService.saveEmployees(employees);
      await localService.printEmployees();

      return employees;
    } catch (e) {
      // Fallback to Hive
      final cachedEmployees = await localService.getEmployees();

      if (cachedEmployees.isNotEmpty) {
        return cachedEmployees;
      }

      rethrow;
    }
  }

  Future<void> createEmployee(Employee employee) async {
    final apiService = ref.read(employeeServiceProvider);
    final localService = ref.read(employeeLocalServiceProvider);

    final createdEmployee =
    await apiService.createEmployee(employee);

    await localService.saveEmployee(createdEmployee);

    final currentEmployees = state.value ?? [];

    state = AsyncData([
      ...currentEmployees,
      createdEmployee,
    ]);
  }

  Future<void> updateEmployee(Employee employee) async {
    final apiService = ref.read(employeeServiceProvider);
    final localService = ref.read(employeeLocalServiceProvider);

    final updatedEmployee =
    await apiService.updateEmployee(employee);

    await localService.saveEmployee(updatedEmployee);

    final currentEmployees = state.value ?? [];

    final updatedEmployees = currentEmployees.map((existingEmployee) {
      if (existingEmployee.id == updatedEmployee.id) {
        return updatedEmployee;
      }

      return existingEmployee;
    }).toList();

    state = AsyncData(updatedEmployees);
  }

  Future<void> deleteEmployee(Employee employee) async {
    final apiService = ref.read(employeeServiceProvider);
    final localService = ref.read(employeeLocalServiceProvider);

    await apiService.deleteEmployee(employee.id!);

    await localService.deleteEmployee(employee.id!);

    final currentEmployees = state.value ?? [];

    final updatedEmployees = currentEmployees
        .where((e) => e.id != employee.id)
        .toList();

    state = AsyncData(updatedEmployees);
  }
}