import requests
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
import requests
import pandas as pd
import os
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

app = FastAPI()

# -------------------- CORS --------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------------------- LOAD DATA --------------------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
csv_path = os.path.join(BASE_DIR, "anime.csv")
anime = pd.read_csv(csv_path)

# -------------------- HELPERS --------------------
def safe_genre_filter(df, genres):
    if not genres:
        return df.head(10)

    pattern = '|'.join(genres)

    return df[
        df['Genres'].fillna('').str.contains(pattern, case=False, na=False)
    ]

def clean_value(value, fallback="N/A"):
    if value is None:
        return fallback
    value = str(value).strip()
    if value.upper() == "UNKNOWN" or value == "":
        return fallback
    return value


def format_anime(row):
    return {
        "title": clean_value(row.get("English name")) 
                if clean_value(row.get("English name")) != "N/A"
                else clean_value(row.get("Name"), "Unknown Anime"),

        "japanese_title": clean_value(row.get("Name"), "Unknown Anime"),
        "rating": clean_value(row.get("Score"), "N/A"),
        "episodes": clean_value(row.get("Episodes"), "N/A"),
        "image_url": clean_value(
            row.get("Image URL"),
            "https://placehold.co/300x450/png?text=Image+Unavailable"
        ),
        "genres": [
            g.strip() for g in str(row.get("Genres", "")).split(",")
            if g.strip().upper() != "UNKNOWN" and g.strip() != ""
        ]
    }


def fetch_jikan_data(url):
    try:
        response = requests.get(url, timeout=5)
        response.raise_for_status()
        return response.json()
    except Exception as e:
        print("Jikan error:", e)
        return None


def format_jikan(item):
    image = (
        item.get("images", {}).get("webp", {}).get("large_image_url")
        or item.get("images", {}).get("jpg", {}).get("large_image_url")
    )

    if not image or image.strip() == "":
        image = "https://placehold.co/300x450/png?text=Image+Unavailable"

    return {
        "title": item.get("title"),
        "japanese_title": item.get("title_japanese"),
        "rating": item.get("score"),
        "episodes": item.get("episodes"),
        "image_url": image,
        "genres": [g["name"] for g in item.get("genres", [])]
    }

def enrich_with_jikan(title):
    try:
        url = f"https://api.jikan.moe/v4/anime?q={title}&limit=1"
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()

        if data["data"]:
            item = data["data"][0]

            return {
                "title": item.get("title"),
                "japanese_title": item.get("title_japanese"),
                "rating": item.get("score"),
                "episodes": item.get("episodes"),
                "image_url": (
                    item.get("images", {}).get("webp", {}).get("large_image_url")
                    or item.get("images", {}).get("jpg", {}).get("large_image_url")
                    or "https://placehold.co/300x450/png?text=Image+Unavailable"
                ),
                "genres": [g["name"] for g in item.get("genres", [])]
            }

    except:
        return None

    return None

# -------------------- ROUTES --------------------

@app.get("/image-proxy")
def image_proxy(url: str):
    try:
        response = requests.get(url, stream=True)
        return StreamingResponse(response.raw, media_type="image/jpeg")
    except:
        return {"error": "Image failed"}

@app.get("/")
def home():
    return {"message": "Anime AI API is running"}


mood_map = {
    "happy": {
        "genres": ["Comedy", "Slice of Life"],
        "keywords": ["funny", "school", "friendship", "light"]
    },
     "sad": {
        "genres": ["Drama", "Romance"],
        "keywords": ["tragedy", "love", "loss", "emotional"]
    },
    "angry": {
        "genres": ["Action", "Shounen"],
        "keywords": ["fight", "revenge", "battle", "power"]
    },
    "relaxed": {
        "genres": ["Fantasy", "Adventure"],
        "keywords": ["calm", "journey", "magic", "peaceful"]
    }
}

@app.get("/anime/enrich")
def anime_enrich(title: str):
    return enrich_with_jikan(title) or {"error": "not found"}


# Build once
anime['combined'] = anime['Genres'].fillna('') + " " + anime['Name'].fillna('')
vectorizer = TfidfVectorizer(stop_words='english')
tfidf_matrix = vectorizer.fit_transform(anime['combined'])

@app.get("/recommend")
def recommend(mood: str):
    mood_data = mood_map.get(mood.lower(), {})
    
    genres = mood_data.get("genres", [])
    keywords = mood_data.get("keywords", [])

    query = " ".join(genres + keywords)
    query_vec = vectorizer.transform([query])
    similarity = cosine_similarity(query_vec, tfidf_matrix).flatten()

    #  TOP AI MATCHES
    ai_indices = similarity.argsort()[-5:][::-1]

    #  RANDOM DISCOVERY
    random_indices = np.random.choice(len(anime), 3)

    #  POPULAR (HIGH SCORE/RATING)
    popular = anime.sort_values(by="Score", ascending=False).head(20)
    popular_indices = np.random.choice(popular.index, 2)

    final_indices = list(set(ai_indices.tolist() + random_indices.tolist() + popular_indices.tolist()))

    return [format_anime(anime.iloc[i]) for i in final_indices[:10]]

@app.get("/recent")
def recent_updates():
    url = "https://api.jikan.moe/v4/seasons/now"
    data = fetch_jikan_data(url)

    if not data:
        return {"error": "Failed to fetch recent anime"}

    return [format_jikan(item) for item in data["data"][:10]]


@app.get("/trending")
def trending():
    url = "https://api.jikan.moe/v4/top/anime"
    data = fetch_jikan_data(url)

    if not data:
        return {"error": "Failed to fetch trending anime"}

    return [format_jikan(item) for item in data["data"][:10]]