import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/providers/employee_providers.dart';

import '../models/employee.dart';
import '../services/secure_storage_service.dart';
import 'employee_form_screen.dart';
import 'login_screen.dart';

class EmployeeListScreen extends ConsumerWidget {
  const EmployeeListScreen({super.key});


  Future<void> _openAddEmployee(BuildContext context) async {
    await Navigator.push<Employee>(
      context,
      MaterialPageRoute(builder: (context) => const EmployeeFormScreen()),
    );
  }

  Future<void> _openEditEmployee(BuildContext context, Employee employee,) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeFormScreen(
          employee: employee,
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, Employee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Delete Employee'),
            content: Text('Delete ${employee.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    return confirmed ?? false;
  }
  Future<void> _logout(BuildContext context) async {
    final storage = SecureStorageService();

    await storage.deleteToken();

    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeAsync = ref.watch(employeesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
     body: employeeAsync.when(
       loading: () => const Center (
         child: CircularProgressIndicator(),
       ),
       error: (error, stackTrace) => Center(
         child: Text(
           'Failed to load employees: $error',
         ),
       ),

       data: (employees) {
         return ListView.builder(
           itemCount: employees.length,
           itemBuilder: (context, index) {
             final employee = employees[index];

             return Dismissible(
               key: ValueKey(employee.id),

               direction: DismissDirection.endToStart,

               background: Container(
                 color: Colors.red,
                 alignment: Alignment.centerRight,
                 padding: const EdgeInsets.symmetric(
                   horizontal: 20,
                 ),
                 child: const Icon(
                   Icons.delete,
                   color: Colors.white,
                 ),
               ),

               confirmDismiss: (_) {
                 return _confirmDelete(
                   context,
                   employee,
                 );
               },

              onDismissed: (_) async {
                 try{
                   await ref.read(employeesProvider.notifier)
                       .deleteEmployee(employee);
                 } catch(e){
                   if (!context.mounted) return;

                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                       content: Text('Failed to delete employee: $e'),
                     ),
                   );

                   ref.invalidate(employeesProvider);
                 }
              },

               child: ListTile(
                 title: Text(employee.name),

                 subtitle: Text(
                   employee.department,
                 ),

                 onTap: () {
                   _openEditEmployee(
                     context,
                     employee,
                   );
                 },

                 trailing: IconButton(
                   icon: const Icon(
                     Icons.delete_outline,
                   ),
                   onPressed: () async {
                     final confirmed = await _confirmDelete(
                       context,
                       employee,
                     );

                     if (!confirmed) return;

                     try {
                       await ref
                           .read(employeesProvider.notifier)
                           .deleteEmployee(employee);
                     } catch (e) {
                       if (!context.mounted) return;

                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                           content: Text('Failed to delete employee: $e'),
                         ),
                       );
                     }
                   },
                 ),
               ),
             );
           },
         );
       },
     ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openAddEmployee(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}