import 'package:hive/hive.dart';

part'employee.g.dart';
@HiveType(typeId: 0)
class Employee{
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String phone;
  @HiveField(4)
  final String department;
  @HiveField(5)
  final double salary;
  
  Employee({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.salary
});
  
  factory Employee.fromJson(Map<String,dynamic> json) {
    return Employee(
      id: json['_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      department: json['department'] ?? '',
      salary: (json['salary'] ?? 0).toDouble(),
    );
  }

  Map<String,dynamic> toJson(){
    return{
      'name':name,
      'email':email,
      'phone':phone,
      'department':department,
      'salary':salary

    };
  }
}