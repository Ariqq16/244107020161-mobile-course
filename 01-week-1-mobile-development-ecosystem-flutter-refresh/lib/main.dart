import 'package:flutter/material.dart';

void main() => runApp(const Week1App());

class Student {
  const Student({required this.name, required this.nim, this.email});

  final String name;
  final String nim;
  final String? email;
}

class Week1App extends StatelessWidget {
  const Week1App({super.key});

  @override
  Widget build(BuildContext context) {
    const student = Student(
      name: 'Mahasiswa Mobile',
      nim: '244107020161',
      email: 'mahasiswa@example.com',
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Week 1 - Flutter Refresh',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const StudentPage(student: student),
    );
  }
}

class StudentPage extends StatelessWidget {
  const StudentPage({required this.student, super.key});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Refresh')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(radius: 36, child: Icon(Icons.person)),
                const SizedBox(height: 16),
                Text(
                  student.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text('NIM: ${student.nim}'),
                Text(student.email ?? 'Email belum diisi'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
