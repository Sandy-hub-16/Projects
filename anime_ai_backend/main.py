from fastapi import FastAPI
import pandas as pd
import os
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load dataset
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
csv_path = os.path.join(BASE_DIR, "anime.csv")

anime = pd.read_csv(csv_path)

def clean_value(value, fallback="N/A"):
    if value is None:
        return fallback
    if str(value).strip().upper() == "UNKNOWN":
        return fallback
    if str(value).strip() == "":
        return fallback
    return value

# print(anime.columns) for debugging

@app.get("/")
def home():
    return {"message": "Anime AI API is running"}

mood_map = {
    "happy": ["Comedy", "Slice of Life"],
    "sad": ["Drama", "Romance"],
    "angry": ["Action", "Shounen"],
    "relaxed": ["Fantasy", "Adventure"]
}

@app.get("/recommend")
def recommend(mood: str):
    genres = mood_map.get(mood.lower(), [])
    
    filtered = anime[anime['Genres'].str.contains('|'.join(genres), na=False)]

    results = filtered.head(10)

    anime_list = []

    for _, row in results.iterrows():
        anime_list.append({
            "title": clean_value(row.get("English name")) 
                    if clean_value(row.get("English name")) != "N/A"
                    else clean_value(row.get("Name"), "Unknown Anime"),

            "japanese_title": clean_value(row.get("Name"), "Unknown Anime"),

            "rating": clean_value(row.get("Score"), "N/A"),

            "episodes": clean_value(row.get("Episodes"), "N/A"),

            "image_url": clean_value(
                row.get("Image URL"),
                "https://via.placeholder.com/150"
            ),

            "genres": [
                g.strip() for g in str(row.get("Genres", "")).split(",")
                if g.strip().upper() != "UNKNOWN" and g.strip() != ""
            ]
        })

    return anime_list


@app.get("/recent")
def recent_updates():
    results = anime.sort_values(by="Score", ascending=False).head(10)

    anime_list = []

    for _, row in results.iterrows():
        anime_list.append({
            "title": clean_value(row.get("English name")) 
                    if clean_value(row.get("English name")) != "N/A"
                    else clean_value(row.get("Name"), "Unknown Anime"),

            "japanese_title": clean_value(row.get("Name"), "Unknown Anime"),

            "rating": clean_value(row.get("Score"), "N/A"),

            "episodes": clean_value(row.get("Episodes"), "N/A"),

            "image_url": clean_value(
                row.get("Image URL"),
                "https://via.placeholder.com/150"
            ),

            "genres": [
                g.strip() for g in str(row.get("Genres", "")).split(",")
                if g.strip().upper() != "UNKNOWN" and g.strip() != ""
            ]
        })

    return anime_list