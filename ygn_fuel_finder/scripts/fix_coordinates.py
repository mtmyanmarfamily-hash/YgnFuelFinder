#!/usr/bin/env python3
import re, json, time, sys, os
import urllib.request, urllib.parse

API_KEY = os.environ.get('GEOCODING_API_KEY', '')
if not API_KEY:
    print("ERROR: GEOCODING_API_KEY not set")
    sys.exit(1)

DART_FILE = 'lib/data/station_data.dart'

def geocode(query):
    url = ("https://maps.googleapis.com/maps/api/geocode/json"
           f"?address={urllib.parse.quote(query)}&key={API_KEY}&language=my&region=MM")
    req = urllib.request.Request(url, headers={'User-Agent': 'YgnFuelFinder/1.0'})
    with urllib.request.urlopen(req, timeout=10) as r:
        data = json.loads(r.read())
    if data['status'] == 'OK':
        loc = data['results'][0]['geometry']['location']
        addr = data['results'][0]['formatted_address']
        return loc['lat'], loc['lng'], addr
    return None, None, data['status']

def in_yangon(lat, lng):
    return 16.60 <= float(lat) <= 17.20 and 95.90 <= float(lng) <= 96.40

QUERIES = {
    'max_thein_phyu':     'Max Energy Thein Phyu Mingalartaungnyunt Yangon Myanmar',
    'max_kyun_taw':       'Max Energy Hanthawaddy Kyun Taw Kamaryut Yangon Myanmar',
    'max_ahlone':         'Max Energy Ahlone Road Yangon Myanmar',
    'max_tamwe':          'Max Energy Kyaikkasan Tamwe Yangon Myanmar',
    'max_bahan':          'Max Energy Sayasan Bahan Yangon Myanmar',
    'max_thuwanna':       'Max Energy Thuwanna Thingangyun Yangon Myanmar',
    'max_tharkayta':      'Max Energy Minnandar Tharkayta Yangon Myanmar',
    'max_aung_mingalar':  'Max Energy Aung Mingalar Bus Terminal Yangon Myanmar',
    'max_padauk_chaung':  'Max Energy Padauk Chaung Thiri Mingalar Market Bayintnaung Hlaing Yangon Myanmar',
    'max_south_okkalapa': 'Max Energy South Okkalapa Yangon Myanmar',
    'max_lay_daungkan':   'Max Energy Lay Daungkan South Dagon Yangon Myanmar',
    'max_sin_ma_lite':    'Max Energy Sin Ma Lite Bayintnaung Kamaryut Yangon Myanmar',
    'max_dagon_ayar':     'Max Energy Dagon Ayar Highway Hlaingtharya Yangon Myanmar',
    'max_shwepyithar':    'Max Energy Shwepyithar Yangon Myanmar',
    'max_hlegu1':         'Max Energy Hlegu Yangon Myanmar',
    'max_hmawbi':         'Max Energy Hmawbi Yangon Myanmar',
    '360petro_north_dagon':    '360 Petro North Dagon Yangon Myanmar',
    '360petro_south_dagon':    '360 Petro South Dagon Yangon Myanmar',
    '360petro_thaketa':        '360 Petro Thaketa Yangon Myanmar',
    '360petro_north_okkalapa': '360 Petro North Okkalapa Yangon Myanmar',
    '360petro_parami':         '360 Petro Bayintnaung Road Yangon Myanmar',
    'denko_north_dagon':  'Denko fuel station North Dagon Yangon Myanmar',
    'denko_insein':       'Denko fuel station Insein Yangon Myanmar',
    'terminal_205':       'Terminal petrol station Yangon Myanmar',
    'terminal_202':       'Terminal petrol station Mingaladon Yangon Myanmar',
    'terminal_thanlyin':  'Terminal petrol station Thanlyin Yangon Myanmar',
    'newday_south_okkalapa': 'New Day petrol station South Okkalapa Yangon Myanmar',
    'newday_kabar_aye':   'New Day petrol station Kabar Aye Pagoda Road Yangon Myanmar',
    'newday_baho':        'New Day petrol station Baho Road Yangon Myanmar',
    'newday_pazundaung':  'New Day petrol station Pazundaung Yangon Myanmar',
    'pt_south_dagon':     'PT Power petrol station South Dagon Yangon Myanmar',
    'pt_thaketa':         'PT Power petrol station Thaketa Yangon Myanmar',
    'pt_central':         'PT Power petrol station Yangon Myanmar',
    'moonsun_mayangon':   'Moon Sun petrol station Mayangon Yangon Myanmar',
    'kzh_banyardala':     'KZH petrol station Banyardala Road Yangon Myanmar',
    'sbp_pathein_rd':     'SBP petrol station Pathein Road Yangon Myanmar',
    'myawaddy_no4':       'Myawaddy petrol station No 4 Highway Yangon Myanmar',
    'myawaddy_insein':    'Myawaddy petrol station Insein Yangon Myanmar',
}

content = open(DART_FILE, encoding='utf-8').read()
updated = 0
failed = 0

for sid, query in QUERIES.items():
    pattern = rf"(id: '{re.escape(sid)}'.*?lat: )([\d.]+)(, lng: )([\d.]+)(,)"
    match = re.search(pattern, content)
    if not match:
        print(f"SKIP {sid}: not found")
        continue
    old_lat, old_lng = float(match.group(2)), float(match.group(4))
    try:
        lat, lng, addr = geocode(query)
        time.sleep(0.25)
        if lat and lng and in_yangon(lat, lng):
            dist = ((lat-old_lat)**2 + (lng-old_lng)**2)**0.5 * 111000
            new = f"{match.group(1)}{lat:.6f}{match.group(3)}{lng:.6f}{match.group(5)}"
            content = content[:match.start()] + new + content[match.end():]
            print(f"OK {sid}: {lat:.6f},{lng:.6f} moved={dist:.0f}m addr={str(addr)[:50]}")
            updated += 1
        else:
            print(f"FAIL {sid}: status={addr} coords=({lat},{lng})")
            failed += 1
    except Exception as e:
        print(f"ERROR {sid}: {e}")
        failed += 1

open(DART_FILE, 'w', encoding='utf-8').write(content)
print(f"\nDONE: updated={updated} failed={failed} total={len(QUERIES)}")
