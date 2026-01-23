# Lendo - Library Management System

A Flutter-based library management system with role-based access control using Supabase authentication.

## Setup Instructions

### 1. Environment Configuration
1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Update the `.env` file with your Supabase credentials:
   ```
   SUPABASE_URL=your_actual_supabase_url
   SUPABASE_ANON_KEY=your_actual_supabase_anon_key
   ```

### 2. Dependencies Installation
Run the following command to install all dependencies:
```bash
flutter pub get
```

### 3. Running the Application
```bash
flutter run
```

## Project Structure

```
lib/
├── config/
│   ├── app_config.dart          # App theme and colors
│   └── supabase_config.dart     # Supabase configuration
├── screens/
│   ├── admin/
│   │   └── dashboard_screen.dart
│   ├── borrower/
│   │   └── dashboard_screen.dart
│   ├── officer/
│   │   └── dashboard_screen.dart
│   ├── auth/
│   │   └── login_screen.dart
│   └── router.dart              # Role-based routing
├── services/
│   └── auth_service.dart        # Authentication logic
├── admin/
│   └── widgets/
│       └── widget.dart          # Admin sidebar widget
└── main.dart                    # Entry point
```

## Features

- **Role-based Access Control**: Admin, Officer, and Borrower roles
- **Supabase Authentication**: Secure user authentication
- **Environment Variables**: Safe storage of API keys
- **Responsive Design**: Works on mobile devices
- **Riverpod State Management**: Efficient state management

## Roles

1. **Admin**: Full system access and management
2. **Officer**: Library staff functionalities
3. **Borrower**: Regular user functionalities

## Security Notes

- Never commit your `.env` file to version control
- Always use environment variables for sensitive data
- The `.env` file is automatically ignored by git