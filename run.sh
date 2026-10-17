#!/bin/bash
set +H
echo "🐉 กำลังเริ่มระบบมังกรฟ้า..."
mkdir -p uploads templates
pip install flask pillow --quiet

# สร้างเว็บอัตโนมัติ
cat > app.py << 'PYEOF'
from flask import Flask, render_template, request, send_from_directory
from PIL import Image
import os
app = Flask(__name__)
os.makedirs("uploads", exist_ok=True)

@app.route("/")
def index(): return render_template("index.html")

@app.route("/create", methods=["POST"])
def create():
    files = request.files.getlist("frames")
    imgs = []
    for f in files:
        im = Image.open(f).convert("RGBA").resize((370,320))
        imgs.append(im)
    path = "uploads/sticker.apng"
    if imgs:
        imgs[0].save(path, save_all=True, append_images=imgs[1:], duration=200, loop=0)
    
    sound = request.files.get("sound")
    spath = ""
    if sound:
        spath = "uploads/sound.m4a"
        sound.save(spath)
    return f"สร้างเสร็จแล้ว! <br> APNG: <a href='/{path}'>{path}</a><br> Sound: {spath}<br><img src='/{path}' width=200> <br><a href='/'>กลับ</a>"

@app.route("/uploads/<p>")
def up(p): return send_from_directory("uploads", p)

if __name__ == "__main__":
    print("เปิดที่ http://127.0.0.1:5000")
    app.run(host="0.0.0.0", port=5000)
PYEOF

cat > templates/index.html << 'HTMLEOF'
<html><meta charset="utf-8"><body style="text-align:center;font-family:sans-serif">
<h1>🐉 มังกรฟ้า STUDIO - รันใน Termux แล้ว!</h1>
<form action="/create" method="post" enctype="multipart/form-data">
อัพโหลดเฟรมหลายรูป (PNG):<br><input type="file" name="frames" multiple required><br><br>
เสียง M4A (3วิ):<br><input type="file" name="sound"><br><br>
<button type="submit" style="padding:15px;background:#1E90FF;color:white;border-radius:10px">สร้าง APNG+SOUND เลย</button>
</form>
<p>ไฟล์ทั้งหมดจะอยู่ในโฟลเดอร์ uploads พร้อมอัพขึ้น LINE ได้เลย</p>
</body></html>
HTMLEOF

python app.py
