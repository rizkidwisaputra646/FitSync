
import os
import csv
from pathlib import Path

import cloudinary
import cloudinary.uploader
from dotenv import load_dotenv

# =====================================
# KONFIGURASI
# =====================================

BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env")

cloud_name = os.getenv("CLOUDINARY_CLOUD_NAME")
api_key = os.getenv("CLOUDINARY_API_KEY")
api_secret = os.getenv("CLOUDINARY_API_SECRET")

if not all([cloud_name, api_key, api_secret]):
    raise ValueError("Konfigurasi Cloudinary di .env belum lengkap!")

cloudinary.config(
    cloud_name=cloud_name,
    api_key=api_key,
    api_secret=api_secret,
    secure=True
)

GIF_DIR = BASE_DIR / "r2_assets" / "gifs"
IMAGE_DIR = BASE_DIR / "r2_assets" / "images"

OUTPUT_CSV = BASE_DIR / "cloudinary_urls.csv"

# =====================================
# UPLOAD FUNCTION
# =====================================

results = []
success = 0
failed = 0

def upload_folder(folder_name, local_folder):

    global success, failed

    if not local_folder.exists():
        print(f"[SKIP] Folder tidak ditemukan: {local_folder}")
        return

    files = sorted(
        file for file in local_folder.rglob("*")
        if file.is_file()
    )

    print(f"\nUpload {folder_name}: {len(files)} file")

    for index, file_path in enumerate(files, start=1):

        relative_path = file_path.relative_to(local_folder)
        category = relative_path.parts[0]

        # Nama publik unik dan mempertahankan kategori
        public_id = (
            f"fitsync/{folder_name}/"
            f"{relative_path.with_suffix('').as_posix()}"
        )

        try:
            result = cloudinary.uploader.upload(
                str(file_path),
                public_id=public_id,
                resource_type="image",
                overwrite=True,
                unique_filename=False
            )

            results.append({
                "type": folder_name,
                "category": category,
                "filename": file_path.name,
                "public_id": result["public_id"],
                "url": result["secure_url"]
            })

            success += 1
            print(f"[{index}/{len(files)}] OK: {public_id}")

        except Exception as error:
            failed += 1
            print(f"[ERROR] {file_path}: {error}")

# =====================================
# MULAI UPLOAD
# =====================================

print("================================")
print("     FITSYNC CLOUDINARY UPLOAD")
print("================================")

upload_folder("gifs", GIF_DIR)
upload_folder("images", IMAGE_DIR)

# =====================================
# SIMPAN CSV
# =====================================

with open(OUTPUT_CSV, "w", newline="", encoding="utf-8") as file:

    columns = [
        "type",
        "category",
        "filename",
        "public_id",
        "url"
    ]

    writer = csv.DictWriter(file, fieldnames=columns)
    writer.writeheader()
    writer.writerows(results)

# =====================================
# RINGKASAN
# =====================================

print("\n================================")
print("             SELESAI")
print("================================")
print(f"Berhasil : {success}")
print(f"Gagal    : {failed}")
print(f"Total    : {success + failed}")
print(f"CSV      : {OUTPUT_CSV}")
