import csv
import json
import re
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

CLOUDINARY_CSV = BASE_DIR / "cloudinary_urls.csv"
R2_EXERCISES_JSON = BASE_DIR / "r2_assets" / "data" / "exercises.json"
APP_DATASET_JSON = BASE_DIR / "assets" / "data" / "exercises_dataset.json"

def clean_tokens(s):
    if not s:
        return []
    tokens = re.sub(r'[^a-z0-9]', ' ', s.lower()).split()
    return [t[:-1] if t.endswith('s') and len(t) > 3 else t for t in tokens]

def main():
    print("=== SYNC CLOUDINARY URLS TO FITSYNC DATASET ===")

    # 1. Read Cloudinary CSV
    if not CLOUDINARY_CSV.exists():
        print(f"ERROR: {CLOUDINARY_CSV} not found!")
        return

    with open(CLOUDINARY_CSV, "r", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        csv_rows = list(reader)

    gif_map = {r["filename"]: r["url"] for r in csv_rows if r["type"] == "gifs"}
    img_map = {r["filename"]: r["url"] for r in csv_rows if r["type"] == "images"}

    print(f"Loaded {len(gif_map)} GIF URLs and {len(img_map)} Image URLs from CSV.")

    # 2. Update r2_assets/data/exercises.json
    with open(R2_EXERCISES_JSON, "r", encoding="utf-8-sig") as f:
        db_exs = json.load(f)

    updated_db_count = 0
    for ex in db_exs:
        gif_file = ex["gif_url"].split("/")[-1]
        img_file = ex["image"].split("/")[-1]

        if gif_file in gif_map:
            ex["gif_url"] = gif_map[gif_file]
            updated_db_count += 1
        if img_file in img_map:
            ex["image"] = img_map[img_file]

    with open(R2_EXERCISES_JSON, "w", encoding="utf-8") as f:
        json.dump(db_exs, f, indent=2, ensure_ascii=False)

    print(f"Updated {updated_db_count}/{len(db_exs)} entries in {R2_EXERCISES_JSON.name} with Cloudinary URLs.")

    # 3. Match and Update assets/data/exercises_dataset.json (Flutter active catalog)
    with open(APP_DATASET_JSON, "r", encoding="utf-8") as f:
        app_exs = json.load(f)

    # Specific curated overrides for exact best visual representations
    manual_overrides = {
        "barbell-bench-press": "0025",
        "incline-barbell-bench-press": "0047",
        "decline-barbell-bench-press": "0033",
        "flat-dumbbell-bench-press": "0289",
        "incline-dumbbell-press": "0314",
        "barbell-bent-over-row": "0027",
        "lat-pulldown": "0197",
        "barbell-deadlift": "0032",
        "barbell-back-squat": "0043",
        "barbell-bicep-curl": "0031",
        "dumbbell-bicep-curl": "0294",
        "hammer-curl-dumbbell": "0313",
        "triceps-rope-pushdown": "0241",
        "dumbbell-lateral-raise": "0334",
        "cable-lateral-raise": "0178",
        "standing-calf-raise-machine": "0738",
        "leg-press-45": "0739",
        "leg-extension-machine": "0585",
        "lying-leg-curl-machine": "0589",
        "standard-push-up": "0662",
        "diamond-push-up": "0290",
        "chest-dips": "0251",
        "ab-wheel-rollout": "0971",
        "hanging-leg-raise": "0472",
        "standard-forearm-plank": "0464",
        "seated-cable-row": "0198",
        "pec-deck-fly-machine": "0577",
        "romanian-deadlift": "0085",
        "walking-lunges-dumbbell": "0337",
        "goblet-squat-dumbbell": "0310",
        "barbell-hip-thrust": "0046",
    }

    db_by_id = {d["id"]: d for d in db_exs}

    matched_app_count = 0
    for app_item in app_exs:
        app_id = app_item.get("id", "")
        best_match = None

        if app_id in manual_overrides and manual_overrides[app_id] in db_by_id:
            best_match = db_by_id[manual_overrides[app_id]]
        else:
            # Algoritma pencocokan cerdas berdasarkan nama, alat, dan target otot
            a_tokens = set(clean_tokens(app_item.get("name", "")))
            a_eq = set(clean_tokens(app_item.get("equipment", "")))
            a_muscle = app_item.get("targetMuscle", "").lower()

            best_score = -1
            for d in db_exs:
                d_tokens = set(clean_tokens(d.get("name", "")))
                d_eq = set(clean_tokens(d.get("equipment", "")))
                d_body = d.get("body_part", "").lower()
                d_target = d.get("target", "").lower()

                overlap = len(a_tokens.intersection(d_tokens))
                score = overlap * 10

                if a_eq and d_eq and a_eq.intersection(d_eq):
                    score += 5

                if a_muscle in d_body or a_muscle in d_target:
                    score += 4
                elif a_muscle == "chest" and "pectorals" in d_target:
                    score += 4
                elif a_muscle == "abs & core" and ("abs" in d_target or "waist" in d_body):
                    score += 4
                elif a_muscle == "legs" and ("quads" in d_target or "glutes" in d_target or "calves" in d_target):
                    score += 4

                if score > best_score:
                    best_score = score
                    best_match = d

        if best_match:
            app_item["gifUrl"] = best_match["gif_url"]
            app_item["thumbnailUrl"] = best_match["image"]
            matched_app_count += 1

    with open(APP_DATASET_JSON, "w", encoding="utf-8") as f:
        json.dump(app_exs, f, indent=2, ensure_ascii=False)

    print(f"Updated all {matched_app_count}/{len(app_exs)} exercises in {APP_DATASET_JSON.name} with real Cloudinary URLs!")
    print("=== FINISHED SUCCESSFULLY ===")

if __name__ == "__main__":
    main()

