
import 'package:flutter/material.dart';
import 'package:peliculas/models/models.dart';
import 'package:peliculas/providers/movies_provider.dart';
import 'package:provider/provider.dart';

class MovieSearchDelegate extends SearchDelegate{

  @override
  String? get searchFieldLabel => 'Buscar película';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '', 
        icon: const Icon( Icons.clear_sharp )
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: (){
        close(context, null);
      } , 
      icon: const Icon(Icons.arrow_back)
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text('buildResults');
  }

  Widget _emptyContainer(){
    return Container(
        child: const Center(
          child: Icon(Icons.movie_creation_outlined, color: Colors.black38, size: 100,),
        ),
      );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    
    if( query.isEmpty ){
      return _emptyContainer();
    }

    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
    moviesProvider.getSuggestionsByQuery( query );


    // return FutureBuilder(
    //   future: moviesProvider.searchMovie(query), 
    //   builder: (_, AsyncSnapshot<List<Movie>> snapshot){

    //     if( !snapshot.hasData ) return _emptyContainer();

    //     final movies = snapshot.data!;

    //     return ListView.builder(
    //       itemCount: movies.length,
    //       itemBuilder: (_, int index) => _MovieItem( movies[index] )
    //     );
    //   }
    // ); Estas lineas se reemplazaron con:

    return StreamBuilder(
      stream: moviesProvider.suggestionStream, 
      builder: (_, AsyncSnapshot<List<Movie>> snapshot){

        if( !snapshot.hasData ) return _emptyContainer();

        final movies = snapshot.data!;

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (_, int index) => _MovieItem( movies[index] )
        );
      }
    );
  }
  
}

class _MovieItem extends StatelessWidget {

  final Movie movie;

  const _MovieItem( this.movie);

  @override
  Widget build(BuildContext context) {

    movie.heroId = 'search-${movie.id}';

    return ListTile(
      leading: Hero(
        tag: movie.heroId!,
        child: FadeInImage(
          placeholder: const AssetImage('assets/no-image.jpg'),
          image: NetworkImage( movie.fullPosterImg ),
          width: 50,
          fit: BoxFit.contain,
        ),
      ),
      title: Text( movie.title ),
      subtitle: Text( movie.originalTitle ),
      onTap: ()=>Navigator.pushNamed(context, 'details', arguments: movie),
    );
  }
}