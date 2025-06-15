import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final class InternetConnectionEvent{
  const InternetConnectionEvent();
}

final class AppStartedEvent extends InternetConnectionEvent{
  const AppStartedEvent();
}
final class OnCheckInternetEvent extends InternetConnectionEvent {
  final InternetStatus status;
  const OnCheckInternetEvent(this.status);
}