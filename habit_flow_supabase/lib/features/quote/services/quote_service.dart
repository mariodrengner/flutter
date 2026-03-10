import 'package:dio/dio.dart';
import 'package:habit_flow/features/quote/models/quote.dart';

class QuoteService {
  
  final dio = Dio();
  static String baseUrl = 'https://dummyjson.com';

  Future<Quote> getRandomQuote() async {
    final response = await dio.get('$baseUrl/quotes/random');
    return Quote.fromJson(response.data);
  }
}
