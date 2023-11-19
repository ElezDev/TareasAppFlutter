import 'package:flutter/material.dart';
import 'package:tareasapp/database/database.dart';

class OtraVista extends StatefulWidget {
  final List<Task> completedTasks;

  OtraVista({required this.completedTasks});

  @override
  _OtraVistaState createState() => _OtraVistaState();
}

class _OtraVistaState extends State<OtraVista> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Otra Vista'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Tareas Completadas:',
              style: TextStyle(fontSize: 18),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.completedTasks.length,
                itemBuilder: (context, index) {
                  Task completedTask = widget.completedTasks[index];
                  return ListTile(
                    title: Text(completedTask.name),
                    // Puedes agregar más detalles de la tarea si es necesario
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
