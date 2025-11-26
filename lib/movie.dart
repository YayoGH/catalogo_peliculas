// lib/movie.dart

class Movie {
  final String id;        // id del documento en Firestore
  final String title;
  final int year;
  final String director;
  final String genre;
  final String synopsis;
  final String imageUrl;

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.director,
    required this.genre,
    required this.synopsis,
    required this.imageUrl,
  });

  // Crear Movie desde un documento de Firestore
  factory Movie.fromMap(String id, Map<String, dynamic> data) {
    return Movie(
      id: id,
      title: data['title'] ?? '',
      year: (data['year'] ?? 0) is int
          ? data['year']
          : int.tryParse(data['year'].toString()) ?? 0,
      director: data['director'] ?? '',
      genre: data['genre'] ?? '',
      synopsis: data['synopsis'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  // Guardar Movie en Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'year': year,
      'director': director,
      'genre': genre,
      'synopsis': synopsis,
      'imageUrl': imageUrl,
    };
  }
}
