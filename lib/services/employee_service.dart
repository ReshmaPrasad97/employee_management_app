import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/employee.dart';


class EmployeeService{
  final String baseUrl = dotenv.env['API_BASE_URL']!;

  Future<List<Employee>> getEmployee() async {
    final response = await http.get(
      Uri.parse('$baseUrl/employees'),
    );

    print('GET employee');
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if(response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((json) => Employee.fromJson(json)).toList();
    } else{
      throw Exception('Failed to load employees');
    }
  }

  Future<Employee> createEmployee(Employee employee) async{
    print('CREATE: request starting');
    final response = await http.post(
      Uri.parse('$baseUrl/employees'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(employee.toJson()),
    );

    print('CREATE: response received');
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

if(response.statusCode == 201) {
  return Employee.fromJson(jsonDecode(response.body),);
    } else {
  throw Exception('Failed to create Employee');
    }
  }

  Future<Employee> updateEmployee(Employee employee) async {
    print('UPDATE: request starting');
    final response = await http.put(
      Uri.parse('$baseUrl/employees/${employee.id}'),
      headers:{
        'Content-Type':'application/json',
      },
      body: jsonEncode(employee.toJson()),
    );

    print('UPDATE: response received');
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if(response.statusCode == 200) {
      return employee;
    } else {
      throw Exception('Failed to update Employee');
    }
  }

  Future<void> deleteEmployee(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/employees/$id'),
    );

    print('DELETE Employee');
    print('Status: ${response.statusCode}');

    if(response.statusCode != 200) {
      throw Exception('Failed to delete employee');
    }
  }
}