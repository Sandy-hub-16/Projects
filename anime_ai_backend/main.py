import json
import os
import requests
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse

load_dotenv()

app = FastAPI()

# -------------------- CORS --------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------------------- API KEYS & CONSTANTS --------------------
GROQ_API_KEY       = os.getenv("GROQ_API_KEY", "")
OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY", "")

GROQ_API_URL       = "https://api.groq.com/openai/v1/chat/completions"
OPENROUTER_API_URL = "https://openrouter.ai/api/v1/chat/completions"
PLACEHOLDER_IMAGE  = "https://placehold.co/300x450/png?text=Image+Unavailable"

# -------------------- JIKAN HELPERS (unchanged) --------------------

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
        image = PLACEHOLDER_IMAGE

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
                    or PLACEHOLDER_IMAGE
                ),
                "genres": [g["name"] for g in item.get("genres", [])]
            }

    except Exception:
        return None

    return None


# -------------------- AI PROMPT BUILDER --------------------

def build_ai_prompt(emoji: str) -> str:
    return f"""You are an anime recommendation assistant.
The user is feeling the mood expressed by this emoji: {emoji}

Based on this mood, recommend exactly 20 anime titles that match this feeling.
Return ONLY a valid JSON array with no extra text, markdown, or explanation.
Each item must have these exact fields:
- "title": English title (string)
- "japanese_title": Japanese/romaji title (string)
- "rating": score out of 10 (number e.g. 8.5, or "N/A" if unknown)
- "episodes": number of episodes (integer or "N/A" if unknown/ongoing)
- "image_url": leave as empty string ""
- "genres": array of genre strings (e.g. ["Action", "Comedy"])

Example:
[
  {{
    "title": "Clannad: After Story",
    "japanese_title": "Clannad: After Story",
    "rating": 9.0,
    "episodes": 24,
    "image_url": "",
    "genres": ["Drama", "Romance", "Slice of Life"]
  }}
]"""


def build_search_prompt(query: str) -> str:
    return f"""You are an anime search assistant.
The user is searching for anime matching this description: {query}

Return between 5 and 20 anime results depending on how many closely match the query.
Return ONLY a valid JSON array with no extra text, markdown, or explanation.
Each item must have these exact fields:
- "title": English title (string)
- "japanese_title": Japanese/romaji title (string)
- "rating": score out of 10 (number e.g. 8.5, or "N/A" if unknown)
- "episodes": number of episodes (integer or "N/A" if unknown/ongoing)
- "image_url": always leave as empty string ""
- "genres": array of genre strings (e.g. ["Action", "Comedy"])

Example:
[
  {{
    "title": "My Hero Academia",
    "japanese_title": "Boku no Hero Academia",
    "rating": 8.5,
    "episodes": 113,
    "image_url": "",
    "genres": ["Action", "Superhero", "School"]
  }}
]"""


# -------------------- AI CALLERS --------------------

def call_groq(prompt: str) -> list:
    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json",
    }
    body = {
        "model": "llama-3.1-8b-instant",
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.7,
    }
    print("[recommend] Calling Groq...")
    response = requests.post(GROQ_API_URL, headers=headers, json=body, timeout=30)
    response.raise_for_status()
    content = response.json()["choices"][0]["message"]["content"]
    content = content.strip()
    if content.startswith("```"):
        content = content.lstrip("```json").lstrip("```")
        content = content.rstrip("```").strip()
    print("[recommend] Groq responded OK")
    return json.loads(content)


def call_openrouter(prompt: str) -> list:
    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
    }
    body = {
        "model": "openai/gpt-oss-120b:free",
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.7,
    }
    print("[recommend] Calling OpenRouter...")
    response = requests.post(OPENROUTER_API_URL, headers=headers, json=body, timeout=30)
    response.raise_for_status()
    content = response.json()["choices"][0]["message"]["content"]
    content = content.strip()
    if content.startswith("```"):
        content = content.lstrip("```json").lstrip("```")
        content = content.rstrip("```").strip()
    print("[recommend] OpenRouter responded OK")
    return json.loads(content)


# -------------------- RESPONSE FORMATTERS --------------------

def format_ai_response(raw_list: list) -> list:
    result = []
    for item in raw_list:
        if not isinstance(item, dict):
            continue
        result.append({
            "title":          str(item.get("title") or "Unknown Anime"),
            "japanese_title": str(item.get("japanese_title") or item.get("title") or ""),
            "rating":         item.get("rating") if item.get("rating") not in (None, "") else "N/A",
            "episodes":       item.get("episodes") if item.get("episodes") not in (None, "") else "N/A",
            "image_url":      str(item.get("image_url") or ""),
            "genres":         list(item.get("genres") or []),
        })
    return result


