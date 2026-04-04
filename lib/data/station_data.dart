import '../models/fuel_station.dart';

class StationData {
  static List<FuelStation> getStations() {
    return [
      // === MAX ENERGY (17 Stations) ===
      _createStation('max_kyun_taw', 'Max Energy (ကျွန်းတောလမ်း)', 'ဟံသာဝတီလမ်း နှင့် ကျွန်းတောလမ်းဒေါင့်', 16.815243, 96.129528, ['92','95','PD','D']),
      _createStation('max_padauk_chaung', 'Max Energy (ပိတောက်ချောင်း)', 'ဘုရင့်နောင်လမ်း၊ လှိုင်မြို့နယ်', 16.868120, 96.115250, ['92','95','PD','D']),
      _createStation('max_sayar_san', 'Max Energy (ဆရာစံလမ်း)', 'ဆရာစံလမ်း၊ ဗဟန်းမြို့နယ်', 16.819034, 96.158521, ['92','95','PD','D']),
      _createStation('max_thein_phyu', 'Max Energy (Thein Phyu)', 'သိမ်ဖြူလမ်းမကြီး၊ မင်္ဂလာတောင်ညွန့်', 16.796721, 96.158012, ['92','95','PD','D']),
      _createStation('max_ahlone', 'Max Energy (Ahlone)', 'အလုံလမ်း၊ အလုံမြို့နယ်', 16.789456, 96.126543, ['92','95','PD','D']),
      _createStation('max_tamwe', 'Max Energy (Tamwe)', 'ကျိုက္ကဆံလမ်း၊ တာမွေမြို့နယ်', 16.81889, 96.17554, ['92','95','PD']),
      _createStation('max_bahan', 'Max Energy (Bahan)', 'ဗဟန်းမြို့နယ်', 16.806654, 96.151678, ['92','95','PD']),
      _createStation('max_thuwanna', 'Max Energy (Thuwanna)', 'သံသုမာလမ်း၊ သင်္ဃန်းကျွန်း', 16.858712, 96.186345, ['92','95','PD','D']),
      _createStation('max_tharkayta', 'Max Energy (Tharkayta)', 'သာကေတမြို့နယ်', 16.804231, 96.195678, ['92','95','PD','D']),
      _createStation('max_aung_mingalar', 'Max Energy (Aung Mingalar)', 'အောင်မင်္ဂလာ', 16.847812, 96.119845, ['92','95','PD','D']),
      _createStation('max_south_okkalapa', 'Max Energy (South Okkalapa)', 'တောင်ဥက္ကလာ', 16.835612, 96.175634, ['92','95','PD','D']),
      _createStation('max_lay_daungkan', 'Max Energy (Lay Daungkan)', 'ဒဂုံမြို့သစ်တောင်', 16.828945, 96.203123, ['92','95','PD']),
      _createStation('max_sin_ma_lite', 'Max Energy (Sin Ma Lite)', 'ကမာရွတ်မြို့နယ်', 16.855812, 96.117834, ['92','95','PD']),
      _createStation('max_dagon_ayar', 'Max Energy (Dagon Ayar)', 'လှိုင်သာယာ', 16.914023, 96.051234, ['92','95','D']),
      _createStation('max_shwepyithar', 'Max Energy (Shwepyithar)', 'ရွှေပြည်သာ', 16.937412, 96.112123, ['92','95','D']),
      _createStation('max_hlegu1', 'Max Energy (Hlegu-1)', 'လှည်းကူး', 17.023412, 96.145634, ['92','95','D']),
      _createStation('max_hmawbi', 'Max Energy (Hmawbi)', 'မှော်ဘီမြို့နယ်', 17.105312, 96.093412, ['92','95','D']),

      // === 360° PETRO (5 Stations) ===
      _createStation('360petro_parami', '360° Petro (ဘုရင့်နောင်)', 'ဘုရင့်နောင်လမ်းမကြီး၊ လှိုင်မြို့နယ်', 16.865510, 96.103250, ['92','95','PD','D']),
      _createStation('360petro_north_dagon', '360° Petro (မြောက်ဒဂုံ)', 'မြောက်ဒဂုံ', 16.8921688, 96.1795913, ['92','95','PD','D']),
      _createStation('360petro_south_dagon', '360° Petro (တောင်ဒဂုံ)', 'တောင်ဒဂုံ', 16.8334103, 96.1960309, ['92','95','PD']),
      _createStation('360petro_thaketa', '360° Petro (သာကေတ)', 'သာကေတမြို့နယ်', 16.802345, 96.218712, ['92','95','PD']),
      _createStation('360petro_north_okkalapa', '360° Petro (မြောက်ဥက္ကလာ)', 'မြောက်ဥက္ကလာပမြို့နယ်', 16.875712, 96.189412, ['92','95','D']),

      // === DENKO (2 Stations) ===
      _createStation('denko_north_dagon', 'DENKO ဆီဆိုင် (မြောက်ဒဂုံ)', 'ဗိုလ်မှူးဘထူးလမ်း၊ မြောက်ဒဂုံ', 16.885458, 96.165922, ['92','95','PD','D']),
      _createStation('denko_insein', 'DENKO ဆီဆိုင် (အင်းစိန်)', 'အင်းစိန်လမ်းမကြီး၊ အင်းစိန်', 16.886083, 96.109679, ['92','95','PD','D']),

      // === TERMINAL (4 Stations) ===
      _createStation('terminal_205', 'Terminal ဆီဆိုင် (205)', 'ရန်ကုန်မြို့', 16.8668633, 96.1315741, ['92','95','PD','D']),
      _createStation('terminal_central', 'Terminal (ဗဟိုလမ်း)', 'ဗဟိုလမ်း၊ ကမာရွတ်', 16.829140, 96.126192, ['92','95','PD','D']),
      _createStation('terminal_202', 'Terminal ဆီဆိုင် (202-မင်္ဂလာဒုံ)', 'မင်္ဂလာဒုံမြို့နယ်', 16.952789, 96.1502402, ['92','95','D']),
      _createStation('terminal_thanlyin', 'Terminal ဆီဆိုင် (သံလျင်)', 'သံလျင်မြို့နယ်', 16.7750536, 96.2489053, ['92','95','D']),

      // === NEW DAY (5 Stations) ===
      _createStation('newday_south_okkalapa', 'New Day (တောင်ဥက္ကလာ)', '၇၀ ဝိဇယလမ်း၊ တောင်ဥက္ကလာ', 16.8340365, 96.178166, ['92','95','PD','D']),
      _createStation('newday_kabar_aye', 'New Day (ကမ္ဘာအေး)', 'ကမ္ဘာအေးဘုရားလမ်း', 16.836254, 96.171189, ['92','95','PD']),
      _createStation('newday_7th_st', 'New Day (၇လမ်း)', '၇ လမ်း၊ တောင်ဥက္ကလာ', 16.829785, 96.182254, ['92','95','PD']),
      _createStation('newday_baho', 'New Day (ဘဟိုလမ်း)', 'ဘဟိုလမ်း', 16.80439, 96.13012, ['92','95']),
      _createStation('newday_pazundaung', 'New Day (ပုဇွန်တောင်)', 'ပုဇွန်တောင်မြို့နယ်', 16.78916, 96.18006, ['92','95','PD']),

      // === PT POWER (3 Stations) ===
      _createStation('pt_south_dagon', 'PT Power (တောင်ဒဂုံ)', 'တောင်ဒဂုံမြို့နယ်', 16.8257591, 96.239254, ['92','95','PD','D']),
      _createStation('pt_thaketa', 'PT Power (သာကေတ)', 'သာကေတမြို့နယ်', 16.7972212, 96.2234997, ['92','95','PD']),
      _createStation('pt_central', 'PT Power (ဗဟို)', 'ရန်ကုန်မြို့', 16.8476079, 96.2189635, ['92','95','PD','D']),

      // === OTHERS ===
      _createStation('htoo_kyeemyindaing', 'Htoo ဆီဆိုင် (ကြည်မြင်တိုင်)', 'ကြည်မြင်တိုင် ကနားလမ်း', 16.78098, 96.1311, ['92','95']),
      _createStation('mmtm_bayintnaung', 'MMTM ဆီဆိုင် (ဘုရင့်နောင်)', 'ဘုရင့်နောင်လမ်း', 16.8329925, 96.1210996, ['92','95','PD']),
      _createStation('regency_kyeemyindaing', 'Regency ဆီဆိုင် (ကြည်မြင်တိုင်)', 'ကြည်မြင်တိုင် ကနားလမ်း', 16.7979154, 96.1221991, ['92','95']),
    ];
  }

  static FuelStation _createStation(String id, String name, String address, double lat, double lng, List<String> fuels) {
    return FuelStation(
      id: id,
      name: name,
      address: address,
      lat: lat,
      lng: lng,
      fuelTypes: fuels,
      status: FuelStatus.unknown,
      availableFuels: { for (var f in fuels) f : true },
      queueMinutes: 0,
      lastUpdated: DateTime.now(),
    );
  }
}
