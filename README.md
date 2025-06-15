# Saai Al-Khayr (ساعي الخير)

**Saai Al-Khayr** is a mobile application built with Flutter to streamline the collection of donations from over 300 mosques. It features a role-based system (admin, driver, imam), real-time mission tracking, and shortest path routing powered by OpenRouteService (ORS). The backend is built using Node.js with a PostgreSQL database.

## Driver Side

- view nearby mosques and available missions.
- select the nearest task based on distance and view the optimized route to the destination.
- Integration with Google Maps allows live navigation from their current location.

<div>
<p align="center">
  <!-- Replace these with actual screenshots of the driver interface -->
  <img src="https://github.com/user-attachments/assets/1e998a18-3e89-4711-b0bf-2d31b3d406ee" height="400">
  <img src="https://github.com/user-attachments/assets/57a10b34-4fab-4ee0-9514-ec173a900327" height="400">
  <img src="https://github.com/user-attachments/assets/49f10089-01be-43aa-bc68-be4c2273c573" height="400">
  <img src="https://github.com/user-attachments/assets/255e9708-0475-42d3-b6db-06ae77a5191c" height="400">
</p>
</div>

## Admin Side

- manage mosques , drivers and imams 
- monitor ongoing collections and reset tasks weekly.
- check collected amount for a certain period of time 

<div>
<p align="center">
  <!-- Replace these with actual screenshots of the admin interface -->
  <img src="https://github.com/user-attachments/assets/8a69d464-88a0-49a3-a40c-98881b3023bc" height="400">
  <img src="https://github.com/user-attachments/assets/c170f093-2ebf-432f-8539-532b2f74c0fe" height="400">
  <img src="https://github.com/user-attachments/assets/490c88c3-1e9e-447a-bd16-52b2104564b9" height="400">
  <img src="https://github.com/user-attachments/assets/b190f280-bf6d-4bcb-8adf-44f37b8c7058" height="400">
</p>
</div>

## Imam Side

- Add the collected weekly amount for the mosque . 
- Add mosque location if missing.

<div>
<p align="center">
  <!-- Replace these with actual screenshots of the admin interface -->
  <img src="https://github.com/user-attachments/assets/71f5f785-c640-4e1a-8dec-9575bd4e95f8" height="400">
  <img src="https://github.com/user-attachments/assets/a26df199-a82f-4b89-95a8-c4558a1c2234" height="400">
</p>
</div>

## Features

- **Role-Based Access:**
  - Admin, Driver, and Imam views with specific permissions and dashboards.
- **Shortest Path Navigation:**
  - Real-time route generation using OpenRouteService (ORS).
- **Mission Management:**
  - Admins assign tasks; drivers accept and complete them.
- **Location Tracking:**
  - Foreground location tracking and alerts on proximity.
- **Weekly Task Reset:**
  - Admins can reset mosque missions every Friday.

## Architecture

This app follows the **Clean Architecture** and **Bloc Pattern**, ensuring scalability, separation of concerns, and testability across UI, domain, and data layers.

## Tools and Libraries

- [Flutter](https://flutter.dev/)
- [Bloc](https://bloclibrary.dev/)
- [GoRouter](https://pub.dev/packages/go_router)
- [GetIt](https://pub.dev/packages/get_it)
- [Equatable](https://pub.dev/packages/equatable)
- [geolocator](https://pub.dev/packages/geolocator)
- [Flutter Map](https://pub.dev/packages/flutter_map)
- [http](https://pub.dev/packages/http)
- [OpenRouteService API](https://openrouteservice.org/dev/#/)
