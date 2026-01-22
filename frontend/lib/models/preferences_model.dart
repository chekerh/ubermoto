import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preferences_model.g.dart';

@JsonSerializable()
class PreferencesModel extends Equatable {
  final NotificationPreferences notifications;
  final String language;
  final String theme;
  final String currency;

  const PreferencesModel({
    required this.notifications,
    required this.language,
    required this.theme,
    required this.currency,
  });

  factory PreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$PreferencesModelFromJson(json);

  Map<String, dynamic> toJson() => _$PreferencesModelToJson(this);

  factory PreferencesModel.defaultPreferences() {
    return const PreferencesModel(
      notifications: NotificationPreferences(
        email: true,
        push: true,
        sms: false,
        deliveryUpdates: true,
        promotions: true,
      ),
      language: 'en',
      theme: 'system',
      currency: 'TND',
    );
  }

  @override
  List<Object> get props => [notifications, language, theme, currency];
}

@JsonSerializable()
class NotificationPreferences extends Equatable {
  final bool email;
  final bool push;
  final bool sms;
  final bool deliveryUpdates;
  final bool promotions;

  const NotificationPreferences({
    required this.email,
    required this.push,
    required this.sms,
    required this.deliveryUpdates,
    required this.promotions,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPreferencesToJson(this);

  @override
  List<Object> get props => [email, push, sms, deliveryUpdates, promotions];
}
