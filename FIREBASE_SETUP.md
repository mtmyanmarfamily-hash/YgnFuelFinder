# 🔥 Firebase Setup လမ်းညွှန်

ဤ App တွင် Firebase Real-time Database ထည့်သွင်းမှသာ
user တွေ သတင်းပို့တာကို တခြားသူများ မြင်နိုင်ပါမည်။

---

## အဆင့် ၁ — Firebase Project ဖန်တီးရန်

1. https://console.firebase.google.com သို့ သွားပါ
2. **"Add project"** နှိပ်ပါ
3. Project name: `YgnFuelFinder` (သင်ကြိုက်တဲ့အမည်)
4. Google Analytics — skip လုပ်နိုင်သည်
5. **"Create project"** နှိပ်ပါ

---

## အဆင့် ၂ — Android App ထည့်ရန်

1. Project dashboard တွင် **Android icon** နှိပ်ပါ
2. Package name: `com.ygnfuel.app` ဟု ထည့်ပါ
3. **"Register app"** နှိပ်ပါ
4. **`google-services.json`** ဖိုင် download လုပ်ပါ
5. ဒီဖိုင်ကို `android/app/google-services.json` နေရာတွင် အစားထိုးပါ
   (ယခု placeholder ဖိုင်ကို ဖျက်ပြီး download လုပ်ထားသည့် ဖိုင်ထည့်ပါ)

---

## အဆင့် ၃ — Realtime Database ဖွင့်ရန်

1. Firebase console တွင် **"Realtime Database"** သို့ သွားပါ
2. **"Create Database"** နှိပ်ပါ
3. Location: `asia-southeast1 (Singapore)` ရွေးပါ (မြန်မာနှင့် နီးစပ်)
4. Security rules — **"Start in test mode"** ရွေးပါ (အခမဲ့ 30 ရက်)
5. **"Enable"** နှိပ်ပါ

---

## အဆင့် ၄ — Authentication ဖွင့်ရန်

1. Firebase console တွင် **"Authentication"** သို့ သွားပါ
2. **"Get started"** နှိပ်ပါ
3. **"Anonymous"** ကို enable လုပ်ပါ
4. **"Save"** နှိပ်ပါ

---

## အဆင့် ၅ — Database Rules ထည့်ရန်

Realtime Database → Rules တွင် ဒီ rules ထည့်ပါ:

```json
{
  "rules": {
    "stations": {
      ".read": true,
      ".write": "auth != null"
    },
    "reports": {
      ".read": true,
      "$stationId": {
        ".write": "auth != null"
      }
    }
  }
}
```

---

## အဆင့် ၆ — ZIP ပြန် Build ရန်

1. `google-services.json` ဖိုင်ကို `android/app/` folder ထဲ ထည့်ပါ
2. ZIP ကြိမ်သစ် ပြုလုပ်ပါ
3. GitHub တွင် upload → build → APK ထုတ်ပါ

---

## ✅ ပြီးပါက ဘာဖြစ်မလဲ

- User တစ်ယောက် ဆီဆိုင် status တင်လိုက်သည်နှင့်
  တခြား user အားလုံး **real-time** တွင် မြင်ရမည်
- Report history (နောက်ဆုံး ၂၀) ကို "သတင်းများ" tab တွင် ကြည့်ရမည်
- Internet မရှိဘဲ offline တွင်လည်း basic features အလုပ်လုပ်မည်
