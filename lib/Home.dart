import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tareasapp/database/database.dart';
import 'package:tareasapp/widgets/styles.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TaskDatabase db;
  late Future<List<Task>> _tasksFuture;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    db = TaskDatabase();
    _tasksFuture = _initializeDatabase();
  }

  Future<List<Task>> _initializeDatabase() async {
    await db.initDB();
    return db.getAllTasks();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 140,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(26, 255, 255, 255), // Verde claro
                  Color.fromARGB(26, 255, 255, 255), // Verde claro
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(40),
                bottomLeft: Radius.circular(40),
              ),
            ),
            child: Center(
              child: Text(widget.title, style: kTlightproMax),
            ),
          ),
          // const Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Text(
          //     'Tus tareas',
          //     style: TextStyle(
          //       fontSize: 18.0,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          // ),
          Expanded(
            child: FutureBuilder(
              future: _tasksFuture,
              builder: (BuildContext context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return _showList(context, snapshot);
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Agregar tarea',
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: _buildProgressBar(context),
    );
  }

  Widget _showList(BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
    if (snapshot.hasData) {
      List<Task>? tasks = snapshot.data;
      if (tasks != null && tasks.isNotEmpty) {
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            Task task = tasks[index];
            return Card(
              elevation: 2.0,
              child: InkWell(
                onTap: () {
                  _toggleTask(task, snapshot);
                },
                onLongPress: () {
                  if (task.name.length > 15) {
                    _showTaskDetailsModal(context, task);
                  } else {
                    _deleteTaskWithSnackBar(context, task);
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        task.name.length > 15
                            ? task.name.substring(0, 15) + "..."
                            : task.name,
                      ),
                      leading: AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: task.completed ? Colors.green : Colors.red,
                        ),
                        child: Icon(
                          task.completed
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Mostrar la imagen por defecto si no se proporciona una específica
                    task.imageUrl != null
                        ? Image.file(
                            File(task.imageUrl!),
                            height: 50,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/go.png',
                            height: 80,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        return Center(
          child: Text('No hay tareas'),
        );
      }
    }
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  void _showTaskDetailsModal(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalles de la tarea'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ' ${task.name}',
                style: TextStyle(
                  fontSize: 15.0,
                  fontFamily: 'Averta_Light',
                ),
                textAlign: TextAlign.justify,
              ),

              //Text('ID: ${task.id}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteTaskWithSnackBar(context, task);
                Navigator.pop(
                    context); // Cerrar el modal después de eliminar la tarea
              },
              child: Text('Eliminar'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Color del botón de eliminar
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteTaskWithSnackBar(BuildContext context, Task task) {
    _deleteTask(task.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text('Tarea eliminada con éxito'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return FutureBuilder(
      future: _tasksFuture,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          List<Task>? tasks = snapshot.data;
          int completedTasks =
              tasks?.where((task) => task.completed).length ?? 0;
          int totalTasks = tasks?.length ?? 0;
          double progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

          return LinearProgressIndicator(
            value: progress,
            color: Colors.green,
            backgroundColor: Colors.grey[300],
          );
        } else {
          return LinearProgressIndicator();
        }
      },
    );
  }

  void _deleteTask(int taskId) async {
    await db.deleteTask(taskId);
    setState(() {
      _tasksFuture = _initializeDatabase();
    });
  }

  void _toggleTask(Task task, AsyncSnapshot<List<Task>> snapshot) async {
    task.completed = !task.completed;
    await db.updateTask(task);
    setState(() {
      _tasksFuture = _initializeDatabase();
    });

    _showProgressSnackBar(snapshot);
  }

  void _addTask() async {
    showDialog(
      context: context,
      builder: (context) {
        String newTaskName = "";
        PickedFile? pickedImage;

        return SimpleDialog(
          title: Text('Agregar Tarea'),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onChanged: (text) {
                  newTaskName = text;
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                // TextButton(
                //   // onPressed: () async {
                //   //   pickedImage = await _picker.pickImage(
                //   //     source: ImageSource.gallery,
                //   //   );
                //   // },
                //   child: Text('Seleccionar Imagen'),
                // ),
                TextButton(
                  onPressed: () async {
                    if (newTaskName.isNotEmpty) {
                      var task = Task(
                        name: newTaskName,
                        completed: false,
                        imageUrl: pickedImage?.path,
                      );
                      await db.insert(task);
                      Navigator.pop(context);

                      setState(() {
                        _tasksFuture = _initializeDatabase();
                      });
                    }
                  },
                  child: Text('Aceptar'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showProgressSnackBar(AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      List<Task>? tasks = snapshot.data as List<Task>?;
      int completedTasks = tasks?.where((task) => task.completed).length ?? 0;
      int totalTasks = tasks?.length ?? 0;
      double progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

      String formattedProgress = (progress * 100).toStringAsFixed(0);

      String snackBarMessage = 'Progreso: $formattedProgress% completado';

      if (progress == 1.0) {
        snackBarMessage = '¡Felicidades! Has completado todas las tareas.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(snackBarMessage),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}
