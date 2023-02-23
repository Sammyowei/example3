import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

enum City {
  stockholm,
  paris,
  london,
  newyork,
  tokyo,
  sydney,
  moscow,
  berlin,
  rome,
  madrid,
}

typedef WeatherEmoji = String;
Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(
    const Duration(seconds: 1),
    () =>
        {
          City.stockholm: '🌤',
          City.paris: '🌧',
          City.london: '🌦',
          City.berlin: '🌧',
          City.madrid: '🌧',
          City.moscow: '🌧',
          City.newyork: '🌧',
          City.rome: '🌧',
          City.sydney: '🌧',
          City.tokyo: '🌧',
        }[city] ??
        '🌩',
  );
}

// UI writes to this and UI reads from this
final currentCityProvider = StateProvider<City?>((ref) => null);

const unknownWeatherEmoji = "🤔";

// UI reads from this
final weatherProvider = FutureProvider(
  (ref) {
    final city = ref.watch(currentCityProvider);

    if (city != null) {
      return getWeather(city);
    } else {
      return unknownWeatherEmoji;
    }
  },
);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(weatherProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Weather App"),
      ),
      body: Column(
        children: [
          currentWeather.when(
            data: (data) => Text(
              data.toString(),
              style: const TextStyle(
                fontSize: 40,
              ),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => const Text("Error 😭"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: City.values.length,
              itemBuilder: (context, index) {
                final city = City.values[index];
                final isSelectedCity = city == ref.watch(currentCityProvider);
                return ListTile(
                  title: Text(
                    city.toString(),
                  ),
                  trailing: isSelectedCity ? const Icon(Icons.check) : null,
                  onTap: () {
                    ref.read(currentCityProvider.notifier).state = city;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
