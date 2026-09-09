

class Employee{
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String department;
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