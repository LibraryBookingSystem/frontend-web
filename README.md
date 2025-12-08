# Library Booking System - Flutter Frontend

A comprehensive Flutter application for managing library seat/room bookings with real-time availability updates, QR code check-in, and role-based access control. This application is architected using **Aspect-Oriented Programming (AOP)** and **Service-Oriented Architecture (SOA)** principles.

## 📚 Documentation

All detailed documentation is available in the [`docs/`](docs/) folder:

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Complete architecture documentation (MVC + AOP + SOA)
- **[PLATFORM_GUIDE.md](docs/PLATFORM_GUIDE.md)** - Complete platform setup, commands, and quick start guide
- **[AOP_SOA_ARCHITECTURE.md](docs/AOP_SOA_ARCHITECTURE.md)** - Detailed AOP and SOA implementation
- **[SETUP_COMPLETE.md](docs/SETUP_COMPLETE.md)** - Setup completion summary
- **[ANALYSIS_REPORT.md](docs/ANALYSIS_REPORT.md)** - Code analysis report

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (>=3.0.0)
- Backend services running (see [Documentation/README.md](../../Documentation/README.md))
- **API Gateway** enabled and running on `http://localhost:8080` (included in docker-compose)

### Backend Setup

1. **Start Backend Services** (including API Gateway):
   ```bash
   cd docker-compose
   docker-compose up -d
   ```

2. **Verify API Gateway is Running**:
   ```bash
   docker-compose ps api-gateway
   curl http://localhost:8080/health
   ```

3. **API Configuration**:
   - The app is pre-configured to use the API Gateway at `http://localhost:8080`
   - For Android emulator, update `lib/core/config/app_config.dart`:
     ```dart
     static const String baseApiUrl = 'http://10.0.2.2:8080';
     ```

### Run the App

**Android:**
```bash
flutter run -d android
```

**Windows:**
```bash
flutter run -d windows
```

**Web:**
```bash
flutter run -d chrome
```

## 📖 Key Features

- **Aspect-Oriented Programming (AOP)**: Cross-cutting concerns via interceptors and mixins
- **Service-Oriented Architecture (SOA)**: Independent service layer for each backend microservice
- **Real-time Updates**: WebSocket-based availability updates with polling fallback
- **Role-Based Access Control**: Student, Staff, and Admin roles
- **QR Code Integration**: QR code generation and scanning for check-in

## 🏗️ Architecture

- **AOP**: Interceptors for HTTP concerns, mixins for UI/business logic
- **SOA**: Independent services for Auth, User, Resource, Booking, Policy, Notification, Analytics
- **API Gateway**: Single entry point (`http://localhost:8080`) routes all requests to microservices
- **State Management**: Provider pattern
- **Platform Support**: Android, iOS, Web, Windows

## 📝 For More Information

See the [docs/](docs/) folder for complete documentation. Start with [ARCHITECTURE.md](docs/ARCHITECTURE.md) for architecture details or [PLATFORM_GUIDE.md](docs/PLATFORM_GUIDE.md) for platform setup.

---

**Last Updated**: December 2025