def enrich_images(recommendations: list) -> list:
    for item in recommendations:
        url = item.get("image_url", "")
        if not url or url.strip() == "":
            item["image_url"] = PLACEHOLDER_IMAGE
    return recommendations


# -------------------- ROUTES --------------------

@app.get("/")
def home():
    return {"message": "Anime AI API is running"}


@app.get("/image-proxy")
def image_proxy(url: str):
    try:
        response = requests.get(url, stream=True)
        return StreamingResponse(response.raw, media_type="image/jpeg")
    except Exception:
        return {"error": "Image failed"}


episodes_db = {
    "Jujutsu Kaisen": [
        {
            "episode": 1,
            "title": "Ryomen Sukuna",
            "video_url": "https://www.youtube.com/watch?v=MPfZhgLiK6w"
        }
    ],
    "Sakamoto Days": [
        {
            "episode": 1,
            "title": "Taro Sakamoto",
            "video_url": "https://www.youtube.com/watch?v=2p0r2xg5l1E"
        }
    ],
    "Solo Leveling Season 2": [
        {
            "episode": 1,
            "title": "Arise",
            "video_url": "https://www.youtube.com/watch?v=6U0s0dF5e8c"
        }
    ]
}


@app.get("/episodes")
def get_episodes(title: str):
    """
    Fetch episode list for a given anime title.
    1. Search Jikan for the anime to get its MAL ID.
    2. Fetch up to 100 episodes from Jikan's episodes endpoint.
    3. Fall back to the local episodes_db if Jikan returns nothing.
    """
    try:
        # Step 1: resolve MAL ID from title
        search_url = f"https://api.jikan.moe/v4/anime?q={requests.utils.quote(title)}&limit=1"
        search_resp = requests.get(search_url, timeout=10)
        search_resp.raise_for_status()
        search_data = search_resp.json()

        results = search_data.get("data", [])
        if not results:
            return episodes_db.get(title, [])

        mal_id = results[0]["mal_id"]

        # Step 2: fetch episodes from Jikan
        eps_url = f"https://api.jikan.moe/v4/anime/{mal_id}/episodes"
        eps_resp = requests.get(eps_url, timeout=10)
        eps_resp.raise_for_status()
        eps_data = eps_resp.json()

        jikan_episodes = eps_data.get("data", [])
        if not jikan_episodes:
            return episodes_db.get(title, [])

        # Step 3: format into the shape the Flutter app expects
        formatted = []
        for ep in jikan_episodes:
            ep_num = ep.get("mal_id") or ep.get("episode_id") or len(formatted) + 1
            ep_title = ep.get("title") or f"Episode {ep_num}"
            formatted.append({
                "episode": ep_num,
                "title": ep_title,
                "video_url": "",   # no direct video — tapping opens streaming site
                "watch_url": "",   # no direct watch URL — tapping opens streaming site
            })

        return formatted

    except Exception as e:
        print(f"[episodes] Jikan fetch failed for '{title}': {e}")
        # Fall back to local DB
        return episodes_db.get(title, [])


@app.get("/anime/enrich")
def anime_enrich(title: str):
    return enrich_with_jikan(title) or {"error": "not found"}


@app.get("/recommend")
def recommend(mood: str):
    if not mood or not mood.strip():
        raise HTTPException(status_code=400, detail="mood parameter is required")

    prompt = build_ai_prompt(mood)
    raw_list = None

    # Primary: Groq
    try:
        raw_list = call_groq(prompt)
    except Exception as groq_err:
        print(f"Groq failed: {groq_err}")

    # Fallback: OpenRouter
    if raw_list is None:
        try:
            raw_list = call_openrouter(prompt)
        except Exception as or_err:
            print(f"OpenRouter failed: {or_err}")

    if raw_list is None:
        raise HTTPException(
            status_code=503,
            detail="Both Groq and OpenRouter are unavailable. Please try again later."
        )

    formatted = format_ai_response(raw_list)
    enriched  = enrich_images(formatted)
    return enriched


@app.get("/search/ai")
def search_ai(query: str = ""):
    if not query or not query.strip():
        raise HTTPException(status_code=400, detail="query parameter is required")

    prompt = build_search_prompt(query)
    raw_list = None

    # Primary: Groq
    try:
        raw_list = call_groq(prompt)
    except Exception as groq_err:
        print(f"[search/ai] Groq failed: {groq_err}")

    # Fallback: OpenRouter
    if raw_list is None:
        try:
            raw_list = call_openrouter(prompt)
        except Exception as or_err:
            print(f"[search/ai] OpenRouter failed: {or_err}")

    if raw_list is None:
        raise HTTPException(
            status_code=503,
            detail="Both Groq and OpenRouter are unavailable. Please try again later."
        )

    return format_ai_response(raw_list)


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
