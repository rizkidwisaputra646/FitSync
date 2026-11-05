import csv
import json
import re
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

CLOUDINARY_CSV = BASE_DIR / "cloudinary_urls.csv"
R2_EXERCISES_JSON = BASE_DIR / "r2_assets" / "data" / "exercises.json"
APP_DATASET_JSON = BASE_DIR / "assets" / "data" / "exercises_dataset.json"

PRESET_MAPPING = {
    'barbell-bench-press': '0025',
    'incline-barbell-bench-press': '0047',
    'decline-barbell-bench-press': '0033',
    'flat-dumbbell-bench-press': '0289',
    'incline-dumbbell-press': '0314',
    'barbell-bent-over-row': '0027',
    'lat-pulldown': '0197',
    'barbell-deadlift': '0032',
    'barbell-back-squat': '0043',
    'barbell-bicep-curl': '0031',
    'dumbbell-bicep-curl': '0294',
    'hammer-curl-dumbbell': '0313',
    'triceps-rope-pushdown': '0241',
    'dumbbell-lateral-raise': '0334',
    'cable-lateral-raise': '0178',
    'standing-calf-raise-machine': '0738',
    'leg-press-45': '0739',
    'leg-extension-machine': '0585',
    'lying-leg-curl-machine': '0589',
    'standard-push-up': '0662',
    'diamond-push-up': '0290',
    'chest-dips': '0251',
    'ab-wheel-rollout': '0971',
    'hanging-leg-raise': '0472',
    'standard-forearm-plank': '0464',
    'seated-cable-row': '0198',
    'pec-deck-fly-machine': '0577',
    'romanian-deadlift': '0085',
    'walking-lunges-dumbbell': '0337',
    'goblet-squat-dumbbell': '0310',
    'barbell-hip-thrust': '0046',
    'cable-seated-high-row': '1472',
    'face-pull-cable': '0204',
    'seated-dumbbell-shoulder-press': '0387',
    'one-arm-dumbbell-row': '0292',
}

def to_title_case(s):
    words = s.strip().split()
    return ' '.join(w.capitalize() if not w.startswith('(') else '(' + w[1:].capitalize() for w in words)

def map_target_muscle(body_part, target, name):
    bp = body_part.lower()
    tgt = target.lower()
    nm = name.lower()

    if bp == 'chest':
        return 'Chest'
    elif bp == 'back':
        return 'Back'
    elif bp == 'shoulders':
        return 'Shoulder'
    elif bp == 'waist':
        return 'Abs & Core'
    elif bp == 'cardio':
        return 'Cardio'
    elif bp == 'upper arms':
        if 'tricep' in tgt or 'tricep' in nm:
            return 'Triceps'
        elif 'bicep' in tgt or 'bicep' in nm or 'curl' in nm:
            return 'Biceps'
        return 'Arms'
    elif bp == 'lower arms':
        return 'Biceps' if 'curl' in nm else 'Arms'
    elif bp in ['upper legs', 'lower legs']:
        if 'glute' in tgt or 'glute' in nm or 'hip' in nm:
            return 'Glutes'
        return 'Legs'
    elif bp == 'neck':
        return 'Back'
    return 'Full Body'

def map_equipment(raw):
    eq = raw.lower().strip()
    mapping = {
        'barbell': 'Barbell',
        'dumbbell': 'Dumbbell',
        'cable': 'Cable Machine',
        'leverage machine': 'Chest Press Machine',
        'smith machine': 'Smith Machine',
        'body weight': 'Bodyweight',
        'band': 'Resistance Band',
        'kettlebell': 'Kettlebell',
        'stability ball': 'Gym Ball',
        'medicine ball': 'Medicine Ball',
        'rope': 'Battle Rope',
        'roller': 'Foam Roller',
        'wheel roller': 'Ab Wheel',
        'assisted': 'Machine',
        'bosu ball': 'Bosu Ball',
        'olympic barbell': 'Barbell',
        'ez barbell': 'Barbell',
        'weighted': 'Bodyweight',
        'sled machine': 'Leg Press Machine',
    }
    return mapping.get(eq, to_title_case(raw))

def map_difficulty(equip, name):
    nm = name.lower()
    if 'deadlift' in nm or 'clean' in nm or 'snatch' in nm or 'handstand' in nm:
        return 'Advanced'
    if equip in ['Bodyweight', 'Gym Ball', 'Resistance Band', 'Bosu Ball']:
        return 'Beginner'
    if equip in ['Barbell', 'Cable Machine']:
        return 'Intermediate'
    return 'Intermediate'

