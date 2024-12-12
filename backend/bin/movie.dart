import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

// PostgreSQL connection

void main() async {
  final conn = await Connection.open(Endpoint(
    host: 'localhost',
    database: 'movie',
    username: 'postgres',
    password: '1234',
  ));

  // Open PostgreSQL connection
  // await conn.open();

  // Create the router
  final router = Router();

  // API routes
  router.get('/movies', getMovies); // Get list of movies
  router.get('/movies/<id>', getMovieById); // Get a single movie by ID
  router.put('/movies/<id>', updateMovieById); // Get a single movie by ID
  router.post('/movies', createMovie); // Create a new movie
  router.delete('/movies/<id>', deleteMovie); // Delete a movie by ID

  // Enable CORS
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router);

  // Start the server
  final server = await shelf_io.serve(handler, 'localhost', 8080);
  print('Server listening on http://${server.address.host}:${server.port}');
}

// Middleware for CORS
Middleware corsHeaders() {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type',
  };
  return (innerHandler) => (request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok(null, headers: corsHeaders);
        }
        final response = await innerHandler(request);
        return response.change(headers: corsHeaders);
      };
}

// GET /movies - Get list of all movies
Future<Response> getMovies(Request request) async {
  final conn = await Connection.open(Endpoint(
    host: 'localhost',
    database: 'movie',
    username: 'postgres',
    password: '1234',
  ));

  try {
    final results = await conn.execute('SELECT * FROM movies');
    final movies = results.map((row) {
      return {
        'id': row[0],
        'title': row[1],
        'score': row[2],
        'genre': row[3],
        'image': row[4],
      };
    }).toList();
    return Response.ok(jsonEncode(movies),
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(body: 'Error fetching movies: $e');
  }
}

// GET /movies/<id> - Get a single movie by ID
Future<Response> getMovieById(Request request, String id) async {
  final conn = await Connection.open(Endpoint(
    host: 'localhost',
    database: 'movie',
    username: 'postgres',
    password: '1234',
  ));
  try {
    final results = await conn.execute(
      'SELECT * FROM movies WHERE id = $id',
    );
    if (results.isEmpty) {
      return Response.notFound('Movie not found');
    }
    final movie = {
      'id': results[0][0],
      'title': results[0][1],
      'score': results[0][2],
      'genre': results[0][3],
      'image': results[0][4],
    };
    return Response.ok(jsonEncode(movie),
        headers: {'Content-Type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(body: 'Error fetching movie: $e');
  }
}

// POST /movies - Create a new movie
Future<Response> createMovie(Request request) async {
  final conn = await Connection.open(Endpoint(
    host: 'localhost',
    database: 'movie',
    username: 'postgres',
    password: '1234',
  ));
  try {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    // Extract data from the request
    final title = data['title'];
    final score = data['score'];
    final genre = data['genre'];
    final image = data['image'];

    // Use parameterized query with placeholders
    String query =
        'INSERT INTO movies (title, score, genre, image) VALUES (\$1, \$2, \$3, \$4)';
    await conn.execute(query, parameters: [title, score, genre, image]);

    return Response.ok('Movie created successfully');
  } catch (e) {
    return Response.internalServerError(body: 'Error creating movie: $e');
  }
}
// PUT /movies/<id> - Update a movie by ID
Future<Response> updateMovieById(Request request, String id) async {
  final conn = await Connection.open(Endpoint(
    host: 'localhost',
    database: 'movie',
    username: 'postgres',
    password: '1234',
  ));
  try {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    // Extract data from the request
    final title = data['title'];
    final score = data['score'];
    final genre = data['genre'];
    final image = data['image'];

    // Update query with parameterized placeholders
    String query =
        'UPDATE movies SET title = \$1, score = \$2, genre = \$3, image = \$4 WHERE id = \$5';
    final result = await conn.execute(
      query,
      parameters: [title, score, genre, image, int.parse(id)],
    );

    // if (result.isEmpty) {
    //   return Response.notFound('Movie not found');
    // }

    return Response.ok('Movie updated successfully');
  } catch (e) {
    return Response.internalServerError(body: 'Error updating movie: $e');
  }
}

// DELETE /movies/<id> - Delete a movie by ID
Future<Response> deleteMovie(Request request, String id) async {
  final conn = await Connection.open(Endpoint(
    host: 'localhost',
    database: 'movie',
    username: 'postgres',
    password: '1234',
  ));

  try {
    final result = await conn.execute(
      'DELETE FROM movies WHERE id = $id RETURNING id',
    );
    if (result.isEmpty) {
      return Response.notFound('Movie not found');
    }
    return Response.ok('Movie deleted successfully');
  } catch (e) {
    return Response.internalServerError(body: 'Error deleting movie: $e');
  }
}

