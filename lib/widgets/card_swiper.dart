import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:peliculas/models/models.dart';

class CardSwiper extends StatelessWidget {

  final List<Movie> movies;

  const CardSwiper({
    super.key, 
    required this.movies
    });

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    if( movies.isEmpty ){
      return SizedBox(
        width: double.infinity,
        height: size.height * 0.5,
        child: const CircularProgressIndicator(),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: size.height * 0.5, //Toma el 50% de la pantasha
      //color:const Color.fromARGB(246, 16, 211, 218),
      child: Swiper(
        itemCount: movies.length,
        layout: SwiperLayout.STACK,
        itemWidth: size.width * 0.6,
        itemHeight: size.height * 0.4,
        itemBuilder: (_, int index){

          movies[index].heroId = 'swiper-${ movies[index].id }';

          return GestureDetector(
            onTap: ()=> Navigator.pushNamed(context, 'details', arguments: movies[index]),
            child: Hero(
              tag: movies[index].heroId!,
              child: ClipRRect(
                borderRadius:  BorderRadius.circular(20),
                child: FadeInImage(
                  placeholder: const AssetImage('assets/no-image.jpg'), 
                  image: NetworkImage(movies[index].fullPosterImg),
                  fit: BoxFit.cover
                ),
              ),
            ),
          );

        }
      ),
    );
  }
}