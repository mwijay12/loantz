# LIMS — Loan & Inventory Management System

A branch-operations app for a lending business, built as a Flutter demo: staff sign in, see the day's numbers, work the loan book and the phone inventory, and scan devices at the counter.

## Stack

Flutter · Dart · Supabase (`supabase_service.dart`) · Gemini for the assistant (`ai_service.dart`) · CI in `.github/`

## Screens

```
splash / welcome / login    entry and staff sign-in
main_shell                  tabbed shell for the signed-in session
home_page                   day summary
inventory_page              device stock
loans_page                  loan book
product_detail_page         single device
scan_page                   scanner entry for serials
admin_console_page          administrative views
```

## Running locally

```bash
flutter pub get
cp .env.example .env      # fill in your Supabase project values
flutter run
```

```bash
flutter run -d chrome     # web
flutter test
flutter analyze
```

## Structure

```
lib/screens/    entry, shell and auth flow
lib/pages/      feature pages listed above
lib/services/   Supabase and AI integrations
lib/state/      app state
lib/data/       models and demo data
lib/widgets/    shared UI
lib/theme.dart  theme tokens
```

## Note

`lib/data/demo_data.dart` seeds the app so it runs without a live database. A real deployment needs its own Supabase project; the seed rows are illustrative, not a migration.

## Licence

See [LICENSE](LICENSE).
