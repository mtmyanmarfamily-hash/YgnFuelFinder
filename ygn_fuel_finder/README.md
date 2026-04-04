# ⛽ ရန်ကုန် ဆီဌာနနေရာရှာဖွေရေး App
## Yangon Fuel Finder

ရန်ကုန်မြို့တွင်း ဆီဌာနနေရာများကို real-time map ပေါ် ပြသပြီး user တွေ သတင်းပို့နိုင်တဲ့ Android App

---

## 📱 Features

- 🗺️ **Live Map** — OpenStreetMap ပေါ် ဆီဌာနနေရာများ ကြည့်ရှုနိုင်
- ✅ **Status Colors** — အစိမ်း (ဆီရ) / လိမ္မော်ရောင် (ရှည်) / အနီ (မရ) / မီးခိုး (မသိ)
- 📋 **List View** — ဆီဌာနစာရင်း Search/Filter
- 📢 **User Report** — ဆီရ/မရ/တန်းစီရှည် status user တင်နိုင်
- ⛽ **Fuel Filter** — 92, 95, PD, D အမျိုးအစားအလိုက် filter
- 💾 **Local Storage** — offline အလုပ်လုပ်သည် (SharedPreferences)

---

## 🛠️ Build Instructions (APK ထုတ်နည်း)

### Prerequisites
```bash
# 1. Flutter SDK install (version 3.x)
# https://docs.flutter.dev/get-started/install

# 2. Android Studio + Android SDK

# 3. Java JDK 11+
```

### Step 1: Project Setup
```bash
git clone <your-repo-url>
cd ygn_fuel_finder

# Dependencies install
flutter pub get
```

### Step 2: Debug APK Build
```bash
flutter build apk --debug
# APK location: build/app/outputs/flutter-apk/app-debug.apk
```

### Step 3: Release APK Build
```bash
flutter build apk --release
# APK location: build/app/outputs/flutter-apk/app-release.apk
```

### Step 4: Split APKs (ဖိုင်အရွယ်အစားသေး)
```bash
flutter build apk --split-per-abi
# arm64-v8a, armeabi-v7a, x86_64 သီးခြားစီ
```

---

## 📁 Project Structure

```
ygn_fuel_finder/
├── lib/
│   ├── main.dart                  # App entry point
│   ├── models/
│   │   └── fuel_station.dart      # Data models
│   ├── providers/
│   │   └── fuel_provider.dart     # State management
│   ├── screens/
│   │   ├── map_screen.dart        # မြေပုံ screen
│   │   ├── list_screen.dart       # စာရင်း screen
│   │   └── station_detail_screen.dart  # အသေးစိတ် + report
│   ├── widgets/
│   │   └── fuel_filter_bar.dart   # Filter bar widget
│   └── data/
│       └── station_data.dart      # ဆီဌာနများ seed data
├── android/                       # Android config
├── pubspec.yaml                   # Dependencies
└── README.md
```

---

## 📦 Dependencies

| Package | ရည်ရွယ်ချက် |
|---------|------------|
| `flutter_map` | OpenStreetMap မြေပုံ |
| `latlong2` | မြေပုံ coordinates |
| `shared_preferences` | Local data သိမ်းဆည်း |
| `provider` | State management |
| `geolocator` | GPS location |
| `flutter_local_notifications` | Local notifications |

---

## ➕ ဆီဌာနအသစ် ထည့်နည်း

`lib/data/station_data.dart` ဖိုင်ထဲ ဒီ format နဲ့ ထည့်ပါ —

```dart
FuelStation(
  id: 'ygn_XXX',          // unique ID
  name: 'ဆီဌာနအမည်',
  address: 'လိပ်စာ',
  lat: 16.XXXX,            // Google Maps မှ latitude
  lng: 96.XXXX,            // Google Maps မှ longitude
  fuelTypes: ['92', '95'], // ရနိုင်သော ဆီအမျိုးအစား
  lastUpdated: DateTime.now(),
),
```

---

## 🚀 Future Improvements

- [ ] Firebase real-time sync (community sharing)
- [ ] Push notifications (နီးစပ်ရာ ဆီဆိုင်တွင် ဆီရောက်မှ alert)
- [ ] Google Maps integration
- [ ] Crowd-sourced station database
- [ ] iOS version

---

## 📄 License
MIT License - Free to use and modify
