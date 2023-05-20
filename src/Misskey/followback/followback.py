# https://girak.moe/api/following/create
from misskey import Misskey
from dotenv import load_dotenv
import os

# 初期化
load_dotenv()
api = Misskey('https://girak.moe/')
api.token = os.getenv("API_TOKEN")

# フォロワー一覧取得
# フォロイーと照らし合わせて相互かどうかを確認
# フォローしてない場合は一括フォロバする
# ノート
print(api.users_followers(user_id=""))
