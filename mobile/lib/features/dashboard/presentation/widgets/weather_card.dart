import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:taskmail/features/dashboard/presentation/widgets/glass_card.dart';
import 'package:taskmail/l10n/app_localizations.dart';
import 'package:taskmail/theme/app_colors.dart';

/// Current weather card (Open-Meteo, no API key). Default: Tel Aviv.
class WeatherCard extends StatefulWidget {
  const WeatherCard({
    super.key,
    this.latitude = 32.0853,
    this.longitude = 34.7818,
    this.locationLabel,
  });

  final double latitude;
  final double longitude;
  final String? locationLabel;

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  _WeatherSnapshot? _weather;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      final response = await dio.get<Map<String, dynamic>>(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': widget.latitude,
          'longitude': widget.longitude,
          'current':
              'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
          'timezone': 'auto',
        },
      );
      final current = response.data?['current'] as Map<String, dynamic>?;
      if (current == null) {
        throw StateError('No current weather');
      }
      if (!mounted) return;
      setState(() {
        _weather = _WeatherSnapshot(
          temperatureC: (current['temperature_2m'] as num).toDouble(),
          humidity: (current['relative_humidity_2m'] as num?)?.toInt() ?? 0,
          windKmh: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0,
          weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
        );
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final place = widget.locationLabel ?? l.weatherDefaultLocation;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, size: 16, color: AppColors.warning),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l.weatherNowTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (!_loading)
                InkWell(
                  onTap: _load,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.refresh,
                      size: 14,
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (_error != null || _weather == null)
            Text(
              l.weatherUnavailable,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                color: AppColors.darkTextSecondary,
              ),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _weather!.icon,
                  size: 36,
                  color: _weather!.iconColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_weather!.temperatureC.round()}°',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkTextPrimary,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        _weather!.description(l),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              place,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l.weatherDetails(_weather!.humidity, _weather!.windKmh.round()),
              style: const TextStyle(
                fontSize: 10,
                height: 1.3,
                color: AppColors.darkTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeatherSnapshot {
  const _WeatherSnapshot({
    required this.temperatureC,
    required this.humidity,
    required this.windKmh,
    required this.weatherCode,
  });

  final double temperatureC;
  final int humidity;
  final double windKmh;
  final int weatherCode;

  IconData get icon {
    if (weatherCode == 0) return Icons.wb_sunny;
    if (weatherCode <= 3) return Icons.wb_cloudy;
    if (weatherCode <= 48) return Icons.cloud;
    if (weatherCode <= 67) return Icons.water_drop;
    if (weatherCode <= 77) return Icons.ac_unit;
    if (weatherCode <= 82) return Icons.umbrella;
    if (weatherCode <= 99) return Icons.thunderstorm;
    return Icons.cloud;
  }

  Color get iconColor {
    if (weatherCode == 0) return AppColors.warning;
    if (weatherCode <= 3) return AppColors.primary;
    if (weatherCode <= 67) return const Color(0xFF64B5F6);
    if (weatherCode <= 77) return const Color(0xFF90CAF9);
    return AppColors.primary;
  }

  String description(AppLocalizations l) {
    if (weatherCode == 0) return l.weatherClear;
    if (weatherCode <= 3) return l.weatherCloudy;
    if (weatherCode <= 48) return l.weatherFog;
    if (weatherCode <= 67) return l.weatherRain;
    if (weatherCode <= 77) return l.weatherSnow;
    if (weatherCode <= 82) return l.weatherShowers;
    if (weatherCode <= 99) return l.weatherThunder;
    return l.weatherCloudy;
  }
}
