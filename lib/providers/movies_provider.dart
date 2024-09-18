
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/helpers/debouncer.dart';
import 'package:peliculas/models/models.dart';


class MoviesProvider extends ChangeNotifier {

  final String _apiKey ='c05b050561245723603f0c16f5fe2a1c';
  final String _baseUrl ='api.themoviedb.org';
  final String _language = 'es-ES';
  final StreamController<List<Movie>> _suggestionStreamController = StreamController.broadcast();
  final debouncer = Debouncer(
    duration: const Duration(milliseconds: 500)
  );


  Stream<List<Movie>> get suggestionStream => _suggestionStreamController.stream;  

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  Map<int, List<Cast>> moviesCast = {};

  int _popularPage = 0;


  MoviesProvider(){
    print('MoviesProvider inicializado');

    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<String> _getJsonData( String endpoint, [int page =1 ] ) async {
    var url = Uri.https(_baseUrl, endpoint, {
      'api_key': _apiKey,
      'language': _language,
      'page': '$page'
    });
    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async {
    final jsonData = await _getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);
    
    onDisplayMovies = nowPlayingResponse.results;
    
    notifyListeners();
  }

  getPopularMovies() async {

    _popularPage++;
    
    final jsonData = await _getJsonData('3/movie/popular', _popularPage);
    final popularResponse = PopularResponse.fromJson(jsonData);
    
    popularMovies = [...popularMovies, ...popularResponse.results];
    
    notifyListeners();
  }

  Future<List<Cast>>getMovieCast( int movieId ) async {

    if( moviesCast.containsKey(movieId) ) return moviesCast[movieId]!; // Si la KEY ya ha sido asignada al mapa, entonces no llama otra vez a la API

    print('Pidiendo info actores');

    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson( jsonData );

    moviesCast[movieId] = creditsResponse.cast;

    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovie( String query ) async{
    final url = Uri.https(_baseUrl, '3/search/movie', {
      'api_key': _apiKey,
      'language': _language,
      'query': query
    });

    final response = await http.get(url);
    final searchMovieResponse = SearchMovieResponse.fromJson( response.body );

    return searchMovieResponse.results; 

  }

  void getSuggestionsByQuery( String searchTerm ){

    debouncer.value = '';
    debouncer.onValue =(value) async {

      //print('Tenemos valor a buscar: $value');
      final results = await searchMovie(value);
      _suggestionStreamController.add(results);

    };

    final timer = Timer.periodic(const Duration(milliseconds: 300), ( _ ) { 
      debouncer.value = searchTerm;
    });


    Future.delayed(const Duration(milliseconds: 301)).then(( _ ) => timer.cancel());
  }

}