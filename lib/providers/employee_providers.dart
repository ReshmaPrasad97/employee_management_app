import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models/employee.dart';
import 'package:untitled/services/employee_service.dart';

final employeeServiceProvider = Provider<EmployeeService>((ref) {
  return EmployeeService();
});

final employeesProvider = AsyncNotifierProvider<EmployeesNotifier,List<Employee>>(
  EmployeesNotifier.new,
);

class EmployeesNotifier extends AsyncNotifier<List<Employee>> {
  @override
  FutureOr<List<Employee>> build() async {
    final service = ref.read(employeeServiceProvider);

    return service.getEmployee();
  }

  Future<void> createEmployee(Employee employee) async{
    final service = ref.read(employeeServiceProvider);
    final createdEmployee =  await service.createEmployee(employee);

    final currentEmployees = state.value??[];

    state = AsyncData([...currentEmployees,createdEmployee]);
  }

  Future<void> updateEmployee(Employee employee) async {
    final service = ref.read(employeeServiceProvider);

    final updatedEmployee = await service.updateEmployee(employee);

    final currentEmployees = state.value ?? [];

    final updatedEmployees = currentEmployees.map((existingEmployee) {
      if (existingEmployee.id == updatedEmployee.id) {
        return updatedEmployee;
      }

      return existingEmployee;
    }).toList();

    state = AsyncData(updatedEmployees);
  }

  Future<void> deleteEmployee(Employee employee) async{
    final service  = ref.read(employeeServiceProvider);

    await service.deleteEmployee(employee.id!);

    final currentEmployees = state.value?? [];

    final updateEmployees = currentEmployees.where((e) => e.id !=employee.id).toList();

    // update Riverpod state
    state = AsyncData(updateEmployees);
  }

}