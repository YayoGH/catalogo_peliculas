import 'package:flutter/material.dart';
import 'movie.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade900,
      appBar: AppBar(
        title: Text(movie.title),
        backgroundColor: Colors.deepPurple.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  movie.imageUrl,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      width: double.infinity,
                      color: Colors.grey,
                      child: const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Título
            Text(
              movie.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Año, Director, Género
            Text(
              'Año: ${movie.year}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Director: ${movie.director}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Género: ${movie.genre}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),

            const Text(
              'Sinopsis',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.synopsis,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
