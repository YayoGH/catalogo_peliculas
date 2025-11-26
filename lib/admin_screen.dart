import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'movie.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  final _directorController = TextEditingController();
  final _genreController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    _directorController.dispose();
    _genreController.dispose();
    _synopsisController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white54),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }

  Future<void> _saveMovie() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('movies').add({
        'title': _titleController.text.trim(),
        'year': int.tryParse(_yearController.text.trim()) ?? 0,
        'director': _directorController.text.trim(),
        'genre': _genreController.text.trim(),
        'synopsis': _synopsisController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _formKey.currentState!.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Película guardada')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _deleteMovie(Movie movie) async {
    try {
      await FirebaseFirestore.instance
          .collection('movies')
          .doc(movie.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Película eliminada')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade900,
      appBar: AppBar(
        title: const Text('Administrar películas'),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // FORMULARIO
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: _inputDecoration('Título'),
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Ingresa un título'
                            : null,
                  ),
                  TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: _inputDecoration('Año'),
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Ingresa un año'
                            : null,
                  ),
                  TextFormField(
                    controller: _directorController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: _inputDecoration('Director'),
                  ),
                  TextFormField(
                    controller: _genreController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: _inputDecoration('Género'),
                  ),
                  TextFormField(
                    controller: _synopsisController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: _inputDecoration('Sinopsis'),
                    maxLines: 3,
                  ),
                  TextFormField(
                    controller: _imageUrlController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration:
                        _inputDecoration('URL de la imagen (poster)'),
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Ingresa una URL de imagen'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple.shade800,
                      ),
                      onPressed: _isSaving ? null : _saveMovie,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar película'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white),
            const SizedBox(height: 8),
            const Text(
              'Películas registradas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // LISTA DE PELÍCULAS
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('movies')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final docs = snapshot.data!.docs;
                final movies = docs
                    .map((doc) => Movie.fromMap(
                        doc.id, doc.data() as Map<String, dynamic>))
                    .toList();

                if (movies.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No hay películas registradas',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return ListTile(
                      leading: movie.imageUrl.isNotEmpty
                          ? Image.network(
                              movie.imageUrl,
                              width: 40,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.movie, color: Colors.white),
                      title: Text(
                        movie.title,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${movie.year} · ${movie.genre}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.redAccent),
                        onPressed: () => _deleteMovie(movie),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