def get_reps(muscle):
    if muscle in ['Chest', 'Back', 'Legs']:
        return (4, '8-12 Reps')
    elif muscle in ['Biceps', 'Triceps', 'Shoulder', 'Glutes']:
        return (3, '10-15 Reps')
    elif muscle == 'Abs & Core':
        return (3, '15-20 Reps')
    elif muscle == 'Cardio':
        return (3, '30-45 Detik')
    return (3, '10-12 Reps')

def main():
    print("=== GENERATING 100% UNIQUE EXERCISE DATASET ===")

    # 1. Load CSV
    with open(CLOUDINARY_CSV, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        csv_rows = list(reader)

    gif_map = {r['filename']: r['url'] for r in csv_rows if r['type'] == 'gifs'}
    img_map = {r['filename']: r['url'] for r in csv_rows if r['type'] == 'images'}

    # 2. Load Master Dataset
    with open(R2_EXERCISES_JSON, 'r', encoding='utf-8-sig') as f:
        raw_exercises = json.load(f)

    # Inverted map: raw_id -> preset_id
    id_to_preset = {v: k for k, v in PRESET_MAPPING.items()}

    new_dataset = []
    seen_gifs = set()

    # First pass: Add all preset-linked exercises to guarantee their place at the top
    for raw_id, preset_id in PRESET_MAPPING.items():
        pass  # will be handled in order

    for ex in raw_exercises:
        raw_id = ex['id']
        gif_file = ex['gif_url'].split('/')[-1]
        img_file = ex['image'].split('/')[-1]

        gif_url = gif_map.get(gif_file)
        img_url = img_map.get(img_file)

        if not gif_url or not img_url:
            continue

        # Check uniqueness of GIF
        if gif_url in seen_gifs:
            continue
        seen_gifs.add(gif_url)

        # Determine ID: use preset ID if mapped, else raw_id or slugified name
        if raw_id in id_to_preset:
            ex_id = id_to_preset[raw_id]
        else:
            ex_id = f"ex-{raw_id}"

        name = to_title_case(ex['name'])
        target_muscle = map_target_muscle(ex.get('body_part', ''), ex.get('target', ''), ex['name'])
        equipment = map_equipment(ex.get('equipment', 'body weight'))
        difficulty = map_difficulty(equipment, ex['name'])
        sets, reps = get_reps(target_muscle)

        # Instructions
        steps = ex.get('instruction_steps', {}).get('en', [])
        if not steps:
            desc = ex.get('instructions', {}).get('en', '')
            if desc:
                steps = [s.strip() for s in desc.split('.') if len(s.strip()) > 5]
            else:
                steps = [
                    f"Posisikan tubuh dengan stabil untuk melakukan {name}.",
                    "Jaga kendali dan form sepanjang rentang gerak penuh (Full Range of Motion).",
                    "Keluarkan napas saat fase kontraksi dan ambil napas saat fase relaksasi."
                ]

        tips = [
            "Pertahankan postur tubuh dan kendali penuh sepanjang rentang gerak.",
            "Fokuskan kontraksi pada otot target dan jangan memantulkan beban secara tiba-tiba."
        ]

        sec_muscles = [to_title_case(m) for m in ex.get('secondary_muscles', []) if m]

        new_dataset.append({
            'id': ex_id,
            'name': name,
            'targetMuscle': target_muscle,
            'secondaryMuscles': sec_muscles,
            'equipment': equipment,
            'difficulty': difficulty,
            'recommendedSets': sets,
            'recommendedReps': reps,
            'instructions': steps,
            'tips': tips,
            'gifUrl': gif_url,
            'thumbnailUrl': img_url,
            'isActive': True,
            'isCustom': False,
        })

    # Sort so that preset items come first, followed by others
    preset_ids = set(PRESET_MAPPING.keys())
    presets_first = [e for e in new_dataset if e['id'] in preset_ids]
    others = [e for e in new_dataset if e['id'] not in preset_ids]
    final_dataset = presets_first + others

    with open(APP_DATASET_JSON, 'w', encoding='utf-8') as f:
        json.dump(final_dataset, f, indent=2, ensure_ascii=False)

    print(f"Total exercises generated: {len(final_dataset)}")
    print(f"Unique GIF URLs: {len(seen_gifs)}")
    print(f"Preset exercises preserved: {len(presets_first)}/{len(PRESET_MAPPING)}")

if __name__ == '__main__':
    main()

