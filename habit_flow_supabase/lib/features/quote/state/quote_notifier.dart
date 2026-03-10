import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/quote/models/quote.dart';
import 'package:habit_flow/features/quote/services/quote_service.dart';

class QuoteNotifier extends AsyncNotifier<Quote> {
  @override
  Future<Quote> build() async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() => QuoteService().getRandomQuote());
    return state.value!;
  }
}

final quoteProvider = AsyncNotifierProvider<QuoteNotifier, Quote>(
  QuoteNotifier.new,
);
